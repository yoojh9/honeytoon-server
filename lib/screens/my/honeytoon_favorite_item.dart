import 'package:flutter/material.dart';
import '../../helpers/dateFormatHelper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoriteToonItem extends StatelessWidget {
  const FavoriteToonItem({
    Key key,
    @required this.height,
    @required this.data,

  }) : super(key: key);

  final double height;
  final data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.15,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${data.title}', style: TextStyle(fontSize:20,),),
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
    );
  }
}