import 'package:flutter/material.dart';

const _SNACKBAR_DURATION = const Duration(seconds: 1);

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackbar(
    Key key,
  BuildContext context,
  String message,
) =>
    Scaffold.of(context).showSnackBar(
      SnackBar(
        key: key,
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
        duration: _SNACKBAR_DURATION,
      ),
    );

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSimpleSnackbar(
    Key key,
  BuildContext context,
  String message,
) =>
    Scaffold.of(context).showSnackBar(
      SnackBar(
        key: key,
        content: Text(message),
        duration: _SNACKBAR_DURATION,
      ),
    );

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
    showNoConnectionSnackbar(BuildContext context) =>
        showErrorSnackbar(Key('connection lost'), context, 'Connection to server lost');
