import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';

/// Picture byte data plus metadata (location and time when it was taken).
class PictureInfo {
  final Uint8List imageData;
  final LatLng location;
  final DateTime time;

  PictureInfo({
    @required this.imageData,
    @required this.location,
    @required this.time,
  });

  @override
  String toString() {
    return 'PictureInfo{imageDataSize: ${imageData.length}b, location: $location, time: $time}';
  }
}
