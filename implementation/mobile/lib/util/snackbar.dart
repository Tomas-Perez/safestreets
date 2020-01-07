import 'package:flutter/material.dart';

const _SNACKBAR_DURATION = const Duration(seconds: 1);

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackbar(
  BuildContext context,
  String message,
) =>
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
        duration: _SNACKBAR_DURATION,
      ),
    );

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSimpleSnackbar(
  BuildContext context,
  String message,
) =>
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: _SNACKBAR_DURATION,
      ),
    );
