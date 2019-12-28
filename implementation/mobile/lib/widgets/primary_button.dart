import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;

  PrimaryButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.width = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: RaisedButton(
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}
