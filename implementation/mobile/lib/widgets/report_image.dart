import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:photo_view/photo_view.dart';

class ReportImage extends StatelessWidget {
  final ImageDescription image;
  final bool enableZoom;

  ReportImage(this.image, {Key key, this.enableZoom = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enableZoom
          ? () => showDialog(
          context: context,
          builder: (ctx) {
            return Container(
              child: PhotoView(
                minScale: 1.0,
                imageProvider: image.type == ImageType.asset
                    ? AssetImage(image.path)
                    : FileImage(File(image.path)),
              ),
            );
          })
          : null,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: image.type == ImageType.asset
              ? Image.asset(image.path)
              : Image.file(File(image.path)),
        ),
      ),
    );
  }
}