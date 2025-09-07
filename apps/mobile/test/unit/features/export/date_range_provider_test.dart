import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'dart:convert';

void main() {
  group('DateRangeState', () {
    late DateRangeState state;
    late DateTimeRange testRange;

    setUp(() {
      testRange = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );
      state = DateRangeState(
        dateRange: testRange,
        presetOption: DateRangePreset.custom,
        receiptCount: 42,
      );
    });

    test('should create state with correct values', () {
      expect(state.dateRange, equals(testRange));
      expect(state.presetOption, equals(DateRangePreset.custom));
      expect(state.receiptCount, equals(42));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('should copyWith correctly', () {
      // Given
      final newRange = DateTimeRange(
        start: DateTime(2024, 2, 1),
        end: DateTime(2024, 2, 29),
      );

      // When
      final newState = state.copyWith(
        dateRange: newRange,
        presetOption: DateRangePreset.lastMonth,
        receiptCount: 100,
        isLoading: true,
        error: 'Test error',
      );

      // Then
      expect(newState.dateRange, equals(newRange));
      expect(newState.presetOption, equals(DateRangePreset.lastMonth));
      expect(newState.receiptCount, equals(100));
      expect(newState.isLoading, isTrue);
      expect(newState.error, equals('Test error'));
      
      // Original state unchanged
      expect(state.dateRange, equals(testRange));
      expect(state.presetOption, equals(DateRangePreset.custom));
    });

    test('should convert to JSON correctly', () {
      // When
      final json = state.toJson();

      // Then
      expect(json['startDate'], equals('2024-01-01T00:00:00.000'));
      expect(json['endDate'], equals('2024-01-31T00:00:00.000'));
      expect(json['presetOption'], equals('custom'));
    });

    test('should create from JSON correctly', () {
      // Given
      final json = {
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-31T00:00:00.000',
        'presetOption': 'lastMonth',
      };

      // When
      final state = DateRangeState.fromJson(json);

      // Then
      expect(state.dateRange.start, equals(DateTime(2024, 1, 1)));
      expect(state.dateRange.end, equals(DateTime(2024, 1, 31)));
      expect(state.presetOption, equals(DateRangePreset.lastMonth));
      expect(state.receiptCount, isNull);
      expect(state.isLoading, isFalse);
    });

    test('should handle invalid preset in JSON gracefully', () {
      // Given
      final json = {
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-31T00:00:00.000',
        'presetOption': 'invalid_preset',
      };

      // When
      final state = DateRangeState.fromJson(json);

      // Then
      expect(state.presetOption, equals(DateRangePreset.last30Days)); // Default
    });

    test('should create initial state with last 30 days', () {
      // When
      final state = DateRangeState.initial();

      // Then
      expect(state.presetOption, equals(DateRangePreset.last30Days));
      expect(state.receiptCount, isNull);
      expect(state.isLoading, isFalse);
      
      // Check date range is approximately 30 days
      final daysDifference = state.dateRange.end.difference(state.dateRange.start).inDays;
      expect(daysDifference, equals(30));
    });

    test('should serialize and deserialize consistently', () {
      // Given
      final originalState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 3, 1),
          end: DateTime(2024, 3, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
      );

      // When
      final json = originalState.toJson();
      final jsonString = jsonEncode(json);
      final decodedJson = jsonDecode(jsonString) as Map<String, dynamic>;
      final restoredState = DateRangeState.fromJson(decodedJson);

      // Then
      expect(restoredState.dateRange.start, equals(originalState.dateRange.start));
      expect(restoredState.dateRange.end, equals(originalState.dateRange.end));
      expect(restoredState.presetOption, equals(originalState.presetOption));
    });
  });
}