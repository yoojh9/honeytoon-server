import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honeytoon/models/auth.dart';
import 'package:honeytoon/models/coupon.dart';
import '../helpers/database.dart';
import '../helpers/dateFormatHelper.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class CouponProvider extends ChangeNotifier {
  static const GIFTISHOW_CUSTOM_AUTH_CODE='REAL78856b57de224f218d645fdc5d8a81eb';
  static const GIFTISHOW_CUSTOM_AUTH_TOKEN='qJL+ZRqaawDtRI4zY8Frvg==';

  /*
   * 쿠폰 구매
   */
  Future<void> buyCoupon(Auth auth, Product product) async {
    try {
      final trid = getGiftishowTransactionId(auth.uid);
      final userRef = Database.userRef.doc(auth.uid);
      final couponRef = Database.couponRef.doc(auth.uid).collection('coupons').doc(trid);
      final pointRef = Database.pointRef.doc(auth.uid).collection('point').doc();
      
      await couponRef.set({'goods_code': product.code, 'goods_name': product.name, 'goods_image': product.image, 'goods_content': product.content, 'success':'', 'create_time': Timestamp.now(), 'use': 'N'});

      http.Response response = await requestSendCoupon(product.code, trid);
      final body = jsonDecode(response.body);

      if(response.statusCode == 200) {
        final couponInfo = await requestCouponInfo(trid); // 발행한 쿠폰 정보 조회
        final validDate = DateFormatHelper.convertDateTimeToDate(couponInfo['validPrdEndDt']);

        await FirebaseFirestore.instance.runTransaction((transaction) async {        
          final data = body['result']['result'];
          transaction.update(couponRef, {'success':'Y','orderNo': data['orderNo'], 'pinNo': data['pinNo'], 'couponImgUrl': data['couponImgUrl'], 'validDate': validDate});
          transaction.update(userRef, {'honey': FieldValue.increment(-(product.honey))});
          transaction.set(pointRef, {'create_time': Timestamp.now(), 'point': -product.honey, 'type': 2});
        });
      } else {
        await couponRef.update({'success':'N', 'response': body['result']});
      }
    } catch(error){
      print('error: ${error}');
    }
  }

  /*
    쿠폰 조회
   */
  Future<List<Coupon>> getCouponList(uid) async{
    List<Coupon> _coupons;
    final couponRef = Database.couponRef.doc(uid).collection('coupons');
    QuerySnapshot snapshot = await couponRef.get();
    _coupons = snapshot.docs.map((document) => Coupon.fromMap(document.id, document.data())).toList();
    return _coupons;
  }

  dynamic requestCouponInfo(trid) async {
    const url = 'https://bizapi.giftishow.com/bizApi/coupons';
    final response = await http.post(url,
      headers: {
        'custom_auth_code': GIFTISHOW_CUSTOM_AUTH_CODE,
        'custom_auth_token': GIFTISHOW_CUSTOM_AUTH_TOKEN,
        'api_code':'0201',
        'dev_yn': 'N',
      },
      body: setCouponInfoData(trid)
    );
    final body = jsonDecode(response.body);
    print('body: ${body['result'][0]['couponInfoList'][0]}');
    return body['result'][0]['couponInfoList'][0];
  }

  Future<http.Response> requestSendCoupon(code, trid) async {
    const url = 'https://bizapi.giftishow.com/bizApi/send';

    final response = await http.post(url,
      headers: {
        'custom_auth_code': GIFTISHOW_CUSTOM_AUTH_CODE,
        'custom_auth_token': GIFTISHOW_CUSTOM_AUTH_TOKEN,
        'api_code':'0204',
        'dev_yn': 'N',
      },
      body: setSendCouponData(code, trid)
    );
    return response;
  }

  Map<String, dynamic> setSendCouponData(code, trid) {
    Map map = Map<String, dynamic>();
    map['api_code'] = '0204';
    map['custom_auth_code'] = GIFTISHOW_CUSTOM_AUTH_CODE;
    map['custom_auth_token'] = GIFTISHOW_CUSTOM_AUTH_TOKEN;
    map['dev_yn'] = 'N';
    map['goods_code'] = code;
    map['mms_msg'] = '기프티콘';
    map['mms_title'] = '기프티콘';
    map['callback_no'] = '01090730150';
    map['phone_no'] = '01090730150';
    map['tr_id'] = trid;
    map['user_id'] = 'yoojh9@gmail.com';
    map['gubun'] = 'I';
  
    return map;
  }

  Map<String, dynamic> setCouponInfoData(trid){
    Map map = Map<String, dynamic>();
    map['api_code'] = '0201';
    map['custom_auth_code'] = GIFTISHOW_CUSTOM_AUTH_CODE;
    map['custom_auth_token'] = GIFTISHOW_CUSTOM_AUTH_TOKEN;
    map['dev_yn'] = 'N';
    map['tr_id'] = trid;

    return map;
  }

  String getGiftishowTransactionId(uid){
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random random = Random(DateTime.now().millisecondsSinceEpoch);
    String randomStr = '';

    for(var i=0; i<7; i++){
      randomStr += chars[random.nextInt(chars.length)];
    }

    return 'coupon_'+DateFormatHelper.getDate(Timestamp.now())+'_'+randomStr;
  }
}