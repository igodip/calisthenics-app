import 'package:calisync/utils/app_date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats dates using the Italian day/month/year order', () {
    expect(AppDateFormat.date(DateTime(2026, 10, 16)), '16/10/2026');
    expect(AppDateFormat.dateValue('2026-10-16'), '16/10/2026');
  });

  test('formats date and time using the Italian date order', () {
    expect(
      AppDateFormat.dateTime(DateTime(2026, 10, 16, 21, 7)),
      '16/10/2026 21:07',
    );
  });

  test('keeps empty and unparseable values safe', () {
    expect(AppDateFormat.dateValue(null), '');
    expect(AppDateFormat.dateValue(''), '');
    expect(AppDateFormat.dateValue('unknown'), 'unknown');
  });
}
