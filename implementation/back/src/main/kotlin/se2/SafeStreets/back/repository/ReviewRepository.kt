package se2.SafeStreets.back.repository

import org.bson.types.ObjectId
import org.springframework.data.mongodb.repository.MongoRepository
import se2.SafeStreets.back.model.Review
import se2.SafeStreets.back.model.ReviewStatus

interface ReviewRepository: MongoRepository<Review, ObjectId> {
    fun findAllByStatus(status: ReviewStatus): List<Review>
    fun findAllByUserIdAndStatus(userId: ObjectId, status: ReviewStatus): List<Review>
    fun findAllByReportIdAndStatus(reportId: ObjectId, status: ReviewStatus): List<Review>
}