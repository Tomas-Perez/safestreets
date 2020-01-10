import 'package:dio/dio.dart';

class TimeoutException extends DioError {
  final message = 'Server took to long to respond';

  TimeoutException();
}

Dio getNewDioClient([BaseOptions options]) {
  final resultOptions = options?.merge(
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ) ??
      BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 3000,
      );
  final client = Dio(resultOptions);
  client.interceptors.add(
    InterceptorsWrapper(onError: (DioError e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT ||
          e.type == DioErrorType.RECEIVE_TIMEOUT)
        return TimeoutException();
      else
        return e;
    }),
  );
  return client;
}
