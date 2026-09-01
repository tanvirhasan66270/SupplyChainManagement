import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/logistics_officer/provider/good_received_note_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_data_screen.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspection_provider.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_form_screen.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_data_screen.dart';
import 'package:scm_flutter/system/notification/notification_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class QCDashboardScreen extends ConsumerStatefulWidget {
  const QCDashboardScreen({super.key});

  @override
  ConsumerState<QCDashboardScreen> createState() => _QCDashboardScreenState();
}

class _QCDashboardScreenState extends ConsumerState<QCDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final inspectionsAsync = ref.watch(qcInspectionListProvider);
    final grnsAsync = ref.watch(goodReceivedNoteListProvider);

    final userName = (currentUser?.name != null && currentUser!.name.isNotEmpty)
        ? currentUser.name
        : 'QC Inspector';

    final inspections = inspectionsAsync.value ?? [];
    final grns = grnsAsync.value ?? [];

    // Calculations matching Angular component logic
    final totalInspections = inspections.length;
    final pendingGrns = grns.where((g) => g.status == 'PENDING').toList();
    final pendingCount = pendingGrns.isNotEmpty ? pendingGrns.length : inspections.where((i) => i.result == 'PENDING').length;

    final passedInspections = inspections.where((i) => i.result == 'GOOD' || i.result == 'VERY_GOOD').toList();
    final failedInspections = inspections.where((i) => i.result == 'BAD').toList();

    final passedCount = passedInspections.length;
    final failedCount = failedInspections.length;

    final totalDefects = inspections.fold<int>(0, (sum, i) => sum + i.defectsFound);
    final totalSamples = inspections.fold<int>(0, (sum, i) => sum + (i.sampleSize > 0 ? i.sampleSize : 1));

    final passRate = totalInspections > 0 ? (passedCount / totalInspections * 100) : 0.0;
    final failRate = totalInspections > 0 ? (failedCount / totalInspections * 100) : 0.0;
    final defectRateStr = totalSamples > 0 ? ((totalDefects / totalSamples) * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: const DynamicScmTopNavBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(qcInspectionListProvider);
          ref.invalidate(goodReceivedNoteListProvider);
          ref.invalidate(notificationUnreadCountProvider);
          ref.invalidate(currentUserProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১. Welcome Banner Card (Designed like CustomerDashboardScreen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.tealDark, AppTheme.tealPrimary, AppTheme.tealLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, $userName 👋',
                                style: const TextStyle(color: AppTheme.surfaceWhite, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'QC Inspector - Quality Compliance & Inspection Matrix Console',
                                style: TextStyle(color: AppTheme.white, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.shield_outlined, color: AppTheme.surfaceWhite, size: 14),
                              SizedBox(width: 4),
                              Text('Active Auditor', style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Responsive layout calculations
              Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final int gridCrossAxisCount = screenWidth >= 800 ? 4 : 2;
                  final double gridAspectRatio = screenWidth >= 1200 ? 2.0 : (screenWidth >= 800 ? 1.6 : 1.35);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ২. Top 4 Metric Cards Grid (Responsive 2 or 4 Columns)
                      GridView.count(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: gridAspectRatio,
                        children: [
                          _buildMetricCard(
                            title: 'PENDING INSPECTION',
                            count: '$pendingCount Batches',
                            icon: Icons.assignment_outlined,
                            iconColor: AppTheme.indigo,
                            iconBg: AppTheme.purpleLight,
                            trendText: '$pendingCount',
                            trendColor: pendingCount > 0 ? AppTheme.indigo : AppTheme.secondary,
                            trendIcon: Icons.arrow_upward,
                          ),
                          _buildMetricCard(
                            title: 'PASSED TODAY',
                            count: '$passedCount Items',
                            icon: Icons.check_circle_outline,
                            iconColor: AppTheme.success,
                            iconBg: AppTheme.successLight,
                            trendText: '$passedCount',
                            trendColor: AppTheme.success,
                            trendIcon: Icons.arrow_upward,
                          ),
                          _buildMetricCard(
                            title: 'DEFECT RATE %',
                            count: '$defectRateStr%',
                            icon: Icons.error_outline,
                            iconColor: AppTheme.danger,
                            iconBg: AppTheme.dangerLight,
                            trendText: '$totalDefects',
                            trendColor: totalDefects > 0 ? AppTheme.danger : AppTheme.success,
                            trendIcon: totalDefects > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                          ),
                          _buildMetricCard(
                            title: "TODAY'S AUDIT",
                            count: '$totalInspections Logs',
                            icon: Icons.description_outlined,
                            iconColor: AppTheme.primary,
                            iconBg: AppTheme.infoLight,
                            trendText: '$totalInspections',
                            trendColor: AppTheme.primary,
                            trendIcon: Icons.arrow_upward,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ৩. Action Banner Cards (3 Action Cards Row)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const QCInspectionFormScreen()),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: _buildActionCard(
                                icon: Icons.verified_user_outlined,
                                title: 'Record Inspection',
                                subtitle: 'Upload new QC audit log',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const QCInspectionDataScreen()),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: _buildActionCard(
                                icon: Icons.assignment_outlined,
                                title: 'Inspections',
                                subtitle: 'View & search all audit records',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GoodReceivedNoteDataScreen()),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: _buildActionCard(
                                icon: Icons.download_rounded,
                                title: 'Goods Received Note',
                                subtitle: 'View & inspect inbound GRN registry',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ৪. Quality Assurance Inspection Queue Table (Responsive Full Width)
                      _buildInspectionQueueTable(inspections),
                      const SizedBox(height: 16),

                      // ৫. Bottom Two Cards (Quality Defect Types & QC Pass vs Fail Proportions)
                      screenWidth < 600
                          ? Column(
                              children: [
                                _buildDefectsCard(failedInspections),
                                const SizedBox(height: 12),
                                _buildPassFailProportionsCard(passRate, failRate, totalInspections),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildDefectsCard(failedInspections)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildPassFailProportionsCard(passRate, failRate, totalInspections)),
                              ],
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        selectedItemColor: AppTheme.indigo,
        unselectedItemColor: AppTheme.secondary,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) {
          setState(() => _selectedNavIndex = idx);
          if (idx == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QCInspectionDataScreen()));
          } else if (idx == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GoodReceivedNoteDataScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Inspections'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'GRN'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String trendText,
    required Color trendColor,
    required IconData trendIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Row(
                children: [
                  Icon(trendIcon, color: trendColor, size: 12),
                  const SizedBox(width: 2),
                  Text(trendText, style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.3),
              ),
              const SizedBox(height: 2),
              Text(
                count,
                style: const TextStyle(color: AppTheme.dark, fontSize: 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.purpleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.purple, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppTheme.secondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionQueueTable(List<QCInspectionResponseModel> inspections) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quality Assurance Inspection Queue',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark),
                  ),
                  Text(
                    'Recent batch compliance verifications',
                    style: TextStyle(fontSize: 10, color: AppTheme.secondary),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QCInspectionDataScreen())),
                child: const Text('View All', style: TextStyle(fontSize: 11, color: AppTheme.indigo, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (inspections.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No inspection logs available', style: TextStyle(fontSize: 11, color: AppTheme.secondary))),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowHeight: 38,
                      dataRowMinHeight: 38,
                      dataRowMaxHeight: 48,
                      columnSpacing: 20,
                      horizontalMargin: 8,
                      columns: const [
                        DataColumn(label: Text('NODE CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('GRN #', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('PRODUCT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('INSPECTOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('RESULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('DEFECTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      ],
                      rows: inspections.take(5).map((item) {
                        final isPass = item.result == 'GOOD' || item.result == 'VERY_GOOD';
                        return DataRow(cells: [
                          DataCell(Text('#${item.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          DataCell(Text(item.grnNumber, style: const TextStyle(fontSize: 10))),
                          DataCell(Text(item.productName.isNotEmpty ? item.productName : 'Prod #${item.productId}', style: const TextStyle(fontSize: 10))),
                          DataCell(Text(item.inspectedByName, style: const TextStyle(fontSize: 10))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPass ? AppTheme.successLight : AppTheme.dangerLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.result,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isPass ? AppTheme.success : AppTheme.danger),
                              ),
                            ),
                          ),
                          DataCell(Text('${item.defectsFound}', style: TextStyle(fontSize: 10, color: item.defectsFound > 0 ? AppTheme.danger : AppTheme.dark, fontWeight: FontWeight.bold))),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDefectsCard(List<QCInspectionResponseModel> failedInspections) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quality Defect Types', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 2),
          const Text('Flagged flaws by severity', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
          const SizedBox(height: 10),
          if (failedInspections.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Zero material defects recorded', style: TextStyle(fontSize: 10, color: AppTheme.success, fontWeight: FontWeight.bold)),
            )
          else
            Column(
              children: failedInspections.take(3).map((f) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          f.defectDescription.isNotEmpty ? f.defectDescription : 'Batch Defect #${f.id}',
                          style: const TextStyle(fontSize: 10, color: AppTheme.dark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.dangerLight, borderRadius: BorderRadius.circular(4)),
                        child: Text('${f.defectsFound} Defects', style: const TextStyle(fontSize: 9, color: AppTheme.danger, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPassFailProportionsCard(double passRate, double failRate, int totalInspections) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pass vs Fail Ratio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
          const SizedBox(height: 2),
          const Text('Proportional audit outcome', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('${passRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.success)),
                  const Text('Pass Rate', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                ],
              ),
              Container(height: 24, width: 1, color: AppTheme.borderGrey),
              Column(
                children: [
                  Text('${failRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.danger)),
                  const Text('Defect Rate', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}