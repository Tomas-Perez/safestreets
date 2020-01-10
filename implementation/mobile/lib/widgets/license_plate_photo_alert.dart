import 'package:flutter/material.dart';
import 'package:mobile/widgets/report_image.dart';

import 'image_carousel.dart';

/// Alert to select the photo showing the target license plate of the report.
class LicensePlateAlert extends StatefulWidget {
  final List<ImageProvider> images;

  LicensePlateAlert({
    Key key,
    @required this.images,
  })  : assert(images.isNotEmpty, "Alert needs at least one image to select"),
        super(key: key);

  @override
  State createState() => _LicensePlateAlertState();
}

class _LicensePlateAlertState extends State<LicensePlateAlert> {
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
                    ReportImage(widget.images[idx], enableZoom: true),
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
          key: Key('cancel'),
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context, null),
        ),
        FlatButton(
          key: Key('ok'),
          child: Text("OK"),
          onPressed: () => Navigator.pop(context, _selectedIndex),
        ),
      ],
    );
  }
}
