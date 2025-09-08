import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/features/capture/services/retry_session_manager.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';

import 'capture_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<OCRService>(),
  MockSpec<ICameraService>(),
  MockSpec<RetrySessionManager>(),
])
void main() {
  group('CaptureNotifier', () {
    late CaptureNotifier captureNotifier;
    late MockOCRService mockOCRService;
    late MockICameraService mockCameraService;
    late MockRetrySessionManager mockSessionManager;

    setUp(() {
      mockOCRService = MockOCRService();
      mockCameraService = MockICameraService();
      mockSessionManager = MockRetrySessionManager();

      // Stub the cleanup method that's called in constructor
      when(mockSessionManager.cleanupExpiredSessions()).thenAnswer((_) async => 0);

      captureNotifier = CaptureNotifier(
        ocrService: mockOCRService,
        cameraService: mockCameraService,
        sessionManager: mockSessionManager,
      );
    });

    group('updateField', () {
      test('should update merchant field and recalculate confidence', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Old Store', confidence: 80.0, originalText: 'Old Store'),
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 85.0, originalText: '\$2.08'),
          overallConfidence: 87.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        final updatedField = FieldData(
          value: 'New Store',
          confidence: 100.0,
          originalText: 'Old Store',
          isManuallyEdited: true,
          validationStatus: 'valid',
        );

        // When
        final result = await captureNotifier.updateField('merchant', updatedField);

        // Then
        expect(result, true);
        expect(captureNotifier.state.lastProcessingResult, isNotNull);
        expect(captureNotifier.state.lastProcessingResult!.merchant!.value, 'New Store');
        expect(captureNotifier.state.lastProcessingResult!.merchant!.isManuallyEdited, true);
        
        // Overall confidence should be recalculated
        final expectedConfidence = (100.0 * 0.2) + (90.0 * 0.3) + (95.0 * 0.4) + (85.0 * 0.1);
        expect(captureNotifier.state.lastProcessingResult!.overallConfidence, 
               closeTo(expectedConfidence, 0.1));
      });

      test('should update date field and recalculate confidence', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),
          date: FieldData(value: '01/15/2024', confidence: 70.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 85.0, originalText: '\$2.08'),
          overallConfidence: 82.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        final updatedField = FieldData(
          value: '02/20/2024',
          confidence: 100.0,
          originalText: '01/15/2024',
          isManuallyEdited: true,
          validationStatus: 'valid',
        );

        // When
        final result = await captureNotifier.updateField('date', updatedField);

        // Then
        expect(result, true);
        expect(captureNotifier.state.lastProcessingResult!.date!.value, '02/20/2024');
        expect(captureNotifier.state.lastProcessingResult!.date!.isManuallyEdited, true);
        
        // Overall confidence should increase due to higher date confidence
        expect(captureNotifier.state.lastProcessingResult!.overallConfidence, 
               greaterThan(originalResult.overallConfidence));
      });

      test('should update total field and recalculate confidence', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 60.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 85.0, originalText: '\$2.08'),
          overallConfidence: 78.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        final updatedField = FieldData(
          value: 35.99,
          confidence: 100.0,
          originalText: '\$25.99',
          isManuallyEdited: true,
          validationStatus: 'valid',
        );

        // When
        final result = await captureNotifier.updateField('total', updatedField);

        // Then
        expect(result, true);
        expect(captureNotifier.state.lastProcessingResult!.total!.value, 35.99);
        expect(captureNotifier.state.lastProcessingResult!.total!.isManuallyEdited, true);
        
        // Overall confidence should increase significantly due to total having 40% weight
        expect(captureNotifier.state.lastProcessingResult!.overallConfidence, 
               greaterThan(originalResult.overallConfidence));
      });

      test('should update tax field and recalculate confidence', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 50.0, originalText: '\$2.08'),
          overallConfidence: 83.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        final updatedField = FieldData(
          value: 2.88,
          confidence: 100.0,
          originalText: '\$2.08',
          isManuallyEdited: true,
          validationStatus: 'valid',
        );

        // When
        final result = await captureNotifier.updateField('tax', updatedField);

        // Then
        expect(result, true);
        expect(captureNotifier.state.lastProcessingResult!.tax!.value, 2.88);
        expect(captureNotifier.state.lastProcessingResult!.tax!.isManuallyEdited, true);
      });

      test('should return false for unknown field name', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 85.0, originalText: '\$2.08'),
          overallConfidence: 87.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        final updatedField = FieldData(
          value: 'Invalid Field',
          confidence: 100.0,
          originalText: 'Invalid Field',
        );

        // When
        final result = await captureNotifier.updateField('unknown_field', updatedField);

        // Then
        expect(result, false);
        // State should remain unchanged
        expect(captureNotifier.state.lastProcessingResult, equals(originalResult));
      });

      test('should return false when no processing result exists', () async {
        // Given - state without processing result
        captureNotifier.state = const CaptureState();

        final updatedField = FieldData(
          value: 'New Store',
          confidence: 100.0,
          originalText: 'New Store',
        );

        // When
        final result = await captureNotifier.updateField('merchant', updatedField);

        // Then
        expect(result, false);
      });

      test('should auto-save session when in retry mode', () async {
        // Given
        when(mockSessionManager.saveSession(any())).thenAnswer((_) async => true);
        
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 85.0, originalText: '\$2.08'),
          overallConfidence: 87.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
          isRetryMode: true,
          sessionId: 'test_session_123',
        );

        final updatedField = FieldData(
          value: 'New Store',
          confidence: 100.0,
          originalText: 'Store',
          isManuallyEdited: true,
        );

        // When
        final result = await captureNotifier.updateField('merchant', updatedField);

        // Then
        expect(result, true);
        verify(mockSessionManager.saveSession(any())).called(1);
      });
    });

    group('updateFields', () {
      test('should update multiple fields at once', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Old Store', confidence: 80.0, originalText: 'Old Store'),
          date: FieldData(value: '01/15/2024', confidence: 70.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 60.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 50.0, originalText: '\$2.08'),
          overallConfidence: 65.0,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        final fieldUpdates = {
          'merchant': FieldData(value: 'New Store', confidence: 100.0, originalText: 'Old Store', isManuallyEdited: true),
          'total': FieldData(value: 35.99, confidence: 100.0, originalText: '\$25.99', isManuallyEdited: true),
        };

        // When
        final result = await captureNotifier.updateFields(fieldUpdates);

        // Then
        expect(result, true);
        expect(captureNotifier.state.lastProcessingResult!.merchant!.value, 'New Store');
        expect(captureNotifier.state.lastProcessingResult!.total!.value, 35.99);
        
        // Overall confidence should be much higher now
        expect(captureNotifier.state.lastProcessingResult!.overallConfidence, 
               greaterThan(originalResult.overallConfidence));
      });

      test('should return false for empty field updates', () async {
        // Given
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
          total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
          tax: FieldData(value: 2.08, confidence: 85.0, originalText: '\$2.08'),
          overallConfidence: 87.5,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        // When
        final result = await captureNotifier.updateFields({});

        // Then
        expect(result, false);
      });
    });

    group('_calculateOverallConfidence', () {
      test('should calculate weighted average correctly', () {
        // Given - access private method through updateField
        final originalResult = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 80.0, originalText: 'Store'),      // 20%
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'), // 30%
          total: FieldData(value: 25.99, confidence: 100.0, originalText: '\$25.99'),         // 40%
          tax: FieldData(value: 2.08, confidence: 70.0, originalText: '\$2.08'),              // 10%
          overallConfidence: 0.0, // Will be recalculated
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        // When - trigger confidence calculation
        captureNotifier.updateField('merchant', originalResult.merchant!);

        // Then - expected: (80*0.2) + (90*0.3) + (100*0.4) + (70*0.1) = 90.0
        expect(captureNotifier.state.lastProcessingResult!.overallConfidence, 
               closeTo(90.0, 0.1));
      });

      test('should handle missing fields correctly', () {
        // Given - only total and date fields
        final originalResult = ProcessingResult(
          merchant: null,
          date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'), // 30%
          total: FieldData(value: 25.99, confidence: 100.0, originalText: '\$25.99'),         // 40%
          tax: null,
          overallConfidence: 0.0,
          processingDurationMs: 1500,
        );

        captureNotifier.state = CaptureState(
          lastProcessingResult: originalResult,
        );

        // When - trigger confidence calculation
        captureNotifier.updateField('date', originalResult.date!);

        // Then - expected: (90*0.3 + 100*0.4) / (0.3 + 0.4) = 95.71
        expect(captureNotifier.state.lastProcessingResult!.overallConfidence, 
               closeTo(95.71, 0.1));
      });
    });
  });
}