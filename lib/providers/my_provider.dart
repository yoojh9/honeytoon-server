import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import 'package:honeytoon/models/likes.dart';

class MyProvider extends ChangeNotifier {

  Future<void> likeHoneytoon(Likes like) async {
    final DocumentReference metaReference =
        Database.metaRef.document(like.workId);
    final DocumentReference likeReference = Database.myRef
        .document(like.uid)
        .collection('likes')
        .document(like.workId);

    Database.firestore
        .runTransaction((transaction) async {
          await transaction.update(metaReference,
              {'likes': FieldValue.increment(like.like ? 1 : -1)});
          if(like.like){
            await transaction.set(likeReference, like.toJson());
          } else {
            await transaction.delete(likeReference);
          }
        })
        .then((value) => {print('success')})
        .catchError((error) {
          print(error.message);
        });
  }

  Future<bool> ifLikeHoneytoon(Likes like) async {
    final DocumentReference likeReference = Database.myRef
        .document(like.uid)
        .collection('likes')
        .document(like.workId);

    DocumentSnapshot snapshot = await likeReference.get();
    return snapshot.exists;
  }

  /**
   * 내가 좋아한 작품 리스트 get
   */
  Future<List<Likes>> getLikeHoneytoon(String uid) async {
    List<Likes> _likes;
    QuerySnapshot snapshot  = await Database.myRef.document(uid).collection('likes').getDocuments();
    _likes = await Future.wait(snapshot.documents.map((likeSnapshot) async {
        DocumentSnapshot toonSnapshot = await Database.metaRef.document(likeSnapshot.documentID).get();
        return Likes.fromMap(likeSnapshot.documentID, likeSnapshot.data['like_time'], toonSnapshot.data);
      }).toList()
    );
    return _likes;
  }
}
