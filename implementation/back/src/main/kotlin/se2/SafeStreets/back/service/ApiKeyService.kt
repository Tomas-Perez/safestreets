package se2.SafeStreets.back.service

import org.bson.types.ObjectId
import org.springframework.stereotype.Service
import se2.SafeStreets.back.model.ApiKeyUser
import se2.SafeStreets.back.repository.ApiKeyRepository

@Service
class ApiKeyService(private val apiKeyRepository: ApiKeyRepository) {

    fun getApiKeyByUserId(userId: ObjectId): String {
        return apiKeyRepository.findFirstByUserId(userId)?.apiKey ?: generateApiKey(userId)
    }

    fun generateApiKey(userId: ObjectId): String {
        val key = "${ObjectId.get().toHexString()}${ObjectId.get().toHexString()}"
        val apiKeyUser = ApiKeyUser(userId, key)
        apiKeyRepository.save(apiKeyUser)
        return key
    }

    fun getApiKeyUserByKey(key: String): ApiKeyUser? {
        return apiKeyRepository.findFirstByApiKey(key)
    }

}
