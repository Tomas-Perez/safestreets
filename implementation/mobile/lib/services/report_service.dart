import 'package:flutter/foundation.dart';
import 'package:mobile/data/picture_info.dart';
import 'package:mobile/data/report.dart';
import 'package:mobile/data/violation_type.dart';

abstract class ReportService with ChangeNotifier {
  Future<void> submit(ReportForm form);
}

class MockReportService with ChangeNotifier implements ReportService {
  @override
  Future<void> submit(ReportForm form) async {
    print(form);
  }
}
