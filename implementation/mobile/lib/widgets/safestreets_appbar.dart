import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/photo_review_alert.dart';
import 'package:mobile/widgets/review_notification_icon.dart';
import 'package:provider/provider.dart';

class SafeStreetsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SafeStreetsAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedIn = Provider.of<AuthService>(context).isAuthenticated();
    return AppBar(
      centerTitle: true,
      leading: loggedIn ? IconButton(
        icon: ReviewNotificationIcon(),
        onPressed: () async {
          final res = await showDialog<ReviewResponse>(
            context: context,
            builder: (_) => PhotoReviewAlert(),
          );
          print(res);
        },
      ) : null,
      automaticallyImplyLeading: false,
      title: Text("SafeStreets"),
      actions: <Widget>[
        if (!currentRouteName(context).contains(PROFILE) && loggedIn)
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
