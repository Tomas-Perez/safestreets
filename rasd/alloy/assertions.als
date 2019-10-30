open model
open predicates

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

assert DetectedCarForLicensePlateIsAlwaysOne {
	all r: AnalyzedReport | #getDetectedCarForSubmittedLicensePlate[r] <= 1
}

check ReportDefinitionsAreDisjointed for 10
check AllReportCasesAreCovered for 10
check DetectedCarForLicensePlateIsAlwaysOne for 10
