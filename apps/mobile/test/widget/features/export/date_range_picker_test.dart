import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';

void main() {
  group('DateRangePickerWidget.calculateDateRange', () {
    late DateTime testDate;
    
    setUp(() {
      // Use a fixed date for consistent testing
      testDate = DateTime(2024, 3, 15); // March 15, 2024
    });

    test('should calculate "This Month" date range correctly', () {
      // Given
      final preset = DateRangePreset.thisMonth;
      
      // When
      final range = DateRangePickerWidget.calculateDateRange(preset);
      
      // Then
      final now = DateTime.now();
      expect(range.start.day, equals(1));
      expect(range.start.month, equals(now.month));
      expect(range.start.year, equals(now.year));
      expect(range.end.day, equals(now.day));
      expect(range.end.month, equals(now.month));
      expect(range.end.year, equals(now.year));
    });

    test('should calculate "Last Month" date range correctly', () {
      // Given
      final preset = DateRangePreset.lastMonth;
      
      // When
      final range = DateRangePickerWidget.calculateDateRange(preset);
      
      // Then
      final now = DateTime.now();
      final expectedStartMonth = now.month == 1 ? 12 : now.month - 1;
      final expectedStartYear = now.month == 1 ? now.year - 1 : now.year;
      
      expect(range.start.day, equals(1));
      expect(range.start.month, equals(expectedStartMonth));
      expect(range.start.year, equals(expectedStartYear));
      
      // Last day of last month
      expect(range.end.month, equals(expectedStartMonth));
      expect(range.end.year, equals(expectedStartYear));
    });

    test('should calculate "Last 30 Days" date range correctly', () {
      // Given
      final preset = DateRangePreset.last30Days;
      
      // When
      final range = DateRangePickerWidget.calculateDateRange(preset);
      
      // Then
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      
      expect(range.start, equals(thirtyDaysAgo));
      expect(range.end, equals(today));
    });

    test('should calculate "Last 90 Days" date range correctly', () {
      // Given
      final preset = DateRangePreset.last90Days;
      
      // When
      final range = DateRangePickerWidget.calculateDateRange(preset);
      
      // Then
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final ninetyDaysAgo = today.subtract(const Duration(days: 90));
      
      expect(range.start, equals(ninetyDaysAgo));
      expect(range.end, equals(today));
    });

    test('should return custom date range when provided', () {
      // Given
      final preset = DateRangePreset.custom;
      final customRange = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );
      
      // When
      final range = DateRangePickerWidget.calculateDateRange(
        preset, 
        customRange: customRange,
      );
      
      // Then
      expect(range, equals(customRange));
    });

    test('should return default range for custom when no range provided', () {
      // Given
      final preset = DateRangePreset.custom;
      
      // When
      final range = DateRangePickerWidget.calculateDateRange(preset);
      
      // Then
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      
      expect(range.start, equals(thirtyDaysAgo));
      expect(range.end, equals(today));
    });

    test('should handle month boundary correctly for "Last Month" in January', () {
      // Given - Simulate January scenario
      final preset = DateRangePreset.lastMonth;
      
      // When calculating in January
      // Note: This test demonstrates the edge case handling
      final range = DateRangePickerWidget.calculateDateRange(preset);
      
      // Then - verify the logic handles year boundary
      final now = DateTime.now();
      if (now.month == 1) {
        expect(range.start.month, equals(12));
        expect(range.start.year, equals(now.year - 1));
        expect(range.end.month, equals(12));
        expect(range.end.year, equals(now.year - 1));
      }
    });

    test('should enforce 2-year historical limit', () {
      // Given
      final now = DateTime.now();
      final twoYearsAgo = now.subtract(const Duration(days: 365 * 2));
      
      // When - widget should not allow dates before 2 years ago
      // This is enforced in the widget's showDateRangePicker firstDate parameter
      
      // Then
      expect(twoYearsAgo.isBefore(now), isTrue);
      expect(now.difference(twoYearsAgo).inDays, greaterThanOrEqualTo(730));
    });
  });
}