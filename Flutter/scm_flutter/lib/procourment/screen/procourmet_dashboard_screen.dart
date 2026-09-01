import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class ProcurementDashboardScreen extends ConsumerStatefulWidget {
  const ProcurementDashboardScreen({super.key});

  @override
  ConsumerState<ProcurementDashboardScreen> createState() => _ProcurementDashboardScreenState();
}

class _ProcurementDashboardScreenState extends ConsumerState<ProcurementDashboardScreen> {
  String selectedPeriod = 'All Time';
  String activeTab = 'APPROVED'; // 'RFQ', 'APPROVED', 'REJECTED', 'SHIPMENT', 'PO_LINE_ITEM'

  final List<Map<String, dynamic>> spendCategories = [
    {'label': 'Sourcing Cost', 'pct': '35%', 'color': AppTheme.success},
    {'label': 'Logistics Cost', 'pct': '25%', 'color': AppTheme.primary},
    {'label': 'Material Cost', 'pct': '25%', 'color': AppTheme.purple},
    {'label': 'Other Cost', 'pct': '15%', 'color': AppTheme.orange},
  ];

  final List<Map<String, dynamic>> inventoryShortages = [
    {'item': 'Fabrics', 'stock': '100 Units', 'threshold': '59,000 Units', 'urgency': 'High'},
    {'item': 'Zipper Metal', 'stock': '450 Units', 'threshold': '12,000 Units', 'urgency': 'Medium'},
  ];

  final List<Map<String, dynamic>> upcomingDeadlines = [
    {'title': 'Bulk Yarn Dispatch Deadline', 'date': '2026-09-15', 'color': AppTheme.primary},
    {'title': 'Dyeing Fluid Import Clear', 'date': '2026-09-18', 'color': AppTheme.danger},
  ];

