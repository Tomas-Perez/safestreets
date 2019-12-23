package se2.SafeStreets.back.model

import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@Document(collection = "review")
class Review(
        val userId: ObjectId,
        val reportId: ObjectId,
        var status: ReviewStatus
) {
    @Id
    lateinit var id: ObjectId

    var license: String? = null
}

