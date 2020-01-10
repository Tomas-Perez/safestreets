import 'package:flutter/material.dart';

/// Styled primary button
class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final bool submitting;

  PrimaryButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.submitting = false,
    this.width = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: RaisedButton(
        child: submitting
            ? Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : child,
        onPressed: onPressed,
      ),
    );
  }
}
