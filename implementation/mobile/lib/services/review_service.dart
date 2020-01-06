import 'package:flutter/foundation.dart';
import 'package:mobile/data/report_review.dart';

abstract class ReviewService with ChangeNotifier {
  bool get reviewPending;

  ReviewRequest get request;

  Future<void> submitReview(ReportReview review);

  Future<void> fetchRequests();

  Future<void> clearRequests();
}

class MockReviewService with ChangeNotifier implements ReviewService {
  final List<List<ReviewRequest>> _queuedRequests = [];
  final List<ReviewRequest> _requests = [];

  MockReviewService(Future<List<List<ReviewRequest>>> queuedRequestsFuture) {
    queuedRequestsFuture.then((queued) => _queuedRequests.addAll(queued));
  }

  @override
  ReviewRequest get request => reviewPending ? _requests.first : null;

  @override
  bool get reviewPending => _requests.isNotEmpty;

  @override
  Future<void> submitReview(ReportReview review) async {
    _requests.removeWhere((req) => req.id == review.id);
    notifyListeners();
  }

  @override
  Future<void> fetchRequests() async {
    if (_queuedRequests.isEmpty) return;
    _requests.addAll(_queuedRequests.first);
    notifyListeners();
    _queuedRequests.removeAt(0);
  }

  @override
  Future<void> clearRequests() async {
    _requests.clear();
    notifyListeners();
  }
}
