import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/commercial_officer/screen/customer_payment_pdf_screen.dart';
import 'package:scm_flutter/cutomer/provider/payment_provider.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class CustomerPaymentDataScreen extends ConsumerStatefulWidget {
  const CustomerPaymentDataScreen({super.key});

  @override
  ConsumerState<CustomerPaymentDataScreen> createState() => _CustomerPaymentDataScreenState();
}

class _CustomerPaymentDataScreenState extends ConsumerState<CustomerPaymentDataScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED_BY_OFFICER':
      case 'ACCEPTED':
        return AppTheme.success;
      case 'PENDING_VERIFICATION':
      case 'PENDING':
        return AppTheme.warning;
      case 'FAILED_OR_REJECTED':
      case 'REJECTED':
        return AppTheme.danger;
      default:
        return AppTheme.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED_BY_OFFICER':
        return 'CONFIRMED / ACCEPTED';
      case 'PENDING_VERIFICATION':
        return 'PENDING VERIFICATION';
      case 'FAILED_OR_REJECTED':
        return 'REJECTED / FAILED';
      default:
        return status;
    }
  }

  Future<void> _updateStatus(int paymentId, String statusLabel, String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Payment Status to $statusLabel?'),
        content: Text('Are you sure you want to update payment #$paymentId status to $statusLabel?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final controller = ref.read(paymentStatementControllerProvider.notifier);
      final success = await controller.updateStatus(paymentId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Payment status updated to $statusLabel successfully' : 'Failed to update payment status'),
            backgroundColor: success ? AppTheme.success : AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentListAsync = ref.watch(paymentStatementListProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Customer Payment Audit & Acceptance',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(paymentStatementListProvider);
        },
        child: paymentListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading payment statements: $err',
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          data: (payments) {
            final totalCount = payments.length;
            final totalAmount = payments.fold<double>(0, (sum, p) => sum + p.paidAmount);
            final confirmedCount = payments.where((p) => p.issueStatus == 'CONFIRMED_BY_OFFICER').length;
            final pendingCount = payments.where((p) => p.issueStatus == 'PENDING_VERIFICATION').length;

            // Filter logic
            final filteredPayments = payments.where((p) {
              final query = _searchQuery.toLowerCase();
              final matchesSearch = query.isEmpty ||
                  p.transactionId.toLowerCase().contains(query) ||
                  p.orderNumber.toLowerCase().contains(query) ||
                  p.paymentMethod.toLowerCase().contains(query) ||
                  (p.customerAccountNumber != null && p.customerAccountNumber!.toLowerCase().contains(query));

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  p.issueStatus.toUpperCase() == _selectedStatusFilter.toUpperCase();

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
                        const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, color: AppTheme.blueLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Customer Payment Verification Pipeline',
                              style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBannerMetric('TOTAL STATEMENTS', '$totalCount', AppTheme.white),
                            _buildBannerMetric('TOTAL PAID', '৳${totalAmount.toStringAsFixed(0)}', AppTheme.blueLight),
                            _buildBannerMetric('ACCEPTED', '$confirmedCount', AppTheme.success),
                            _buildBannerMetric('PENDING', '$pendingCount', AppTheme.warning),
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
                      hintText: 'Search by Txn ID, Order No, Payment Method...',
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
                        _buildFilterChip('CONFIRMED_BY_OFFICER', label: 'ACCEPTED'),
                        _buildFilterChip('PENDING_VERIFICATION', label: 'PENDING'),
                        _buildFilterChip('FAILED_OR_REJECTED', label: 'REJECTED'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Payment Cards List ──
                  if (filteredPayments.isEmpty)
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
                          Icon(Icons.payment_outlined, size: 48, color: AppTheme.grey),
                          SizedBox(height: 12),
                          Text(
                            'No customer payment statements found within this scope.',
                            style: TextStyle(color: AppTheme.grey, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final p = filteredPayments[index];
                        final statusColor = _getStatusColor(p.issueStatus);
                        final statusLabel = _getStatusLabel(p.issueStatus);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Txn Ref, Order No & Status Badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.transactionId.isNotEmpty ? p.transactionId : '#PAY-${p.id}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Order #${p.orderNumber} (ID: ${p.customerOrderId})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Payment Metrics Grid
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
                                          const Text('PAID AMOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text('৳${p.paidAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.success)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text('INSTRUMENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text(p.paymentMethod.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.dark)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('ACCOUNT / REF', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.grey)),
                                          Text(p.customerAccountNumber ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.indigoDark)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 16),

                                // Action Row with Status Buttons
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    // 1. Accept & Confirm Button
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.success,
                                        foregroundColor: AppTheme.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.check_circle_outline, size: 14),
                                      label: const Text('Accept', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      onPressed: () => _updateStatus(p.id, 'ACCEPTED', 'CONFIRMED_BY_OFFICER'),
                                    ),
                                    // 2. Reject Button
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.danger,
                                        foregroundColor: AppTheme.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.cancel_outlined, size: 14),
                                      label: const Text('Reject', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      onPressed: () => _updateStatus(p.id, 'REJECTED', 'FAILED_OR_REJECTED'),
                                    ),
                                    // 3. Set Pending Button
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.hourglass_empty, size: 14, color: AppTheme.warning),
                                      label: const Text('Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.warning)),
                                      onPressed: () => _updateStatus(p.id, 'PENDING', 'PENDING_VERIFICATION'),
                                    ),
                                    // 4. View PDF Button
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryDark,
                                        foregroundColor: AppTheme.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.picture_as_pdf, size: 14),
                                      label: const Text('PDF Receipt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CustomerPaymentPdfScreen(payment: p),
                                          ),
                                        );
                                      },
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

  Widget _buildFilterChip(String filterName, {String? label}) {
    final isSelected = _selectedStatusFilter == filterName;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(
          label ?? filterName,
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
