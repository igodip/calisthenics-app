import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String dateValue(Object? value) {
    if (value == null) return '';
    if (value is DateTime) return date(value);
    final text = value.toString();
    if (text.isEmpty) return '';
    final parsed = DateTime.tryParse(text);
    return parsed == null ? text : date(parsed);
  }
}
