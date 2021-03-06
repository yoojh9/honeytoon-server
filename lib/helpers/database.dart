import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static final firestore = FirebaseFirestore.instance;
  static final contentRef = firestore.collection(Collections.CONTENT);
  static final metaRef = firestore.collection(Collections.TOON);
  static final userRef = firestore.collection(Collections.USER);
  static final pointRef = firestore.collection(Collections.POINT);
  static final commentRef = firestore.collection(Collections.COMMENT);
  static final myRef = firestore.collection(Collections.MY);
  static final brandRef = firestore.collection(Collections.BRAND);
  static final productRef = firestore.collection(Collections.PRODUCT);
  static final couponRef = firestore.collection(Collections.COUPON);
}

class Collections {
  static const TOON = 'toons';
  static const USER = 'users';
  static const CONTENT = 'contents';
  static const POINT = 'points';
  static const COMMENT = 'comments';
  static const MY = 'my';
  static const BRAND = 'brands';
  static const PRODUCT = 'products';
  static const COUPON = 'coupon';
}
