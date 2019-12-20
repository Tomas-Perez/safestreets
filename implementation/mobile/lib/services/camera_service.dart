import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/services/camera_util.dart';

abstract class CameraService {
  Future<String> openViewfinder(BuildContext context);
}

class PhoneCameraService implements CameraService{
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

  Future<String> openViewfinder(BuildContext context) async {
    await _initializationCompleter.future;
    return takePicture(context, _camera);
  }
}
