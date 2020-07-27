import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import '../models/honeytoonMeta.dart';

class HoneytoonMetaProvider extends ChangeNotifier {

  List<HoneytoonMeta> _metaList;

  Future<List<HoneytoonMeta>> getHoneytoonMetaList() async {
    QuerySnapshot result = await Database.metaRef.getDocuments();
    _metaList = result.documents
        .map((document) =>
            HoneytoonMeta.fromMap(document.data, document.documentID))
        .toList();
    return _metaList;
  }

  Future<HoneytoonMeta> getHoneytoonMeta(String id) async {
    DocumentSnapshot snapshot = await Database.metaRef.document(id).get();
    HoneytoonMeta honeytoonMeta = HoneytoonMeta.fromMap(snapshot.data, snapshot.documentID);
    return honeytoonMeta;
  }

  Future<void> createHoneytoonMeta(HoneytoonMeta meta) async {
    Map data = meta.toJson();
    final DocumentReference metaReference = Database.metaRef.document();
    final DocumentReference userReference = Database.userRef.document(meta.uid);

    Database.firestore.runTransaction((transaction) async {
      await transaction.set(metaReference, data);
      await transaction.update(userReference, {'works':  FieldValue.arrayUnion([metaReference.documentID]) });
    }).then((_){
      print('success');
    }).catchError((error){
      print(error.message);
    });
  }

  Future<void> updateHoneytoonMeta(HoneytoonMeta meta) async {
    Map data = meta.toJson();
     await Database.metaRef.document(meta.workId).updateData(data);
  }

  Stream<QuerySnapshot> streamMeta() {
    return Database.metaRef.getDocuments().asStream();
  }
}
