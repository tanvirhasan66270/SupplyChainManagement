import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scm_flutter/commercial_officer/provider/lc_bank_provider.dart';
import 'package:scm_flutter/commercial_officer/provider/letter_of_credit_provider.dart';
import 'package:scm_flutter/entity/letter_of_cradit_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class LetterOfCreditFormScreen extends ConsumerStatefulWidget {
  const LetterOfCreditFormScreen({
    super.key,
    this.lcToEdit,
    this.isAmendMode = false,
  });

  final LetterOfCreditResponseModel? lcToEdit;
  final bool isAmendMode;

  @override
  ConsumerState<LetterOfCreditFormScreen> createState() => _LetterOfCreditFormScreenState();
}

class _LetterOfCreditFormScreenState extends ConsumerState<LetterOfCreditFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int purchaseOrderId = 0;
  int supplierId = 0;
  int issuingBankId = 0;
  String shipmentIncoTerms = 'FOB';
  String portOfLoading = '';
  String portOfDischarge = '';
  double amount = 0.0;
  String latestShipmentDate = '';
  String expiryDate = '';
  String currency = 'USD';
  String lcStatus = 'DRAFT';

  File? selectedFile;
  final ImagePicker _picker = ImagePicker();
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lcToEdit != null) {
      final o = widget.lcToEdit!;
      purchaseOrderId = o.purchaseOrderId;
      supplierId = o.supplierId;
      issuingBankId = o.issuingBankId;
      shipmentIncoTerms = o.shipmentIncoTerms.isNotEmpty ? o.shipmentIncoTerms : 'FOB';
      portOfLoading = o.portOfLoading;
      portOfDischarge = o.portOfDischarge;
      amount = o.amount;
      latestShipmentDate = o.latestShipmentDate;
      expiryDate = o.expiryDate;
      currency = o.currency.isNotEmpty ? o.currency : 'USD';
      lcStatus = o.lcStatus.isNotEmpty ? o.lcStatus : 'OPENED';
    } else {
      latestShipmentDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30)));
      expiryDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 90)));
    }
  }

  Future<void> _pickFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isShipmentDate) async {
    final DateTime initial = isShipmentDate
        ? (DateTime.tryParse(latestShipmentDate) ?? DateTime.now().add(const Duration(days: 30)))
        : (DateTime.tryParse(expiryDate) ?? DateTime.now().add(const Duration(days: 90)));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        if (isShipmentDate) {
          latestShipmentDate = formatted;
        } else {
          expiryDate = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lcToEdit != null;
    final isAmend = widget.isAmendMode;

    final poAsync = ref.watch(purchaseOrderListProvider);
    final supplierAsync = ref.watch(supplierListProvider);
    final bankAsync = ref.watch(lcBankListProvider);

    final purchaseOrders = poAsync.value ?? [];
    final suppliers = supplierAsync.value ?? [];
    final banks = bankAsync.value ?? [];

    String headerTitle = 'Formulate Commercial LC';
    if (isAmend) {
      headerTitle = 'Official Trade Amendment (PATCH)';
    } else if (isEdit) {
      headerTitle = 'Update LC Configuration';
    }

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.dark, AppTheme.indigoDark, AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        headerTitle,
                        style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppTheme.white, size: 22),
                  ),
                ],
              ),
            ),

            // Error Banner
            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppTheme.danger.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Form Body - Step by Step Vertical Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAmend)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: AppTheme.warning, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Active Financial Amendment Bounds: Patching valuation amount and deadline dates.',
                                  style: TextStyle(fontSize: 11, color: AppTheme.indigoDark, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Step 1: Purchase Order Node
                      _buildStepLabel('1', 'TARGET CORPORATE PURCHASE ORDER *', Icons.description_outlined),
                      DropdownButtonFormField<int>(
                        initialValue: purchaseOrderId == 0 ? null : purchaseOrderId,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Select Firm Purchase Order Node --',
                          prefixIcon: const Icon(Icons.description_outlined, size: 18, color: AppTheme.primary),
                        ),
                        items: purchaseOrders.map((po) => DropdownMenuItem<int>(
                          value: po.id,
                          child: Text('PO #${po.poNumber.isNotEmpty ? po.poNumber : po.id} (৳${po.totalAmount})', style: const TextStyle(fontSize: 12)),
                        )).toList(),
                        onChanged: (isEdit || isAmend) ? null : (val) => setState(() => purchaseOrderId = val ?? 0),
                      ),
                      const SizedBox(height: 16),

                      // Step 2: Vendor Beneficiary
                      _buildStepLabel('2', 'CREDIT BENEFICIARY (SUPPLIER) *', Icons.person_outline),
                      DropdownButtonFormField<int>(
                        initialValue: supplierId == 0 ? null : supplierId,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Select Vendor Beneficiary --',
                          prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppTheme.primary),
                        ),
                        items: suppliers.map((s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.name, style: const TextStyle(fontSize: 12)),
                        )).toList(),
                        onChanged: (isEdit || isAmend) ? null : (val) => setState(() => supplierId = val ?? 0),
                      ),
                      const SizedBox(height: 16),

                      // Step 3: Issuing Financial Institution
                      _buildStepLabel('3', 'ISSUING FINANCIAL INSTITUTION (BANK) *', Icons.account_balance_outlined),
                      DropdownButtonFormField<int>(
                        initialValue: issuingBankId == 0 ? null : issuingBankId,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Select SWIFT Banking Terminal --',
                          prefixIcon: const Icon(Icons.account_balance_outlined, size: 18, color: AppTheme.primary),
                        ),
                        items: banks.map((b) => DropdownMenuItem<int>(
                          value: b.id,
                          child: Text('${b.name} (${b.swiftCode})', style: const TextStyle(fontSize: 12)),
                        )).toList(),
                        onChanged: isAmend ? null : (val) => setState(() => issuingBankId = val ?? 0),
                      ),
                      const SizedBox(height: 16),

                      // Step 4: Incoterms Framework
                      _buildStepLabel('4', 'INCOTERMS FRAMEWORK *', Icons.assignment_outlined),
                      DropdownButtonFormField<String>(
                        initialValue: shipmentIncoTerms,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Icon(Icons.assignment_outlined, size: 18, color: AppTheme.primary),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'FOB', child: Text('FOB - Free on Board', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'CIF', child: Text('CIF - Cost Insurance & Freight', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'EXW', child: Text('EXW - Ex Works', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'DDP', child: Text('DDP - Delivered Duty Paid', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: isAmend ? null : (val) => setState(() => shipmentIncoTerms = val ?? 'FOB'),
                      ),
                      const SizedBox(height: 16),

                      // Step 5: LC Operation State
                      _buildStepLabel('5', 'LC OPERATION STAGE *', Icons.flaky_outlined),
                      DropdownButtonFormField<String>(
                        initialValue: lcStatus,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Icon(Icons.flaky_outlined, size: 18, color: AppTheme.primary),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'OPENED', child: Text('OPENED', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'AMENDED', child: Text('AMENDED', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'EXPIRED', child: Text('EXPIRED', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: isAmend ? null : (val) => setState(() => lcStatus = val ?? 'DRAFT'),
                      ),
                      const SizedBox(height: 16),

                      // Step 6: Port of Loading
                      _buildStepLabel('6', 'PORT OF LOADING *', Icons.anchor),
                      TextFormField(
                        initialValue: portOfLoading,
                        enabled: !isAmend,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. Shanghai Port',
                          prefixIcon: const Icon(Icons.anchor, size: 18, color: AppTheme.primary),
                        ),
                        onChanged: (val) => portOfLoading = val,
                      ),
                      const SizedBox(height: 16),

                      // Step 7: Port of Discharge
                      _buildStepLabel('7', 'PORT OF DISCHARGE *', Icons.anchor_outlined),
                      TextFormField(
                        initialValue: portOfDischarge,
                        enabled: !isAmend,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. Chattogram Port (CTG)',
                          prefixIcon: const Icon(Icons.anchor_outlined, size: 18, color: AppTheme.primary),
                        ),
                        onChanged: (val) => portOfDischarge = val,
                      ),
                      const SizedBox(height: 16),

                      // Step 8: Total Credit Valuation
                      _buildStepLabel('8', 'TOTAL CREDIT VALUATION (\$ AMOUNT) *', Icons.monetization_on_outlined),
                      TextFormField(
                        initialValue: amount == 0.0 ? '' : amount.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Enter total credit valuation amount',
                          prefixIcon: const Icon(Icons.attach_money, color: AppTheme.success, size: 20),
                        ),
                        onChanged: (val) => amount = double.tryParse(val) ?? 0.0,
                      ),
                      const SizedBox(height: 16),

                      // Step 9: Currency
                      _buildStepLabel('9', 'INSTRUMENT CURRENCY *', Icons.currency_exchange),
                      DropdownButtonFormField<String>(
                        initialValue: currency,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Icon(Icons.currency_exchange, size: 18, color: AppTheme.primary),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD (\$ United States Dollar)', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'BDT', child: Text('BDT (৳ Bangladeshi Taka)', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: isAmend ? null : (val) => setState(() => currency = val ?? 'USD'),
                      ),
                      const SizedBox(height: 16),

                      // Step 10: Latest Shipment Date
                      _buildStepLabel('10', 'LATEST SHIPMENT DATE *', Icons.calendar_month),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  latestShipmentDate.isNotEmpty ? latestShipmentDate : 'Select Latest Shipment Date',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppTheme.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 11: LC Expiry Deadline
                      _buildStepLabel('11', 'LC EXPIRY DEADLINE *', Icons.event_busy),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_busy, size: 16, color: AppTheme.danger),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  expiryDate.isNotEmpty ? expiryDate : 'Select Expiry Date',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.danger),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppTheme.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 12: Official SWIFT Document File Copy
                      if (!isAmend) ...[
                        _buildStepLabel('12', 'OFFICIAL SWIFT LETTER DOCUMENT COPY', Icons.attach_file),
                        InkWell(
                          onTap: _pickFile,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderGrey),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 20, color: AppTheme.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedFile != null
                                        ? selectedFile!.path.split('/').last
                                        : (isEdit && widget.lcToEdit != null && widget.lcToEdit!.documentVaultUrl.isNotEmpty
                                            ? 'Existing File Attached'
                                            : 'Attach SWIFT document image or PDF'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.add_a_photo, size: 18, color: AppTheme.grey),
                              ],
                            ),
                          ),
                        ),
                        if (selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(selectedFile!, height: 120, width: double.infinity, fit: BoxFit.cover),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() => errorMessage = null);

                                  if (purchaseOrderId == 0 || supplierId == 0 || issuingBankId == 0 || amount <= 0) {
                                    setState(() {
                                      errorMessage = "Validation Fault: Please select valid Purchase Order, Supplier, Issuing Bank, and enter amount > 0.";
                                    });
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  final req = LetterOfCreditRequestModel(
                                    purchaseOrderId: purchaseOrderId,
                                    supplierId: supplierId,
                                    issuingBankId: issuingBankId,
                                    shipmentIncoTerms: shipmentIncoTerms,
                                    portOfLoading: portOfLoading.isNotEmpty ? portOfLoading : 'Shanghai Port',
                                    portOfDischarge: portOfDischarge.isNotEmpty ? portOfDischarge : 'Chattogram Port',
                                    amount: amount,
                                    latestShipmentDate: latestShipmentDate,
                                    expiryDate: expiryDate,
                                    currency: currency,
                                    lcStatus: lcStatus,
                                    documentVaultUrl: widget.lcToEdit?.documentVaultUrl ?? '',
                                  );

                                  bool ok = false;
                                  if (isAmend && widget.lcToEdit != null) {
                                    final patchData = {
                                      'amount': amount,
                                      'latestShipmentDate': latestShipmentDate,
                                      'expiryDate': expiryDate,
                                    };
                                    ok = await ref.read(letterOfCreditControllerProvider.notifier).amendLC(widget.lcToEdit!.id, patchData);
                                  } else if (isEdit && widget.lcToEdit != null) {
                                    ok = await ref.read(letterOfCreditControllerProvider.notifier).updateLC(widget.lcToEdit!.id, req, selectedFile);
                                  } else {
                                    ok = await ref.read(letterOfCreditControllerProvider.notifier).saveLC(req, selectedFile);
                                  }

                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                    if (ok) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isAmend ? 'Commercial Amendment deployed!' : (isEdit ? 'LC updated!' : 'Letter of Credit opened successfully!')),
                                          backgroundColor: AppTheme.success,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      setState(() => errorMessage = 'Operation failed. Please check mandatory parameters.');
                                    }
                                  }
                                },
                          icon: isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white))
                              : Icon(isAmend ? Icons.build_circle_outlined : (isEdit ? Icons.edit : Icons.verified), size: 18),
                          label: Text(
                            isAmend ? 'DEPLOY LEGAL PATCH' : (isEdit ? 'COMMIT METADATA' : 'OPEN CREDIT NODE'),
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAmend ? AppTheme.warning : (isEdit ? AppTheme.primary : AppTheme.success),
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: AppTheme.borderGrey),
                          ),
                          child: const Text('CANCEL', style: TextStyle(color: AppTheme.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildStepLabel(String stepNumber, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Step $stepNumber',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}