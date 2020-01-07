import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/services/api_connection_service.dart';
import 'package:mobile/util/license_plate.dart';
import 'package:mobile/widgets/primary_button.dart';
import 'package:mobile/widgets/report_image.dart';
import 'package:mobile/widgets/secondary_button.dart';
import 'package:provider/provider.dart';

class ApiConnectionConfigAlert extends StatefulWidget {
  ApiConnectionConfigAlert({Key key}) : super(key: key);

  @override
  State createState() => _ApiConnectionConfigAlertState();
}

class _ApiConnectionConfigAlertState extends State<ApiConnectionConfigAlert> {
  final _fieldKey = GlobalKey<FormFieldState>();
  final _urlFocus = FocusNode();
  var _url = '';
  var _connecting = false;
  var _autovalidate = false;

  @override
  void initState() {
    super.initState();
    _url = Provider.of<ApiConnectionService>(context, listen: false).url;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Application server connection'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _urlField(),
            SizedBox(height: 5),
            _submitButton(),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _urlField() {
    return TextFormField(
      key: _fieldKey,
      initialValue: _url,
      autovalidate: _autovalidate,
      textInputAction: TextInputAction.next,
      focusNode: _urlFocus,
      decoration: InputDecoration(
        labelText: 'URL *',
        helperText: ' ', // spacing for error message
        icon: Container(
          width: 20,
          height: 20,
          child: _connectionIcon(context),
        ),
      ),
      validator: (value) {
        if (value.isEmpty) return "Url missing";
        return null;
      },
      onFieldSubmitted: (_) => _submit(),
      onSaved: (url) => _url = url,
    );
  }

  Widget _connectionIcon(BuildContext context) {
    if (_connecting)
      return CircularProgressIndicator(strokeWidth: 2);

    final connected = Provider.of<ApiConnectionService>(context).connected;
    if (connected)
      return Icon(
        Icons.check_circle_outline,
        color: Theme.of(context).primaryColor,
      );
    else
      return Icon(
        Icons.error_outline,
        color: Theme.of(context).errorColor,
      );
  }

  Widget _submitButton() {
    return PrimaryButton(
      child: Text('Connect'),
      onPressed: _submit,
    );
  }

  void _submit() async {
    final field = _fieldKey.currentState;
    if (field.validate()) {
      final service = Provider.of<ApiConnectionService>(context);
      _urlFocus.unfocus();
      field.save();
      setState(() {
        _connecting = true;
      });
      await service.connect(_url);
      setState(() {
        _connecting = false;
      });
    } else {
      if (!_autovalidate) {
        setState(() {
          _autovalidate = true;
        });
      }
    }
  }
}
