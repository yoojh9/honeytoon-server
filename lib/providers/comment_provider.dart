
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import '../models/comment.dart';

class CommentProvider extends ChangeNotifier {
  
  Future<void> setComment(Comment comment) async {
    Map data = comment.toJson();
    final DocumentReference commentReference = Database.commentRef.doc(comment.toonId).collection('comment').doc();
    await commentReference.set(data);
  }

  Stream<QuerySnapshot> commentStream(String toonId) {
    return Database.commentRef.doc(toonId).collection('comment').orderBy('create_time', descending: true).snapshots();
  }

  Future<List<dynamic>> getCommentsWithUser(List<dynamic> comments) async {
    for(Comment comment in comments){
      var userData = await Database.userRef.doc(comment.uid).get();
      comment.username = userData.data()['displayName'];
      comment.thumbnail = userData.data()['thumbnail'];
    }
    return comments;
  }

  Future<List<Comment>> getComments(String toonId) async {
    List<Comment> _comments;
    QuerySnapshot snapshot = await Database.commentRef.doc(toonId).collection('comment').orderBy('create_time', descending: true).get();
    _comments = snapshot.docs
      .map((document) =>
        Comment.fromMap(toonId, document.id, document.data()))
      .toList();

    for(Comment comment in _comments) {
      print('comment:$comment');
      var userData = await Database.userRef.doc(comment.uid).get();
      comment.username = userData.data()['displayName'];
      comment.thumbnail = userData.data()['thumbnail'];
    }

    return _comments;
  }

  Future<void> deleteComment(Comment comment) async {
    print('toonId: ${comment.toonId}, commentId: ${comment.commentId}');
    await Database.commentRef.doc(comment.toonId).collection('comment').doc(comment.commentId).delete();
  }
}