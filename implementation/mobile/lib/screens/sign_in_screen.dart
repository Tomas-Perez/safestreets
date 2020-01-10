import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/screens/sign_up_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/http_client.dart';
import 'package:mobile/util/email_validation.dart';
import 'package:mobile/util/snackbar.dart';
import 'package:mobile/util/submit_controller.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:mobile/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  @override
  State createState() => _SignInScreenState();

  SignInScreen({Key key}) : super(key: key);
}

class _SignInScreenState extends State<SignInScreen> {
  final _controller = SingleListenerController<void>();
  var _submitting = false;

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
                SafeStreetsScreenTitle("Sign in"),
                Builder(
                  builder: (ctx) => _SignInForm(
                    submitListener: (info) => _onSubmit(ctx, info),
                    controller: _controller,
                  ),
                ),
                _submitButton(),
                Builder(builder: (ctx) => _signUpButton(ctx)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return PrimaryButton(
      key: Key('sign in'),
      submitting: _submitting,
      child: Text("Sign in"),
      onPressed: _controller.submit,
    );
  }

  Widget _signUpButton(BuildContext context) {
    return SecondaryButton(
      key: Key('$SIGN_UP redirect'),
      child: Text("Sign up"),
      onPressed: () async {
        final res = await Navigator.pushNamed(context, SIGN_UP) as SignUpResult;
        if (res?.success ?? false) {
          showSimpleSnackbar(Key('successful sign-up'), context, 'Sign up successful');
        }
      },
    );
  }

  Future<void> _onSubmit(BuildContext context, _SignInFormInfo info) async {
    setState(() {
      _submitting = true;
    });
    try {
      await Provider.of<AuthService>(context).login(info.email, info.password);
      await Navigator.pushReplacementNamed(context, HOME);
    } on TimeoutException catch (_) {
      showNoConnectionSnackbar(context);
    } on InvalidCredentialsException {
      showErrorSnackbar(Key('invalid credentials'), context, "Invalid credentials");
    } catch (e) {
      print(e);
      showErrorSnackbar(Key('sign-in error'), context, "There was a problem performing the sign-in");
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }
}

typedef _SignInSubmitListener = void Function(_SignInFormInfo);

class _SignInForm extends StatefulWidget {
  final _SignInSubmitListener submitListener;
  final SubmitController<void> controller;

  _SignInForm({
    Key key,
    @required this.submitListener,
    @required this.controller,
  }) : super(key: key);

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
          _emailField(),
          _passwordField(),
        ],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      key: Key('$SIGN_IN email field'),
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
      key: Key('$SIGN_IN password field'),
      textInputAction: TextInputAction.done,
      obscureText: true,
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
