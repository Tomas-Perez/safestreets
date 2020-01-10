package se2.SafeStreets.back.model

import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId

/**
 * Class that represents an image with a name.
 */
data class Image(
        @JsonSerialize(using = ObjectIDSerializer::class) val id: ObjectId,
        val name: String)
