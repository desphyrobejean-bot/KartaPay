import 'package:flutter_test/flutter_test.dart';
import 'package:kartapay/models.dart';

void main() {
  group('equalShares', () {
    test('distributes leftover cent deterministically', () {
      final shares = equalShares(100, 3);

      expect(shares, [33.34, 33.33, 33.33]);
      expect(shares.fold<double>(0, (total, value) => total + value), 100);
    });

    test('returns no shares for an invalid count or amount', () {
      expect(equalShares(10, 0), isEmpty);
      expect(equalShares(-1, 2), isEmpty);
    });
  });

  test('payroll totals and JSON round trip preserve net pay', () {
    final record = PayrollRecord(
      id: 'record-1',
      kind: 'driver',
      date: DateTime(2026, 11, 18),
      reference: 'TRIP-12',
      description: '2 trips',
      tripCount: 2,
      ratePerTrip: 1500,
      lines: const [
        PayrollLine(
          workerId: 'driver-1',
          workerName: 'Juan Driver',
          gross: 3000,
          deduction: 250,
        ),
      ],
    );

    final restored = PayrollRecord.fromJson(record.toJson());

    expect(restored.totalGross, 3000);
    expect(restored.totalDeduction, 250);
    expect(restored.totalNet, 2750);
    expect(restored.tripCount, 2);
  });
}
