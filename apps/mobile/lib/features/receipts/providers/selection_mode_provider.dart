import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:receipt_organizer/core/models/receipt.dart';

part 'selection_mode_provider.freezed.dart';

@freezed
class SelectionModeState with _$SelectionModeState {
  const factory SelectionModeState({
    @Default(false) bool isSelectionMode,
    @Default({}) Set<String> selectedIds,
    @Default([]) List<Receipt> allReceipts,
    String? lastFocusedId,
  }) = _SelectionModeState;
  
  const SelectionModeState._();
  
  int get selectedCount => selectedIds.length;
  
  bool isSelected(String id) => selectedIds.contains(id);
  
  List<Receipt> get selectedReceipts => 
      allReceipts.where((r) => selectedIds.contains(r.id)).toList();
  
  bool get hasSelection => selectedIds.isNotEmpty;
  
  String get selectionSummary {
    if (selectedCount == 0) return 'No items selected';
    if (selectedCount == 1) return '1 item selected';
    return '$selectedCount items selected';
  }
  
  String get accessibilityAnnouncement {
    if (!isSelectionMode) return 'Selection mode disabled';
    if (selectedCount == 0) return 'Selection mode enabled. No items selected';
    return 'Selection mode enabled. $selectionSummary';
  }
}

class SelectionModeNotifier extends StateNotifier<SelectionModeState> {
  SelectionModeNotifier() : super(const SelectionModeState());
  
  void enterSelectionMode({String? initialSelection}) {
    state = state.copyWith(
      isSelectionMode: true,
      selectedIds: initialSelection != null ? {initialSelection} : {},
    );
  }
  
  void exitSelectionMode() {
    state = const SelectionModeState();
  }
  
  void toggleSelection(String id) {
    if (!state.isSelectionMode) {
      // Auto-enter selection mode on first selection
      enterSelectionMode(initialSelection: id);
      return;
    }
    
    final newSelectedIds = Set<String>.from(state.selectedIds);
    if (newSelectedIds.contains(id)) {
      newSelectedIds.remove(id);
      
      // Exit selection mode if no items selected
      if (newSelectedIds.isEmpty) {
        exitSelectionMode();
        return;
      }
    } else {
      newSelectedIds.add(id);
    }
    
    state = state.copyWith(
      selectedIds: newSelectedIds,
      lastFocusedId: id,
    );
  }
  
  void selectAll(List<Receipt> receipts) {
    if (!state.isSelectionMode) {
      enterSelectionMode();
    }
    
    state = state.copyWith(
      selectedIds: receipts.map((r) => r.id).toSet(),
      allReceipts: receipts,
    );
  }
  
  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }
  
  void selectRange(String fromId, String toId, List<Receipt> receipts) {
    if (!state.isSelectionMode) {
      enterSelectionMode();
    }
    
    final fromIndex = receipts.indexWhere((r) => r.id == fromId);
    final toIndex = receipts.indexWhere((r) => r.id == toId);
    
    if (fromIndex == -1 || toIndex == -1) return;
    
    final start = fromIndex < toIndex ? fromIndex : toIndex;
    final end = fromIndex < toIndex ? toIndex : fromIndex;
    
    final rangeIds = receipts
        .sublist(start, end + 1)
        .map((r) => r.id)
        .toSet();
    
    state = state.copyWith(
      selectedIds: state.selectedIds.union(rangeIds),
      allReceipts: receipts,
      lastFocusedId: toId,
    );
  }
  
  void updateAvailableReceipts(List<Receipt> receipts) {
    // Remove selected IDs that are no longer in the list
    final availableIds = receipts.map((r) => r.id).toSet();
    final validSelectedIds = state.selectedIds.intersection(availableIds);
    
    state = state.copyWith(
      allReceipts: receipts,
      selectedIds: validSelectedIds,
    );
    
    // Exit selection mode if no valid selections remain
    if (state.isSelectionMode && validSelectedIds.isEmpty) {
      exitSelectionMode();
    }
  }
  
  void removeFromSelection(List<String> ids) {
    final newSelectedIds = Set<String>.from(state.selectedIds);
    newSelectedIds.removeAll(ids);
    
    if (newSelectedIds.isEmpty && state.isSelectionMode) {
      exitSelectionMode();
    } else {
      state = state.copyWith(selectedIds: newSelectedIds);
    }
  }
}

final selectionModeProvider = 
    StateNotifierProvider<SelectionModeNotifier, SelectionModeState>((ref) {
  return SelectionModeNotifier();
});

// Convenience providers
final isSelectionModeProvider = Provider<bool>((ref) {
  return ref.watch(selectionModeProvider).isSelectionMode;
});

final selectedCountProvider = Provider<int>((ref) {
  return ref.watch(selectionModeProvider).selectedCount;
});

final selectedReceiptsProvider = Provider<List<Receipt>>((ref) {
  return ref.watch(selectionModeProvider).selectedReceipts;
});

final hasSelectionProvider = Provider<bool>((ref) {
  return ref.watch(selectionModeProvider).hasSelection;
});