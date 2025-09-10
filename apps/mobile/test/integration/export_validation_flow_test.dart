import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:receipt_organizer/features/export/domain/receipt_converter.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as data;
import 'package:receipt_organizer/core/models/receipt.dart' as core;
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('Export Validation Flow', () {
    test('should convert data receipts to core receipts correctly', () {
      // Create a data layer receipt with OCR results
      final ocrResult = ProcessingResult(
        merchant: FieldData(
          value: 'Target Store',
          confidence: 0.95,
          originalText: 'Target Store',
          boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
        ),
        total: FieldData(
          value: 125.50,
          confidence: 0.98,
          originalText: '125.50',
          boundingBox: const Rect.fromLTWH(0, 40, 100, 20),
        ),
        tax: FieldData(
          value: 12.55,
          confidence: 0.92,
          originalText: '12.55',
          boundingBox: const Rect.fromLTWH(0, 60, 100, 20),
        ),
        date: FieldData(
          value: '12/25/2024',
          confidence: 0.90,
          originalText: '12/25/2024',
          boundingBox: const Rect.fromLTWH(0, 20, 100, 20),
        ),
        overallConfidence: 0.93,
        processingDurationMs: 100,
      );
      
      final dataReceipt = data.Receipt(
        id: 'test-123',
        imageUri: '/path/to/image.jpg',
        status: data.ReceiptStatus.ready,
        ocrResults: ocrResult,
        capturedAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      
      // Convert to core receipt
      final coreReceipt = ReceiptConverter.fromDataReceipt(dataReceipt);
      
      // Verify conversion
      expect(coreReceipt.id, equals('test-123'));
      expect(coreReceipt.merchantName, equals('Target Store'));
      expect(coreReceipt.totalAmount, equals(125.50));
      expect(coreReceipt.taxAmount, equals(12.55));
      expect(coreReceipt.date?.year, equals(2024));
      expect(coreReceipt.date?.month, equals(12));
      expect(coreReceipt.date?.day, equals(25));
    });
    
    test('should filter exportable receipts correctly', () {
      // Create receipts with different statuses
      final receipts = [
        // Should be included - ready with OCR results
        data.Receipt(
          id: 'ready-1',
          imageUri: '/path/1.jpg',
          status: data.ReceiptStatus.ready,
          ocrResults: ProcessingResult(
            merchant: FieldData(
              value: 'Store 1',
              confidence: 0.9,
              originalText: 'Store 1',
              boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
            ),
            total: FieldData(
              value: 100.00,
              confidence: 0.9,
              originalText: '100.00',
              boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
            ),
            tax: FieldData(
              value: 10.00,
              confidence: 0.9,
              originalText: '10.00',
              boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
            ),
            date: FieldData(
              value: '01/01/2024',
              confidence: 0.9,
              originalText: '01/01/2024',
              boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
            ),
            overallConfidence: 0.9,
            processingDurationMs: 100,
          ),
          capturedAt: DateTime.now(),
          lastModified: DateTime.now(),
        ),
        // Should NOT be included - processing status
        data.Receipt(
          id: 'processing-1',
          imageUri: '/path/2.jpg',
          status: data.ReceiptStatus.processing,
          capturedAt: DateTime.now(),
          lastModified: DateTime.now(),
        ),
        // Should NOT be included - ready but no OCR results
        data.Receipt(
          id: 'ready-no-ocr',
          imageUri: '/path/3.jpg',
          status: data.ReceiptStatus.ready,
          capturedAt: DateTime.now(),
          lastModified: DateTime.now(),
        ),
        // Should NOT be included - error status
        data.Receipt(
          id: 'error-1',
          imageUri: '/path/4.jpg',
          status: data.ReceiptStatus.error,
          notes: 'OCR failed',
          capturedAt: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      ];
      
      final exportable = ReceiptConverter.filterExportableReceipts(receipts);
      
      expect(exportable.length, equals(1));
      expect(exportable.first.id, equals('ready-1'));
    });
    
    test('should determine minimum fields correctly', () {
      // Receipt with all fields
      final fullReceipt = data.Receipt(
        id: 'full',
        imageUri: '/path/full.jpg',
        status: data.ReceiptStatus.ready,
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: 'Store',
            confidence: 0.9,
            originalText: 'Store',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          total: FieldData(
            value: 100.00,
            confidence: 0.9,
            originalText: '100.00',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          tax: FieldData(
            value: 10.00,
            confidence: 0.9,
            originalText: '10.00',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          date: FieldData(
            value: '01/01/2024',
            confidence: 0.9,
            originalText: '01/01/2024',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          overallConfidence: 0.9,
          processingDurationMs: 100,
        ),
        capturedAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      
      // Receipt missing merchant name
      final missingMerchant = data.Receipt(
        id: 'partial',
        imageUri: '/path/partial.jpg',
        status: data.ReceiptStatus.ready,
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: '',
            confidence: 0.0,
            originalText: '',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          total: FieldData(
            value: 100.00,
            confidence: 0.9,
            originalText: '100.00',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          tax: FieldData(
            value: 10.00,
            confidence: 0.9,
            originalText: '10.00',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          date: FieldData(
            value: '01/01/2024',
            confidence: 0.9,
            originalText: '01/01/2024',
            boundingBox: const Rect.fromLTWH(0, 0, 100, 20),
          ),
          overallConfidence: 0.7,
          processingDurationMs: 100,
        ),
        capturedAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      
      expect(ReceiptConverter.hasMinimumFieldsForExport(fullReceipt), isTrue);
      expect(ReceiptConverter.hasMinimumFieldsForExport(missingMerchant), isFalse);
    });
  });
}