  double _parseNum(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final poListAsync = ref.watch(purchaseOrderListProvider);
    final prListAsync = ref.watch(purchaseRequisitionListProvider);
    final supplierListAsync = ref.watch(supplierListProvider);
    final quotationListAsync = ref.watch(quotationListProvider);

    final userName = currentUser?.name ?? 'Procurement Officer';

    List<PurchaseOrderResponse> pos = poListAsync.value ?? [];
    List<PurchaseRequisitionResponse> prs = prListAsync.value ?? [];
    final suppliers = supplierListAsync.value ?? [];
    final quotations = quotationListAsync.value ?? [];

    final totalReqCount = prs.length;
    final totalRfqCount = quotations.isNotEmpty ? quotations.length : prs.length;
    final pendingPoCount = pos.where((p) => ['PENDING', 'ISSUED', 'DRAFT'].contains(p.status.toUpperCase())).length;
    final approvedPoCount = pos.where((p) => ['APPROVED', 'RECEIVED', 'COMPLETE'].contains(p.status.toUpperCase())).length;
    final rejectedPoCount = pos.where((p) => ['REJECTED', 'CANCELLED'].contains(p.status.toUpperCase())).length;
    final activeSupplierCount = suppliers.length;

    final budgetSourcedPct = pos.isEmpty ? 35 : ((approvedPoCount / pos.length) * 100).round();

    double totalSpend = 0.0;
    for (var p in pos) {
      totalSpend += _parseNum(p.totalAmount);
    }

    List<PurchaseOrderResponse> filteredPos = pos;
    if (activeTab == 'APPROVED') {
      filteredPos = pos.where((p) => ['APPROVED', 'RECEIVED', 'COMPLETE'].contains(p.status.toUpperCase())).toList();
    } else if (activeTab == 'REJECTED') {
      filteredPos = pos.where((p) => ['REJECTED', 'CANCELLED'].contains(p.status.toUpperCase())).toList();
    } else if (activeTab == 'RFQ') {
      filteredPos = pos.where((p) => ['PENDING', 'ISSUED', 'DRAFT'].contains(p.status.toUpperCase())).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(purchaseOrderListProvider);
            ref.invalidate(purchaseRequisitionListProvider);
            ref.invalidate(supplierListProvider);
            ref.invalidate(quotationListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DynamicScmTopNavBar(
                  onRefresh: () {
                    ref.invalidate(purchaseOrderListProvider);
                    ref.invalidate(purchaseRequisitionListProvider);
                    ref.invalidate(supplierListProvider);
                    ref.invalidate(quotationListProvider);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(userName),
                      const SizedBox(height: 20),
                      _buildKpiRow1(totalReqCount, totalRfqCount, pendingPoCount, budgetSourcedPct),
                      const SizedBox(height: 16),
                      _buildKpiRow2(totalSpend, pendingPoCount, approvedPoCount, activeSupplierCount),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.dark)),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/purchase-orders'),
                            child: const Text('View All POs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionsGrid(pendingPoCount, approvedPoCount, rejectedPoCount),
                      const SizedBox(height: 24),
                      _buildCostAnalyticsSection(totalSpend),
                      const SizedBox(height: 24),
                      _buildApprovedPoLogSection(filteredPos),
                      const SizedBox(height: 24),
                      _buildSpendAndNotificationsRow(totalSpend),
                      const SizedBox(height: 24),
                      _buildShortagesAndDeadlinesRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeBanner(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, $userName 👋', style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Track requisitions, purchase orders & procurement spend in real time.', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: AppTheme.success),
                SizedBox(width: 6),
                Text('Live Procurement Cluster Connected', style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FIXED KPI ROW 1 (Added Overflow safety with Flexible) ---
  Widget _buildKpiRow1(int reqCount, int rfqCount, int pendingPoCount, int budgetPct) {
    final List<Map<String, dynamic>> kpis = [
      {
        'label': 'Requisitions',
        'value': '$reqCount',
        'trend': '18%',
        'icon': Icons.description_outlined,
        'iconBg': AppTheme.infoLight,
        'iconColor': AppTheme.primary,
      },
      {
        'label': 'RFQ Sent',
        'value': '$rfqCount',
        'trend': '17%',
        'icon': Icons.mark_email_read_outlined,
        'iconBg': AppTheme.purpleLight,
        'iconColor': AppTheme.purple,
      },
      {
        'label': 'Pending POs',
        'value': '$pendingPoCount',
        'trend': '18%',
        'icon': Icons.hourglass_top_outlined,
        'iconBg': AppTheme.warningLight,
        'iconColor': AppTheme.warning,
      },
      {
        'label': 'Budget Sourced',
        'value': '$budgetPct%',
        'trend': '$budgetPct%',
        'icon': Icons.account_balance_wallet_outlined,
        'iconBg': AppTheme.successLight,
        'iconColor': AppTheme.success,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        Widget buildSingleCard(Map<String, dynamic> kpi, {bool isMarginRight = true}) {
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
                          color: AppTheme.secondary,
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
                    color: AppTheme.dark,
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
                    const SizedBox(width: 2),
                    const Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        'vs last period',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8,
                          color: AppTheme.secondary,
                        ),
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

  // --- FIXED KPI ROW 2 (Added Overflow safety with Flexible) ---
  Widget _buildKpiRow2(double totalSpend, int pendingCount, int approvedCount, int activeSupplierCount) {
    final List<Map<String, dynamic>> kpis = [
      {
        'type': 'spend',
        'label': 'Total Spend',
        'value': totalSpend > 0 ? '৳${totalSpend.toStringAsFixed(0)}' : '৳850,115,275',
        'trend': '8%',
        'icon': Icons.attach_money_rounded,
        'iconBg': AppTheme.successLight,
        'iconColor': AppTheme.success,
      },
      {
        'type': 'action',
        'label': 'Pending POs',
        'value': '$pendingCount',
        'trend': '18%',
        'route': '/purchase-orders',
        'icon': Icons.emoji_events_outlined,
        'iconBg': AppTheme.warningLight,
        'iconColor': AppTheme.warning,
      },
      {
        'type': 'action',
        'label': 'Approved POs',
        'value': '$approvedCount',
        'trend': '14%',
        'route': '/purchase-orders',
        'icon': Icons.gpp_good_outlined,
        'iconBg': AppTheme.successLight,
        'iconColor': AppTheme.success,
      },
      {
        'type': 'action',
        'label': 'Suppliers',
        'value': '$activeSupplierCount',
        'trend': '12%',
        'route': '/suppliers',
        'icon': Icons.person_outline_rounded,
        'iconBg': AppTheme.purpleLight,
        'iconColor': AppTheme.purple,
      },
    ];

    return Row(
      children: kpis.asMap().entries.map((entry) {
        final index = entry.key;
        final kpi = entry.value;
        bool isSpend = kpi['type'] == 'spend';

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (kpi['route'] != null) {
                Navigator.pushNamed(context, kpi['route']);
              }
            },
            child: Container(
              height: 115,
              margin: EdgeInsets.only(right: index == kpis.length - 1 ? 0 : 8),
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
                    style: TextStyle(
                      fontSize: isSpend ? 12 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.dark,
                    ),
                  ),
                  if (isSpend)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'vs last period',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 12,
                          child: CustomPaint(
                            painter: _SparklinePainter(),
                          ),
                        ),
                      ],
                    )
                  else
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
                        const SizedBox(width: 2),
                        const Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'vs last period',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid(int pendingCount, int approvedCount, int rejectedCount) {
    final List<Map<String, dynamic>> actions = [
      {'label': 'Create Requisition', 'icon': Icons.description, 'color': AppTheme.teal, 'route': '/purchase-requisition-create'},
      {'label': 'Purchase Order', 'icon': Icons.shopping_cart, 'color': AppTheme.primary, 'route': '/purchase-order-create'},
      {'label': 'Award Quotations', 'icon': Icons.assignment, 'color': AppTheme.warning, 'sub': 'All Quotations', 'route': '/quotations'},
      {'label': 'Manage Suppliers', 'icon': Icons.people, 'color': AppTheme.danger, 'route': '/suppliers'},
      {'label': 'Process Invoices', 'icon': Icons.receipt_long, 'color': AppTheme.info, 'route': '/invoice-portal'},
      {'label': 'Inventory Status', 'icon': Icons.inventory_2, 'color': AppTheme.success, 'route': '/inventory-data'},
      {'label': 'RFQ Log', 'icon': Icons.history, 'color': AppTheme.warning, 'sub': '$pendingCount Pending', 'route': '/quotations', 'arguments': 'PENDING'},
      {'label': 'Requisitions', 'icon': Icons.assignment_outlined, 'color': AppTheme.success, 'sub': 'All Requisitions', 'route': '/purchase-requisitions'},
      {'label': 'Purchases', 'icon': Icons.shopping_bag_outlined, 'color': AppTheme.warning, 'sub': 'All Purchases', 'route': '/purchase-orders'},
      {'label': 'Cargo Shipment Log', 'icon': Icons.local_shipping, 'color': AppTheme.primary, 'sub': 'Shipments', 'route': '/shipments'},
      {'label': 'Track Purchase Order', 'icon': Icons.map, 'color': AppTheme.primary, 'sub': 'Search & Track', 'route': '/track-po'},
      {'label': 'PO Line Items', 'icon': Icons.list, 'color': AppTheme.secondary, 'sub': 'Line Items', 'route': '/po-line-items'},
    ];

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
            bool isSelected = act['tab'] != null && activeTab == act['tab'];
            return InkWell(
              onTap: () {
                if (act['route'] != null) {
                  Navigator.pushNamed(context, act['route'], arguments: act['arguments']);
                } else if (act['tab'] != null) {
                  setState(() => activeTab = act['tab']);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.successLight : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppTheme.success : AppTheme.light, width: isSelected ? 1.5 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(act['icon'], color: act['color'], size: 24),
                    const SizedBox(height: 6),
                    Text(act['label'], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                    if (act['sub'] != null) ...[
                      const SizedBox(height: 2),
                      Text(act['sub'], style: TextStyle(fontSize: 9, color: isSelected ? AppTheme.success : AppTheme.secondary)),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCostAnalyticsSection(double totalSpend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.light),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: AppTheme.success, size: 20),
              const SizedBox(width: 6),
              const Text('Procurement Cost Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('৳${totalSpend.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                const Text('Total Procurement Spend', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: spendCategories.map((cat) {
              final pctVal = double.parse(cat['pct'].replaceAll('%', '')) / 100;
              final catAmount = totalSpend * pctVal;
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 55,
                        height: 55,
                        child: CircularProgressIndicator(
                          value: pctVal,
                          backgroundColor: AppTheme.light,
                          color: cat['color'],
                          strokeWidth: 6,
                        ),
                      ),
                      Text(cat['pct'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('৳${catAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                  Text(cat['label'], style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedPoLogSection(List<PurchaseOrderResponse> pos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(top: BorderSide(color: AppTheme.success, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$activeTab Purchase Order Log (${pos.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/purchase-orders'),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(),
          if (pos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text('No purchase order records in this tab category.', style: TextStyle(color: AppTheme.secondary, fontSize: 12))),
            )
          else
            ListView.separated(
              itemCount: pos.length > 5 ? 5 : pos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final po = pos[index];
                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('#${po.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 11)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(po.poNumber.isNotEmpty ? po.poNumber : 'PO-${po.id}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          const SizedBox(height: 2),
                          Text('Total: ৳${_parseNum(po.totalAmount).toStringAsFixed(2)} | Supplier ID: ${po.supplierId}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.procourmentStatusColor(po.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(po.status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.procourmentStatusColor(po.status))),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: AppTheme.secondary),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSpendAndNotificationsRow(double totalSpend) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spend by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
                  DropdownButton<String>(
                    value: selectedPeriod,
                    items: ['All Time', 'This Month', 'Last Month'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 11)))).toList(),
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                    underline: const SizedBox(),
                  ),
                ],
              ),
              const Divider(),
              ...spendCategories.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: c['color']),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c['label'], style: const TextStyle(fontSize: 11))),
                    Text(c['pct'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('System Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    child: const Text('View All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: AppTheme.success),
                    SizedBox(width: 8),
                    Expanded(child: Text('Procurement Node System Active', style: TextStyle(fontSize: 11))),
                    Text('Just now', style: TextStyle(fontSize: 10, color: AppTheme.secondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortagesAndDeadlinesRow() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Inventory Critical Shortages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/inventory-data'),
                    child: const Text('View Inventory', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const Divider(),
              Table(
                columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1)},
                children: [
                  const TableRow(children: [
                    Text('Item', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    Text('In Stock', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    Text('Threshold', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    Text('Urgency', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                  ]),
                  ...inventoryShortages.map((s) => TableRow(children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s['item'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s['stock'], style: const TextStyle(fontSize: 11))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(s['threshold'], style: const TextStyle(fontSize: 11))),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.dangerLight, borderRadius: BorderRadius.circular(4)),
                        child: Text(s['urgency'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.danger)),
                      ),
                    ),
                  ])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text('Upcoming Deadlines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.dark)),
    TextButton(
    onPressed: () {},
    child: const Text('View All', style: TextStyle(fontSize: 12)),
    ),
    ],
    ),
    const Divider(),
    ...upcomingDeadlines.map((d) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
    children: [
    const Icon(Icons.calendar_today, size: 18, color: AppTheme.primary),
    const SizedBox(width: 12),
    Expanded(child: Text(d['title'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
    Text(d['date'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: d['color'])),
    ],
    ),
    )),
    ],
    ),
    ),

      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', true, onTap: () {}),
          _buildNavItem(Icons.receipt, 'POs', false, onTap: () => Navigator.pushNamed(context, '/purchase-orders')),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/purchase-requisition-create'),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: AppTheme.surfaceWhite, size: 26),
            ),
          ),
          _buildNavItem(Icons.notifications, 'Notifications', false, badge: '!', onTap: () => Navigator.pushNamed(context, '/notifications')),
          _buildNavItem(Icons.more_horiz, 'More', false, onTap: () => Navigator.pushNamed(context, '/procurement-profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {String? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Icon(icon, color: isActive ? AppTheme.primary : AppTheme.secondary, size: 22),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 7)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primary : AppTheme.secondary, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppTheme.success
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.9,
        size.width * 0.5,
        size.height * 0.2,
        size.width * 0.75,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height * 0.1);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.success.withValues(alpha: 0.3),
          AppTheme.success.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}