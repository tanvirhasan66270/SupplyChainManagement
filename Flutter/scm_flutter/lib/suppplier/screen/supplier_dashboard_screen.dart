import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/entity/supplier_model.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/procourment/screen/purchase_order_pdf_screen.dart';
import 'package:scm_flutter/suppplier/provider/po_line_item_provider.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/suppplier/screen/supplier_form_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class SupplierDashboardScreen extends ConsumerStatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  ConsumerState<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends ConsumerState<SupplierDashboardScreen> {
  String activeTableTab = 'ISSUED_POS';
  String searchQuery = '';

  // Dialog State Variables
  String modalSearchText = '';
  String? activeShortcutModal;

  // Shipment Update Modal State
  String shipmentSearchTerm = '';
  PurchaseOrderResponse? selectedShipmentPo;

  // Find LC Modal State
  final TextEditingController _findLcPoController = TextEditingController();
  Map<String, dynamic>? foundLcResult;
  String? lcSearchError;

  @override
  void dispose() {
    _findLcPoController.dispose();
    super.dispose();
  }

  Future<void> _updatePoStatus(int orderId, String nextStatus) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref.read(purchaseOrderControllerProvider.notifier).updateStatus(orderId, nextStatus);
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Purchase Order #PO-$orderId status marked as $nextStatus successfully!'),
          backgroundColor: AppTheme.statusSupplierColor(nextStatus),
        ),
      );
    }
  }

  Future<void> _deleteSupplier(SupplierResponseDTO supplier) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier Profile'),
        content: Text('Are you sure you want to delete supplier "${supplier.name}" from active directories?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(supplierControllerProvider.notifier).deleteSupplier(supplier.id);
      if (success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Supplier ${supplier.name} purged successfully.'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  // ── Modal Handlers ──

  void _openFindLcModal(List<PurchaseOrderResponse> allPOs) {
    setState(() {
      _findLcPoController.clear();
      foundLcResult = null;
      lcSearchError = null;
    });

    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(16),
            title: const Row(
              children: [
                Icon(Icons.account_balance, color: AppTheme.warning),
                SizedBox(width: 8),
                Expanded(child: Text('Find Letter of Credit (LC)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
              ],
            ),
            content: SizedBox(
              width: screenWidth > 600 ? 420 : screenWidth * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SEARCH PURCHASE ORDER REFERENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _findLcPoController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. PO-17835... or Order ID',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                        onPressed: () {
                          final term = _findLcPoController.text.trim().toLowerCase();
                          if (term.isEmpty) {
                            setModalState(() {
                              lcSearchError = 'Please enter a PO number.';
                              foundLcResult = null;
                            });
                            return;
                          }

                          final match = allPOs.where((po) => po.poNumber.toLowerCase().contains(term) || po.id.toString() == term).firstOrNull;

                          if (match != null) {
                            setModalState(() {
                              lcSearchError = null;
                              foundLcResult = {
                                'lcNumber': 'LC-${100000 + match.id}',
                                'poNumber': match.poNumber,
                                'amount': match.totalAmount,
                                'currency': match.currency.isNotEmpty ? match.currency : 'USD',
                                'bank': 'SCM Commercial Settlement Bank',
                                'swift': 'SCMBBDDH101',
                                'status': 'OPENED',
                                'expiry': match.expectedDeliveryDate,
                              };
                            });
                          } else {
                            setModalState(() {
                              lcSearchError = 'No Letter of Credit found for PO "$term".';
                              foundLcResult = null;
                            });
                          }
                        },
                        child: const Text('SEARCH'),
                      ),
                    ],
                  ),
                  if (lcSearchError != null) ...[
                    const SizedBox(height: 12),
                    Text(lcSearchError!, style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  ],
                  if (foundLcResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.warning),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(foundLcResult!['lcNumber'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark, fontFamily: 'monospace'), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(4)),
                                child: Text(foundLcResult!['status'], style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Divider(height: 12),
                          Text('PO Ref: ${foundLcResult!['poNumber']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('Valuation: \$${foundLcResult!['amount']} ${foundLcResult!['currency']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success)),
                          Text('Issuing Bank: ${foundLcResult!['bank']}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                          Text('SWIFT: ${foundLcResult!['swift']}  |  Expiry: ${foundLcResult!['expiry']}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final currentUser = ref.watch(currentUserProvider);
    final supplierListAsync = ref.watch(supplierListProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final quotationsAsync = ref.watch(quotationListProvider);
    final requisitionsAsync = ref.watch(purchaseRequisitionListProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);
    final lineItemsAsync = ref.watch(poLineItemListProvider);

    final userName = currentUser?.name ?? 'Supplier Node';
    final userRole = (currentUser?.role ?? 'SUPPLIER').toUpperCase();

    final suppliers = supplierListAsync.value ?? [];
    final allPOs = purchaseOrdersAsync.value ?? [];
    final allQuotations = quotationsAsync.value ?? [];
    final allRequisitions = requisitionsAsync.value ?? [];
    final allShipments = shipmentsAsync.value ?? [];
    final allLineItems = lineItemsAsync.value ?? [];

    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;
    final isSupplierRole = userRole == 'SUPPLIER';

    // Supplier Specific PO filtering
    final supplierPOs = isSupplierRole && currentSupplier != null
        ? allPOs.where((po) => po.supplierId == currentSupplier.id).toList()
        : allPOs;

    final issuedPOs = supplierPOs.where((po) => po.status.toUpperCase() == 'ISSUED' || po.status.toUpperCase() == 'DRAFT').toList();
    final receivedPOs = supplierPOs.where((po) => po.status.toUpperCase() == 'RECEIVED' || po.status.toUpperCase() == 'APPROVED').toList();

    // Metrics Calculation
    final totalPOs = supplierPOs.length;
    final pendingDeliveries = issuedPOs.length;
    final supplyAccuracy = totalPOs > 0 ? ((receivedPOs.length / totalPOs) * 100).round() : 100;
    final activeQuotations = isSupplierRole && currentSupplier != null
        ? allQuotations.where((q) => q.supplierId == currentSupplier.id).length
        : allQuotations.length;
    final supplierRequisitions = isSupplierRole && currentSupplier != null
        ? allRequisitions.where((r) =>
            r.supplierIds.contains(currentSupplier.id) ||
            r.supplierNames.any((s) => s.toLowerCase() == currentSupplier.name.toLowerCase()) ||
            r.supplierIds.isEmpty
          ).toList()
        : allRequisitions;
    final assignedPRs = supplierRequisitions.length;
    final activeLCs = receivedPOs.length;

    // Build KPI List matching ProcurementDashboardScreen format
    final List<Map<String, dynamic>> kpisRow1 = [
      {
        'label': 'Purchase Orders',
        'value': '$totalPOs',
        'trend': '12%',
        'icon': Icons.inbox_outlined,
        'iconBg': AppTheme.infoLight,
        'iconColor': AppTheme.primary,
      },
      {
        'label': 'Pending Delivery',
        'value': '$pendingDeliveries',
        'trend': '5%',
        'icon': Icons.hourglass_top_outlined,
        'iconBg': AppTheme.warningLight,
        'iconColor': AppTheme.warning,
      },
      {
        'label': 'Supply Accuracy',
        'value': '$supplyAccuracy%',
        'trend': '$supplyAccuracy%',
        'icon': Icons.verified_outlined,
        'iconBg': AppTheme.successLight,
        'iconColor': AppTheme.success,
      },
      {
        'label': 'Active RFQ Bids',
        'value': '$activeQuotations',
        'trend': '20%',
        'icon': Icons.mark_email_read_outlined,
        'iconBg': AppTheme.purpleLight,
        'iconColor': AppTheme.purple,
      },
    ];

    final List<Map<String, dynamic>> kpisRow2 = [
      {
        'label': 'Assigned PRs',
        'value': '$assignedPRs',
        'trend': '8%',
        'icon': Icons.description_outlined,
        'iconBg': AppTheme.infoLight,
        'iconColor': AppTheme.info,
      },
      {
        'label': 'Active LCs',
        'value': '$activeLCs',
        'trend': '10%',
        'icon': Icons.account_balance_outlined,
        'iconBg': AppTheme.purpleLight,
        'iconColor': AppTheme.purple,
      },

      {
        'label': 'Outstanding Value',
        'value': '\$${supplierPOs.fold(0.0, (sum, po) => sum + po.totalAmount).toStringAsFixed(0)}',
        'trend': 'Total',
        'icon': Icons.account_balance_wallet_outlined,
        'iconBg': AppTheme.successLight,
        'iconColor': AppTheme.success,
      },
    ];

    // Quick Actions grid array matching ProcurementDashboardScreen
    final List<Map<String, dynamic>> quickActions = [
      {
        'label': 'Add Quotation',
        'icon': Icons.description,
        'color': AppTheme.teal,
        'sub': '$activeQuotations Bids',
        'onTap': () => Navigator.pushNamed(context, '/quotation-create'),
      },
      {
        'label': 'Add Line Item',
        'icon': Icons.list,
        'color': AppTheme.primary,
        'sub': '${allLineItems.length} Items',
        'onTap': () => Navigator.pushNamed(context, '/po-line-item-create'),
      },
      {
        'label': 'Add Shipment',
        'icon': Icons.local_shipping,
        'color': AppTheme.warning,
        'sub': '${allShipments.length} Cargo',
        'onTap': () => Navigator.pushNamed(context, '/shipment-create'),
      },
      {
        'label': 'Shipment Update',
        'icon': Icons.autorenew,
        'color': AppTheme.orange,
        'sub': 'Consignment',
        'onTap': () => Navigator.pushNamed(context, '/shipment-update'),
      },
      {
        'label': 'Find LC',
        'icon': Icons.search,
        'color': AppTheme.danger,
        'sub': 'Search LC',
        'onTap': () => _openFindLcModal(allPOs),
      },
      {
        'label': 'Purchase Orders',
        'icon': Icons.shopping_bag_outlined,
        'color': AppTheme.indigo,
        'sub': '$totalPOs POs',
        'onTap': () => Navigator.pushNamed(context, '/purchase-orders'),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.light,
      floatingActionButton: (!isSupplierRole)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/supplier-create'),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Add Supplier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(supplierListProvider);
            ref.invalidate(purchaseOrderListProvider);
            ref.invalidate(quotationListProvider);
            ref.invalidate(purchaseRequisitionListProvider);
            ref.invalidate(shipmentListProvider);
            ref.invalidate(poLineItemListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Bar (Fully Dynamic) ──
                DynamicScmTopNavBar(
                  onRefresh: () {
                    ref.invalidate(supplierListProvider);
                    ref.invalidate(purchaseOrderListProvider);
                    ref.invalidate(quotationListProvider);
                    ref.invalidate(purchaseRequisitionListProvider);
                    ref.invalidate(shipmentListProvider);
                    ref.invalidate(poLineItemListProvider);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2. Welcome Banner (Matching ProcurementDashboardScreen) ──
                      _buildWelcomeBanner(userName, userRole),

                      const SizedBox(height: 20),

                      // ── 3. KPI Row 1 (Matching ProcurementDashboardScreen) ──
                      _buildKpiCardRow(kpisRow1),

                      const SizedBox(height: 12),

                      // ── 4. KPI Row 2 (Matching ProcurementDashboardScreen) ──
                      _buildKpiCardRow(kpisRow2),

                      const SizedBox(height: 24),

                      // ── 5. Quick Actions Section Header ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/purchase-orders'),
                            child: const Text('View All POs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 6. Quick Actions Grid (Matching ProcurementDashboardScreen Grid) ──
                      _buildQuickActionsGrid(quickActions),

                      const SizedBox(height: 24),

                      // ── 7. Category Tab Switcher Chips ──
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabCard('ISSUED_POS', 'Issued POs (${issuedPOs.length})', Icons.notifications_active, AppTheme.primary),
                            _buildTabCard('RFQ_BIDS', 'Quotation Bids ($activeQuotations)', Icons.access_time, AppTheme.info),
                            _buildTabCard('DEMANDS', 'Requisitions ($assignedPRs)', Icons.assignment, AppTheme.teal),
                            _buildTabCard('LC', 'LC Status ($activeLCs)', Icons.account_balance, AppTheme.warning),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── 8. Dynamic Data Section (Matching ProcurementDashboardScreen Card Log) ──
                      _buildTabContent(isSupplierRole, supplierPOs, issuedPOs, receivedPOs, allQuotations, supplierRequisitions, suppliers, isMobile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── ProcurementDashboardScreen Exact Welcome Banner ──
  Widget _buildWelcomeBanner(String userName, String userRole) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, $userName 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Track purchase orders, consignments & supplier quotes in real time ($userRole Node).', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: Colors.green),
                SizedBox(width: 6),
                Text('Live Supplier Cluster Connected', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ProcurementDashboardScreen Exact KPI Card Row Design (Android Responsive) ──
  Widget _buildKpiCardRow(List<Map<String, dynamic>> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        Widget buildSingleCard(Map<String, dynamic> kpi) {
          return Container(
            height: 115,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.light),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: kpi['iconBg'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(kpi['icon'], size: 14, color: kpi['iconColor']),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        kpi['label'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  kpi['value'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 10, color: AppTheme.success),
                    const SizedBox(width: 2),
                    Text(
                      '${kpi['trend']}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (isMobile) {
          final firstRow = kpis.take(2).toList();
          final secondRow = kpis.skip(2).toList();

          return Column(
            children: [
              Row(
                children: firstRow.asMap().entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: entry.key == firstRow.length - 1 ? 0 : 8),
                      child: buildSingleCard(entry.value),
                    ),
                  );
                }).toList(),
              ),
              if (secondRow.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: secondRow.asMap().entries.map((entry) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: entry.key == secondRow.length - 1 ? 0 : 8),
                        child: buildSingleCard(entry.value),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        }

        return Row(
          children: kpis.asMap().entries.map((entry) {
            final index = entry.key;
            final kpi = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == kpis.length - 1 ? 0 : 8),
                child: buildSingleCard(kpi),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── ProcurementDashboardScreen Exact Quick Actions Grid ──
  Widget _buildQuickActionsGrid(List<Map<String, dynamic>> actions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final crossCount = isWide ? 6 : (constraints.maxWidth > 480 ? 3 : 2);
        final aspect = isWide ? 1.6 : (constraints.maxWidth > 480 ? 1.2 : 1.15);

        return GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: aspect,
          ),
          itemBuilder: (context, index) {
            final act = actions[index];
            return InkWell(
              onTap: act['onTap'],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(act['icon'], color: act['color'], size: 24),
                    const SizedBox(height: 6),
                    Text(
                      act['label'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    if (act['sub'] != null) ...[
                      const SizedBox(height: 2),
                      Text(act['sub'], style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Tab Switcher Cards (Card View) ──
  Widget _buildTabCard(String key, String label, IconData icon, Color color) {
    final isSelected = activeTableTab == key;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => activeTableTab = key);
            if (key == 'DEMANDS') {
              Navigator.pushNamed(context, '/purchase-requisitions');
            } else if (key == 'RFQ_BIDS') {
              Navigator.pushNamed(context, '/quotations');
            } else if (key == 'ISSUED_POS' || key == 'ORDERS') {
              Navigator.pushNamed(context, '/purchase-orders');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 14, color: isSelected ? Colors.white : color),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Content Renderer (100% Functionality Preserved) ──
  Widget _buildTabContent(
    bool isSupplierRole,
    List<PurchaseOrderResponse> supplierPOs,
    List<PurchaseOrderResponse> issuedPOs,
    List<PurchaseOrderResponse> receivedPOs,
    List<QuotationResponseModel> allQuotations,
    List<PurchaseRequisitionResponse> allRequisitions,
    List<SupplierResponseDTO> suppliers,
    bool isMobile,
  ) {
    if (activeTableTab == 'ISSUED_POS') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Open Sourcing / Issued Purchase Orders', Icons.notifications_active, AppTheme.primary),
          const SizedBox(height: 10),
          if (issuedPOs.isEmpty)
            _buildEmptyState('No open issued purchase orders available.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: issuedPOs.length,
              itemBuilder: (context, idx) => _buildPoCard(issuedPOs[idx], showManageActions: true),
            ),
        ],
      );
    } else if (activeTableTab == 'RECEIVED_POS') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Received & Fulfilled Purchase Orders', Icons.check_circle, AppTheme.success),
          const SizedBox(height: 10),
          if (receivedPOs.isEmpty)
            _buildEmptyState('No received orders found in archive.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: receivedPOs.length,
              itemBuilder: (context, idx) => _buildPoCard(receivedPOs[idx], showManageActions: false),
            ),
        ],
      );
    } else if (activeTableTab == 'RFQ_BIDS') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Supplier Quotations & Bidding Registry', Icons.request_quote, AppTheme.info),
          const SizedBox(height: 10),
          if (allQuotations.isEmpty)
            _buildEmptyState('No active quotation bids logged.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allQuotations.length,
              itemBuilder: (context, idx) {
                final q = allQuotations[idx];
                final statusColor = AppTheme.statusSupplierColor(q.status);
                final statusBg = AppTheme.statusLightColor(q.status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.light)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quotation #Q-${q.quotationNumber.isNotEmpty ? q.quotationNumber : q.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace', color: AppTheme.dark)),
                            Text('Item: ${q.productName.isNotEmpty ? q.productName : 'Product Spec'}', style: const TextStyle(fontSize: 11, color: AppTheme.dark)),
                            Text('Supplier: ${q.supplierName}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${q.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: statusColor)),
                            child: Text(q.status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    } else if (activeTableTab == 'DEMANDS') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Corporate Demand Slips & Purchase Requisitions', Icons.assignment, AppTheme.teal),
          const SizedBox(height: 10),
          if (allRequisitions.isEmpty)
            _buildEmptyState('No purchase requisitions logged.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allRequisitions.length,
              itemBuilder: (context, idx) {
                final req = allRequisitions[idx];
                final statusColor = AppTheme.statusColor(req.approvalStatus);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.light)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#PRQ-${req.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace', color: AppTheme.dark)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: statusColor)),
                            child: Text(req.approvalStatus, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Products: ${req.productNames.join(', ')}', style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontWeight: FontWeight.w500)),
                      Text('Volume: ${req.quantityRequired} Units  |  Urgency: ${req.urgencyLevel}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    } else if (activeTableTab == 'LC') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Associated Letters of Credit (LC Status)', Icons.account_balance, AppTheme.warning),
          const SizedBox(height: 10),
          if (receivedPOs.isEmpty)
            _buildEmptyState('No Letters of Credit issued or available against received orders.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: receivedPOs.length,
              itemBuilder: (context, idx) {
                final po = receivedPOs[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.light)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LC-${100000 + po.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.warning, fontFamily: 'monospace')),
                            Text('PO Ref: ${po.poNumber}', style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
                            Text('Expiry: ${po.expectedDeliveryDate}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${po.totalAmount.toStringAsFixed(2)} ${po.currency}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.success)),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.warning)),
                            child: const Text('OPEN', style: TextStyle(color: AppTheme.warning, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    } else {
      // PO_ARCHIVE / SUPPLIER DIRECTORY
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSupplierRole) ...[
            _buildSectionHeader('Vendor Full Purchase Order Ledger Archive', Icons.folder_shared, AppTheme.secondary),
            const SizedBox(height: 10),
            if (supplierPOs.isEmpty)
              _buildEmptyState('No purchase orders allocated to your supplier profile yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: supplierPOs.length,
                itemBuilder: (context, idx) => _buildPoCard(supplierPOs[idx], showManageActions: false),
              ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildSectionHeader('Supplier Directory & Node Matrix', Icons.people, AppTheme.primary)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Supplier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pushNamed(context, '/supplier-create'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search Supplier Name, Email, Phone or Address...',
                prefixIcon: Icon(Icons.search, size: 18),
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suppliers.where((s) {
                if (searchQuery.trim().isEmpty) return true;
                final q = searchQuery.toLowerCase().trim();
                return s.name.toLowerCase().contains(q) || s.email.toLowerCase().contains(q) || s.phone.contains(q);
              }).length,
              itemBuilder: (context, idx) {
                final s = suppliers[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.light)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('Contact: ${s.contactPerson}  |  Email: ${s.email}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.warning, size: 18),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierFormScreen(supplierToEdit: s))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                            onPressed: () => _deleteSupplier(s),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.light)),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 36, color: AppTheme.secondary),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPoCard(PurchaseOrderResponse po, {required bool showManageActions}) {
    final statusColor = AppTheme.statusSupplierColor(po.status);
    final statusBg = AppTheme.statusLightColor(po.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.light),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.dark, borderRadius: BorderRadius.circular(6)),
                child: Text(po.poNumber, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(po.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: statusColor)),
                child: Text(po.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${po.quantity} Units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark)),
              Text('\$${po.totalAmount.toStringAsFixed(2)} ${po.currency}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.success)),
              Text('Due: ${po.expectedDeliveryDate}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseOrderPDFScreen(order: po))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primary)),
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 14, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text('PDF Invoice', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (showManageActions)
                PopupMenuButton<String>(
                  onSelected: (nextStatus) => _updatePoStatus(po.id, nextStatus),
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'RECEIVED', child: Row(children: [Icon(Icons.check_circle, color: AppTheme.success, size: 16), SizedBox(width: 6), Text('RECEIVED', style: TextStyle(fontSize: 12))])),
                    PopupMenuItem(value: 'CANCELLED', child: Row(children: [Icon(Icons.cancel, color: AppTheme.danger, size: 16), SizedBox(width: 6), Text('CANCELLED', style: TextStyle(fontSize: 12))])),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.light, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderGrey)),
                    child: const Row(
                      children: [
                        Text('Manage Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}