import 'package:flutter/material.dart';
import 'package:mobile/data/report_review.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/review_service.dart';
import 'package:mobile/util/snackbar.dart';
import 'package:mobile/widgets/api_connection_config_alert.dart';
import 'package:mobile/widgets/photo_review_alert.dart';
import 'package:mobile/widgets/review_notification_icon.dart';
import 'package:provider/provider.dart';

class SafeStreetsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SafeStreetsAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedIn = Provider.of<AuthService>(context).authenticated;
    final reviewService = Provider.of<ReviewService>(context);
    return AppBar(
      centerTitle: true,
      leading: loggedIn
          ? IconButton(
              key: Key('open reviews'),
              icon:
                  ReviewNotificationIcon(pending: reviewService.reviewPending),
              onPressed: () {
                if (!reviewService.reviewPending) return;
                performReview(reviewService, context);
              },
            )
          : null,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        child:
            Text("SafeStreets", style: TextStyle(color: _titleColor(context))),
        onLongPress: () => _showUrlConfig(context),
      ),
      actions: <Widget>[
        if (!currentRouteName(context).contains(PROFILE) && loggedIn)
          IconButton(
            key: Key('$PROFILE redirect'),
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, PROFILE),
          )
      ],
    );
  }

  Color _titleColor(BuildContext context) {
    final connected = Provider.of<ApiConnectionService>(context).connected;
    final defaultColor = Theme.of(context).appBarTheme.textTheme.title.color;
    final disabledColor = Theme.of(context).disabledColor;
    return connected ? defaultColor : disabledColor;
  }

  Future<void> performReview(
    ReviewService reviewService,
    BuildContext context,
  ) async {
    final request = reviewService.request;
    final res = await showDialog<ReviewResponse>(
      context: context,
      builder: (_) => PhotoReviewAlert(
        key: Key('review alert'),
        imageProvider: MemoryImage(request.imageData),
      ),
    );
    if (res == null) return;
    final submittingSnackbar =
        showSimpleSnackbar(Key('submitting review'), context, "Submitting review...");
    final review = res.clear
        ? ReportReview.clear(request.id, res.licensePlate)
        : ReportReview.notClear(request.id);
    try {
      await reviewService.submitReview(review);
      submittingSnackbar.close();
      showSimpleSnackbar(Key('successful review'), context, "Review submitted!");
    } catch (e) {
      print(e);
      submittingSnackbar.close();
      showErrorSnackbar(Key('submit review error'), context, "There was a problem submitting the review");
    }
  }

  String currentRouteName(BuildContext context) =>
      ModalRoute.of(context).settings.name;

  Size get preferredSize => Size.fromHeight(40.0);

  _showUrlConfig(BuildContext context) {
    showDialog(
      context: context,
      child: ApiConnectionConfigAlert(),
    );
  }
}
