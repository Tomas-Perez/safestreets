import 'dart:typed_data';

import 'package:dio/dio.dart';
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

class HttpReviewService with ChangeNotifier implements ReviewService {
  final _dio = Dio();
  final List<ReviewRequest> _requests = [];

  @override
  Future<void> clearRequests() async {
    _requests.clear();
    notifyListeners();
  }

  @override
  Future<void> fetchRequests() async {
    _requests.clear();
    notifyListeners();
    try {
      final requestDtos =
          (await _dio.get<List<dynamic>>('/review/pending/me')).data;
      final fetchingRequests = requestDtos.map((r) async {
        final imageData = await _fetchImage(r['imageName']);
        if (imageData == null) return null;
        return ReviewRequest(r['id'], imageData);
      });
      final requests = await Future.wait(fetchingRequests);
      _requests.addAll(requests.where((r) => r != null));
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<Uint8List> _fetchImage(String name) async {
    try {
      final bytes = (await _dio.get<List<int>>(
        '/image/$name',
        options: Options(responseType: ResponseType.bytes),
      ))
          .data;
      return Uint8List.fromList(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  ReviewRequest get request => reviewPending ? _requests.first : null;

  @override
  bool get reviewPending => _requests.isNotEmpty;

  @override
  Future<void> submitReview(ReportReview review) async {
    try {
      await _dio.post('/review', data: {
        'reviewId': review.id,
        'licensePlate': review.licensePlate,
        'clear': review.clear,
      });
    } catch (e) {
      print(e);
    }
  }

  set baseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  set token(String token) {
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
    };
    if (token != null) fetchRequests();
  }
}
