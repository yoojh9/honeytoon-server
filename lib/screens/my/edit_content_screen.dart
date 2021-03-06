import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/models/auth.dart';
import 'package:honeytoon/providers/honeytoon_meta_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/honeytoon_content_provider.dart';
import '../../models/honeytoonContent.dart';
import '../../models/honeytoonContentItem.dart';
import '../../helpers/storage.dart';
import '../../widgets/cover_img_widget.dart';

class EditContentScreen extends StatefulWidget {
  static final routeName = 'edit-content';

  @override
  _EditContentScreenState createState() => _EditContentScreenState();
}

class _EditContentScreenState extends State<EditContentScreen> {
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
      final contentId = args['content_id'];
      Auth _auth =  await _authProvider.getUserFromDB();
      bool _result = await checkPoint(_auth);
      HoneytoonContentItem contentItem = HoneytoonContentItem(times: total.toString(), contentId: contentId, updateTime: Timestamp.now());

      if(!_result){
        _showErrorSnackbar(ctx, '작품을 등록할 포인트가 부족합니다.');
        return;
      }
      Navigator.of(ctx).pop('허니툰 등록 진행중입니다. 잠시 후 다시 확인해주세요');

      if(_coverImage!=null){
        final downloadUrl = await Storage.uploadImageToStorage(StorageType.CONTENT_COVER, id, _coverImage);
        contentItem.coverImgUrl = downloadUrl;
      }

      if(_images.length>0){
        final contentImageList = await uploadContentImage(id, _images);
        contentItem.contentImgUrls = contentImageList;
      }

      final content = HoneytoonContent(toonId: id, content: contentItem);
  
      await _contentProvider.updateHoneytoonContent(content, _auth.uid);

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

  Future _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if(pickedFile!=null){
      File coverImage = File(pickedFile.path);
      setImage(coverImage);
    }
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
              child: _coverImage!=null 
                ? CoverImgWidget(_coverImage, setImage)   
                : GestureDetector(
                    onTap: _getImage,
                      child: AspectRatio(
                        aspectRatio: 1 / 1 ,
                        child: CachedNetworkImage(
                          imageUrl: args['cover_img'],
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: imageProvider, fit:BoxFit.cover)
                            ) ,
                          ),
                          placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    )
                  ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                future: _metaProvider.getHoneytoonMeta(args['id']),
                builder: (context, snapshot) {  
                  if(snapshot.hasData){
                    var count = snapshot.data.totalCount;
                    total = count;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(snapshot.data.title, style: Theme.of(context).textTheme.headline6),
                        Text('$count 화', style: Theme.of(context).textTheme.subtitle1),
                        Text('회차 내용을 변경하려면 허니툰 변경 버튼을 눌러 추가해주세요'),
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text('허니툰 변경'),
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
              child: _images.length > 0 ? buildGridView() : Container(),
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
        title: Text('회차 변경'),
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
          title: Text('허니툰 변경'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('허니툰을 변경을 하실건가요'),
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
