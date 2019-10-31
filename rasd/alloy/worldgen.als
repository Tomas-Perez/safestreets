module worldgen
open model

pred ReportWithConfirmedLicensePlateExists {
	some r: AnalyzedReport | reportHasConfirmedLicensePlate[r]
}

run ReportWithConfirmedLicensePlateExists for 2 but 5 Int

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

run DetectionWithCarAndLicensePlateExists for 2 but 1 AnalyzedReport, 5 Int

pred ReportWithConfirmedCarExists {
	some r: AnalyzedReport | reportHasConfirmedCar[r]
}

run ReportWithConfirmedCarExists for 2 but 5 Int


run {
	some r: AnalyzedReport | reportHasBadlyDetectedLicensePlate[r]
	ReportWithConfirmedCarExists
	DetectionWithCarAndLicensePlateExists
	ReportWithConfirmedLicensePlateExists
	#Detection = 3
} for 1 but 3 Detection, 2 Car, 2 LicensePlate, 2 DetectedCar, 2 DetectedLicensePlate, 5 Int

run {
	some r: AnalyzedReport | reportHasAcceptableLicensePlateReview[r]
	ReportWithConfirmedCarExists
	DetectionWithCarAndLicensePlateExists
	ReportWithConfirmedLicensePlateExists
	#Detection = 3
} for 1 but 3 Detection, 2 Car, 2 LicensePlate, 2 DetectedCar, 2 DetectedLicensePlate, 5 Int

run {
	some r: AnalyzedReport | reportHasHighConfidenceLicensePlateReview[r]
	ReportWithConfirmedCarExists
	DetectionWithCarAndLicensePlateExists
	ReportWithConfirmedLicensePlateExists
	#Detection = 3
} for 1 but 3 Detection, 2 Car, 2 LicensePlate, 2 DetectedCar, 2 DetectedLicensePlate, 5 Int
