import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as ss;
import 'package:mobile/services/http_client.dart';

/// Provides the application with the base url to connect to the server,
/// as well as the current connection status.
abstract class ApiConnectionService with ChangeNotifier {
  String get url;

  bool get connected;

  Future<void> connect(String newUrl);
}

class MockApiConnectionService
    with ChangeNotifier
    implements ApiConnectionService {
  String __url;
  bool __connected = false;

  MockApiConnectionService(this.__url) : __connected = true;

  bool get _connected => __connected;

  set _connected(bool value) {
    __connected = value;
    notifyListeners();
  }

  String get _url => __url;

  set _url(String value) {
    __url = value;
    notifyListeners();
  }

  @override
  Future<void> connect(String newUrl) async {
    _url = newUrl;
    await Future.delayed(Duration(seconds: 2));
    _connected = !__connected;
  }

  @override
  String get url => _url;

  @override
  bool get connected => _connected;
}

class HttpApiConnectionService
    with ChangeNotifier
    implements ApiConnectionService {
  final _dio = getNewDioClient();
  final storage = ss.FlutterSecureStorage();
  String __url;
  bool __connected = false;

  HttpApiConnectionService(String url) {
    connect(url);
  }

  @override
  Future<void> connect(String newUrl) async {
    _url = newUrl;
    try {
      await _dio.get("$newUrl/auth/ping");
      await storage.write(key: 'baseUrl', value: newUrl);
      _connected = true;
    } catch (e) {
      print(e);
      _connected = false;
    }
  }

  @override
  bool get connected => _connected;

  @override
  String get url => _url;

  String get _url => __url;

  set _url(String value) {
    __url = value;
    notifyListeners();
  }

  bool get _connected => __connected;

  set _connected(bool value) {
    __connected = value;
    notifyListeners();
  }
}
