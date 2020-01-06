import 'package:flutter/material.dart';
import 'package:mobile/data/profile.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/util/email_validation.dart';
import 'package:mobile/util/submit_controller.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _controller = SingleListenerController<void>();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: ListView(
        children: <Widget>[
          BackButtonSection(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: <Widget>[
                SafeStreetsScreenTitle('Edit profile'),
                _EditProfileForm(
                  controller: _controller,
                  submitListener: _onSubmit,
                ),
                _submitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return PrimaryButton(
      child: Text('Confirm'),
      submitting: _submitting,
      onPressed: () => _controller.submit(),
    );
  }

  void _onSubmit(EditProfile edit) async {
    final service = Provider.of<UserService>(context);
    setState(() {
      _submitting = true;
    });
    await service.editProfile(edit);
    setState(() {
      _submitting = false;
    });
    Navigator.pop(context);
  }
}

typedef _EditInfoSubmitListener = void Function(EditProfile);

class _EditProfileForm extends StatefulWidget {
  final _EditInfoSubmitListener submitListener;
  final SubmitController<void> controller;

  _EditProfileForm({
    Key key,
    @required this.submitListener,
    @required this.controller,
  }) : super(key: key);

  @override
  State createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _surnameFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  var _editInfo;
  var _autovalidate = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller.register(_submit);
    }
    final profileSnapshot =
        Provider.of<UserService>(context, listen: false).currentProfile;
    if (profileSnapshot.hasData)
      _editInfo = EditProfile.fromProfile(profileSnapshot.data);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
      child: _editInfo != null
          ? Column(
              children: <Widget>[
                _nameField(),
                _surnameField(),
                _usernameField(),
                _emailField(),
              ],
            )
          : Text('Not logged in'),
    );
  }

  Widget _nameField() {
    return TextFormField(
      initialValue: _editInfo.name,
      textInputAction: TextInputAction.next,
      focusNode: _nameFocus,
      decoration: InputDecoration(
        labelText: 'Name *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Name missing";
        return null;
      },
      onFieldSubmitted: (term) {
        _nameFocus.unfocus();
        FocusScope.of(context).requestFocus(_surnameFocus);
      },
      onSaved: (name) => _editInfo.name = name,
    );
  }

  Widget _surnameField() {
    return TextFormField(
      initialValue: _editInfo.surname,
      textInputAction: TextInputAction.next,
      focusNode: _surnameFocus,
      decoration: InputDecoration(
        labelText: 'Surname *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Surname missing";
        return null;
      },
      onFieldSubmitted: (term) {
        _surnameFocus.unfocus();
        FocusScope.of(context).requestFocus(_usernameFocus);
      },
      onSaved: (surname) => _editInfo.surname = surname,
    );
  }

  Widget _usernameField() {
    return TextFormField(
      initialValue: _editInfo.username,
      textInputAction: TextInputAction.next,
      focusNode: _usernameFocus,
      decoration: InputDecoration(
        labelText: 'Username *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Username missing";
        return null;
      },
      onFieldSubmitted: (term) {
        _usernameFocus.unfocus();
        FocusScope.of(context).requestFocus(_emailFocus);
      },
      onSaved: (username) => _editInfo.username = username,
    );
  }

  Widget _emailField() {
    return TextFormField(
      initialValue: _editInfo.email,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailFocus,
      decoration: InputDecoration(
        labelText: 'Email *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Email missing";
        if (!isValidEmail(value)) return "Please enter a valid email";
        return null;
      },
      onFieldSubmitted: (term) {
        _emailFocus.unfocus();
        _submit();
      },
      onSaved: (email) => _editInfo.email = email,
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      _nameFocus.unfocus();
      _surnameFocus.unfocus();
      _usernameFocus.unfocus();
      _emailFocus.unfocus();
      form.save();
      widget.submitListener(_editInfo);
    } else {
      if (!_autovalidate) {
        setState(() {
          _autovalidate = true;
        });
      }
    }
  }
}