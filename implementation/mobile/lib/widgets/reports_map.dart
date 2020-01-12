import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:mobile/data/confidence_level.dart';
import 'package:mobile/data/report.dart';
import 'package:mobile/data/violation_type.dart';
import 'package:mobile/util/date_helpers.dart';
import 'package:super_tooltip/super_tooltip.dart';

/// Wrapper on flutter_map to show styled reports indicators on a map with a popup on tap.
class ReportsMap extends StatefulWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final List<ReportIndicator> indicators;
  final LatLng currentLocation;
  final void Function(MapPosition) onPositionChange;

  ReportsMap({
    Key key,
    @required this.mapController,
    @required this.initialCenter,
    @required this.initialZoom,
    @required this.indicators,
    @required this.currentLocation,
    @required this.onPositionChange,
  }) : super(key: key);

  @override
  State createState() => _ReportsMapState();
}

class _ReportsMapState extends State<ReportsMap> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
          center: widget.initialCenter,
          zoom: widget.initialZoom,
          onPositionChanged: (mapPosition, _) {
            if (widget.onPositionChange != null)
              widget.onPositionChange(mapPosition);
          }),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(markers: [
          _currentLocationMarker(),
        ]),
        MarkerLayerOptions(
            markers: widget.indicators.map(_reportMarker).toList()),
      ],
    );
  }

  Marker _currentLocationMarker() {
    final size = 22.0;
    final mainColor = Theme.of(context).primaryColor;
    final borderColor = mainColor.withOpacity(0.5);
    return Marker(
      width: size,
      height: size,
      point: widget.currentLocation,
      builder: (_) => Container(
        key: Key('report indicator'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: borderColor,
        ),
        child: Center(
          child: Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor,
            ),
          ),
        ),
      ),
    );
  }

  Marker _reportMarker(ReportIndicator reportMarkerInfo) {
    return Marker(
      width: 30,
      height: 27,
      point: reportMarkerInfo.location,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (ctx) => Container(
        child: _ReportMarker(
          id: reportMarkerInfo.id,
          location: reportMarkerInfo.location,
          confidenceLevel: reportMarkerInfo.confidenceLevel,
          dateTime: reportMarkerInfo.time,
          violationType: reportMarkerInfo.violationType,
        ),
      ),
    );
  }
}

class _ReportMarker extends StatelessWidget {
  final String id;
  final LatLng location;
  final ConfidenceLevel confidenceLevel;
  final DateTime dateTime;
  final ViolationType violationType;

  _ReportMarker({
    Key key,
    @required this.id,
    @required this.location,
    @required this.confidenceLevel,
    @required this.dateTime,
    @required this.violationType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: 30,
      color: Theme.of(context).primaryColor,
      icon: Icon(Icons.location_on),
      onPressed: () => _showTooltip(context),
    );
  }

  void _showTooltip(BuildContext context) {
    final popupTextStyle = const TextStyle(fontSize: 14);
    return SuperTooltip(
      hasShadow: false,
      popupDirection: TooltipDirection.up,
      content: Material(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "ID: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "$id"),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "Lat: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${location.latitude}"),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "Lon: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${location.longitude}"),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "Type: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${violationTypeToString(violationType)}"),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "Date: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${formatDate(dateTime)}"),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "Time: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "${formatTime(dateTime)}"),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: popupTextStyle,
                  children: [
                    TextSpan(
                      text: "Confidence level: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: confidenceLevel == ConfidenceLevel.HIGH_CONFIDENCE ? 'HIGH' : 'LOW'),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    ).show(context);
  }
}
