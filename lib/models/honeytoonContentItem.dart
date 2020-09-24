
import 'package:cloud_firestore/cloud_firestore.dart';

class HoneytoonContentItem {
  String contentId;
  String times;
  String coverImgUrl;
  String authorId;
  Timestamp createTime;
  Timestamp updateTime;
  List<String> contentImgUrls;

  HoneytoonContentItem({this.times, this.coverImgUrl, this.contentId, this.contentImgUrls, this.createTime, this.updateTime});

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['times'] = this.times;
    if(this.coverImgUrl!=null){
      data['cover_img'] = this.coverImgUrl;
    }
    if(this.contentId!=null){
      data['content_id'] = this.contentId;
    }
    if(this.createTime!=null){
      data['create_time'] = this.createTime;
    }
    if(this.updateTime!=null){
      data['update_time'] = this.updateTime;
    }
    if(this.contentImgUrls!=null){
      data['content_imgs'] = this.contentImgUrls;
    }
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