import 'package:dio/dio.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:mobile/routes.dart';
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

    test('submits report correctly', () async {
      await driver.waitFor(homeScreen);
      await driver.tap(find.byValueKey('$REPORT redirect'));
      await driver.waitFor(reportScreen);
      await driver.tap(find.byValueKey('$REPORT violation type field'));
      await driver.tap(find.text('Parking'));
      await driver.enterTextInField(find.byValueKey('$REPORT license plate field'), 'DX034PS');
      await driver.enterTextInField(find.byValueKey('$REPORT description field'), 'testing');
      await driver.tap(find.byValueKey('take photo'));
      final submitReportButton = find.byValueKey('submit report');
      await driver.scrollIntoView(submitReportButton);
      await driver.tap(submitReportButton);
      await driver.waitFor(find.byValueKey('license plate photo alert'));
      await driver.tap(find.byValueKey('ok'));
      await driver.waitFor(find.byValueKey('successful report submission'));
    });

    test('shows reports on the map', () async {
      await driver.waitFor(homeScreen);
      await driver.tap(find.byValueKey('$MAP redirect'));
      await driver.waitFor(mapScreen);
      await driver.waitFor(find.byValueKey('report indicator'));
    });
  });
}
