import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspection_provider.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspector_provider.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_form_screen.dart';
import 'package:scm_flutter/qc_inspactor/screen/qc_inspection_data_pdf_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class QCInspectionDataScreen extends ConsumerStatefulWidget {
  const QCInspectionDataScreen({super.key});

  @override
  ConsumerState<QCInspectionDataScreen> createState() => _QCInspectionDataScreenState();
}

class _QCInspectionDataScreenState extends ConsumerState<QCInspectionDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedResultFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getResultColor(String result) {
    switch (result.toUpperCase()) {
      case 'VERY_GOOD':
      case 'GOOD':
        return AppTheme.success;
      case 'AVERAGE':
        return AppTheme.warning;
      case 'BAD':
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getResultBg(String result) {
    switch (result.toUpperCase()) {
      case 'VERY_GOOD':
      case 'GOOD':
        return AppTheme.successLight;
      case 'AVERAGE':
        return AppTheme.warningLight;
      case 'BAD':
        return AppTheme.dangerLight;
      default:
        return AppTheme.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspectionsAsync = ref.watch(qcInspectionListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentInspectorAsync = ref.watch(currentQcInspectorProvider);

    final userRole = currentUser?.role.toUpperCase() ?? '';
    final isQcInspector = userRole == 'QC_INSPECTOR' || userRole == 'ROLE_QC_INSPECTOR';
    final currentInspector = currentInspectorAsync.value;

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'QC Inspections Directory',
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
          MaterialPageRoute(builder: (_) => const QCInspectionFormScreen()),
        ),
        backgroundColor: AppTheme.tealPrimary,
        icon: const Icon(Icons.add, color: AppTheme.surfaceWhite),
        label: const Text(
          'Execute Inspection',
          style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(qcInspectionListProvider);
        },
        child: inspectionsAsync.when(
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
                    'Failed to load QC inspections: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(qcInspectionListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allInspections) {
            List<QCInspectionResponseModel> inspections = allInspections;
            if (isQcInspector) {
              final cId = currentInspector?.id;
              final cUserId = currentUser?.userId;
              final cName = currentInspector?.name ?? currentUser?.name ?? '';

              inspections = allInspections.where((i) {
                final matchesId = cId != null && i.inspectedBy == cId;
                final matchesUserId = cUserId != null && i.inspectedBy == cUserId;
                final matchesName = cName.isNotEmpty && i.inspectedByName.toLowerCase().trim() == cName.toLowerCase().trim();
                return matchesId || matchesUserId || matchesName;
              }).toList();
            }

            final filteredInspections = inspections.where((i) {
              final matchesSearch = _searchQuery.isEmpty ||
                  'QC-NODE-#${i.id}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.grnNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.inspectedByName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  i.result.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesFilter = _selectedResultFilter == 'ALL' ||
                  i.result.toUpperCase() == _selectedResultFilter;

              return matchesSearch && matchesFilter;
            }).toList();

            int passedCount = inspections.where((i) => i.result == 'GOOD' || i.result == 'VERY_GOOD').length;
            int failedCount = inspections.where((i) => i.result == 'BAD').length;
            int totalDefects = inspections.fold(0, (sum, i) => sum + i.defectsFound);
            int totalSamples = inspections.fold(0, (sum, i) => sum + (i.sampleSize > 0 ? i.sampleSize : 1));
            double defectRate = totalSamples > 0 ? (totalDefects / totalSamples * 100) : 0.0;

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
                        colors: [AppTheme.tealDark, AppTheme.dark],
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
                            Icon(Icons.shield_outlined, color: AppTheme.tealLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'QC AUDIT MATRIX SUMMARY',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildBannerMetric('Total Audits', '${inspections.length}', AppTheme.surfaceWhite)),
                            Expanded(child: _buildBannerMetric('Passed', '$passedCount', AppTheme.success)),
                            Expanded(child: _buildBannerMetric('Defective', '$failedCount', AppTheme.danger)),
                            Expanded(child: _buildBannerMetric('Defect Rate', '${defectRate.toStringAsFixed(1)}%', AppTheme.warning)),
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
                      hintText: 'Search by Audit ID, Product, GRN, Inspector, Result...',
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
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.tealPrimary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ৩. Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Items (${inspections.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip('GOOD', 'Passed (GOOD)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('VERY_GOOD', 'Very Good'),
                        const SizedBox(width: 8),
                        _buildFilterChip('AVERAGE', 'Average'),
                        const SizedBox(width: 8),
                        _buildFilterChip('BAD', 'Defective (BAD)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ৪. Data List Cards
                  if (filteredInspections.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.shield_moon_outlined, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No QC inspection records found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search query or status filter.', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredInspections.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredInspections[index];
                        final resColor = _getResultColor(item.result);
                        final resBg = _getResultBg(item.result);

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
                                    child: Text('QC-NODE-#${item.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.tealPrimary)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: resBg, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      item.result,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: resColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.productName.isNotEmpty ? item.productName : 'Product #${item.productId}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.numbers_outlined, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('GRN: ${item.grnNumber}', style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.person_outline, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('Inspector: ${item.inspectedByName}', style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text('Sample: ${item.sampleSize} units', style: const TextStyle(fontSize: 10)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.light,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('Defects: ${item.defectsFound}', style: TextStyle(fontSize: 10, color: item.defectsFound > 0 ? AppTheme.danger : AppTheme.dark, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: item.defectsFound > 0 ? AppTheme.dangerLight : AppTheme.light,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text('Type: ${item.inspectionType}', style: const TextStyle(fontSize: 10)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.light,
                                  ),
                                ],
                              ),
                              if (item.defectDescription.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.light,
                                    borderRadius: BorderRadius.circular(6),
                                    border: const Border(left: BorderSide(color: AppTheme.danger, width: 3)),
                                  ),
                                  child: Text(
                                    'Flaw Details: ${item.defectDescription}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.dark),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderGrey),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.inspectedAt,
                                    style: const TextStyle(fontSize: 10, color: AppTheme.secondary),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'View PDF Report',
                                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.danger, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QCInspectionDataPDFScreen(inspection: item),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit QC Audit',
                                        icon: const Icon(Icons.edit_outlined, color: AppTheme.tealPrimary, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QCInspectionFormScreen(inspectionToEdit: item),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete QC Record',
                                        icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete QC Record?'),
                                              content: const Text('Are you sure you want to delete this inspection entry?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.danger))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await ref.read(qcInspectionControllerProvider.notifier).deleteInspection(item.id);
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

  Widget _buildFilterChip(String resultKey, String label) {
    final isSelected = _selectedResultFilter == resultKey;
    return FilterChip(
      selected: isSelected,
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? AppTheme.surfaceWhite : AppTheme.dark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      backgroundColor: AppTheme.surfaceWhite,
      selectedColor: AppTheme.tealPrimary,
      checkmarkColor: AppTheme.surfaceWhite,
      side: BorderSide(color: isSelected ? AppTheme.tealPrimary : AppTheme.borderGrey),
      onSelected: (selected) {
        setState(() {
          _selectedResultFilter = selected ? resultKey : 'ALL';
        });
      },
    );
  }
}
