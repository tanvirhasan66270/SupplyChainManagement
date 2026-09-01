import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class PurchaseOrderScreen extends ConsumerStatefulWidget {
  final PurchaseOrderResponse? orderToEdit;

  const PurchaseOrderScreen({super.key, this.orderToEdit});

  @override
  ConsumerState<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends ConsumerState<PurchaseOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? selectedQuotationId;
  double totalAmount = 0.0;
  int quantity = 1;
  String currency = 'USD';
  String expectedDeliveryDate = '';
  String supplierName = 'N/A';
  String supplierEmail = 'N/A';
  int purchaseRequisitionId = 0;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _supplierEmailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _createdAtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.orderToEdit != null) {
      final po = widget.orderToEdit!;
      selectedQuotationId = po.quotationId;
      totalAmount = po.totalAmount;
      quantity = po.quantity;
      currency = po.currency.isNotEmpty ? po.currency : 'USD';
      expectedDeliveryDate = po.expectedDeliveryDate;
      supplierName = po.supplierName;
      supplierEmail = po.supplierEmail;
      purchaseRequisitionId = po.purchaseRequisitionId;

      _amountController.text = totalAmount.toStringAsFixed(2);
      _supplierNameController.text = supplierName;
      _supplierEmailController.text = supplierEmail;
      _dateController.text = expectedDeliveryDate;
      _createdAtController.text = po.createdAt.isNotEmpty ? po.createdAt : DateTime.now().toString().split('.')[0];
    } else {
      _createdAtController.text = DateTime.now().toString().split('.')[0];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _supplierNameController.dispose();
    _supplierEmailController.dispose();
    _dateController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  void _onQuotationSelected(QuotationResponseModel q) {
    setState(() {
      selectedQuotationId = q.id;
      totalAmount = q.totalPrice > 0 ? q.totalPrice : (q.unitPrice * q.quantity);
      quantity = q.quantity > 0 ? q.quantity : 1;
      supplierName = q.supplierName.isNotEmpty ? q.supplierName : 'Supplier #${q.supplierId}';
      supplierEmail = (q.supplierEmail.isNotEmpty) ? q.supplierEmail : 'supplier${q.supplierId}@scm.com';
      purchaseRequisitionId = q.purchaseRequisitionId;

      _amountController.text = totalAmount.toStringAsFixed(2);
      _supplierNameController.text = supplierName;
      _supplierEmailController.text = supplierEmail;
    });
  }

  Future<void> _pickDate() async {
    final initialDate = widget.orderToEdit != null && expectedDeliveryDate.isNotEmpty
        ? (DateTime.tryParse(expectedDeliveryDate) ?? DateTime.now().add(const Duration(days: 7)))
        : DateTime.now().add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        expectedDeliveryDate = picked.toIso8601String().split('T')[0];
        _dateController.text = expectedDeliveryDate;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      selectedQuotationId = null;
      totalAmount = 0.0;
      quantity = 1;
      supplierName = 'N/A';
      supplierEmail = 'N/A';
      purchaseRequisitionId = 0;
      expectedDeliveryDate = '';
      _amountController.clear();
      _supplierNameController.clear();
      _supplierEmailController.clear();
      _dateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final quotationsAsync = ref.watch(quotationListProvider);

    final isEdit = widget.orderToEdit != null;
    final String issuedByName = isEdit ? widget.orderToEdit!.issuedByName : (currentUser?.name ?? 'Procurement Officer');
    final int issuedBy = isEdit ? widget.orderToEdit!.issuedBy : (currentUser?.userId ?? 1);

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Header Bar (Fully Dynamic) ──
            DynamicScmTopNavBar(
              onRefresh: () {
                ref.invalidate(purchaseRequisitionListProvider);
                ref.invalidate(supplierListProvider);
              },
            ),

            // ── 2. Blue Banner Header Card with View All Button ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
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
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEdit ? 'Modify Purchase Order Details (${widget.orderToEdit!.poNumber})' : 'Compile Firm Purchase Order',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Text(
                            isEdit ? 'Update order attributes & delivery schedule parameters' : 'Create and dispatch firm purchase order for authorization',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/purchase-orders');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.list_alt, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'View All',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 3. Form Content Scrollable Area ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Target Approved Quotation Slip Dropdown
                      _buildNumberedStepLabel(1, 'TARGET APPROVED QUOTATION SLIP *'),
                      quotationsAsync.when(
                        data: (quotations) {
                          final approvedQuotations = isEdit
                              ? quotations.where((q) => q.status.toUpperCase() == 'APPROVED' || q.id == selectedQuotationId).toList()
                              : quotations.where((q) => q.status.toUpperCase() == 'APPROVED').toList();

                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderGrey),
                            ),
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedQuotationId,
                              isExpanded: true,
                              hint: const Text('-- Select Approved Bid Source --', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: approvedQuotations.map((q) {
                                final label = 'Quotation #Q-${q.quotationNumber.isNotEmpty ? q.quotationNumber : q.id} (Supplier: ${q.supplierName} - \$${q.totalPrice})';
                                return DropdownMenuItem<int>(
                                  value: q.id,
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final selectedQ = approvedQuotations.firstWhere((q) => q.id == val);
                                  _onQuotationSelected(selectedQ);
                                }
                              },
                            ),
                          );
                        },
                        loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                        error: (err, _) => Text('Error loading quotations: $err', style: const TextStyle(color: Colors.red, fontSize: 11)),
                      ),
                      const SizedBox(height: 16),

                      // Step 2: Financial Settlement Value ($)
                      _buildNumberedStepLabel(2, 'FINANCIAL SETTLEMENT VALUE (\$)'),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                        decoration: _inputDecoration(icon: Icons.attach_money).copyWith(hintText: 'Auto-calculated from selected quotation'),
                      ),
                      const SizedBox(height: 16),

                      // Step 3: Expected Delivery Date
                      _buildNumberedStepLabel(3, 'EXPECTED DELIVERY DATE *'),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: _inputDecoration(icon: Icons.calendar_today_outlined).copyWith(hintText: 'Select delivery date'),
                      ),
                      const SizedBox(height: 16),

                      // Step 4: System Base Currency
                      _buildNumberedStepLabel(4, 'SYSTEM BASE CURRENCY'),
                      TextFormField(
                        initialValue: 'USD (\$) Fixed SCM',
                        readOnly: true,
                        enabled: false,
                        decoration: _inputDecoration(icon: Icons.currency_exchange),
                      ),
                      const SizedBox(height: 20),

                      // Step 5: Supplier Name
                      _buildNumberedStepLabel(5, 'SUPPLIER NAME'),
                      TextFormField(
                        readOnly: true,
                        controller: _supplierNameController,
                        decoration: _metadataInputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Step 6: Supplier Email
                      _buildNumberedStepLabel(6, 'SUPPLIER EMAIL'),
                      TextFormField(
                        readOnly: true,
                        controller: _supplierEmailController,
                        decoration: _metadataInputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Step 7: Created At
                      _buildNumberedStepLabel(7, 'CREATED AT'),
                      TextFormField(
                        readOnly: true,
                        controller: _createdAtController,
                        decoration: _metadataInputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Step 8: Issued By
                      _buildNumberedStepLabel(8, 'ISSUED BY (USER NAME)'),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: issuedByName),
                        decoration: _metadataInputDecoration(),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons (Submit & Clear)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (selectedQuotationId == null || selectedQuotationId == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Validation Fault: Target Approved Quotation Slip is required.')),
                              );
                              return;
                            }

                            if (expectedDeliveryDate.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select an expected delivery date.')),
                              );
                              return;
                            }

                            final request = PurchaseOrderRequest(
                              quotationId: selectedQuotationId!,
                              issuedBy: issuedBy,
                              issuedByName: issuedByName,
                              totalAmount: totalAmount,
                              quantity: quantity,
                              currency: currency,
                              expectedDeliveryDate: expectedDeliveryDate,
                              status: isEdit ? widget.orderToEdit!.status : 'DRAFT',
                              supplierName: supplierName,
                              supplierEmail: supplierEmail,
                              purchaseRequisitionId: purchaseRequisitionId,
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);

                            bool success;
                            if (isEdit) {
                              success = await ref
                                  .read(purchaseOrderControllerProvider.notifier)
                                  .updatePurchaseOrder(widget.orderToEdit!.id, request);
                            } else {
                              success = await ref
                                  .read(purchaseOrderControllerProvider.notifier)
                                  .createPurchaseOrder(request);
                            }

                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(isEdit
                                      ? 'Purchase Order ${widget.orderToEdit!.poNumber} updated successfully!'
                                      : 'New Purchase Order created as DRAFT. Approval mail dispatched to manager.'),
                                  backgroundColor: const Color(0xFF16A34A),
                                ),
                              );
                              nav.pop();
                            }
                          },
                          icon: Icon(isEdit ? Icons.save_outlined : Icons.cloud_upload_outlined, size: 18),
                          label: Text(isEdit ? 'UPDATE PURCHASE ORDER' : 'DISPATCH FOR AUTHORIZATION'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEdit ? const Color(0xFF2563EB) : AppTheme.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resetForm,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.borderGrey),
                            foregroundColor: AppTheme.dark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildNumberedStepLabel(int stepNum, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }

  InputDecoration _metadataInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}