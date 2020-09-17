import 'package:flutter/material.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingMyInfoEditScreen extends StatefulWidget {
  static const routeName = 'setting-myinfo-edit';

  @override
  _SettingMyInfoEditScreenState createState() => _SettingMyInfoEditScreenState();
}



class _SettingMyInfoEditScreenState extends State<SettingMyInfoEditScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _updateDisplayName(BuildContext ctx, uid) async {
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) return;

    var _changeInfo = {'displayName': _displayNameController.text};
    await Provider.of<AuthProvider>(ctx, listen: false).changeUserInfo(uid, _changeInfo);
    Navigator.of(ctx).pop();
  }

  Future<void> _showDialog(BuildContext context, uid) async {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('닉네임 변경'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('닉네임을 변경하실건가요?'),
              ],
            )
          ),
          actions: <Widget>[ 
            FlatButton(
              child: Text('확인'),
              onPressed: (){
                Navigator.of(context).pop();
                _updateDisplayName(context, uid);
              },
            ),
            FlatButton(
              child: Text('취소'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }  
    );
  }

  String _validateDisplayName(displayName){
    print(displayName);
    bool displayNameValid = RegExp(r"^[ㄱ-ㅎ|가-힣|a-z|A-Z|0-9|\*]+$").hasMatch(displayName);
    if(displayName.isEmpty){
      return '닉네임을 입력해주세요';
    } else if(!displayNameValid) {
      return '닉네임은 특수문자를 입력하실 수 없습니다.';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _displayNameController.text = args['user'].displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 변경'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _displayNameController,
                textAlign: TextAlign.center,
                //initialValue: args['user'].displayName,
                decoration: InputDecoration(
                  labelText: "닉네임",
                  contentPadding: EdgeInsets.all(8),
                ),
                style: TextStyle(
                  fontSize: 18,
                ),
                textInputAction: TextInputAction.send,
                validator: (value) {
                  return _validateDisplayName(value);
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ButtonTheme(
              minWidth: double.infinity,
              height: 40,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  '변경하기',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  _showDialog(context, args['user'].uid);
                },
            )),
          ]
        ),
        
      ),
    );
  }
}