import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/point.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/login_button_page.dart';
import '../../providers/point_provider.dart';
import './coupon_screen.dart';
import '../../helpers/dateFormatHelper.dart';

class PointScreen extends StatelessWidget {
  void _tapMyCouponBtn(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(CouponScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final height = mediaQueryData.size.height - (kToolbarHeight + kBottomNavigationBarHeight + kTextTabBarHeight);

    return FutureBuilder<Auth>(
        future: Provider.of<AuthProvider>(context).getUserFromDB(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return LoginButtonPage();
          } else {
            return Column(children: [
              Expanded(child: _buildPointHeader(context, height, snapshot.data), flex: 1),
              Expanded(child: _buildPointHistory(context, height, snapshot.data.uid), flex: 1),
            ]);
          }
        });
  }

  SingleChildScrollView _buildPointHistory(context, double height, String uid) {
    PointProvider _pointProvider = Provider.of<PointProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Container(
        child: FutureBuilder(
            future: _pointProvider.getPoints(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (ctx, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _pointTypeImage(snapshot.data[index])
                          )
                          ),
                        title: Text('${snapshot.data[index].point}꿀'),
                        subtitle: Row(children: [
                          _buildPointType(snapshot.data[index], snapshot.data[index].otherDisplayName),
                          Spacer(),
                          Text(
                              '${DateFormatHelper.getDateWithFormat(snapshot.data[index].createTime, 'yyyy-MM-dd')}'),
                        ])),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget _buildPointType(data, otherName) {
    switch (data.type) {
      case PointType.REWARD:
        return Text('출석체크');
        break;
      case PointType.CHEER:
        return Text('응원선물 (from: $otherName)');
        break;
      case PointType.GIFT_SEND:
        return Text('선물하기 (to: $otherName)');
        break;
      case PointType.REGIST:
        return Text('허니툰생성');
      default:
        return null;
    }
  }

  Widget _pointTypeImage(data){
    switch(data.type){
      case PointType.CHEER:
        return Image.asset('assets/images/gift.png');
      case PointType.GIFT_SEND:
        return Image.asset('assets/images/send_gift.png');
        break;
      case PointType.REWARD:
        return Image.asset('assets/images/attend.png');
      case PointType.REGIST:
        return Image.asset('assets/images/pencil.png');
      
    }
  }

  Widget _buildPointHeader(ctx, height, data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      //height: height * 0.4,
      child: Column(children: [
        Expanded(
            flex: 4,
            child: Column(children: [
              Text('나의 꿀단지',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${data.honey == null ? "0" : data.honey}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '꿀',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ])),
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/honey.png'),
                  fit: BoxFit.contain)),
            child: null,
          ),
        ),
        Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsetsDirectional.only(end: 20),
              alignment: Alignment.centerRight,
              child: RaisedButton(
                color: Theme.of(ctx).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Text('내 쿠폰함'),
                onPressed: () {
                  _tapMyCouponBtn(ctx);
                },
              ),
            )),
      ]),
    );
  }
}
