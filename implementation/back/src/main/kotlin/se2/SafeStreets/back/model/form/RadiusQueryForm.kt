package se2.SafeStreets.back.model.form

import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

class RadiusQueryForm(val location: Array<Double>, val radius: Double, val from: LocalDateTime, val to: LocalDateTime, val types: List<ViolationType>)

