import 'package:mobile/data/report.dart';
import 'package:mobile/data/violation_type.dart';

class FilterInfo {
  DateTime from, to;
  ViolationType violationType;

  FilterInfo(this.from, this.to, this.violationType);

  FilterInfo.empty();

  bool test(ReportIndicator report) {
    if (violationType != null && report.violationType != violationType)
      return false;
    if (report.time.isAfter(to)) return false;
    if (report.time.isBefore(from)) return false;
    return true;
  }
}
