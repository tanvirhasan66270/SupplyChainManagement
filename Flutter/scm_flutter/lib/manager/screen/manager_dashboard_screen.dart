import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen> {
  int _currentBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(currentUserProvider);

    final shipmentsAsync = ref.watch(shipmentListProvider);
    final quotationsAsync = ref.watch(quotationListProvider);

    int pendingApprovalsCount = 4;
    int activeShipmentsCount = 6;
    int lowStockCount = 1;
    int totalInvoicesCount = 1;
    int activeWarehousesCount = 1;

    quotationsAsync.whenData((qList) {
      if (qList.isNotEmpty) {
        final count = qList.where((q) => q.status.toUpperCase() == 'PENDING').length;
        if (count > 0) pendingApprovalsCount = count;
      }
    });

    shipmentsAsync.whenData((sList) {
      if (sList.isNotEmpty) {
        final count = sList.length;
        if (count > 0) activeShipmentsCount = count;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DynamicScmTopNavBar(
        showBackButton: false,
        title: 'Manager Dashboard',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Top KPI Metrics Grid (2x3 Grid) ─────────────────────────
            _buildKpiGrid(
              pendingApprovals: pendingApprovalsCount,
              activeShipments: activeShipmentsCount,
              lowStockAlerts: lowStockCount,
              activeWarehouses: activeWarehousesCount,
              totalInvoices: totalInvoicesCount,
            ),
            const SizedBox(height: 20),

            // ── 2. Managerial Quick Shortcuts ──────────────────────────────
            _buildManagerialShortcuts(context),
            const SizedBox(height: 20),

            // ── 3. Operations Shortcuts ─────────────────────────────────────
            _buildOperationsShortcuts(context, pendingApprovalsCount, activeShipmentsCount, lowStockCount),
            const SizedBox(height: 20),

            // ── 4. Analytics & Performance 2-Column Row ─────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _RevenueSpendAnalyticsCard()),
                      SizedBox(width: 16),
                      Expanded(child: _DepartmentPerformanceCard()),
                    ],
                  );
                } else {
                  return const Column(
                    children: [
                      _RevenueSpendAnalyticsCard(),
                      SizedBox(height: 16),
                      _DepartmentPerformanceCard(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // ── 5. Critical Logistics & Latest Updates 2-Column Row ─────────
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _CriticalLogisticsCard()),
                      SizedBox(width: 16),
                      Expanded(child: _LatestUpdatesCard()),
                    ],
                  );
                } else {
                  return const Column(
                    children: [
                      _CriticalLogisticsCard(),
                      SizedBox(height: 16),
                      _LatestUpdatesCard(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // ── 6. Colorful Stats Strip ──────────────────────────────────────
            _buildColorfulStatsStrip(
              pendingApprovals: pendingApprovalsCount,
              activeShipments: activeShipmentsCount,
              warehouses: activeWarehousesCount,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── Bottom Navigation Bar (Customer Dashboard Style) ────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          _handleBottomNavNavigation(context, index);
        },
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.space_dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Shipments'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }

  // ── 1. KPI Grid Widget ───────────────────────────────────────────────────
  Widget _buildKpiGrid({
    required int pendingApprovals,
    required int activeShipments,
    required int lowStockAlerts,
    required int activeWarehouses,
    required int totalInvoices,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 400 ? 1.65 : 1.45,
          children: [
            _KpiCard(
              title: 'TOTAL REVENUE',
              value: '৳212.0K',
              subtitle: '-100% vs last month',
              isSubtitlePositive: false,
              icon: Icons.monetization_on_outlined,
              iconColor: const Color(0xFF16A34A),
              bgColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFBBF7D0),
              sparklineColor: const Color(0xFF22C55E),
            ),
            _KpiCard(
              title: 'PENDING APPROVALS',
              value: '$pendingApprovals',
              subtitle: '+450% vs last month',
              isSubtitlePositive: true,
              icon: Icons.assignment_outlined,
              iconColor: const Color(0xFFD97706),
              bgColor: const Color(0xFFFFFBEB),
              borderColor: const Color(0xFFFDE68A),
              sparklineColor: const Color(0xFFF59E0B),
            ),
            _KpiCard(
              title: 'ACTIVE WAREHOUSES',
              value: '$activeWarehouses',
              subtitle: '-100% vs last month',
              isSubtitlePositive: false,
              icon: Icons.storefront_outlined,
              iconColor: const Color(0xFF0284C7),
              bgColor: const Color(0xFFF0F9FF),
              borderColor: const Color(0xFFBAE6FD),
              sparklineColor: const Color(0xFF0EA5E9),
            ),
            _KpiCard(
              title: 'TOTAL INVOICES',
              value: '$totalInvoices',
              subtitle: '-100% vs last month',
              isSubtitlePositive: false,
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              borderColor: const Color(0xFFBFDBFE),
              sparklineColor: const Color(0xFF3B82F6),
            ),
            _KpiCard(
              title: 'ACTIVE SHIPMENTS',
              value: '$activeShipments',
              subtitle: '0% vs last month',
              isSubtitleNeutral: true,
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF5F3FF),
              borderColor: const Color(0xFFDDD6FE),
              sparklineColor: const Color(0xFF8B5CF6),
            ),
            _KpiCard(
              title: 'LOW STOCK ALERTS',
              value: '$lowStockAlerts',
              subtitle: '+100% vs last month',
              isSubtitlePositive: false,
              icon: Icons.error_outline_rounded,
              iconColor: const Color(0xFFDC2626),
              bgColor: const Color(0xFFFEF2F2),
              borderColor: const Color(0xFFFECACA),
              sparklineColor: const Color(0xFFEF4444),
            ),
          ],
        );
      },
    );
  }

  // ── 2. Managerial Quick Shortcuts ───────────────────────────────────────
  Widget _buildManagerialShortcuts(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'MANAGERIAL QUICK SHORTCUTS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              InkWell(
                onTap: () {},
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ShortcutCard(
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Daily Report',
                  subtitle: '5 Submitted',
                  onTap: () => Navigator.pushNamed(context, '/customer-orders'),
                ),
                _ShortcutCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFF16A34A),
                  title: 'Audit Logs',
                  subtitle: '5 Records',
                  onTap: () => Navigator.pushNamed(context, '/customer-orders'),
                ),
                _ShortcutCard(
                  icon: Icons.domain_outlined,
                  iconColor: const Color(0xFFD97706),
                  title: 'Facilities',
                  subtitle: '1 Active',
                  onTap: () => Navigator.pushNamed(context, '/inventory-data'),
                ),
                _ShortcutCard(
                  icon: Icons.assignment_outlined,
                  iconColor: const Color(0xFF0891B2),
                  title: 'Requisitions',
                  subtitle: '4 Pending',
                  onTap: () => Navigator.pushNamed(context, '/purchase-requisitions'),
                ),
                _ShortcutCard(
                  icon: Icons.groups_outlined,
                  iconColor: const Color(0xFF9333EA),
                  title: 'Suppliers',
                  subtitle: '2 Active',
                  onTap: () => Navigator.pushNamed(context, '/suppliers'),
                ),
                _ShortcutCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFFDC2626),
                  title: 'Inventory',
                  subtitle: '1 Low Stock',
                  subtitleColor: const Color(0xFFDC2626),
                  onTap: () => Navigator.pushNamed(context, '/inventory-data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Operations Shortcuts ─────────────────────────────────────────────
  Widget _buildOperationsShortcuts(BuildContext context, int pending, int shipments, int lowStock) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'OPERATIONS SHORTCUTS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              InkWell(
                onTap: () {},
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ShortcutCard(
                  icon: Icons.gavel_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Quotations Approvals',
                  subtitle: '$pending Pending',
                  isHighlighted: true,
                  onTap: () => Navigator.pushNamed(context, '/quotations'),
                ),
                _ShortcutCard(
                  icon: Icons.shopping_cart_outlined,
                  iconColor: const Color(0xFF9333EA),
                  title: 'Purchase Orders',
                  subtitle: '10 Awaiting',
                  onTap: () => Navigator.pushNamed(context, '/purchase-orders'),
                ),
                _ShortcutCard(
                  icon: Icons.move_to_inbox_outlined,
                  iconColor: const Color(0xFF16A34A),
                  title: 'GRNs',
                  subtitle: '1 Pending',
                  onTap: () => Navigator.pushNamed(context, '/good-received-notes'),
                ),
                _ShortcutCard(
                  icon: Icons.local_shipping_outlined,
                  iconColor: const Color(0xFF0891B2),
                  title: 'Shipments',
                  subtitle: '$shipments Active',
                  onTap: () => Navigator.pushNamed(context, '/shipments'),
                ),
                _ShortcutCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: 'Low Stock',
                  subtitle: '$lowStock Alerts',
                  onTap: () => Navigator.pushNamed(context, '/inventory-data'),
                ),
                _ShortcutCard(
                  icon: Icons.analytics_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Daily Report',
                  subtitle: '5 Submitted',
                  onTap: () => Navigator.pushNamed(context, '/customer-orders'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Colorful Stats Strip ───────────────────────────────────────────────
  Widget _buildColorfulStatsStrip({
    required int pendingApprovals,
    required int activeShipments,
    required int warehouses,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 6 : (constraints.maxWidth > 500 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            _ColorStatPill(
              bgColor: const Color(0xFF3B82F6),
              icon: Icons.monetization_on_outlined,
              value: '৳212.0K',
              label: 'Total Revenue',
            ),
            _ColorStatPill(
              bgColor: const Color(0xFFEC4899),
              icon: Icons.shopping_bag_outlined,
              value: '৳850.1M',
              label: 'Total Spend',
            ),
            _ColorStatPill(
              bgColor: const Color(0xFF10B981),
              icon: Icons.storefront_outlined,
              value: '$warehouses',
              label: 'Warehouses',
            ),
            _ColorStatPill(
              bgColor: const Color(0xFF0EA5E9),
              icon: Icons.verified_outlined,
              value: '$pendingApprovals',
              label: 'Pending Auth',
            ),
            _ColorStatPill(
              bgColor: const Color(0xFF1E293B),
              icon: Icons.local_shipping_outlined,
              value: '$activeShipments',
              label: 'Live Transit',
            ),
            _ColorStatPill(
              bgColor: const Color(0xFFEF4444),
              icon: Icons.bug_report_outlined,
              value: '0',
              label: 'Failed QC',
            ),
          ],
        );
      },
    );
  }

  void _handleBottomNavNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        break; // Already on Manager Dashboard
      case 1:
        Navigator.pushNamed(context, '/customer-orders');
        break;
      case 2:
        Navigator.pushNamed(context, '/shipments');
        break;
      case 3:
        Navigator.pushNamed(context, '/inventory-data');
        break;
      case 4:
        Navigator.pushNamed(context, '/customer-orders');
        break;
      case 5:
        Navigator.pushNamed(context, '/messages');
        break;
    }
  }
}

