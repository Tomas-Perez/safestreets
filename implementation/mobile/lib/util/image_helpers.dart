import 'dart:typed_data';

import 'package:flutter/services.dart';

Future<Uint8List> loadAssetImage(String name) =>
    rootBundle.load(name).then((bd) => bd.buffer.asUint8List());
