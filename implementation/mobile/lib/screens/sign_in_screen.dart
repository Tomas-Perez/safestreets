import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/util/email_validation.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:mobile/widgets/secondary_button.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
        ),
        children: <Widget>[
          BackButtonSection(),
          SafeStreetsScreenTitle("Sign in"),
          _SignInForm(submitListener: (info) => _onSubmit(context, info)),
          Center(
            child: Container(
              width: 120,
              child: _signUpButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signUpButton(BuildContext context) {
    return SecondaryButton(
      child: Text("Sign up"),
      onPressed: () => Navigator.pushNamed(context, SIGN_UP),
    );
  }

  void _onSubmit(BuildContext context, _SignInFormInfo info) {
    print(info);
    Navigator.pushReplacementNamed(context, HOME);
  }
}

typedef _SignInSubmitListener = void Function(_SignInFormInfo);

class _SignInForm extends StatefulWidget {
  final _SignInSubmitListener submitListener;

  _SignInForm({Key key, @required this.submitListener}) : super(key: key);

  @override
  State createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _signInInfo = _SignInFormInfo.empty();
  var _autovalidate = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
      child: Column(
        children: <Widget>[
          _emailField(),
          _passwordField(),
          Container(
            width: 120,
            child: _submitButton(),
          ),
        ],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
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
      onSaved: (email) => _signInInfo.email = email,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      focusNode: _passwordFocus,
      decoration: InputDecoration(
        labelText: 'Password *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "Password missing";
        return null;
      },
      onFieldSubmitted: (term) {
        _passwordFocus.unfocus();
        _submit();
      },
      onSaved: (password) => _signInInfo.password = password,
    );
  }

  _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      _emailFocus.unfocus();
      _passwordFocus.unfocus();
      form.save();
      widget.submitListener(_signInInfo);
    } else {
      if (!_autovalidate) {
        setState(() {
          _autovalidate = true;
        });
      }
    }
  }

  Widget _submitButton() {
    return RaisedButton(
      child: Text("Sign in"),
      onPressed: _submit,
    );
  }
}

class _SignInFormInfo {
  String email, password;

  _SignInFormInfo({@required this.email, @required this.password});

  _SignInFormInfo.empty();

  @override
  String toString() {
    return '_SignInFormInfo{email: $email, password: $password}';
  }
}
