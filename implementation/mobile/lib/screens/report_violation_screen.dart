import 'package:flutter/material.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/image_carousel.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';

class ReportViolationScreen extends StatefulWidget {
  @override
  _ReportViolationScreenState createState() => _ReportViolationScreenState();
}

class _ReportViolationScreenState extends State<ReportViolationScreen> {
  final List<int> _items = [0, 1, 2];
  int _selectedIndex = 0;
  int _itemsGenerated = 3;

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
          setState(() {
            _items.add(_itemsGenerated++);
          });
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
            child: Container(
              height: 180,
              child: _buildItem(_items[_selectedIndex]),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ImageCarousel(
              itemBuilder: (BuildContext context, int index) => _buildItem(_items[index]),
              itemCount: _items.length,
              onIndexChanged: (idx) {
                setState(() {
                  _selectedIndex = idx;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int item) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text("$item"),
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
