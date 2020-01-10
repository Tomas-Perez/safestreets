import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/util/license_plate.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/report_image.dart';
import 'package:mobile/widgets/secondary_button.dart';

class PhotoReviewAlert extends StatefulWidget {
  final ImageProvider imageProvider;

  PhotoReviewAlert({Key key, @required this.imageProvider}) : super(key: key);

  @override
  State createState() => _PhotoReviewAlertState();
}

class _PhotoReviewAlertState extends State<PhotoReviewAlert> {
  final _fieldKey = GlobalKey<FormFieldState>(debugLabel: 'review license plate field');
  final _licensePlateFocus = FocusNode();
  var _licensePlate = '';
  var _autovalidate = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Help us understand this photo'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ReportImage(widget.imageProvider, enableZoom: true),
            _licensePlateField(),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _cancelButton(),
                SizedBox(width: 25),
                _confirmButton(),
              ],
            ),
            SizedBox(height: 20),
            _photoNotClear(),
          ],
        ),
      ),
    );
  }

  Widget _licensePlateField() {
    return TextFormField(
      key: _fieldKey,
      autovalidate: _autovalidate,
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
      onFieldSubmitted: (_) => _submit(),
      onSaved: (licensePlate) => _licensePlate = licensePlate,
    );
  }

  Widget _cancelButton() {
    return SecondaryButton(
      width: 100,
      child: Text('Cancel'),
      onPressed: () => Navigator.pop(context, null),
    );
  }

  Widget _confirmButton() {
    return PrimaryButton(
      key: Key('submit review'),
      width: 120,
      child: Text('Confirm'),
      onPressed: _submit,
    );
  }

  Widget _photoNotClear() {
    return RichText(
      text: TextSpan(
        text: 'The photo is not clear',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => Navigator.pop(context, ReviewResponse.notClear()),
      ),
    );
  }

  void _submit() {
    final field = _fieldKey.currentState;
    if (field.validate()) {
      _licensePlateFocus.unfocus();
      field.save();
      Navigator.pop(context, ReviewResponse.clear(_licensePlate));
    } else {
      if (!_autovalidate) {
        setState(() {
          _autovalidate = true;
        });
      }
    }
  }
}

class ReviewResponse {
  final bool clear;
  final String licensePlate;

  ReviewResponse.clear(this.licensePlate) : clear = true;

  ReviewResponse.notClear()
      : clear = false,
        licensePlate = null;

  @override
  String toString() {
    return 'ReviewResponse{clear: $clear, licensePlate: $licensePlate}';
  }
}
