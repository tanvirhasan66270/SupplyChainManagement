import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/inventory_model.dart';
import 'package:scm_flutter/logistics_officer/provider/inventory_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/inventory_data_pdf_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/inventory_form_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class InventoryDataScreen extends ConsumerStatefulWidget {
  const InventoryDataScreen({super.key});

  @override
  ConsumerState<InventoryDataScreen> createState() => _InventoryDataScreenState();
}

class _InventoryDataScreenState extends ConsumerState<InventoryDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case StockStatus.inStock:
        return AppTheme.success;
      case StockStatus.lowStock:
        return AppTheme.warning;
      case StockStatus.outOfStock:
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toUpperCase()) {
      case StockStatus.inStock:
        return AppTheme.successLight;
      case StockStatus.lowStock:
        return AppTheme.warningLight;
      case StockStatus.outOfStock:
        return AppTheme.dangerLight;
      default:
        return AppTheme.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userRole = currentUser?.role.toUpperCase() ?? '';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Warehouse Stock Inventory',
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
          MaterialPageRoute(builder: (_) => const InventoryFormScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: AppTheme.surfaceWhite),
        label: const Text(
          'Create Stock Node',
          style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inventoryListProvider);
        },
        child: inventoryAsync.when(
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
                    'Failed to load inventory: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(inventoryListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (inventories) {
            final filteredList = inventories.where((i) {
              final matchesSearch = _searchQuery.isEmpty ||
                  'STK-${i.id}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.productCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.warehouseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.locationStatus.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.stockStatus.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesFilter = _selectedStatusFilter == 'ALL' ||
                  i.stockStatus.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesFilter;
            }).toList();

            int inStockCount = inventories.where((i) => i.stockStatus == StockStatus.inStock).length;
            int lowStockCount = inventories.where((i) => i.stockStatus == StockStatus.lowStock).length;
            int outOfStockCount = inventories.where((i) => i.stockStatus == StockStatus.outOfStock).length;

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
                            Icon(Icons.inventory_2_outlined, color: AppTheme.primaryLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'WAREHOUSE STOCK MATRIX SUMMARY',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildBannerMetric('Total Items', '${inventories.length}', AppTheme.surfaceWhite)),
                            Expanded(child: _buildBannerMetric('In Stock', '$inStockCount', AppTheme.success)),
                            Expanded(child: _buildBannerMetric('Low Stock', '$lowStockCount', AppTheme.warning)),
                            Expanded(child: _buildBannerMetric('Out of Stock', '$outOfStockCount', AppTheme.danger)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ২. Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by Stock ID, Product, Code, Warehouse, Location...',
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

                  // ৩. Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Items (${inventories.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip(StockStatus.inStock, 'In Stock ($inStockCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip(StockStatus.lowStock, 'Low Stock ($lowStockCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip(StockStatus.outOfStock, 'Out of Stock ($outOfStockCount)'),
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
                          Icon(Icons.inventory, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No structural inventory records found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or status filter.', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
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
                        final stColor = _getStatusColor(item.stockStatus);
                        final stBg = _getStatusBg(item.stockStatus);

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
                                    child: Text('STK-${item.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      item.stockStatus,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stColor),
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
                              Text(
                                'Code: ${item.productCode}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.indigo, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.storefront_outlined, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(item.warehouseName, style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text('On Hand: ${item.quantityOnHand}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.light,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('Reserved: ${item.quantityReserved}', style: const TextStyle(fontSize: 10, color: AppTheme.danger, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.dangerLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('Available: ${item.availableQuantity}', style: const TextStyle(fontSize: 10, color: AppTheme.success, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.successLight,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.pin_drop_outlined, size: 13, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.locationStatus.isNotEmpty ? item.locationStatus : 'Unassigned Location',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                  ),
                                  if (item.expiryDate.isNotEmpty) ...[
                                    const SizedBox(width: 16),
                                    const Icon(Icons.event_outlined, size: 13, color: AppTheme.warning),
                                    const SizedBox(width: 4),
                                    Text('Exp: ${item.expiryDate}', style: const TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.bold)),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderGrey),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Updated: ${item.lastUpdated}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                  ),
                                  Row(
                                    children: [
                                      // Status edit button for LOGISTICS_OFFICER, MANAGER, ADMIN
                                      if (['LOGISTICS_OFFICER', 'MANAGER', 'ADMIN', 'ROLE_LOGISTICS_OFFICER'].contains(userRole))
                                        IconButton(
                                          tooltip: 'Update Stock Status',
                                          icon: const Icon(Icons.shield_outlined, color: AppTheme.success, size: 18),
                                          onPressed: () => _showStatusChangeDialog(context, item),
                                        ),
                                      IconButton(
                                        tooltip: 'View PDF Report',
                                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.danger, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => InventoryDataPDFScreen(inventory: item),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit Parameters',
                                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => InventoryFormScreen(inventoryToEdit: item),
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
                                              title: const Text('Purge Inventory Record?'),
                                              content: const Text('Are you sure you want to completely purge this inventory record from storage maps?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Purge', style: TextStyle(color: AppTheme.danger))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await ref.read(inventoryControllerProvider.notifier).deleteInventory(item.id);
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

  Widget _buildFilterChip(String statusKey, String label) {
    final isSelected = _selectedStatusFilter == statusKey;
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
          _selectedStatusFilter = selected ? statusKey : 'ALL';
        });
      },
    );
  }

  void _showStatusChangeDialog(BuildContext context, InventoryResponseModel item) {
    String selected = item.stockStatus;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Stock Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('IN_STOCK', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                trailing: selected == StockStatus.inStock ? const Icon(Icons.check_circle, color: AppTheme.success) : null,
                onTap: () => setDialogState(() => selected = StockStatus.inStock),
              ),
              ListTile(
                title: const Text('LOW_STOCK', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                trailing: selected == StockStatus.lowStock ? const Icon(Icons.check_circle, color: AppTheme.warning) : null,
                onTap: () => setDialogState(() => selected = StockStatus.lowStock),
              ),
              ListTile(
                title: const Text('OUT_OF_STOCK', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 12)),
                trailing: selected == StockStatus.outOfStock ? const Icon(Icons.check_circle, color: AppTheme.danger) : null,
                onTap: () => setDialogState(() => selected = StockStatus.outOfStock),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final payload = InventoryRequestModel(
                productId: item.productId,
                warehouseId: item.warehouseId,
                quantityOnHand: item.quantityOnHand,
                quantityReserved: item.quantityReserved,
                locationStatus: item.locationStatus,
                expiryDate: item.expiryDate.isNotEmpty ? item.expiryDate : null,
                stockStatus: selected,
              );
              await ref.read(inventoryControllerProvider.notifier).updateInventory(item.id, payload);
            },
            child: const Text('Save Status', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
