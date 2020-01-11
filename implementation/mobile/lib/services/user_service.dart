import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/profile.dart';
import 'package:mobile/services/http_client.dart';

/// Provides profile information for the current user, as well as profile edition
/// and user sign up.
abstract class UserService with ChangeNotifier {
  AsyncSnapshot<Profile> get currentProfile;

  Future<void> editProfile(EditProfile edit);

  Future<void> signUp(CreateProfile createProfile);
}

class MockUserService with ChangeNotifier implements UserService {
  final Map<String, Profile> _profileByToken;
  final String _token;
  Profile __profile;

  MockUserService(this._profileByToken, this._token)
      : __profile = _profileByToken[_token];

  @override
  AsyncSnapshot<Profile> get currentProfile => _profile == null
      ? AsyncSnapshot.withData(ConnectionState.waiting, null)
      : AsyncSnapshot.withData(ConnectionState.done, _profile);

  set _profile(Profile profile) {
    __profile = profile;
    notifyListeners();
  }

  Profile get _profile => __profile;

  @override
  Future<void> editProfile(EditProfile edit) async {
    _profile = Profile(
      name: edit.name,
      surname: edit.surname,
      username: edit.username,
      email: edit.email,
    );
    _profileByToken[_token] = _profile;
  }

  @override
  Future<void> signUp(CreateProfile createProfile) async {
    print(createProfile);
  }
}

class HttpUserService with ChangeNotifier implements UserService {
  final _dio = getNewDioClient();
  Profile _profile;
  bool _fetching = false;
  void Function(String) onNewTokenListener;

  Future<void> _fetchCurrentProfile() async {
    _fetching = true;
    notifyListeners();
    try {
      final json = (await _dio.get('/user/me')).data;
      _profile = Profile(
        name: json['name'],
        surname: json['surname'],
        username: json['username'],
        email: json['email'],
      );
    } catch (exc) {
      print(exc);
    } finally {
      _fetching = false;
      notifyListeners();
    }
  }

  @override
  AsyncSnapshot<Profile> get currentProfile => AsyncSnapshot.withData(
        _fetching ? ConnectionState.waiting : ConnectionState.done,
        _profile,
      );

  @override
  Future<void> editProfile(EditProfile edit) async {
    try {
      final res = await _dio.put('/user/me', data: {
        'name': edit.name,
        'surname': edit.surname,
        'username': edit.username,
        'email': edit.email,
      });
      _profile = Profile(
        name: edit.name,
        surname: edit.surname,
        username: edit.username,
        email: edit.email,
      );
      if (onNewTokenListener != null) onNewTokenListener(res.data['token']);
      notifyListeners();
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == HttpStatus.conflict) {
        final message = e.response.data['message'] as String;
        if (message == 'Duplicated key: username') {
          throw const UsernameTakenException();
        } else if (message == 'Duplicated key: email') {
          throw const EmailTakenException();
        }
      }
      throw e;
    }
  }

  set baseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  set token(String token) {
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
    };
    if (token != null) _fetchCurrentProfile();
  }

  @override
  Future<void> signUp(CreateProfile createProfile) async {
    try {
      await _dio.post('/user/sign-up', data: {
        'name': createProfile.name,
        'surname': createProfile.surname,
        'username': createProfile.username,
        'email': createProfile.email,
        'password': createProfile.password,
      });
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == HttpStatus.conflict) {
        final message = e.response.data['message'] as String;
        if (message == 'Duplicated key: username') {
          throw const UsernameTakenException();
        } else if (message == 'Duplicated key: email') {
          throw const EmailTakenException();
        }
      }
      throw e;
    }
  }
}

class EmailTakenException implements Exception {
  final message = 'Email taken';

  const EmailTakenException();
}

class UsernameTakenException implements Exception {
  final message = 'Username taken';

  const UsernameTakenException();
}
