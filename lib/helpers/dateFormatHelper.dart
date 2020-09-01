import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateFormatHelper {
  static String getDateTime(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  static String getDate(Timestamp timestamp){
    return DateFormat('yyyyMMdd').format(timestamp.toDate());
  }
  
  static String convertDateTimeToDate(String dateTimeStr){
    print('dateTimeStr:$dateTimeStr');
    String dateWithT = dateTimeStr.substring(0, 8) + 'T' + dateTimeStr.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
