import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/po_line_item_model.dart';
import 'package:scm_flutter/suppplier/provider/po_line_item_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/suppplier/screen/po_line_item_form_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class POLineItemDataScreen extends ConsumerStatefulWidget {
  const POLineItemDataScreen({super.key});

  @override
  ConsumerState<POLineItemDataScreen> createState() => _POLineItemDataScreenState();
}

class _POLineItemDataScreenState extends ConsumerState<POLineItemDataScreen> {
  String searchPoNum = '';
  String searchProductName = '';
  String searchSupplierName = '';
  String searchStatus = '';

  void _deleteLineItem(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this PO line item allocation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(poLineItemControllerProvider.notifier).deleteLineItem(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Line item deleted successfully' : 'Failed to delete line item'),
            backgroundColor: success ? AppTheme.success : AppTheme.danger,
          ),
        );
      }
    }
  }

  void _updateStatus(POLineItemResponseDTO item, String newStatus) async {
    final req = POLineItemRequestDTO(
      poId: item.poId,
      productId: item.productId,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      quotationRef: item.quotationRef,
      poNumber: item.poNumber,
      deliveryDate: item.deliveryDate,
      shipmentMethod: item.shipmentMethod,
      notes: item.notes,
      status: newStatus,
    );

    final success = await ref.read(poLineItemControllerProvider.notifier).updateLineItem(item.id, req);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Status updated to $newStatus' : 'Failed to update status'),
          backgroundColor: success ? AppTheme.success : AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lineItemsAsync = ref.watch(poLineItemListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);
    final currentUser = ref.watch(currentUserProvider);

    final userRole = (currentUser?.role ?? 'PROCUREMENT').toUpperCase();
    final suppliers = suppliersAsync.value ?? [];
    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: DynamicScmTopNavBar(
        title: 'PO Line Items Matrix',
        showBackButton: true,
        onRefresh: () => ref.invalidate(poLineItemListProvider),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(poLineItemListProvider),
          child: Column(
            children: [
              // ── 1. Top Title & Summary Banner Card ──
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'PO Line Items Allocation Matrix',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.only(left: 28.0),
                            child: Text(
                              'Track item allocations, status workflows, unit valuations, and linked PO nodes.',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Search & Status Filter Controls (Android Responsive) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final poSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search PO No...'),
                      onChanged: (val) => setState(() => searchPoNum = val),
                    );

                    final prodSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search Product...'),
                      onChanged: (val) => setState(() => searchProductName = val),
                    );

                    final supSearch = TextField(
                      decoration: _searchDecoration(hint: 'Search Supplier...'),
                      onChanged: (val) => setState(() => searchSupplierName = val),
                    );

                    final statusDropdown = DropdownButtonFormField<String>(
                      initialValue: searchStatus.isEmpty ? '' : searchStatus,
                      decoration: _searchDecoration(hint: 'Status'),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All Status', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'PENDING', child: Text('PENDING', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'SHIPPED', child: Text('SHIPPED', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED', style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED', style: TextStyle(fontSize: 11))),
                      ],
                      onChanged: (val) => setState(() => searchStatus = val ?? ''),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: poSearch),
                              const SizedBox(width: 8),
                              Expanded(child: prodSearch),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (userRole != 'SUPPLIER') ...[
                                Expanded(child: supSearch),
                                const SizedBox(width: 8),
                              ],
                              Expanded(child: statusDropdown),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: poSearch),
                        const SizedBox(width: 8),
                        Expanded(child: prodSearch),
                        if (userRole != 'SUPPLIER') ...[
                          const SizedBox(width: 8),
                          Expanded(child: supSearch),
                        ],
                        const SizedBox(width: 8),
                        Expanded(child: statusDropdown),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── 3. Line Items List Vector ──
              Expanded(
                child: lineItemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                          const SizedBox(height: 12),
                          Text('Failed to load line items: $err', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(poLineItemListProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (items) {
                    List<POLineItemResponseDTO> roleFiltered = items;

                    // Role-based data isolation for Suppliers
                    if (userRole == 'SUPPLIER' && currentSupplier != null) {
                      final supName = currentSupplier.name.trim().toLowerCase();
                      roleFiltered = items.where((i) {
                        final isSupplierIdMatch = i.supplierId == currentSupplier.id.toString();
                        final isSupplierNameMatch = supName.isNotEmpty && i.supplierName.trim().toLowerCase() == supName;
                        return isSupplierIdMatch || isSupplierNameMatch;
                      }).toList();
                    }

                    // Apply Search Filters
                    final filtered = roleFiltered.where((i) {
                      final poNoStr = (i.poNumber.isNotEmpty ? i.poNumber : '#PO-${i.poId}').toLowerCase();
                      final prodName = i.productName.toLowerCase();
                      final supName = i.supplierName.toLowerCase();
                      final status = i.status.toLowerCase();

                      final matchesPo = searchPoNum.isEmpty || poNoStr.contains(searchPoNum.toLowerCase().trim());
                      final matchesProd = searchProductName.isEmpty || prodName.contains(searchProductName.toLowerCase().trim());
                      final matchesSup = searchSupplierName.isEmpty || supName.contains(searchSupplierName.toLowerCase().trim());
                      final matchesStatus = searchStatus.isEmpty || status.contains(searchStatus.toLowerCase().trim());

                      return matchesPo && matchesProd && matchesSup && matchesStatus;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_outlined, size: 48, color: AppTheme.secondary),
                              SizedBox(height: 8),
                              Text('No PO line items match your criteria.', style: TextStyle(color: AppTheme.secondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final statusColor = AppTheme.statusColor(item.status);
                        final subtotal = item.quantity * item.unitPrice;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                            border: Border.all(color: AppTheme.light),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Item Badge, Linked PO No & Status Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.dark,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.poNumber.isNotEmpty ? item.poNumber : '#PO-${item.poId}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Text(
                                        item.productName.isNotEmpty ? item.productName : 'Product #${item.productId}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Meta Subrow: Supplier & Code
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Supplier: ${item.supplierName.isNotEmpty ? item.supplierName : "Supplier #${item.supplierId}"}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.w500),
                                  ),
                                  if (item.productCode.isNotEmpty)
                                    Text(
                                      'Code: ${item.productCode}',
                                      style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                    ),
                                ],
                              ),

                              const Divider(height: 16),

                              // Valuation & Quantity Grid
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$${item.unitPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark, fontFamily: 'monospace'),
                                      ),
                                      const Text('Unit Price', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${item.quantity} Units',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark, fontFamily: 'monospace'),
                                      ),
                                      const Text('Allocated Qty', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.success, fontFamily: 'monospace'),
                                      ),
                                      const Text('Line Subtotal', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Bottom Action Row
                              Row(
                                children: [
                                  if (userRole == 'ADMIN' || userRole == 'PROCUREMENT' || userRole == 'MANAGER')
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: ['PENDING', 'APPROVED', 'SHIPPED', 'DELIVERED', 'CANCELLED'].contains(item.status) ? item.status : 'PENDING',
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          border: OutlineInputBorder(),
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: 'PENDING', child: Text('PENDING', style: TextStyle(fontSize: 10))),
                                          DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED', style: TextStyle(fontSize: 10))),
                                          DropdownMenuItem(value: 'SHIPPED', child: Text('SHIPPED', style: TextStyle(fontSize: 10))),
                                          DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED', style: TextStyle(fontSize: 10))),
                                          DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED', style: TextStyle(fontSize: 10))),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) _updateStatus(item, val);
                                        },
                                      ),
                                    ),
                                  const Spacer(),
                                  // Edit Button for Pending
                                  if (userRole == 'ADMIN' || userRole == 'MANAGER' || userRole == 'PROCUREMENT' || (userRole == 'SUPPLIER' && item.status == 'PENDING')) ...[
                                    _buildActionButton(
                                      icon: Icons.edit_outlined,
                                      color: AppTheme.primary,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => POLineItemFormScreen(itemToEdit: item)),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  // Delete Button
                                  if (userRole == 'ADMIN' || userRole == 'MANAGER' || userRole == 'PROCUREMENT') ...[
                                    _buildActionButton(
                                      icon: Icons.delete_outline,
                                      color: AppTheme.danger,
                                      onTap: () => _deleteLineItem(item.id),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _searchDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: AppTheme.secondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
