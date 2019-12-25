import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  SecondaryButton({
    Key key,
    @required this.onPressed,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      child: child,
      onPressed: onPressed,
      borderSide: BorderSide(color: Colors.blue, width: 2),
    );
  }
}
