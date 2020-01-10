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

String toDTString(ViolationType type) {
  switch (type) {
    case ViolationType.PARKING:
      return "PARKING";
    case ViolationType.POOR_CONDITION:
      return "POOR_CONDITION";
    case ViolationType.CRASH:
      return 'CRASH';
    case ViolationType.RED_LIGHT:
      return 'RED_LIGHT';
    default:
      throw Exception("$type is not a ViolationType");
  }
}

ViolationType fromDTString(String type) {
  switch (type) {
    case "PARKING":
      return ViolationType.PARKING;
    case "POOR_CONDITION":
      return ViolationType.POOR_CONDITION;
    case "CRASH":
      return ViolationType.CRASH;
    case "RED_LIGHT":
      return ViolationType.RED_LIGHT;
    default:
      throw Exception("$type is not a ViolationType");
  }
}
