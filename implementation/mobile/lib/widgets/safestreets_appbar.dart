import 'package:flutter/material.dart';

class SafeStreetsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SafeStreetsAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.error),
        onPressed: () {},
      ),
      title: Text("SafeStreets"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {},
        )
      ],
    );
  }

  Size get preferredSize => Size.fromHeight(40.0);
}