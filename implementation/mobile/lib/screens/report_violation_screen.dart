import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/util/license_plate.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/image_carousel.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class ReportViolationScreen extends StatefulWidget {
  const ReportViolationScreen({Key key}) : super(key: key);

  @override
  State createState() => _ReportViolationScreenState();
}

class _ReportViolationScreenState extends State<ReportViolationScreen> {
  final _controller = _ReportFormController();
  final _images = <String>[];
  var _selectedIndex = -1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                SafeStreetsScreenTitle("Report a violation"),
                _ReportForm(controller: _controller),
                const SizedBox(height: 30),
                _photosSection(context),
                const SizedBox(height: 10),
                _confirmButton(context),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
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
          if (imagePath != null) {
            setState(() {
              _images.add(imagePath);
              if (_images.length == 1) _selectedIndex = 0;
            });
          }
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
          _buildCurrentImageView(context),
          _buildCarousel(context),
        ],
      ),
    );
  }

  Widget _buildCurrentImageView(BuildContext context) {
    final height = 180.0;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _images.isEmpty
          ? Container(height: height, child: _noItemsPlaceholder())
          : _MainImageOverlay(
              child: Container(
                height: height,
                child: _ReportImage(
                  _images[_selectedIndex],
                  enableZoom: true,
                ),
              ),
              onEliminate: () {
                setState(() {
                  if (_images.isEmpty) return;
                  _images.removeAt(_selectedIndex);
                  if (_selectedIndex >= _images.length) {
                    _selectedIndex = _images.length - 1;
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
        ignoring: _images.isEmpty,
        child: Opacity(
          opacity: _images.isEmpty ? 0 : 1,
          child: ImageCarousel(
            itemBuilder: (_, idx) => _ReportImage(_images[idx]),
            itemCount: _images.length,
            onIndexChanged: (idx) {
              setState(() => _selectedIndex = idx);
            },
            viewportFraction: 0.33,
          ),
        ),
      ),
    );
  }

  Widget _confirmButton(BuildContext context) {
    return Center(
      child: Container(
        width: 130,
        child: RaisedButton(
          child: Text(
            'Confirm',
          ),
          onPressed: _images.isEmpty ? null : _submitForm,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final reportInfo = _controller.submit();
    if (reportInfo == null) return;
    final selectedIndex = await showDialog(
      context: context,
      builder: (ctx) => _LicensePlateAlert(images: _images),
    );
    if (selectedIndex != null)
      print("$selectedIndex");
    else
      print("cancelled");
  }

  Widget _noItemsPlaceholder() {
    return Center(
      child: Text(
        "Please upload a photo of the scene",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

class _MainImageOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback onEliminate;

  _MainImageOverlay({
    Key key,
    @required this.child,
    @required this.onEliminate,
  }) : super(key: key);

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
                icon: Icon(Icons.close),
                iconSize: iconSize,
                padding: const EdgeInsets.all(0),
                onPressed: () => _onEliminatePress(context),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onEliminatePress(BuildContext context) async {
    final delete = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete photo"),
        content: Text("Are you sure you want to delete this photo?"),
        actions: <Widget>[
          FlatButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(ctx, null),
          ),
          FlatButton(
            child: Text("Yes"),
            onPressed: () => Navigator.pop(ctx, true),
          )
        ],
      ),
    );
    if (delete == null) return;
    onEliminate();
  }
}

class _ReportImage extends StatelessWidget {
  final String path;
  final bool enableZoom;

  _ReportImage(this.path, {Key key, this.enableZoom = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enableZoom
          ? () => showDialog(
              context: context,
              builder: (ctx) {
                return Container(
                  child: PhotoView(
                    minScale: 1.0,
                    imageProvider: FileImage(File(path)),
                  ),
                );
              })
          : null,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Image.file(File(path)),
      ),
    );
  }
}

typedef _ReportFormSubmitCallback = _ReportFormInfo Function();

class _ReportFormController {
  _ReportFormSubmitCallback _onSubmit;

  void register(_ReportFormSubmitCallback onSubmit) {
    assert(_onSubmit == null,
        "Another callback is registered on this controller, deregister it first");
    _onSubmit = onSubmit;
  }

  void deregister() {
    _onSubmit = null;
  }

  _ReportFormInfo submit() {
    assert(_onSubmit != null, "No callback registered for this controller");
    return _onSubmit();
  }

  dispose() {
    _onSubmit = null;
  }
}

class _ReportForm extends StatefulWidget {
  final _ReportFormController controller;

  _ReportForm({Key key, this.controller}) : super(key: key);

  @override
  State createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _reportInfo = _ReportFormInfo.empty();
  var _autovalidate = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller.register(_submit);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
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
        labelText: 'Violation type *',
        helperText: ' ', // spacing for error message
      ),
      items: ViolationType.values
          .map(
            (t) => DropdownMenuItem(
              child: Text("${violationTypeToString(t)}"),
              value: t,
            ),
          )
          .toList(),
      validator: (value) {
        if (value == null) return "Violation type missing";
        return null;
      },
      onChanged: (violationType) {
        print("Changed violation type to $violationType");
        setState(() => _reportInfo.violationType = violationType);
      },
    );
  }

  Widget _licensePlateField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      focusNode: _licensePlateFocus,
      decoration: InputDecoration(
        labelText: 'License plate *',
        helperText: ' ', // spacing for error message
      ),
      validator: (value) {
        if (value.isEmpty) return "License plate missing";
        if (!isItalianLicensePlate(value))
          return "Please enter an italian license plate";
        return null;
      },
      onFieldSubmitted: (term) {
        _licensePlateFocus.unfocus();
        FocusScope.of(context).requestFocus(_descriptionFocus);
      },
      onSaved: (licensePlate) => _reportInfo.licensePlate = licensePlate,
    );
  }

  Widget _descriptionField() {
    return TextFormField(
      maxLengthEnforced: true,
      maxLength: 150,
      minLines: 2,
      maxLines: 4,
      textInputAction: TextInputAction.done,
      focusNode: _descriptionFocus,
      decoration: InputDecoration(
        labelText: 'Description',
      ),
      onFieldSubmitted: (term) => _descriptionFocus.unfocus(),
      onSaved: (description) => _reportInfo.description = description,
    );
  }

  _ReportFormInfo _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      _licensePlateFocus.unfocus();
      _descriptionFocus.unfocus();
      form.save();
      return _reportInfo;
    } else {
      setState(() {
        _autovalidate = true;
      });
      return null;
    }
  }
}

