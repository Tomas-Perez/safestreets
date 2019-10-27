sig Photo, LicensePlate, Location, Time {}

// An analyzed photo, where multiple license plates could be detected
sig AnalyzedPhoto {
	photo: Photo,
	detected: set LicensePlate
}

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
		! submission.licensePlate = none and
		submission.licensePlate in analyzedPhoto.detected
	) or 
	#analyzedPhoto.detected = 1
}

sig AmbiguousPictureReport extends AnalyzedReport {} {
	no submission.licensePlate
	#analyzedPhoto.detected > 1
}

sig NoLicensePlateReport extends AnalyzedReport {} {
	no analyzedPhoto.detected
}

// Report definitions do not overlap, meaning that a given Submission 
// can only be classified under one of the established definitions

assert ReportDefinitionsAreDisjointed {
	ValidReport.submission & AmbiguousPictureReport.submission = none
	ValidReport.submission & NoLicensePlateReport.submission = none
	NoLicensePlateReport.submission & AmbiguousPictureReport.submission = none
}

check ReportDefinitionsAreDisjointed for 4
