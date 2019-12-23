package se2.SafeStreets.back.model

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document


@Document(collection = "user")
class User() {

    @Id
    @JsonSerialize(using = ObjectIDSerializer::class)
    var id: ObjectId? = null

    @Indexed(unique = true)
    lateinit var username: String

    @JsonIgnore
    var active: Boolean = true

    lateinit var password: String
    lateinit var name: String
    lateinit var lastName: String
    lateinit var type: UserType

    @JsonIgnore
    var pendingReviews: Int = 0

    constructor(username:String, password:String, name:String, lastName:String, type:UserType) : this() {
        this.username = username
        this.password = password
        this.name = name
        this.lastName = lastName
        this.type = type
    }

    @JsonProperty("pendingReviews")
    fun jsonGetPendingReviews(): Int = pendingReviews
}
