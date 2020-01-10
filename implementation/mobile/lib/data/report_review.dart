import 'dart:typed_data';

class ReviewRequest {
  final String id;
  final Uint8List imageData;

  ReviewRequest(this.id, this.imageData);

  @override
  String toString() {
    return 'ReviewRequest{id: $id}';
  }
}

class ReportReview {
  final String id;
  final bool clear;
  final String licensePlate;

  ReportReview.clear(this.id, this.licensePlate) : clear = true;

  ReportReview.notClear(this.id)
      : clear = false,
        licensePlate = null;

  @override
  String toString() {
    return 'ReportReview{id: $id, clear: $clear, licensePlate: $licensePlate}';
  }
}
