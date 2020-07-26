import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateFormatHelper {
  static String getDate(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd').format(timestamp.toDate());
  }
}
