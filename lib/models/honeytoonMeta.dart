import 'package:cloud_firestore/cloud_firestore.dart';

class HoneytoonMeta {
  String workId;
  String uid; // userid
  String displayName;
  String coverImgUrl;
  int totalCount;
  int likes;
  String title;
  String description;
  Timestamp createTime;

  HoneytoonMeta(
      {this.workId,
      this.uid,
      this.displayName,
      this.coverImgUrl,
      this.totalCount,
      this.likes,
      this.title,
      this.description});

  HoneytoonMeta.fromMap(Map snapshot, String documentId) {
    this.workId = documentId;
    if(snapshot['uid']!=null){
      this.uid = snapshot['uid'];
    }
    this.title = snapshot['title'];
    this.description = snapshot['description'];
    this.displayName = snapshot['displayName'];
    this.coverImgUrl = snapshot['cover_img'];
    this.likes = snapshot['likes'];
    this.totalCount = snapshot['total_count'];
    this.createTime = snapshot['create_time'];
  }

  HoneytoonMeta.fromMapWithAuthor(String documentId, Map metaSnapshot, Map authorSnapshot) {
    this.workId = documentId;
    if(metaSnapshot['uid']!=null){
      this.uid = metaSnapshot['uid'];
    }
    this.title = metaSnapshot['title'];
    this.description = metaSnapshot['description'];
    this.displayName = authorSnapshot['displayName'];
    this.coverImgUrl = metaSnapshot['cover_img'];
    this.likes = metaSnapshot['likes'];
    this.totalCount = metaSnapshot['total_count'];
    this.createTime = metaSnapshot['create_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.uid!=null) {
      data['uid'] = this.uid;
    }
    if(this.title!=null){
      data['title'] = this.title;
    }
    if(this.description!=null){
      data['description'] = this.description;
    }
    if(this.coverImgUrl!=null){
      data['cover_img'] = this.coverImgUrl;
    }
    if(this.totalCount!=null){
      data['total_count'] = this.totalCount;
    }
    if(this.likes!=null){
      data['likes'] = this.likes;
    }
    if(this.createTime!=null){
      data['create_time'] = this.createTime;
    }
    return data;
  }
}
