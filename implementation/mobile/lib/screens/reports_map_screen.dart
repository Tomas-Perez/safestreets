import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/date_helpers.dart';
import 'package:mobile/screens/report_violation_screen.dart';

class ReportsMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 30.0,
        ),
        child: ListView(
          children: <Widget>[
            _title(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: FilterForm(),
            ),
          ],
        ),
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
}

class FilterForm extends StatefulWidget {
  @override
  State createState() {
    return FilterFormState();
  }
}

class FilterFormState extends State<FilterForm> {
  final _formKey = GlobalKey<FormState>();
  final _filterInfo = FilterInfo.empty();
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
            .map((t) => DropdownMenuItem(child: Text("$t"), value: t))
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
        _fromController.text = "${date.day}/${date.month}/${date.year}";
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
        _toController.text = "${date.day}/${date.month}/${date.year}";
      });
    }
  }
}

class FilterInfo {
  DateTime to, from;
  ViolationType violationType;

  FilterInfo(this.to, this.from, this.violationType);

  FilterInfo.empty();
}
