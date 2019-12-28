import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/routes.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:mobile/screens/reports_map_screen.dart';
import 'package:mobile/screens/sign_in_screen.dart';
import 'package:mobile/screens/sign_up_screen.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: safeStreetsTheme,
        initialRoute: '/sign-in',
        routes: {
          HOME: (ctx) => HomeScreen(),
          MAP: (ctx) => ReportsMapScreen(),
          REPORT: (ctx) => ReportViolationScreen(),
          PROFILE: (ctx) => ProfileScreen(),
          SIGN_IN: (ctx) => SignInScreen(),
          SIGN_UP: (ctx) => SignUpScreen(),
        },
      ),
      providers: [
        Provider<CameraService>.value(value: PhoneCameraService()),
      ],
    );
  }
}
