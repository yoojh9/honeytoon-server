import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/storage.dart';
import 'package:honeytoon/models/user.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:honeytoon/screens/template_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AuthJoinScreen extends StatefulWidget {
  static final routeName = 'join-screen';

  @override
  _AuthJoinScreenState createState() => _AuthJoinScreenState();
}

class _AuthJoinScreenState extends State<AuthJoinScreen> {
  AuthProvider _authProvider;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  File _thumbnail;
  final _descriptionFocusNode = FocusNode();
  var user = User();
  bool _isLoading = false;
  bool _disposed = false;

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

  void _submitForm(BuildContext ctx) async {
    print('submitForm');
    AuthResult authResult;
    try {
      final _isValid = _formKey.currentState.validate();
      if (!_isValid) return;

      if (!_disposed) {
        setState(() {
          _isLoading = true;
        });
      }
      _formKey.currentState.save();
      authResult = await _authProvider.createUserWithEmailAndPassword(user);
      String thumbnailUrl = await Storage.uploadImageToStorage(
          StorageType.USER_THUMBNAIL, authResult.user.uid, _thumbnail);
      user.thumbnail = thumbnailUrl;

      await _authProvider.addUserToDB(authResult, 'EMAIL', user);
      if (!_disposed) {
        setState(() {
          _isLoading = false;
        });
      }

      Navigator.of(ctx).pushNamed(TemplateScreen.routeName);
    } catch (error) {
      print(error);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('회원가입에 실패했습니다. 입력하신 정보를 확인해주세요'),
          duration: Duration(seconds: 2)));
    }
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('회원가입')),
        body: _isLoading
            ? Container(
                child: Center(child: CircularProgressIndicator()),
              )
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: Form(
                            key: _formKey,
                            child: Column(children: [
                              _thumbnail == null
                                  ? GestureDetector(
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/avatar_placeholder.png'),
                                        radius: 50,
                                      ),
                                      onTap: _getImage,
                                    )
                                  : GestureDetector(
                                      child: CircleAvatar(
                                        backgroundImage: FileImage(_thumbnail),
                                        radius: 50,
                                      ),
                                      onTap: _getImage,
                                    ),
                              TextFormField(
                                decoration: InputDecoration(labelText: "닉네임"),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_descriptionFocusNode);
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '닉네임을 입력해주세요';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  user.displayName = value;
                                },
                              ),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_descriptionFocusNode);
                                },
                                decoration: InputDecoration(
                                  labelText: "이메일",
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '이메일을 입력해주세요';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  user.email = value;
                                },
                              ),
                              TextFormField(
                                controller: _password,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(labelText: "비밀번호"),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_descriptionFocusNode);
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '비밀번호를 입력해주세요';
                                  } else if (value.length < 7) {
                                    return '비밀번호는 7자리 이상 입력해주세요';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  user.password = value;
                                },
                              ),
                              TextFormField(
                                controller: _confirmPassword,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                decoration:
                                    InputDecoration(labelText: "비밀번호 확인"),
                                focusNode: _descriptionFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_descriptionFocusNode);
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '비밀번호를 입력해주세요';
                                  } else if (value != _password.text) {
                                    return '비밀번호를 다시 확인해주세요';
                                  } else {
                                    return null;
                                  }
                                },
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
                                      '회원가입',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () {
                                      _submitForm(context);
                                    },
                                  )),
                            ]),
                          )),
                    )
                  ],
                ),
              ));
  }
}
