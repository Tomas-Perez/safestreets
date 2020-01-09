package se2.SafeStreets.back.model.Dto

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId
import se2.SafeStreets.back.model.ObjectIDSerializer
import se2.SafeStreets.back.model.UserType


class UserDto() {

    @JsonSerialize(using = ObjectIDSerializer::class)
    var id: ObjectId? = null

    lateinit var email: String
    lateinit var username: String
    lateinit var name: String
    lateinit var surname: String
    lateinit var type: UserType

    @JsonIgnore
    var pendingReviews: Int = 0

    constructor(id: ObjectId, email:String, username:String, name:String, surname:String, type:UserType) : this() {
        this.id = id
        this.email = email
        this.username = username
        this.name = name
        this.surname = surname
        this.type = type
    }

    @JsonProperty("pendingReviews")
    fun jsonGetPendingReviews(): Int = pendingReviews
}
