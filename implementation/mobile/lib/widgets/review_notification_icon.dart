import 'package:flutter/material.dart';

class ReviewNotificationIcon extends StatelessWidget {
  final bool pending;

  ReviewNotificationIcon({Key key, this.pending = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Positioned.fill(
          child: Icon(Icons.error),
        ),
        if (pending)
          Positioned(
            key: Key('pending reviews'),
            right: 8,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepOrange,
              ),
              width: 10,
              height: 10,
            ),
          ),
      ],
    );
  }
}
