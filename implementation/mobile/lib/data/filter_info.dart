import 'package:mobile/data/violation_type.dart';

class FilterInfo {
  DateTime from, to;
  ViolationType violationType;

  FilterInfo(this.from, this.to, this.violationType);

  FilterInfo.empty();
}