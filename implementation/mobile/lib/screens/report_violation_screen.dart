import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:mobile/data/picture_info.dart';
import 'package:mobile/data/report.dart';
import 'package:mobile/data/violation_type.dart';
import 'package:mobile/screens/display_success_snackbar.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/services/http_client.dart';
import 'package:mobile/services/report_submission_service.dart';
import 'package:mobile/util/license_plate.dart';
import 'package:mobile/util/snackbar.dart';
import 'package:mobile/util/submit_controller.dart';
import 'package:mobile/widgets/backbutton_section.dart';
import 'package:mobile/widgets/image_carousel.dart';
import 'package:mobile/widgets/license_plate_photo_alert.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/report_image.dart';
import 'package:mobile/widgets/safestreets_appbar.dart';
import 'package:mobile/widgets/safestreets_screen_title.dart';
import 'package:provider/provider.dart';

class ReportViolationScreen extends StatefulWidget {
  const ReportViolationScreen({Key key}) : super(key: key);

  @override
  State createState() => _ReportViolationScreenState();
}

class _ReportViolationScreenState extends State<ReportViolationScreen> {
  final _controller = SingleListenerController<_ReportFormInfo>();
  final _images = <PictureInfo>[];
  var _selectedIndex = -1;
  var _submitting = false;

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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            child: Column(
              children: <Widget>[
                SafeStreetsScreenTitle("Report a violation"),
                _ReportForm(controller: _controller),
                const SizedBox(height: 30),
                Builder(builder: (ctx) => _photosSection(ctx)),
                const SizedBox(height: 10),
                Builder(builder: (ctx) => _confirmButton(ctx)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _takePhotoButton(BuildContext context) {
    return Container(
      width: 100,
      height: 25,
      child: RaisedButton(
        padding: const EdgeInsets.all(0),
        child: Text('Take a photo'),
        onPressed: () async {
          final service = Provider.of<CameraService>(context);
          final imageData = await service.openViewfinder(context);
          if (imageData != null) {
            Position position = await Geolocator()
                .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
            final pictureInfo = PictureInfo(
              imageData: imageData,
              location: LatLng(position.latitude, position.longitude),
              time: DateTime.now(),
            );
            setState(() {
              _images.add(pictureInfo);
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
          _takePhotoButton(context),
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
                child: ReportImage(
                  MemoryImage(_images[_selectedIndex].imageData),
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
            itemBuilder: (_, idx) =>
                ReportImage(MemoryImage(_images[idx].imageData)),
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
      child: PrimaryButton(
        submitting: _submitting,
        width: 130,
        child: Text(
          'Confirm',
        ),
        onPressed: _images.isEmpty ? null : () => _submitForm(context),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    final reportInfo = _controller.submit();
    if (reportInfo == null) return;
    final selectedIndex = await showDialog(
      context: context,
      builder: (ctx) => LicensePlateAlert(
        images: _images.map((i) => MemoryImage(i.imageData)).toList(),
      ),
    );
    if (selectedIndex == null) return;
    setState(() {
      _submitting = true;
    });
    final reportService = Provider.of<ReportSubmissionService>(context);
    try {
      await reportService.submit(
        ReportForm(
          violationType: reportInfo.violationType,
          licensePlate: reportInfo.licensePlate,
          description: reportInfo.description,
          images: _images,
          licensePlateImgIndex: selectedIndex,
        ),
      );
      Navigator.pop(context, const DisplaySuccessSnackbar());
    } on TimeoutException {
      showNoConnectionSnackbar(context);
    } catch (e) {
      print(e);
      showErrorSnackbar(Key('submit report error'), context, 'There was a problem submitting the report');
    } finally {
      if (mounted)
        setState(() {
          _submitting = false;
        });
    }
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

class _ReportForm extends StatefulWidget {
  final SubmitController<_ReportFormInfo> controller;

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
          return "Please enter an italian license plate (AA000AA)";
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
      if (!_autovalidate) {
        setState(() {
          _autovalidate = true;
        });
      }
      return null;
    }
  }
}

class _ReportFormInfo {
  ViolationType violationType;
  String licensePlate, description;

  _ReportFormInfo({
    @required this.violationType,
    @required this.licensePlate,
    @required this.description,
  });

  _ReportFormInfo.empty();

  @override
  String toString() {
    return 'ReportInfo{violationType: $violationType, licensePlate: $licensePlate, description: $description}';
  }
}
