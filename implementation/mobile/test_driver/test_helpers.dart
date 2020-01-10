import 'package:flutter_driver/flutter_driver.dart';

extension BetterDriver on FlutterDriver {
  Future<void> enterTextInField(SerializableFinder finder, String text, { Duration timeout }) async {
    await tap(finder);
    await enterText(text);
    await waitFor(find.text(text));
  }
}