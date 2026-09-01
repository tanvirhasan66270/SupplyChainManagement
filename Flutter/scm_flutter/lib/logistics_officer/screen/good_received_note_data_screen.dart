import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/logistics_officer/provider/good_received_note_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_form_screen.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_pdf_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspector_provider.dart';

class GoodReceivedNoteDataScreen extends ConsumerStatefulWidget {
  const GoodReceivedNoteDataScreen({super.key});

  @override
  ConsumerState<GoodReceivedNoteDataScreen> createState() => _GoodReceivedNoteDataScreenState();
}

class _GoodReceivedNoteDataScreenState extends ConsumerState<GoodReceivedNoteDataScreen> {
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
      case 'PENDING':
        return AppTheme.warning;
      case 'RECEIVED':
      case 'PARTIALLY_RECEIVED':
        return AppTheme.primary;
      case 'APPROVED':
      case 'INSPECTED':
        return AppTheme.success;
      case 'REJECTED':
        return AppTheme.danger;
      default:
        return AppTheme.secondary;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppTheme.warningLight;
      case 'RECEIVED':
      case 'PARTIALLY_RECEIVED':
        return AppTheme.light;
      case 'APPROVED':
      case 'INSPECTED':
        return AppTheme.successLight;
      case 'REJECTED':
        return AppTheme.dangerLight;
      default:
        return AppTheme.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grnsAsync = ref.watch(goodReceivedNoteListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentInspectorAsync = ref.watch(currentQcInspectorProvider);

    final userRole = currentUser?.role.toUpperCase() ?? '';
    final isQcInspector = userRole == 'QC_INSPECTOR' || userRole == 'ROLE_QC_INSPECTOR' || userRole == 'QC' || userRole == 'QC_INSPACTOR' || userRole == 'ROLE_QC_INSPACTOR';
    final currentInspector = currentInspectorAsync.value;

    final canConsoleActions = userRole == 'ADMIN' || userRole == 'LOGISTICS_OFFICER' || userRole == 'ROLE_ADMIN' || userRole == 'ROLE_LOGISTICS_OFFICER';
    final canStageUpdate = canConsoleActions || userRole == 'MANAGER' || userRole == 'ROLE_MANAGER';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Inbound Goods Received Notes (GRN)',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      floatingActionButton: canConsoleActions
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoodReceivedNoteFormScreen()),
              ),
              backgroundColor: AppTheme.success,
              icon: const Icon(Icons.note_add_outlined, color: AppTheme.surfaceWhite),
              label: const Text(
                'Create New GRN',
                style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goodReceivedNoteListProvider);
        },
        child: grnsAsync.when(
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
                    'Failed to load goods received notes: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(goodReceivedNoteListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allGrns) {
            List<GoodsReceivedNoteResponseModel> grns = allGrns;
            if (isQcInspector) {
              final cId = currentInspector?.id;
              final cUserId = currentUser?.userId;
              final cName = (currentInspector?.name ?? currentUser?.name ?? '').trim().toLowerCase();

              final assignedGrns = allGrns.where((g) {
                final matchesId = cId != null && g.inspectedBy == cId;
                final matchesUserId = cUserId != null && g.inspectedBy == cUserId;
                final matchesName = cName.isNotEmpty && (g.inspectedByName?.toLowerCase().trim() == cName);
                return matchesId || matchesUserId || matchesName;
              }).toList();

              if (assignedGrns.isNotEmpty) {
                grns = assignedGrns;
              } else {
                grns = allGrns;
              }
            }

            final filteredList = grns.where((g) {
              final matchesSearch = _searchQuery.isEmpty ||
                  g.grnNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  'PO-${g.poNumber}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  g.warehouseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  g.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  g.receivedByName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  g.status.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesFilter = _selectedStatusFilter == 'ALL' ||
                  g.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesFilter;
            }).toList();

            int pendingCount = grns.where((g) => g.status == 'PENDING').length;
            int receivedCount = grns.where((g) => g.status == 'RECEIVED' || g.status == 'PARTIALLY_RECEIVED').length;
            int approvedCount = grns.where((g) => g.status == 'APPROVED' || g.status == 'INSPECTED').length;
            int rejectedCount = grns.where((g) => g.status == 'REJECTED').length;

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
                              'INBOUND CARGO & GRN REGISTRY SUMMARY',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _buildBannerMetric('Total GRNs', '${grns.length}', AppTheme.surfaceWhite)),
                            Expanded(child: _buildBannerMetric('Pending', '$pendingCount', AppTheme.warning)),
                            Expanded(child: _buildBannerMetric('Received', '$receivedCount', AppTheme.primaryLight)),
                            Expanded(child: _buildBannerMetric('Approved', '$approvedCount', AppTheme.success)),
                            Expanded(child: _buildBannerMetric('Rejected', '$rejectedCount', AppTheme.danger)),
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
                      hintText: 'Search by GRN#, PO#, Warehouse, Product, Status...',
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
                        _buildFilterChip('ALL', 'All GRNs (${grns.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip('PENDING', 'Pending ($pendingCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('RECEIVED', 'Received'),
                        const SizedBox(width: 8),
                        _buildFilterChip('INSPECTED', 'Inspected'),
                        const SizedBox(width: 8),
                        _buildFilterChip('APPROVED', 'Approved ($approvedCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip('REJECTED', 'Rejected ($rejectedCount)'),
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
                          Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.secondary),
                          SizedBox(height: 12),
                          Text('No GRN records processed in matrix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dark)),
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
                        final stColor = _getStatusColor(item.status);
                        final stBg = _getStatusBg(item.status);

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
                                      color: AppTheme.dark,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.grnNumber.isNotEmpty ? item.grnNumber : 'GRN-${item.id}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.surfaceWhite),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: stColor)),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ref PO: ${item.poNumber.isNotEmpty ? item.poNumber : "PO-#${item.poId}"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                                      Text('PO Node ID: #${item.poId}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                                    ],
                                  ),
                                  Chip(
                                    label: Text('${item.receivedQuantity} / ${item.quantity} Units', style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: AppTheme.light,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.storefront_outlined, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('Terminal: ${item.warehouseName}', style: const TextStyle(fontSize: 11, color: AppTheme.dark, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: AppTheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('Receiver: ${item.receivedByName}', style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    item.inspectedByName != null ? Icons.verified : Icons.hourglass_empty,
                                    size: 14,
                                    color: item.inspectedByName != null ? AppTheme.success : AppTheme.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.inspectedByName != null
                                        ? 'QC Verified: ${item.inspectedByName} (${item.inspectionDate ?? "N/A"})'
                                        : 'QC Inspection Pending',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: item.inspectedByName != null ? AppTheme.success : AppTheme.warning,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.remarks.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Remarks: ${item.remarks}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderGrey),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Logged At: ${item.receivedAt}', style: const TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                  Row(
                                    children: [
                                      if (canStageUpdate)
                                        IconButton(
                                          tooltip: 'Update Stage',
                                          icon: const Icon(Icons.autorenew, color: AppTheme.primary, size: 18),
                                          onPressed: () => _showStatusChangeDialog(context, item),
                                        ),
                                      IconButton(
                                        tooltip: 'Preview & Download PDF',
                                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.danger, size: 18),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GoodReceivedNotePDFScreen(grn: item),
                                          ),
                                        ),
                                      ),
                                      if (!isQcInspector)
                                        IconButton(
                                          tooltip: 'Modify GRN Ledger',
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GoodReceivedNoteFormScreen(grnToEdit: item),
                                            ),
                                          ),
                                        ),
                                      if (!isQcInspector)
                                        IconButton(
                                          tooltip: 'Purge Record',
                                          icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Purge GRN Record?'),
                                                content: const Text('Definitively remove this Goods Received Note record?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Purge', style: TextStyle(color: AppTheme.danger))),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await ref.read(goodReceivedNoteControllerProvider.notifier).deleteGRN(item.id);
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

  void _showStatusChangeDialog(BuildContext context, GoodsReceivedNoteResponseModel item) {
    String selected = item.status;
    final stages = ['PENDING', 'PARTIALLY_RECEIVED', 'RECEIVED', 'INSPECTED', 'APPROVED', 'REJECTED'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Stage Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: stages.map((st) {
              final isSel = selected == st;
              final stColor = _getStatusColor(st);
              return ListTile(
                title: Text(st, style: TextStyle(color: stColor, fontWeight: FontWeight.bold, fontSize: 12)),
                trailing: isSel ? Icon(Icons.check_circle, color: stColor) : null,
                onTap: () => setDialogState(() => selected = st),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final payload = GoodsReceivedNoteRequestModel(
                poId: item.poId,
                productId: item.productId,
                receivedQuantity: item.receivedQuantity,
                receivedBy: item.receivedBy,
                warehouseId: item.warehouseId,
                receivedAt: item.receivedAt,
                status: selected,
                remarks: item.remarks,
                inspectedBy: item.inspectedBy,
                inspectionDate: item.inspectionDate,
                lineItems: [],
              );
              await ref.read(goodReceivedNoteControllerProvider.notifier).updateGRN(item.id, payload);
            },
            child: const Text('Save Stage', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
