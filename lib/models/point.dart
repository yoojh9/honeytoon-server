import 'package:cloud_firestore/cloud_firestore.dart';

enum PointType { REWARD, CHEER, GIFT_SEND, REGIST }

class Point {
  String uid;
  String pointId;
  PointType type;
  int point;
  String otherUid;
  String otherDisplayName;
  Timestamp createTime;

  Point(
      {this.uid,
      this.pointId,
      this.type,
      this.point,
      this.otherUid,
      this.otherDisplayName,
      this.createTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.type != null) {
      data['type'] = this.type.index;
    }
    if (this.point != null) {
      data['point'] = this.point;
    }
    if (this.otherUid != null) {
      data['otherUid'] = this.otherUid;
    }
    if (this.createTime != null) {
      data['create_time'] = this.createTime;
    }
    return data;
  }

  Point.fromMap(String documentId, Map snapshot) {
    this.pointId = documentId;
    if (snapshot['type'] != null) {
      this.type = PointType.values[snapshot['type']];
    }
    if (snapshot['point'] != 0) {
      this.point = snapshot['point'];
    }
    if (snapshot['otherUid'] != null) {
      this.otherUid = snapshot['otherUid'];
    }
    if (snapshot['create_time'] != null) {
      this.createTime = snapshot['create_time'];
    }
  }

  Point.fromMapWithUser(String documentId, Map pointSnapshot, Map userSnapshot) {
    this.pointId = documentId;
    if (pointSnapshot['type'] != null) {
      this.type = PointType.values[pointSnapshot['type']];
    }
    if (pointSnapshot['point'] != 0) {
      this.point = pointSnapshot['point'];
    }
    if (pointSnapshot['otherUid'] != null) {
      this.otherUid = pointSnapshot['otherUid'];
    }
    if(userSnapshot['displayName']!=null){
      this.otherDisplayName = userSnapshot['displayName'];
    }
    if (pointSnapshot['create_time'] != null) {
      this.createTime = pointSnapshot['create_time'];
    }
  }
}
