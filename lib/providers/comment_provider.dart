
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import 'package:honeytoon/models/user.dart';
import '../models/comment.dart';

class CommentProvider extends ChangeNotifier {
  
  Future<void> setComment(Comment comment) async {
    Map data = comment.toJson();
    final DocumentReference commentReference = Database.commentRef.document(comment.toonId).collection('comment').document();
    await commentReference.setData(data);
  }

  Future<List<Comment>> getComments(String toonId) async {
    print('toonId:$toonId');
    List<Comment> _comments;
    QuerySnapshot snapshot = await Database.commentRef.document(toonId)
        .collection('comment').orderBy('create_time', descending: true)
        .getDocuments();
    _comments = snapshot.documents
      .map((document) =>
        Comment.fromMap(document.documentID, document.data))
      .toList();

    for(Comment comment in _comments) {
      print('comment:$comment');
      var userData = await Database.userRef.document(comment.uid).get();
      comment.username = userData.data['displayName'];
      comment.thumbnail = userData.data['thumbnail'];
    }

    return _comments;
  }
}