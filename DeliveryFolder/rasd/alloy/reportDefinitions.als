open model
module reportDefinitions

---------------------------- MAIN DEFINITIONS -----------------------------

pred reportIsHighConfidence [r: AnalyzedReport] {
	reportHasConfirmedLicensePlate[r]
	reportHasConfirmedCar[r]
	reportHasHighConfidenceLicensePlate[r]
	reportHasConfirmedCarCharacteristics[r]
	detectionLicensePlateCarMatchIsTrustworthy[getTargetDetection[r]]
}

pred reportIsLowConfidence [r: AnalyzedReport] {
	reportHasConfirmedLicensePlate[r]
	reportHasConfirmedCar[r]
	!reportHasBadlyDetectedLicensePlate[r]
	(
		reportHasAcceptableLicensePlateReview[r] or 
		!carDetectionIsTrustworthy[getTargetDetection[r]] or 
		noCarRegisteredForLicensePlate[r.submission.licensePlate] or 
		!detectionLicensePlateCarMatchIsTrustworthy[getTargetDetection[r]]
	)
}

pred reportHasNoDetectedLicensePlate [r: AnalyzedReport] {
	no getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
}

pred reportHasNonMatchingLicensePlates [r: AnalyzedReport] {
	let licensePlates = getAnalyzedPhotoLicensePlates[r.analyzedPhoto] {
		some licensePlates
		! r.submission.licensePlate in licensePlates
	}
}

pred reportHasBadlyDetectedLicensePlate [r: AnalyzedReport] {
	badDetectionReview[(Review <: detection).(getTargetDetection[r])]
}

pred reportHasNoDetectedCarForLicensePlate [r: AnalyzedReport] {
	reportHasConfirmedLicensePlate[r]
	no getTargetCar[r]
}

pred reportIsInReview [r: AnalyzedReport] {
	reportHasConfirmedLicensePlate[r]
	reportHasConfirmedCar[r]
	!licensePlateDetectionIsTrustworthy[getTargetDetection[r]] 
	!reportHasReview[r]
}

--------------------------- UTILITY PREDICATES ----------------------------

pred reportHasConfirmedLicensePlate [r: AnalyzedReport]  {
	r.submission.licensePlate in getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
}

pred reportHasAcceptableLicensePlateReview [r: AnalyzedReport] {
	acceptableDetectionReview[(Review <: detection).(getTargetDetection[r])]
}

pred reportHasHighConfidenceLicensePlateReview [r: AnalyzedReport] {
	highConfidenceDetectionReview[(Review <: detection).(getTargetDetection[r])]
}

pred reportHasConfirmedCar [r: AnalyzedReport] {
	some getTargetCar[r]
}

pred reportHasHighConfidenceLicensePlate [r: AnalyzedReport] {
	licensePlateDetectionIsTrustworthy[getTargetDetection[r]] or
	reportHasHighConfidenceLicensePlateReview[r]
}

pred reportHasConfirmedCarCharacteristics [r: AnalyzedReport] {
	carDetectionIsTrustworthy[getTargetDetection[r]]
}

pred reportHasReview [r: AnalyzedReport] {
	some Review.detection & getTargetDetection[r]
}
