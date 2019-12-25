import 'package:flutter/material.dart';

class SafeStreetsScreenTitle extends StatelessWidget {
  final String title;


  SafeStreetsScreenTitle(this.title, {Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}