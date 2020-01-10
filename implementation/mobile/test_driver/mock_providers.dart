import 'package:latlong/latlong.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/report_map_service.dart';
import 'package:mobile/services/report_submission_service.dart';
import 'package:mobile/services/review_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:provider/provider.dart';

List<SingleChildCloneableWidget> mockRemaining({
  SingleChildCloneableWidget authService,
  SingleChildCloneableWidget apiConnectionService,
  SingleChildCloneableWidget cameraService,
  SingleChildCloneableWidget locationService,
  SingleChildCloneableWidget reportMapService,
  SingleChildCloneableWidget reportSubmissionService,
  SingleChildCloneableWidget reviewService,
  SingleChildCloneableWidget userService,
}) {
  return [
    apiConnectionService ??
        ChangeNotifierProvider<ApiConnectionService>(
          create: (_) => MockApiConnectionService('http://192.168.99.100:8080'),
        ),
    authService ??
        ChangeNotifierProvider<AuthService>(
          create: (_) => DefaultTokenAuthService(),
        ),
    cameraService ??
        Provider<CameraService>(
          create: (_) => MockCameraService('mocks/DX034PS.jpeg'),
        ),
    locationService ??
        ChangeNotifierProvider<LocationService>(
          create: (_) => MockLocationService(LatLng(45.468464, 9.195674)),
        ),
    reportMapService ??
        ChangeNotifierProvider<ReportMapService>(
          create: (_) => MockReportMapService(),
        ),
    reportSubmissionService ??
        Provider<ReportSubmissionService>(
          create: (_) => MockReportSubmissionService(),
        ),
    reviewService ??
        ChangeNotifierProvider<ReviewService>(
          create: (_) => MockReviewService(Future.value([])),
        ),
    userService ??
        ChangeNotifierProvider<UserService>(
          create: (_) => MockUserService({}, null),
        ),
  ];
}