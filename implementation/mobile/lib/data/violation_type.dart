enum ViolationType { PARKING, POOR_CONDITION, RED_LIGHT, CRASH }

String violationTypeToString(ViolationType type) {
  switch (type) {
    case ViolationType.PARKING:
      return "Parking";
    case ViolationType.POOR_CONDITION:
      return "Poor condition";
    case ViolationType.CRASH:
      return 'Crash';
    case ViolationType.RED_LIGHT:
      return 'Red light';
    default:
      throw Exception("$type is not a ViolationType");
  }
}