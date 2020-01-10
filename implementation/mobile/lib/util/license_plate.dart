final _regex = RegExp(r"(^[A-Z]{2}[0-9]{3}[A-Z]{2}$)");

bool isItalianLicensePlate(String x) {
  final matches = _regex.allMatches(x);
  if (matches.length != 1) return false;
  final match = matches.first.group(0);
  return match == x;
}
