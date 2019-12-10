import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportViolationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 30.0,
        ),
        child: ListView(
          children: <Widget>[
            _title(),
            ReportForm(),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Center(
      child: Text(
        "Report a violation",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ReportForm extends StatefulWidget {

  @override
  State createState() {
    return ReportFormState();
  }
}

class ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _reportInfo = ReportInfo.empty();


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _violationTypeField(),
          _licensePlateField(),
          _descriptionField(),
        ],
      ),
    );
  }

  Widget _violationTypeField() {
    return DropdownButtonFormField(
      value: _reportInfo.violationType,
      decoration: InputDecoration(
        labelText: 'Violation type',
      ),
      items: ViolationType.values.map((t) => DropdownMenuItem(child: Text("$t"),value: t))
          .toList(),
      onChanged: (violationType) {
        print("Changed violation type to $violationType");
        setState(() {
          _reportInfo.violationType = violationType;
        });
      },
    );
  }

  Widget _licensePlateField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _licensePlateFocus,
      decoration: InputDecoration(
        labelText: 'License plate',
      ),
      onFieldSubmitted: (term) {
        _licensePlateFocus.unfocus();
        FocusScope.of(context).requestFocus(_descriptionFocus);
      },
      onSaved: (licensePlate) {
        _reportInfo.licensePlate = licensePlate;
      },
    );
  }

  Widget _descriptionField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      focusNode: _descriptionFocus,
      decoration: InputDecoration(
        labelText: 'Description',
      ),
      onFieldSubmitted: (term) {
        _descriptionFocus.unfocus();
      },
      onSaved: (description) {
        _reportInfo.description = description;
      },
    );
  }
}

enum ViolationType { PARKING, BAD_CONDITION }

class ReportInfo {
  ViolationType violationType;
  String licensePlate, description;

  ReportInfo({this.violationType, this.licensePlate, this.description});

  ReportInfo.empty();

  @override
  String toString() {
    return 'ReportInfo{violationType: $violationType, licensePlate: $licensePlate, description: $description}';
  }
}
