import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:super_tooltip/super_tooltip.dart';

class ReportsMap extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final MapController controller;

  ReportsMap({this.center, this.zoom, this.controller});

  @override
  _ReportsMapState createState() => _ReportsMapState();
}

class _ReportsMapState extends State<ReportsMap> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        center: widget.center,
        zoom: widget.zoom,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
          markers: [
            _marker(widget.center),
          ],
        ),
      ],
    );
  }

  Marker _marker(LatLng position) {
    return Marker(
      width: 30,
      height: 27,
      point: position,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (ctx) {
        return position == null
            ? Container()
            : Container(
                child: ReportMarker(),
              );
      },
    );
  }
}

class ReportMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final popupTextStyle = TextStyle(fontSize: 14);
    return IconButton(
      padding: EdgeInsets.all(0),
      iconSize: 30,
      color: Theme.of(context).accentColor,
      icon: Icon(Icons.location_on),
      onPressed: () {
        final tooltip = SuperTooltip(
          hasShadow: false,
          popupDirection: TooltipDirection.up,
          content: Container(
            height: 100,
            child: Material(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Violation Type", style: popupTextStyle),
                  Text("Date", style: popupTextStyle),
                  Text("Ticket Issued", style: popupTextStyle),
                ],
              ),
            ),
          ),
        );
        tooltip.show(context);
      },
    );
  }
}
