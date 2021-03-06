package se2.SafeStreets.back.repository

import org.bson.types.ObjectId
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import se2.SafeStreets.back.model.User
import java.util.*

/**
 * Repository for User objects.
 */
@Repository
interface UserRepository: MongoRepository<User, ObjectId> {
    fun findAllByActiveIsTrue(): List<User>
    fun findFirstByEmailAndActiveIsTrue(email: String): User?
    fun findAllByActiveIsTrueOrderByPendingReviewsAsc(): List<User>
}