import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';

class MyHonetoonInfo extends StatelessWidget {
  const MyHonetoonInfo({
    Key key,
    @required this.height,
    @required this.auth,
  }) : super(key: key);

  final double height;
  final Auth auth;

  @override
  Widget build(BuildContext context) {
    final double circleRadius = 120.0;
    return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding:
            EdgeInsets.only(top: circleRadius/2.0 + 8, bottom: 16, right: 16, left: 16 ),  ///here we create space for the circle avatar to get ut of the box
            child: Container(
              height: height * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0.0, 5.0),
                  ),
                ],
              ),
              child: Column(
                  children: <Widget>[
                    SizedBox(height: circleRadius/2,),
                    Text(auth.displayName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text('작가랭킹', style: TextStyle( fontSize: 16.0,  color: Colors.black54,),),
                              Text("${auth.rank <= 0? '-': auth.rank}위"  , style: TextStyle( fontSize: 16.0, color: Colors.black87, fontFamily: ''),),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text('작품정보', style: TextStyle( fontSize: 16.0,  color: Colors.black54),),
                              Text("${auth.works==null || auth.works.length==0 ? '-': auth.works.length}개", style: TextStyle( fontSize: 16.0, color: Colors.black87, fontFamily: ''),),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text('꿀단지', style: TextStyle( fontSize: 16.0,  color: Colors.black54),),
                              Text("${auth.honey==null ? 0 : auth.honey}꿀", style: TextStyle( fontSize: 16.0, color: Colors.black87, fontFamily: ''),),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
            ),
          ),
          ///Image Avatar
          Container(
            width: circleRadius,
            height: circleRadius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0.0, 5.0),
                ),
              ],
            ),
            child: Center(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: 
                    auth.thumbnail !=null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(circleRadius),
                      child: CachedNetworkImage(
                        width: circleRadius,
                        height: circleRadius,
                        imageUrl: auth.thumbnail,
                        placeholder: (context, url) => Image.asset('assets/images/avatar_placeholder.png',),
                        errorWidget: (context, url, error) => Image.asset('assets/images/avatar_placeholder.png'),
                        fit: BoxFit.cover
                      ),   
                    )
                    : CircleAvatar(
                      radius: circleRadius,
                      backgroundImage: AssetImage('assets/images/avatar_placeholder.png'),
                      //radius: 50,
                    ),
                ),
              ),
            ),
        ],
      );
  }
}