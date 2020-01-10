package se2.SafeStreets.back.model.form

import se2.SafeStreets.back.model.ViolationReportStatus
import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

/**
 * Form for querying violation reports within certain radius.
 */
class RadiusQueryForm(val location: Array<Double>,
                      val radius: Double,
                      val from: LocalDateTime,
                      val to: LocalDateTime,
                      val status: List<ViolationReportStatus>,
                      val types: List<ViolationType>)

