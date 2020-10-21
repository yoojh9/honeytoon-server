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
        Database.metaRef.doc(like.workId);
    final DocumentReference likeReference = Database.myRef.doc(like.uid).collection('likes').doc(like.workId);

    await Database.firestore.runTransaction((transaction) async {
      transaction.update(metaReference,{'likes': FieldValue.increment(like.like ? 1 : -1)});
      if (like.like) {
        transaction.set(likeReference, like.toJson());
      } else {
        transaction.delete(likeReference);
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
    final DocumentReference likeReference = Database.myRef.doc(like.uid).collection('likes').doc(like.workId);
    DocumentSnapshot snapshot = await likeReference.get();
    return snapshot.exists;
  }

  /*
   * 내가 좋아한 작품 리스트 조회
   */
  Future<List<Likes>> getLikeHoneytoon(String uid) async {
    List<Likes> _likes;
    QuerySnapshot snapshot = await Database.myRef.doc(uid).collection('likes').orderBy('like_time', descending: true).get();

    _likes = await Future.wait(snapshot.docs.map((likeSnapshot) async {
        DocumentSnapshot toonSnapshot = await Database.metaRef.doc(likeSnapshot.id).get();
        if(!toonSnapshot.exists) return null;
        DocumentSnapshot userSnapshot = await Database.userRef.doc(toonSnapshot.data()['uid']).get();
        return Likes.fromMap(likeSnapshot.id, likeSnapshot.data()['like_time'], toonSnapshot.data(), userSnapshot.data());
    }).toList());
    return _likes;
  }

  /*
   * 최근 본 작품 추가 
   */
  Future<void> addCurrentHoneytoon(Current current) async {
    final DocumentReference currentReference = Database.myRef.doc(current.uid).collection('current').doc(current.workId);
    await currentReference.set(current.toJson());
  }

  Future<void> addHoneytoonHistory(History history) async {
    final DocumentReference historyReference = Database.myRef.doc(history.uid).collection('history').doc(history.workId);
    DocumentSnapshot historySnapshot = await historyReference.get();

    if(historySnapshot.exists){
      await historyReference.update({
        'contents': FieldValue.arrayUnion([history.times]),
        'update_time': history.updateTime
      });
    } else {
      await historyReference.set({
        'contents': [history.times],
        'update_time': history.updateTime
      });
    }
  }

  Future<History> getHoneytoonHistory(uid, workId) async {
    final DocumentReference historyReference = Database.myRef.doc(uid).collection('history').doc(workId);
    DocumentSnapshot historySnapshot = await historyReference.get();
    if(!historySnapshot.exists) return null;
    return History.fromMap(historySnapshot.id, historySnapshot.data());
  }

  /*
   * 최근 본 작품 리스트 조회
   */
  Future<List<Current>> getCurrentHoneytoon(String uid) async {
    List<Current> _currentList;
    QuerySnapshot snapshot = await Database.myRef.doc(uid).collection('current').orderBy('update_time', descending: true).get();
  
    _currentList = await Future.wait(snapshot.docs.map((currentSnapshot) async {
      DocumentSnapshot toonSnapshot = await Database.metaRef.doc(currentSnapshot.id).get();
      
      if(!toonSnapshot.exists) return null;

      DocumentSnapshot userSnapshot = await Database.userRef.doc(toonSnapshot.data()['uid']).get();
      return Current.fromMap(currentSnapshot.id, currentSnapshot.data(), toonSnapshot.data(), userSnapshot.data());
    }).toList());
    return _currentList;
  }
}
