
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/storage.dart';
import 'package:honeytoon/models/user.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:honeytoon/screens/auth/auth_screen.dart';
import 'package:honeytoon/screens/settings/setting_myinfo_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingMyInfoEditScreen extends StatefulWidget {
  static const routeName = 'setting-myinfo-edit';

  @override
  _SettingMyInfoEditScreenState createState() => _SettingMyInfoEditScreenState();
}

class _SettingMyInfoEditScreenState extends State<SettingMyInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String uid;
  File _thumbnail;
  String _displayName;
  User _user;

  @override
  void initState(){
    super.initState();
    _getUserInfo();
    print(_user);
  }

  void _getUserInfo() async {
    final user = await Provider.of<AuthProvider>(context, listen: false).getUserFromDB();
    setState(() {
      _user = user;
    });
  }

  //String _displayName;

  Future _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    _thumbnail = File(pickedFile.path);
    _setImage(_thumbnail);
  }

  void _setImage(thumbnail) {
    setState(() {
      _thumbnail = thumbnail;
    });
  }


  Future<void> _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
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

  void _updateUserProfile(BuildContext ctx) async {
    print('_updateUserProfile');
    final uid = _user.uid;
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) return;
    _formKey.currentState.save();

    var _changeInfo = Map<String, dynamic>();
    if(_displayName!=null){
      _changeInfo['displayName'] = _displayName;
    } 
    if(_thumbnail!=null) {
      String thumbnailUrl = await Storage.uploadImageToStorage(StorageType.USER_THUMBNAIL, uid, _thumbnail);
      _changeInfo['thumbnail'] = thumbnailUrl;
    }
    print(_changeInfo);
    await Provider.of<AuthProvider>(ctx, listen: false).changeUserInfo(uid, _changeInfo);
    Navigator.of(ctx).pushReplacementNamed(SettingMyinfoScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);

    //final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    //_displayNameController.text = args['user'].displayName;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('프로필 변경'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FlatButton(onPressed: (){_updateUserProfile(context);}, child: Text('변경', style: TextStyle(fontSize: 18),))
        ],
      ),
      body: 
        _user == null ? Center(
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('로그인'),
              onPressed: () => _loginPage(context)),
        )
        :
           Container(
              height: height * 0.35,
              margin: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: height * 0.15,
                      child: GestureDetector(
                          child: _thumbnail == null ? 
                            ClipOval(
                              child: CachedNetworkImage(
                                height: height * 0.15,
                                width: height * 0.15,
                                imageUrl: _user.thumbnail,
                                placeholder: (context, url) => Image.asset('assets/images/avatar_placeholder.png',),
                                errorWidget: (context, url, error) => Image.asset('assets/images/avatar_placeholder.png'),
                                fit: BoxFit.cover,
                              )
                            )
                          :
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(_thumbnail),
                            //radius: 50,
                          ),
                          onTap: _getImage,
                        ),
                    ),

                    TextFormField(
                      initialValue: _displayName == null ? _user.displayName: _displayName,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87
                      ),
                      validator: (value) {
                        return _validateDisplayName(value);
                      },
                      onSaved: (value){
                        _displayName = value;
                      },
                    ),
                    Text('프로필 사진과 닉네임을 입력해주세요.', style: TextStyle(color: Colors.grey),)
                  ]
                  )
              ),
      )
  );
  }
}