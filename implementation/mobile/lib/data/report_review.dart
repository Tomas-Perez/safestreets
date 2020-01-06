import 'dart:typed_data';

class ReviewRequest {
  final String id;
  final Uint8List imageData;

  ReviewRequest(this.id, this.imageData);
}

class ReportReview {
  final String id;
  final bool clear;
  final String licensePlate;

  ReportReview.clear(this.id, this.licensePlate) : clear = true;

  ReportReview.notClear(this.id)
      : clear = false,
        licensePlate = null;
}
