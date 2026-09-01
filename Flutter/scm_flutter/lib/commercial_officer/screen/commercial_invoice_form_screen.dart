import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scm_flutter/commercial_officer/provider/invoice_provider.dart';
import 'package:scm_flutter/cutomer/provider/customeroredr_provider.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';
import 'package:scm_flutter/entity/invoiceModel.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class CommercialInvoiceFormScreen extends ConsumerStatefulWidget {
  const CommercialInvoiceFormScreen({
    super.key,
    this.invoiceToEdit,
  });

  final InvoiceResponseModel? invoiceToEdit;

  @override
  ConsumerState<CommercialInvoiceFormScreen> createState() => _CommercialInvoiceFormScreenState();
}

class _CommercialInvoiceFormScreenState extends ConsumerState<CommercialInvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCustomerOrderId;
  int? _salesOfficerId;
  final _subtotalController = TextEditingController(text: '0');
  double _selectedTaxRate = 0.0;
  final _discountPctController = TextEditingController(text: '0');
  final _discountFlatController = TextEditingController(text: '0');
  final _shippingFeesController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController(text: '0');

  String _paymentMethod = 'CASH';
  final _txnRefController = TextEditingController();
  String _invoiceStatus = 'DRAFT';
  final _deliveryDateController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _cancelledReasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _errorMessage;
  bool _isSubmitting = false;

  bool get _isEdit => widget.invoiceToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final inv = widget.invoiceToEdit!;
      _selectedCustomerOrderId = inv.customerOrderId;
      _salesOfficerId = inv.salesOfficerId;
      _subtotalController.text = inv.subtotal.toStringAsFixed(2);
      _selectedTaxRate = inv.taxRate;
      _discountPctController.text = inv.discountPercentage.toStringAsFixed(2);
      _discountFlatController.text = inv.discountAmount.toStringAsFixed(2);
      _shippingFeesController.text = inv.shippingFees.toStringAsFixed(2);
      _paidAmountController.text = inv.paidAmount.toStringAsFixed(2);
      _paymentMethod = inv.paymentMethod ?? 'CASH';
      _txnRefController.text = inv.transactionReference ?? '';
      _invoiceStatus = inv.invoiceStatus;
      _deliveryDateController.text = inv.deliveryDate ?? '';
      _deliveryAddressController.text = inv.deliveryAddress;
      _cancelledReasonController.text = inv.cancelledReason ?? '';
      _notesController.text = inv.notes ?? '';
    }
  }

  @override
  void dispose() {
    _subtotalController.dispose();
    _discountPctController.dispose();
    _discountFlatController.dispose();
    _shippingFeesController.dispose();
    _paidAmountController.dispose();
    _txnRefController.dispose();
    _deliveryDateController.dispose();
    _deliveryAddressController.dispose();
    _cancelledReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCustomerOrderChanged(CustomerOrderResponse? order) {
    if (order == null) return;
    setState(() {
      _selectedCustomerOrderId = order.id;
      _subtotalController.text = order.totalAmount.toStringAsFixed(2);
      _paidAmountController.text = order.paidAmount.toStringAsFixed(2);
      _deliveryAddressController.text = order.deliveryAddress;
      if (order.paymentMethod.isNotEmpty) {
        _paymentMethod = order.paymentMethod;
      }
      _recalculateDiscountPct();
    });
  }

  void _recalculateDiscountPct() {
    final subtotal = double.tryParse(_subtotalController.text) ?? 0.0;
    final pct = double.tryParse(_discountPctController.text) ?? 0.0;
    if (subtotal > 0 && pct >= 0) {
      final amt = (subtotal * pct) / 100.0;
      _discountFlatController.text = amt.toStringAsFixed(2);
    } else {
      _discountFlatController.text = '0.00';
    }
  }

  void _recalculateDiscountFlat() {
    final subtotal = double.tryParse(_subtotalController.text) ?? 0.0;
    final flat = double.tryParse(_discountFlatController.text) ?? 0.0;
    if (subtotal > 0 && flat >= 0) {
      final pct = (flat / subtotal) * 100.0;
      _discountPctController.text = pct.toStringAsFixed(2);
    } else {
      _discountPctController.text = '0.00';
    }
  }

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _deliveryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() => _errorMessage = null);

    if (_selectedCustomerOrderId == null || _selectedCustomerOrderId == 0) {
      setState(() => _errorMessage = "Validation Fault: Customer Order Linkage is required.");
      return;
    }

    if (_deliveryAddressController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Validation Fault: Structural Delivery Address map is required.");
      return;
    }

    if (_invoiceStatus == 'CANCELLED' && _cancelledReasonController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Validation Fault: Cancellation reason is required when status is CANCELLED.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final req = InvoiceRequestModel(
      customerOrderId: _selectedCustomerOrderId,
      salesOfficerId: _salesOfficerId,
      subtotal: double.tryParse(_subtotalController.text) ?? 0.0,
      taxRate: _selectedTaxRate,
      discountAmount: double.tryParse(_discountFlatController.text) ?? 0.0,
      discountPercentage: double.tryParse(_discountPctController.text) ?? 0.0,
      shippingFees: double.tryParse(_shippingFeesController.text) ?? 0.0,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,
      paymentMethod: _paymentMethod,
      transactionReference: _txnRefController.text.trim().isEmpty ? null : _txnRefController.text.trim(),
      invoiceStatus: _invoiceStatus,
      deliveryDate: _deliveryDateController.text.trim().isEmpty ? null : _deliveryDateController.text.trim(),
      deliveryAddress: _deliveryAddressController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      cancelledReason: _invoiceStatus == 'CANCELLED' ? _cancelledReasonController.text.trim() : null,
    );

    final controller = ref.read(invoiceControllerProvider.notifier);
    bool success = false;
    if (_isEdit) {
      success = await controller.updateInvoice(widget.invoiceToEdit!.id, req);
    } else {
      success = await controller.createInvoice(req);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Invoice configuration updated successfully.' : 'New commercial invoice node created.'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Failed to submit invoice dataset node.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerOrdersAsync = ref.watch(customerOrderListProvider);
    final ordersList = customerOrdersAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Modify Commercial Invoice' : 'Generate Commercial Invoice Node',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: const [
          DynamicNotificationButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.dark, AppTheme.indigoDark]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEdit ? 'Commercial Invoice Ledger Patch' : 'Initiate Commercial Invoice Genesis',
                      style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Complete all parameters step by step from top to bottom.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Step 1: Customer Order Selection ──
              _buildStepHeader('Step 1', 'Link Customer Order Vector'),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedCustomerOrderId,
                decoration: const InputDecoration(
                  labelText: 'Select Verified Customer Order *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ordersList.map((o) {
                  return DropdownMenuItem<int>(
                    value: o.id,
                    child: Text(
                      'Order #${o.orderNumber} (${o.customerName}) - ৳${o.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: _isEdit
                    ? null
                    : (val) {
                        final selected = ordersList.firstWhere((element) => element.id == val);
                        _onCustomerOrderChanged(selected);
                      },
              ),
              const SizedBox(height: 16),

              // ── Step 2: Financial Subtotal ──
              _buildStepHeader('Step 2', 'Financial Subtotal Volume'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _subtotalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Financial Subtotal Amount *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => _recalculateDiscountPct(),
                validator: (val) => val == null || val.isEmpty ? 'Subtotal is required' : null,
              ),
              const SizedBox(height: 16),

              // ── Step 3: Tax Rate Tariff ──
              _buildStepHeader('Step 3', 'Tax Rate Tariff Multiplier'),
              const SizedBox(height: 6),
              DropdownButtonFormField<double>(
                initialValue: _selectedTaxRate,
                decoration: const InputDecoration(
                  labelText: 'Select Tax Rate',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 0.0, child: Text('0% (Zero Rated)')),
                  DropdownMenuItem(value: 0.05, child: Text('5% (Standard Tariffs)')),
                  DropdownMenuItem(value: 0.15, child: Text('15% (Corporate VAT)')),
                ],
                onChanged: (v) => setState(() => _selectedTaxRate = v ?? 0.0),
              ),
              const SizedBox(height: 16),

              // ── Step 4: Discount Pct (%) ──
              _buildStepHeader('Step 4', 'Discount Percentage Margin (%)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _discountPctController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Discount Percentage (%)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => _recalculateDiscountPct(),
              ),
              const SizedBox(height: 16),

              // ── Step 5: Discount Flat Amount ──
              _buildStepHeader('Step 5', 'Discount Flat Amount'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _discountFlatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Discount Flat Amount (৳)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => _recalculateDiscountFlat(),
              ),
              const SizedBox(height: 16),

              // ── Step 6: Shipping Fees ──
              _buildStepHeader('Step 6', 'Logistics Shipping Fees'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _shippingFeesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Logistics / Shipping Fees (৳)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // ── Step 7: Paid Amount ──
              _buildStepHeader('Step 7', 'Paid Account Balance'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _paidAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Paid Account Balance (৳)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // ── Step 8: Payment Instrument ──
              _buildStepHeader('Step 8', 'Payment Instrument'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Instrument / Channel',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('CASH')),
                  DropdownMenuItem(value: 'BANK', child: Text('BANK / CHECK / LC')),
                  DropdownMenuItem(value: 'BKASH', child: Text('BKASH MFS GATEWAY')),
                  DropdownMenuItem(value: 'NAGAD', child: Text('NAGAD ROUTING')),
                  DropdownMenuItem(value: 'ROCKET', child: Text('ROCKET VALUE')),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v ?? 'CASH'),
              ),
              const SizedBox(height: 16),

              // ── Step 9: Txn Ref ──
              _buildStepHeader('Step 9', 'Transaction Reference String'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _txnRefController,
                decoration: const InputDecoration(
                  labelText: 'Txn Reference String',
                  hintText: 'e.g., CHK-99210, MFS-TxnID',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // ── Step 10: Invoice Status ──
              _buildStepHeader('Step 10', 'Invoice Pipeline Status'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _invoiceStatus,
                decoration: const InputDecoration(
                  labelText: 'Invoice Pipeline Status *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'DRAFT', child: Text('📁 DRAFT MODE (Under Review)')),
                  DropdownMenuItem(value: 'ISSUED', child: Text('🚀 ISSUED MODE (Commit & Dispatch)')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('❌ CANCELLED MODE (Revoke Ledger)')),
                ],
                onChanged: (v) => setState(() => _invoiceStatus = v ?? 'DRAFT'),
              ),
              const SizedBox(height: 16),

              // ── Step 11: Target Delivery Date ──
              _buildStepHeader('Step 11', 'Target Delivery Date'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deliveryDateController,
                readOnly: true,
                onTap: _pickDeliveryDate,
                decoration: const InputDecoration(
                  labelText: 'Target Delivery Date (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // ── Step 12: Delivery Address ──
              _buildStepHeader('Step 12', 'Consignment Destination Address'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deliveryAddressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Consignment Shipping Address *',
                  hintText: 'Input physical destination drop coordinates...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Delivery address is required' : null,
              ),
              const SizedBox(height: 16),

              if (_invoiceStatus == 'CANCELLED') ...[
                _buildStepHeader('Step 13', 'Revocation / Cancellation Reason'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cancelledReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Audit Interruption / Cancellation Reason *',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => _invoiceStatus == 'CANCELLED' && (val == null || val.trim().isEmpty) ? 'Cancellation reason is required' : null,
                ),
                const SizedBox(height: 16),
              ],

              _buildStepHeader(_invoiceStatus == 'CANCELLED' ? 'Step 14' : 'Step 13', 'Internal Accounting Notes'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes & Accounting Instructions',
                  hintText: 'Log terms, bank details, or internal notes...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2))
                      : const Icon(Icons.shield_outlined, size: 20),
                  label: Text(
                    _isSubmitting
                        ? 'PROCESSING...'
                        : (_isEdit ? 'PUSH MATRIX PATCH' : 'EXECUTE ASSET GENESIS'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String stepLabel, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            stepLabel,
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigoDark),
        ),
      ],
    );
  }
}
