sig Photo, LicensePlate {}

// An analyzed photo, where multiple license plates could be detected
sig AnalyzedPhoto {
	photo: Photo,
	detected: set LicensePlate
}

/*
	Repeating the image analysis over a photo gives the same result
	There cannot be two analysis of the same photo with a different set of detected license plates
*/
fact ImageAnalysisAlwaysReturnsTheSameResult {
	all p, p': AnalyzedPhoto | p.photo = p'.photo implies p.detected = p'.detected
}

sig ReportSubmission {
	licensePlate: lone LicensePlate,
	photos: set Photo,
	licensePlatePhoto: Photo
} {
	licensePlatePhoto in photos
}

fact NoDanglingData {
	Photo = ReportSubmission.photos
	LicensePlate = AnalyzedPhoto.detected + ReportSubmission.licensePlate
}

sig AnalyzedReport {
	submission: ReportSubmission,
	analyzedPhoto: AnalyzedPhoto
} {
	analyzedPhoto.photo = submission.licensePlatePhoto
}

pred reportHasConfirmedLicensePlate [r: AnalyzedReport]  {
	(
		one r.submission.licensePlate and
		r.submission.licensePlate in r.analyzedPhoto.detected
	) 
	or 
	(
		one r.analyzedPhoto.detected and 
		no r.submission.licensePlate
	)
}

pred reportHasAmbiguousPicture [r: AnalyzedReport] {
	no r.submission.licensePlate
	#r.analyzedPhoto.detected > 1
}

pred reportHasNoDetectedLicensePlate [r: AnalyzedReport] {
	no r.analyzedPhoto.detected
}

pred reportHasNonMatchingLicensePlates [r: AnalyzedReport] {
	some r.analyzedPhoto.detected
	! r.submission.licensePlate in r.analyzedPhoto.detected
}

/*
	Report definitions do not overlap, meaning that a given Submission 
	can be classified under only one of the established definitions
*/
assert ReportDefinitionsAreDisjointed {
	all r: AnalyzedReport | 
		!(reportHasConfirmedLicensePlate[r] and reportHasAmbiguousPicture[r]) and
		!(reportHasConfirmedLicensePlate[r] and reportHasNonMatchingLicensePlates[r]) and
		!(reportHasConfirmedLicensePlate[r] and reportHasNoDetectedLicensePlate[r]) and
		!(reportHasAmbiguousPicture[r] and reportHasNoDetectedLicensePlate[r]) and
		!(reportHasAmbiguousPicture[r] and reportHasNonMatchingLicensePlates[r]) and
		!(reportHasNonMatchingLicensePlates[r] and reportHasNoDetectedLicensePlate[r])
}

// Ensure that all possible variations of a report are covered by our established definitions
assert AllReportCasesAreCovered {
	no r: AnalyzedReport | 
		!reportHasConfirmedLicensePlate[r] and 
		!reportHasAmbiguousPicture[r] and 
		!reportHasNoDetectedLicensePlate[r] and
		!reportHasNonMatchingLicensePlates[r]
}

check ReportDefinitionsAreDisjointed for 4
check AllReportCasesAreCovered for 4

pred ReportWithConfirmedLicensePlateExists {
	some r: AnalyzedReport | reportHasConfirmedLicensePlate[r]
}

run ReportWithConfirmedLicensePlateExists for 1

pred AmbiguousReportExists {
	some r: AnalyzedReport | reportHasAmbiguousPicture[r]
}

run AmbiguousReportExists for 1 but 2 LicensePlate

pred NoDetectedLicensePlateReportExists {
	some r: AnalyzedReport | reportHasNoDetectedLicensePlate[r]
}

run NoDetectedLicensePlateReportExists for 1

pred NonMatchingLicensePlateReportExists {
	some r: AnalyzedReport | reportHasNonMatchingLicensePlates[r]
}

run NonMatchingLicensePlateReportExists for 1 but 2 LicensePlate





