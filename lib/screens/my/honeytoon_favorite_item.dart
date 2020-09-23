import 'package:flutter/material.dart';
import '../../helpers/dateFormatHelper.dart';
import '../../screens/honeytoon_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoriteToonItem extends StatelessWidget {
  const FavoriteToonItem({
    Key key,
    @required this.height,
    @required this.data,
    @required this.uid,

  }) : super(key: key);

  final double height;
  final data;
  final uid;

  _navigateDetailPage(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(HoneytoonDetailScreen.routeName,
      arguments: {'id' : data.workId, 'authorId': data.uid});
  }

  @override
  Widget build(BuildContext context) {
    return data == null ? Container() : 
    Container(
      height: height * 0.15,
      child: GestureDetector(
        onTap: (){
          _navigateDetailPage(context);
        },
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${data.title}', style: TextStyle(fontSize:18,), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  Text('${data.authName}'),
                  Text('${DateFormatHelper.getDateTime(data.likeTime)}')
                ]
              )
            ),

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
                  fit: BoxFit.cover))),
          ]
        ),
      ),
    );
  }
}