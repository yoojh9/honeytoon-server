import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/screens/template_screen.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _leave(BuildContext ctx) async {
    User user = FirebaseAuth.instance.currentUser;
    try {
      await Provider.of<AuthProvider>(ctx, listen: false).deleteUser(user);
      await user.delete();
      //throw Error;
    } catch(error){
      _showSnackbar(context, "회원 탈퇴를 위해 재인증이 필요합니다. 로그인 후 다시 진행해주세요.");
      await _logout();
    }
    //await Provider.of<AuthProvider>(context, listen: false).deleteUser(user);
    //await _logout();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('프로필'),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){Navigator.of(context).pushReplacementNamed(TemplateScreen.routeName);}),
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
              } else if (snapshot.data==null) {
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
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (futureSnapshot.data==null) {
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
                                    futureSnapshot.data.thumbnail != null
                                    ? ClipOval(
                                      child: CachedNetworkImage(
                                        width: height * 0.15,
                                        height: height * 0.15,
                                        imageUrl: futureSnapshot.data.thumbnail,
                                        placeholder: (context, url) => Image.asset('assets/images/avatar_placeholder.png', width: height * 0.15),
                                        errorWidget: (context, url, error) => Image.asset('assets/images/avatar_placeholder.png', width: height * 0.15),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : CircleAvatar(
                                      radius: 50,
                                      backgroundImage: AssetImage('assets/images/avatar_placeholder.png'),
                                      //radius: 50,
                                    ),
                                    Text(futureSnapshot.data.displayName == null ? '' : futureSnapshot.data.displayName,
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
                                          title: '로그아웃', onTap: (){_showLogoutDialog(context);}),
                                      SettingsTile(title: '탈퇴하기', onTap: (){ _showLeaveDialog(context);}),
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

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
     return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('로그아웃 하실건가요?'),
              ],
            )
          ),
          actions: <Widget>[ 
            FlatButton(
              child: Text('확인'),
              onPressed: (){
                Navigator.of(ctx).pop();
                _logout();
              },
            ),
            FlatButton(
              child: Text('취소'),
              onPressed: (){
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      }  
    );   
  }

  Future<void> _showLeaveDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('회원 탈퇴'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('정말 허니툰을 탈퇴하실건가요?'),
                Text('탈퇴 시 포인트는 모두 삭제됩니다.'),
                Text('탈퇴 처리는 최대 3일 소요됩니다.')
              ],
            )
          ),
          actions: <Widget>[ 
            FlatButton(
              child: Text('확인'),
              onPressed: (){
                Navigator.of(ctx).pop();
                _leave(context);
              },
            ),
            FlatButton(
              child: Text('취소'),
              onPressed: (){
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      }  
    );
  }
}
