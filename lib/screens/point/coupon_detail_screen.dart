import 'package:flutter/material.dart';

class CouponDetailScreen extends StatelessWidget {
  static final routeName = 'coupon-detail';

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height - (kToolbarHeight + kBottomNavigationBarHeight);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('내 쿠폰함'),
        ),
        body: 
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: height * 0.7,        
                    alignment: Alignment.center,
                    child: Image.network('https://imgs.giftishow.co.kr/Resource2/mms/20200901/10/mms_8e82f75faebfeddda857bf34d5164013_01.jpg'),
                  ),
                  Divider(),
                  Text('쿠폰은 교환, 환불, 연장이 불가능합니다', style: TextStyle(color: Colors.red),),
                  Divider(),
                  Text('▶상품설명시원한 커피와 카라멜 시럽이 조화를 이루며 그위에 휘핑크림을 얹고 달콤한 카라멜로 장식한 커피 음료▶유의사항- 상기 이미지는 연출된 것으로 실제와 다를 수 있습니다.- 본 상품은 매장 재고 상황에 따라 동일 상품으로 교환이 불가능할 수 있습니다.- 동일 상품 교환이 불가능한 경우 동일 가격 이상의 다른 상품으로 교환이 가능하며 차액은 추가 지불하여야 합니다.- 정식 판매처 외의 장소나 경로를 통하여 구매하거나 기타의 방법으로 보유하신 쿠폰은 사용이 금지/제한될 수 있으니 주의하시기 바랍니다.- 해당 쿠폰과 스타벅스 카드의 복합결제 거래는 스타벅스 카드의 고유혜택인 Free Extra 적용대상이 아닌 점 이용에 참고하시기 바랍니다.- 해당 쿠폰 거래시 스타벅스 카드의 고유혜택인 별적립 적용대상이 아닌 점 이용에 참고하시기 바랍니다.- 스타벅스 앱의 사이렌 오더를 통해서도 주문 및 결제가 가능합니다.▶사용불가매장미군부대 매장(오산AB, 평택험프리, 대구캠프워커, 군산AB, 캠프케롤, 캠프케이시, 평택험프리 트룹몰, 평택험프리 메인몰), 오션월드점')
              ]),
            ),
          // Expanded(
          //   flex: 1,
          //   child: SingleChildScrollView(
          //             child: Text('▶상품설명시원한 커피와 카라멜 시럽이 조화를 이루며 그위에 휘핑크림을 얹고 달콤한 카라멜로 장식한 커피 음료▶유의사항- 상기 이미지는 연출된 것으로 실제와 다를 수 있습니다.- 본 상품은 매장 재고 상황에 따라 동일 상품으로 교환이 불가능할 수 있습니다.- 동일 상품 교환이 불가능한 경우 동일 가격 이상의 다른 상품으로 교환이 가능하며 차액은 추가 지불하여야 합니다.- 정식 판매처 외의 장소나 경로를 통하여 구매하거나 기타의 방법으로 보유하신 쿠폰은 사용이 금지/제한될 수 있으니 주의하시기 바랍니다.- 해당 쿠폰과 스타벅스 카드의 복합결제 거래는 스타벅스 카드의 고유혜택인 Free Extra 적용대상이 아닌 점 이용에 참고하시기 바랍니다.- 해당 쿠폰 거래시 스타벅스 카드의 고유혜택인 별적립 적용대상이 아닌 점 이용에 참고하시기 바랍니다.- 스타벅스 앱의 사이렌 오더를 통해서도 주문 및 결제가 가능합니다.▶사용불가매장미군부대 매장(오산AB, 평택험프리, 대구캠프워커, 군산AB, 캠프케롤, 캠프케이시, 평택험프리 트룹몰, 평택험프리 메인몰), 오션월드점'))
          // )

    );
  }
}