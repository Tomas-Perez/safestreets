import 'package:flutter/material.dart';
import 'package:mobile/data/profile.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/http_client.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/util/email_validation.dart';
import 'package:mobile/util/snackbar.dart';
import 'package:mobile/util/submit_controller.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpScreenState();

  SignUpScreen({Key key}) : super(key: key);
}

class _SignUpScreenState extends State<SignUpScreen> {
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
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: Column(
              children: <Widget>[
                SafeStreetsScreenTitle("Sign up"),
                Builder(
                  builder: (ctx) => _SignUpForm(
                    submitListener: (form) => _onSubmit(ctx, form),
                    controller: _controller,
                  ),
                ),
                _submitButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _submitButton() {
    return PrimaryButton(
      key: Key('sign up'),
      submitting: _submitting,
      child: Text("Sign up"),
      onPressed: _controller.submit,
    );
  }

  _onSubmit(BuildContext context, _SignUpFormInfo form) async {
    final service = Provider.of<UserService>(context);
    setState(() {
      _submitting = true;
    });
    try {
      await service.signUp(
        CreateProfile(
          name: form.name,
          surname: form.surname,
          username: form.username,
          password: form.password,
          email: form.email,
        ),
      );
      Navigator.pop(context, SignUpResult.success());
    } on TimeoutException {
      showNoConnectionSnackbar(context);
    } catch (e) {
      print(e);
      showErrorSnackbar(context, 'There was a problem performing the sign up');
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }
}

typedef _SignUpSubmitListener = void Function(_SignUpFormInfo);

class _SignUpForm extends StatefulWidget {
  final _SignUpSubmitListener submitListener;
  final SubmitController<void> controller;

  _SignUpForm({
    Key key,
    @required this.submitListener,
    @required this.controller,
  }) : super(key: key);

  @override
  State createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _surnameFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _repeatPasswordFocus = FocusNode();
  final _signUpInfo = _SignUpFormInfo.empty();
  var _passwordFieldValue = "";
  var _autovalidate = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller.register(_submit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
      child: Column(
        children: <Widget>[
          _nameField(),
          _surnameField(),
          _usernameField(),
          _emailField(),
          _passwordField(),
          _repeatPasswordField(),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextFormField(
      key: Key('$SIGN_UP name field'),
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
      onSaved: (name) => _signUpInfo.name = name,
    );
  }

  Widget _surnameField() {
    return TextFormField(
      key: Key('$SIGN_UP surname field'),
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
      onSaved: (surname) => _signUpInfo.surname = surname,
    );
  }

  Widget _usernameField() {
    return TextFormField(
      key: Key('$SIGN_UP username field'),
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
      onSaved: (username) => _signUpInfo.username = username,
    );
  }

  Widget _emailField() {
    return TextFormField(
      key: Key('$SIGN_UP email field'),
      textInputAction: TextInputAction.next,
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
        FocusScope.of(context).requestFocus(_passwordFocus);
      },
      onSaved: (email) => _signUpInfo.email = email,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      key: Key('$SIGN_UP password field'),
      textInputAction: TextInputAction.next,
      focusNode: _passwordFocus,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Password missing";
        return null;
      },
      onChanged: (value) => _passwordFieldValue = value,
      onFieldSubmitted: (term) {
        _passwordFocus.unfocus();
        FocusScope.of(context).requestFocus(_repeatPasswordFocus);
      },
      onSaved: (password) => _signUpInfo.password = password,
    );
  }

  Widget _repeatPasswordField() {
    return TextFormField(
      key: Key('$SIGN_UP repeat password field'),
      textInputAction: TextInputAction.done,
      focusNode: _repeatPasswordFocus,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Repeat password *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Enter your password again";
        if (value != _passwordFieldValue) return "Passwords do not match";
        return null;
      },
      onFieldSubmitted: (term) {
        _repeatPasswordFocus.unfocus();
        _submit();
      },
    );
  }

  _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      _nameFocus.unfocus();
      _surnameFocus.unfocus();
      _usernameFocus.unfocus();
      _emailFocus.unfocus();
      _passwordFocus.unfocus();
      _repeatPasswordFocus.unfocus();
      form.save();
      widget.submitListener(_signUpInfo);
    } else {
      if (!_autovalidate) {
        setState(() {
          _autovalidate = true;
        });
      }
    }
  }
}

class _SignUpFormInfo {
  String name, surname, username, email, password;

  _SignUpFormInfo({
    @required this.name,
    @required this.surname,
    @required this.username,
    @required this.email,
    @required this.password,
  });

  _SignUpFormInfo.empty();
}

class SignUpResult {
  final bool success;

  SignUpResult.success() : success = true;


}