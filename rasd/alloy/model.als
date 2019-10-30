sig Photo, LicensePlate {}

sig Confidence {
	rate: Int
} {
	// Confidence is between 0 and 100%. But not exactly 0.
	rate > 0 && rate <= 10
}

sig DetectedLicensePlate {
	licensePlate: LicensePlate,
	confidence: Confidence
}

sig Make, Model, Color {}

sig Car {
	make: Make,
	model: Model,
	color: Color
}

sig DetectedCar {
	car: Car,
	confidence: Confidence
}

// Detection of a license plate and the car on which it is set on
sig Detection {
	car: lone DetectedCar,
	licensePlate: lone DetectedLicensePlate
} {
	no car => some licensePlate
	no licensePlate => some car
}

// An analyzed photo, where multiple cars and their license plates could be detected
sig AnalyzedPhoto {
	photo: Photo,
	detected: set Detection
}

/*
	Repeating the image analysis over a photo gives the same result
	There cannot be two analysis of the same photo with a different set of detected license plates
*/
fact ImageAnalysisAlwaysReturnsTheSameResult {
	all p, p': AnalyzedPhoto | p.photo = p'.photo implies p.detected = p'.detected
}

sig ReportSubmission {
	licensePlate: LicensePlate,
	photos: set Photo,
	licensePlatePhoto: Photo
} {
	licensePlatePhoto in photos
}

fact NoDanglingData {
	Photo = ReportSubmission.photos
	LicensePlate = DetectedLicensePlate.licensePlate + ReportSubmission.licensePlate
	Detection = AnalyzedPhoto.detected
	Confidence = DetectedLicensePlate.confidence + DetectedCar.confidence
	Make = Car.make
	Model = Car.model
	Color = Car.color
}

sig AnalyzedReport {
	submission: ReportSubmission,
	analyzedPhoto: AnalyzedPhoto
} {
	analyzedPhoto.photo = submission.licensePlatePhoto
}

fun getAnalyzedPhotoLicensePlates [p: AnalyzedPhoto] : set LicensePlate {
	p.detected.(Detection <: licensePlate).(DetectedLicensePlate <: licensePlate)
}

pred reportHasConfirmedLicensePlate [r: AnalyzedReport]  {
	r.submission.licensePlate in getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
}

pred reportHasNoDetectedLicensePlate [r: AnalyzedReport] {
	no getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
}

pred reportHasNonMatchingLicensePlates [r: AnalyzedReport] {
	some getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
	! r.submission.licensePlate in getAnalyzedPhotoLicensePlates[r.analyzedPhoto]
}

/*
	Report definitions do not overlap, meaning that a given Submission 
	can be classified under only one of the established definitions
*/
assert ReportDefinitionsAreDisjointed {
	all r: AnalyzedReport | 
		!(reportHasConfirmedLicensePlate[r] and reportHasNonMatchingLicensePlates[r]) and
		!(reportHasConfirmedLicensePlate[r] and reportHasNoDetectedLicensePlate[r]) and
		!(reportHasNonMatchingLicensePlates[r] and reportHasNoDetectedLicensePlate[r])
}

// Ensure that all possible variations of a report are covered by our established definitions
assert AllReportCasesAreCovered {
	no r: AnalyzedReport | 
		!reportHasConfirmedLicensePlate[r] and 
		!reportHasNoDetectedLicensePlate[r] and
		!reportHasNonMatchingLicensePlates[r]
}

check ReportDefinitionsAreDisjointed for 4
check AllReportCasesAreCovered for 4

pred ReportWithConfirmedLicensePlateExists {
	some r: AnalyzedReport | reportHasConfirmedLicensePlate[r]
}

run ReportWithConfirmedLicensePlateExists for 1 but 5 Int

pred NoDetectedLicensePlateReportExists {
	some r: AnalyzedReport | reportHasNoDetectedLicensePlate[r]
}

run NoDetectedLicensePlateReportExists for 1 but 5 Int

pred NonMatchingLicensePlateReportExists {
	some r: AnalyzedReport | reportHasNonMatchingLicensePlates[r]
}

run NonMatchingLicensePlateReportExists for 1 but 2 LicensePlate, 5 Int



