import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/widgets/photo_review_alert.dart';

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
        onPressed: () async {
          final res = await showDialog<ReviewResponse>(
            context: context,
            builder: (_) => PhotoReviewAlert(),
          );
          print(res);
        },
      ),
      title: Text("SafeStreets"),
      actions: <Widget>[
        if (currentRouteName(context) != PROFILE)
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, PROFILE),
          )
      ],
    );
  }

  String currentRouteName(BuildContext context) =>
      ModalRoute.of(context).settings.name;

  Size get preferredSize => Size.fromHeight(40.0);
}
