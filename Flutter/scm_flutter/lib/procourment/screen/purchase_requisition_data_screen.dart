import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_data_pdf_screen.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class PurchaseRequisitionDataScreen extends ConsumerStatefulWidget {
  const PurchaseRequisitionDataScreen({super.key});

  @override
  ConsumerState<PurchaseRequisitionDataScreen> createState() => _PurchaseRequisitionDataScreenState();
}

class _PurchaseRequisitionDataScreenState extends ConsumerState<PurchaseRequisitionDataScreen> {
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
      case 'APPROVED':
        return AppTheme.success;
      case 'PENDING':
        return AppTheme.warning;
      case 'REJECTED':
      case 'CANCELLED':
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'CRITICAL':
        return AppTheme.danger;
      case 'HIGH':
        return AppTheme.warning;
      case 'MEDIUM':
        return AppTheme.primary;
      case 'LOW':
      default:
        return AppTheme.secondary;
    }
  }

  Future<void> _authorizeApproval(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authorize Requisition Approval'),
        content: Text('Are you sure you want to APPROVE purchase requisition #PRQ-$id?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: AppTheme.surfaceWhite),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('APPROVE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(purchaseRequisitionControllerProvider.notifier).authorizeApproval(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Requisition #PRQ-$id APPROVED successfully!'), backgroundColor: AppTheme.success),
        );
      }
    }
  }

  Future<void> _authorizeRejection(int id, String action) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Register $action Requisition'),
        content: Text('Are you sure you want to $action purchase requisition #PRQ-$id?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('BACK')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: AppTheme.surfaceWhite),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(purchaseRequisitionControllerProvider.notifier).authorizeRejection(id, action);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Requisition #PRQ-$id set to $action successfully.'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final requisitionsAsync = ref.watch(purchaseRequisitionListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);

    final userRole = (currentUser?.role ?? '').toUpperCase();
    final suppliers = suppliersAsync.value ?? [];
    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: DynamicScmTopNavBar(
        title: 'Purchase Requisitions',
        showBackButton: true,
        onRefresh: () => ref.invalidate(purchaseRequisitionListProvider),
      ),
      floatingActionButton: userRole != 'SUPPLIER'
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.surfaceWhite,
              icon: const Icon(Icons.add),
              label: const Text('Add Requisition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => Navigator.pushNamed(context, '/purchase-requisition-create'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(purchaseRequisitionListProvider);
        },
        child: requisitionsAsync.when(
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
                    'Failed to load purchase requisitions: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(purchaseRequisitionListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (requisitions) {
            // Supplier Role-based Data Isolation
            List<PurchaseRequisitionResponse> roleFiltered = requisitions;
            if (userRole == 'SUPPLIER' && currentSupplier != null) {
              roleFiltered = requisitions.where((r) =>
                r.supplierIds.contains(currentSupplier.id) ||
                r.supplierNames.any((s) => s.toLowerCase() == currentSupplier.name.toLowerCase()) ||
                r.supplierIds.isEmpty
              ).toList();
            }

            // Apply searching & status filtering
            final filtered = roleFiltered.where((r) {
              final prqStr = '#PRQ-${r.id}'.toLowerCase();
              final idStr = r.id.toString();
              final matchesSearch = _searchQuery.isEmpty ||
                  prqStr.contains(_searchQuery.toLowerCase()) ||
                  idStr.contains(_searchQuery.toLowerCase()) ||
                  r.urgencyLevel.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  r.approvalStatus.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  r.productNames.any((p) => p.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                  r.supplierNames.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                  (r.remarks != null && r.remarks!.toLowerCase().contains(_searchQuery.toLowerCase()));

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  r.approvalStatus.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesStatus;
            }).toList();

            // Calculate Metrics
            final totalReqs = roleFiltered.length;
            final pendingReqs = roleFiltered.where((r) => r.approvalStatus.toUpperCase() == 'PENDING').length;
            final approvedReqs = roleFiltered.where((r) => r.approvalStatus.toUpperCase() == 'APPROVED').length;
            final rejectedReqs = roleFiltered.where((r) => ['REJECTED', 'CANCELLED'].contains(r.approvalStatus.toUpperCase())).length;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Metrics Summary Banner ─────────────────
                  if (userRole != 'SUPPLIER') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.dark, AppTheme.primaryDark],
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
                              Icon(Icons.analytics_outlined, color: AppTheme.primaryLight, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'PURCHASE REQUISITION SUMMARY',
                                style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
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
                                        Expanded(child: _buildBannerMetric('Total PRQs', '$totalReqs', AppTheme.surfaceWhite)),
                                        Expanded(child: _buildBannerMetric('Pending', '$pendingReqs', AppTheme.warning)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(child: _buildBannerMetric('Approved', '$approvedReqs', AppTheme.success)),
                                        Expanded(child: _buildBannerMetric('Rejected', '$rejectedReqs', AppTheme.danger)),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: _buildBannerMetric('Total PRQs', '$totalReqs', AppTheme.surfaceWhite)),
                                  Expanded(child: _buildBannerMetric('Pending', '$pendingReqs', AppTheme.warning)),
                                  Expanded(child: _buildBannerMetric('Approved', '$approvedReqs', AppTheme.success)),
                                  Expanded(child: _buildBannerMetric('Rejected', '$rejectedReqs', AppTheme.danger)),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── 2. Search & Filter Controls ────────────────
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by #PRQ ID, products, suppliers, remarks...',
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
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  if (userRole != 'SUPPLIER') ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['ALL', 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'].map((status) {
                          final isSelected = _selectedStatusFilter == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(
                                status == 'ALL' ? 'All PRQs ($totalReqs)' : status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.surfaceWhite : AppTheme.dark,
                                ),
                              ),
                              selectedColor: AppTheme.primary,
                              backgroundColor: AppTheme.surfaceWhite,
                              checkmarkColor: AppTheme.surfaceWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderGrey),
                              ),
                              onSelected: (_) => setState(() => _selectedStatusFilter = status),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── 3. Data Cards List ───────────────────
                  if (filtered.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.light),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.folder_off_outlined, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No purchase requisitions found.', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or filters.', style: TextStyle(color: AppTheme.secondary, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        final statusColor = _getStatusColor(r.approvalStatus);
                        final urgencyColor = _getUrgencyColor(r.urgencyLevel);
                        final dateFormatted = r.requiredByDate.contains('T')
                            ? r.requiredByDate.split('T').first
                            : r.requiredByDate;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.light),
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
                                  color: AppTheme.light,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  border: Border(bottom: BorderSide(color: AppTheme.borderGrey.withValues(alpha: 0.5))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.description, size: 18, color: AppTheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          '#PRQ-${r.id}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark, fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        r.approvalStatus,
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
                                    // Row 1: Target Date, Urgency & Quantity
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('REQUIRED DEADLINE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                              const SizedBox(height: 2),
                                              Text(dateFormatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('URGENCY STRATEGY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                              const SizedBox(height: 2),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: urgencyColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  r.urgencyLevel,
                                                  style: TextStyle(color: urgencyColor, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('REQUIRED VOLUME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${r.quantityRequired} Units',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Products specifications list
                                    if (r.productNames.isNotEmpty) ...[
                                      const Text('PRODUCT SPECIFICATIONS:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: r.productNames.map((pName) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.dark,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(pName, style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 10, fontWeight: FontWeight.bold)),
                                        )).toList(),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    // Target Suppliers Badges
                                    if (r.supplierNames.isNotEmpty) ...[
                                      const Text('TARGET PREFERRED SUPPLIERS:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: r.supplierNames.map((sName) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.light,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppTheme.borderGrey),
                                          ),
                                          child: Text(sName, style: const TextStyle(color: AppTheme.dark, fontSize: 10, fontWeight: FontWeight.w600)),
                                        )).toList(),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    // Remarks if present
                                    if (r.remarks != null && r.remarks!.isNotEmpty) ...[
                                      Text(
                                        'Directives: ${r.remarks}',
                                        style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    const Divider(height: 16),

                                    // ── Action Buttons Row ──
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        // View PDF Button
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryDark,
                                            foregroundColor: AppTheme.surfaceWhite,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                                          label: const Text('View Requisition PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PurchaseRequisitionDataPDFScreen(requisition: r),
                                              ),
                                            );
                                          },
                                        ),

                                        // Approval Actions for MANAGER or ADMIN when PENDING
                                        if (userRole != 'SUPPLIER' && r.approvalStatus.toUpperCase() == 'PENDING' && (userRole == 'MANAGER' || userRole == 'ADMIN' || userRole == 'PROCUREMENT')) ...[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.success,
                                                  foregroundColor: AppTheme.surfaceWhite,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => _authorizeApproval(r.id),
                                                child: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(width: 6),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.danger,
                                                  foregroundColor: AppTheme.surfaceWhite,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => _authorizeRejection(r.id, 'REJECT'),
                                                child: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ],
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
          style: const TextStyle(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}