import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/util/snackbar.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:mobile/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: ListView(
        children: <Widget>[
          BackButtonSection(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: _buildProfileData(context),
          ),
          SizedBox(height: 30),
          Center(child: Builder(builder: (ctx) => _editButton(ctx))),
          Center(child: _signOutButton(context)),
        ],
      ),
    );
  }

  Widget _buildProfileData(BuildContext context) {
    final profileSnapshot = Provider.of<UserService>(context).currentProfile;
    if (profileSnapshot.connectionState == ConnectionState.waiting) {
      return Container(
        width: 50,
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (profileSnapshot.hasError) {
      return Text('${profileSnapshot.error}');
    }
    final profile = profileSnapshot.data;
    return Column(
      children: <Widget>[
        SafeStreetsScreenTitle("Profile"),
        SizedBox(height: 30),
        _buildRow(Key('profile name'), "Name:", profile.name),
        SizedBox(height: 20),
        _buildRow(Key('profile surname'), "Surname:", profile.surname),
        SizedBox(height: 20),
        _buildRow(Key('profile username'), "Username:", profile.username),
        SizedBox(height: 20),
        _buildRow(Key('profile email'), "Email:", profile.email),
      ],
    );
  }

  Widget _buildRow(Key key, String type, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(type),
        Text(value, key: key),
      ],
    );
  }

  Widget _editButton(BuildContext context) {
    return PrimaryButton(
      key: Key('$EDIT_PROFILE redirect'),
      child: Text("Edit"),
      onPressed: () async {
        final display = Navigator.pushNamed(context, EDIT_PROFILE);
        if (display != null)
          showSimpleSnackbar(
            Key('successful profile edition'),
            context,
            'Profile edition successful!',
          );
      },
    );
  }

  Widget _signOutButton(BuildContext context) {
    return SecondaryButton(
      key: Key('sign out'),
      child: Text("Sign out"),
      onPressed: () async {
        Provider.of<AuthService>(context).logout();
        await Navigator.pushNamedAndRemoveUntil(context, SIGN_IN, (_) => false);
      },
    );
  }

  ProfileScreen({Key key}) : super(key: key);
}
