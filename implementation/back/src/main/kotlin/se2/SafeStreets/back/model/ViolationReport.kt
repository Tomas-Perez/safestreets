package se2.SafeStreets.back.model

import com.fasterxml.jackson.databind.annotation.JsonSerialize
import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.time.LocalDateTime

@Document(collection = "violation-report")
class ViolationReport() {
    //TODO Add location

    @Id
    @JsonSerialize(using = ObjectIDSerializer::class)
    var id: ObjectId? = null

    @JsonSerialize(using = ObjectIDSerializer::class)
    lateinit var filledBy: ObjectId

    lateinit var licensePlate: String
    lateinit var description: String
    lateinit var dateTime: LocalDateTime
    lateinit var type: ViolationType

    var licenseImage: Image? = null
    var images: ArrayList<Image> = ArrayList()

    constructor(filledBy:ObjectId, licensePlate:String, description: String, dateTime:LocalDateTime, type: ViolationType) : this() {
        this.filledBy = filledBy
        this.licensePlate = licensePlate
        this.description = description
        this.dateTime = dateTime
        this.type = type
    }


}