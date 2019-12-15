package se2.SafeStreets.back.model

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonProperty
import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.index.Indexed
import org.springframework.data.mongodb.core.mapping.Document

@Document(collection = "user")
class User(@Indexed(unique = true) var username:String, var password:String, var name:String, var lastName:String, var type:UserType) {

    @Id
    @JsonIgnore
    var id: ObjectId? = null

    var active: Boolean = true

    @JsonProperty("id")
    fun getId() = id?.toHexString()
}

