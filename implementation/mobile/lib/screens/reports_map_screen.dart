import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:mobile/data/filter_info.dart';
import 'package:mobile/data/violation_type.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/report_map_service.dart';
import 'package:mobile/util/date_helpers.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/reports_map.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:provider/provider.dart';

class ReportsMapScreen extends StatefulWidget {
  const ReportsMapScreen({Key key}) : super(key: key);

  @override
  State createState() => _ReportsMapScreenState();
}

class _ReportsMapScreenState extends State<ReportsMapScreen> {
  var _center;
  final _mapController = MapController();
  final initialFilter = FilterInfo(
    startOfDay(DateTime.now().subtract(Duration(hours: 1))),
    endOfDay(DateTime.now().add(Duration(hours: 1))),
    null,
  );
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    _center =
        Provider.of<LocationService>(context, listen: false).currentLocation;
    final service = Provider.of<ReportMapService>(context, listen: false);
    _mapController.onReady.then((_) {
      service.initialize(initialFilter, _mapController.bounds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ReportMapService>(context);
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              BackButtonSection(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                child: Column(
                  children: <Widget>[
                    SafeStreetsScreenTitle("Reports map"),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: _FilterForm(initialValue: initialFilter),
                    ),
                    _locationSearch(),
                  ],
                ),
              ),
              SizedBox(height: 6.0),
            ]),
          ),
          SliverFillRemaining(
            child: Stack(
              children: <Widget>[
                ReportsMap(
                  mapController: _mapController,
                  initialCenter: _center,
                  currentPosition:
                      Provider.of<LocationService>(context).currentLocation,
                  initialZoom: 13.0,
                  indicators: service.reports,
                  onPositionChange: (mapPosition) {
                    if (service.ready) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        service.setBounds(mapPosition.bounds);
                      });
                    }
                  },
                ),
                if (service.fetching)
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(15),
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationSearch() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Search",
        icon: Icon(Icons.search),
      ),
      validator: (search) {
        final location = parseLatLng(search);
        if (location == null) return "Invalid coordinates";
        return null;
      },
      onFieldSubmitted: (search) {
        final location = parseLatLng(search);
        if (location != null) {
          final service = Provider.of<ReportMapService>(context);
          setState(() {
            _center = location;
            _mapController.onReady.then((_) {
              _mapController.move(location, 13.0);
            });
            service.setBounds(_mapController.bounds);
          });
        }
      },
    );
  }
}

LatLng parseLatLng(String str) {
  final parts = str.split(",").map((p) => num.tryParse(p.trim())).toList();
  if (parts.length != 2 || parts[0] == null || parts[1] == null) return null;
  final location = LatLng(parts[0], parts[1]);
  return location;
}

class _FilterForm extends StatefulWidget {
  final FilterInfo initialValue;

  _FilterForm({Key key, this.initialValue}) : super(key: key);

  @override
  State createState() => _FilterFormState();
}

class _FilterFormState extends State<_FilterForm> {
  final _formKey = GlobalKey<FormState>();
  final _filterInfo = FilterInfo.empty();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _filterInfo.from = widget.initialValue.from;
      _filterInfo.to = widget.initialValue.to;
      _filterInfo.violationType = widget.initialValue.violationType;

      if (_filterInfo.from != null)
        _fromController.text = formatDate(_filterInfo.from);
      if (_filterInfo.to != null)
        _toController.text = formatDate(_filterInfo.to);
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Expanded(child: _fromDateField()),
                const SizedBox(width: 20),
                Expanded(child: _toDateField()),
              ],
            ),
          ),
          _violationTypeField(),
          const SizedBox(height: 15),
          _filterButton(),
        ],
      ),
    );
  }

  Widget _violationTypeField() {
    return DropdownButtonFormField(
      value: _filterInfo.violationType,
      decoration: InputDecoration(
        labelText: 'Violation type',
      ),
      items: [
        DropdownMenuItem(child: Text(""), value: null),
        ...ViolationType.values
            .map((t) => DropdownMenuItem(
                child: Text("${violationTypeToString(t)}"), value: t))
            .toList(),
      ],
      onChanged: (violationType) {
        print("Changed violation type to $violationType");
        setState(() {
          _filterInfo.violationType = violationType;
        });
      },
    );
  }

  Widget _fromDateField() {
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: _tapFromDateField,
          child: IgnorePointer(
            child: TextFormField(
              controller: _fromController,
              decoration: InputDecoration(
                labelText: 'From',
              ),
            ),
          ),
        ),
        if (_filterInfo.from != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 18.0,
              color: Colors.grey,
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _filterInfo.from = null;
                  _fromController.clear();
                });
              },
            ),
          ),
      ],
    );
  }

  _tapFromDateField() async {
    final lastDate = _filterInfo.to ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _filterInfo.from ?? lastDate,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: lastDate,
    );
    if (date != null) {
      setState(() {
        _filterInfo.from = startOfDay(date);
        _fromController.text = formatDate(date);
      });
    }
  }

  Widget _toDateField() {
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: _tapToDateField,
          child: IgnorePointer(
            child: TextFormField(
              controller: _toController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'To',
              ),
            ),
          ),
        ),
        if (_filterInfo.to != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 18.0,
              color: Colors.grey,
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _filterInfo.to = null;
                  _toController.clear();
                });
              },
            ),
          ),
      ],
    );
  }

  _tapToDateField() async {
    final firstDate =
        _filterInfo.from ?? DateTime.fromMillisecondsSinceEpoch(0);
    final date = await showDatePicker(
      context: context,
      initialDate: _filterInfo.to ?? firstDate,
      firstDate: firstDate,
      lastDate: endOfDay(DateTime.now()),
    );
    if (date != null) {
      setState(() {
        _filterInfo.to = endOfDay(date);
        _toController.text = formatDate(date);
      });
    }
  }

  Widget _filterButton() {
    return PrimaryButton(
      width: 140,
      child: Text(
        'Filter',
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      onPressed: () {
        final service = Provider.of<ReportMapService>(context);
        service.filter(_filterInfo);
      },
    );
  }
}
