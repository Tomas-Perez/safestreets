package se2.SafeStreets.back.model

/**
 * Wrapper of an license recognition result with only the necessary info.
 */
data class RecognisedLicense(val license: String, val confidence: Float)

