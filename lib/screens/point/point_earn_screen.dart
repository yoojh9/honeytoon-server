import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/dateFormatHelper.dart';
import 'package:honeytoon/models/point.dart';
import 'package:honeytoon/providers/point_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _checkPoint = false;
  Map<String, dynamic> _history = Map<String, dynamic>();
  String _dateKey = '';

  @override
  void initState() {
    setState(() {
      _dateKey = DateFormatHelper.getDateFromDateTime(DateTime.now());
    });
    _loadPref();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _pointHistory = prefs.getString('point_history');

    if (_pointHistory == null) return;
    if (mounted) {
      setState(() {
        _history = jsonDecode(_pointHistory);
        if (_history.containsKey(_dateKey)) {
          setState(() {
            _checkPoint = _history[_dateKey];
          });
        }
      });
    }
  }

  void _setPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkPoint = true;
    });
    _history[_dateKey] = _checkPoint;
    prefs.setString('point_history', jsonEncode(_history));
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
            point: rewardAmount,
            createTime: Timestamp.now()));

        _setPref();
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
        (!_checkPoint)
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
