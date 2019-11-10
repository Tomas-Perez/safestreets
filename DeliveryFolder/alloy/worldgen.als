module worldgen
open model
open reportDefinitions

pred ReportWithNoDetectedLicensePlateExists {
	some r: AnalyzedReport | reportHasNoDetectedLicensePlate[r]
}

run ReportWithNoDetectedLicensePlateExists for 2 but 5 Int, 1 AnalyzedReport

pred ReportWithNonMatchingLicensePlatesExists {
	some r: AnalyzedReport | reportHasNonMatchingLicensePlates[r]
}

run ReportWithNonMatchingLicensePlatesExists for 2 but 5 Int, 1 AnalyzedReport

pred ReportWithBadlyDetectedLicensePlateExists {
	some r: AnalyzedReport | reportHasBadlyDetectedLicensePlate[r]
}

run ReportWithBadlyDetectedLicensePlateExists for 2 but 5 Int, 1 AnalyzedReport

pred ReportWithNoDetectedCarForLicensePlateExists {
	some r: AnalyzedReport | reportHasNoDetectedCarForLicensePlate[r]
}

run ReportWithNoDetectedCarForLicensePlateExists for 2 
	but 5 Int, 1 AnalyzedReport

pred ReportInReviewExists{
	some r: AnalyzedReport | reportIsInReview[r]
}

run ReportInReviewExists for 2 but 5 Int, 1 AnalyzedReport

pred HighConfidenceReportWithoutReviewExists {
	some r: AnalyzedReport | reportIsHighConfidence[r] and !reportHasReview[r]
}

run HighConfidenceReportWithoutReviewExists for 2 but 5 Int, 1 AnalyzedReport

pred HighConfidenceReportWithReviewExists {
	some r: AnalyzedReport | reportIsHighConfidence[r] and reportHasReview[r]
}

run HighConfidenceReportWithReviewExists for 2 but 5 Int, 1 AnalyzedReport

pred LowConfidenceReportWithoutReviewExists {
	some r: AnalyzedReport | reportIsLowConfidence[r] and !reportHasReview[r]
}

run LowConfidenceReportWithoutReviewExists for 2 but 5 Int, 1 AnalyzedReport

pred LowConfidenceReportWithReviewExists {
	some r: AnalyzedReport | reportIsLowConfidence[r] and reportHasReview[r]
}

run LowConfidenceReportWithReviewExists for 2 but 5 Int, 1 AnalyzedReport

pred reportHasMultipleLicensePlates [r: AnalyzedReport] {
	#getAnalyzedPhotoLicensePlates[r.analyzedPhoto] > 1
}

pred HighConfidenceReportWithMultipleLicensePlatesExists {
	some r: AnalyzedReport | 
		reportIsHighConfidence[r] and reportHasMultipleLicensePlates[r]
}

run HighConfidenceReportWithMultipleLicensePlatesExists for 2 
	but 5 Int, 4 LicensePlate, 4 DetectedLicensePlate, 1 AnalyzedReport

pred LowConfidenceReportWithMultipleLicensePlatesExists {
	some r: AnalyzedReport | 
		reportIsLowConfidence[r] and reportHasMultipleLicensePlates[r]
}

run LowConfidenceReportWithMultipleLicensePlatesExists for 2 
	but 5 Int, 4 LicensePlate, 4 DetectedLicensePlate, 1 AnalyzedReport

pred LowConfidenceReportBecauseOfAcceptableReviewExists {
	some r: AnalyzedReport | 
		reportIsLowConfidence[r] and 
		reportHasAcceptableLicensePlateReview[r] and
		carDetectionIsTrustworthy[getTargetDetection[r]] and
		!noCarRegisteredForLicensePlate[r.submission.licensePlate] and
		detectionLicensePlateCarMatchIsTrustworthy[getTargetDetection[r]]
}

run LowConfidenceReportBecauseOfAcceptableReviewExists for 2 
	but 5 Int, 1 AnalyzedReport

pred LowConfidenceReportBecauseOfBadCarDetectionExists {
	some r: AnalyzedReport | 
		reportIsLowConfidence[r] and 
		!carDetectionIsTrustworthy[getTargetDetection[r]] and
		!noCarRegisteredForLicensePlate[r.submission.licensePlate] and
		detectionLicensePlateCarMatchIsTrustworthy[getTargetDetection[r]] and 
		!reportHasAcceptableLicensePlateReview[r]
}

run LowConfidenceReportBecauseOfBadCarDetectionExists for 2 
	but 5 Int, 1 AnalyzedReport

pred LowConfidenceReportBecauseOfNoCarRegisteredForLicensePlateExists {
	some r: AnalyzedReport |
		reportIsLowConfidence[r] and 
		noCarRegisteredForLicensePlate[r.submission.licensePlate] and
		carDetectionIsTrustworthy[getTargetDetection[r]] and
		!reportHasAcceptableLicensePlateReview[r]
}

run LowConfidenceReportBecauseOfNoCarRegisteredForLicensePlateExists for 2 
	but 5 Int, 1 AnalyzedReport

pred LowConfidenceReportBecauseOfBadCarAndLicensePlateMatchExists {
	some r: AnalyzedReport | 
		reportIsLowConfidence[r] and 
		!detectionLicensePlateCarMatchIsTrustworthy[getTargetDetection[r]] and
		!noCarRegisteredForLicensePlate[r.submission.licensePlate] and
		carDetectionIsTrustworthy[getTargetDetection[r]] and
		!reportHasAcceptableLicensePlateReview[r]
}

run LowConfidenceReportBecauseOfBadCarAndLicensePlateMatchExists for 2 
	but 5 Int, 1 AnalyzedReport
