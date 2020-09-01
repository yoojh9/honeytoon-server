import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/dateFormatHelper.dart';
import 'package:http/http.dart' as http;
import '../helpers/database.dart';
import '../models/product.dart';
import '../models/brand.dart';

class ProductProvider extends ChangeNotifier {
  static const GIFTISHOW_CUSTOM_AUTH_CODE='REAL78856b57de224f218d645fdc5d8a81eb';
  static const GIFTISHOW_CUSTOM_AUTH_TOKEN='qJL+ZRqaawDtRI4zY8Frvg==';

  Future<List<Brand>> getBrands() async {
    List<Brand> _brands;
    QuerySnapshot snapshot = await Database.brandRef.getDocuments();
    _brands = snapshot.documents.map((document) => Brand.fromMap(document.documentID, document.data))
      .toList();
    return _brands;
  }

  Future<List<Product>> getProducts(brandCode) async {
    List<Product> _products;
    if(brandCode!=null && brandCode!=""){
      QuerySnapshot snapshot = await Database.productRef.document(brandCode).collection('product').getDocuments();
      _products = snapshot.documents
          .map((document) => Product.fromMap(document.documentID, document.data))
          .toList();
    }
    return _products;
  }

  Future<Product> getProductById(id, brandCode) async {
    Product _product;
    DocumentSnapshot snapshot = await Database.productRef.document(brandCode).collection('product').document(id).get();
    _product = Product.fromMap(snapshot.documentID, snapshot.data);
    return _product;
  }

  /*
   * 쿠폰 구매
   */
  Future<void> buyCoupon(user, Product product) async {
    try {
      final trid = getGiftishowTransactionId(user.uid);
      final userRef = Database.userRef.document(user.uid);
      final couponRef = Database.couponRef.document(user.uid).collection('coupons').document(trid);
      final pointRef = Database.pointRef.document(user.uid).collection('point').document();
      
      await couponRef.setData({'goods_code': product.code, 'goods_name': product.name, 'success':'', 'response': '', 'create_time': Timestamp.now()});

      http.Response response = await requestSendCoupon(product.code, trid);
      final body = jsonDecode(response.body);

      if(response.statusCode == 200) {
        final couponInfo = await requestCouponInfo(trid); // 발행한 쿠폰 정보 조회
        final validDate = DateFormatHelper.convertDateTimeToDate(couponInfo['validPrdEndDt']);

        Database.firestore.runTransaction((transaction) async {        
          final data = body['result']['result'];

          await transaction.update(couponRef, {'success':'Y', 'response': {'orderNo': data['orderNo'], 'pinNo': data['pinNo'], 'couponImgUrl': data['couponImgUrl'], 'validDate': validDate, 'use': 'N'}});
          await transaction.update(userRef, {'honey': FieldValue.increment(-(product.realPrice))});
          await transaction.set(pointRef, {'create_time': Timestamp.now(), 'point': -product.realPrice, 'type': 2});
        });
      } else {
        await couponRef.updateData({'success':'N', 'response': body['result']});
      }
    } catch(error){
      print('error: ${error}');
    }
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
