import 'dart:math';

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
      position: _randomPositionInBounds(),
    );
  }

  ViolationType _randomViolationTypeInFilter() {
    if (__filterInfo.violationType != null) return __filterInfo.violationType;
    final randomIndex = _random.nextInt(ViolationType.values.length);
    return ViolationType.values[randomIndex];
  }

  DateTime _randomTimeInTimeFilter() {
    final difference = __filterInfo.to.difference(__filterInfo.from);
    final deltaDuration = Duration(seconds: nextIntFromZero(difference.inSeconds));
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
    return max == 0? 0 : _random.nextInt(max);
  }

  @override
  bool get ready => _ready;
}
