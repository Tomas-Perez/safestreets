import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final bool submitting;

  SecondaryButton({
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
      child: OutlineButton(
        child: submitting
            ? Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).backgroundColor,
                  strokeWidth: 2,
                ),
              )
            : child,
        onPressed: onPressed,
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}
