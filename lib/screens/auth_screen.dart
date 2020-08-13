import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'auth_join_screen.dart';

class AuthScreen extends StatefulWidget {
  static final routeName = 'auth-screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var user;

  void _loginKakao(BuildContext ctx) async {
    try {
      user = await FirebaseAuth.instance.currentUser();
      if (user == null) {
        user = await Provider.of<AuthProvider>(context, listen: false).kakaoLogin();
      }
      Navigator.of(ctx).pop(user);
    } catch(error){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('카카오톡으로 로그인을 진행할 수 없습니다.'), duration: Duration(seconds: 2),));
      print(error);
    }
  }

  void _loginFacebook(BuildContext ctx) async {
    user = await FirebaseAuth.instance.currentUser();

    if (user == null) {
      user = await Provider.of<AuthProvider>(context, listen: false)
          .facebookLogin();
    }

    Navigator.of(ctx).pop(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('로그인')
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text('이메일로 로그인',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "이메일",
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: "비밀번호"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ButtonTheme(
                          minWidth: double.infinity,
                          height: 40,
                          child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                '이메일로 로그인',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: () {}),
                        ),
                        Row(children: <Widget>[
                          FlatButton(onPressed: (){}, child: Text('비밀번호를 잊으셨나요?', style: TextStyle(decoration: TextDecoration.underline))),
                          Spacer(),
                          FlatButton(onPressed: (){
                            Navigator.of(context).pushNamed(AuthJoinScreen.routeName);
                          }, child: Text('회원가입', style: TextStyle(decoration: TextDecoration.underline)))
                        ],)
                      ])),
              ),
              Expanded(
                flex: 1,
                child: Container(
                    child: Column(
                      children: 
                      [ 
                        Text('SNS 계정으로 로그인 / 가입', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/images/kakao_login_icon.png'),
                                  radius: 30,
                                ),
                                onTap: () => _loginKakao(context)),
                            SizedBox(width: 20),
                            GestureDetector(
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/images/facebook_login_icon.png'),
                                  radius: 30,
                                ),
                                onTap: () => _loginFacebook(context)),
                            SizedBox(width: 20),
                          ]),
                      ]
                    ),
                ),
              ),
            ],
          ),
        )
        //Center(child: Text('login'),)

        );
  }
}
