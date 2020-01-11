import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/api_key_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/http_client.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/util/snackbar.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:mobile/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

/// Screen showing profile information, api key request, and redirects to profile edition or sign out.
class ProfileScreen extends StatefulWidget {
  @override
  State createState() => _ProfileScreenState();

  ProfileScreen({Key key}) : super(key: key);
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _fetchingKey = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _apiKeyButton(context),
          ),
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
        final display = await Navigator.pushNamed(context, EDIT_PROFILE);
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

  Widget _apiKeyButton(BuildContext context) {
    final service = Provider.of<ApiKeyService>(context);
    if (service.fetched)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Text('Api key:'),
            SizedBox(height: 10),
            SelectableText(
              '${service.key}',
              key: Key('api key'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            )
          ],
        ),
      );
    if (_fetchingKey)
      return Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 1),
      );

    return RichText(
      key: Key('get api key'),
      text: TextSpan(
        text: 'get API key',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            setState(() {
              _fetchingKey = true;
            });
            try {
              await service.fetch();
            } on TimeoutException {
              showNoConnectionSnackbar(context);
            } catch (e) {
              print(e);
              showErrorSnackbar(Key('fetch api key error'), context,
                  'There was a problem getting the api key');
            } finally {
              if (mounted)
                setState(() {
                  _fetchingKey = false;
                });
            }
          },
      ),
    );
  }
}
