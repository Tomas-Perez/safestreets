package se2.SafeStreets.back.model

import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId

class ReviewDto() {

    @JsonSerialize(using = ObjectIDSerializer::class)
    lateinit var id: ObjectId

    lateinit var imageName: String

    constructor(id: ObjectId, imageName: String): this() {
        this.id = id
        this.imageName = imageName
    }
}

