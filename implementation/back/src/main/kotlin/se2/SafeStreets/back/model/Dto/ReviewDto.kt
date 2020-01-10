package se2.SafeStreets.back.model.Dto

import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId
import se2.SafeStreets.back.model.ObjectIDSerializer

/**
 * Data Transfer Object for reviews.
 */
class ReviewDto() {

    @JsonSerialize(using = ObjectIDSerializer::class)
    lateinit var id: ObjectId

    lateinit var imageName: String

    constructor(id: ObjectId, imageName: String): this() {
        this.id = id
        this.imageName = imageName
    }
}

