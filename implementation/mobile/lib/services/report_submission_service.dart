import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mobile/data/report.dart';
import 'package:mobile/data/violation_type.dart';
import 'package:mobile/services/http_client.dart';

abstract class ReportSubmissionService {
  Future<void> submit(ReportForm form);
}

class MockReportSubmissionService implements ReportSubmissionService {
  @override
  Future<void> submit(ReportForm form) async {
    print(form);
  }
}

class HttpReportSubmissionService implements ReportSubmissionService {
  final Dio _dio;

  HttpReportSubmissionService(String baseUrl, String token)
      : _dio = getNewDioClient(
          BaseOptions(baseUrl: baseUrl, headers: {
            'Authorization': 'Bearer $token',
          }),
        );

  @override
  Future<void> submit(ReportForm form) async {
    try {
      final licensePlateImage = form.images[form.licensePlateImgIndex];
      final nonLicensePlateImgs =
          form.images.where((i) => i != licensePlateImage);
      final time = licensePlateImage.time.toIso8601String();
      final location = [
        licensePlateImage.location.longitude,
        licensePlateImage.location.latitude
      ];
      final res = await _dio.post('/violation', data: {
        'licensePlate': form.licensePlate,
        'description': form.description,
        'dateTime': time,
        'type': violationTypeToDTString(form.violationType),
        'location': location,
      });
      final reportId = res.data as String;
      await Future.wait([
        ...nonLicensePlateImgs.map((i) => uploadImage(reportId, i.imageData)),
        uploadImage(reportId, licensePlateImage.imageData,
            isLicensePlateImg: true),
      ]);
      await _dio.post('/violation/$reportId/done');
    } on DioError catch (e) {
      print(e);
    }
  }

  Future<void> uploadImage(
    String id,
    Uint8List imageData, {
    bool isLicensePlateImg,
  }) async {
    final file = MultipartFile.fromBytes(imageData.toList(), filename: "image");
    await _dio.post(
      '/violation/$id' +
          ((isLicensePlateImg ?? false) ? '/license-image' : '/image'),
      data: FormData.fromMap({
        "file": file,
      }),
    );
  }
}
