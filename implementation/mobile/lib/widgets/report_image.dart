import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ReportImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final bool enableZoom;

  ReportImage(this.imageProvider, {Key key, this.enableZoom = false})
      : super(key: key);

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
                    imageProvider: imageProvider,
                  ),
                );
              })
          : null,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(image: imageProvider),
        ),
      ),
    );
  }
}
