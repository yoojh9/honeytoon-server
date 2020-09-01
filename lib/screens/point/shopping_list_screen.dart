import 'package:flutter/material.dart';
import 'package:honeytoon/providers/product_provider.dart';
import 'package:provider/provider.dart';
import './shopping_item_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  ProductProvider _productProvider;
  var _brandCode = '';
  var _brandList = [];


  @override
  void initState() {
    super.initState();
    _getBrandList();
  }

  void _getBrandList() async {
    final brandList = await Provider.of<ProductProvider>(context, listen: false).getBrands();
    setState(() {
      _brandList = brandList;
      _brandCode = brandList[0].code;
    });
  }

  void _changeBrandCode(code){
    setState(() {
      _brandCode = code;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    _productProvider = Provider.of<ProductProvider>(context);

    return Container(
      child: Column(children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: false,
            itemCount: _brandList == null? 0 : _brandList.length ,
            itemBuilder: (ctx, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: GestureDetector(
                  onTap: (){ _changeBrandCode('${_brandList[index].code}');},
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                            child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network('${_brandList[index].brandIconImg}'),
                        )),
                        Text('${_brandList[index].name}')
                      ]),
                ),
              );
            }
          )
        ),
        Expanded(
            flex: 5,
            child: FutureBuilder(
                future: _productProvider.getProducts(_brandCode),
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
                    return ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(ctx).pushNamed(
                                      ShoppingItemScreen.routeName,
                                      arguments: {
                                        'product': snapshot.data[index],
                                      });
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                        '${snapshot.data[index].image}'),
                                  )),
                                  title: Row(children: [
                                    Text('${snapshot.data[index].brandName}'),
                                    Spacer(),
                                    Text('${snapshot.data[index].realPrice}원'),
                                  ]),
                                  subtitle:
                                      Text('${snapshot.data[index].name}'),
                                ),
                              ),
                            ));
                  }
                }))
      ]),
    );
  }
}
