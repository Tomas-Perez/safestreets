import 'package:flutter_driver/flutter_driver.dart';
import 'package:mobile/routes.dart';
import 'package:test/test.dart';

void main() {
  group('Sign in test', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    final email = 'user0@mail.com';
    final password = 'pass1';

    final signInScreen = find.byValueKey('$SIGN_IN screen');
    final profileButton = find.byValueKey('$PROFILE redirect');
    final reviewsButton = find.byValueKey('open reviews');

    test('logs in correctly', () async {
      await driver.waitFor(signInScreen);
      await driver.waitForAbsent(profileButton);
      await driver.waitForAbsent(reviewsButton);
      final emailField = find.byValueKey('$SIGN_IN email field');
      await driver.tap(emailField);
      await driver.enterText(email);
      await driver.waitFor(find.text(email));
      final passwordField = find.byValueKey('$SIGN_IN password field');
      await driver.tap(passwordField);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await driver.tap(find.byValueKey('$SIGN_IN submit'));
      await driver.waitFor(find.byValueKey('$HOME screen'));
      await driver.waitFor(profileButton);
      await driver.waitFor(reviewsButton);
    });

    test('logs out correctly', () async {
      await driver.tap(profileButton);
      await driver.waitFor(find.byValueKey('$PROFILE screen'));
      await driver.tap(find.byValueKey('sign out'));
      await driver.waitFor(signInScreen);
      await driver.waitForAbsent(profileButton);
      await driver.waitForAbsent(reviewsButton);
    });
  });
}
