module assertions
open model
open reportDefinitions

/*
	Report definitions do not overlap, meaning that a given Submission 
	can be classified under only one of the established definitions
*/
assert ReportDefinitionsAreDisjointed {
	all r: AnalyzedReport {
		reportIsHighConfidence[r] =>
			!reportIsLowConfidence[r] and
			!reportHasNoDetectedLicensePlate[r] and
			!reportHasNonMatchingLicensePlates[r] and
			!reportHasBadlyDetectedLicensePlate[r] and
			!reportHasNoDetectedCarForLicensePlate[r]
			!reportIsInReview[r] 
		and
		reportIsHighConfidence[r] => 
			!reportIsLowConfidence[r] and
			!reportHasNoDetectedLicensePlate[r] and
			!reportHasNonMatchingLicensePlates[r] and
			!reportHasBadlyDetectedLicensePlate[r] and
			!reportHasNoDetectedCarForLicensePlate[r]
			!reportIsInReview[r] 
		and 
		reportHasNoDetectedLicensePlate[r] => 
			!reportIsHighConfidence[r] and
			!reportIsLowConfidence[r] and
			!reportHasNonMatchingLicensePlates[r] and
			!reportHasBadlyDetectedLicensePlate[r] and
			!reportHasNoDetectedCarForLicensePlate[r]
		and
		reportHasNonMatchingLicensePlates[r] =>
			!reportIsHighConfidence[r] and
			!reportIsLowConfidence[r] and
			!reportHasNoDetectedLicensePlate[r] and
			!reportHasBadlyDetectedLicensePlate[r] and
			!reportHasNoDetectedCarForLicensePlate[r]
			!reportIsInReview[r] 
		and
		reportHasBadlyDetectedLicensePlate[r] =>
			!reportIsHighConfidence[r] and
			!reportIsLowConfidence[r] and
			!reportHasNoDetectedLicensePlate[r] and
			!reportHasNonMatchingLicensePlates[r] and
			!reportHasNoDetectedCarForLicensePlate[r]
			!reportIsInReview[r] 
		and
		reportHasNoDetectedCarForLicensePlate[r] =>
			!reportIsHighConfidence[r] and
			!reportIsLowConfidence[r] and
			!reportHasNoDetectedLicensePlate[r] and
			!reportHasNonMatchingLicensePlates[r] and
			!reportHasBadlyDetectedLicensePlate[r]	
			!reportIsInReview[r] 
		and
		reportIsInReview[r] =>
			!reportIsHighConfidence[r] and
			!reportIsLowConfidence[r] and
			!reportHasNoDetectedLicensePlate[r] and
			!reportHasNonMatchingLicensePlates[r] and
			!reportHasBadlyDetectedLicensePlate[r]	 and
			!reportHasNoDetectedCarForLicensePlate[r]
	}
}

check ReportDefinitionsAreDisjointed for 6 but 5 Int

// Ensure that all possible variations of a report are covered by our established definitions
assert AllReportCasesAreCovered {
	no r: AnalyzedReport | 
		!reportIsHighConfidence[r] and 
		!reportIsLowConfidence[r] and
		!reportHasNoDetectedLicensePlate[r] and
		!reportHasNonMatchingLicensePlates[r] and
		!reportHasBadlyDetectedLicensePlate[r] and
		!reportHasNoDetectedCarForLicensePlate[r] and
		!reportIsInReview[r]
}

check AllReportCasesAreCovered for 10 but 5 Int
