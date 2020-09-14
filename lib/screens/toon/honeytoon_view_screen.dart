import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:honeytoon/models/current.dart';
import 'package:honeytoon/providers/honeytoon_content_provider.dart';
import 'package:honeytoon/providers/point_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/my_provider.dart';
import 'package:provider/provider.dart';
import './honeytoon_comment_screen.dart';
import 'package:async/async.dart';

class HoneytoonViewScreen extends StatefulWidget {
  static final routeName = 'honeytoon-view';

  @override
  _HoneytoonViewScreenState createState() => _HoneytoonViewScreenState();
}

class _HoneytoonViewScreenState extends State<HoneytoonViewScreen> with SingleTickerProviderStateMixin {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  var _isVisible = true;
  int _currentIndex = 0;
  String userId;
  MyProvider _myProvider;
  HoneytoonContentProvider _contentProvider;
  TextEditingController _controller;
  int _giftPoint = 0;

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: '0');
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _isVisible) {
        setState(() {
          _isVisible = false;
        });
      }
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          !_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
      setState(() {
        _giftPoint = 10;
      });
    });
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

      Current current = Current(
          uid: userId,
          workId: args['id'],
          contentId: args['data'].contentId,
          times: args['data'].times,
          updateTime: Timestamp.now());
      await _myProvider.addCurrentHoneytoon(current);
    });
  }

  void _onTap(BuildContext context, height, int index, args) {
    setState(() {
      if (index == 0) {
      } else if (index == 1) {
        Navigator.of(context).pushNamed(HoneytoonCommentScreen.routeName,
            arguments: {'id': args['data'].contentId});
      } else if (index == 2) {
        _modalBottomSheetMenu(context, height, args);
      } else if (index == 3) {}
    });
  }

  void _submitGiftPoint(context, args) async {
    PointProvider _pointProvider = Provider.of<PointProvider>(context, listen: false);
    await _pointProvider.sendPoint(args['authorId'], userId, _giftPoint);
    Navigator.pop(context);
    _showSnackbar(context, '작가에게 $_giftPoint 꿀을 선물했습니다.');
  }

  Widget buildImage(args) {
    List<String> images = args['images'];
    if (images != null) {
      return Container(
          child: Column(
              children: images
                  .map((image) => CachedNetworkImage(
                      imageUrl: image,
                      placeholder: (context, url) =>
                          Image.asset('assets/images/image_spinner.gif'),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover))
                  .toList()));
    } else {
      return FutureBuilder(
          future: _contentProvider.getHoneytoonContentByTimes(
              args['id'], args['data'].times),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              print('image:${snapshot.data.contentImgUrls}');
              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: snapshot.data.contentImgUrls.length,
                        itemBuilder: (ctx, index) => CachedNetworkImage(
                            imageUrl: snapshot.data.contentImgUrls[index],
                            placeholder: (context, url) =>
                                Image.asset('assets/images/image_spinner.gif'),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover))
                  ]));
            } else {
              return Center(
                child: Text('허니툰을 불러오는데 문제가 발생했습니다. 잠시 후 다시 시도해주세요'),
              );
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (mediaQueryData.padding.top + mediaQueryData.padding.bottom + 160);
    final width = mediaQueryData.size.width -
        (mediaQueryData.padding.left + mediaQueryData.padding.right);
    _contentProvider =
        Provider.of<HoneytoonContentProvider>(context, listen: false);

    return Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(controller: _scrollController, slivers: [
          SliverAppBar(
            expandedHeight: 30,
            backgroundColor: Colors.transparent,
            floating: false,
            pinned: false,
            leading: IconButton(
                icon: Icon(Icons.format_list_bulleted),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                '${args['data'].times}화',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate([buildImage(args)]))
        ]),
        bottomNavigationBar:
            _buildBottonNavigationBar(height, width, args));
  }

  Widget _buildBottonNavigationBar(height, width, args) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: _isVisible ? 60 : 0,
        child: _isVisible
            ? Wrap(children: [
                BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.arrow_back), title: Text('이전화')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.mode_comment), title: Text('댓글')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.attach_money), title: Text('선물하기')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.arrow_forward), title: Text('다음화')),
                  ],
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    _onTap(context, height, index, args);
                  },
                ),
              ])
            : Container(color: Colors.transparent, width: width));
  }

  void _modalBottomSheetMenu(context, height, args) {
    String authorId = args['authorId'];

    if(authorId == userId){
      _showSnackbar(context, '내가 등록한 작품에는 선물을 보낼 수 없습니다');
      return;
    }

    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                height: height * 0.5,
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0))),
                child: Column(children: [
                  RadioListTile(
                      value: 10,
                      groupValue: _giftPoint,
                      title: Text('10꿀'),
                      selected: _giftPoint == 10,
                      onChanged: (value) {
                        setState(() {
                          _giftPoint = value;
                        });
                      }
                  ),
                  RadioListTile(
                      value: 30,
                      groupValue: _giftPoint,
                      title: Text('30꿀'),
                      selected: _giftPoint == 30,
                      onChanged: (value) {
                        print('value:$value');
                        setState(() {
                          _giftPoint = value;
                        });
                      }
                  ),
                  RadioListTile(
                      value: 50,
                      groupValue: _giftPoint,
                      title: Text('50꿀'),
                      selected: _giftPoint == 50,
                      onChanged: (value) {
                        print('value:$value');
                        setState(() {
                          _giftPoint = value;
                        });
                      }
                  ),
                  RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: (){ _submitGiftPoint(context, args);},
                      child: Text(
                        '선물하기',
                      ))
                ]));
          });
        });
  }

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );
  }
}
