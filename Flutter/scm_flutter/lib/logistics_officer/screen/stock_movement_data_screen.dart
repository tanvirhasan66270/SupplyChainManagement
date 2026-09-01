import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/logistics_officer/provider/stock_movement_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/stock_movement_pdf_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/stock_movement_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class StockMovementDataScreen extends ConsumerStatefulWidget {
  const StockMovementDataScreen({super.key});

  @override
  ConsumerState<StockMovementDataScreen> createState() => _StockMovementDataScreenState();
}

class _StockMovementDataScreenState extends ConsumerState<StockMovementDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTypeFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'INWARD':
        return AppTheme.success;
      case 'OUTWARD':
        return AppTheme.danger;
      case 'TRANSFER':
        return AppTheme.primary;
      case 'ADJUSTMENT':
        return AppTheme.warning;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getTypeBg(String type) {
    switch (type.toUpperCase()) {
      case 'INWARD':
        return AppTheme.successLight;
      case 'OUTWARD':
        return AppTheme.dangerLight;
      case 'TRANSFER':
        return AppTheme.infoLight;
      case 'ADJUSTMENT':
        return AppTheme.warningLight;
      default:
        return AppTheme.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(stockMovementListProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Stock Movement Ledger',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StockMovementScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.swap_horiz, color: AppTheme.surfaceWhite),
        label: const Text(
          'Log Stock Movement',
          style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockMovementListProvider);
        },
        child: movementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load stock movements: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(stockMovementListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (movements) {
            final filteredList = movements.where((m) {
              final matchesSearch = _searchQuery.isEmpty ||
                  'LOG-${m.id}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.referenceId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.warehouseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.movementType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.performedByName.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesFilter = _selectedTypeFilter == 'ALL' ||
                  m.movementType.toUpperCase() == _selectedTypeFilter;

              return matchesSearch && matchesFilter;
            }).toList();

            int inwardCount = movements.where((m) => m.movementType == 'INWARD').length;
            int outwardCount = movements.where((m) => m.movementType == 'OUTWARD').length;
            int transferCount = movements.where((m) => m.movementType == 'TRANSFER').length;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ১. Summary Metrics Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.dark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.swap_horiz, color: AppTheme.primaryLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'STOCK MOVEMENT FLOW SUMMARY',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildBannerMetric('Total Logs', '${movements.length}', AppTheme.surfaceWhite)),
                            Expanded(child: _buildBannerMetric('Inward', '$inwardCount', AppTheme.success)),
                            Expanded(child: _buildBannerMetric('Outward', '$outwardCount', AppTheme.danger)),
                            Expanded(child: _buildBannerMetric('Transfers', '$transferCount', AppTheme.warning)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ২. Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by Log ID, Product, Reference, Type, Warehouse...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.secondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ৩. Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Logs (${movements.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip('INWARD', 'Inward ($inwardCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('OUTWARD', 'Outward ($outwardCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('TRANSFER', 'Transfers ($transferCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('ADJUSTMENT', 'Adjustments'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ৪. Data List Cards
                  if (filteredList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.swap_horizontal_circle_outlined, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No stock movement logs found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or movement filter.', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final typeColor = _getTypeColor(item.movementType);
                        final typeBg = _getTypeBg(item.movementType);

                        String sourceText = 'External Vendor / Supply Chain';
                        if (item.movementType == 'TRANSFER') {
                          sourceText = item.sourceWarehouseName ?? 'Origin Facility';
                        } else if (item.movementType == 'OUTWARD' || item.movementType == 'ADJUSTMENT') {
                          sourceText = item.warehouseName;
                        }

                        String targetText = item.movementType == 'OUTWARD' ? 'External Customer' : item.warehouseName;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderGrey),
                            boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.light,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.borderGrey),
                                    ),
                                    child: Text('LOG-${item.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      item.movementType,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.productName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark),
                              ),
                              const SizedBox(height: 2),
                              Text('Product ID: #${item.productId}', style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_upward, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'From: $sourceText',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_downward, size: 14, color: AppTheme.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'To: $targetText',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text('Volume: ${item.quantity} Units', style: const TextStyle(fontSize: 10, color: AppTheme.indigo, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.light,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('Ref: ${item.referenceId}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.light,
                                  ),
                                ],
                              ),
                              if (item.remarks.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Rem: ${item.remarks}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderGrey),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Logged By: ${item.performedByName}', style: const TextStyle(fontSize: 10, color: AppTheme.dark, fontWeight: FontWeight.bold)),
                                      Text(item.movedAt, style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'View PDF Report',
                                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.danger, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StockMovementPDFScreen(movement: item),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Purge Record',
                                        icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Purge Movement Log?'),
                                              content: const Text('Are you sure you want to delete this log transaction entry?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Purge', style: TextStyle(color: AppTheme.danger))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await ref.read(stockMovementControllerProvider.notifier).deleteMovement(item.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBannerMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.surfaceWhite.withValues(alpha: 0.7), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildFilterChip(String typeKey, String label) {
    final isSelected = _selectedTypeFilter == typeKey;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isSelected ? AppTheme.surfaceWhite : AppTheme.dark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: AppTheme.surfaceWhite,
      selectedColor: AppTheme.primary,
      checkmarkColor: AppTheme.surfaceWhite,
      side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderGrey),
      onSelected: (selected) {
        setState(() {
          _selectedTypeFilter = selected ? typeKey : 'ALL';
        });
      },
    );
  }
}
