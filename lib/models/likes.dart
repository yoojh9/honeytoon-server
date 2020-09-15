import 'package:cloud_firestore/cloud_firestore.dart';

class Likes {
  String uid;
  String workId;
  String title;
  String coverImgUrl;
  String authName;
  bool like;
  Timestamp likeTime;

  Likes({this.uid, this.workId, this.like, this.likeTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['like_time'] = this.likeTime;
    return data;
  }

  Likes.fromMap(String documentId, Timestamp likeTime, Map toonSnapshot, Map userSnapshot) {
    this.workId = documentId;
    if (likeTime != null) {
      this.likeTime = likeTime;
    }
    if (toonSnapshot == null) return;

    if (toonSnapshot['title'] != null) {
      this.title = toonSnapshot['title'];
    }
    if (toonSnapshot['cover_img'] != null) {
      this.coverImgUrl = toonSnapshot['cover_img'];
    }
    if (userSnapshot['displayName'] != null) {
      this.authName = userSnapshot['displayName'];
    }
  }
}
