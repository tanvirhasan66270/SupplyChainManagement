import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/commercial_officer/provider/invoice_provider.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_invoice_form_screen.dart';
import 'package:scm_flutter/commercial_officer/screen/commercial_invoice_pdf_screen.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

import 'package:scm_flutter/them/allAppThim.dart';

class CommercialInvoiceDataScreen extends ConsumerStatefulWidget {
  const CommercialInvoiceDataScreen({super.key});

  @override
  ConsumerState<CommercialInvoiceDataScreen> createState() => _CommercialInvoiceDataScreenState();
}

class _CommercialInvoiceDataScreenState extends ConsumerState<CommercialInvoiceDataScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getInvoiceStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ISSUED':
        return AppTheme.success;
      case 'DRAFT':
        return AppTheme.grey;
      case 'CANCELLED':
        return AppTheme.danger;
      default:
        return AppTheme.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AppTheme.success;
      case 'PARTIALLY_PAID':
        return AppTheme.warning;
      case 'UNPAID':
      case 'REFUNDED':
        return AppTheme.danger;
      default:
        return AppTheme.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentCustomerAsync = ref.watch(currentCustomerProvider);

    final userRole = currentUser?.role.toUpperCase() ?? '';
    final isCustomer = userRole == 'CUSTOMER';
    final customerEmail = currentUser?.email.toLowerCase().trim() ?? '';
    final customerName = (currentCustomerAsync.value?.name ?? currentUser?.name ?? '').toLowerCase().trim();

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: DynamicScmTopNavBar(
        showBackButton: true,
        title: isCustomer ? 'My Invoices & Payments' : 'Commercial Invoice Ledger',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(invoiceListProvider);
        },
        child: invoiceListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading commercial invoice ledger: $err',
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          data: (allInvoices) {
            List<dynamic> invoicesList = allInvoices;
            if (isCustomer) {
              invoicesList = allInvoices.where((inv) {
                final matchesEmail = customerEmail.isNotEmpty && inv.customerEmail.toLowerCase().trim() == customerEmail;
                final matchesName = customerName.isNotEmpty && inv.issuedToName.toLowerCase().trim() == customerName;
                return matchesEmail || matchesName;
              }).toList();
            }

            final invoices = invoicesList.cast<dynamic>();
            final totalCount = invoices.length;
            final totalBilling = invoices.fold<double>(0, (sum, inv) => sum + inv.totalAmount);
            final paidBilling = invoices.fold<double>(0, (sum, inv) => sum + inv.paidAmount);
            final unpaidDues = invoices.fold<double>(0, (sum, inv) => sum + inv.dueAmount);

            // Filter logic
            final filteredInvoices = invoices.where((inv) {
              final query = _searchQuery.toLowerCase();
              final matchesSearch = query.isEmpty ||
                  inv.invoiceNumber.toLowerCase().contains(query) ||
                  inv.issuedToName.toLowerCase().contains(query) ||
                  inv.customerEmail.toLowerCase().contains(query) ||
                  (inv.customerOrderId != null && inv.customerOrderId.toString().contains(query));

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  inv.invoiceStatus.toUpperCase() == _selectedStatusFilter.toUpperCase() ||
                  inv.paymentStatus.toUpperCase() == _selectedStatusFilter.toUpperCase();

              return matchesSearch && matchesStatus;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Metric Pipeline Banner ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.dark, AppTheme.indigoDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
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
                                Icon(Icons.receipt_long_outlined, color: AppTheme.blueLight, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Commercial Billing Ledger Pipeline',
                                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            if (!isCustomer)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('New Invoice', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CommercialInvoiceFormScreen()),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBannerMetric('INVOICES', '$totalCount', AppTheme.white),
                            _buildBannerMetric('TOTAL BILLING', '৳${totalBilling.toStringAsFixed(0)}', AppTheme.blueLight),
                            _buildBannerMetric('PAID BILLING', '৳${paidBilling.toStringAsFixed(0)}', AppTheme.success),
                            _buildBannerMetric('UNPAID DUES', '৳${unpaidDues.toStringAsFixed(0)}', AppTheme.danger),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Search Bar ──
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Invoice No, Recipient, Order ID...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderGrey),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Status Filter Chips ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL'),
                        _buildFilterChip('ISSUED'),
                        _buildFilterChip('DRAFT'),
                        _buildFilterChip('CANCELLED'),
                        _buildFilterChip('PAID'),
                        _buildFilterChip('UNPAID'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Commercial Invoices Cards List ──
                  if (filteredInvoices.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.description_outlined, size: 48, color: AppTheme.grey),
                          SizedBox(height: 12),
                          Text(
                            'No commercial invoices generated within this scope.',
                            style: TextStyle(color: AppTheme.grey, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final inv = filteredInvoices[index];
                        final invColor = _getInvoiceStatusColor(inv.invoiceStatus);
                        final payColor = _getPaymentStatusColor(inv.paymentStatus);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row: Invoice Code, Recipient, Badges
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            inv.invoiceNumber,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            inv.issuedToName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary),
                                          ),
                                          Text(
                                            inv.customerEmail,
                                            style: const TextStyle(fontSize: 10, color: AppTheme.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: invColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: invColor.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            inv.invoiceStatus,
                                            style: TextStyle(color: invColor, fontWeight: FontWeight.bold, fontSize: 10),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: payColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: payColor.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            inv.paymentStatus,
                                            style: TextStyle(color: payColor, fontWeight: FontWeight.bold, fontSize: 9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Order Ref Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.light,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ORD-#${inv.customerOrderId ?? "N/A"}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.indigoDark),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Financial Metrics Grid
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.light,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.borderGrey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text('৳${inv.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.success)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text('PAID AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text('৳${inv.paidAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.success)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('DUE AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text(
                                            '৳${inv.dueAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: inv.dueAmount > 0 ? AppTheme.danger : AppTheme.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 16),

                                // Action Buttons Row
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryDark,
                                        foregroundColor: AppTheme.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                                      label: const Text('View Invoice PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CommercialInvoicePdfScreen(invoice: inv),
                                          ),
                                        );
                                      },
                                    ),
                                    if (!isCustomer)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppTheme.warning, size: 20),
                                            tooltip: 'Edit Parameters',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => CommercialInvoiceFormScreen(invoiceToEdit: inv),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                                            tooltip: 'Purge Record',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Confirm Deletion'),
                                                  content: Text('Are you sure you want to drop invoice ${inv.invoiceNumber}?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.danger))),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                await ref.read(invoiceControllerProvider.notifier).deleteInvoice(inv.id);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
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
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.grey, fontSize: 8, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterName) {
    final isSelected = _selectedStatusFilter == filterName;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(
          filterName,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.indigoDark,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        selected: isSelected,
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.white,
        checkmarkColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.borderGrey,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedStatusFilter = filterName;
          });
        },
      ),
    );
  }
}
