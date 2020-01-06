import 'package:flutter/material.dart';
import 'package:mobile/data/report_review.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/review_service.dart';
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
              icon:
                  ReviewNotificationIcon(pending: reviewService.reviewPending),
              onPressed: () {
                if (!reviewService.reviewPending) return;
                performReview(reviewService, context);
              },
            )
          : null,
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

  Future<void> performReview(
    ReviewService reviewService,
    BuildContext context,
  ) async {
    final request = reviewService.request;
    final res = await showDialog<ReviewResponse>(
      context: context,
      builder: (_) => PhotoReviewAlert(
        imageProvider: MemoryImage(request.imageData),
      ),
    );
    if (res == null) return;
    const SNACKBAR_DURATION = Duration(seconds: 1);
    final submittingSnackbar = Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Submitting review..."),
      duration: SNACKBAR_DURATION,
    ));
    final review = res.clear
        ? ReportReview.clear(request.id, res.licensePlate)
        : ReportReview.notClear(request.id);
    try {
      await reviewService.submitReview(review);
      submittingSnackbar.close();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Review submitted!"),
        duration: SNACKBAR_DURATION,
      ));
    } catch (_) {
      submittingSnackbar.close();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("There was a problem submitting the review"),
          backgroundColor: Colors.red,
          duration: SNACKBAR_DURATION,
        ),
      );
    }
  }

  String currentRouteName(BuildContext context) =>
      ModalRoute.of(context).settings.name;

  Size get preferredSize => Size.fromHeight(40.0);
}
