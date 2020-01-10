import 'package:dio/dio.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'config.dart';
import 'screen_finders.dart';
import 'test_helpers.dart';

void main() {
  group('Safestreets app', () {
    FlutterDriver driver;

    setUpAll(() async {
      await Dio().get('$baseUrl/debug/reinitializedb');
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    const mockLicensePlate = 'EX215GC';

    test('submits review correctly', () async {
      await driver.waitFor(homeScreen);
      await driver.waitFor(find.byValueKey('pending reviews'));
      await driver.tap(find.byValueKey('open reviews'));
      await driver.waitFor(find.byValueKey('review alert'));
      await driver.enterTextInField(find.byType('TextFormField'), mockLicensePlate);
      await driver.tap(find.byValueKey('submit review'));
      await driver.waitFor(find.byValueKey('successful review'));
    });
  });
}
