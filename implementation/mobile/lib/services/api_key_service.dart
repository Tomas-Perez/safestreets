import 'package:flutter/foundation.dart';
import 'package:mobile/services/http_client.dart';

abstract class ApiKeyService with ChangeNotifier {
  String get key;

  bool get fetched;

  Future<void> fetch();
}

class MockApiKeyService with ChangeNotifier implements ApiKeyService {
  static final _mockKey = 'key';
  String __key;

  String get _key => __key;

  set _key(String value) {
    __key = value;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    await Future.delayed(Duration(seconds: 1));
    _key = _mockKey;
  }

  @override
  String get key => _key;

  @override
  bool get fetched => key != null;
}

class HttpApiKeyService with ChangeNotifier implements ApiKeyService {
  final _dio = getNewDioClient();
  String __key;

  String get _key => __key;

  set _key(String value) {
    __key = value;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    _key = (await _dio.get('/api-key/me')).data;
  }

  @override
  String get key => _key;

  set baseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  set token(String token) {
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
    };
    _key = null;
  }

  @override
  bool get fetched => _key != null;
}
