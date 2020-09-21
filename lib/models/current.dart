import 'package:cloud_firestore/cloud_firestore.dart';

class Current {
  String uid;
  String workId;
  String title;
  String coverImgUrl;
  String authorName;
  String authorId;
  String times;
  int totalCount;
  Timestamp updateTime;

  Current({this.uid, this.workId, this.times, this.updateTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['update_time'] = this.updateTime;
    data['times'] = this.times;
    return data;
  }

  Current.fromMap(String documentId, Map currentSnapshot, Map toonSnapshot, Map userSnapshot) {
    this.workId = documentId;

    if (currentSnapshot['times'] != null) {
      this.times = currentSnapshot['times'];
    }
    if (toonSnapshot == null) return;
    if (toonSnapshot['title'] != null) {
      this.title = toonSnapshot['title'];
    }
    if (toonSnapshot['cover_img'] != null) {
      this.coverImgUrl = toonSnapshot['cover_img'];
    }
    if (userSnapshot['displayName'] != null) {
      this.authorName = userSnapshot['displayName'];
    }
    if(toonSnapshot['uid']!=null){
      this.authorId = toonSnapshot['uid'];
    }
    if (toonSnapshot['total_count'] != null) {
      this.totalCount = toonSnapshot['total_count'];
    }
  }
}
