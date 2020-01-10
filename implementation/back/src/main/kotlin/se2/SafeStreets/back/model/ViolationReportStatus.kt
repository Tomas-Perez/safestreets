package se2.SafeStreets.back.model

/**
 * Enum for the different states of a violation report.
 */
enum class ViolationReportStatus {
    HIGH_CONFIDENCE,
    LOW_CONFIDENCE,
    INVALID,
    REVIEW,
    INCOMPLETE
}
