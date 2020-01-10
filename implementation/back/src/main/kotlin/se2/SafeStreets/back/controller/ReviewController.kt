package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import se2.SafeStreets.back.model.Dto.ReviewDto
import se2.SafeStreets.back.model.form.ReviewForm
import se2.SafeStreets.back.service.ReviewRecruiter
import se2.SafeStreets.back.service.UserService
import javax.validation.Valid

/**
 * Controller that handles violation report reviews.
 */
@RestController
@RequestMapping("/review")
class ReviewController(
        val userService: UserService,
        val reviewRecruiter: ReviewRecruiter
) {

    @GetMapping("/pending/me")
    fun getPendingReviews(): ResponseEntity<List<ReviewDto>> {
        return userService.findCurrent()?.let {
            val result = reviewRecruiter.getPendingReviews(it)
            return ResponseEntity.ok(result)
        } ?: ResponseEntity.notFound().build()
    }

    @PostMapping
    fun submitReview(@Valid @RequestBody reviewForm: ReviewForm): ResponseEntity<Any> {
        return userService.findCurrent()?.let {
            val id = ObjectId(reviewForm.reviewId)
            reviewRecruiter.submitReview(it, id, reviewForm.licensePlate, reviewForm.clear)
            return ResponseEntity.noContent().build()
        } ?: ResponseEntity.notFound().build()
    }

}