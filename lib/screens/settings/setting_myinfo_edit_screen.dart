
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../helpers/storage.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_screen.dart';
import './setting_myinfo_screen.dart';


class SettingMyInfoEditScreen extends StatefulWidget {
  static const routeName = 'setting-myinfo-edit';

  @override
  _SettingMyInfoEditScreenState createState() => _SettingMyInfoEditScreenState();
}

class _SettingMyInfoEditScreenState extends State<SettingMyInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
  File _thumbnail;
  String _displayName;
  Auth _auth;
  String _thumbnailUrl;
  var _loading = false;


  @override
  void initState(){
    super.initState();
    _getUserInfo();
    print(_auth);
  }

  void _getUserInfo() async {
    final user = await Provider.of<AuthProvider>(context, listen: false).getUserFromDB();
    setState(() {
      _auth = user;
      _thumbnailUrl = user.thumbnail;
      _displayName = user.displayName;
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
    try {
      final uid = _auth.uid;
      final _isValid = _formKey.currentState.validate();
      if (!_isValid) return;
      _formKey.currentState.save();

      var _changeInfo = Map<String, dynamic>();
      if(_displayName!=null){
        _changeInfo['displayName'] = _displayName;
      } 
      setState(() {
        _loading = true;
      });
      if(_thumbnail!=null) {
        String thumbnailUrl = await Storage.uploadImageToStorage(StorageType.USER_THUMBNAIL, uid, _thumbnail);
        _changeInfo['thumbnail'] = thumbnailUrl;
        _thumbnailUrl = thumbnailUrl;
      }
      await Provider.of<AuthProvider>(ctx, listen: false).changeUserInfo(uid, _changeInfo);
      Navigator.of(ctx).pushReplacementNamed(SettingMyinfoScreen.routeName);
    } catch(error){
      print(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _navigateToPage(BuildContext ctx){
    if(_displayName == null || _thumbnailUrl==null){
      _showSnackbar(ctx, '프로필 정보를 입력해주세요');
      return;
    }
    Navigator.of(ctx).pop();
  }

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);

    //final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    //_displayNameController.text = args['user'].displayName;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('프로필 변경'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){_navigateToPage(context);}),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FlatButton(onPressed: (){_updateUserProfile(context);}, child: Text('변경', style: TextStyle(fontSize: 18),))
        ],
      ),
      body: 
        _auth == null 
          ? Center(
            child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('로그인'),
                onPressed: () => _loginPage(context)),
          )
          : _loading 
            ? Center(child: CircularProgressIndicator(),)
            : _buildMyInfoForm(height)
  );
  }

  Widget _buildMyInfoForm(height){
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
                      _auth.thumbnail == null 
                      ? CircleAvatar(
                        backgroundImage: AssetImage('assets/images/avatar_placeholder.png'),
                        radius: 50,
                      )

                      : ClipOval(
                        child: CachedNetworkImage(
                          height: height * 0.15,
                          width: height * 0.15,
                          imageUrl: _auth.thumbnail,
                          placeholder: (context, url) => Image.asset('assets/images/avatar_placeholder.png',),
                          errorWidget: (context, url, error) => Image.asset('assets/images/avatar_placeholder.png'),
                          fit: BoxFit.cover,
                        )
                      )
                    :
                    ClipOval(
                      child: Image.file(_thumbnail, fit: BoxFit.cover, height: height * 0.15, width: height*0.15),
                    ),
                    onTap: _getImage,
                  ),
              ),

              TextFormField(
                initialValue: _displayName == null ? _auth.displayName: _displayName,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87
                ),
                maxLength: 7,
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
    );
  }
}