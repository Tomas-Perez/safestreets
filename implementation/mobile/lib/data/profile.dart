import 'package:flutter/foundation.dart';

class Profile {
  String name, surname, username, email;

  Profile({
    @required this.name,
    @required this.surname,
    @required this.username,
    @required this.email,
  });
}

class EditProfile {
  String name, surname, username, email;

  EditProfile({
    @required this.name,
    @required this.surname,
    @required this.username,
    @required this.email,
  });

  EditProfile.empty();

  EditProfile.fromProfile(Profile profile) {
    name = profile.name;
    surname = profile.surname;
    username = profile.username;
    email = profile.email;
  }
}

class CreateProfile {
  final String name, surname, username, email, password;

  CreateProfile({
    this.name,
    this.surname,
    this.username,
    this.email,
    this.password,
  });
}
