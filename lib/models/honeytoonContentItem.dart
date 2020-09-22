
import 'package:cloud_firestore/cloud_firestore.dart';

class HoneytoonContentItem {
  String contentId;
  String times;
  String coverImgUrl;
  String authorId;
  Timestamp createTime;
  Timestamp updateTime;
  List<String> contentImgUrls;

  HoneytoonContentItem({this.times, this.coverImgUrl, this.contentImgUrls});

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['times'] = this.times;
    data['cover_img'] = this.coverImgUrl;
    data['create_time'] = Timestamp.now();
    data['update_time'] = Timestamp.now();
    data['content_imgs'] = this.contentImgUrls;
    return data;
  }

  HoneytoonContentItem.fromMap(String documentId, Map snapshot){
    this.contentId = documentId;
    this.times = snapshot['times'];
    this.coverImgUrl = snapshot['cover_img'];
    this.authorId = snapshot['uid'];
    this.contentImgUrls = List<String>.from(snapshot['content_imgs']);
    this.createTime = snapshot['create_time'];
    this.updateTime = snapshot['update_time'];
  }
}