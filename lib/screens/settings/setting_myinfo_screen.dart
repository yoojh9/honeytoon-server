import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/models/user.dart';
import '../../providers/auth_provider.dart';
import 'package:honeytoon/screens/settings/setting_section.dart';
import 'package:provider/provider.dart';
import 'setting_list.dart';
import 'setting_tile.dart';
import '../auth_screen.dart';

class SettingMyinfoScreen extends StatefulWidget {
  static const routeName = 'setting-myinfo';

  @override
  _SettingMyinfoScreenState createState() => _SettingMyinfoScreenState();
}

class _SettingMyinfoScreenState extends State<SettingMyinfoScreen> {
  Future<User> _getUserInfo(BuildContext ctx) async {
    final user =
        await Provider.of<AuthProvider>(ctx, listen: false).getUserFromDB();
    return user;
  }

  Future<void> _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (kToolbarHeight +
            mediaQueryData.padding.top +
            mediaQueryData.padding.bottom);

    return Scaffold(
        appBar: AppBar(
          title: Text('프로필'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!(snapshot.hasData)) {
                return Center(
                  child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text('로그인'),
                      onPressed: () => _loginPage(context)),
                );
              } else {
                return FutureBuilder(
                  future: Provider.of<AuthProvider>(context, listen: false)
                      .getUserFromDB(),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!(futureSnapshot.hasData)) {
                      return Center(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text('로그인'),
                            onPressed: () => _loginPage(context)),
                      );
                    } else {
                      return Container(
                        height: height,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        width: height * 0.15,
                                        height: height * 0.15,
                                        imageUrl: futureSnapshot.data.thumbnail,
                                        placeholder: (context, url) => Image.asset('assets/images/avatar_placeholder.png', width: height * 0.15),
                                        errorWidget: (context, url, error) => Image.asset('assets/images/avatar_placeholder.png', width: height * 0.15),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(futureSnapshot.data.displayName,
                                        style: TextStyle(
                                          fontSize: 20,
                                        )),
                                    Text('12000꿀')
                                  ],
                                )),
                            Expanded(
                                flex: 3,
                                child: SettingList(
                                  sections: [
                                    SettingsSection(title: '계정', tiles: [
                                      SettingsTile(
                                        title: '닉네임변경',
                                        onTap: () {},
                                      ),
                                      SettingsTile(
                                          title: '로그아웃', onTap: _logout),
                                      SettingsTile(title: '탈퇴하기', onTap: () {}),
                                    ])
                                  ],
                                ))
                          ],
                        ),
                      );
                    }
                  },
                );
              }
            }));
  }
}
