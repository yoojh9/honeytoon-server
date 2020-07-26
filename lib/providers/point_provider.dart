import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/collections.dart';
import '../models/point.dart';

class PointProvider extends ChangeNotifier {
  static final _firestore = Firestore.instance;
  static final _pointRef = _firestore.collection(Collections.POINT);
  static final _userRef = _firestore.collection(Collections.USER);

  Future<void> setPoint(Point point) async {
    Map data = point.toJson();
    final DocumentReference pointReference =
        _pointRef.document(point.uid).collection('point').document();
    final DocumentReference userReference = _userRef.document(point.uid);

    _firestore
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
        await _pointRef.document(uid).collection('point').getDocuments();
    print(snapshot.documents.length);
    _points = snapshot.documents
        .map((document) => Point.fromMap(document.documentID, document.data))
        .toList();
    print('_points:${_points}');
    return _points;
  }

  Stream<QuerySnapshot> streamPoint(String uid) {
    return _pointRef
        .document(uid)
        .collection('point')
        .getDocuments()
        .asStream();
  }
}
