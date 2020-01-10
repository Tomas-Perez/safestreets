import 'package:dio/dio.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:mobile/routes.dart';
import 'package:test/test.dart';

import 'config.dart';
import 'test_helpers.dart';

void main() {
  group('Safestreets app', () {
    FlutterDriver driver;

    setUpAll(() async {
      await Dio().get(
        '$baseUrl/debug/reinitializedb',
        options: Options(
          headers: {
            'Authorization': 'Bearer $debugToken',
          },
        ),
      );
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
    final homeScreen = find.byValueKey('$HOME screen');
    final signInEmailField = find.byValueKey('$SIGN_IN email field');
    final signInPasswordField = find.byValueKey('$SIGN_IN password field');
    final signInButton = find.byValueKey('sign in');

    test('signs in correctly', () async {
      await driver.waitFor(signInScreen);
      await driver.waitForAbsent(profileButton);
      await driver.waitForAbsent(reviewsButton);
      await driver.enterTextInField(signInEmailField, email);
      await driver.enterTextInField(signInPasswordField, password);
      await driver.tap(signInButton);
      await driver.waitFor(homeScreen);
      await driver.waitFor(profileButton);
      await driver.waitFor(reviewsButton);
    });

    test('signs out correctly', () async {
      await driver.waitFor(homeScreen);
      await driver.tap(profileButton);
      await driver.waitFor(find.byValueKey('$PROFILE screen'));
      await driver.tap(find.byValueKey('sign out'));
      await driver.waitFor(signInScreen);
      await driver.waitForAbsent(profileButton);
      await driver.waitForAbsent(reviewsButton);
    });

    test('signs up correctly', () async {
      await driver.waitFor(signInScreen);
      await driver.tap(find.byValueKey('$SIGN_UP redirect'));
      await driver.waitFor(find.byValueKey('$SIGN_UP screen'));
      final nameField = find.byValueKey('$SIGN_UP name field');
      final surnameField = find.byValueKey('$SIGN_UP surname field');
      final usernameField = find.byValueKey('$SIGN_UP username field');
      final emailField = find.byValueKey('$SIGN_UP email field');
      final passwordField = find.byValueKey('$SIGN_UP password field');
      final repeatPasswordField =
          find.byValueKey('$SIGN_UP repeat password field');
      final email = 'email@mail.com';
      final password = 'pass';

      await driver.enterTextInField(nameField, 'name');
      await driver.enterTextInField(surnameField, 'surname');
      await driver.enterTextInField(usernameField, 'username');
      await driver.enterTextInField(emailField, email);
      await driver.enterTextInField(passwordField, password);
      await driver.enterTextInField(repeatPasswordField, password);
      await driver.tap(find.byValueKey('sign up'));
      await driver.waitFor(signInScreen);
      await driver.enterTextInField(signInEmailField, email);
      await driver.enterTextInField(signInPasswordField, password);
      await driver.tap(signInButton);
      await driver.waitFor(homeScreen);
      await driver.waitFor(profileButton);
      await driver.waitFor(reviewsButton);
    });
  });
}
