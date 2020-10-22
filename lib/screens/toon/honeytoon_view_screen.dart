import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:honeytoon/models/admobTargetingInfo.dart';
import 'package:provider/provider.dart';
import '../../models/current.dart';
import '../../models/history.dart';
import '../../models/auth.dart';
import '../../providers/honeytoon_content_provider.dart';
import '../../providers/point_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/my_provider.dart';
import '../honeytoon_detail_screen.dart';
import './honeytoon_comment_screen.dart';


class HoneytoonViewScreen extends StatefulWidget {
  static final routeName = 'honeytoon-view';

  @override
  _HoneytoonViewScreenState createState() => _HoneytoonViewScreenState();
}

class _HoneytoonViewScreenState extends State<HoneytoonViewScreen> with SingleTickerProviderStateMixin {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  var _isVisible = true;
  int _currentIndex = 0;
  int _giftPoint = 0;
  String userId;
  MyProvider _myProvider;
  HoneytoonContentProvider _contentProvider;


  @override
  void initState() {    
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);

    setState(() {
      _giftPoint = 10;
    });
    interstitialAd();
    super.initState();
  }

  void interstitialAd() {
    print('interstitialAd()');

    final interstitialAdInstance = InterstitialAd(
      adUnitId: AdMobTargetingInfo.interstitialAdUnitId, 
      targetingInfo: AdMobTargetingInfo.targetingInfo, 
      listener: (MobileAdEvent event){
        print('loaded');
      }
    );

   interstitialAdInstance..load()..show();


    // RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) async {
    //   print('RewardedVideoAd event $event');
    //   if (event == RewardedVideoAdEvent.loaded) {
    //     print('loaded');
    //     await RewardedVideoAd.instance.show();
    //   }
    // };
    // await RewardedVideoAd.instance.load(
    //     adUnitId: AdMobTargetingInfo.adUnitId, targetingInfo: AdMobTargetingInfo.targetingInfo);
  }

  void _handleScroll(){
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(() { });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _myProvider = Provider.of<MyProvider>(context, listen: false);

    this._memoizer.runOnce(() async {
      //await interstitialAd();
      final uid = await AuthProvider.getCurrentFirebaseUserUid();
      setState(() {
        userId = uid;
      });
      await _addHoneytoonViewLog(args);
    });
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
        body: CustomScrollView(
          //controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 30,
              backgroundColor: Colors.transparent,
              floating: false,
              pinned: false,
              leading: IconButton(
                  icon: Icon(Icons.format_list_bulleted),
                  onPressed: () {
                    _navigateDetailPage(context, args['id'], args['authorId']);
                  }),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  '${args['times']}화',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([buildImage(args)])
            )
          ]),
        bottomNavigationBar:
            _buildBottomNavigationBar(height, width, args));
  }

  /*
   * contents image build
   */
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
                      fit: BoxFit.fill))
                  .toList()));
    } else {
      return FutureBuilder(
          future: _contentProvider.getHoneytoonContentByTimes(args['id'], args['times']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              args['contentId'] = snapshot.data.contentId;

              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: 
                        List.generate(snapshot.data.contentImgUrls.length, (index) => CachedNetworkImage(
                                imageUrl: snapshot.data.contentImgUrls[index],
                                placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover))
                      ));
                      
            } else {
              return Center(
                child: Text('허니툰을 불러오는데 문제가 발생했습니다. 잠시 후 다시 시도해주세요'),
              );
            }
          });
    }
  }


 /*
  *  bottom Navigation bar 생성
  */
  Widget _buildBottomNavigationBar(height, width, args) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: _isVisible ? 60 : 0,
        child: _isVisible
          ? Wrap(children: [
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.arrow_back), label: '이전화',),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.mode_comment), label: '댓글'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.attach_money), label: '선물하기'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.arrow_forward), label: '다음화'),
                ],
                currentIndex: _currentIndex,
                onTap: (index) {
                  _onTap(context, height, index, args);
                },
              ),
            ])
          : Container(color: Colors.transparent, width: width));
  }


  Future<void> _addHoneytoonViewLog(args) async {
    if(userId==null) return;
    else if(userId == args['authorId']) return;
    
      Current current = Current(
          uid: userId,
          workId: args['id'],
          contentId: args['contentId'],
          times: args['times'],
          updateTime: Timestamp.now()
      );
      
      History history = History(
        uid: userId,
        workId: args['id'],
        times: args['times'],
        updateTime: Timestamp.now()
      );

    try {
      await _myProvider.addCurrentHoneytoon(current);
      await _myProvider.addHoneytoonHistory(history);
    } catch(error){
      print(error);
    }
  }

  void _onTap(BuildContext context, height, int index, args) {
    setState(() {
      if (index == 0) {
        _navigateOtherPage(context, args, -1);
      } else if (index == 1) {
        Navigator.of(context).pushNamed(HoneytoonCommentScreen.routeName,
            arguments: {'id': args['contentId']});
      } else if (index == 2) {
        _modalBottomSheetMenu(context, height, args);
      } else if (index == 3) {
        _navigateOtherPage(context, args, 1);
      }
    });
  }

  void _submitGiftPoint(context, args) async {
    AuthProvider  _authProvider = Provider.of<AuthProvider>(context, listen: false);
    PointProvider _pointProvider = Provider.of<PointProvider>(context, listen: false);

    Auth _auth = await _authProvider.getUserFromDB();
    if(_auth.honey < _giftPoint) {
      Navigator.pop(context);
      _showSnackbar(context, '보유한 꿀단지 수가 부족하여 선물할 수 없습니다.');
    } else {
      await _pointProvider.sendPoint(args['authorId'], userId, _giftPoint);
      Navigator.pop(context);
      _showSnackbar(context, '작가에게 $_giftPoint 꿀을 선물했습니다.');
    }
  }

  void _navigateOtherPage(BuildContext ctx, args, timesIncrement) {
    int times = int.parse(args['times']) + timesIncrement;
    if(times == 0) {
      _showSnackbar(context, '이전화가 없습니다.');
      return;
    } else if(times > args['total']){
      _showSnackbar(context, '마지막 화 입니다.');
      return;
    } else {
      args['times'] = times.toString();
      Navigator.of(ctx).pushReplacementNamed(HoneytoonViewScreen.routeName,
        arguments: {
          'id': args['id'],
          'authorId': args['authorId'],
          'times': args['times'],
          'contentId': args['contentId'],
          'total': args['total'],
          'images':null,
        }
      );
    }
  }

  void _navigateDetailPage(BuildContext ctx, workId, authorId){
    Navigator.of(context).pushNamed(HoneytoonDetailScreen.routeName,
    arguments: {
      'id': workId,
      'authorId': authorId,
    });
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
