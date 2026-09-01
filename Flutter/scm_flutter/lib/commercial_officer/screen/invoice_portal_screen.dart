import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/util/pdf_invoice_generator.dart';
import 'package:scm_flutter/widget/commonWidget.dart';

class InvoicePortalScreen extends ConsumerStatefulWidget {
  const InvoicePortalScreen({super.key, this.initialOrderNumber});
  final String? initialOrderNumber;

  @override
  ConsumerState<InvoicePortalScreen> createState() => _InvoicePortalScreenState();
}

class _InvoicePortalScreenState extends ConsumerState<InvoicePortalScreen> {
  final _searchController = TextEditingController();
  String? _searchedCode;

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
    final orderAsync = (_searchedCode != null) ? ref.watch(trackCustomerOrderProvider(_searchedCode!)) : null;

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text('Invoice Portal', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            if (_searchedCode == null) _buildEmptyState()
            else if (orderAsync != null) orderAsync.when(
              data: (order) => _buildInvoice(order),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorBanner(message: apiErrorMessage(e)),
            ),
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
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Invoice Portal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('View and download official sales invoices', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Order No / Invoice ID', border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)),
                    onSubmitted: (v) => setState(() => _searchedCode = v.trim()),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _searchedCode = _searchController.text.trim()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('Get Invoice'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoice(CustomerOrderResponse order) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                   Text('OFFICIAL INVOICE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                   Text('SCM PRO Supply Chain Management', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
                StatusBadge(status: order.paymentStatus),
              ]),
              const Divider(height: 32),
              
              _infoRow('Invoice Number', 'INV-${order.orderNumber}', 'Order Reference', order.orderNumber),
              const SizedBox(height: 12),
              _infoRow('Issued To', order.customerName, 'Email', order.customerEmail),
              const SizedBox(height: 12),
              _infoRow('Issued At', order.createdAt.substring(0, 10), 'Currency', order.currency),
              
              const SizedBox(height: 32),
              const Text('ITEMIZED PRODUCTS BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              
              _buildItemsTable(order),
              
              const SizedBox(height: 24),
              _buildFinancials(order),
              
              const SizedBox(height: 40),
              _buildSignatureBlock(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await PdfInvoiceGenerator.downloadOrPrint(order: order);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error generating PDF invoice: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Download PDF Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {}, // Implementation for doc export could go here
                icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                label: const Text('Export Word (.doc)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B579A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(String l1, String v1, String l2, String v2) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l1, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(v1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ])),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l2, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(v2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ])),
    ]);
  }

  Widget _buildItemsTable(CustomerOrderResponse order) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(
          color: const Color(0xFF0F172A),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Row(children: [
            Expanded(flex: 3, child: Text('Description', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10))),
            Expanded(child: Text('Total', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 10))),
          ]),
        ),
        ...order.lineItems.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(child: Text(item.quantity.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
            Expanded(child: Text('৳${item.lineTotal}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))),
          ]),
        )),
      ]),
    );
  }

  Widget _buildFinancials(CustomerOrderResponse order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _finRow('Subtotal', '৳${order.itemSubtotal}'),
        _finRow('Shipping', '৳${order.deliveryCharge}'),
        const Divider(),
        _finRow('Grand Total', '৳${order.totalAmount}', isBold: true, color: Colors.blue),
        _finRow('Paid', '৳${order.paidAmount}', color: Colors.green),
        _finRow('Balance Due', '৳${order.dueAmount}', color: Colors.red),
      ]),
    );
  }

  Widget _finRow(String l, String v, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : null)),
        Text(v, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildSignatureBlock() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _sig('Officer Signature'),
      _sig('Manager Signature'),
    ]);
  }

  Widget _sig(String label) {
    return Column(children: [
      const Text('--------------------', style: TextStyle(color: Colors.grey)),
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.all(60), child: Text('Enter an order number to view invoice details.', style: TextStyle(color: Colors.grey, fontSize: 12))));
  }
}
