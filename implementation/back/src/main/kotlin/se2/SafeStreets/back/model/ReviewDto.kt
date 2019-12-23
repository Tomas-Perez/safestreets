package se2.SafeStreets.back.model

import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId

class ReviewDto(val imageName: String, @JsonSerialize(using = ObjectIDSerializer::class) val id: ObjectId)

