import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/screens/edit_profile_screen.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/loading_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:mobile/screens/reports_map_screen.dart';
import 'package:mobile/screens/sign_in_screen.dart';
import 'package:mobile/screens/sign_up_screen.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/report_map_service.dart';
import 'package:mobile/services/report_submission_service.dart';
import 'package:mobile/services/review_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        child: MyApp(),
        providers: [
          ChangeNotifierProvider<ApiConnectionService>(
            create: (_) =>
                HttpApiConnectionService('http://192.168.99.100:8080'),
          ),
          Provider<CameraService>(
            create: (_) => MockCameraService("mocks/DX034PS.jpeg"),
          ),
          ChangeNotifierProxyProvider<ApiConnectionService, AuthService>(
            create: (_) => HttpAuthService(),
            update: (_, conService, authService) {
              final httpService = authService as HttpAuthService;
              httpService.baseUrl = conService.url;
              return httpService;
            },
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
          ChangeNotifierProxyProvider2<AuthService, ApiConnectionService,
              UserService>(
            create: (_) => HttpUserService(),
            update: (_, authService, conService, userService) {
              final httpService = userService as HttpUserService;
              httpService.baseUrl = conService.url;
              httpService.token = authService.token;
              return httpService;
            },
          ),
          ProxyProvider2<AuthService, ApiConnectionService,
              ReportSubmissionService>(
            create: (_) => HttpReportSubmissionService(null, null),
            update: (_, authService, conService, reportService) =>
                HttpReportSubmissionService(
              conService.url,
              authService.token,
            ),
          ),
          ChangeNotifierProxyProvider2<AuthService, ApiConnectionService, ReportMapService>(
            create: (_) => HttpReportMapService(),
            update: (_, authService, conService, reportService) {
              final httpService = reportService as HttpReportMapService;
              httpService.baseUrl = conService.url;
              httpService.token = authService.token;
              return httpService;
            },
          ),
          ChangeNotifierProxyProvider2<AuthService, ApiConnectionService,
              ReviewService>(
            create: (_) => HttpReviewService(),
            update: (_, authService, conService, reviewService) {
              final httpService = reviewService as HttpReviewService;
              httpService.baseUrl = conService.url;
              httpService.token = authService.token;
              return httpService;
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
        EDIT_PROFILE: (_) =>
            EditProfileScreen(key: Key('$EDIT_PROFILE screen')),
        SIGN_IN: (_) => SignInScreen(key: Key('$SIGN_IN screen')),
        SIGN_UP: (_) => SignUpScreen(key: Key('$SIGN_UP screen')),
      },
    );
  }
}