// ── KPI Card Component ──────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.isSubtitlePositive = false,
    this.isSubtitleNeutral = false,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.sparklineColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final bool isSubtitlePositive;
  final bool isSubtitleNeutral;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Color sparklineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: borderColor)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSubtitleNeutral
                        ? Icons.remove
                        : (isSubtitlePositive ? Icons.trending_up : Icons.trending_down),
                    size: 12,
                    color: isSubtitleNeutral
                        ? Colors.grey
                        : (isSubtitlePositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isSubtitleNeutral
                          ? Colors.grey
                          : (isSubtitlePositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                    ),
                  ),
                ],
              ),
              // Mini Sparkline Line
              SizedBox(
                width: 38,
                height: 14,
                child: CustomPaint(painter: _SparklinePainter(color: sparklineColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mini Sparkline Painter ──────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.25, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Quick Shortcut Card Component ───────────────────────────────────────────
class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.isHighlighted = false,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 108,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: isHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: subtitleColor ?? const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Revenue & Spend Analytics Card ──────────────────────────────────────────
class _RevenueSpendAnalyticsCard extends StatelessWidget {
  const _RevenueSpendAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.insert_chart_outlined_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 6),
                  Text('REVENUE & SPEND ANALYTICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1E293B))),
                ],
              ),
              Row(
                children: [
                  _chartDotLegend(const Color(0xFF2563EB), 'Revenue'),
                  const SizedBox(width: 10),
                  _chartDotLegend(const Color(0xFFEF4444), 'Expenses'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart View Canvas
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _AnalyticsChartPainter()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.work_outline, color: Color(0xFF2563EB), size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('৳212.0K', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                          Text('Total Revenue', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: Color(0xFFDC2626), size: 20),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('৳850.1M', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                          Text('Total Expenses', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                        ],
                      ),
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

  Widget _chartDotLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AnalyticsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotBlue = Paint()..color = const Color(0xFF2563EB);
    final dotRed = Paint()..color = const Color(0xFFEF4444);

    final months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
    final dx = size.width / (months.length - 1);

    // Flat Revenue Line
    final revenuePath = Path();
    for (int i = 0; i < months.length; i++) {
      final x = i * dx;
      final y = size.height * 0.85;
      if (i == 0) {
        revenuePath.moveTo(x, y);
      } else {
        revenuePath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotBlue);
    }
    canvas.drawPath(revenuePath, bluePaint);

    // Expenses Curved Line
    final expensesPath = Path();
    for (int i = 0; i < months.length; i++) {
      final x = i * dx;
      double y = size.height * 0.85;
      if (i == 5) {
        y = size.height * 0.15; // Spike at Aug
      }
      if (i == 0) {
        expensesPath.moveTo(x, y);
      } else {
        expensesPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotRed);
    }
    canvas.drawPath(expensesPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Department Performance Card ─────────────────────────────────────────────
class _DepartmentPerformanceCard extends StatelessWidget {
  const _DepartmentPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_outlined, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: 6),
              Text('DEPARTMENT PERFORMANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          _deptProgressItem('Sourcing & SCM', 0.69, '69%', const Color(0xFF16A34A)),
          const SizedBox(height: 10),
          _deptProgressItem('Logistics & Fleet', 0.0, '0%', const Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          _deptProgressItem('Quality Control', 1.0, '100%', const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          _deptProgressItem('Commercial Imports', 1.0, '100%', const Color(0xFFD97706)),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('৳212.0K', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF16A34A))),
                  Text('Revenue', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
              Column(
                children: [
                  Text('৳850.1M', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFDC2626))),
                  Text('Expenses', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deptProgressItem(String label, double val, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Text(percent, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Critical Logistics & Shipments Card ──────────────────────────────────────
class _CriticalLogisticsCard extends StatelessWidget {
  const _CriticalLogisticsCard();

  @override
  Widget build(BuildContext context) {
    final grnItems = [
      {'title': 'New Goods Received Note Created: GRN-AEABB018', 'time': '8d ago'},
      {'title': 'New Goods Received Note Created: GRN-AEABB018', 'time': '8d ago'},
      {'title': 'New Goods Received Note Created: GRN-195D8656', 'time': '8d ago'},
      {'title': 'New Goods Received Note Created: GRN-195D8656', 'time': '8d ago'},
      {'title': 'New Goods Received Note Created: GRN-CBF9BF72', 'time': '8d ago'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 6),
                  const Text('CRITICAL LOGISTICS & SHIPMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E293B))),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: const Text('6', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/shipments'),
                child: const Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grnItems.length,
            separatorBuilder: (ctx, idx) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, i) {
              final item = grnItems[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded, size: 14, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ),
                  Text(item['time']!, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/shipments'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All Shipments', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Latest Updates Card ──────────────────────────────────────────────────────
class _LatestUpdatesCard extends StatelessWidget {
  const _LatestUpdatesCard();

  @override
  Widget build(BuildContext context) {
    final updates = [
      {'title': 'UPDATE_STATUS on CUSTOMER_ORDER', 'desc': 'Order status updated to SHIPPED for Order Number: ORD-1785669559228', 'time': '7d ago'},
      {'title': 'UPDATE_STATUS on CUSTOMER_ORDER', 'desc': 'Order status updated to PROCESSING for Order Number: ORD-1785669559228', 'time': '7d ago'},
      {'title': 'UPDATE_STATUS on PURCHASE_ORDER', 'desc': 'Order status updated to CONFIRMED for Order Number: ORD-1785669559228', 'time': '7d ago'},
      {'title': 'UPDATE_STATUS on PURCHASE_ORDER', 'desc': 'Purchase Order status changed from ISSUED to RECEIVED for PO: PO-1783508545513', 'time': '8d ago'},
      {'title': 'UPDATE_STATUS on PURCHASE_ORDER', 'desc': 'Purchase Order status changed from ISSUED to RECEIVED for PO: PO-1787421341459', 'time': '8d ago'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: Color(0xFF0891B2), size: 18),
                  const SizedBox(width: 6),
                  const Text('LATEST UPDATES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B))),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: const Color(0xFF0891B2),
                    child: const Text('6', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/customer-orders'),
                child: const Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: updates.length,
            separatorBuilder: (ctx, idx) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, i) {
              final item = updates[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFECFEFF), shape: BoxShape.circle),
                    child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0891B2)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 2),
                        Text(item['desc']!, style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(3)),
                          child: const Text('SUCCESS', style: TextStyle(fontSize: 7.5, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Text(item['time']!, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/customer-orders'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All Updates', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Color Stat Pill Component ───────────────────────────────────────────────
class _ColorStatPill extends StatelessWidget {
  const _ColorStatPill({
    required this.bgColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color bgColor;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8.5), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
