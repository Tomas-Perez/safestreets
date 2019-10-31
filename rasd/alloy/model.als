module model

sig Photo, LicensePlate, Car {}

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

// Detection of a license plate and the car on which it is set on
sig Detection {
	car: lone DetectedCar,
	licensePlate: lone DetectedLicensePlate
} {
	some car or some licensePlate
}

fun Detection.getLicensePlateWithCar: set LicensePlate -> Car {
	this.licensePlate.licensePlate -> this.car.car 
}

fun Detection.matchWithLicensePlateAndCar: set LicensePlate -> Car -> Detection {
	getLicensePlateWithCar[this] -> this
}

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

// An analyzed photo, where multiple cars and their license plates could be detected
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

fun AnalyzedPhoto.getAnalyzedPhotoCars : set Car {
	this.detected.(Detection <: car).(DetectedCar <: car)
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

sig AnalyzedReport {
	submission: ReportSubmission,
	analyzedPhoto: AnalyzedPhoto
} {
	analyzedPhoto.photo = submission.licensePlatePhoto
}

fun AnalyzedReport.getTargetDetection : set Detection {
	let 
		targetLicensePlate = this.submission.licensePlate, 
		licensePlateDetections = this.analyzedPhoto.detected <: licensePlate {
			licensePlateDetections.(DetectedLicensePlate <: licensePlate).targetLicensePlate
	}
}

fun AnalyzedReport.getTargetCar : set Car {
	getTargetDetection[this].car.car
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

pred reportHasBadlyDetectedLicensePlate [r: AnalyzedReport] {
	badDetectionReview[(Review <: detection).(getTargetDetection[r])]
}

pred reportHasAcceptableLicensePlateDetection [r: AnalyzedReport] {
	acceptableDetectionReview[(Review <: detection).(getTargetDetection[r])]
}

pred reportHasHighConfidenceLicensePlateDetection [r: AnalyzedReport] {
	highConfidenceDetectionReview[(Review <: detection).(getTargetDetection[r])]
}

// Placeholder for the license plate registration service API
one sig LicensePlateRegistry {
	registration: LicensePlate -> Car
}

/*
	Two license plates cannot be attached to the same car
	Two cars cannot be registered under the same license plate
*/
fact NoRepeatedRegistrations {
	no disj l1, l2: LicensePlate | getCarRegisteredUnderLicensePlate[l1] = getCarRegisteredUnderLicensePlate[l2]
	no disj c1, c2: Car | LicensePlateRegistry.registration.c1 = LicensePlateRegistry.registration.c2
}

fun getCarRegisteredUnderLicensePlate [l: LicensePlate] : set Car {
	 l.(LicensePlateRegistry.registration)
}

pred noCarRegisteredForLicensePlate [l: LicensePlate] {
	no getCarRegisteredUnderLicensePlate[l]
}

sig Review {
	detection: Detection,
	matchPercentage: Int
} {
	// Percentage between 0 and 100%
	matchPercentage >= 0 and matchPercentage <= 10
}

fact OnlyReviewLowConfidenceLicensePlateDetections {
	no r: Review | licensePlateDetectionIsTrustworthy[r.detection]
}

fact OnlyReviewDetectionsOfTargetCarAndLicensePlate {
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

fact NoDanglingData {
	Photo = ReportSubmission.photos
	LicensePlate = DetectedLicensePlate.licensePlate + ReportSubmission.licensePlate + LicensePlateRegistry.registration.Car
	Detection = AnalyzedPhoto.detected
	Confidence = DetectedLicensePlate.confidence + DetectedCar.confidence
}

