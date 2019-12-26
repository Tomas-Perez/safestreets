package se2.SafeStreets.back.repository

import org.bson.types.ObjectId
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import se2.SafeStreets.back.model.ApiKeyUser

@Repository
interface ApiKeyRepository: MongoRepository<ApiKeyUser, ObjectId> {
    fun findFirstByUserId(userId: ObjectId): ApiKeyUser?
    fun findFirstByApiKey(key: String): ApiKeyUser?
}
