import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'auth_join_screen.dart';

class AuthScreen extends StatefulWidget {
  static final routeName = 'auth-screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var user;
  var _loading = false;


  void _loginKakao(BuildContext ctx) async {
    try {
      setState(() {
        _loading = true;
      });
      user = await FirebaseAuth.instance.currentUser();
      if (user == null) {
        user = await Provider.of<AuthProvider>(context, listen: false).kakaoLogin();
      }     
      Navigator.of(ctx).pop(user);      
    } catch(error){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('카카오톡으로 로그인을 진행할 수 없습니다.'), duration: Duration(seconds: 2),));
      print(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _loginFacebook(BuildContext ctx) async {
    try {
      setState(() {
        _loading = true;
      });
      user = await FirebaseAuth.instance.currentUser();
      if (user == null) {
        user = await Provider.of<AuthProvider>(context, listen: false)
            .facebookLogin();
      }
    Navigator.of(ctx).pop(user);
    } catch(error){
      print(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _loginEmail(BuildContext ctx) async {
    try {
      setState(() {
        _loading = true;
      });
      final email = _emailController.text;
      final password = _passwordController.text;
      user = await Provider.of<AuthProvider>(context, listen: false).emailLogin(email, password);
      Navigator.of(ctx).pop(user);
    } on PlatformException catch (error) {
      if(error.code == "ERROR_WRONG_PASSWORD") {
        _showSnackbar(ctx, '비밀번호가 다릅니다');
      }
      print(error);
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );
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
          child: 
          _loading 
          ? Center(child: CircularProgressIndicator(),)
          : Column(
            children: <Widget>[
              _buildEmailLogin(),
              _buildSnsLogin()
            ],
          ),
        )
        //Center(child: Text('login'),)

        );
  }

  Widget _buildEmailLogin(){
    return Expanded(
      flex: 1,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('이메일로 로그인',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "이메일",
                  ),
                  validator: (String value){
                    if(value.isEmpty) return '이메일을 입력해주세요';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "비밀번호"),
                  obscureText: true,
                  validator: (String value){
                    if(value.isEmpty) return '비밀번호를 입력해주세요';
                    return null;
                  },
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
                      onPressed: () async {
                        if(_formKey.currentState.validate()){
                          _loginEmail(context);
                        }
                      }
                  )
                ),
                Row(children: <Widget>[
                  FlatButton(onPressed: (){}, child: Text('비밀번호를 잊으셨나요?', style: TextStyle(decoration: TextDecoration.underline))),
                  Spacer(),
                  FlatButton(onPressed: (){
                    Navigator.of(context).pushNamed(AuthJoinScreen.routeName);
                  }, child: Text('회원가입', style: TextStyle(decoration: TextDecoration.underline)))
                ],)
              ]),
          )),
    );
  }

  Widget _buildSnsLogin(){
    return Expanded(
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
    );
  }
}
