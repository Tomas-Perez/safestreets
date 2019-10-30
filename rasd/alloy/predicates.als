module predicates
open model

// Utility predicates

pred licensePlateDetectionIsTrustworthy [d: Detection] {
	d.licensePlate.confidence.rate >= 8
}

pred carDetectionIsTrustworthy [d: Detection] {
	d.car.confidence.rate >= 8
}

pred detectionLicensePlateCarMatchIsTrustworthy [d: Detection] {
	let detectedLicensePlateToCar = getLicensePlateWithCar[d] {
		some detectedLicensePlateToCar
		detectedLicensePlateToCar in LicensePlateRegistry.registration
	}
}

pred reportHasConfirmedLicensePlate [r: AnalyzedReport]  {
	r.submission.licensePlate in getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
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

pred reportHasNoDetectedCar [r: AnalyzedReport] {
	no getAnalyzedPhotoCars[r.analyzedPhoto]
}

// World generation

pred ReportWithConfirmedLicensePlateExists {
	some r: AnalyzedReport | reportHasConfirmedLicensePlate[r]
}

run ReportWithConfirmedLicensePlateExists for 4 but 5 Int

pred ReportWithNoDetectedLicensePlateExists {
	some r: AnalyzedReport | reportHasNoDetectedLicensePlate[r]
}

run ReportWithNoDetectedLicensePlateExists for 4 but 5 Int

pred ReportWithNonMatchingLicensePlatesExists {
	some r: AnalyzedReport | reportHasNonMatchingLicensePlates[r]
}

run ReportWithNonMatchingLicensePlatesExists for 4 but 5 Int

pred AnalyzedPhotoWithNoCarsExists {
	some p: AnalyzedPhoto | no getAnalyzedPhotoCars[p]
}

run AnalyzedPhotoWithNoCarsExists for 4 but 5 Int

pred AnalyzedPhotoWithNoLicensePlatesExists {
	some p: AnalyzedPhoto | no getAnalyzedPhotoLicensePlates[p]
}

run AnalyzedPhotoWithNoLicensePlatesExists for 4 but 5 Int

pred AnalyzedPhotoWithLicensePlatesAndCarsExists {
	some p: AnalyzedPhoto | some getAnalyzedPhotoLicensePlates[p] and some getAnalyzedPhotoCars[p]
}

run AnalyzedPhotoWithLicensePlatesAndCarsExists for 4 but 5 Int

pred AnalyzedPhotoWithLicensePlatesButNoCarsExists {
	some p: AnalyzedPhoto | some getAnalyzedPhotoLicensePlates[p] and no getAnalyzedPhotoCars[p]
}

run AnalyzedPhotoWithLicensePlatesButNoCarsExists for 4 but 5 Int

pred AnalyzedPhotoWithCarsButNoLicensePlatesExists {
	some p: AnalyzedPhoto | no getAnalyzedPhotoLicensePlates[p] and some getAnalyzedPhotoCars[p]
}

run AnalyzedPhotoWithCarsButNoLicensePlatesExists for 4 but 5 Int

pred DetectionWithCarAndLicensePlateExists {
	some d: Detection | some d.car and some d.licensePlate
}

run DetectionWithCarAndLicensePlateExists for 2 but 5 Int

pred ReportWithConfirmedCarExists {
	some r: AnalyzedReport | some getDetectedCarForSubmittedLicensePlate[r]
}

run ReportWithConfirmedCarExists for 2 but 5 Int
