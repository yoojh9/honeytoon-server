import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/models/point.dart';
import 'package:honeytoon/providers/point_provider.dart';
import 'package:provider/provider.dart';

// test device id for production
const String testDevice = null;

class PointEarnScreen extends StatefulWidget {
  @override
  _PointEarnScreenState createState() => _PointEarnScreenState();
}

class _PointEarnScreenState extends State<PointEarnScreen>
    with TickerProviderStateMixin {
  PointProvider _pointProvider;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['fun'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  int _coins = 0;
  bool _videoLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void rewardVideo() async {
    print('rewardVideo()');
    final _user = await FirebaseAuth.instance.currentUser();
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      print('RewardedVideoAd event $event');
      if (event == RewardedVideoAdEvent.rewarded) {
        _pointProvider.setPoint(Point(
            uid: _user.uid,
            type: PointType.REWARD,
            point: rewardAmount.toDouble(),
            createTime: Timestamp.now()));
        setState(() {
          _coins += rewardAmount;
          _videoLoaded = true;
          print('coins:$_coins');
        });
      } else if (event == RewardedVideoAdEvent.loaded) {
        print('loaded');
        await RewardedVideoAd.instance.show();
      }
    };
    await RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _pointProvider = Provider.of<PointProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        (!_videoLoaded)
            ? RaisedButton(
                child: Text('출석하기'),
                onPressed: rewardVideo,
                color: Theme.of(context).primaryColor)
            : Text('리워드 완료')
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text('더 많은 포인트를 얻고싶다면?', style: TextStyle(fontSize: 14),),
        //     SizedBox(width: 10),
        //     FlatButton(child: Text('광고보기'), onPressed: (){},)
        //   ]
        // )
      ],
    );
  }
}
