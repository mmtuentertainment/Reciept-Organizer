import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/receipt_card.dart';

void main() {
  group('ReceiptCard', () {
    late Receipt testReceipt;

    setUp(() {
      testReceipt = Receipt(
        imageUri: 'test/path/image.jpg',
        capturedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: ReceiptStatus.ready,
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: 'Test Store',
            confidence: 85.0,
            originalText: 'Test Store',
          ),
          date: FieldData(
            value: '01/15/2024',
            confidence: 90.0,
            originalText: '01/15/2024',
          ),
          total: FieldData(
            value: 25.47,
            confidence: 95.0,
            originalText: '\$25.47',
          ),
          tax: FieldData(
            value: 2.04,
            confidence: 88.0,
            originalText: '\$2.04',
          ),
          overallConfidence: 89.5,
          processingDurationMs: 1250,
          allText: ['Test Store', '01/15/2024', 'Total: \$25.47', 'Tax: \$2.04'],
        ),
      );
    });

    testWidgets('displays receipt information correctly', (WidgetTester tester) async {
      // Given
      bool tapCalled = false;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(
              receipt: testReceipt,
              onTap: () => tapCalled = true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text('01/15/2024'), findsOneWidget);
      expect(find.text('\$25.47'), findsOneWidget);
      expect(find.text('2h ago'), findsOneWidget);
      
      // Test tap functionality
      await tester.tap(find.byType(ReceiptCard));
      expect(tapCalled, isTrue);
    });

    testWidgets('shows confidence score when OCR results are available', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(
              receipt: testReceipt,
              showConfidenceSummary: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('90%'), findsOneWidget); // Overall confidence rounded
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows processing state when no OCR results', (WidgetTester tester) async {
      // Given
      final processingReceipt = Receipt(
        imageUri: 'test/path/image.jpg',
        capturedAt: DateTime.now(),
        status: ReceiptStatus.processing,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(
              receipt: processingReceipt,
              showConfidenceSummary: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Unknown Merchant'), findsOneWidget);
    });

    testWidgets('displays field confidence preview dots', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(
              receipt: testReceipt,
              showConfidenceSummary: true,
            ),
          ),
        ),
      );

      // Then - Should have 4 confidence dots for merchant, date, total, tax
      final containers = tester.widgetList<Container>(find.byType(Container));
      final confidenceDots = containers.where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && 
               decoration.shape == BoxShape.circle &&
               container.constraints?.minWidth == 8;
      }).toList();
      
      expect(confidenceDots.length, 4);
    });

    testWidgets('shows correct status indicator', (WidgetTester tester) async {
      // Test different status states
      final statuses = [
        (ReceiptStatus.captured, Icons.photo_camera),
        (ReceiptStatus.processing, Icons.hourglass_empty),
        (ReceiptStatus.ready, Icons.check_circle),
        (ReceiptStatus.exported, Icons.download_done),
        (ReceiptStatus.error, Icons.error),
      ];

      for (final (status, expectedIcon) in statuses) {
        final receipt = testReceipt.copyWith(status: status);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReceiptCard(receipt: receipt),
            ),
          ),
        );

        expect(find.byIcon(expectedIcon), findsOneWidget,
            reason: 'Expected icon $expectedIcon for status $status');

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('highlights card when selected', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(
              receipt: testReceipt,
              isSelected: true,
            ),
          ),
        ),
      );

      // Then - Should have elevated card and blue border
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4);
      
      final containers = tester.widgetList<Container>(find.byType(Container));
      final borderContainer = containers.firstWhere((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.border != null;
      });
      final decoration = borderContainer.decoration as BoxDecoration;
      expect(decoration.border?.top.width, 2);
    });

    testWidgets('handles null OCR data gracefully', (WidgetTester tester) async {
      // Given
      final receiptWithoutOCR = Receipt(
        imageUri: 'test/path/image.jpg',
        capturedAt: DateTime.now(),
        status: ReceiptStatus.captured,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(receipt: receiptWithoutOCR),
          ),
        ),
      );

      // Then
      expect(find.text('Unknown Merchant'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('formats timestamp correctly', (WidgetTester tester) async {
      // Test different time intervals
      final testCases = [
        (DateTime.now().subtract(const Duration(minutes: 30)), 'Just now'),
        (DateTime.now().subtract(const Duration(hours: 1)), '1h ago'),
        (DateTime.now().subtract(const Duration(days: 2)), '2d ago'),
      ];

      for (final (timestamp, expectedText) in testCases) {
        final receipt = testReceipt.copyWith(capturedAt: timestamp);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReceiptCard(receipt: receipt),
            ),
          ),
        );

        expect(find.textContaining('ago'), findsWidgets,
            reason: 'Expected relative timestamp for $timestamp');

        await tester.pumpWidget(Container());
      }
    });

    testWidgets('can hide confidence summary', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptCard(
              receipt: testReceipt,
              showConfidenceSummary: false,
            ),
          ),
        ),
      );

      // Then - Should not show confidence score widget
      expect(find.text('90%'), findsNothing);
    });
  });

  group('CompactReceiptCard', () {
    late Receipt testReceipt;

    setUp(() {
      testReceipt = Receipt(
        imageUri: 'test/path/image.jpg',
        capturedAt: DateTime.now(),
        status: ReceiptStatus.ready,
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: 'Compact Store',
            confidence: 85.0,
            originalText: 'Compact Store',
          ),
          total: FieldData(
            value: 15.99,
            confidence: 90.0,
            originalText: '\$15.99',
          ),
          overallConfidence: 87.5,
          processingDurationMs: 800,
          allText: ['Compact Store', '\$15.99'],
        ),
      );
    });

    testWidgets('displays compact receipt information', (WidgetTester tester) async {
      // Given
      bool tapCalled = false;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactReceiptCard(
              receipt: testReceipt,
              onTap: () => tapCalled = true,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Compact Store'), findsOneWidget);
      expect(find.text('\$15.99'), findsOneWidget);
      
      // Test tap functionality
      await tester.tap(find.byType(CompactReceiptCard));
      expect(tapCalled, isTrue);
    });

    testWidgets('shows confidence badge overlay', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactReceiptCard(receipt: testReceipt),
          ),
        ),
      );

      // Then
      expect(find.byType(Stack), findsOneWidget);
      expect(find.text('88'), findsOneWidget); // Rounded confidence
    });

    testWidgets('handles unknown merchant gracefully', (WidgetTester tester) async {
      // Given
      final receiptWithoutMerchant = testReceipt.copyWith(
        ocrResults: ProcessingResult(
          total: FieldData(
            value: 15.99,
            confidence: 90.0,
            originalText: '\$15.99',
          ),
          overallConfidence: 90.0,
          processingDurationMs: 800,
          allText: ['\$15.99'],
        ),
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactReceiptCard(receipt: receiptWithoutMerchant),
          ),
        ),
      );

      // Then
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('\$15.99'), findsOneWidget);
    });
  });
}