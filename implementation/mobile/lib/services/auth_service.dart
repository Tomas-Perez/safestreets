import 'package:flutter/material.dart';

abstract class AuthService with ChangeNotifier {
  String get token;
  Future<void> silentLogin();
  Future<void> login(String email, String password);
  Future<void> logout();
  bool get authenticated;
}

class NoUserForEmailException implements Exception {
  final String email;
  final String message;

  const NoUserForEmailException(this.email)
      : message = 'No user found for email $email';
}

class WrongPasswordException implements Exception {
  final String message = 'Wrong password';

  const WrongPasswordException();
}

class SilentLoginFailedException implements Exception {
  final String message = 'Silent login failed';

  const SilentLoginFailedException();
}

class MockAuthService with ChangeNotifier implements AuthService{
  final Map<String, String> _registeredUsers;
  String __token;

  MockAuthService(this._registeredUsers);

  @override
  Future<void> login(String email, String password) async {
    final password = _registeredUsers[email];
    if (password == null) throw NoUserForEmailException(email);
    if (password != password) const WrongPasswordException();
    _token = email;
  }

  @override
  Future<void> logout() async {
    _token = null;
  }

  String get token => __token;

  set _token(String token) {
    __token = token;
    notifyListeners();
  }

  @override
  bool get authenticated => token != null;

  @override
  Future<void> silentLogin() async {
    final anEmail = _registeredUsers.keys.first;
    if (anEmail == null) throw const SilentLoginFailedException();
    _token = anEmail;
  }
}
