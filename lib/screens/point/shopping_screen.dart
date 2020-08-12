import 'package:flutter/material.dart';

class ShoppingScreen extends StatelessWidget {
  final test_data = [
    {'name': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/brand/BR_20140605_164826_3.jpg'},
    {'name': '투썸플레이스', 'img': 'https://biz.giftishow.com/Resource/brand/20190819_095358914.jpg'},
    {'name': '이디야커피', 'img': 'https://biz.giftishow.com/Resource/brand/20180326_113355154.jpg'},
    {'name': '커피빈', 'img': 'https://biz.giftishow.com/Resource/brand/20161130_172005195.jpg'},
    {'name': '폴바셋', 'img': 'https://biz.giftishow.com/Resource/brand/20190416_175254764.jpg'},
  ];
  final test_product = [
    {'name': '카페아메리카노 Tall', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000008072/G00000008072.jpg', 'price': 3440},
    {'name': '아이스 카페아메리카노 Tall', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000008077/G00000008077.jpg', 'price': 3440},
    {'name': '달콤한 디저트 세트', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000261112/G00000261112.jpg', 'price': 9210},
    {'name': '아이스 카페라떼 Tall', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000008084/G00000008084.jpg', 'price': 4320},
    {'name': '시원한 아메리카노 커플세트', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000460706/G00000460706.jpg', 'price': 7700},
    {'name': '부드러운 디저트 세트', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000261108/G00000261108.jpg', 'price': 11930},
    {'name': '아이스 자몽 허니 블랙티', 'brand': '스타벅스', 'img': 'https://biz.giftishow.com/Resource/goods/G00000251701/G00000251701.jpg', 'price': 4980},


  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children:[
          Expanded(
            flex: 1,
            child: 
                ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: false,
                itemCount: test_data.length,
                itemBuilder: (ctx, index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(test_data[index]['img']),
                        )
                      ),
                      Text('${test_data[index]['name']}')
                    ]
                  ),
                ),
              )
          ),
          Expanded(
            flex: 5,
            child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: test_product.length,
                  itemBuilder: (ctx, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        leading: CircleAvatar(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(test_product[index]['img']),
                          )
                        ),
                        title: Row(children: [
                          Text('${test_product[index]['brand']}'),
                          Spacer(),
                          Text('${test_product[index]['price']}원'),
                          ]
                        ),
                        subtitle: Text('${test_product[index]['name']}'),
                  ),
                )
            )
          )
        ]
      ),
    );
  }
}