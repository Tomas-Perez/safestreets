import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

abstract class LocationService with ChangeNotifier {
  LatLng get currentLocation;

  bool get permissionGranted;
}

class MockLocationService with ChangeNotifier implements LocationService {
  static const FPS = 30;
  static const MILLISECONDS_IN_SECOND = 1000;
  static const TIMER_DURATION = MILLISECONDS_IN_SECOND ~/ FPS;
  LatLng _location;

  MockLocationService(this._location, {bool animate}) {
    if (animate != null && animate) {
      Timer.periodic(Duration(milliseconds: TIMER_DURATION), (t) {
        _location = LatLng(
          _location.latitude,
          _location.longitude + 0.000001 * TIMER_DURATION,
        );
        notifyListeners();
      });
    }
  }

  @override
  LatLng get currentLocation => _location;

  @override
  bool get permissionGranted => true;
}

class GeolocatorLocationService with ChangeNotifier implements LocationService {
  final int distanceFilter;
  var __currentLocation;
  var __permissionGranted;
  StreamSubscription _subscription;

  GeolocatorLocationService(this.distanceFilter);

  set _currentLocation(LatLng location) {
    __currentLocation = location;
    notifyListeners();
  }

  get _currentLocation => __currentLocation;

  set _permissionGranted(bool granted) {
    __permissionGranted = granted;
    notifyListeners();
  }

  get _permissionGranted => __permissionGranted;

  @override
  LatLng get currentLocation => _currentLocation;

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  bool get permissionGranted => _permissionGranted;

  void start() {
    final geolocator = Geolocator();
    final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );

    _subscription = geolocator.getPositionStream(locationOptions).listen(
      (Position position) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _permissionGranted = true;
      },
      onError: (err) {
        if (err is PlatformException && err.code == 'PERMISSION_DENIED') {
          _permissionGranted = false;
        }
      },
      cancelOnError: false,
    );
  }

  void stop() {
    if (_subscription != null) _subscription.cancel();
  }
}
