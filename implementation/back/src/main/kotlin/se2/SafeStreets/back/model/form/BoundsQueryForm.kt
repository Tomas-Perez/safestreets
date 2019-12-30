package se2.SafeStreets.back.model.form

import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

class BoundsQueryForm (val bottomLeft: Array<Double>, val upperRight: Array<Double>, val from: LocalDateTime, val to: LocalDateTime, val types: List<ViolationType>)

