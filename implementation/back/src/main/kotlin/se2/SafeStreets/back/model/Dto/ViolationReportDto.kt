package se2.SafeStreets.back.model.Dto

import org.bson.types.ObjectId
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.ViolationReportStatus
import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

class ViolationReportDto() {

    lateinit var description: String
    lateinit var dateTime: LocalDateTime
    lateinit var type: ViolationType
    lateinit var location: Array<Double>
    lateinit var status: ViolationReportStatus

    constructor(description: String, dateTime:LocalDateTime, type: ViolationType, location: Array<Double>, status: ViolationReportStatus) : this() {
        this.description = description
        this.dateTime = dateTime
        this.type = type
        this.location = location
        this.status = status
    }

    companion object {
        fun fromReport(report: ViolationReport): ViolationReportDto {
            return ViolationReportDto(report.description, report.dateTime, report.type, report.location.coordinates, report.status)
        }
    }
}