import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_screen.dart';
import './setting_myinfo_edit_screen.dart';
import './setting_section.dart';
import './setting_list.dart';
import './setting_tile.dart';


class SettingMyinfoScreen extends StatefulWidget {
  static const routeName = 'setting-myinfo';

  @override
  _SettingMyinfoScreenState createState() => _SettingMyinfoScreenState();
}

class _SettingMyinfoScreenState extends State<SettingMyinfoScreen> {

  Future<void> _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);

    return Scaffold(
        appBar: AppBar(
          title: Text('프로필'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(icon: Icon(Icons.more_vert), onPressed: (){_modalBottomSheetMenu(context, height);})
          ],
          
        ),
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
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
                  future: Provider.of<AuthProvider>(context, listen: false).getUserFromDB(),
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
                                    Text('${futureSnapshot.data.honey}꿀')
                                  ],
                                )),
                            Expanded(
                                flex: 3,
                                child: SettingList(
                                  sections: [
                                    SettingsSection(title: '계정', tiles: [
                                      // SettingsTile(
                                      //   title: '닉네임변경',
                                      //   onTap: (){ Navigator.of(context).pushNamed( SettingMyInfoEditScreen.routeName, arguments: {'user': futureSnapshot.data} );},
                                      // ),
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

  void _modalBottomSheetMenu(BuildContext ctx, height){
    Platform.isIOS ? _showIOSBottomModalMenu(ctx) : _showAndroidBottomModalMenu(ctx, height); 
  }

  void _showIOSBottomModalMenu(BuildContext ctx){
    showCupertinoModalPopup(
      context: ctx,
      builder: (context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('변경'),
            onPressed:(){
              Navigator.of(ctx).pop();
              Navigator.of(ctx).popAndPushNamed(SettingMyInfoEditScreen.routeName);
              //Navigator.of(ctx).pop();
            }
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: (){Navigator.of(ctx).pop();}, child: Text('취소')
        ),
      )
    );
  }

  void _showAndroidBottomModalMenu(BuildContext ctx, height){
    showModalBottomSheet(
        context: context, 
        builder: (builder){
          return Container(
            height: height * 0.2,
            child: Column(
              children: [
                Container(
                  child: FlatButton(
                    onPressed: (){}, 
                    child: Text('변경', style: TextStyle(fontSize:12, color: Theme.of(context).primaryColor),)
                )
                ),
                Container(
                  child: FlatButton(
                    onPressed: (){Navigator.of(ctx).pop();}, 
                    child: Text('닫기',style: TextStyle(fontSize:12, color: Theme.of(context).primaryColor),)
                  )
                ),
              ]
            ),
          );
        }
      );
  }
}
