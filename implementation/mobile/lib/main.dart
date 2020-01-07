import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/data/report_review.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/screens/edit_profile_screen.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/loading_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:mobile/screens/reports_map_screen.dart';
import 'package:mobile/screens/sign_in_screen.dart';
import 'package:mobile/screens/sign_up_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/report_map_service.dart';
import 'package:mobile/services/report_submission_service.dart';
import 'package:mobile/services/review_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/util/image_helpers.dart';
import 'package:provider/provider.dart';

import 'data/mocks.dart';

void main() => runApp(
      MultiProvider(
        child: MyApp(),
        providers: [
          Provider<CameraService>(
            create: (_) => PhoneCameraService(),
          ),
          ChangeNotifierProvider<AuthService>(
            create: (_) => HttpAuthService(),
          ),
          ChangeNotifierProxyProvider<AuthService, LocationService>(
            create: (_) => GeolocatorLocationService(10),
            update: (_, authService, locationService) {
              final geolocatorService =
                  locationService as GeolocatorLocationService;
              if (authService.authenticated)
                return geolocatorService..start();
              else
                return geolocatorService..stop();
            },
          ),
          ChangeNotifierProxyProvider<AuthService, UserService>(
            create: (_) => MockUserService(mockProfileByToken, null),
            update: (_, authService, __) => MockUserService(
              mockProfileByToken,
              authService.token,
            ),
          ),
          ProxyProvider<AuthService, ReportSubmissionService>(
            create: (_) => MockReportSubmissionService(),
            update: (_, authService, reportService) => reportService,
          ),
          ChangeNotifierProxyProvider<AuthService, ReportMapService>(
            create: (_) => MockReportMapService(),
            update: (_, authService, reportService) => reportService,
          ),
          ChangeNotifierProxyProvider<AuthService, ReviewService>(
            create: (_) => MockReviewService(
                loadAssetImage('mocks/mock-image.jpg').then((img) => [
                      [ReviewRequest('1', img), ReviewRequest('2', img)],
                      [ReviewRequest('3', img)],
                    ])),
            update: (_, authService, reviewService) {
              if (authService.authenticated)
                return reviewService..fetchRequests();
              else
                return reviewService..clearRequests();
            },
          )
        ],
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: safeStreetsTheme,
      initialRoute: LOADING,
      routes: {
        LOADING: (_) => LoadingScreen(key: Key('$LOADING screen')),
        HOME: (_) => HomeScreen(key: Key('$HOME screen')),
        MAP: (_) => ReportsMapScreen(key: Key('$MAP screen')),
        REPORT: (_) => ReportViolationScreen(key: Key('$REPORT screen')),
        PROFILE: (_) => ProfileScreen(key: Key('$PROFILE screen')),
        EDIT_PROFILE: (_) => EditProfileScreen(key: Key('$EDIT_PROFILE screen')),
        SIGN_IN: (_) => SignInScreen(key: Key('$SIGN_IN screen')),
        SIGN_UP: (_) => SignUpScreen(key: Key('$SIGN_UP screen')),
      },
    );
  }
}
