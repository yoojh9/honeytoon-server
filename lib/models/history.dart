import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String uid;
  String workId;
  String times;
  List<dynamic> timesList;
  Timestamp updateTime;

  History({this.uid, this.workId, this.times, this.updateTime});

  History.fromMap(String documentId, Map snapshot) {
    this.workId = documentId;
    if(snapshot['contents']!=null){
      this.timesList = snapshot['contents'];
      print('timeList:${this.timesList}');
    }
    this.updateTime = snapshot['update_time'];
  }

}
