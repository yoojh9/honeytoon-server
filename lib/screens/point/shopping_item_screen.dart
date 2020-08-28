import 'package:flutter/material.dart';
import 'package:honeytoon/providers/auth_provider.dart';
import 'package:honeytoon/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ShoppingItemScreen extends StatelessWidget {
  static final routeName = 'shopping-item';

  void _tapBuyCouponBtn(ctx, code) async {
    final uid = await AuthProvider.getCurrentFirebaseUserUid();
    await Provider.of<ProductProvider>(ctx, listen: false).buyCoupon(uid, code);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height -
        (kToolbarHeight + kBottomNavigationBarHeight);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
          child: FutureBuilder(
              future: Provider.of<ProductProvider>(context)
                  .getProductById(args['id']),
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
              })),
      bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          height: kBottomNavigationBarHeight,
          child: InkWell(
              onTap: (){ _tapBuyCouponBtn(context, args['id']); },
              child: Center(
                child: Text('구매하기'),
              ))),
    );
  }
}
