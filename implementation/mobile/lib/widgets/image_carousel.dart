import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

/// Shows a carousel of images.
class ImageCarousel extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ValueChanged<int> onIndexChanged;
  final double viewportFraction;

  ImageCarousel({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    this.onIndexChanged,
    this.viewportFraction,
  }) : super(key: key);

  @override
  State createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = SwiperController();
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(Icons.arrow_back),
            onPressed: _index == 0 ? null : _controller.previous,
          ),
        ),
        Expanded(
          child: Container(
            height: 60,
            child: Swiper(
              index: _index,
              controller: _controller,
              onIndexChanged: (index) {
                setState(() {
                  _index = index;
                  widget.onIndexChanged(_index);
                });
              },
              itemBuilder: (BuildContext context, int index) {
                final item = widget.itemBuilder(context, index);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: index != _index
                          ? Opacity(
                              opacity: 0.75,
                              child: item,
                            )
                          : item,
                    ),
                  ),
                );
              },
              viewportFraction: widget.viewportFraction,
              itemCount: widget.itemCount,
              loop: false,
            ),
          ),
        ),
        Container(
          width: 30,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(Icons.arrow_forward),
            onPressed: _index == widget.itemCount - 1 ? null : _controller.next,
          ),
        ),
      ],
    );
  }
}
