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
    if(brandCode!=null){
      QuerySnapshot snapshot = await Database.productRef.document(brandCode).collection('product').getDocuments();
      _products = snapshot.documents
          .map((document) => Product.fromMap(document.documentID, document.data))
          .toList();
      print('product : $_products');
    }
    return _products;
  }

  Future<Product> getProductById(id, brandCode) async {
    Product _product;
    DocumentSnapshot snapshot = await Database.productRef.document(brandCode).collection('product').document(id).get();
    _product = Product.fromMap(snapshot.documentID, snapshot.data);
    return _product;
  }

  Future<void> buyCoupon(user, code, price) async {
    try {
      final trid = getGiftishowTransactionId(user.uid);
      final userRef = Database.userRef.document(user.uid);
      final couponRef = Database.couponRef.document(user.uid).collection('coupons').document(trid);
      final pointRef = Database.pointRef.document(user.uid).collection('point').document();
      await couponRef.setData({'goods_code': code, 'success':'', 'response': '', 'create_time': Timestamp.now()});

      http.Response response = await requestSendCoupon(code, trid);

      final body = jsonDecode(response.body);

      if(response.statusCode == 200) {
        Database.firestore.runTransaction((transaction) async {
          
          final data = body['result']['result'];
          print('data : $data');
          await transaction.update(couponRef, {'success':'Y', 'response': {'orderNo': data['orderNo'], 'pinNo': data['pinNo'], 'couponImgUrl': data['couponImgUrl']}});
          await transaction.update(userRef, {'honey': FieldValue.increment(-(price))});
          await transaction.set(pointRef, {'create_time': Timestamp.now(), 'point': -price, 'type': 2});
        });
      } else {
        await couponRef.updateData({'success':'N', 'response': body['result']});
      }


    } catch(error){
      print('error: ${error}');
    }
  }

  Future<http.Response> requestSendCoupon(code, trid) async {
    const url = 'https://bizapi.giftishow.com/bizApi/send';
    print('code:$code');

    final response = await http.post(url,
      headers: {
        'custom_auth_code': GIFTISHOW_CUSTOM_AUTH_CODE,
        'custom_auth_token': GIFTISHOW_CUSTOM_AUTH_TOKEN,
        'api_code':'0204',
        'dev_yn': 'N',
      },
      body: setSendCouponData(code, trid)
    );
    print(response);
    print(response.statusCode);
    
    // {"code":"0000","message":null,"result":{"code":"0000","message":null,"result":{"orderNo":"20200828674875","pinNo":"900811088247","couponImgUrl":"https://imgs.giftishow.co.kr/Resource2/mms/20200828/10/mms_956ba394892708c19b28cf4f482e44b2_01.jpg"}}}
    print(response.body);
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
