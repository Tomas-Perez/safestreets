import 'package:flutter/foundation.dart';

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
    await Future.delayed(Duration(seconds: 2));
    _url = newUrl;
    _connected = !__connected;
  }

  @override
  String get url => _url;

  @override
  bool get connected => _connected;
}
