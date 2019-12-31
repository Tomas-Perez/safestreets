import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

Future<String> takePicture(BuildContext context, CameraDescription camera) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (ctx) => _CameraViewfinder(camera: camera)),
  );
}

class _CameraViewfinder extends StatefulWidget {
  final CameraDescription camera;

  const _CameraViewfinder({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  State createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<_CameraViewfinder> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: <Widget>[
              CameraPreview(_controller),
              _buildTakePictureButton(),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildTakePictureButton() {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      alignment: orientation == Orientation.landscape
          ? Alignment.centerRight
          : Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 55.0,
          width: 55.0,
          child: RaisedButton(
            color: Colors.white,
            shape: CircleBorder(
              side: BorderSide(color: Colors.black, width: 4.0),
            ),
            onPressed: _takePicture,
          ),
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      await _controller.takePicture(path);
      Navigator.pop(context, path);
    } catch (e) {
      print(e);
    }
  }
}
