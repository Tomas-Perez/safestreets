import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:mobile/main.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/services/api_key_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:provider/provider.dart';

import 'mock_providers.dart';

/// Setup for authentication flow and user service tests.
void main() {
  enableFlutterDriverExtension();

  runApp(
    MultiProvider(
      child: MyApp(),
      providers: mockRemaining(
        authService:
            ChangeNotifierProxyProvider<ApiConnectionService, AuthService>(
          create: (_) => HttpAuthService(),
          update: (_, conService, authService) {
            final httpService = authService as HttpAuthService;
            httpService.baseUrl = conService.url;
            return httpService;
          },
        ),
        userService: ChangeNotifierProxyProvider2<AuthService,
            ApiConnectionService, UserService>(
          create: (_) => HttpUserService(),
          update: (_, authService, conService, userService) {
            final httpService = userService as HttpUserService;
            httpService.baseUrl = conService.url;
            httpService.token = authService.token;
            final httpAuthService = authService as HttpAuthService;
            httpService.onNewTokenListener =
                (token) => httpAuthService.token = token;
            return httpService;
          },
        ),
        apiKeyService: ChangeNotifierProxyProvider2<AuthService,
            ApiConnectionService, ApiKeyService>(
          create: (_) => HttpApiKeyService(),
          update: (_, authService, conService, keyService) {
            final httpService = keyService as HttpApiKeyService;
            httpService.baseUrl = conService.url;
            httpService.token = authService.token;
            return httpService;
          },
        ),
      ),
    ),
  );
}
