import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/cutomer/provider/payment_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/payment_statement_model.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/pdf_statement_generator.dart';
import 'package:scm_flutter/widget/commonWidget.dart';

class BillingLedgerScreen extends ConsumerStatefulWidget {
  const BillingLedgerScreen({super.key, this.initialOrderNumber});
  final String? initialOrderNumber;

  @override
  ConsumerState<BillingLedgerScreen> createState() => _BillingLedgerScreenState();
}

class _BillingLedgerScreenState extends ConsumerState<BillingLedgerScreen> {
  final _searchController = TextEditingController();
  String? _searchedCode;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderNumber != null) {
      _searchController.text = widget.initialOrderNumber!;
      _searchedCode = widget.initialOrderNumber;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = (_searchedCode != null) ? ref.watch(orderPaymentsProvider(_searchedCode!)) : null;
    final orderAsync = (_searchedCode != null) ? ref.watch(trackCustomerOrderProvider(_searchedCode!)) : null;

    final currentPayments = paymentsAsync?.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text('Billing Ledger', style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: [
          if (orderAsync != null && orderAsync.hasValue)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Download PDF Statement',
                icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
                onPressed: _isGeneratingPdf ? null : () => _downloadPdf(orderAsync.value!, currentPayments),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            if (_searchedCode == null) _buildEmptyState('Search for an order to view history')
            else ...[
               if (orderAsync != null) orderAsync.when(
                 data: (order) => _buildFinancialCard(order, currentPayments),
                 loading: () => const LinearProgressIndicator(),
                 error: (e, _) => ErrorBanner(message: apiErrorMessage(e)),
               ),
               const SizedBox(height: 20),
               if (paymentsAsync != null) paymentsAsync.when(
                 data: (payments) => _buildPaymentLog(payments),
                 loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                 error: (e, _) => ErrorBanner(message: apiErrorMessage(e)),
               ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryDark, AppTheme.blue]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Statement', style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Consolidated financial log for your orders', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: AppTheme.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Order No (ORD-...)', border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)),
                    onSubmitted: (v) => setState(() => _searchedCode = v.trim()),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _searchedCode = _searchController.text.trim()),
                  icon: const Icon(Icons.search, color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(CustomerOrderResponse order, List<PaymentStatementResponse> payments) async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfStatementGenerator.downloadOrPrint(order: order, payments: payments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Widget _buildFinancialCard(CustomerOrderResponse order, List<PaymentStatementResponse> payments) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Financial Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    StatusBadge(status: order.paymentStatus),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isGeneratingPdf ? null : () => _downloadPdf(order, payments),
                      icon: _isGeneratingPdf
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white))
                          : const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('PDF Download', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [
              _statItem('Grand Total', '৳${order.totalAmount}', AppTheme.blue),
              _statItem('Total Paid', '৳${order.paidAmount}', AppTheme.success),
              _statItem('Balance Due', '৳${order.dueAmount}', AppTheme.danger),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(child: Column(children: [
      Text(label, style: const TextStyle(color: AppTheme.grey, fontSize: 10)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
    ]));
  }

  Widget _buildPaymentLog(List<PaymentStatementResponse> payments) {
    if (payments.isEmpty) {
      return _buildEmptyState('No payment transactions found for this order.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TRANSACTION HISTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.grey)),
        const SizedBox(height: 10),
        ...payments.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderGrey)),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: AppTheme.blueLight.withValues(alpha: 0.2), child: const Icon(Icons.payment, size: 18, color: AppTheme.blue)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(p.createdAt.substring(0, 16).replaceFirst('T', ' '), style: const TextStyle(color: AppTheme.grey, fontSize: 10)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('৳${p.paidAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 13)),
                Text(PaymentStatementStatusMeta.labelFor(p.issueStatus), style: TextStyle(fontSize: 9, color: p.issueStatus == PaymentStatementStatus.confirmedByOfficer ? AppTheme.success : AppTheme.warning)),
              ]),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(msg, style: const TextStyle(color: AppTheme.grey, fontSize: 12))));
  }
}
