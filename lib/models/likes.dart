import 'package:cloud_firestore/cloud_firestore.dart';

class Likes {
  String uid;
  String workId;
  bool like;
  Timestamp likeTime;

  Likes({this.uid, this.workId, this.like, this.likeTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['like_time'] = this.likeTime;
    return data;
  }

  Likes.fromMap(String documentId, Map snapshot) {
    this.workId = documentId;
    if (snapshot['like_time'] != null) {
      this.likeTime = snapshot['like_time'];
    }
  }
}
