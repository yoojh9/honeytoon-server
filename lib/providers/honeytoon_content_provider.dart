import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import 'package:honeytoon/models/point.dart';
import '../models/honeytoonContentItem.dart';
import '../models/honeytoonContent.dart';

class HoneytoonContentProvider extends ChangeNotifier {

  Future<List<HoneytoonContentItem>> getHoneytoonContentList(String toonId) async {
    List<HoneytoonContentItem> _items;

    QuerySnapshot result = await Database.contentRef.document(toonId).collection('items').orderBy('create_time' ,descending: true).getDocuments();
    _items = result.documents
      .map((document) => HoneytoonContentItem.fromMap(document.documentID, document.data))
      .toList();

    return _items;
  }

  Future<void> createHoneytoonContent(HoneytoonContent content, String uid) async {
    const point = -10;
    Map data = content.toJson();
    Map pointData = Point(uid: uid, type: PointType.REGIST, point:point, createTime: Timestamp.now()).toJson();

    final DocumentReference _contentReference = Database.contentRef.document(content.toonId)
        .collection('items').document();
    final DocumentReference _metaReference = Database.metaRef.document(content.toonId);
    final DocumentReference _userReference = Database.userRef.document(uid);
    final DocumentReference _pointReference = Database.pointRef.document(uid).collection('point').document();

    Database.firestore.runTransaction((transaction) async {
      await transaction.set(_contentReference, data);
      await transaction.update(_metaReference, {'total_count': content.count});
      await transaction.update(_userReference, {'honey': FieldValue.increment(-10)});
      await transaction.set(_pointReference, pointData);
    }).then((_){
      print('success');
    }).catchError((error){
      print('createHoneytoonContent Error');
      print(error.message);
    });
  }

  // Future<void> updateHoneytoonMeta(HoneytoonMeta meta) async {
  //   Map data = meta.toJson();
  //   DocumentReference document = await _api.updateDocument(meta.workId, data);
  // }

  Stream<QuerySnapshot> streamMeta() {
    return Database.contentRef.getDocuments().asStream();
  }

  Stream<QuerySnapshot> streamHoneytoonContents(String toonId) {
    return Database.contentRef.document(toonId).collection('items').orderBy('create_time' ,descending: true).snapshots();
  }

  Future<HoneytoonContentItem> getHoneytoonContentByTimes(String toonId, String times) async {
    HoneytoonContentItem _contentItem;
    QuerySnapshot snapshot =  await Database.contentRef.document(toonId).collection('items').where('times', isEqualTo: times).getDocuments();
    DocumentSnapshot document = snapshot.documents.firstWhere((element) => element['times'] == times);
    _contentItem = HoneytoonContentItem.fromMap(document.documentID, document.data);
    return _contentItem;
  }
}
