import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/procourment/screen/purchase-order_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_order_pdf_screen.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class PurchaseOrderDataScreen extends ConsumerStatefulWidget {
  final String? initialStatus;

  const PurchaseOrderDataScreen({super.key, this.initialStatus});

  @override
  ConsumerState<PurchaseOrderDataScreen> createState() => _PurchaseOrderDataScreenState();
}

class _PurchaseOrderDataScreenState extends ConsumerState<PurchaseOrderDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _selectedStatusFilter = widget.initialStatus ?? 'ALL';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'RECEIVED':
        return const Color(0xFF16A34A);
      case 'ISSUED':
      case 'PARTIALLY_RECEIVED':
        return const Color(0xFF2563EB);
      case 'DRAFT':
        return const Color(0xFFD97706);
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  Future<void> _updatePoStatus(PurchaseOrderResponse po, String newStatus) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref.read(purchaseOrderControllerProvider.notifier).updateStatus(po.id, newStatus);
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('PO #${po.poNumber} status updated to $newStatus successfully.'),
          backgroundColor: _getStatusColor(newStatus),
        ),
      );
    }
  }

  Future<void> _deletePo(int id) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purge Purchase Order'),
        content: Text('Definitively purge Purchase Order #PO-$id record from active directories?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(purchaseOrderControllerProvider.notifier).deletePurchaseOrder(id);
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('PO instance wiped successfully.'), backgroundColor: Color(0xFFDC2626)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);

    final userRole = (currentUser?.role ?? 'PROCUREMENT').toUpperCase();
    final suppliers = suppliersAsync.value ?? [];
    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;

    final isManagementRole = (userRole == 'ADMIN' || userRole == 'MANAGER' || userRole == 'PROCUREMENT');

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: DynamicScmTopNavBar(
        title: 'Purchase Orders',
        showBackButton: true,
        onRefresh: () => ref.invalidate(purchaseOrderListProvider),
      ),
      floatingActionButton: isManagementRole
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add PO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => Navigator.pushNamed(context, '/purchase-order-create'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(purchaseOrderListProvider);
        },
        child: purchaseOrdersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load purchase orders: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(purchaseOrderListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (orders) {
            List<PurchaseOrderResponse> roleFiltered = orders;

            // Role-based data isolation for Suppliers
            if (userRole == 'SUPPLIER' && currentSupplier != null) {
              final supName = currentSupplier.name.trim().toLowerCase();
              roleFiltered = orders.where((po) {
                final isSupplierIdMatch = po.supplierId == currentSupplier.id;
                final isSupplierNameMatch = supName.isNotEmpty && po.supplierName.trim().toLowerCase() == supName;
                return isSupplierIdMatch || isSupplierNameMatch;
              }).toList();
            }

            // Apply searching & status filtering
            final filtered = roleFiltered.where((po) {
              final poNumStr = po.poNumber.toLowerCase();
              final idStr = po.id.toString();
              final matchesSearch = _searchQuery.isEmpty ||
                  poNumStr.contains(_searchQuery.toLowerCase()) ||
                  idStr.contains(_searchQuery.toLowerCase()) ||
                  po.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  po.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  po.expectedDeliveryDate.contains(_searchQuery) ||
                  po.createdAt.contains(_searchQuery);

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  po.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesStatus;
            }).toList();

            // Calculate Metrics
            final totalPOs = roleFiltered.length;
            final draftPOs = roleFiltered.where((po) => po.status.toUpperCase() == 'DRAFT').length;
            final issuedPOs = roleFiltered.where((po) => ['ISSUED', 'PARTIALLY_RECEIVED'].contains(po.status.toUpperCase())).length;
            final completedPOs = roleFiltered.where((po) => ['RECEIVED', 'APPROVED'].contains(po.status.toUpperCase())).length;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Metrics Summary Banner ─────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shopping_cart_checkout_outlined, color: Colors.blueAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'PURCHASE ORDER DIRECTORY SUMMARY',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 500;
                            if (isMobile) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _buildBannerMetric('Total POs', '$totalPOs', Colors.white)),
                                      Expanded(child: _buildBannerMetric('Draft', '$draftPOs', const Color(0xFFFBBF24))),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: _buildBannerMetric('Issued', '$issuedPOs', const Color(0xFF60A5FA))),
                                      Expanded(child: _buildBannerMetric('Completed', '$completedPOs', const Color(0xFF4ADE80))),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: _buildBannerMetric('Total POs', '$totalPOs', Colors.white)),
                                Expanded(child: _buildBannerMetric('Draft', '$draftPOs', const Color(0xFFFBBF24))),
                                Expanded(child: _buildBannerMetric('Issued', '$issuedPOs', const Color(0xFF60A5FA))),
                                Expanded(child: _buildBannerMetric('Completed', '$completedPOs', const Color(0xFF4ADE80))),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 2. Search & Filter Controls ────────────────
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by PO number, supplier name, status...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['ALL', 'DRAFT', 'ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'APPROVED', 'CANCELLED'].map((status) {
                        final isSelected = _selectedStatusFilter == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(
                              status == 'ALL' ? 'All POs ($totalPOs)' : status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300),
                            ),
                            onSelected: (_) => setState(() => _selectedStatusFilter = status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 3. Data Cards List ───────────────────
                  if (filtered.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No purchase orders found.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or filters.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final po = filtered[index];
                        final statusColor = _getStatusColor(po.status);
                        final deliveryDateFormatted = po.expectedDeliveryDate.contains('T')
                            ? po.expectedDeliveryDate.split('T').first
                            : po.expectedDeliveryDate;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.shopping_cart, size: 18, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 8),
                                        Text(
                                          po.poNumber,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A), fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                    // Interactive Status Selector Dropdown for Management, Static Badge for Supplier
                                    if (isManagementRole)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: ['DRAFT', 'ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'APPROVED', 'CANCELLED'].contains(po.status.toUpperCase())
                                                ? po.status.toUpperCase()
                                                : 'DRAFT',
                                            isDense: true,
                                            icon: Icon(Icons.arrow_drop_down, color: statusColor, size: 18),
                                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                            onChanged: (val) {
                                              if (val != null && val != po.status) {
                                                _updatePoStatus(po, val);
                                              }
                                            },
                                            items: const [
                                              DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
                                              DropdownMenuItem(value: 'ISSUED', child: Text('ISSUED')),
                                              DropdownMenuItem(value: 'PARTIALLY_RECEIVED', child: Text('PARTIALLY_RECEIVED')),
                                              DropdownMenuItem(value: 'RECEIVED', child: Text('RECEIVED')),
                                              DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED')),
                                              DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          po.status,
                                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Card Body Content
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Expected Delivery Date & Volume
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('DELIVERY DEADLINE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text(
                                                deliveryDateFormatted.isNotEmpty ? deliveryDateFormatted : 'N/A',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('TOTAL VOLUME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${po.quantity} Units',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('AGGREGATE VALUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text(
                                                '\$${po.totalAmount.toStringAsFixed(2)} ${po.currency}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF16A34A)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Supplier & Linked Requisition Details
                                    const Text('SUPPLIER & REQUISITION MATRIX:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                po.supplierName.isNotEmpty ? po.supplierName : 'Supplier #${po.supplierId}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                              ),
                                              if (po.supplierEmail.isNotEmpty)
                                                Text(
                                                  po.supplierEmail,
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 6,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: Text('PR Node: #${po.purchaseRequisitionId}', style: const TextStyle(color: Color(0xFF334155), fontSize: 10, fontWeight: FontWeight.w600)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: Text('Quotation: #${po.quotationId}', style: const TextStyle(color: Color(0xFF334155), fontSize: 10, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const Divider(height: 16),

                                    // ── Action Buttons Row ──
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        // Track PO Button
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF059669),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.radar, size: 16),
                                          label: const Text('Track Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/track-po',
                                              arguments: po.poNumber,
                                            );
                                          },
                                        ),

                                        // View PO PDF Button
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1E40AF),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                                          label: const Text('View PO Invoice PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PurchaseOrderPDFScreen(order: po),
                                              ),
                                            );
                                          },
                                        ),

                                        if (isManagementRole)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Edit PO Button (Opens PurchaseOrderScreen for full edit)
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                icon: const Icon(Icons.edit_outlined, size: 14),
                                                label: const Text('Edit Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => PurchaseOrderScreen(orderToEdit: po),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 6),
                                              // Delete PO Button
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFDC2626),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                icon: const Icon(Icons.delete_outline, size: 14),
                                                label: const Text('Delete', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                onPressed: () => _deletePo(po.id),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
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

  Widget _buildBannerMetric(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}