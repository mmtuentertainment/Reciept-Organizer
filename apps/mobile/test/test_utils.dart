/// Minimal test utilities for Receipt Organizer MVP
/// Following CleanArchitectureTodoApp pattern - keep it simple!

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/main.dart';

/// Simple widget wrapper for testing
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

/// Simple receipt test data
class TestData {
  static final testReceipt = {
    'id': 'test-123',
    'merchantName': 'Test Store',
    'totalAmount': 25.99,
    'date': '12/06/2024',
    'confidence': 95.0,
  };
  
  static final testReceiptList = [
    testReceipt,
    {
      'id': 'test-456', 
      'merchantName': 'Coffee Shop',
      'totalAmount': 4.50,
      'date': '12/07/2024',
      'confidence': 88.0,
    }
  ];
}

/// Run app for integration tests
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: ReceiptOrganizerApp(),
    ),
  );
  await tester.pumpAndSettle();
}