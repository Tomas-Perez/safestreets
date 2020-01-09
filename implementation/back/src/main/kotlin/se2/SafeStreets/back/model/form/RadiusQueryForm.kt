package se2.SafeStreets.back.model.form

import se2.SafeStreets.back.model.ViolationReportStatus
import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

class RadiusQueryForm(val southWest: Array<Double>,
                      val northEast: Double,
                      val from: LocalDateTime,
                      val to: LocalDateTime,
                      val status: List<ViolationReportStatus>,
                      val types: List<ViolationType>)

