import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/image_carousel.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:provider/provider.dart';

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
                _ReportForm(),
                SizedBox(height: 30),
                _photosSection(context),
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
        padding: const EdgeInsets.all(0),
        child: Text('Take a photo'),
        onPressed: () async {
          final service = Provider.of<CameraService>(context);
          final imagePath = await service.openViewfinder(context);
          print(imagePath);
        },
      ),
    );
  }

  Widget _photosSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _takePhotoButton(),
          SizedBox(height: 10),
          _buildCurrentImageView(),
          _buildCarousel(context),
        ],
      ),
    );
  }

  Widget _buildCurrentImageView() {
    final height = 180.0;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _items.isEmpty
          ? Container(height: height, child: _noItemsPlaceholder())
          : _MainImageOverlay(
              child: Container(
                height: height,
                child: _buildItem(_items[_selectedIndex]),
              ),
              onEliminate: () {
                setState(() {
                  if (_items.isEmpty) return;
                  _items.removeAt(_selectedIndex);
                  if (_selectedIndex >= _items.length) {
                    _selectedIndex = _items.length - 1;
                  }
                });
              },
            ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IgnorePointer(
        ignoring: _items.isEmpty,
        child: Opacity(
          opacity: _items.isEmpty ? 0 : 1,
          child: ImageCarousel(
            itemBuilder: (_, idx) => _buildItem(_items[idx]),
            itemCount: _items.length,
            onIndexChanged: (idx) {
              setState(() => _selectedIndex = idx);
            },
          ),
        ),
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

  Widget _noItemsPlaceholder() {
    return Center(
      child: Text(
        "Please upload a picture of the scene",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

class _MainImageOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback onEliminate;

  _MainImageOverlay({this.child, this.onEliminate});

  @override
  Widget build(BuildContext context) {
    final iconSize = 24.0;
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: iconSize / 2,
          right: iconSize / 2,
          child: SizedBox(
            height: iconSize,
            width: iconSize,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                iconSize: iconSize,
                padding: const EdgeInsets.all(0),
                icon: Icon(Icons.close),
                onPressed: onEliminate,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _ReportForm extends StatefulWidget {
  @override
  State createState() {
    return _ReportFormState();
  }
}

class _ReportFormState extends State<_ReportForm> {
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
