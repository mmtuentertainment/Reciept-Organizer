import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:receipt_organizer/features/receipts/providers/receipts_provider.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/receipt_extended.dart';
import 'package:receipt_organizer/ui/components/shad/shad_components.dart';
import 'package:receipt_organizer/ui/responsive/responsive_builder.dart';
import 'package:receipt_organizer/ui/theme/shadcn_theme_provider.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/receipt_card.dart';
import 'package:receipt_organizer/features/export/presentation/pages/export_screen.dart';

/// Modernized receipts list screen with responsive layout
class ReceiptsListScreenV2 extends ConsumerStatefulWidget {
  const ReceiptsListScreenV2({super.key});

  @override
  ConsumerState<ReceiptsListScreenV2> createState() => _ReceiptsListScreenV2State();
}

class _ReceiptsListScreenV2State extends ConsumerState<ReceiptsListScreenV2> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dateFilter;
  String? _selectedCategory;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ReceiptColors.backgroundDark : ReceiptColors.background,
      appBar: AppBar(
        title: const Text('My Receipts'),
        backgroundColor: isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface,
        foregroundColor: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Toggle Filters',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportScreen()),
              );
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(receiptsAsync, isDark),
        tablet: _buildTabletLayout(receiptsAsync, isDark),
        desktop: _buildDesktopLayout(receiptsAsync, isDark),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/capture');
        },
        backgroundColor: ReceiptColors.success,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildMobileLayout(AsyncValue<List<Receipt>> receiptsAsync, bool isDark) {
    return Column(
      children: [
        _buildSearchBar(isDark),
        if (_showFilters) _buildFilterChips(isDark),
        Expanded(
          child: _buildReceiptsList(receiptsAsync, isDark, columns: 1),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(AsyncValue<List<Receipt>> receiptsAsync, bool isDark) {
    return Row(
      children: [
        // Sidebar filters
        if (_showFilters)
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface,
              border: Border(
                right: BorderSide(
                  color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildSearchBar(isDark),
                Expanded(
                  child: _buildAdvancedFilters(isDark),
                ),
              ],
            ),
          ),
        // Main content
        Expanded(
          child: Column(
            children: [
              if (!_showFilters) _buildSearchBar(isDark),
              Expanded(
                child: _buildReceiptsList(receiptsAsync, isDark, columns: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(AsyncValue<List<Receipt>> receiptsAsync, bool isDark) {
    return Row(
      children: [
        // Sidebar filters
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface,
            border: Border(
              right: BorderSide(
                color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(isDark),
              Expanded(
                child: _buildAdvancedFilters(isDark),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: _buildReceiptsList(receiptsAsync, isDark, columns: 3),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ReceiptColors.backgroundDark : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
          ),
        ),
      ),
      child: AppTextField(
        controller: _searchController,
        placeholder: 'Search by merchant name...',
        prefix: const Icon(Icons.search, size: 20),
        suffix: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                  ref.invalidate(receiptsProvider);
                },
              )
            : null,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchQuery == value && mounted) {
              ref.invalidate(receiptsProvider);
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_dateFilter != null)
            Chip(
              label: Text(
                '${DateFormat('MMM dd').format(_dateFilter!.start)} - ${DateFormat('MMM dd').format(_dateFilter!.end)}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _dateFilter = null;
                });
                ref.invalidate(receiptsProvider);
              },
            ),
          if (_selectedCategory != null)
            Chip(
              label: Text(
                _selectedCategory!,
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedCategory = null;
                });
                ref.invalidate(receiptsProvider);
              },
            ),
          ActionChip(
            label: const Text('Date Range'),
            onPressed: () => _selectDateRange(context),
            avatar: const Icon(Icons.calendar_today, size: 16),
          ),
          ActionChip(
            label: const Text('Category'),
            onPressed: () => _selectCategory(context),
            avatar: const Icon(Icons.category, size: 16),
          ),
          if (_dateFilter != null || _selectedCategory != null || _searchQuery.isNotEmpty)
            ActionChip(
              label: const Text('Clear All'),
              onPressed: () {
                setState(() {
                  _dateFilter = null;
                  _selectedCategory = null;
                  _searchController.clear();
                  _searchQuery = '';
                });
                ref.invalidate(receiptsProvider);
              },
              avatar: const Icon(Icons.clear_all, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Filters',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppOutlineButton(
                onPressed: () => _selectDateRange(context),
                child: Text(
                  _dateFilter != null
                      ? '${DateFormat('MMM dd, yyyy').format(_dateFilter!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateFilter!.end)}'
                      : 'Select Date Range',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppOutlineButton(
                onPressed: () => _selectCategory(context),
                child: Text(_selectedCategory ?? 'All Categories'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickFilter('Today', () {
                    final now = DateTime.now();
                    setState(() {
                      _dateFilter = DateTimeRange(
                        start: DateTime(now.year, now.month, now.day),
                        end: now,
                      );
                    });
                    ref.invalidate(receiptsProvider);
                  }),
                  _buildQuickFilter('This Week', () {
                    final now = DateTime.now();
                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    setState(() {
                      _dateFilter = DateTimeRange(
                        start: startOfWeek,
                        end: now,
                      );
                    });
                    ref.invalidate(receiptsProvider);
                  }),
                  _buildQuickFilter('This Month', () {
                    final now = DateTime.now();
                    setState(() {
                      _dateFilter = DateTimeRange(
                        start: DateTime(now.year, now.month, 1),
                        end: now,
                      );
                    });
                    ref.invalidate(receiptsProvider);
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilter(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: ReceiptColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildReceiptsList(
    AsyncValue<List<Receipt>> receiptsAsync,
    bool isDark, {
    required int columns,
  }) {
    return receiptsAsync.when(
      data: (receipts) {
        final filteredReceipts = _filterReceipts(receipts);

        if (filteredReceipts.isEmpty) {
          return Center(
            child: AppEmptyState(
              icon: Icons.receipt_long,
              title: _searchQuery.isNotEmpty || _dateFilter != null || _selectedCategory != null
                  ? 'No receipts found'
                  : 'No receipts yet',
              description: _searchQuery.isNotEmpty || _dateFilter != null || _selectedCategory != null
                  ? 'Try adjusting your filters'
                  : 'Tap the camera button to capture your first receipt',
              action: _searchQuery.isNotEmpty || _dateFilter != null || _selectedCategory != null
                  ? AppButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _dateFilter = null;
                          _selectedCategory = null;
                        });
                        ref.invalidate(receiptsProvider);
                      },
                      child: const Text('Clear Filters'),
                    )
                  : null,
            ),
          );
        }

        if (columns == 1) {
          // Mobile list view
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(receiptsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReceipts.length,
              itemBuilder: (context, index) {
                final receipt = filteredReceipts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReceiptCard(receipt: receipt),
                );
              },
            ),
          );
        } else {
          // Grid view for tablet/desktop
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(receiptsProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredReceipts.length,
              itemBuilder: (context, index) {
                final receipt = filteredReceipts[index];
                return ReceiptCard(receipt: receipt);
              },
            ),
          );
        }
      },
      loading: () => const Center(child: AppListSkeleton()),
      error: (error, stack) => Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: ReceiptColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load receipts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: ReceiptColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () {
                  ref.invalidate(receiptsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Receipt> _filterReceipts(List<Receipt> receipts) {
    var filtered = receipts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((receipt) {
        final merchantName = receipt.merchant?.toLowerCase() ?? '';
        final description = receipt.description?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return merchantName.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply date filter
    if (_dateFilter != null) {
      filtered = filtered.where((receipt) {
        if (receipt.receiptDate == null) return false;
        final date = DateTime.parse(receipt.receiptDate!);
        return date.isAfter(_dateFilter!.start.subtract(const Duration(days: 1))) &&
            date.isBefore(_dateFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((receipt) {
        return receipt.category == _selectedCategory;
      }).toList();
    }

    // Sort by date descending
    filtered.sort((a, b) {
      if (a.receiptDate == null && b.receiptDate == null) return 0;
      if (a.receiptDate == null) return 1;
      if (b.receiptDate == null) return -1;
      return DateTime.parse(b.receiptDate!).compareTo(DateTime.parse(a.receiptDate!));
    });

    return filtered;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateFilter,
    );

    if (picked != null && mounted) {
      setState(() {
        _dateFilter = picked;
      });
      ref.invalidate(receiptsProvider);
    }
  }

  Future<void> _selectCategory(BuildContext context) async {
    // This would show a category selector dialog
    // For now, we'll use a simple list
    final categories = ['Food', 'Travel', 'Office', 'Entertainment', 'Other'];

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('All Categories'),
                  onTap: () => Navigator.pop(context, null),
                );
              }
              final category = categories[index - 1];
              return ListTile(
                title: Text(category),
                onTap: () => Navigator.pop(context, category),
              );
            },
          ),
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _selectedCategory = selected;
      });
      ref.invalidate(receiptsProvider);
    }
  }
}