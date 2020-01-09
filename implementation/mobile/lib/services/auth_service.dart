import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as ss;

abstract class AuthService with ChangeNotifier {
  String get token;

  Future<void> silentLogin();

  Future<void> login(String email, String password);

  Future<void> logout();

  bool get authenticated;
}

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

class SilentLoginFailedException implements Exception {
  final String message = 'Silent login failed';

  const SilentLoginFailedException();
}

class MockAuthService with ChangeNotifier implements AuthService {
  final Map<String, String> _registeredUsers;
  String __token;

  MockAuthService(this._registeredUsers);

  @override
  Future<void> login(String email, String password) async {
    final password = _registeredUsers[email];
    if (password == null || password != password)
      throw const InvalidCredentialsException();
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

class HttpAuthService with ChangeNotifier implements AuthService {
  final _dio = Dio();
  final storage = ss.FlutterSecureStorage();
  String __token;

  String get _token => __token;

  set _token(String value) {
    __token = value;
    notifyListeners();
  }

  @override
  bool get authenticated => _token != null;

  @override
  Future<void> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth', data: {
        "email": email,
        "password": password,
      });
      final token = res.data['token'];
      await storage.write(key: 'token', value: token);
      _token = token;
    } on DioError catch (exc) {
      if (exc.response != null &&
          exc.response.statusCode == HttpStatus.unauthorized) {
        throw const InvalidCredentialsException();
      }
    }
  }

  @override
  Future<void> logout() async {
    _token = null;
    await storage.delete(key: 'token');
  }

  @override
  Future<void> silentLogin() async {
    try {
      final token = await storage.read(key: 'token');
      await _dio.get(
        '/user/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          }
        ),
      );
      _token = token;
    } catch (_) {
      throw SilentLoginFailedException();
    }
  }

  @override
  String get token => _token;

  set baseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
}
