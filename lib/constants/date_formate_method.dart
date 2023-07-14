  
  
  
  import 'package:intl/intl.dart';

String formattedate(timestamp) {
    var dateFromTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd.MMM.yy').format(dateFromTimeStamp);
  }