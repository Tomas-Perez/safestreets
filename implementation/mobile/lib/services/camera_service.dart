import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/services/camera_util.dart';

abstract class CameraService {
  Future<ImageDescription> openViewfinder(BuildContext context);
}

enum ImageType { asset, file }

class ImageDescription {
  final String path;
  final ImageType type;

  ImageDescription.file(this.path) : type = ImageType.file;

  ImageDescription.asset(this.path) : type = ImageType.asset;
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

  Future<ImageDescription> openViewfinder(BuildContext context) async {
    await _initializationCompleter.future;
    return ImageDescription.file(await takePicture(context, _camera));
  }
}
