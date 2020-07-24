import 'package:firebase_admob/firebase_admob.dart';

  // test device id for production
const String testDevice = null;

class AdMobTargetingInfo {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['fun'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

}