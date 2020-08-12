import 'package:flutter/material.dart';

class ShoppingItemScreen extends StatelessWidget {
  static final routeName = 'shopping-item';

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + kBottomNavigationBarHeight);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0
      ),
      body: SafeArea(child: Column(
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
                  child: Image.network('https://biz.giftishow.com/Resource/goods/G00000008077/G00000008077.jpg',
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('스타벅스', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Text('아이스 카페아메리카노 Tall'),
                    Text('4100원'),
                  ]
                )
                
            ],)
          ),
          Divider(),
          Expanded(
            flex:1,
            child: SingleChildScrollView(child: Text('▶상품설명 \n 스타벅스의 깔끔한 맛을 자랑하는 커피로, 스타벅스 파트너들이 가장 좋아하는 커피입니다. \n\n ▶유의사항 \n - 상기 이미지는 연출된 것으로 실제와 다를 수 있습니다. \n - 본 상품은 매장 재고 상황에 따라 동일 상품으로 교환이 불가능할 수 있습니다. \n - 동일 상품 교환이 불가능한 경우 동일 가격 이상의 다른 상품으로 교환이 가능하며 차액은 추가 지불하여야 합니다. \n - 정식 판매처 외의 장소나 경로를 통하여 구매하거나 기타의 방법으로 보유하신 쿠폰은 사용이 금지/제한될 수 있으니 주의하시기 바랍니다. \n - 해당 쿠폰과 스타벅스 카드의 복합결제 거래는 스타벅스 카드의 고유혜택인 Free Extra 적용대상이 아닌 점 이용에 참고하시기 바랍니다. \n - 해당 쿠폰 거래시 스타벅스 카드의 고유혜택인 별적립 적용대상이 아닌 점 이용에 참고하시기 바랍니다. \n - 스타벅스 앱의 사이렌 오더를 통해서도 주문 및 결제가 가능합니다. \n\n ▶사용불가매장 \n 미군부대 매장(오산AB, 평택험프리, 대구캠프워커, 군산AB, 캠프케롤, 캠프케이시, 평택험프리 트룹몰, 평택험프리 메인몰), 오션월드점')),
          ),
        ],
      ),
    ),
    bottomNavigationBar: Container(
      color: Theme.of(context).primaryColor,
      height: kBottomNavigationBarHeight,
      child: InkWell(
        onTap: (){},
        child: Center(
          child: Text('구매하기'),
        )
      )
    ),
  );
  }
}