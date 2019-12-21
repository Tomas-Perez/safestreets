package se2.SafeStreets.back.model

import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId

data class Image(
        @JsonSerialize(using = ObjectIDSerializer::class) val id: ObjectId,
        val name: String)
