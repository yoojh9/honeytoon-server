import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:honeytoon/models/coupon.dart';
import 'package:honeytoon/providers/coupon_provider.dart';
import 'package:honeytoon/screens/point/coupon_detail_screen.dart';
import 'package:honeytoon/widgets/login_button_page.dart';
import 'package:provider/provider.dart';

class CouponScreen extends StatefulWidget {
  static final routeName = 'coupon-screen';

  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  CouponProvider _couponProvider;
  List<Coupon> _notUsedCoupons = [];
  List<Coupon> _usedCoupons = [];

  @override
  void initState() {
    super.initState();
    _getCouponList();
  }

  void _getCouponList() async {
    final user = await FirebaseAuth.instance.currentUser();
    List<Coupon> coupons = await _couponProvider.getCouponList(user.uid);
    List<Coupon> notUsed = List<Coupon>();
    List<Coupon> used = List<Coupon>();

    for(Coupon coupon in coupons){
      if(coupon.use == 'N') notUsed.add(coupon);
      else used.add(coupon);
    }

    setState(() {
      _notUsedCoupons = notUsed;
      _usedCoupons = used;
    });
  }

  void _useCoupon(ctx, coupon){
    Navigator.of(ctx).pushNamed(CouponDetailScreen.routeName, arguments: {'coupon': coupon});
  }



  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (mediaQueryData.padding.top + mediaQueryData.padding.bottom + 50);
    _couponProvider = Provider.of<CouponProvider>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('내 쿠폰함'),
        ),
        body: StreamBuilder<FirebaseUser>(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (!snapshot.hasData) {
                return LoginButtonPage();
              } else {
                return _buildCouponList(context);
              }
            }));
  }


  Widget _buildCouponList(BuildContext context){
    return SafeArea(
      child: SingleChildScrollView(
          child: Column(children: [
        Container(
          padding:
              EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text('미사용 쿠폰'),
          alignment: Alignment.centerLeft,
        ),
        _notUsedCoupons.length == 0 
        ? Container(
          margin: EdgeInsets.only(bottom: 50),
          child: Center(
            child: Text('미사용 쿠폰이 없습니다'),
          ),
        )

        : ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: ClipRRect(
                child: Image.network(_notUsedCoupons[index].goodsImage),
              ),
              title: Text(_notUsedCoupons[index].goodsName),
              subtitle: Text('${_notUsedCoupons[index].validDate}까지'),
              trailing:
                  FlatButton(onPressed: (){_useCoupon(context, _notUsedCoupons[index]);}, child: Text('사용하기')),
            ),
          ),
          itemCount: _notUsedCoupons.length,
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Text('사용 완료 | 유효기간 만료'),
          alignment: Alignment.centerLeft,
        ),
        _usedCoupons.length == 0 ? 
        Center(
            child: Text('사용 완료 또는 유효기간이 만료된 쿠폰이 없습니다')
        )
        : ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: ClipRRect(
                child: Image.network(
                  _usedCoupons[index].goodsImage,
                  color: Colors.grey[50],
                  colorBlendMode: BlendMode.color,
                ),
              ),
              title: Text(
                _usedCoupons[index].goodsName,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              subtitle: Text('${_usedCoupons[index].validDate}까지'),
              trailing:
                  FlatButton(onPressed: (){_useCoupon(context, _usedCoupons[index]);}, child: Text('사용하기')),
            ),
          ),
          itemCount: _usedCoupons.length,
        ),
      ])),
    );
  }
}
