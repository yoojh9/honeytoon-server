import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static final firestore = Firestore.instance;
  static final contentRef = firestore.collection(Collections.CONTENT);
  static final metaRef = firestore.collection(Collections.TOON);
  static final userRef = firestore.collection(Collections.USER);
  static final pointRef = firestore.collection(Collections.POINT);
  static final commentRef = firestore.collection(Collections.COMMENT);
}

class Collections {
  static const TOON = 'toons';
  static const USER = 'users';
  static const CONTENT = 'contents';
  static const POINT = 'points';
  static const COMMENT = 'comments';
}