package se2.SafeStreets.back.model.form

import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

data class ViolationReportForm(
        val licensePlate:String,
        val description:String,
        val dateTime:LocalDateTime,
        val type:ViolationType
)