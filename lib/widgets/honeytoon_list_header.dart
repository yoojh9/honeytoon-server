import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HoneytoonListHeader extends StatefulWidget {
  HoneytoonListHeader({
    Key key,
    @required this.height,
  }) : super(key: key);

  final height;

  @override
  _HoneytoonListHeaderState createState() => _HoneytoonListHeaderState();
}

class _HoneytoonListHeaderState extends State<HoneytoonListHeader> {
  int _current = 0;

  static const List<String> imgList = [
    'https://firebasestorage.googleapis.com/v0/b/honeytoon-server.appspot.com/o/main%2Fimage1.png?alt=media&token=3fa9f77d-e73d-4952-b0d6-2edd9dcf4519',
    'https://firebasestorage.googleapis.com/v0/b/honeytoon-server.appspot.com/o/main%2Fimage2.png?alt=media&token=94cbc1aa-e9bc-4fd4-8ab5-9dff8e62301b',
    'https://firebasestorage.googleapis.com/v0/b/honeytoon-server.appspot.com/o/main%2Fimage3.png?alt=media&token=3ddb8a06-b37c-4b52-a19e-84fe0b507dd0',
  ];

  final List<Widget> imageSliders = imgList
      .map((item) => Container(
            // child: Center(
            //   child: NativeAdsWidget()
            // )
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      CachedNetworkImage(
                        //width: 1000,
                        imageUrl: item,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) =>
                            Image.asset('assets/images/image_spinner.gif'),
                        //fit: BoxFit.fill,
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                              // gradient: LinearGradient(
                              //   colors: [
                              //     Color.fromARGB(200, 0, 0, 0),
                              //     Color.fromARGB(0, 0, 0, 0)
                              //   ],
                              //   begin: Alignment.bottomCenter,
                              //   end: Alignment.topCenter,
                              // ),
                              ),
                          //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        ),
                      ),
                    ],
                  )),
            ),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          overflow: Overflow.visible,
          children: [_buildCarouselSlider(), _buildIndicator()]),
    );
  }

  Widget _buildCarouselSlider() {
    return Container(
      child: CarouselSlider(
          items: imageSliders,
          options: CarouselOptions(
              initialPage: 0,
              aspectRatio: 2/1,
              viewportFraction: 1.0,
              enlargeCenterPage: true,
              //enlargeStrategy: CenterPageEnlargeStrategy.height,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              onPageChanged: (index, _) {
                if (mounted) {
                  setState(() {
                    _current = index;
                  });
                }
              })),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: imgList.map((url) {
        int index = imgList.indexOf(url);
        return Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _current == index
                ? Color.fromRGBO(255, 255, 255, 0.9)
                : Color.fromRGBO(255, 255, 255, 0.4),
          ),
        );
      }).toList(),
    );
  }
}
