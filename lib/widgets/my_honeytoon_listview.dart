import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/models/honeytoonMeta.dart';
import '../screens/honeytoon_detail_screen.dart';
import 'package:provider/provider.dart';
import '../screens/my/add_content_screen.dart';
import '../providers/honeytoon_meta_provider.dart';

class MyHoneytoonListView extends StatefulWidget {
  const MyHoneytoonListView({
    Key key,
    @required this.height,
    @required this.uid,
    this.scaffoldKey
  }) : super(key: key);

  final double height;
  final String uid;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _MyHoneytoonListViewState createState() => _MyHoneytoonListViewState();
}

class _MyHoneytoonListViewState extends State<MyHoneytoonListView> {
  List<dynamic> _myHoneytoon = [];

  void _navigateToDetail(BuildContext ctx, String uid, String workId){
    Navigator.of(ctx).pushNamed(HoneytoonDetailScreen.routeName, arguments: {'uid': uid, 'id': workId});
  }

  void _navigateToAddContentPage(BuildContext ctx, data) async{
    var result = await Navigator.of(ctx)
                .pushNamed(AddContentScreen.routeName, arguments: {'id': data.workId, 'page': HoneytoonDetailScreen.routeName});
    if(result!=null){
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(result), duration: Duration(seconds: 2),));
    }
  }

  @override
  Widget build(BuildContext context) {
    HoneytoonMetaProvider _metaProvider = Provider.of<HoneytoonMetaProvider>(context, listen: true);

    return Container(
      child: StreamBuilder(
        stream: _metaProvider.getMyHoneytoonStream(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if(snapshot.hasError) {
            return Center(child: Text('허니툰을 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요'));
          } else if(snapshot.hasData) {
            _myHoneytoon = snapshot.data.documents
              .map((item) => HoneytoonMeta.fromMap(item.data, item.documentID))
              .toList();

            return ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (_, index) {
                var data = _myHoneytoon[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(children: [
                    _buildCoverImage(context, data),
                    _buildHoneytoonInfo(context, widget.uid, data),
                    _buildAddIcon(context, data)
                  ]),
                );
              },
            );
          } else {
            return Center(child: Text('데이터가 없습니다'));
          }
        }),
    );
  }

  Widget _buildCoverImage(ctx, data){
    return Expanded(
      flex: 2,
      child: AspectRatio(
          aspectRatio: 4 / 3,
          child: GestureDetector(
            onTap: (){
              _navigateToDetail(ctx, widget.uid, data.workId);
            },
            child: CachedNetworkImage(
              imageUrl: data.coverImgUrl,
              placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover
            ),
          )
      ),
    );
  }

  Widget _buildHoneytoonInfo(ctx, uid, data){
    return Expanded(
      flex: 3,
      child: GestureDetector(
        onTap: (){
          _navigateToDetail(ctx, uid, data.workId);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data.title}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text((data.totalCount == 0)
                    ? "- 화"
                    : '${data.totalCount}화'),
                Text('3일전'),
              ]),
        ),
      )
    );
  }

  Widget _buildAddIcon(ctx, data){
   return Expanded(
      flex: 1,
      child: IconButton(
          icon: Icon(
            Icons.add,
          ),
          onPressed: () {
           _navigateToAddContentPage(ctx, data);
          }
      )
    );
  }
}
