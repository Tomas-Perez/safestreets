import 'package:mobile/data/report.dart';

abstract class ReportSubmissionService {
  Future<void> submit(ReportForm form);
}

class MockReportSubmissionService implements ReportSubmissionService {
  @override
  Future<void> submit(ReportForm form) async {
    print(form);
  }
}
