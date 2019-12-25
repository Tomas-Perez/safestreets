import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:mobile/screens/report_violation_screen.dart';
import 'package:mobile/util/date_helpers.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/reports_map.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';

class ReportsMapScreen extends StatefulWidget {
  const ReportsMapScreen({Key key}) : super(key: key);

  @override
  State createState() => _ReportsMapScreenState();
}

class _ReportsMapScreenState extends State<ReportsMapScreen> {
  var _center = LatLng(45.505621, 9.246872);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              BackButtonSection(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                child: Column(
                  children: <Widget>[
                    _title(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: _FilterForm(),
                    ),
                    _locationSearch(),
                  ],
                ),
              ),
              SizedBox(height: 6.0),
            ]),
          ),
          SliverFillRemaining(
            child: ReportsMap(
              center: _center,
              zoom: 13.0,
              markers: [
                ReportMarkerInfo(
                  location: LatLng(45.505621, 9.246872),
                  violationType: ViolationType.BAD_CONDITION,
                  dateTime: DateTime.now(),
                ),
                ReportMarkerInfo(
                  location: LatLng(45.5, 9.25),
                  violationType: ViolationType.BAD_CONDITION,
                  dateTime: DateTime.now().subtract(Duration(hours: 2)),
                ),
                ReportMarkerInfo(
                  location: LatLng(45.509, 9.242),
                  violationType: ViolationType.BAD_CONDITION,
                  dateTime: DateTime.now().subtract(Duration(minutes: 32)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Center(
      child: Text(
        "Reports map",
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _locationSearch() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Search",
        icon: Icon(Icons.search),
      ),
      onFieldSubmitted: (search) {
        final location = parseLatLng(search);
        if (location != null) {
          setState(() {
            _center = location;
          });
        } else
          print('Invalid location');
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
  @override
  State createState() {
    return _FilterFormState();
  }
}

class _FilterFormState extends State<_FilterForm> {
  final _formKey = GlobalKey<FormState>();
  final _filterInfo = _FilterInfo.empty();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

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
            .map((t) => DropdownMenuItem(child: Text("${violationTypeToString(t)}"), value: t))
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
    return Container(
      width: 140,
      child: RaisedButton(
        child: Text(
          'Filter',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => ReportViolationScreen()),
          );
        },
      ),
    );
  }
}

class _FilterInfo {
  DateTime to, from;
  ViolationType violationType;

  _FilterInfo(this.to, this.from, this.violationType);

  _FilterInfo.empty();
}
