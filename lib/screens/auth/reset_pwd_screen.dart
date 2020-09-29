import 'package:flutter/material.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ResetPwdScreen extends StatefulWidget {
  static final routeName = 'reset-pwd';

  @override
  _ResetPwdScreenState createState() => _ResetPwdScreenState();
}

class _ResetPwdScreenState extends State<ResetPwdScreen> {
  AuthProvider _authProvider;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword(BuildContext ctx) async {
    final email = _emailController.text;
    try {
      await _authProvider.resetPassword(email);
      _showSnackbar(context, '비밀번호 재설정 이메일을 보냈습니다. 확인해주세요');
      //await Navigator.of(ctx).pop();
    } catch(error){
      _showSnackbar(context, '이메일 전송에 실패했습니다. 관리자에게 문의하세요');
      print(error);
    }

  }

  String _validateEmail(email){
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(email.isEmpty){
      return '이메일을 입력해주세요';
    } else if(!emailValid){
      return '유효한 이메일을 입력해주세요';
    }
    return null;
  }

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('비밀번호 재설정')
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32, right: 16, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('비밀번호를 다시 설정하시려면\n아래 입력창에 가입하신 메일 주소를 입력해주세요.'),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일'
                ),
                validator: (String value){
                  return _validateEmail(value);
                },
              ),

              Container(
                margin: EdgeInsets.only(top: 16),
                child: ButtonTheme(
                  minWidth: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text('이메일 전송하기', style: TextStyle(fontSize: 16)),
                    onPressed: (){
                      _resetPassword(context);
                    }
                  ),
                ),
              )
            ]
          ),
        ),)
    );
  }
}