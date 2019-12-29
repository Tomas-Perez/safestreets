import 'package:flutter/material.dart';
import 'package:mobile/data/profile.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:mobile/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context);
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: ListView(
        children: <Widget>[
          BackButtonSection(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                SafeStreetsScreenTitle("Profile"),
                SizedBox(height: 30),
                _buildRow("Name:", profile.name),
                SizedBox(height: 20),
                _buildRow("Surname:", profile.surname),
                SizedBox(height: 20),
                _buildRow("Username:", profile.username),
                SizedBox(height: 20),
                _buildRow("Email:", profile.email),
              ],
            ),
          ),
          SizedBox(height: 30),
          Center(child: _editButton(context)),
          Center(child: _signOutButton()),
        ],
      ),
    );
  }

  Widget _buildRow(String type, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(type),
        Text(value),
      ],
    );
  }

  Widget _editButton(BuildContext context) {
    return PrimaryButton(
      child: Text("Edit"),
      onPressed: () => Navigator.pushNamed(context, EDIT_PROFILE),
    );
  }

  Widget _signOutButton() {
    return SecondaryButton(
      child: Text("Sign out"),
      onPressed: () => print("sign out"),
    );
  }
}