class _LicensePlateAlert extends StatefulWidget {
  final List<String> images;

  _LicensePlateAlert({
    Key key,
    @required this.images,
  })  : assert(images.isNotEmpty, "Alert needs at least one image to select"),
        super(key: key);

  @override
  State createState() => _LicensePlateAlertState();
}

class _LicensePlateAlertState extends State<_LicensePlateAlert> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("License plate photo"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              widget.images.length == 1
                  ? "Please ensure that the picture clearly shows the license plate, then press OK."
                  : "Please select a picture which clearly shows the license plate, then press OK.",
            ),
            SizedBox(height: 20),
            Container(
              width: 1,
              height: 100,
              child: ImageCarousel(
                itemBuilder: (_, idx) =>
                    _ReportImage(widget.images[idx], enableZoom: true),
                itemCount: widget.images.length,
                onIndexChanged: (idx) => _selectedIndex = idx,
                viewportFraction: 1,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context, null),
        ),
        FlatButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context, _selectedIndex),
        ),
      ],
    );
  }
}

enum ViolationType { PARKING, BAD_CONDITION }

String violationTypeToString(ViolationType type) {
  switch (type) {
    case ViolationType.PARKING:
      return "Parking";
    case ViolationType.BAD_CONDITION:
      return "Bad condition";
    default:
      throw Exception("$type is not a ViolationType");
  }
}

class _ReportFormInfo {
  ViolationType violationType;
  String licensePlate, description;

  _ReportFormInfo({this.violationType, this.licensePlate, this.description});

  _ReportFormInfo.empty();

  @override
  String toString() {
    return 'ReportInfo{violationType: $violationType, licensePlate: $licensePlate, description: $description}';
  }
}
