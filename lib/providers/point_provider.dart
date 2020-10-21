import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import '../models/point.dart';

class PointProvider extends ChangeNotifier {

  /*
   * 포인트 정보 업데이트
   */
  Future<void> setPoint(Point point) async {
    Map data = point.toJson();
    final DocumentReference pointReference = Database.pointRef.doc(point.uid).collection('point').doc();
    final DocumentReference userReference = Database.userRef.doc(point.uid);

    Map<String, dynamic> honeyData = Map<String, dynamic>();
    honeyData['honey'] = FieldValue.increment(point.point);
    if(PointType.REWARD == point.type){
      honeyData['earned_honey'] = FieldValue.increment(point.point);
    }

    Database.firestore.runTransaction((transaction) async {
      transaction.set(pointReference, data);
      transaction.update(userReference, honeyData);
    })
    .then((_) => {print('success')})
    .catchError((error) {
      print('error');
      print(error.message);
    });
  }

  /*
   * 포인트 이력 조회
   */
  Future<List<Point>> getPoints(String uid) async {
    List<Point> _points;
    QuerySnapshot pointSnapshot = await Database.pointRef.doc(uid).collection('point').orderBy('create_time', descending: true).get();

    _points = await Future.wait(pointSnapshot.docs.map((point) async {
      PointType _pointType = PointType.values[point.data()['type']];
      if(_pointType == PointType.GIFT_SEND || _pointType == PointType.CHEER){
        DocumentSnapshot userSnapshot = await Database.userRef.doc(point.data()['otherUid']).get();
        return Point.fromMapWithUser(point.id, point.data(), userSnapshot.data());
      } else {
        return Point.fromMap(point.id, point.data());
      }
    }).toList());

    return _points;
  }

  Stream<QuerySnapshot> streamPoint(String uid) {
    return Database.pointRef.doc(uid).collection('point').get().asStream();
  }

  /*
   * to: point를 선물받는 사용자의 uid  
   * from: point를 선물하는 사용자의 uid
   * point: point 값
   */
  Future<void> sendPoint(String to, String from, int point) async {
    final DocumentReference toUserRef =  Database.userRef.doc(to);
    final DocumentReference fromUserRef = Database.userRef.doc(from);
    final DocumentReference toPointRef = Database.pointRef.doc(to).collection('point').doc();
    final DocumentReference fromPointRef = Database.pointRef.doc(from).collection('point').doc();

    Point toPoint = Point(otherUid: from, type: PointType.CHEER, point: point, createTime: Timestamp.now());
    Point fromPoint = Point(otherUid: to, type: PointType.GIFT_SEND, point: -point, createTime: Timestamp.now());

    await Database.firestore.runTransaction((transaction) async {
      transaction.update(toUserRef, {'honey': FieldValue.increment(point), 'earned_honey': FieldValue.increment(point)});
      transaction.update(fromUserRef, {'honey': FieldValue.increment(-point)});
      transaction.set(toPointRef, toPoint.toJson());
      transaction.set(fromPointRef, fromPoint.toJson());
    }).then((value) => print('success'))
    .catchError((error) {
      print(error.message);
    });
  }
}
