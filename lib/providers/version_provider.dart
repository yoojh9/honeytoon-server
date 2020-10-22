

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VersionProvider with ChangeNotifier {
    static final _db = FirebaseFirestore.instance;


    Future<String> getNewestVersion() async {
      QuerySnapshot snapshot =  await _db.collection('versions').where('newest', isEqualTo:true).get();
      final version = snapshot.docs.first.data()['version'];
      return version;
    }
}