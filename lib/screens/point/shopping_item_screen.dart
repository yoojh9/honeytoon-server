
import 'package:flutter/material.dart';
import 'package:honeytoon/models/user.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:honeytoon/providers/product_provider.dart';
import 'package:honeytoon/screens/point/coupon_screen.dart';
import 'package:provider/provider.dart';

class ShoppingItemScreen extends StatefulWidget {
  static final routeName = 'shopping-item';

  @override
  _ShoppingItemScreenState createState() => _ShoppingItemScreenState();
}

class _ShoppingItemScreenState extends State<ShoppingItemScreen> {
  User _user;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    final user = await Provider.of<AuthProvider>(context, listen: false).getUserFromDB();
    setState(() {
      _user = user;
    });
  }

  bool isPurchaseable(_price){
    int honey = _user==null? 0 : _user.honey;
    if(honey >= _price) return true;
    return false;
  }

  void _tapBuyCouponBtn(ctx, code, price) async {
    if(_user.honey < price) {
      _showSnackbar(ctx, '해당 상품을 구매할 수 없습니다.');
    } else {
      await Provider.of<ProductProvider>(ctx, listen: false).buyCoupon(_user, code, price);
       Navigator.of(ctx).pushNamed(CouponScreen.routeName);
    }
  }

  void _showSnackbar(BuildContext context, String message){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (kToolbarHeight + kBottomNavigationBarHeight);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      key: _scaffoldKey,
      body: SafeArea(
          child: FutureBuilder(
              future: Provider.of<ProductProvider>(context)
                  .getProductById(args['id'], args['brandCode']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Text('데이터를 불러오는 데 실패했습니다.'),
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsetsDirectional.only(bottom: 16),
                                height: height * 0.3,
                                alignment: Alignment.center,
                                child: Image.network(snapshot.data.image),
                              ),
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '${snapshot.data.brandName}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('${snapshot.data.name}'),
                                    Text('${snapshot.data.realPrice}원'),
                                  ])
                            ],
                          )),
                      Divider(),
                      Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                              child: Text('${snapshot.data.content}'))),
                    ],
                  );
                }
              }
          )),
      bottomNavigationBar: Container(
          color: isPurchaseable(args['price']) ? Theme.of(context).primaryColor : Colors.grey,
          height: kBottomNavigationBarHeight,
          child: InkWell(
              onTap: isPurchaseable(args['price']) ? (){ _tapBuyCouponBtn(context, args['id'], args['price']); } : null,
              child: Center(
                child: Text('구매하기'),
              ))),
    );
  }
}
