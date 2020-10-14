import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/link.dart';
import 'package:provider/provider.dart';
import './providers/coupon_provider.dart';
import './providers/product_provider.dart';
import './screens/auth/auth_join_screen.dart';
import './screens/auth/reset_pwd_screen.dart';
import './screens/my/edit_content_screen.dart';
import './screens/point/coupon_detail_screen.dart';
import './screens/settings/setting_myinfo_edit_screen.dart';
import './screens/settings/setting_privacy_screen.dart';
import './screens/honeytoon_list_screen.dart';
import './screens/auth/auth_screen.dart';
import './screens/point/shopping_item_screen.dart';
import './screens/template_screen.dart';
import './screens/point/coupon_screen.dart';
import './screens/toon/honeytoon_view_screen.dart';
import './screens/toon/honeytoon_comment_screen.dart';
import './screens/honeytoon_detail_screen.dart';
import './screens/my/add_contentmeta_screen.dart';
import './screens/my/add_content_screen.dart';
import './screens/settings/setting_myinfo_screen.dart';
import './providers/honeytoon_content_provider.dart';
import './providers/auth_provider.dart';
import './providers/honeytoon_meta_provider.dart';
import './providers/my_provider.dart';
import './providers/comment_provider.dart';
import './providers/point_provider.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  KakaoContext.clientId = "a34461bb86a5d8782ab16e75419d5955";
  KakaoContext.javascriptClientId = "38549e1d4f65d4c9c19ac37cad047400";
  //await FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  await Firebase.initializeApp();
  await FirebaseAdMob.instance.initialize(appId: Platform.isIOS ? 'ca-app-pub-6013376310231208~9087160217' : 'ca-app-pub-6013376310231208~8843617638');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HoneytoonMetaProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HoneytoonContentProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PointProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CommentProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MyProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProductProvider()
        ),
        ChangeNotifierProvider(
          create: (ctx) => CouponProvider()
        )
      ],
      child: MaterialApp(
        title: 'Honey Toon',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: themeColor,
          primaryColor: themeColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,
        ),
        // darkTheme: ThemeData(
        //   primaryColor: themeColor,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        //   brightness: Brightness.dark,
        // ),
        home: TemplateScreen(),
        routes: {
          TemplateScreen.routeName : (context) => TemplateScreen(),
          HoneyToonListScreen.routeName : (context) => HoneyToonListScreen(),
          CouponScreen.routeName: (context) => CouponScreen(),
          CouponDetailScreen.routeName: (context) => CouponDetailScreen(),
          ShoppingItemScreen.routeName: (context) => ShoppingItemScreen(),
          HoneytoonViewScreen.routeName: (context) => HoneytoonViewScreen(),
          HoneytoonDetailScreen.routeName: (context) => HoneytoonDetailScreen(),
          AddContentMetaScreen.routeName: (context) => AddContentMetaScreen(),
          AddContentScreen.routeName: (context) => AddContentScreen(),
          EditContentScreen.routeName: (context) => EditContentScreen(),
          AuthScreen.routeName: (context) => AuthScreen(),
          AuthJoinScreen.routeName: (context) => AuthJoinScreen(),
          HoneytoonCommentScreen.routeName: (context) =>  HoneytoonCommentScreen(),
          SettingMyinfoScreen.routeName: (context) => SettingMyinfoScreen(),
          SettingMyInfoEditScreen.routeName : (context) => SettingMyInfoEditScreen(),
          SettingPrivacyScreen.routeName: (context) => SettingPrivacyScreen(),
          ResetPwdScreen.routeName : (context) => ResetPwdScreen(),
  
        },
      ),
    );
  }

  void firebaseCloudMessagingListeners() {
    if(Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token){
      print('token:'+token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      }
    );

  }

  void iOSPermission(){
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print('Settings registered : $settings');
    });
  }
}

const MaterialColor themeColor = MaterialColor(0XFFFFBE42, <int, Color>{
  50: Color(0XFFFFBE42),
  100: Color(0XFFFFBE42),
  200: Color(0XFFFFBE42),
  300: Color(0XFFFFBE42),
  400: Color(0XFFFFBE42),
  500: Color(0XFFFFBE42),
  600: Color(0XFFFFBE42),
  700: Color(0XFFFFBE42),
  800: Color(0XFFFFBE42),
  900: Color(0XFFFFBE42),
});
