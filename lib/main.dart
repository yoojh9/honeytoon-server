import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/screens/auth_join_screen.dart';
import 'package:kakao_flutter_sdk/link.dart';
import './screens/honeytoon_list_screen.dart';
import './screens/auth_screen.dart';
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
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoContext.clientId = "a34461bb86a5d8782ab16e75419d5955";
  KakaoContext.javascriptClientId = "38549e1d4f65d4c9c19ac37cad047400";
  FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
        )
      ],
      child: MaterialApp(
        title: 'Honey Toon',
        theme: ThemeData(
          primarySwatch: themeColor,
          primaryColor: themeColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primaryColor: themeColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark,
        ),
        home: TemplateScreen(),
        routes: {
          HoneyToonListScreen.routeName : (context) => HoneyToonListScreen(),
          CouponScreen.routeName: (context) => CouponScreen(),
          ShoppingItemScreen.routeName: (context) => ShoppingItemScreen(),
          HoneytoonViewScreen.routeName: (context) => HoneytoonViewScreen(),
          HoneytoonDetailScreen.routeName: (context) => HoneytoonDetailScreen(),
          AddContentMetaScreen.routeName: (context) => AddContentMetaScreen(),
          AddContentScreen.routeName: (context) => AddContentScreen(),
          AuthScreen.routeName: (context) => AuthScreen(),
          AuthJoinScreen.routeName: (context) => AuthJoinScreen(),
          HoneytoonCommentScreen.routeName: (context) =>
              HoneytoonCommentScreen(),
          SettingMyinfoScreen.routeName: (context) => SettingMyinfoScreen(),
        },
      ),
    );
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
