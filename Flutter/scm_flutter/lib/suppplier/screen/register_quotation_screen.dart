import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/suppplier/provider/quotation_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class RegisterQuotationScreen extends ConsumerStatefulWidget {
  final QuotationResponseModel? quotationToEdit;

  const RegisterQuotationScreen({super.key, this.quotationToEdit});

  @override
  ConsumerState<RegisterQuotationScreen> createState() => _RegisterQuotationScreenState();
}

class _RegisterQuotationScreenState extends ConsumerState<RegisterQuotationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int purchaseRequisitionId = 0;
  int supplierId = 0;
  double unitPrice = 0.0;
  int quantity = 1;
  int leadTimeDays = 1;
  String status = 'PENDING';
  String receivedAt = '';
  String deliveryTime = '';
  String warranty = '';
  String productDescription = '';
  String notes = '';
  File? selectedFile;

  String? errorMessage;
  bool isEdit = false;
  int? currentEditId;

  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _leadTimeController = TextEditingController();
  final TextEditingController _receivedAtController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final deliveryDefault = DateTime.now().add(const Duration(days: 10)).toIso8601String().split('T')[0];

    receivedAt = today;
    deliveryTime = deliveryDefault;

    _receivedAtController.text = today;
    _deliveryTimeController.text = deliveryDefault;
    _unitPriceController.text = '0.00';
    _quantityController.text = '1';
    _leadTimeController.text = '1';

    if (widget.quotationToEdit != null) {
      final o = widget.quotationToEdit!;
      isEdit = true;
      currentEditId = o.id;
      purchaseRequisitionId = o.purchaseRequisitionId;
      supplierId = o.supplierId;
      unitPrice = o.unitPrice;
      quantity = o.quantity;
      leadTimeDays = o.leadTimeDays;
      status = o.status;
      receivedAt = o.receivedAt;
      deliveryTime = o.deliveryTime;
      warranty = o.warranty;
      productDescription = o.productDescription;
      notes = o.notes;

      _unitPriceController.text = o.unitPrice.toString();
      _quantityController.text = o.quantity.toString();
      _leadTimeController.text = o.leadTimeDays.toString();
      _receivedAtController.text = o.receivedAt;
      _deliveryTimeController.text = o.deliveryTime;
      _warrantyController.text = o.warranty;
      _descriptionController.text = o.productDescription;
      _notesController.text = o.notes;
    }
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    _quantityController.dispose();
    _leadTimeController.dispose();
    _receivedAtController.dispose();
    _deliveryTimeController.dispose();
    _warrantyController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
      });
    }
  }

  int _getLinkedRequisitionQty(List<PurchaseRequisitionResponse> requisitions) {
    if (purchaseRequisitionId == 0) return 0;
    final req = requisitions.where((r) => r.id == purchaseRequisitionId).firstOrNull;
    if (req == null) return 0;
    final productCount = req.productIds.isNotEmpty ? req.productIds.length : 1;
    return req.quantityRequired * productCount;
  }

  bool _isQuantityValid(List<PurchaseRequisitionResponse> requisitions) {
    if (purchaseRequisitionId == 0) return true;
    final reqQty = _getLinkedRequisitionQty(requisitions);
    if (reqQty == 0) return true;
    return quantity <= reqQty;
  }

  void _onRequisitionSelect(int reqId, List<PurchaseRequisitionResponse> requisitions) {
    setState(() {
      purchaseRequisitionId = reqId;
      if (reqId > 0) {
        final selectedReq = requisitions.where((r) => r.id == reqId).firstOrNull;
        if (selectedReq != null && selectedReq.createdAt.isNotEmpty) {
          receivedAt = selectedReq.createdAt.split('T')[0];
          _receivedAtController.text = receivedAt;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final supplierListAsync = ref.watch(supplierListProvider);
    final requisitionListAsync = ref.watch(purchaseRequisitionListProvider);
    final quotationControllerState = ref.watch(quotationControllerProvider);

    final userRole = (currentUser?.role ?? 'SUPPLIER').toUpperCase();
    final isSupplierRole = userRole == 'SUPPLIER';

    final suppliers = supplierListAsync.value ?? [];
    final requisitions = requisitionListAsync.value ?? [];

    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;
    final currentSupplierId = currentSupplier?.id ?? (suppliers.isNotEmpty ? suppliers.first.id : 1);
    final currentSupplierName = currentSupplier?.name ?? currentUser?.name ?? 'Your Supplier Account';

    if (isSupplierRole && supplierId == 0) {
      supplierId = currentSupplierId;
    }

    final maxAllowedQty = _getLinkedRequisitionQty(requisitions);
    final quantityValid = _isQuantityValid(requisitions);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Bar Design (Fully Dynamic) ──
            DynamicScmTopNavBar(
              title: isEdit ? 'Modify Quotation' : 'Register Quotation',
              showBackButton: true,
              onRefresh: () {
                ref.invalidate(purchaseRequisitionListProvider);
                ref.invalidate(productListProvider);
              },
            ),

            // ── 2. Error Banner ──
            if (errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppTheme.dangerLight,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── 3. Scrollable Form Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: LINKED PURCHASE REQUISITION VECTOR
                      _buildNumberedStepLabel(1, 'LINKED PURCHASE REQUISITION VECTOR *'),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: purchaseRequisitionId == 0 ? null : purchaseRequisitionId,
                        hint: const Text('-- Select Linked Requisition Node --', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
                        decoration: _inputDecoration(),
                        items: requisitions.map((req) {
                          return DropdownMenuItem<int>(
                            value: req.id,
                            child: Text(
                              'PR #${req.id} (${req.productNames.join(', ')}) - Req Date: ${req.requiredByDate}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: isEdit ? null : (val) => _onRequisitionSelect(val ?? 0, requisitions),
                      ),
                      const SizedBox(height: 14),

                      // Step 2: TARGET VENDOR NODE
                      _buildNumberedStepLabel(2, 'TARGET VENDOR NODE *'),
                      if (isSupplierRole)
                        TextFormField(
                          readOnly: true,
                          initialValue: '$currentSupplierName (Your Supplier Account)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          decoration: _inputDecoration(),
                        )
                      else
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: supplierId == 0 ? null : supplierId,
                          hint: const Text('-- Select Supplier Entity --', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
                          decoration: _inputDecoration(),
                          items: suppliers.map((sup) {
                            return DropdownMenuItem<int>(
                              value: sup.id,
                              child: Text(
                                '${sup.name} (${sup.contactPerson})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: isEdit ? null : (val) => setState(() => supplierId = val ?? 0),
                        ),
                      const SizedBox(height: 14),

                      // Step 3: UNIT BID COST ($)
                      _buildNumberedStepLabel(3, 'UNIT BID COST (\$) *'),
                      TextFormField(
                        controller: _unitPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        decoration: _inputDecoration().copyWith(prefixText: '\$ '),
                        onChanged: (val) => unitPrice = double.tryParse(val) ?? 0.0,
                      ),
                      const SizedBox(height: 14),

                      // Step 4: SUPPLY VOLUME (QTY)
                      _buildNumberedStepLabel(4, 'SUPPLY VOLUME (QTY) *'),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: !quantityValid ? Colors.red : Colors.black87,
                        ),
                        decoration: _inputDecoration().copyWith(
                          suffixText: 'Pcs',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: !quantityValid ? Colors.red : AppTheme.borderGrey),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            quantity = int.tryParse(val) ?? 1;
                          });
                        },
                      ),
                      if (!quantityValid) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⚠️ Quantity limit exceeded! Max allowed volume for linked PR is $maxAllowedQty Pcs.',
                          style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Step 5: LEAD TIME (DAYS)
                      _buildNumberedStepLabel(5, 'LEAD TIME (DAYS) *'),
                      TextFormField(
                        controller: _leadTimeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: _inputDecoration().copyWith(suffixText: 'Days'),
                        onChanged: (val) => leadTimeDays = int.tryParse(val) ?? 1,
                      ),
                      const SizedBox(height: 14),

                      // Step 6: AUDITING STATE
                      _buildNumberedStepLabel(6, 'AUDITING STATE *'),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: _inputDecoration(),
                        items: ['PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'EXPIRED']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))))
                            .toList(),
                        onChanged: isSupplierRole ? null : (val) => setState(() => status = val ?? 'PENDING'),
                      ),
                      const SizedBox(height: 14),

                      // Step 7: REQUISITION RECEIVED DATE
                      _buildNumberedStepLabel(7, 'REQUISITION RECEIVED DATE'),
                      TextFormField(
                        controller: _receivedAtController,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        decoration: _inputDecoration().copyWith(
                          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.secondary),
                        ),
                        onChanged: (val) => receivedAt = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 8: ESTIMATED DELIVERY DATE
                      _buildNumberedStepLabel(8, 'ESTIMATED DELIVERY DATE'),
                      TextFormField(
                        controller: _deliveryTimeController,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        decoration: _inputDecoration().copyWith(
                          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.secondary),
                        ),
                        onChanged: (val) => deliveryTime = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 9: WARRANTY COVERAGE MATRIX
                      _buildNumberedStepLabel(9, 'WARRANTY COVERAGE MATRIX'),
                      TextFormField(
                        controller: _warrantyController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration().copyWith(hintText: 'e.g. 3 Years Operational Warranty'),
                        onChanged: (val) => warranty = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 10: ATTACHMENT DOCUMENT ENVELOPE
                      _buildNumberedStepLabel(10, 'ATTACHMENT DOCUMENT ENVELOPE'),
                      InkWell(
                        onTap: _pickAttachment,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.attach_file, size: 14, color: Color(0xFF2563EB)),
                                    SizedBox(width: 4),
                                    Text('Choose File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedFile != null ? selectedFile!.path.split('/').last : (widget.quotationToEdit?.attachmentUrl ?? 'No file chosen'),
                                  style: TextStyle(fontSize: 11, color: selectedFile != null ? Colors.black87 : AppTheme.secondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Step 11: PRODUCT NOMENCLATURE SPECIFICATIONS
                      _buildNumberedStepLabel(11, 'PRODUCT NOMENCLATURE SPECIFICATIONS'),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration().copyWith(hintText: 'Detailed technical description or material specs...'),
                        onChanged: (val) => productDescription = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 12: SOURCING OPERATIONS NOTES
                      _buildNumberedStepLabel(12, 'SOURCING OPERATIONS NOTES'),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration().copyWith(hintText: 'Additional terms, payment conditions, notes...'),
                        onChanged: (val) => notes = val,
                      ),
                      const SizedBox(height: 24),

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: (quotationControllerState.isLoading || !quantityValid)
                              ? null
                              : () async {
                                  setState(() => errorMessage = null);

                                  if (purchaseRequisitionId == 0) {
                                    setState(() => errorMessage = 'Validation Fault: Linked Purchase Requisition node mapping is mandatory.');
                                    return;
                                  }

                                  if (supplierId == 0) {
                                    setState(() => errorMessage = 'Validation Fault: Target Supplier mapping is mandatory.');
                                    return;
                                  }

                                  if (!quantityValid) {
                                    setState(() => errorMessage = 'Validation Fault: Quantity limit exceeded for linked PR.');
                                    return;
                                  }

                                  if (isEdit && currentEditId != null) {
                                    if (widget.quotationToEdit?.status == 'APPROVED' || widget.quotationToEdit?.status == 'UNDER_REVIEW') {
                                      setState(() => errorMessage = 'Access Denied: Cannot modify a quotation that is APPROVED or UNDER_REVIEW.');
                                      return;
                                    }
                                  }

                                  final req = QuotationRequestModel(
                                    supplierId: supplierId,
                                    purchaseRequisitionId: purchaseRequisitionId,
                                    leadTimeDays: leadTimeDays,
                                    receivedAt: receivedAt,
                                    status: status,
                                    productDescription: productDescription,
                                    unitPrice: unitPrice,
                                    quantity: quantity,
                                    deliveryTime: deliveryTime,
                                    warranty: warranty,
                                    notes: notes,
                                  );

                                  bool success = false;
                                  if (isEdit && currentEditId != null) {
                                    success = await ref.read(quotationControllerProvider.notifier).updateQuotation(currentEditId!, req);
                                  } else {
                                    success = await ref.read(quotationControllerProvider.notifier).createQuotation(req, selectedFile);
                                  }

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isEdit ? 'Quotation document node updated successfully.' : 'Quotation document node synchronized successfully.'),
                                        backgroundColor: const Color(0xFF16A34A),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                          icon: quotationControllerState.isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: Text(
                            isEdit ? 'COMMIT BID MUTATIONS' : 'PUBLISH QUOTATION ENVELOPE',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
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
      padding: const EdgeInsets.only(bottom: 5),
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
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary, letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
    );
  }
}