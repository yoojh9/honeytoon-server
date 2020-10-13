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
    QuerySnapshot listSnapshot = (keyword == null || keyword == "") 
      ? await Database.metaRef.orderBy(sortType, descending: true).get() 
      : await Database.metaRef.where('title', isEqualTo: keyword).get();

    _metaList = await Future.wait(listSnapshot.docs.map((item) async {
      DocumentSnapshot userSnapshot = await Database.userRef.doc(item.data()['uid']).get();
      return HoneytoonMeta.fromMapWithAuthor(item.id, item.data(), userSnapshot.data());
    }).toList());

    return _metaList;
  }

  Future<List<HoneytoonMeta>> getMyHoneytoonMetaList(String uid) async {
    QuerySnapshot result = await Database.metaRef.get();
    _metaList = result.docs
        .map((document) => HoneytoonMeta.fromMap(document.data(), document.id))
        .where((data) => data.uid == uid)
        .toList();
    return _metaList;
  }

  Stream<QuerySnapshot> getMyHoneytoonStream(String uid) {
    return Database.metaRef
        .where('uid', isEqualTo: uid).snapshots();
  }

  Future<HoneytoonMeta> getHoneytoonMeta(String id) async {
    DocumentSnapshot metaSnapshot = await Database.metaRef.doc(id).get();
    String authorId = metaSnapshot.data()['uid'];
    DocumentSnapshot userSnapshot = await Database.userRef.doc(authorId).get();
    HoneytoonMeta honeytoonMeta =
        HoneytoonMeta.fromMapWithAuthor(metaSnapshot.id, metaSnapshot.data(), userSnapshot.data());
    return honeytoonMeta;
  }

  Future<void> createHoneytoonMeta(HoneytoonMeta meta) async {
    Map data = meta.toJson();
    final DocumentReference metaReference = Database.metaRef.doc();
    final DocumentReference userReference = Database.userRef.doc(meta.uid);

    await Database.firestore.runTransaction((transaction) async {
      transaction.set(metaReference, data);
      transaction.update(userReference, {
        'works': FieldValue.arrayUnion([metaReference.id])
      });
    }).then((_) {
      print('success');
    }).catchError((error) {
      print(error.message);
    });
  }

  Future<void> updateHoneytoonMeta(HoneytoonMeta meta) async {
    Map data = meta.toJson();
    await Database.metaRef.doc(meta.workId).update(data);
  }

  Stream<QuerySnapshot> streamMeta(type, keyword) {
    String sortType = type == 1 ? 'create_time' : 'likes';
    if (keyword == null || keyword == "") {
      return Database.metaRef
        .orderBy(sortType, descending: true)
        .get()
        .asStream();
    } else {
      return Database.metaRef
        .where('title', isEqualTo: keyword)
        .get()
        .asStream();
    }
  }

  Future<void> deleteHoneytoon(HoneytoonMeta meta) async {
    final contentsRef = Database.contentRef.doc(meta.workId).collection('items');
    final commentRef = Database.commentRef;
    final userRef = Database.userRef.doc(meta.uid);

    await Database.firestore.runTransaction((transaction) async {
      transaction.delete(Database.metaRef.doc(meta.workId));
      transaction.update(userRef, {'works': FieldValue.arrayRemove([meta.workId])});
      await Storage.deleteImageFromStorage(meta.coverImgUrl);
      
      final items = await contentsRef.get();
      for(var item in items.docs){
        final contentImgUrls = item.data()['content_imgs'];
        for(String contentImgUrl in contentImgUrls){
          await Storage.deleteImageFromStorage(contentImgUrl);
        }
        final coverImg = item.data()['cover_img'];
        if(coverImg!=null) {
          await Storage.deleteImageFromStorage(coverImg);
        }
        transaction.delete(contentsRef.doc(item.id));
        transaction.delete(commentRef.doc(item.id));
      }
    }).then((_) {
      print('success');
    }).catchError((error) {
      print(error.message);
    });
  }
}
