sig Photo, LicensePlate, Location, Time {}

// An analyzed photo, where multiple license plates could be detected
sig AnalyzedPhoto {
	photo: Photo,
	detected: set LicensePlate
}

// Repeating the image analysis over a photo gives the same result
// There cannot be two analysis of the same photo with a different set of detected license plates
fact ImageAnalysisAlwaysReturnsTheSameResult {
	all p, p': AnalyzedPhoto | p.photo = p'.photo implies p.detected = p'.detected
}

sig ReportSubmission {
	location: Location,
	time: Time,
	licensePlate: lone LicensePlate,
	photos: set Photo,
	licensePlatePhoto: Photo
} {
	licensePlatePhoto in photos
}

abstract sig AnalyzedReport {
	submission: ReportSubmission,
	analyzedPhoto: AnalyzedPhoto
} {
	analyzedPhoto.photo = submission.licensePlatePhoto
}

sig ValidReport extends AnalyzedReport {} {
	(
		some submission.licensePlate and
		submission.licensePlate in analyzedPhoto.detected
	) or 
		one analyzedPhoto.detected
}

sig AmbiguousPictureReport extends AnalyzedReport {} {
	no submission.licensePlate
	#analyzedPhoto.detected > 1
}

sig NoLicensePlateReport extends AnalyzedReport {} {
	no analyzedPhoto.detected
}

// Report definitions do not overlap, meaning that a given Submission 
// can be classified under only one of the established definitions
assert ReportDefinitionsAreDisjointed {
	no ValidReport.submission & AmbiguousPictureReport.submission
	no ValidReport.submission & NoLicensePlateReport.submission
	no NoLicensePlateReport.submission & AmbiguousPictureReport.submission
}

check ReportDefinitionsAreDisjointed for 4
