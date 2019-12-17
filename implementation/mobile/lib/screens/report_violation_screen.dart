import 'package:flutter/material.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/image_carousel.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';

class ReportViolationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeStreetsAppBar(),
      body: ListView(
        children: <Widget>[
          BackButtonSection(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: Column(
              children: <Widget>[
                _title(),
                ReportForm(),
                SizedBox(height: 30),
                _photosSection(),
                SizedBox(height: 10),
                _confirmButton(),
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
        "Report a violation",
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _takePhotoButton() {
    return Container(
      width: 100,
      height: 25,
      child: RaisedButton(
        padding: EdgeInsets.all(0),
        child: Text(
          'Take a photo',
        ),
        onPressed: () {
          print('take photo');
        },
      ),
    );
  }

  Widget _photosSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _takePhotoButton(),
          SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Placeholder(
              fallbackHeight: 180,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ImageCarousel(
              itemBuilder: (BuildContext context, int index) => Placeholder(),
              itemCount: 3,
              onIndexChanged: print,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmButton() {
    return Center(
      child: Container(
        width: 130,
        child: RaisedButton(
          child: Text(
            'Confirm',
          ),
          onPressed: () {
            print('Confirm');
          },
        ),
      ),
    );
  }
}

class ReportForm extends StatefulWidget {
  @override
  State createState() {
    return _ReportFormState();
  }
}

class _ReportFormState extends State<ReportForm> {
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
      items: ViolationType.values
          .map((t) => DropdownMenuItem(child: Text("$t"), value: t))
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
