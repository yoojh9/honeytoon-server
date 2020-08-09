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
          await transaction.set(likeReference, like.toJson());
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

  Future<List<Likes>> getLikeHoneytoon() async {}
}
