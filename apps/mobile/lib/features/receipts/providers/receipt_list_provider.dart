import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';

/// State for the receipt list including search functionality
class ReceiptListState {
  final List<Receipt> receipts;
  final List<Receipt> filteredReceipts;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const ReceiptListState({
    this.receipts = const [],
    this.filteredReceipts = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ReceiptListState copyWith({
    List<Receipt>? receipts,
    List<Receipt>? filteredReceipts,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ReceiptListState(
      receipts: receipts ?? this.receipts,
      filteredReceipts: filteredReceipts ?? this.filteredReceipts,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for managing receipt list and search functionality
class ReceiptListNotifier extends StateNotifier<ReceiptListState> {
  ReceiptListNotifier() : super(const ReceiptListState());

  /// Loads all receipts from storage
  Future<void> loadReceipts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual data loading from repository
      // For now, using mock data
      final receipts = _getMockReceipts();
      
      state = state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load receipts: $e',
      );
    }
  }

  /// Searches receipts by query including notes field
  void searchReceipts(String query) {
    state = state.copyWith(searchQuery: query);

    if (query.isEmpty) {
      state = state.copyWith(filteredReceipts: state.receipts);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = state.receipts.where((receipt) {
      // Search in merchant name
      if (receipt.merchantName?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in date
      if (receipt.receiptDate != null) {
        final dateStr = receipt.receiptDate!.toString().toLowerCase();
        if (dateStr.contains(lowercaseQuery)) {
          return true;
        }
      }

      // Search in notes
      if (receipt.notes?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in total amount (convert to string for searching)
      if (receipt.totalAmount != null) {
        final totalStr = receipt.totalAmount!.toStringAsFixed(2);
        if (totalStr.contains(lowercaseQuery)) {
          return true;
        }
      }

      // Search in tax amount
      if (receipt.taxAmount != null) {
        final taxStr = receipt.taxAmount!.toStringAsFixed(2);
        if (taxStr.contains(lowercaseQuery)) {
          return true;
        }
      }

      return false;
    }).toList();

    state = state.copyWith(filteredReceipts: filtered);
  }

  /// Adds a new receipt to the list
  void addReceipt(Receipt receipt) {
    final updatedReceipts = [...state.receipts, receipt];
    state = state.copyWith(receipts: updatedReceipts);
    
    // Re-apply search if active
    if (state.searchQuery.isNotEmpty) {
      searchReceipts(state.searchQuery);
    } else {
      state = state.copyWith(filteredReceipts: updatedReceipts);
    }
  }

  /// Updates an existing receipt
  void updateReceipt(Receipt updatedReceipt) {
    final updatedReceipts = state.receipts.map((r) {
      return r.id == updatedReceipt.id ? updatedReceipt : r;
    }).toList();

    state = state.copyWith(receipts: updatedReceipts);
    
    // Re-apply search if active
    if (state.searchQuery.isNotEmpty) {
      searchReceipts(state.searchQuery);
    } else {
      state = state.copyWith(filteredReceipts: updatedReceipts);
    }
  }

  /// Deletes a receipt
  void deleteReceipt(String receiptId) {
    final updatedReceipts = state.receipts.where((r) => r.id != receiptId).toList();
    state = state.copyWith(receipts: updatedReceipts);
    
    // Re-apply search if active
    if (state.searchQuery.isNotEmpty) {
      searchReceipts(state.searchQuery);
    } else {
      state = state.copyWith(filteredReceipts: updatedReceipts);
    }
  }

  /// Clears the search query
  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      filteredReceipts: state.receipts,
    );
  }

  // Mock data for testing
  List<Receipt> _getMockReceipts() {
    return [
      Receipt(
        id: '1',
        imageUri: 'path/to/image1.jpg',
        capturedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: ReceiptStatus.ready,
        notes: 'Business lunch with client discussing Q4 strategy',
      ),
      Receipt(
        id: '2',
        imageUri: 'path/to/image2.jpg',
        capturedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: ReceiptStatus.ready,
        notes: 'Office supplies for new project',
      ),
      Receipt(
        id: '3',
        imageUri: 'path/to/image3.jpg',
        capturedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: ReceiptStatus.ready,
        notes: null, // No notes
      ),
    ];
  }
}

/// Provider instance for receipt list
final receiptListProvider = StateNotifierProvider<ReceiptListNotifier, ReceiptListState>((ref) {
  return ReceiptListNotifier();
});

/// Provider for filtered receipts count
final filteredReceiptCountProvider = Provider<int>((ref) {
  final state = ref.watch(receiptListProvider);
  return state.filteredReceipts.length;
});

/// Provider for checking if search is active
final isSearchActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(receiptListProvider);
  return state.searchQuery.isNotEmpty;
});