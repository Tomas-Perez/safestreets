import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/profile.dart';

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
  final _dio = Dio();
  Profile _profile;
  bool _fetching = false;

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
      await _dio.put('/user/me', data: {
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
      notifyListeners();
    } catch (e) {
      print(e);
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
    await _dio.post('/user/sign-up', data: {
      'name': createProfile.name,
      'surname': createProfile.surname,
      'username': createProfile.username,
      'email': createProfile.email,
      'password': createProfile.password,
    });
  }
}
