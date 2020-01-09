import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:mobile/data/filter_info.dart';
import 'package:mobile/data/report.dart';
import 'package:mobile/data/violation_type.dart';

abstract class ReportMapService with ChangeNotifier {
  bool get fetching;

  bool get ready;

  List<ReportIndicator> get reports;

  Future<void> initialize(FilterInfo filter, LatLngBounds bounds);

  Future<void> filter(FilterInfo filter);

  Future<void> setBounds(LatLngBounds bounds);
}

class MockReportMapService with ChangeNotifier implements ReportMapService {
  bool __ready = false;
  bool __fetching = false;
  List<ReportIndicator> __reports = [];
  LatLngBounds __bounds;
  FilterInfo __filterInfo;
  final _random = Random();

  bool get _ready => __ready;

  set _ready(bool value) {
    __ready = value;
    notifyListeners();
  }

  List<ReportIndicator> get _reports => __reports;

  set _reports(List<ReportIndicator> value) {
    __reports = value;
    notifyListeners();
  }

  bool get _fetching => __fetching;

  set _fetching(bool value) {
    __fetching = value;
    notifyListeners();
  }

  bool get fetching => _fetching;

  @override
  List<ReportIndicator> get reports => _reports;

  @override
  Future<void> initialize(FilterInfo filter, LatLngBounds bounds) async {
    assert(filter.to != null);
    assert(filter.from != null);
    assert(bounds != null);
    __filterInfo = filter;
    __bounds = bounds;
    _fetching = true;
    await Future.delayed(Duration(seconds: 2));
    _generateIndicators();
    _fetching = false;
    _ready = true;
  }

  @override
  Future<void> filter(FilterInfo filter) async {
    assert(filter.to != null);
    assert(filter.from != null);
    __filterInfo = filter;
    _fetching = true;
    await Future.delayed(Duration(seconds: 2));
    _generateIndicators();
    _fetching = false;
  }

  @override
  Future<void> setBounds(LatLngBounds bounds) async {
    assert(__filterInfo.to != null);
    assert(__filterInfo.from != null);
    __bounds = bounds;
    _fetching = true;
    await Future.delayed(Duration(seconds: 2));
    _generateIndicators();
    _fetching = false;
  }

  void _generateIndicators() {
    _reports = [
      _randomIndicator(),
      _randomIndicator(),
      _randomIndicator(),
      _randomIndicator(),
      _randomIndicator(),
    ];
  }

  ReportIndicator _randomIndicator() {
    return ReportIndicator(
      violationType: _randomViolationTypeInFilter(),
      time: _randomTimeInTimeFilter(),
      location: _randomPositionInBounds(),
    );
  }

  ViolationType _randomViolationTypeInFilter() {
    if (__filterInfo.violationType != null) return __filterInfo.violationType;
    final randomIndex = _random.nextInt(ViolationType.values.length);
    return ViolationType.values[randomIndex];
  }

  DateTime _randomTimeInTimeFilter() {
    final difference = __filterInfo.to.difference(__filterInfo.from);
    final deltaDuration =
        Duration(seconds: nextIntFromZero(difference.inSeconds));
    return __filterInfo.from.add(deltaDuration);
  }

  LatLng _randomPositionInBounds() {
    final latDelta = __bounds.north - __bounds.south;
    final lonDelta = __bounds.east - __bounds.west;

    final latAdd = _random.nextDouble() * latDelta;
    final lonAdd = _random.nextDouble() * lonDelta;

    return LatLng(__bounds.south + latAdd, __bounds.west + lonAdd);
  }

  int nextIntFromZero(int max) {
    return max == 0 ? 0 : _random.nextInt(max);
  }

  @override
  bool get ready => _ready;
}

class HttpReportMapService with ChangeNotifier implements ReportMapService {
  final _dio = Dio();
  bool __ready = false;
  bool __fetching = false;
  List<ReportIndicator> __reports = [];
  LatLngBounds _bounds;
  FilterInfo _filterInfo;

  @override
  bool get fetching => _fetching;

  @override
  bool get ready => _ready;

  @override
  List<ReportIndicator> get reports => _reports;

  @override
  Future<void> initialize(FilterInfo filter, LatLngBounds bounds) async {
    _bounds = bounds;
    _filterInfo = filter;
    await fetchReports();
    _ready = true;
  }

  @override
  Future<void> filter(FilterInfo filter) async {
    final filterCurrentReports = filterIsMoreRestrictiveThanCurrent(filter);
    _filterInfo = filter;
    if (filterCurrentReports)
      _reports = _reports.where((r) => _filterInfo.test(r)).toList();
    else
      fetchReports();
  }

  bool filterIsMoreRestrictiveThanCurrent(FilterInfo filter) {
    if (_filterInfo.violationType != null && filter.violationType == null)
      return false;
    if (_filterInfo.from.isAfter(filter.from)) return false;
    if (_filterInfo.to.isBefore(filter.to)) return false;
    return true;
  }

  @override
  Future<void> setBounds(LatLngBounds bounds) async {
    final filterCurrentReports = _bounds.containsBounds(bounds);
    _bounds = bounds;
    if (filterCurrentReports) {
      _reports = _reports.where((r) => _bounds.contains(r.location)).toList();
    } else
      await fetchReports();
  }

  Future<void> fetchReports() async {
    _fetching = true;
    final res =
        await _dio.post<List<dynamic>>('/violation/query/bounds', data: {
      'bottomLeft': [_bounds.southWest.latitude, _bounds.southWest.longitude],
      'upperRight': [_bounds.northEast.latitude, _bounds.northEast.longitude],
      'from': _filterInfo.from.toIso8601String(),
      'to': _filterInfo.to.toIso8601String(),
      'types': [_filterInfo.violationType],
    });
    final reports = res.data
        .map((dto) => ReportIndicator(
              violationType: dto['type'],
              time: dto['dateTime'],
              location: LatLng(dto['location'][0], dto['location'][1]),
            ))
        .toList();
    _fetching = false;
    _reports = reports;
  }

  bool get _fetching => __fetching;

  set _fetching(bool value) {
    __fetching = value;
    notifyListeners();
  }

  List<ReportIndicator> get _reports => __reports;

  set _reports(List<ReportIndicator> value) {
    __reports = value;
    notifyListeners();
  }

  bool get _ready => __ready;

  set _ready(bool value) {
    __ready = value;
    notifyListeners();
  }

  set baseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  set token(String token) {
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
    };
  }
}
