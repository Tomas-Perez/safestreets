import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile/util/camera.dart';
import 'package:mobile/util/image_helpers.dart';

/// Provides a way to open the device camera and returns the image the user captures.
abstract class CameraService {
  Future<Uint8List> openViewfinder(BuildContext context);
}

class MockCameraService implements CameraService {
  final _imageDataCompleter = Completer<Uint8List>();

  MockCameraService(String asset) {
    _imageDataCompleter.complete(loadAssetImage(asset));
  }

  @override
  Future<Uint8List> openViewfinder(BuildContext context) =>
      _imageDataCompleter.future;
}

class PhoneCameraService implements CameraService {
  CameraDescription _camera;
  final _initializationCompleter = Completer<void>();

  PhoneCameraService() {
    availableCameras().then(
      (cameras) {
        _camera = cameras
            .firstWhere((c) => c.lensDirection == CameraLensDirection.front);
        _initializationCompleter.complete();
      },
    );
  }

  Future<Uint8List> openViewfinder(BuildContext context) async {
    await _initializationCompleter.future;
    final imagePath = await takePicture(context, _camera);
    if (imagePath == null) return null;
    return File(imagePath).readAsBytes();
  }
}
