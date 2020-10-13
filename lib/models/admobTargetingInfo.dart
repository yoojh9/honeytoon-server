import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

  // test device id for production
const String testDevice = null;

class AdMobTargetingInfo {
  static final interstitialAdUnitId = Platform.isIOS ? 'ca-app-pub-6013376310231208/6571099472': 'ca-app-pub-6013376310231208/8625760638';
  static final rewardAdUnitId = Platform.isIOS ? 'ca-app-pub-6013376310231208/8867668365' : 'ca-app-pub-6013376310231208~8843617638';
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['fun'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

}