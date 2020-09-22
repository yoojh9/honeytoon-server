
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String toonId;
  String commentId;
  String uid;
  String username;
  String thumbnail;
  String comment;
  Timestamp createTime;
  Timestamp updateTime;


  Comment({this.toonId, this.commentId, this.uid, this.comment, this.createTime, this.updateTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['comment'] = this.comment;
    if(this.createTime!=null){
      data['create_time'] = this.createTime;
    }
    if(this.updateTime!=null){
      data['update_time'] = this.updateTime;
    }
    return data;
  }

  Comment.fromMap(String toonId, String documentId, Map snapshot){
    this.toonId = toonId;
    this.commentId = documentId;
    this.uid = snapshot['uid'];
    this.comment = snapshot['comment'];
    this.createTime = snapshot['create_time'];
    this.updateTime = snapshot['update_time'];
  }
}