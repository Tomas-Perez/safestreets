import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key}): super(key: key);

  @override
  State createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(child: Center(child: CircularProgressIndicator()));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false)
          .silentLogin()
          .then((_) => Navigator.pushReplacementNamed(context, HOME))
          .catchError((_) => Navigator.pushReplacementNamed(context, SIGN_IN));
    });
  }


}
