package se2.SafeStreets.back.service

import org.bson.types.ObjectId
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import se2.SafeStreets.back.model.*
import se2.SafeStreets.back.repository.ReviewRepository
import se2.SafeStreets.back.repository.UserRepository
import se2.SafeStreets.back.repository.ViolationRepository

@Service
class ReviewRecruiter(
        val userRepository: UserRepository,
        val reviewRepository: ReviewRepository,
        val violationRepository: ViolationRepository) {

    companion object {
        const val REVIEWS_AMOUNT = 10
        const val REQUIRED_REVIEWS = 5
    }

    fun sendForReview(report: ViolationReport) {
        val candidates = userRepository.findAllByActiveIsTrueOrderByPendingReviewsAsc()
        val selected: List<User> =
                if (candidates.size >= REVIEWS_AMOUNT)
                    candidates.subList(0, REVIEWS_AMOUNT)
                else
                    candidates
        selected.forEach { user ->
            val review = Review(user.id!!, report.id!!, ReviewStatus.PENDING)
            reviewRepository.save(review)
            user.pendingReviews++
            userRepository.save(user)
        }
    }

    fun getPendingReviews(user: User): List<ReviewDto> {
        val reviews: List<Review> = reviewRepository.findAllByUserIdAndStatus(user.id!!, ReviewStatus.PENDING)
        return reviews.map {
            val report = violationRepository.findByIdOrNull(it.reportId)
            report?.let { r -> ReviewDto(r.licenseImage!!.name, it.id) } ?: throw NoSuchElementException("Report not found")
        }
    }

    fun submitReview(user: User, reviewId: ObjectId, license: String) {
        val review = reviewRepository.findByIdOrNull(reviewId)
        return review?.let {

            if (review.status != ReviewStatus.PENDING) return

            val report = violationRepository.findByIdOrNull(it.reportId)
            report?.let {
                // Update the review
                review.status = ReviewStatus.COMPLETED
                review.license = license.replace("\\s+", "").toUpperCase()
                reviewRepository.save(review)
                user.pendingReviews--
                userRepository.save(user)

                // Check if reached required amount of reviews
                val completedReviews = reviewRepository.findAllByReportIdAndStatus(review.reportId, ReviewStatus.COMPLETED)
                if (completedReviews.size >= REQUIRED_REVIEWS) {
                    // Update confidence/validity
                    var matches = 0
                    for (completedReview in completedReviews) {
                        if (completedReview.license == report.licensePlate)
                            matches++
                    }
                    val res = matches.toFloat() / REQUIRED_REVIEWS.toFloat()
                    when {
                        res >= 0.8F -> {
                            report.status = ViolationReportStatus.HIGH_CONFIDENCE
                        }
                        res >= 0.6F -> {
                            report.status = ViolationReportStatus.LOW_CONFIDENCE
                        }
                        else -> {
                            report.status = ViolationReportStatus.INVALID
                        }
                    }
                    violationRepository.save(report)

                    // Cancel other pending reviews of the same report
                    val pendingReviews = reviewRepository.findAllByReportIdAndStatus(review.reportId, ReviewStatus.PENDING)
                    for (pendingReview in pendingReviews) {
                        pendingReview.status = ReviewStatus.CANCELLED
                        reviewRepository.save(pendingReview)
                        userRepository.findByIdOrNull(pendingReview.userId)?.let { pendingUser ->
                            pendingUser.pendingReviews--
                            userRepository.save(pendingUser)
                        }
                    }
                }
            } ?: throw NoSuchElementException("Report not found")
        } ?: throw NoSuchElementException("Review not found")
    }

}