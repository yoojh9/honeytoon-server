
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/storage.dart';
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
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) return;

    var _changeInfo = Map<String, dynamic>();
    if(_displayName!=null){
      _changeInfo['displayName'] = _displayName;
    } 
    if(_thumbnail!=null) {
      String thumbnailUrl = await Storage.uploadImageToStorage(StorageType.USER_THUMBNAIL, uid, _thumbnail);
      _changeInfo['thumbnail'] = thumbnailUrl;
    }

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
      appBar: AppBar(
        title: Text('프로필 변경'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FlatButton(onPressed: (){_updateUserProfile(context);}, child: Text('변경', style: TextStyle(fontSize: 18),))
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<AuthProvider>(context, listen: false).getUserFromDB(),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
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
            print(futureSnapshot.data.displayName);
            uid = futureSnapshot.data.uid;
            return Container(
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
                                imageUrl: futureSnapshot.data.thumbnail,
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
                      textAlign: TextAlign.center,
                      initialValue: futureSnapshot.data.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87
                      ),
                      textInputAction: TextInputAction.send,
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
                  // SizedBox(
                  //   height: 30,
                  // ),
                  // ButtonTheme(
                  //   minWidth: double.infinity,
                  //   height: 40,
                  //   child: RaisedButton(
                  //     color: Theme.of(context).primaryColor,
                  //     child: Text('변경하기',style: TextStyle(fontSize: 16),),
                  //     onPressed: () {
                  //       //_showDialog(context, args['user'].uid);
                  //     },
                  // )),
              ),
      );
      }
    }
   )
  );
  }
}