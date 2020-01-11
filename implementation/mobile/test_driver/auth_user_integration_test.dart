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

    final mockEmail = 'user0@mail.com';
    final mockPassword = 'pass1';

    final profileButton = find.byValueKey('$PROFILE redirect');
    final reviewsButton = find.byValueKey('open reviews');
    final signInEmailField = find.byValueKey('$SIGN_IN email field');
    final signInPasswordField = find.byValueKey('$SIGN_IN password field');
    final signInButton = find.byValueKey('sign in');

    test('signs in correctly', () async {
      await driver.waitFor(signInScreen);
      await driver.waitForAbsent(profileButton);
      await driver.waitForAbsent(reviewsButton);
      await driver.enterTextInField(signInEmailField, mockEmail);
      await driver.enterTextInField(signInPasswordField, mockPassword);
      await driver.tap(signInButton);
      await driver.waitFor(homeScreen);
      await driver.waitFor(profileButton);
      await driver.waitFor(reviewsButton);
    });

    test('shows user profile correctly', () async {
      await driver.waitFor(homeScreen);
      await driver.tap(profileButton);
      await driver.waitFor(profileScreen);

      final mockName = 'User1';
      final mockSurname = 'last1';
      final mockUsername = 'user1';

      expect(mockName, await driver.getText(find.byValueKey('profile name')));
      expect(mockSurname,
          await driver.getText(find.byValueKey('profile surname')));
      expect(mockUsername,
          await driver.getText(find.byValueKey('profile username')));
      expect(mockEmail, await driver.getText(find.byValueKey('profile email')));
    });

    test('gets api key correctly', () async {
      await driver.waitFor(profileScreen);
      await driver.tap(find.byValueKey('get api key'));
      await driver.waitFor(find.byValueKey('api key'));
    });

    test('edits user profile correctly', () async {
      await driver.waitFor(profileScreen);
      await driver.tap(find.byValueKey('$EDIT_PROFILE redirect'));
      await driver.waitFor(editProfileScreen);

      final nameField = find.byValueKey('$EDIT_PROFILE name field');
      final surnameField = find.byValueKey('$EDIT_PROFILE surname field');
      final usernameField = find.byValueKey('$EDIT_PROFILE username field');
      final emailField = find.byValueKey('$EDIT_PROFILE email field');

      final newName = 'newName';
      final newSurname = 'newSurname';
      final newUsername = 'newUsername';
      final newEmail = 'newMail@mail.com';

      await driver.enterTextInField(nameField, newName);
      await driver.enterTextInField(surnameField, newSurname);
      await driver.enterTextInField(usernameField, newUsername);
      await driver.enterTextInField(emailField, newEmail);

      await driver.tap(find.byValueKey('edit profile'));
      await driver.waitFor(profileScreen);
      await driver.waitFor(find.byValueKey('successful profile edition'));

      expect(newName, await driver.getText(find.byValueKey('profile name')));
      expect(
          newSurname, await driver.getText(find.byValueKey('profile surname')));
      expect(newUsername,
          await driver.getText(find.byValueKey('profile username')));
      expect(newEmail, await driver.getText(find.byValueKey('profile email')));
    });

    test('signs out correctly', () async {
      await driver.waitFor(profileScreen);
      await driver.tap(find.byValueKey('sign out'));
      await driver.waitFor(signInScreen);
      await driver.waitForAbsent(profileButton);
      await driver.waitForAbsent(reviewsButton);
    });

    test('signs up correctly', () async {
      await driver.waitFor(signInScreen);
      await driver.tap(find.byValueKey('$SIGN_UP redirect'));
      await driver.waitFor(signUpScreen);
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
      await driver.waitFor(find.byValueKey('successful sign-up'));

      await driver.enterTextInField(signInEmailField, email);
      await driver.enterTextInField(signInPasswordField, password);
      await driver.tap(signInButton);
      await driver.waitFor(homeScreen);
      await driver.waitFor(profileButton);
      await driver.waitFor(reviewsButton);
    });
  });
}
