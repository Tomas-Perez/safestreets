import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:super_tooltip/super_tooltip.dart';

class ReportsMap extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final List<ReportMarkerInfo> markers;

  ReportsMap({this.center, this.zoom, this.markers});

  @override
  _ReportsMapState createState() => _ReportsMapState();
}

class _ReportsMapState extends State<ReportsMap> {
  final MapController _controller = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        center: widget.center,
        zoom: widget.zoom,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(markers: widget.markers.map(_marker).toList()),
      ],
    );
  }

  Marker _marker(ReportMarkerInfo reportMarkerInfo) {
    return Marker(
      width: 30,
      height: 27,
      point: reportMarkerInfo.location,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (ctx) => Container(
        child: _ReportMarker(
          dateTime: reportMarkerInfo.dateTime,
          violationType: reportMarkerInfo.violationType,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(ReportsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _controller.onReady.then((_) {
        _controller.move(widget.center, widget.zoom);
      });
    });
  }
}

class _ReportMarker extends StatelessWidget {
  final DateTime dateTime;
  final ViolationType violationType;

  _ReportMarker({@required this.dateTime, @required this.violationType});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: 30,
      color: Theme.of(context).accentColor,
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
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("$violationType", style: popupTextStyle),
              SizedBox(height: 10),
              Text("$dateTime", style: popupTextStyle),
            ],
          ),
        ),
      ),
    ).show(context);
  }
}

class ReportMarkerInfo {
  LatLng location;
  DateTime dateTime;
  ViolationType violationType;

  ReportMarkerInfo({this.location, this.dateTime, this.violationType});
}
