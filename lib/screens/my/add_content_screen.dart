import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/honeytoon_meta_provider.dart';
import '../../providers/honeytoon_content_provider.dart';
import '../../models/honeytoonContent.dart';
import '../../models/honeytoonContentItem.dart';
import '../../models/auth.dart';
import '../../helpers/storage.dart';
import '../../widgets/cover_img_widget.dart';

class AddContentScreen extends StatefulWidget {
  static final routeName = 'add-content';

  @override
  _AddContentScreenState createState() => _AddContentScreenState();
}

class _AddContentScreenState extends State<AddContentScreen> {
  HoneytoonContentProvider _contentProvider;
  AuthProvider _authProvider;
  HoneytoonMetaProvider _metaProvider;

  int total;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Asset> _images = List<Asset>();
  File _coverImage;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

    _contentProvider = Provider.of<HoneytoonContentProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _metaProvider = Provider.of<HoneytoonMetaProvider>(context, listen: false);

    return Scaffold(
        appBar: _buildAppBar(context, args),
        key: _scaffoldKey,
        body: _buildForm(args)
    );
  }

  Future<void> _submitForm(ctx, args) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    try {
      final id = args['id'];
      Auth _auth =  await _authProvider.getUserFromDB();
      bool _result = await checkPoint(_auth);

      if(!_result){
        _showErrorSnackbar(ctx, '작품을 등록할 포인트가 부족합니다.');
        return;
      }
      Navigator.of(ctx).pop('허니툰 등록 진행중입니다. 잠시 후 다시 확인해주세요');

      final downloadUrl = await Storage.uploadImageToStorage(StorageType.CONTENT_COVER, id, _coverImage);
      final List<String> contentImageList = await uploadContentImage(id, _images);
      final contentItem = HoneytoonContentItem(times: total.toString(), coverImgUrl: downloadUrl, contentImgUrls: contentImageList, createTime: Timestamp.now(), updateTime: Timestamp.now());
      final content = HoneytoonContent(toonId: id, content: contentItem, count: total);
  
      await _contentProvider.createHoneytoonContent(content, _auth.uid);
      
    } catch (error){
      print('error: $error');
      Navigator.of(ctx).pop('허니툰 등록에 실패하였습니다.');
    }
  }

  Future<bool> checkPoint(Auth auth) async {
    if(auth.honey < 10){
      return false;
    }
    return true;
  }


  Future<List<String>> uploadContentImage(id, images) async {
    final contentsImageList = List<String>();
    for(Asset image in images){
      final downloadUrl = await Storage.uploadContentImage(id, image);
      contentsImageList.add(downloadUrl);
    }
    return contentsImageList;
  }


  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: false,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _images = resultList;
    });
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(_images.length, (index) {
        Asset asset = _images[index];
        return AssetThumb(asset: asset, width: 300, height: 300);
      }),
    );
  }

  void setImage(coverImage){
    setState(() {
      _coverImage = coverImage;
    });
  }



  Widget _buildForm(Map<String, dynamic> args){
    return SafeArea(
      child: Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            Expanded(
              flex: 1,
              child: CoverImgWidget(_coverImage, setImage)   
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                future: _metaProvider.getHoneytoonMeta(args['id']),
                builder: (context, snapshot) {  
                  if(snapshot.hasData){
                    var count = snapshot.data.totalCount == 0 ? 1 : (snapshot.data.totalCount+1);
                    total = count;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(snapshot.data.title, style: Theme.of(context).textTheme.headline6),
                        Text('$count 화', style: Theme.of(context).textTheme.subtitle1),
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text('허니툰 선택'),
                          onPressed: loadAssets
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
              ),
            ),
            Expanded(
              flex: 2,
              child: _images.length > 0 ? buildGridView() : SizedBox(),
            )
          ]),
        ),
      )
    );
  }

  AppBar _buildAppBar(BuildContext context, Map<String, dynamic> args) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('회차 등록'),
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
                _showDialog(context, args);
              },
            ),
          )
        ],
      );
  }

  Future<void> _showDialog(BuildContext context, args) async {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('허니툰 등록'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('허니툰을 등록을 하실건가요'),
                Text('꿀단지 10개가 차감됩니다.')
              ],
            )
          ),
          actions: <Widget>[ 
            FlatButton(
              child: Text('확인'),
              onPressed: (){
                Navigator.of(ctx).pop();
                _submitForm(ctx, args);
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

  void _showErrorSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }
}
