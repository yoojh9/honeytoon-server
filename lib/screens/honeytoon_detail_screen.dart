import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/history.dart';
import '../models/honeytoonContentItem.dart';
import '../models/likes.dart';
import '../providers/auth_provider.dart';
import '../providers/honeytoon_content_provider.dart';
import '../providers/honeytoon_meta_provider.dart';
import '../providers/my_provider.dart';
import './my/edit_content_screen.dart';
import './template_screen.dart';
import './toon/honeytoon_view_screen.dart';
import './my/add_content_screen.dart';


class HoneytoonDetailScreen extends StatefulWidget {
  static final routeName = 'honeytoon-detail';

  @override
  _HoneytoonDetailScreenState createState() => _HoneytoonDetailScreenState();
}

class _HoneytoonDetailScreenState extends State<HoneytoonDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  HoneytoonContentProvider _contentProvider;
  HoneytoonMetaProvider _metaProvider;
  MyProvider _myProvider;
  bool like = false;
  String userId;
  List<dynamic> _contentList = [];
  History _history;
  int totalCount = 0;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _myProvider = Provider.of<MyProvider>(context, listen: false);

    this._memoizer.runOnce(() async {
      final uid = await AuthProvider.getCurrentFirebaseUserUid();
      setState(() {
        userId = uid;
      });

      final result = await _myProvider.ifLikeHoneytoon(Likes(uid: uid, workId: args['id']));
      setState(() {
        like = result;
      });

      final history = await _myProvider.getHoneytoonHistory(uid, args['id']);
      setState(() {
        _history = history;
      });
    });
  }

  void _navigateToAddContentPage(BuildContext ctx, args) async{
    var result = await Navigator.of(ctx).pushNamed(
              AddContentScreen.routeName,
              arguments: {'id': args['id']});
    if(result!=null){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(result), duration: Duration(seconds: 2),));
    }
  }

  void _navigateToEditContentPage(BuildContext ctx, workId, HoneytoonContentItem data) async {
    var result = await Navigator.of(ctx).pushNamed(
      EditContentScreen.routeName,
      arguments: {'id': workId, 'content_id': data.contentId, 'cover_img': data.coverImgUrl}
    );
  }

  Future<void> _tabLikeButton(String workId, String uid) async {
    setState(() {
      like = !like;
    });
    Likes likeObj =
        Likes(uid: uid, workId: workId, like: like, likeTime: Timestamp.now());
    await _myProvider.likeHoneytoon(likeObj);
  }

  void _navigateViewPage(BuildContext ctx, String workId, String authorId, HoneytoonContentItem data) {
    Navigator.of(ctx).pushNamed(
      HoneytoonViewScreen.routeName,
      arguments: {
        'id': workId,
        'authorId': authorId,
        'times': data.times,
        'contentId': data.contentId,
        'total': totalCount,
        'images': data.contentImgUrls,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    _contentProvider = Provider.of<HoneytoonContentProvider>(context, listen: false);
    _metaProvider = Provider.of<HoneytoonMetaProvider>(context, listen: false);

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (mediaQueryData.padding.top + mediaQueryData.padding.bottom);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(TemplateScreen.routeName);
              }),
          actions: <Widget>[             
            _buildHeaderIcon(context, userId, args)
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(children: [
                      _buildHoneytoonMetaInfo(args['id'], height),
                      _buildHoneytoonContentList(args, _history)
                    ]
                    )
                )
            )
        )
    );
  }

  Widget _buildHeaderIcon(ctx, userId, args) {
    return 
    (userId!=null && userId == args['authorId']) ?
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          _navigateToAddContentPage(ctx, args);
        }
      )
    :
    IconButton(
      icon: (like) 
          ? Icon(Icons.favorite, color: Theme.of(ctx).primaryColor,)
          : Icon(Icons.favorite_border, color: Theme.of(ctx).primaryColor,),
      onPressed: () {
        _tabLikeButton(args['id'], userId);
      },
    );
  }

  Widget _buildHoneytoonMetaInfo(id, height) {
    return FutureBuilder(
        future: _metaProvider.getHoneytoonMeta(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasData) {
            totalCount = snapshot.data.totalCount;
            return Container(
                height: height * 0.4,
                margin: EdgeInsets.only(bottom: height * 0.03),
                child: Column(
                  children: <Widget>[
                    Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: CachedNetworkImage(
                                imageUrl: snapshot.data.coverImgUrl,
                                placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover
                            )
                          )
                        )
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${snapshot.data.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text('${snapshot.data.description}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                  
                                ),
                              ],
                            ),
                            Text('${snapshot.data.displayName}',
                              style: TextStyle(fontSize: 18, color: Colors.grey)
                            ),
                          ]),
                    ),
                  ],
                ));
          } else {
            return Center(child: Text('허니툰을 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요'));
          }
        });
  }

  Widget _buildHoneytoonContentList(args, history) {
    return StreamBuilder(
      stream: _contentProvider.streamHoneytoonContents(args['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0) {
            _contentList = snapshot.data.documents
                .map((item) =>
                    HoneytoonContentItem.fromMap(item.id, item.data()))
                .toList();
          }
          return _buildHoneytoonContentItem(args, history, _contentList);

        } else {
          return Center(child: Text('허니툰을 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요'));
        }
      },
    );
  }

  Widget _buildHoneytoonContentItem(args, history, _contentList){
    return Container(
      child: GridView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _contentList.length,
        itemBuilder: (ctx, index) => ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: GridTile(
            child: GestureDetector(
                onTap: () {
                  _navigateViewPage(ctx, args['id'], args['authorId'], _contentList[index]);
                },
                child: Stack(
                  children: 
                  [
                    CachedNetworkImage(
                      imageBuilder: (context, imageProvider) => _buildImageDecoration(history, _contentList[index].times, imageProvider),
                      imageUrl: _contentList[index].coverImgUrl,
                      placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    (userId==args['authorId'])
                    ? Positioned(
                      top: 0.0, 
                      right: 0.0, 
                      child: InkWell(
                        onTap: (){
                          _navigateToEditContentPage(ctx, args['id'], _contentList[index]);
                        },
                        child: Icon(Icons.settings, size: 18, color: Colors.black87,),
                      )
                    )
                    : Container()
                  ]
                )
            ),
            footer: GridTileBar(
              backgroundColor: Colors.white70,
              title: Text(
                '${_contentList[index].times}화',
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5 / 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5),
      ),
    );
  }

  Widget _buildImageDecoration(history, times, imageProvider){
    if(history!=null && history.timesList.contains(times)){
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            colorFilter: ColorFilter.mode(Colors.grey, BlendMode.lighten),
            fit: BoxFit.cover,
          )
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          )
        ),
      );
    }
  }
}
