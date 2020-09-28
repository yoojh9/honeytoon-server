import 'package:flutter/material.dart';
import './add_contentmeta_screen.dart';
import '../auth/auth_screen.dart';
import '../../widgets/my_honeytoon_listview.dart';
import '../../widgets/my_honeytoon_info.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HoneytoonMyScreen extends StatefulWidget {
  @override
  _HoneytoonMyScreenState createState() => _HoneytoonMyScreenState();
}

class _HoneytoonMyScreenState extends State<HoneytoonMyScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _loginPage(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(AuthScreen.routeName);
  }

  void _navigateToAddContentMetaPage(BuildContext ctx) async{
    var result = await Navigator.of(ctx).pushNamed(AddContentMetaScreen.routeName);
    if(result!=null){
     _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(result), duration: Duration(seconds: 2),));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (mediaQueryData.padding.top + mediaQueryData.padding.bottom + 50);

    return FutureBuilder(
        future:
            Provider.of<AuthProvider>(context, listen: false).getUserFromDBwithRank(),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (futureSnapshot.hasData) {
            return Scaffold(
              key: _scaffoldKey,
              body: SingleChildScrollView(
                child: Column(children: [
                  MyHonetoonInfo(height: height, user: futureSnapshot.data),
                  FlatButton.icon(
                    icon: Icon(
                      Icons.add,
                      color: Colors.grey,
                    ),
                    label: Text(
                      '작품 추가',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      _navigateToAddContentMetaPage(context);
                    },
                  ),
                  MyHoneytoonListView(height: height, uid: futureSnapshot.data.uid, scaffoldKey: _scaffoldKey),
                ]),
              ),
            );
          } else {
            return Scaffold(
                body: Center(
              child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text('로그인'),
                  onPressed: () => _loginPage(context)),
            ));
          }
        });
  }
}
