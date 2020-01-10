import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:mobile/main.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/review_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:provider/provider.dart';

import 'mock_providers.dart';

void main() {
  enableFlutterDriverExtension();

  runApp(
    MultiProvider(
      child: MyApp(),
      providers: mockRemaining(
        reviewService: ChangeNotifierProxyProvider2<AuthService, ApiConnectionService,
            ReviewService>(
          create: (_) => HttpReviewService(),
          update: (_, authService, conService, reviewService) {
            final httpService = reviewService as HttpReviewService;
            httpService.baseUrl = conService.url;
            httpService.token = authService.token;
            return httpService;
          },
        ),
      ),
    ),
  );
}
