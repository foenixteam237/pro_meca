

import 'package:intl/intl.dart';

String formatedDate(DateTime date){
  DateTime nowUtc = date;
  DateTime camerounDate = nowUtc.add(const Duration(hours: 1)); // GMT+1

  String formattedDate = DateFormat(
    'yyyy-MM-ddTHH:mm:ss+01:00',
  ).format(camerounDate);

  return formattedDate;
}