import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import '../models/point.dart';

class PointProvider extends ChangeNotifier {

  Future<void> setPoint(Point point) async {
    Map data = point.toJson();
    final DocumentReference pointReference =
        Database.pointRef.document(point.uid).collection('point').document();
    final DocumentReference userReference = Database.userRef.document(point.uid);

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
    QuerySnapshot snapshot =
        await Database.pointRef.document(uid).collection('point').orderBy('create_time' ,descending: true).getDocuments();
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
}
