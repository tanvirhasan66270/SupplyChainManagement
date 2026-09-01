import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/suppplier/screen/quotation_data_pdf_screen.dart';
import 'package:scm_flutter/suppplier/screen/register_quotation_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class QuotationDataScreen extends ConsumerStatefulWidget {
  final String? initialStatus;

  const QuotationDataScreen({super.key, this.initialStatus});

  @override
  ConsumerState<QuotationDataScreen> createState() => _QuotationDataScreenState();
}

class _QuotationDataScreenState extends ConsumerState<QuotationDataScreen> {
  String searchQtn = '';
  String searchSupplierName = '';
  late String searchState;

  @override
  void initState() {
    super.initState();
    searchState = widget.initialStatus ?? '';
  }

  Future<void> _updateStatus(QuotationResponseModel q, String newStatus) async {
    final success = await ref.read(quotationControllerProvider.notifier).updateQuotationStatus(q.id, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quotation #${q.id} status updated to $newStatus successfully.')),
      );
    }
  }

  Future<void> _deleteQuotation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purge Quotation Envelope'),
        content: Text('Are you sure you want to permanently delete quotation bid #Q-$id?'),
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
      final success = await ref.read(quotationControllerProvider.notifier).deleteQuotation(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quotation envelope purged successfully.'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final quotationsAsync = ref.watch(quotationListProvider);
    final suppliersAsync = ref.watch(supplierListProvider);

    final userRole = (currentUser?.role ?? '').toUpperCase();
    final suppliers = suppliersAsync.value ?? [];
    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Header Bar (Fully Dynamic) ──
            DynamicScmTopNavBar(
              onRefresh: () => ref.invalidate(quotationListProvider),
            ),

            // ── 2. Header Title & Banner Card ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark, AppTheme.indigoDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
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
                              child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Supplier Quotation Matrix',
                              style: TextStyle(color: AppTheme.white, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Text(
                            'Log supplier bids, trace PR reference nodes, and analyze procurement price layouts',
                            style: TextStyle(color: AppTheme.white.withValues(alpha: 0.7), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userRole == 'SUPPLIER')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.white.withValues(alpha: 0.25),
                        foregroundColor: AppTheme.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: AppTheme.white.withValues(alpha: 0.5))),
                      ),
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Upload Bid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterQuotationScreen()),
                        );
                      },
                    ),
                ],
              ),
            ),

            // ── 3. Search Filters Row (Android Responsive) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final qtnSearch = TextField(
                    decoration: _searchDecoration(hint: 'Search QTN No...'),
                    onChanged: (val) => setState(() => searchQtn = val),
                  );

                  final supSearch = TextField(
                    decoration: _searchDecoration(hint: 'Search Supplier...'),
                    onChanged: (val) => setState(() => searchSupplierName = val),
                  );

                  final stateDropdown = DropdownButtonFormField<String>(
                    initialValue: searchState.isEmpty ? '' : searchState,
                    decoration: _searchDecoration(hint: 'State'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All States', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'PENDING', child: Text('PENDING', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'UNDER_REVIEW', child: Text('UNDER_REVIEW', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'EXPIRED', child: Text('EXPIRED', style: TextStyle(fontSize: 11))),
                    ],
                    onChanged: (val) => setState(() => searchState = val ?? ''),
                  );

                  if (isMobile) {
                    return Column(
                      children: [
                        qtnSearch,
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (userRole != 'SUPPLIER') ...[
                              Expanded(child: supSearch),
                              const SizedBox(width: 8),
                            ],
                            Expanded(child: stateDropdown),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: qtnSearch),
                      if (userRole != 'SUPPLIER') ...[
                        const SizedBox(width: 8),
                        Expanded(child: supSearch),
                      ],
                      const SizedBox(width: 8),
                      Expanded(child: stateDropdown),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── 4. Quotations List View ──
            Expanded(
              child: quotationsAsync.when(
                data: (quotations) {
                  List<QuotationResponseModel> roleFiltered = quotations;
                  if (userRole == 'SUPPLIER' && currentSupplier != null) {
                    roleFiltered = quotations.where((q) => q.supplierId == currentSupplier.id).toList();
                  }

                  final filtered = roleFiltered.where((q) {
                    final qtnNo = (q.quotationNumber.isNotEmpty ? q.quotationNumber : 'QTN-${q.id}').toLowerCase();
                    final supName = q.supplierName.toLowerCase();
                    final status = q.status.toLowerCase();

                    final matchesQtn = searchQtn.isEmpty || qtnNo.contains(searchQtn.toLowerCase().trim());
                    final matchesSup = searchSupplierName.isEmpty || supName.contains(searchSupplierName.toLowerCase().trim());
                    final matchesState = searchState.isEmpty || status.contains(searchState.toLowerCase().trim());

                    return matchesQtn && matchesSup && matchesState;
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
                            Text('No quotations match your criteria.', style: TextStyle(color: AppTheme.secondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final q = filtered[index];
                      final statusColor = AppTheme.statusColor(q.status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: QTN Badge, Supplier & Status
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
                                    q.quotationNumber.isNotEmpty ? q.quotationNumber : 'QTN-${q.id}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      q.supplierName.isNotEmpty ? q.supplierName : 'Supplier #${q.supplierId}',
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
                                    q.status,
                                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // PR Node Meta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Linked Product: ${q.productName.isNotEmpty ? q.productName : "Product #${q.productIds}"}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PR Node: #PR-${q.purchaseRequisitionId}',
                                  style: const TextStyle(fontSize: 9, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Price & Volume Details (Responsive Expanded)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$${q.unitPrice.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark),
                                      ),
                                      const Text('Unit Bid Price', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${q.quantity} Pcs',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark),
                                      ),
                                      const Text('Qty Required', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${q.totalPrice.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.success),
                                      ),
                                      const Text('Aggregate Price', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Bottom Actions Row (Status Change & Actions)
                            Row(
                              children: [
                                if (userRole == 'ADMIN' || userRole == 'PROCUREMENT' || userRole == 'MANAGER')
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: ['PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'EXPIRED'].contains(q.status) ? q.status : 'PENDING',
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'PENDING', child: Text('PENDING', style: TextStyle(fontSize: 10))),
                                        DropdownMenuItem(value: 'UNDER_REVIEW', child: Text('UNDER_REVIEW', style: TextStyle(fontSize: 10))),
                                        DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED', style: TextStyle(fontSize: 10))),
                                        DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED', style: TextStyle(fontSize: 10))),
                                        DropdownMenuItem(value: 'EXPIRED', child: Text('EXPIRED', style: TextStyle(fontSize: 10))),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) _updateStatus(q, val);
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  color: const Color(0xFF1E3A8A),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => QuotationDataPDFScreen(quotation: q)),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                if (userRole == 'SUPPLIER' && (q.status.toUpperCase() == 'PENDING' || q.status.toUpperCase() == 'DRAFT')) ...[
                                  _buildActionButton(
                                    icon: Icons.edit_outlined,
                                    color: AppTheme.primary,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => RegisterQuotationScreen(quotationToEdit: q)),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (userRole == 'ADMIN' || userRole == 'MANAGER' || userRole == 'PROCUREMENT') ...[
                                  if (q.status.toUpperCase() == 'APPROVED') ...[
                                    _buildActionButton(
                                      icon: Icons.shopping_cart_checkout,
                                      color: AppTheme.success,
                                      onTap: () {
                                        Navigator.pushNamed(context, '/purchase-order-create');
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  _buildActionButton(
                                    icon: Icons.delete_outline,
                                    color: AppTheme.danger,
                                    onTap: () => _deleteQuotation(q.id),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading quotations: $err', style: const TextStyle(color: AppTheme.danger))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: userRole == 'SUPPLIER'
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Quotation', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterQuotationScreen()),
                );
              },
            )
          : null,
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
