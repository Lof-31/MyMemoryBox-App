import 'package:flutter_test/flutter_test.dart';
import 'package:my_memory_box_app/utils/dates.dart';

void main() {
  test('daysBetween counts calendar days across a DST change', () {
    // Europe switches to winter time on 25 October 2026 (a 25 h day).
    expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 11, 1)), 8);
    // Summer time on 29 March 2026 (a 23 h day).
    expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
  });

  test('daysBetween ignores the time of day', () {
    expect(daysBetween(DateTime(2026, 1, 1, 23, 59), DateTime(2026, 1, 2)), 1);
    expect(daysBetween(DateTime(2026, 1, 2), DateTime(2026, 1, 1)), -1);
  });
}
