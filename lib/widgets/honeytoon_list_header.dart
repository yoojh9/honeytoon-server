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
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
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
                        width: 1000,
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
              aspectRatio: 2 / 1,
              viewportFraction: 1.0,
              enlargeCenterPage: true,
              //enlargeStrategy: CenterPageEnlargeStrategy.height,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              onPageChanged: (index, _) {
                setState(() {
                  _current = index;
                });
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
