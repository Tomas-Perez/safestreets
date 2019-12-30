import 'package:mobile/data/profile.dart';

final mockEmail = 'peter@mail.com';

final mockRegisteredUsers = {
  mockEmail: '1234',
};

final mockProfileByToken = {
  mockEmail: mockProfile,
};

final mockProfile = Profile(
  name: 'Pedro',
  surname: 'Alfonso',
  username: 'iampeter2019',
  email: mockEmail,
);
