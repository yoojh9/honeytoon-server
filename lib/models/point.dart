import 'package:cloud_firestore/cloud_firestore.dart';

class Point {
  String uid;
  String type;
  double point;
  String targetUid;
  Timestamp createTime;

  Point({this.uid, this.type, this.point, this.targetUid, this.createTime});

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.type!=null){
      data['type'] = this.type;
    } 
    if(this.point!=null){
      data['point'] = this.point;
    }
    if(this.targetUid!=null){
      data['target_uid'] = this.targetUid;
    }
    if(this.createTime!=null){
      data['create_time'] = this.createTime;
    }
    return data;
  }
}