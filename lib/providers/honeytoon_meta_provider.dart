import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import 'package:honeytoon/helpers/storage.dart';
import '../models/honeytoonMeta.dart';

class HoneytoonMetaProvider extends ChangeNotifier {
  List<HoneytoonMeta> _metaList;

  Future<List<HoneytoonMeta>> getHoneytoonMetaList(type, keyword) async {
    String sortType = type == 1 ? 'create_time' : 'likes';
    List<HoneytoonMeta> _metaList;
    QuerySnapshot listSnapshot = (keyword == null || keyword == "") ? 
      await Database.metaRef.orderBy(sortType, descending: true).getDocuments() :
      await Database.metaRef.where('title', isEqualTo: keyword).getDocuments();

    _metaList = await Future.wait(listSnapshot.documents.map((item) async {
      DocumentSnapshot userSnapshot = await Database.userRef.document(item.data['uid']).get();
      return HoneytoonMeta.fromMapWithAuthor(item.documentID, item.data, userSnapshot.data);
    }).toList());

    return _metaList;
  }

  Future<List<HoneytoonMeta>> getMyHoneytoonMetaList(String uid) async {
    QuerySnapshot result = await Database.metaRef.getDocuments();
    _metaList = result.documents
        .map((document) =>
            HoneytoonMeta.fromMap(document.data, document.documentID))
        .where((data) => data.uid == uid)
        .toList();
    return _metaList;
  }

  Stream<QuerySnapshot> getMyHoneytoonStream(String uid) {
    return Database.metaRef
        .where('uid', isEqualTo: uid).snapshots();
  }

  Future<HoneytoonMeta> getHoneytoonMeta(String id) async {
    DocumentSnapshot metaSnapshot = await Database.metaRef.document(id).get();
    String authorId = metaSnapshot.data['uid'];
    DocumentSnapshot userSnapshot = await Database.userRef.document(authorId).get();
    HoneytoonMeta honeytoonMeta =
        HoneytoonMeta.fromMapWithAuthor(metaSnapshot.documentID, metaSnapshot.data, userSnapshot.data);
    return honeytoonMeta;
  }

  Future<void> createHoneytoonMeta(HoneytoonMeta meta) async {
    Map data = meta.toJson();
    final DocumentReference metaReference = Database.metaRef.document();
    final DocumentReference userReference = Database.userRef.document(meta.uid);

    Database.firestore.runTransaction((transaction) async {
      await transaction.set(metaReference, data);
      await transaction.update(userReference, {
        'works': FieldValue.arrayUnion([metaReference.documentID])
      });
    }).then((_) {
      print('success');
    }).catchError((error) {
      print(error.message);
    });
  }

  Future<void> updateHoneytoonMeta(HoneytoonMeta meta) async {
    Map data = meta.toJson();
    await Database.metaRef.document(meta.workId).updateData(data);
  }

  Stream<QuerySnapshot> streamMeta(type, keyword) {
    String sortType = type == 1 ? 'create_time' : 'likes';

    if (keyword == null || keyword == "") {
      return Database.metaRef
          .orderBy(sortType, descending: true)
          .getDocuments()
          .asStream();
    } else {
      return Database.metaRef
          .where('title', isEqualTo: keyword)
          .getDocuments()
          .asStream();
    }
  }

  Future<void> deleteHoneytoon(HoneytoonMeta meta) {
    final contentsRef = Database.contentRef.document(meta.workId).collection('items');
    final commentRef = Database.commentRef;
    final userRef = Database.userRef.document(meta.uid);

    try {
      Database.firestore.runTransaction((transaction) async {
        await transaction.delete(Database.metaRef.document(meta.workId));
        await transaction.update(userRef, {'works': FieldValue.arrayRemove([meta.workId])});

        await Storage.deleteImageFromStorage(meta.coverImgUrl);

        final items = await contentsRef.getDocuments();

        for(var item in items.documents){
          final contentImgUrls = item.data['content_imgs'];
          for(String contentImgUrl in contentImgUrls){
            await Storage.deleteImageFromStorage(contentImgUrl);
          }
          final coverImg = item.data['cover_img'];
          if(coverImg!=null) {
            await Storage.deleteImageFromStorage(coverImg);
          }
          await transaction.delete(contentsRef.document(item.documentID));
          await transaction.delete(commentRef.document(item.documentID));
        }
      });
      print('success');
    } catch(error){
      print(error);
    }

  }
}
