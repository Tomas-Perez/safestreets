package se2.SafeStreets.back.model

import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document

/**
 * Represents the relationship between a user and their api key.
 */
@Document("api-key-user")
class ApiKeyUser(
        @Indexed(unique = true)
        val userId: ObjectId,
        val apiKey: String) {
    @Id
    lateinit var id: ObjectId
}

