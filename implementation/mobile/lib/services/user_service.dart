import 'package:flutter/material.dart';
import 'package:mobile/data/profile.dart';

abstract class UserService with ChangeNotifier {
  AsyncSnapshot<Profile> get currentProfile;

  Future<void> editProfile(EditProfile edit);
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
}
