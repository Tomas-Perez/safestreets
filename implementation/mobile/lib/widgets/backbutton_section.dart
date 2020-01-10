import 'package:flutter/material.dart';

class BackButtonSection extends StatelessWidget {
  const BackButtonSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      alignment: Alignment.centerLeft,
      child: Navigator.canPop(context)
          ? FlatButton(
              padding: EdgeInsets.all(0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.arrow_back_ios, size: 14.0),
                  SizedBox(width: 5),
                  Text("Back"),
                ],
              ),
              onPressed: () => Navigator.pop(context),
            )
          : Container(),
    );
  }
}
