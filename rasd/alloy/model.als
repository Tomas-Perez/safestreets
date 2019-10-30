module model

sig Photo, LicensePlate, Car {}

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

fun AnalyzedReport.getDetectedCarForSubmittedLicensePlate : set Car {
	this.submission.licensePlate.(getLicensePlateWithCar[this.analyzedPhoto.detected])
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
	no disj l1, l2: LicensePlate | l1.(LicensePlateRegistry.registration) = l2.(LicensePlateRegistry.registration)
	no disj c1, c2: Car | LicensePlateRegistry.registration.c1 = LicensePlateRegistry.registration.c2
}

fact NoDanglingData {
	Photo = ReportSubmission.photos
	LicensePlate = DetectedLicensePlate.licensePlate + ReportSubmission.licensePlate + LicensePlateRegistry.registration.Car
	Detection = AnalyzedPhoto.detected
	Confidence = DetectedLicensePlate.confidence + DetectedCar.confidence
}
