import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:honeytoon/helpers/database.dart';
import 'package:honeytoon/models/current.dart';
import 'package:honeytoon/models/history.dart';
import 'package:honeytoon/models/likes.dart';

class MyProvider extends ChangeNotifier {
  /*
   * 관심툰 추가 or 제거 
   */
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
          if (like.like) {
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

  /*
   * 관심툰에 추가한 작품인지 확인 
   */
  Future<bool> ifLikeHoneytoon(Likes like) async {
    final DocumentReference likeReference = Database.myRef
        .document(like.uid)
        .collection('likes')
        .document(like.workId);

    DocumentSnapshot snapshot = await likeReference.get();
    return snapshot.exists;
  }

  /*
   * 내가 좋아한 작품 리스트 조회
   */
  Future<List<Likes>> getLikeHoneytoon(String uid) async {
    List<Likes> _likes;
    QuerySnapshot snapshot = await Database.myRef
        .document(uid)
        .collection('likes')
        .orderBy('like_time', descending: true)
        .getDocuments();

    _likes = await Future.wait(snapshot.documents.map((likeSnapshot) async {
        DocumentSnapshot toonSnapshot = await Database.metaRef.document(likeSnapshot.documentID).get();
        
        if(!toonSnapshot.exists) return null;

        DocumentSnapshot userSnapshot = await Database.userRef.document(toonSnapshot.data['uid']).get();
      return Likes.fromMap(likeSnapshot.documentID, likeSnapshot.data['like_time'], toonSnapshot.data, userSnapshot.data);
    }).toList());
    return _likes;
  }

  /*
   * 최근 본 작품 추가 
   */
  Future<void> addCurrentHoneytoon(Current current) async {
    final DocumentReference currentReference = Database.myRef
        .document(current.uid)
        .collection('current')
        .document(current.workId);

    await currentReference.setData(current.toJson());
  }

  Future<void> addHoneytoonHistory(History history) async {
    final DocumentReference historyReference = Database.myRef.document(history.uid).collection('history').document(history.workId);
    DocumentSnapshot historySnapshot = await historyReference.get();
    print('exists:${historySnapshot.exists}');
    print('id:${history.times}');
    if(historySnapshot.exists){
      await historyReference.updateData({
        'contents': FieldValue.arrayUnion([history.times]),
        'update_time': history.updateTime
      });
    } else {
      await historyReference.setData({
        'contents': [history.times],
        'update_time': history.updateTime
      });
    }
  }

  Future<History> getHoneytoonHistory(uid, workId) async {
    final DocumentReference historyReference = Database.myRef.document(uid).collection('history').document(workId);
    DocumentSnapshot historySnapshot = await historyReference.get();
    if(!historySnapshot.exists) return null;
    return History.fromMap(historySnapshot.documentID, historySnapshot.data);
  }

  /*
   * 최근 본 작품 리스트 조회
   */
  Future<List<Current>> getCurrentHoneytoon(String uid) async {
    List<Current> _currentList;
    QuerySnapshot snapshot = await Database.myRef
        .document(uid)
        .collection('current')
        .orderBy('update_time', descending: true)
        .getDocuments();
  
    _currentList = await Future.wait(snapshot.documents.map((currentSnapshot) async {
      DocumentSnapshot toonSnapshot =
          await Database.metaRef.document(currentSnapshot.documentID).get();
      
      if(!toonSnapshot.exists) return null;

      DocumentSnapshot userSnapshot = await Database.userRef.document(toonSnapshot.data['uid']).get();
      return Current.fromMap(
          currentSnapshot.documentID, currentSnapshot.data, toonSnapshot.data, userSnapshot.data);
    }).toList());
    return _currentList;
  }
}
