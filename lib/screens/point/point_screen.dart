import 'package:flutter/material.dart';
import 'package:honeytoon/models/point.dart';
import 'package:honeytoon/models/user.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:honeytoon/widgets/login_button_page.dart';
import '../../providers/point_provider.dart';
import 'package:provider/provider.dart';
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

    return FutureBuilder<User>(
        future: Provider.of<AuthProvider>(context).getUserFromDB(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return LoginButtonPage();
          } else {
            return Column(children: [
              _buildPointHeader(context, height, snapshot.data),
              _buildPointHistory(context, height, snapshot.data.uid)
            ]);
          }
        });
  }

  SingleChildScrollView _buildPointHistory(context, double height, String uid) {
    PointProvider _pointProvider =
        Provider.of<PointProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Container(
        height: height * 0.5,
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
                            child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset('assets/images/honey_pot.png',),
                        )),
                        title: Text('${snapshot.data[index].point}꿀'),
                        subtitle: Row(children: [
                          _buildPointType(snapshot.data[index]),
                          Spacer(),
                          Text(
                              '${DateFormatHelper.getDate(snapshot.data[index].createTime)}'),
                        ])),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget _buildPointType(data) {
    switch (data.type) {
      case PointType.REWARD:
        return Text('출석체크');
        break;
      case PointType.CHEER:
        return Text('응원선물');
        break;
      case PointType.GIFT:
        return Text('선물전달');
        break;
      case PointType.REGIST:
        return Text('허니툰생성');
      default:
        return null;
    }
  }

  Widget _buildPointHeader(ctx, height, data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      height: height * 0.4,
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
                  '${data.honey}',
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
                  image: AssetImage('assets/images/honey_pot.png'),
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
