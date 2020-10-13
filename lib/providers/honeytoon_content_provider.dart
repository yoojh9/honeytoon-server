import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import 'package:honeytoon/models/point.dart';
import '../models/honeytoonContentItem.dart';
import '../models/honeytoonContent.dart';

class HoneytoonContentProvider extends ChangeNotifier {

  Future<List<HoneytoonContentItem>> getHoneytoonContentList(String toonId) async {
    List<HoneytoonContentItem> _items;

    QuerySnapshot result = await Database.contentRef.doc(toonId).collection('items').orderBy('create_time' ,descending: true).get();
    _items = result.docs
      .map((document) => HoneytoonContentItem.fromMap(document.id, document.data()))
      .toList();

    return _items;
  }

  Future<void> createHoneytoonContent(HoneytoonContent content, String uid) async {
    const point = -10;
    Map data = content.toJson();
    Map pointData = Point(uid: uid, type: PointType.REGIST, point:point, createTime: Timestamp.now()).toJson();

    final DocumentReference _contentReference = Database.contentRef.doc(content.toonId).collection('items').doc();
    final DocumentReference _metaReference = Database.metaRef.doc(content.toonId);
    final DocumentReference _userReference = Database.userRef.doc(uid);
    final DocumentReference _pointReference = Database.pointRef.doc(uid).collection('point').doc();

    await Database.firestore.runTransaction((transaction) async {
       transaction.set(_contentReference, data);
       transaction.update(_metaReference, {'total_count': content.count, 'update_time': Timestamp.now()});
       transaction.update(_userReference, {'honey': FieldValue.increment(-10)});
       transaction.set(_pointReference, pointData);
    }).then((_){
      print('success');
    }).catchError((error){
      print('createHoneytoonContent Error');
      print(error.message);
    });
  }

  Future<void> updateHoneytoonContent(HoneytoonContent content, String uid) async {
    const point = -10;
    Map data = content.toJson();
    Map pointData = Point(uid: uid, type: PointType.REGIST, point:point, createTime: Timestamp.now()).toJson();

    final DocumentReference _contentReference = Database.contentRef.doc(content.toonId).collection('items').doc(content.content.contentId);
    final DocumentReference _metaReference = Database.metaRef.doc(content.toonId);
    final DocumentReference _userReference = Database.userRef.doc(uid);
    final DocumentReference _pointReference = Database.pointRef.doc(uid).collection('point').doc();

    await Database.firestore.runTransaction((transaction) async {
      transaction.update(_contentReference, data);
      transaction.update(_metaReference, {'update_time':Timestamp.now()});
      transaction.update(_userReference, {'honey': FieldValue.increment(-10)});
      transaction.set(_pointReference, pointData);
    }).then((_){
      print('success');
    }).catchError((error){
      print('updateHoneytoonContent Error');
      print(error.message);
    });
  }

  Stream<QuerySnapshot> streamMeta() {
    return Database.contentRef.get().asStream();
  }

  Stream<QuerySnapshot> streamHoneytoonContents(String toonId) {
    return Database.contentRef.doc(toonId).collection('items').orderBy('create_time' ,descending: true).snapshots();
  }

  Future<HoneytoonContentItem> getHoneytoonContentByTimes(String toonId, String times) async {
    HoneytoonContentItem _contentItem;
    QuerySnapshot snapshot =  await Database.contentRef.doc(toonId).collection('items').where('times', isEqualTo: times).get();
    DocumentSnapshot document = snapshot.docs.firstWhere((element) => element['times'] == times);
    _contentItem = HoneytoonContentItem.fromMap(document.id, document.data());
    return _contentItem;
  }
}
