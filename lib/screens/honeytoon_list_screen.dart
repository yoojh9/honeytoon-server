import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/honeytoonMeta.dart';
import '../providers/honeytoon_meta_provider.dart';
import './honeytoon_detail_screen.dart';
import '../widgets/honeytoon_list_header.dart';
import '../widgets/honeytoon_list_sort.dart';


class HoneyToonListScreen extends StatefulWidget {
  static final routeName = 'list';
  final Stream<String> stream;
  
  HoneyToonListScreen({this.stream});

  @override
  _HoneyToonListScreenState createState() => _HoneyToonListScreenState();
}

class _HoneyToonListScreenState extends State<HoneyToonListScreen> {
  var sort = 1;
  String _keyword = '';
  StreamSubscription _subscription;
  HoneytoonMetaProvider _metaProvider;
  List<dynamic> _metaList = [];

  @override
  void initState() {
    setState(() {
      sort = 1;
    });
    _subscribe();
    super.initState();
  }

  void _subscribe(){
    if(widget.stream != null){
      _subscription = widget.stream.listen((keyword){
        _changeKeyword(keyword);
      });
    }
  }

  void _unsubscribe(){
    if(_subscription!=null){
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _toggleSort(_sort){
    setState(() {
      sort = _sort;
      _keyword = '';
    });
  }

  void _changeKeyword(keyword){
    print('_changeKeyword');
    setState(() {
      _keyword = keyword;
    });
    print('setState()');
  }

  @override
  Widget build(BuildContext context) {
    _metaProvider = Provider.of<HoneytoonMetaProvider>(context);

    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (kToolbarHeight +
            kBottomNavigationBarHeight +
            mediaQueryData.padding.top +
            mediaQueryData.padding.bottom);

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              HoneytoonListHeader(height: height),
              HoneytoonListSort(toggleSort: _toggleSort),
              _buildHoneytoonList(height)
            ])),
      ),
    );
  }

  Widget _buildHoneytoonList(height){
    return  Container(
      margin: EdgeInsets.only(top: 16),
      height: height * 0.6,
      child: StreamBuilder(
          stream: _metaProvider.streamMeta(sort, _keyword),
          builder: (context, snapshot) {
            print(snapshot);
            print(snapshot.data);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData &&
                snapshot.data.documents.length > 0) {
                  _metaList = snapshot.data.documents
                    .map((item) => HoneytoonMeta.fromMap(item.data, item.documentID))
                    .toList();

              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 8 / 10
                  ),
                  itemCount: _metaList.length,
                  itemBuilder: (_, index) {
                    return _buildHoneytoonItem(index);
                  }
              );
            } else {
              return Center(
                child: Text('허니툰을 불러오는 데 실패했습니다. 잠시 후 다시 시도해주세요'));
            }
          }),
    );
  }

  Widget _buildHoneytoonItem(index){
    return GestureDetector(
      onTap: (){Navigator.of(context).pushNamed(HoneytoonDetailScreen.routeName, 
        arguments: {'id': _metaList[index].workId, 'uid': _metaList[index].uid});
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: _metaList[index].coverImgUrl,
                placeholder: (context, url) => Image.asset(
                    'assets/images/image_spinner.gif'),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            "${_metaList[index].title}",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 12)),
                        Text(
                          "${_metaList[index].displayName}",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey),
                        )
                      ],
                    )))
            ],
          ),
      ),
    );
  }
}
