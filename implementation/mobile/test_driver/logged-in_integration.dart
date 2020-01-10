import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:mobile/main.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/report_map_service.dart';
import 'package:mobile/services/report_submission_service.dart';
import 'package:mobile/services/review_service.dart';
import 'package:provider/provider.dart';

import 'mock_providers.dart';

/// Setup for review and report tests. Providing a already logged in state.
void main() {
  enableFlutterDriverExtension();

  runApp(
    MultiProvider(
      child: MyApp(),
      providers: mockRemaining(
        reportMapService: ChangeNotifierProxyProvider2<AuthService,
            ApiConnectionService, ReportMapService>(
          create: (_) => HttpReportMapService(),
          update: (_, authService, conService, reportService) {
            final httpService = reportService as HttpReportMapService;
            httpService.baseUrl = conService.url;
            httpService.token = authService.token;
            return httpService;
          },
        ),
        reportSubmissionService: ProxyProvider2<AuthService,
            ApiConnectionService, ReportSubmissionService>(
          create: (_) => HttpReportSubmissionService(null, null),
          update: (_, authService, conService, reportService) =>
              HttpReportSubmissionService(
            conService.url,
            authService.token,
          ),
        ),
        reviewService: ChangeNotifierProxyProvider2<AuthService,
            ApiConnectionService, ReviewService>(
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
