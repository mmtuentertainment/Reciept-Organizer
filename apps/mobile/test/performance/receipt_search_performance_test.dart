import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/receipts/providers/receipt_list_provider.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('Receipt Search Performance', () {
    late ProviderContainer container;
    late ReceiptListNotifier notifier;
    late List<Receipt> largeDataset;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(receiptListProvider.notifier);
      
      // Generate 1000+ receipts with varied notes content
      largeDataset = _generateLargeReceiptDataset(1500);
    });

    tearDown(() {
      container.dispose();
    });

    test('should search through 1000+ receipts with notes in under 100ms', () {
      // Given - Load large dataset
      notifier.state = notifier.state.copyWith(
        receipts: largeDataset,
        filteredReceipts: largeDataset,
      );

      // When - Perform various searches and measure time
      final searchQueries = [
        'meeting',
        'expense',
        'client',
        'quarterly',
        'tax',
        '2024',
        'abc123', // Non-existent
      ];

      for (final query in searchQueries) {
        final stopwatch = Stopwatch()..start();
        
        notifier.searchReceipts(query);
        
        stopwatch.stop();
        
        // Then - Verify performance
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'Search for "$query" took ${stopwatch.elapsedMilliseconds}ms, '
              'exceeding 100ms threshold',
        );
        
        // Verify results are correct
        final state = container.read(receiptListProvider);
        final expectedCount = largeDataset.where((r) {
          final lowerQuery = query.toLowerCase();
          return r.merchantName?.toLowerCase().contains(lowerQuery) == true ||
              r.receiptDate?.toLowerCase().contains(lowerQuery) == true ||
              r.notes?.toLowerCase().contains(lowerQuery) == true ||
              (r.totalAmount?.toStringAsFixed(2).contains(lowerQuery) ?? false);
        }).length;
        
        expect(
          state.filteredReceipts.length,
          equals(expectedCount),
          reason: 'Search results count mismatch for query "$query"',
        );
      }
    });

    test('should handle rapid consecutive searches efficiently', () {
      // Given
      notifier.state = notifier.state.copyWith(
        receipts: largeDataset,
        filteredReceipts: largeDataset,
      );

      // When - Simulate rapid typing
      final typingSequence = ['m', 'me', 'mee', 'meet', 'meeti', 'meetin', 'meeting'];
      final stopwatch = Stopwatch()..start();
      
      for (final partial in typingSequence) {
        notifier.searchReceipts(partial);
      }
      
      stopwatch.stop();
      
      // Then - All searches combined should be fast
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(200),
        reason: 'Rapid search sequence took ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('should maintain performance with complex search patterns', () {
      // Given
      notifier.state = notifier.state.copyWith(
        receipts: largeDataset,
        filteredReceipts: largeDataset,
      );

      // When - Search with special characters and numbers
      final complexQueries = [
        '@',
        '#tag',
        '\$100',
        '50.00',
        'meeting @ 3PM',
        'Q1-2024',
      ];

      for (final query in complexQueries) {
        final stopwatch = Stopwatch()..start();
        
        notifier.searchReceipts(query);
        
        stopwatch.stop();
        
        // Then
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'Complex search "$query" exceeded performance threshold',
        );
      }
    });

    test('should scale linearly with dataset size', () {
      // Test with different dataset sizes
      final sizes = [100, 500, 1000, 2000];
      final timings = <int, int>{};
      
      for (final size in sizes) {
        final dataset = _generateLargeReceiptDataset(size);
        notifier.state = notifier.state.copyWith(
          receipts: dataset,
          filteredReceipts: dataset,
        );
        
        final stopwatch = Stopwatch()..start();
        notifier.searchReceipts('test');
        stopwatch.stop();
        
        timings[size] = stopwatch.elapsedMilliseconds;
      }
      
      // Verify roughly linear scaling
      // Time for 2000 should be less than 2.5x time for 1000
      final ratio = timings[2000]! / timings[1000]!;
      expect(
        ratio,
        lessThan(2.5),
        reason: 'Search performance does not scale linearly. '
            'Timings: $timings, ratio: $ratio',
      );
    });
  });
}

/// Generate a large dataset of receipts with realistic data
List<Receipt> _generateLargeReceiptDataset(int count) {
  final merchants = [
    'Costco', 'Target', 'Walmart', 'Home Depot', 'Starbucks',
    'Amazon', 'Best Buy', 'CVS Pharmacy', 'Whole Foods', 'Office Depot',
  ];
  
  final noteTemplates = [
    'Business meeting with {name}',
    'Office supplies for {project}',
    'Client lunch - {topic} discussion',
    'Quarterly expense for {department}',
    'Tax deductible - {category}',
    'Team building event at {location}',
    'Conference materials for {event}',
    'Travel expense - {destination}',
    'Equipment purchase for {purpose}',
    'Marketing expense - {campaign}',
  ];
  
  final names = ['John', 'Sarah', 'Mike', 'Lisa', 'David'];
  final projects = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon'];
  final topics = ['strategy', 'budget', 'roadmap', 'hiring', 'expansion'];
  final departments = ['Engineering', 'Sales', 'Marketing', 'HR', 'Finance'];
  final categories = ['meals', 'supplies', 'travel', 'equipment', 'services'];
  
  return List.generate(count, (index) {
    final merchant = merchants[index % merchants.length];
    final date = DateTime.now().subtract(Duration(days: index % 365));
    final total = 10.0 + (index % 1000);
    final tax = total * 0.08;
    
    // Generate varied notes content
    String? notes;
    if (index % 3 != 0) { // 2/3 have notes
      final template = noteTemplates[index % noteTemplates.length];
      notes = template
          .replaceAll('{name}', names[index % names.length])
          .replaceAll('{project}', projects[index % projects.length])
          .replaceAll('{topic}', topics[index % topics.length])
          .replaceAll('{department}', departments[index % departments.length])
          .replaceAll('{category}', categories[index % categories.length])
          .replaceAll('{location}', merchant)
          .replaceAll('{event}', 'Summit ${date.year}')
          .replaceAll('{destination}', 'City ${index % 50}')
          .replaceAll('{purpose}', 'Project ${index % 20}')
          .replaceAll('{campaign}', 'Campaign ${index % 15}');
    }
    
    return Receipt(
      id: 'receipt_$index',
      imageUri: 'path/to/image_$index.jpg',
      capturedAt: date,
      status: ReceiptStatus.ready,
      notes: notes,
      ocrResults: ProcessingResult(
        merchant: FieldData(value: merchant, confidence: 90 + (index % 10).toDouble(), originalText: merchant),
        date: FieldData(
          value: '${date.month}/${date.day}/${date.year}',
          confidence: 95 - (index % 10).toDouble(),
          originalText: '${date.month}/${date.day}/${date.year}',
        ),
        total: FieldData(value: total, confidence: 92 + (index % 8).toDouble(), originalText: total.toString()),
        tax: FieldData(value: tax, confidence: 88 + (index % 12).toDouble(), originalText: tax.toString()),
        overallConfidence: 91.0,
        processingDurationMs: 1000,
      ),
    );
  });
}