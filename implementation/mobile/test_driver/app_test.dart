import 'package:flutter_driver/flutter_driver.dart';
import 'package:mobile/routes.dart';
import 'package:test/test.dart';

void main() {
  group('SafeStreets App', () {
    final reportViolationFinder = find.text("Report a violation");

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('finds report violation card', () async {
      expect(await driver.getText(reportViolationFinder), "Report a violation");
    });
    
    test('tapping report violation card redirects to ReportViolationScreen', () async {
      await driver.tap(find.byValueKey('REPORT card'));
      await driver.waitFor(find.byValueKey('$REPORT screen'));
    });
  });
}
