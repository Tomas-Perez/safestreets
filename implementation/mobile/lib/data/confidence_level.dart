/// Report confidence level and utility functions.

enum ConfidenceLevel { HIGH_CONFIDENCE, LOW_CONFIDENCE }

String confidenceLevelToString(ConfidenceLevel level) {
  switch (level) {
    case ConfidenceLevel.HIGH_CONFIDENCE:
      return 'High confidence';
    case ConfidenceLevel.LOW_CONFIDENCE:
      return 'Low confidence';
    default:
      throw Exception('$level is not a ConfidenceLevel');
  }
}

String confidenceToDTString(ConfidenceLevel level) {
  switch (level) {
    case ConfidenceLevel.HIGH_CONFIDENCE:
      return 'HIGH_CONFIDENCE';
    case ConfidenceLevel.LOW_CONFIDENCE:
      return 'LOW_CONFIDENCE';
    default:
      throw Exception("$level is not a ConfidenceLevel");
  }
}

ConfidenceLevel confidenceFromDTString(String level) {
  switch (level) {
    case "HIGH_CONFIDENCE":
      return ConfidenceLevel.HIGH_CONFIDENCE;
    case "LOW_CONFIDENCE":
      return ConfidenceLevel.LOW_CONFIDENCE;
    default:
      throw Exception("$level is not a ConfidenceLevel");
  }
}