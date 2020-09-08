import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/honeytoon_meta_provider.dart';
import '../../helpers/storage.dart';
import '../../models/honeytoonMeta.dart';
import '../../widgets/cover_img_widget.dart';

class AddContentMetaScreen extends StatefulWidget {
  static final routeName = 'add-contentmeta';

  @override
  _AddContentMetaScreenState createState() => _AddContentMetaScreenState();
}

class _AddContentMetaScreenState extends State<AddContentMetaScreen> {
  HoneytoonMetaProvider _metaProvider; 
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _coverImage;
  var honeytoonMeta = HoneytoonMeta();
  final _descriptionFocusNode = FocusNode();

  Future<void> _submitForm(BuildContext ctx) async {
    try {
      final user = await FirebaseAuth.instance.currentUser();
      final _isValid = _formKey.currentState.validate();
      
      if (!_isValid){
        _showSnackbar(ctx, '작품 제목과 작품 설명을 모두 입력해주세요');
        return;
      }

      if(_coverImage==null){
        _showSnackbar(ctx, '커버이미지를 등록해주세요');
        return;
      }

      _formKey.currentState.save();

      Navigator.of(ctx).pop('작품 등록이 진행중입니다. 작품은 잠시 후 추가됩니다.');

      String downloadUrl = await Storage.uploadImageToStorage(StorageType.META_COVER, user.uid, _coverImage);
      honeytoonMeta.coverImgUrl = downloadUrl;
      honeytoonMeta.displayName = user.displayName;
      honeytoonMeta.uid = user.uid;
      honeytoonMeta.createTime = Timestamp.now();
      honeytoonMeta.totalCount = 0;
      honeytoonMeta.likes = 0;

      await _metaProvider.createHoneytoonMeta(honeytoonMeta);

    } catch (error) {
      print('add content meta error : ${error}');
      Navigator.of(ctx).pop('작품 등록에 실패했습니다.');
    }

  }

  void setImage(coverImage){
    setState(() {
      _coverImage = coverImage;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + mediaQueryData.padding.top + mediaQueryData.padding.bottom);
    _metaProvider = Provider.of<HoneytoonMetaProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset : false,
      key: _scaffoldKey,
      appBar: _buildAppbar(),
      body: _buildBody(height)
    );
  }

  Widget _buildAppbar(){
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('작품 추가'),
      actions: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: 16),
          child: GestureDetector(
            child: Text(
              '완료',
              textScaleFactor: 1.5,
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              _submitForm(context);
            },
          ),
        )
      ],
    );
  }

  Widget _buildBody(height){
    return SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: '작품 제목',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '작품 명을 입력해주세요';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  honeytoonMeta.title = value;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                  alignLabelWithHint: true, hintText: '작품 설명'),
                validator: (value) {
                  if (value.isEmpty) {
                    return '작품 설명을 입력해주세요';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  honeytoonMeta.description = value;
                },
              ),
              SizedBox(height: 30),
              Container(
                height: height * 0.25,
                child: CoverImgWidget(_coverImage, setImage)
              ),
            ]),
          ),
        )
    );
  }

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message))
    );
  }
}
