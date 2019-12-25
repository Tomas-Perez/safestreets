import 'package:flutter/material.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:mobile/widgets/secondary_button.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: ListView(
        children: <Widget>[
          BackButtonSection(),
          SafeStreetsScreenTitle("Profile"),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _buildRow("Name:", "Peter"),
                SizedBox(height: 20),
                _buildRow("Surname:", "Alfonso"),
                SizedBox(height: 20),
                _buildRow("Username:", "iampeter2019"),
                SizedBox(height: 20),
                _buildRow("Email:", "peter@mail.com"),
              ],
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              width: 120,
              child: _editButton(),
            ),
          ),
          Center(
            child: Container(
              width: 120,
              child: _signOutButton(),
            ),
          ),
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

  Widget _editButton() {
    return RaisedButton(
      child: Text("Edit"),
      onPressed: () => print('edit'),
    );
  }

  Widget _signOutButton() {
    return SecondaryButton(
      child: Text("Sign out"),
      onPressed: () => print("sign out"),
    );
  }
}
