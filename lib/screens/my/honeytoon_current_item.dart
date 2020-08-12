import 'package:flutter/material.dart';
import '../toon/honeytoon_view_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CurrentToonItem extends StatelessWidget {
  const CurrentToonItem({
    Key key,
    @required this.height,
    @required this.data,
    @required this.uid,

  }) : super(key: key);

  final double height;
  final data;
  final uid;

  _navigateViewPage(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(HoneytoonViewScreen.routeName,
      arguments: {'id' : data.workId, 'contentId': data.contentId, 'times': data.times});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.15,
      child: GestureDetector(
        onTap: (){
          _navigateViewPage(context);
        },
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 4/3,
                child: CachedNetworkImage(
                  imageUrl: data.coverImgUrl,
                  placeholder: (context, url) => Image.asset(
                      'assets/images/image_spinner.gif'),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                  fit: BoxFit.cover))
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${data.title}', style: TextStyle(fontSize:20,),),
                    Text('${data.authName}'),
                    Text('${data.times}화')
                  ]
                ),
              )
            ),

          ]
        ),
      ),
    );
  }
}