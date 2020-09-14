import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../screens/auth_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/my_provider.dart';
import './honeytoon_favorite_item.dart';

class HoneytoonFavoriteScreen extends StatefulWidget {
  @override
  _HoneytoonFavoriteScreenState createState() => _HoneytoonFavoriteScreenState();
}

class _HoneytoonFavoriteScreenState extends State<HoneytoonFavoriteScreen> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  Future future;
  MyProvider _myProvider;
  String userId;
  bool _disposed = false;

  @override
  void initState() {
    this._memoizer.runOnce(() async {
      final uid = await AuthProvider.getCurrentFirebaseUserUid();
      if(!_disposed){
        setState(() {
          userId = uid;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose(){
    _disposed = true;
    super.dispose();
  }

  Future<void> _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (mediaQueryData.padding.top + mediaQueryData.padding.bottom);
    _myProvider = Provider.of<MyProvider>(context, listen: false);

    return 
      userId == null 
      ? Center(
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('로그인'),
              onPressed: () => _loginPage(context)),
        )
      : 

      FutureBuilder(
        future: _myProvider.getLikeHoneytoon(userId),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data!=null && snapshot.data.length > 0){
          return  SingleChildScrollView(
            child: 
            ListView.builder(
              itemCount: snapshot.data.length,
              primary: false,
              shrinkWrap: true,
              itemBuilder: (ctx, index) => 
                Padding(padding: const EdgeInsets.all(16),
                child: FavoriteToonItem(height: height, data: snapshot.data[index], uid: userId,),
              ),
            )
          );
          } else if(snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              )
            );
          } else {
            return Center(
              child: Text('아직 관심툰이 없습니다. 관심툰을 추가해보세요'),
            );
          }

        }
    );
  }
}

