import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/entity/qc_inspaction_model.dart';
import 'package:scm_flutter/logistics_officer/provider/good_received_note_provider.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspection_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class QCInspectionFormScreen extends ConsumerStatefulWidget {
  const QCInspectionFormScreen({super.key, this.inspectionToEdit});

  final QCInspectionResponseModel? inspectionToEdit;

  @override
  ConsumerState<QCInspectionFormScreen> createState() => _QCInspectionFormScreenState();
}

class _QCInspectionFormScreenState extends ConsumerState<QCInspectionFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int grnId = 0;
  int productId = 0;
  String inspectionType = 'VISUAL';
  int inspectedBy = 0;
  int sampleSize = 5;
  int defectsFound = 0;
  String defectDescription = '';
  String result = 'GOOD';
  String certificateRef = '';
  String inspectedAt = DateTime.now().toIso8601String().split('T')[0];
  List<QCChecklistRequestModel> checklists = [];

  File? selectedFile;
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    inspectedBy = currentUser?.userId ?? 0;

    if (widget.inspectionToEdit != null) {
      final o = widget.inspectionToEdit!;
      grnId = o.grnId;
      productId = o.productId;
      inspectionType = o.inspectionType;
      inspectedBy = o.inspectedBy;
      sampleSize = o.sampleSize;
      defectsFound = o.defectsFound;
      defectDescription = o.defectDescription;
      result = o.result;
      certificateRef = o.certificateRef;
      inspectedAt = o.inspectedAt;
      checklists = o.checklists.map((c) => QCChecklistRequestModel(
        inspectionId: c.inspectionId,
        checkpointName: c.checkpointName,
        isPassed: c.isPassed,
        remarks: c.remarks,
      )).toList();
    }
  }

  Future<void> _pickFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedFileName = image.name;
        selectedFileBytes = bytes;
        if (!kIsWeb) {
          selectedFile = File(image.path);
        }
      });
    }
  }

  // Filtering products based on Angular component getFilteredProducts() & fallbackGrnFilter()
  List<ProductResponseModel> _getFilteredProducts(
    List<ProductResponseModel> products,
    List<GoodsReceivedNoteResponseModel> grns,
    List<PurchaseOrderResponse> pos,
    List<PurchaseRequisitionResponse> prs,
  ) {
    if (grnId == 0) return products;

    final selectedGrn = grns.firstWhereOrNull((g) => g.id == grnId);
    if (selectedGrn == null) return products;

    final selectedPo = pos.firstWhereOrNull(
      (po) => po.id == selectedGrn.poId || (selectedGrn.poNumber.isNotEmpty && po.poNumber == selectedGrn.poNumber),
    );

    if (selectedPo != null) {
      final selectedPr = prs.firstWhereOrNull((pr) => pr.id == selectedPo.purchaseRequisitionId);
      if (selectedPr != null && selectedPr.productIds.isNotEmpty) {
        final prProductIds = selectedPr.productIds.toSet();
        final filtered = products.where((p) => prProductIds.contains(p.id)).toList();
        if (filtered.isNotEmpty) return filtered;
      }
    }

    // Fallback GRN Filter
    final grnProductIds = <int>{};
    if (selectedGrn.productId > 0) grnProductIds.add(selectedGrn.productId);
    if (selectedGrn.lineItems != null) {
      for (final item in selectedGrn.lineItems!) {
        if (item.productId > 0) grnProductIds.add(item.productId);
      }
    }

    if (grnProductIds.isEmpty) return products;
    final fallbackFiltered = products.where((p) => grnProductIds.contains(p.id)).toList();
    return fallbackFiltered.isNotEmpty ? fallbackFiltered : products;
  }

  void _onGrnChange(
    int newGrnId,
    List<ProductResponseModel> products,
    List<GoodsReceivedNoteResponseModel> grns,
    List<PurchaseOrderResponse> pos,
    List<PurchaseRequisitionResponse> prs,
  ) {
    grnId = newGrnId;
    final filtered = _getFilteredProducts(products, grns, pos, prs);
    final stillValid = filtered.any((p) => p.id == productId);
    if (!stillValid) {
      productId = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.inspectionToEdit != null;
    final grnsAsync = ref.watch(goodReceivedNoteListProvider);
    final productsAsync = ref.watch(productListProvider);
    final posAsync = ref.watch(purchaseOrderListProvider);
    final prsAsync = ref.watch(purchaseRequisitionListProvider);
    final currentUser = ref.watch(currentUserProvider);

    final grns = grnsAsync.value ?? [];
    final products = productsAsync.value ?? [];
    final pos = posAsync.value ?? [];
    final prs = prsAsync.value ?? [];

    final filteredProducts = _getFilteredProducts(products, grns, pos, prs);
    final inspectorDisplayName = currentUser != null
        ? '${currentUser.name} (QC Inspector)'
        : 'Not Assigned';

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ১. Top Teal Gradient Header Banner (Using AppTheme palette)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.tealDark, AppTheme.tealPrimary, AppTheme.tealLight],
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
                        child: const Icon(Icons.arrow_back, color: AppTheme.surfaceWhite, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Authorize Quality Matrix',
                            style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ensure target QC audit before outbound cargo batch',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppTheme.surfaceWhite, size: 22),
                  ),
                ],
              ),
            ),

            // ২. Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Assigning Cargo Node Vector (GRN Link)
                      _buildNumberedLabel(1, 'ASSIGNING CARGO NODE VECTOR (GRN LINK) *', Icons.link),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: grnId == 0 ? null : grnId,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Select Internal GRN Code Reference --',
                        ),
                        items: grns.map((g) => DropdownMenuItem<int>(
                          value: g.id,
                          child: Text('GRN: ${g.grnNumber} (PO: ${g.poNumber})', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: isEdit
                            ? null
                            : (val) {
                                if (val != null) {
                                  _onGrnChange(val, products, grns, pos, prs);
                                }
                              },
                      ),
                      const SizedBox(height: 16),

                      // Step 2: Target Consignment Product
                      _buildNumberedLabel(2, 'TARGET CONSIGNMENT PRODUCT *', Icons.inventory_2_outlined),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: (productId != 0 && filteredProducts.any((p) => p.id == productId)) ? productId : null,
                        decoration: _inputDecoration().copyWith(
                          hintText: '-- Select Core Target Product --',
                        ),
                        items: filteredProducts.map((p) => DropdownMenuItem<int>(
                          value: p.id,
                          child: Text(p.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: isEdit ? null : (val) => setState(() => productId = val ?? 0),
                      ),
                      const SizedBox(height: 16),

                      // Step 3: Inspection Topology
                      _buildNumberedLabel(3, 'INSPECTION TOPOLOGY *', Icons.filter_alt_outlined),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: inspectionType,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'VISUAL', child: Text('VISUAL EXAMINATION', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'LAB_TEST', child: Text('CHEMICAL LAB TEST', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'FUNCTIONAL', child: Text('FUNCTIONAL AUDIT', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'DIMENSIONAL', child: Text('DIMENSIONAL METRIC', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) => setState(() => inspectionType = val ?? 'VISUAL'),
                      ),
                      const SizedBox(height: 16),

                      // Step 4: Sample Pool Volume Size
                      _buildNumberedLabel(4, 'SAMPLE POOL VOLUME SIZE *', Icons.bar_chart),
                      TextFormField(
                        initialValue: sampleSize.toString(),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Text('123', style: TextStyle(color: AppTheme.tealPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        onChanged: (val) => sampleSize = int.tryParse(val) ?? 5,
                      ),
                      const SizedBox(height: 16),

                      // Step 5: Audit Authority Execution Date
                      _buildNumberedLabel(5, 'AUDIT AUTHORITY EXECUTION DATE *', Icons.calendar_today),
                      TextFormField(
                        initialValue: inspectedAt,
                        decoration: _inputDecoration().copyWith(
                          suffixIcon: const Icon(Icons.calendar_month_outlined, size: 18, color: AppTheme.secondary),
                        ),
                        onChanged: (val) => inspectedAt = val,
                      ),
                      const SizedBox(height: 16),

                      // Step 6: Audit Evaluation Grade
                      _buildNumberedLabel(6, 'AUDIT EVALUATION GRADE *', Icons.workspace_premium_outlined),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: result,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'VERY_GOOD', child: Text('🌟 VERY GOOD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'GOOD', child: Text('✅ GOOD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'AVERAGE', child: Text('⚠️ AVERAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.warning), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'BAD', child: Text('❌ BAD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.danger), overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) => setState(() => result = val ?? 'GOOD'),
                      ),
                      const SizedBox(height: 16),

                      // Step 7: Total Defectives Identified
                      _buildNumberedLabel(7, 'TOTAL DEFECTIVES IDENTIFIED *', Icons.cancel_outlined),
                      TextFormField(
                        initialValue: defectsFound.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
                        decoration: _inputDecoration(),
                        onChanged: (val) => defectsFound = int.tryParse(val) ?? 0,
                      ),
                      const SizedBox(height: 16),

                      // Step 8: Certificate Reference Stamp
                      _buildNumberedLabel(8, 'CERTIFICATE REFERENCE STAMP', Icons.verified_outlined),
                      TextFormField(
                        initialValue: certificateRef,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. ISO-QC-99221',
                          prefixIcon: const Icon(Icons.local_offer_outlined, size: 18, color: AppTheme.secondary),
                        ),
                        onChanged: (val) => certificateRef = val,
                      ),
                      const SizedBox(height: 16),

                      // Step 9: Inspector Controller Assigned (Read-only as in Angular template)
                      _buildNumberedLabel(9, 'INSPECTOR CONTROLLER ASSIGNED', Icons.person_outline),
                      TextFormField(
                        initialValue: inspectorDisplayName,
                        readOnly: true,
                        decoration: _inputDecoration().copyWith(
                          fillColor: AppTheme.light,
                          prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: AppTheme.tealPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 10: Defect Layer Narrative Description
                      _buildNumberedLabel(10, 'DEFECT LAYER NARRATIVE DESCRIPTION *', Icons.chat_bubble_outline),
                      TextFormField(
                        initialValue: defectDescription,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Provide detailed specifications of flaws discovered during batch audit...',
                          contentPadding: const EdgeInsets.all(12),
                          counterText: '',
                        ),
                        onChanged: (val) => defectDescription = val,
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text('0/500', style: TextStyle(fontSize: 9, color: AppTheme.secondary)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 11: Target QC Checkpoint Metrics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNumberedLabel(11, 'TARGET QC CHECKPOINT METRICS', Icons.list_alt),
                          OutlinedButton.icon(
                            onPressed: () => setState(() {
                              checklists.add(QCChecklistRequestModel(
                                checkpointName: '',
                                isPassed: true,
                                remarks: '',
                              ));
                            }),
                            icon: const Icon(Icons.add, size: 14, color: AppTheme.tealPrimary),
                            label: const Text('Add Checkpoint', style: TextStyle(fontSize: 11, color: AppTheme.tealPrimary, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.tealPrimary),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (checklists.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderGrey, style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.assignment_turned_in_outlined, color: AppTheme.tealPrimary, size: 28),
                              SizedBox(height: 6),
                              Text('No specific child checklist checkpoints deployed yet.', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                            ],
                          ),
                        )
                      else
                        ...checklists.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final chk = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppTheme.surfaceWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderGrey)),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Autocomplete<String>(
                                    initialValue: TextEditingValue(text: chk.checkpointName),
                                    optionsBuilder: (TextEditingValue textEditingValue) {
                                      final productNames = filteredProducts.map((p) => p.name).toList();
                                      if (productNames.isEmpty) return const Iterable<String>.empty();
                                      if (textEditingValue.text.isEmpty) {
                                        return productNames;
                                      }
                                      return productNames.where((name) =>
                                        name.toLowerCase().contains(textEditingValue.text.toLowerCase())
                                      );
                                    },
                                    onSelected: (String selection) {
                                      setState(() {
                                        checklists[idx] = QCChecklistRequestModel(
                                          inspectionId: chk.inspectionId,
                                          checkpointName: selection,
                                          isPassed: chk.isPassed,
                                          remarks: chk.remarks,
                                        );
                                      });
                                    },
                                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                      return TextFormField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        onEditingComplete: onEditingComplete,
                                        decoration: _inputDecoration().copyWith(
                                          hintText: 'Checkpoint Label (e.g. Density Check)',
                                          suffixIcon: const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.tealPrimary),
                                        ),
                                        onChanged: (val) {
                                          checklists[idx] = QCChecklistRequestModel(
                                            inspectionId: chk.inspectionId,
                                            checkpointName: val,
                                            isPassed: chk.isPassed,
                                            remarks: chk.remarks,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: DropdownButtonFormField<bool>(
                                    initialValue: chk.isPassed,
                                    decoration: _inputDecoration(),
                                    items: const [
                                      DropdownMenuItem(value: true, child: Text('✔ PASS', style: TextStyle(fontSize: 10, color: AppTheme.success))),
                                      DropdownMenuItem(value: false, child: Text('❌ FAIL', style: TextStyle(fontSize: 10, color: AppTheme.danger))),
                                    ],
                                    onChanged: (val) => setState(() => checklists[idx] = QCChecklistRequestModel(
                                      inspectionId: chk.inspectionId,
                                      checkpointName: chk.checkpointName,
                                      isPassed: val ?? true,
                                      remarks: chk.remarks,
                                    )),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: AppTheme.danger, size: 20),
                                  onPressed: () => setState(() => checklists.removeAt(idx)),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 16),

                      // Step 12: Chemical Lab Swift Telemetry Report Copy
                      _buildNumberedLabel(12, 'CHEMICAL LAB SWIFT TELEMETRY REPORT COPY *', Icons.description_outlined),
                      InkWell(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: (selectedFileBytes != null || selectedFile != null) ? AppTheme.tealPrimary : AppTheme.borderGrey),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, size: 18, color: AppTheme.tealPrimary),
                              const SizedBox(width: 8),
                              const Text('Choose File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.tealPrimary)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFileName ?? selectedFile?.path.split(RegExp(r'[/\\]')).last ?? 'No file chosen',
                                  style: TextStyle(fontSize: 12, color: (selectedFileBytes != null || selectedFile != null) ? AppTheme.dark : AppTheme.secondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selectedFileBytes != null || selectedFile != null)
                                const Icon(Icons.check_circle, color: AppTheme.tealPrimary, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Upload verified chemical composition map or spectroscopic scan logs.',
                        style: TextStyle(fontSize: 9, color: AppTheme.secondary),
                      ),
                      if (selectedFileBytes != null || (selectedFile != null && !kIsWeb)) ...[
                        const SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.tealPrimary, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: selectedFileBytes != null
                                  ? Image.memory(selectedFileBytes!, fit: BoxFit.contain)
                                  : Image.file(selectedFile!, fit: BoxFit.contain),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => setState(() {
                                  selectedFile = null;
                                  selectedFileBytes = null;
                                  selectedFileName = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: AppTheme.surfaceWhite, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Footer Action Buttons (Authorize & Broadcast Matrix & Cancel)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (grnId == 0 || productId == 0 || inspectedBy == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Validation Fault: Linked GRN Code, Target Product, and Inspector are mandatory.'),
                                      backgroundColor: AppTheme.danger,
                                    ),
                                  );
                                  return;
                                }

                                if (inspectedAt.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Validation Fault: Inspection Execution Date is mandatory.'),
                                      backgroundColor: AppTheme.danger,
                                    ),
                                  );
                                  return;
                                }

                                final processedChecklists = checklists.map((c) => QCChecklistRequestModel(
                                  inspectionId: c.inspectionId,
                                  checkpointName: c.checkpointName.trim().isEmpty ? 'General Checkpoint' : c.checkpointName.trim(),
                                  isPassed: c.isPassed,
                                  remarks: c.remarks.trim(),
                                )).toList();

                                final request = QCInspectionRequestModel(
                                  id: widget.inspectionToEdit?.id,
                                  grnId: grnId,
                                  productId: productId,
                                  inspectionType: inspectionType,
                                  inspectedBy: inspectedBy,
                                  sampleSize: sampleSize,
                                  defectsFound: defectsFound,
                                  defectDescription: defectDescription.trim(),
                                  result: result.toUpperCase(),
                                  certificateRef: certificateRef.trim(),
                                  labTestReport: widget.inspectionToEdit?.labTestReport ?? '',
                                  inspectedAt: inspectedAt,
                                  checklists: processedChecklists,
                                );

                                bool success = false;
                                if (isEdit && widget.inspectionToEdit != null) {
                                  success = await ref
                                      .read(qcInspectionControllerProvider.notifier)
                                      .updateInspection(widget.inspectionToEdit!.id, request, selectedFile);
                                } else {
                                  success = await ref
                                      .read(qcInspectionControllerProvider.notifier)
                                      .saveInspection(request, selectedFile);
                                }

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Quality Control Audit authorized successfully!'), backgroundColor: AppTheme.success),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.cloud_upload, size: 18),
                              label: Text(isEdit ? 'COMMIT AUDIT CHANGES' : 'AUTHORIZE & BROADCAST MATRIX'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.tealPrimary,
                                foregroundColor: AppTheme.surfaceWhite,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: AppTheme.dark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
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

  Widget _buildNumberedLabel(int stepNum, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: AppTheme.tealBackground, shape: BoxShape.circle),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.tealPrimary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: AppTheme.tealPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.tealPrimary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}