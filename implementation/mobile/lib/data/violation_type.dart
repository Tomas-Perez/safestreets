enum ViolationType { PARKING, BAD_CONDITION }

String violationTypeToString(ViolationType type) {
  switch (type) {
    case ViolationType.PARKING:
      return "Parking";
    case ViolationType.BAD_CONDITION:
      return "Bad condition";
    default:
      throw Exception("$type is not a ViolationType");
  }
}