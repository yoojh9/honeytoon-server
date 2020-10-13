
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/coupon_provider.dart';
import './coupon_screen.dart';

class ShoppingItemScreen extends StatefulWidget {
  static final routeName = 'shopping-item';

  @override
  _ShoppingItemScreenState createState() => _ShoppingItemScreenState();
}

class _ShoppingItemScreenState extends State<ShoppingItemScreen> {
  Auth _auth;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    final user = await Provider.of<AuthProvider>(context, listen: false).getUserFromDB();
    setState(() {
      _auth = user;
    });
  }

  bool isPurchaseable(_price){
    int honey = _auth==null? 0 : _auth.honey;
    if(honey >= _price) return true;
    return false;
  }

  void _tapBuyCouponBtn(ctx, product) async {
    if(_auth.honey < product.honey) {
      _showSnackbar(ctx, '해당 상품을 구매할 수 없습니다.');
    } else {
      await Provider.of<CouponProvider>(ctx, listen: false).buyCoupon(_auth, product);
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
    final product = args['product'];
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (kToolbarHeight + kBottomNavigationBarHeight);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      key: _scaffoldKey,
      body: SafeArea(
          child: Column(
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
                        child: Image.network(product.image),
                      ),
                      Column(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '${product.brandName}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('${product.name}'),
                            Text('${product.honey}꿀'),
                          ]
                      )
                    ],
                  )),
              Divider(),
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: Text('${product.content}'))),
            ],
          )
        ),
      bottomNavigationBar: Container(
          color: isPurchaseable(product.honey) ? Theme.of(context).primaryColor : Colors.grey,
          height: kBottomNavigationBarHeight,
          child: InkWell(
              onTap: isPurchaseable(product.honey) ? (){ _tapBuyCouponBtn(context, product); } : null,
              child: Center(
                child: Text('구매하기'),
              ))),
    );
  }
}
