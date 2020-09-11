import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import '../models/point.dart';

class PointProvider extends ChangeNotifier {
  Future<void> setPoint(Point point) async {
    Map data = point.toJson();
    final DocumentReference pointReference =
        Database.pointRef.document(point.uid).collection('point').document();
    final DocumentReference userReference =
        Database.userRef.document(point.uid);

    Database.firestore
        .runTransaction((transaction) async {
          await transaction.set(pointReference, data);
          await transaction.update(
              userReference, {'honey': FieldValue.increment(point.point)});
        })
        .then((value) => {print('success')})
        .catchError((error) {
          print(error.message);
        });
  }

  Future<List<Point>> getPoints(String uid) async {
    List<Point> _points;
    QuerySnapshot snapshot = await Database.pointRef
        .document(uid)
        .collection('point')
        .orderBy('create_time', descending: true)
        .getDocuments();
    _points = snapshot.documents
        .map((document) => Point.fromMap(document.documentID, document.data))
        .toList();
    return _points;
  }

  Stream<QuerySnapshot> streamPoint(String uid) {
    return Database.pointRef
        .document(uid)
        .collection('point')
        .getDocuments()
        .asStream();
  }

  /*
   * to: point를 선물받는 사용자의 uid  
   * from: point를 선물하는 사용자의 uid
   * point: point 값
   */
  Future<void> sendPoint(String to, String from, int point) async {
    print('to:$to');
    final DocumentReference toUserRef =  Database.userRef.document(to);
    final DocumentReference fromUserRef = Database.userRef.document(from);
    final DocumentReference toPointRef = Database.pointRef.document(to).collection('point').document();
    final DocumentReference fromPointRef = Database.pointRef.document(from).collection('point').document();

    Point toPoint = Point(targetUid: to, type: PointType.CHEER, point: point, createTime: Timestamp.now());
    Point fromPoint = Point(targetUid: from, type: PointType.GIFT_SEND, point: -point, createTime: Timestamp.now());

    await Database.firestore
        .runTransaction((transaction) async {
          await transaction.update(toUserRef, {'honey': FieldValue.increment(point)});
          await transaction.update(fromUserRef, {'honey': FieldValue.increment(-point)});
          await transaction.set(toPointRef, toPoint.toJson());
          await transaction.set(fromPointRef, fromPoint.toJson());
        }).then((value) => print('success'))
        .catchError((error) {
          print(error.message);
        });
  }
}
