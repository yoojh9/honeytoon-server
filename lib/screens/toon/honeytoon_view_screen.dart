import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:honeytoon/models/current.dart';
import '../../providers/auth_provider.dart';
import '../../providers/my_provider.dart';
import 'package:provider/provider.dart';
import './honeytoon_comment_screen.dart';
import 'package:async/async.dart';

class HoneytoonViewScreen extends StatefulWidget {
  static final routeName = 'honeytoon-view';

  @override
  _HoneytoonViewScreenState createState() => _HoneytoonViewScreenState();
}

class _HoneytoonViewScreenState extends State<HoneytoonViewScreen> with SingleTickerProviderStateMixin{
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  ScrollController _scrollController;
  var _isVisible = true;
  int _currentIndex = 0;
  String userId;
  MyProvider _myProvider;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse && _isVisible){
        setState(() {
          _isVisible = false;
        });
      }
      if(_scrollController.position.userScrollDirection == ScrollDirection.forward && !_isVisible){
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _myProvider = Provider.of<MyProvider>(context, listen: false);

    this._memoizer.runOnce(() async {
      final uid = await AuthProvider.getCurrentFirebaseUserUid();
      setState(() {
        userId = uid;
      });

      Current current = Current(uid: userId, workId: args['id'], contentId: args['contentId'], times: args['times'], updateTime: Timestamp.now());
      await _myProvider.addCurrentHoneytoon(current);
    });

  }

  void _onTap(BuildContext context, String contentId, int index){
    setState(() {
      print(index);
      if(index==1){
        Navigator.of(context).pushNamed(HoneytoonCommentScreen.routeName, arguments: {'id': contentId });
      }
    });
  }

  Widget buildImage(List<String> images){
    if(images!=null){
      return FutureBuilder(
        future: null,
        builder: (context, snapshot) {
          return Container(
            child: Column(
                children: 
                  images.map((image) => CachedNetworkImage(
                    imageUrl: image,
                    placeholder: (context, url) => Image.asset('assets/images/image_spinner.gif'),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover
                  )).toList()
              )
          );
        }
      );
    } else {
      return Container(
        // @TODO
        child: Text('TODO')
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (mediaQueryData.padding.top + mediaQueryData.padding.bottom + 160 );
    final width = mediaQueryData.size.width - (mediaQueryData.padding.left + mediaQueryData.padding.right);

    return Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 30,
              backgroundColor: Colors.transparent,
              floating: false,
              pinned: false,
              leading: IconButton(icon: Icon(Icons.list), onPressed: (){Navigator.of(context).pop();}),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('${args['times']}화', style: TextStyle(fontSize:20),),
              ),
            ),
 
            SliverList(
              delegate: SliverChildListDelegate([
                buildImage(args['images'])
              ])
            )
           
          ]
        ),
        bottomNavigationBar: _buildBottonNavigationBar(width, args['contentId']) 
      );
  }

  Widget _buildBottonNavigationBar(width, contentId){
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: _isVisible ? 60 : 0,
        child: _isVisible
        ? Wrap(
            children: [ BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.arrow_back), title: Text('이전화')),
              BottomNavigationBarItem(icon: Icon(Icons.mode_comment), title: Text('댓글')),
              BottomNavigationBarItem(icon: Icon(Icons.arrow_forward), title: Text('다음화')),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              _onTap(context, contentId, index);
            },
            ),
          ]
        ) 
        : Container(
          color: Colors.transparent,
          width: width
        )
    );
  }
}