module model

---------------------------------- DETECTION -----------------------------------

sig LicensePlate, Car {}

sig Confidence {
	rate: Int
} {
	// Confidence is between 0 and 100%. But not exactly 0.
	rate > 0 and rate <= 10
}

sig DetectedLicensePlate {
	licensePlate: LicensePlate,
	confidence: Confidence
}

sig DetectedCar {
	car: Car,
	confidence: Confidence
}

// Detection of a license plate and the car on which it is set on.
sig Detection {
	car: lone DetectedCar,
	licensePlate: lone DetectedLicensePlate
}

fact DetectionsCannotLackCarAndLicensePlate {
	no d: Detection | no d.car and no d.licensePlate
}

fun Detection.getLicensePlateWithCar: set LicensePlate -> Car {
	this.licensePlate.licensePlate -> this.car.car 
}

pred licensePlateDetectionIsTrustworthy [d: Detection] {
	d.licensePlate.confidence.rate >= 8
}

pred carDetectionIsTrustworthy [d: Detection] {
	d.car.confidence.rate >= 8
}

-------------------------------- PHOTO ANALYSIS --------------------------------

sig Photo {}

/*
	An analyzed photo, where multiple cars and their license plates
	could be detected.
*/
sig AnalyzedPhoto {
	photo: Photo,
	detected: set Detection
}

fact NoCarIsDetectedTwice {
	no disj d1, d2: AnalyzedPhoto.detected | 
		some d1.car and
		some d2.car and
		d1.car.car = d2.car.car
}

fact NoLicensePlateIsDetectedTwice {
	no disj d1, d2: AnalyzedPhoto.detected |
		some d1.licensePlate and 
		some d2.licensePlate and
		d1.licensePlate.licensePlate = d2.licensePlate.licensePlate
}

fun AnalyzedPhoto.getAnalyzedPhotoLicensePlates : set LicensePlate {
	this.detected.(Detection <: licensePlate).(DetectedLicensePlate <: licensePlate)
}

/*
	Repeating the image analysis over a photo gives the same result.
	There cannot be two analysis of the same photo with a different 
	set of detected license plates.
*/
fact ImageAnalysisAlwaysReturnsTheSameResult {
	all p, p': AnalyzedPhoto | p.photo = p'.photo implies p.detected = p'.detected
}

----------------------------------- REPORTS ------------------------------------

sig ReportSubmission {
	licensePlate: LicensePlate,
	photos: set Photo,
	licensePlatePhoto: Photo
} {
	licensePlatePhoto in photos
}

sig AnalyzedReport {
	submission: ReportSubmission,
	analyzedPhoto: AnalyzedPhoto
} {
	analyzedPhoto.photo = submission.licensePlatePhoto
}

fun AnalyzedReport.getTargetDetection : set Detection {
	let 
		targetLP = this.submission.licensePlate, 
		lpDetections = this.analyzedPhoto.detected <: licensePlate {
			lpDetections.(DetectedLicensePlate <: licensePlate).targetLP
	}
}

fun AnalyzedReport.getTargetCar : set Car {
	getTargetDetection[this].car.car
}

---------------------------- LICENSE PLATE REGISTRY ----------------------------

// Placeholder for the license plate registration service API.
one sig LicensePlateRegistry {
	registration: LicensePlate -> Car
}

/*
	Every car is registered under at most 1 license plate.
	Every license plate is registered for at most 1 car.

	There could be cases where a car or license plate is not registered:
		- Bad detection
		- Fake license plate
*/
fact NoRepeatedRegistrations {
	all c: Car | lone LicensePlateRegistry.registration.c
	all l: LicensePlate | lone getCarRegisteredUnderLicensePlate[l]
}

fun getCarRegisteredUnderLicensePlate [l: LicensePlate] : set Car {
	 l.(LicensePlateRegistry.registration)
}

pred detectionLicensePlateCarMatchIsTrustworthy [d: Detection] {
	let detectedLicensePlateToCar = getLicensePlateWithCar[d] {
		some detectedLicensePlateToCar
		detectedLicensePlateToCar in LicensePlateRegistry.registration
	}
}

pred noCarRegisteredForLicensePlate [l: LicensePlate] {
	no getCarRegisteredUnderLicensePlate[l]
}

----------------------------------- REVIEWS ------------------------------------

sig Review {
	detection: Detection,
	matchPercentage: Int
} {
	// Percentage between 0 and 100%.
	matchPercentage >= 0 and matchPercentage <= 10
}

fact OnlyReviewLowConfidenceLicensePlateDetections {
	no r: Review | licensePlateDetectionIsTrustworthy[r.detection]
}

fact OnlyReviewDetectionsWithLicensePlateAndCar {
	all d: Review.detection | some d.car and some d.licensePlate
}

fact OnlyReviewDetectionsOfTarget {
	Review.detection in getTargetDetection[AnalyzedReport]
}

fact NoRepeatedReviews {
	no disj r1, r2: Review | r1.detection = r2.detection
}

pred badDetectionReview [r: Review] {
	some r
	r.matchPercentage < 6
}

pred acceptableDetectionReview [r: Review] {
	r.matchPercentage >= 6 and r.matchPercentage < 8
}

pred highConfidenceDetectionReview [r: Review] {
	r.matchPercentage >= 8
}

------------------------------------ EXTRA -------------------------------------

fact NoDanglingData {
	// All reports are analyzed.
	ReportSubmission = AnalyzedReport.submission

	// All photos come from submissions.
	Photo = ReportSubmission.photos

	// LicensePlates are detected, submitted, or in the license plate registry.
	LicensePlate = 
		DetectedLicensePlate.licensePlate + 
		ReportSubmission.licensePlate + 
		LicensePlateRegistry.registration.Car

	// Cars are detected or in the license plate registry.
	Car = DetectedCar.car + LicensePlate.(LicensePlateRegistry.registration)
	
	// Detections come from a photo analysis.
	Detection = AnalyzedPhoto.detected
	
	// Confidence is attached to a detection.
	Confidence = DetectedLicensePlate.confidence + DetectedCar.confidence
	
	// Only photos from a report are analyzed.
	AnalyzedPhoto = AnalyzedReport.analyzedPhoto
	
	// Detected license plates come from a photo detection.
	DetectedLicensePlate = Detection.licensePlate
	
	// Detected cars come from a photo detection.
	DetectedCar = Detection.car
}

