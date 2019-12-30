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
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/theme.dart';
import 'package:provider/provider.dart';

import 'data/mocks.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: safeStreetsTheme,
        initialRoute: LOADING,
        routes: {
          LOADING: (_) => LoadingScreen(),
          HOME: (_) => HomeScreen(),
          MAP: (_) => ReportsMapScreen(),
          REPORT: (_) => ReportViolationScreen(),
          PROFILE: (_) => ProfileScreen(),
          EDIT_PROFILE: (_) => EditProfileScreen(),
          SIGN_IN: (_) => SignInScreen(),
          SIGN_UP: (_) => SignUpScreen(),
        },
      ),
      providers: [
        Provider<CameraService>(create: (_) => PhoneCameraService()),
        ChangeNotifierProvider<AuthService>(
          create: (_) => MockAuthService(mockRegisteredUsers),
        ),
        ChangeNotifierProxyProvider<AuthService, UserService>(
          create: (_) => MockUserService(mockProfileByToken, null),
          update: (_, authService, __) => MockUserService(
            mockProfileByToken,
            authService.token,
          ),
        ),
      ],
    );
  }
}
