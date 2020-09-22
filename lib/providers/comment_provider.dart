
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import '../models/comment.dart';

class CommentProvider extends ChangeNotifier {
  
  Future<void> setComment(Comment comment) async {
    Map data = comment.toJson();
    final DocumentReference commentReference = Database.commentRef.document(comment.toonId).collection('comment').document();
    await commentReference.setData(data);
  }

  Stream<QuerySnapshot> commentStream(String toonId) {
    return Database.commentRef.document(toonId).collection('comment').orderBy('create_time', descending: true).snapshots();
  }

  Future<List<dynamic>> getCommentsWithUser(List<dynamic> comments) async {
    print('getCommentsWithUser');
    for(Comment comment in comments){
      print('toonId:${comment.toonId}');
      print('comment:${comment}');
      var userData = await Database.userRef.document(comment.uid).get();
      print('userData:${userData.data}');
      comment.username = userData.data['displayName'];
      comment.thumbnail = userData.data['thumbnail'];
      print('loop : ${comment.thumbnail}');
    }
    return comments;
  }

  Future<List<Comment>> getComments(String toonId) async {

    List<Comment> _comments;
    QuerySnapshot snapshot = await Database.commentRef.document(toonId)
        .collection('comment').orderBy('create_time', descending: true)
        .getDocuments();
    _comments = snapshot.documents
      .map((document) =>
        Comment.fromMap(toonId, document.documentID, document.data))
      .toList();

    for(Comment comment in _comments) {
      print('comment:$comment');
      var userData = await Database.userRef.document(comment.uid).get();
      comment.username = userData.data['displayName'];
      comment.thumbnail = userData.data['thumbnail'];
    }

    return _comments;
  }

  Future<void> deleteComment(Comment comment) async {
    print('toonId: ${comment.toonId}, commentId: ${comment.commentId}');
    await Database.commentRef.document(comment.toonId).collection('comment').document(comment.commentId).delete();
  }
}