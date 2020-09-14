import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../screens/auth_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/my_provider.dart';
import './honeytoon_current_item.dart';

class HoneytoonCurrentScreen extends StatefulWidget {
  @override
  _HoneytoonCurrentScreenState createState() => _HoneytoonCurrentScreenState();
}

class _HoneytoonCurrentScreenState extends State<HoneytoonCurrentScreen> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  MyProvider _myProvider;
  String userId;

  @override
  void initState() {
    super.initState();

    this._memoizer.runOnce(() async {
      final uid = await AuthProvider.getCurrentFirebaseUserUid();
      setState(() {
        userId = uid;
      });
    });
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
        future: _myProvider.getCurrentHoneytoon(userId),
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
                child: CurrentToonItem(height: height, data: snapshot.data[index], uid: userId,),
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
              child: Text('아직 최근 본 허니툰이 없습니다. 허니툰을 구경해보세요'),
            );
          }

        }
    );
  }
}

