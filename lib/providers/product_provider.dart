import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/database.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  static const GIFTISHOW_CUSTOM_AUTH_CODE='REAL78856b57de224f218d645fdc5d8a81eb';
  static const GIFTISHOW_CUSTOM_AUTH_TOKEN='qJL+ZRqaawDtRI4zY8Frvg==';

  Future<List<Product>> getProducts() async {
    List<Product> _products;
    QuerySnapshot snapshot = await Database.productRef.getDocuments();
    _products = snapshot.documents
        .map((document) => Product.fromMap(document.documentID, document.data))
        .toList();
    return _products;
  }

  Future<Product> getProductById(id) async {
    Product _product;
    DocumentSnapshot snapshot = await Database.productRef.document(id).get();
    _product = Product.fromMap(snapshot.documentID, snapshot.data);
    return _product;
  }

  Future<void> buyCoupon(uid, code) async {
    try {
      final ref = Database.couponRef.document(uid).collection('coupons').document('service_20200828_12345677');
      await ref.setData({'goods_code': code, 'success':'', 'response': ''});
      http.Response response = await requestSendCoupon(code);
      final result = jsonDecode(response.body);
      await ref.updateData({'success': (response.statusCode == 200 ?'Y':'N'), 'response': result.result});
    } catch(error){
      print('error: ${error}');
    }
  }

  Future<http.Response> requestSendCoupon(code) async {
    const url = 'https://bizapi.giftishow.com/bizApi/send';
    Map data = setSendCouponData(code);
    print('code:$code');

    final response = await http.post(url,
      headers: {
        'custom_auth_code': GIFTISHOW_CUSTOM_AUTH_CODE,
        'custom_auth_token': GIFTISHOW_CUSTOM_AUTH_TOKEN,
        'api_code':'0204',
        'dev_yn': 'N',
      },
      body: setSendCouponData(code)
    );
    print(response);
    print(response.statusCode);
    
    // {"code":"0000","message":null,"result":{"code":"0000","message":null,"result":{"orderNo":"20200828674875","pinNo":"900811088247","couponImgUrl":"https://imgs.giftishow.co.kr/Resource2/mms/20200828/10/mms_956ba394892708c19b28cf4f482e44b2_01.jpg"}}}
    print(response.body);
    return response;
  }

  Map<String, dynamic> setSendCouponData(code) {
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
    map['tr_id'] = 'service_20200828_12345679';
    map['user_id'] = 'yoojh9@gmail.com';
    map['gubun'] = 'I';
  
    return map;
  }
}
