import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/product_requirement.dart';
import 'package:scm_flutter/logistics_officer/provider/product_requirement_provider.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class ProductRequirementFormScreen extends ConsumerStatefulWidget {
  const ProductRequirementFormScreen({super.key, this.requirementToEdit});

  final ProductRequirementResponse? requirementToEdit;

  @override
  ConsumerState<ProductRequirementFormScreen> createState() => _ProductRequirementFormScreenState();
}

class _ProductRequirementFormScreenState extends ConsumerState<ProductRequirementFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String customerOrderNumber = '';
  String productName = '';
  String description = '';
  int requestedQuantity = 1;
  String unit = 'Pcs';
  String targetPriceRange = '';
  String urgencyLevel = 'MEDIUM';
  String status = 'PENDING';
  int? requestedByOfficerId;
  String requestedByOfficerName = '';
  String procurementRemarks = '';

  final List<String> units = ['Pcs', 'Kg', 'Box', 'Ltr', 'Meter', 'Set', 'Pack'];
  final List<String> urgencyLevels = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    requestedByOfficerId = currentUser?.userId;
    requestedByOfficerName = currentUser?.name ?? '';

    if (widget.requirementToEdit != null) {
      final r = widget.requirementToEdit!;
      customerOrderNumber = r.customerOrderNumber;
      productName = r.productName;
      description = r.description;
      requestedQuantity = r.requestedQuantity;
      unit = r.unit;
      targetPriceRange = r.targetPriceRange;
      urgencyLevel = r.urgencyLevel;
      status = r.status;
      requestedByOfficerId = r.requestedByOfficerId;
      requestedByOfficerName = r.requestedByOfficerName;
      procurementRemarks = r.procurementRemarks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.requirementToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ১. Top Header Bar
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Update Product Requirement' : 'Record Product Requirement',
                            style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Log requisition specifications, target quantities, and officer requests',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
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

            // ২. Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Product Item Name
                      _buildNumberedStepLabel(1, 'Product Item Name *'),
                      TextFormField(
                        initialValue: productName,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. Industrial Steel Pipe / Raw Cotton',
                          prefixIcon: const Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.grey),
                        ),
                        onChanged: (val) => productName = val,
                      ),
                      const SizedBox(height: 16),

                      // 2. Movement Quantity (Requested Quantity)
                      _buildNumberedStepLabel(2, 'Movement Quantity *'),
                      TextFormField(
                        initialValue: requestedQuantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          hintText: '1',
                          prefixIcon: const Icon(Icons.format_list_numbered, size: 18, color: AppTheme.grey),
                        ),
                        validator: (val) {
                          final num = int.tryParse(val ?? '') ?? 0;
                          return num <= 0 ? 'Quantity must be at least 1!' : null;
                        },
                        onChanged: (val) => requestedQuantity = int.tryParse(val) ?? 1,
                      ),
                      const SizedBox(height: 16),

                      // 3. Urgency Priority Level
                      _buildNumberedStepLabel(3, 'Urgency Priority Level *'),
                      DropdownButtonFormField<String>(
                        initialValue: urgencyLevel,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Icon(Icons.bolt, size: 18, color: AppTheme.warning),
                        ),
                        items: urgencyLevels.map((u) => DropdownMenuItem(
                          value: u,
                          child: Text('⚡ $u', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        )).toList(),
                        onChanged: (val) => setState(() => urgencyLevel = val ?? 'MEDIUM'),
                      ),
                      const SizedBox(height: 16),

                      // 4. Customer Order Number
                      _buildNumberedStepLabel(4, 'Customer Order Number'),
                      TextFormField(
                        initialValue: customerOrderNumber,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. ORD-1786341321716',
                          prefixIcon: const Icon(Icons.receipt_outlined, size: 18, color: AppTheme.grey),
                        ),
                        onChanged: (val) => customerOrderNumber = val,
                      ),
                      const SizedBox(height: 16),

                      // 5. Packaging Unit
                      _buildNumberedStepLabel(5, 'Packaging Unit *'),
                      DropdownButtonFormField<String>(
                        initialValue: unit,
                        decoration: _inputDecoration(),
                        items: units.map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u, style: const TextStyle(fontSize: 13)),
                        )).toList(),
                        onChanged: (val) => setState(() => unit = val ?? 'Pcs'),
                      ),
                      const SizedBox(height: 16),

                      // 6. Target Price Range
                      _buildNumberedStepLabel(6, 'Target Price Range'),
                      TextFormField(
                        initialValue: targetPriceRange,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'e.g. ৳500 - ৳800 per unit',
                          prefixIcon: const Icon(Icons.local_offer_outlined, size: 18, color: AppTheme.grey),
                        ),
                        onChanged: (val) => targetPriceRange = val,
                      ),
                      const SizedBox(height: 16),

                      // 7. Requesting Officer Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNumberedStepLabel(7, 'Requesting Officer Name'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.blueLight.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.blueLight.withValues(alpha: 0.4)),
                            ),
                            child: const Text('Auto-filled', style: TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        readOnly: true,
                        initialValue: requestedByOfficerName,
                        decoration: _inputDecoration().copyWith(
                          prefixIcon: const Icon(Icons.person, size: 18, color: AppTheme.grey),
                          fillColor: AppTheme.borderGrey.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 8. Product Specification & Details
                      _buildNumberedStepLabel(8, 'Product Specification & Details'),
                      TextFormField(
                        initialValue: description,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Product technical specifications, grade, measurements, brand requirements...',
                          contentPadding: const EdgeInsets.all(12),
                          counterText: '',
                        ),
                        onChanged: (val) => description = val,
                      ),
                      const SizedBox(height: 16),

                      // 9. Remarks & Audit Notes
                      _buildNumberedStepLabel(9, 'Remarks & Audit Notes'),
                      TextFormField(
                        initialValue: procurementRemarks,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Cause of requirement or procurement notes...',
                          contentPadding: const EdgeInsets.all(12),
                          counterText: '',
                        ),
                        onChanged: (val) => procurementRemarks = val,
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text('0/300', style: TextStyle(fontSize: 9, color: AppTheme.grey)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer Action Buttons (Cancel & Commit Requirement Ledger)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: AppTheme.dark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                final request = ProductRequirementRequest(
                                  customerOrderNumber: customerOrderNumber.trim(),
                                  productName: productName.trim(),
                                  description: description.trim(),
                                  requestedQuantity: requestedQuantity,
                                  unit: unit,
                                  targetPriceRange: targetPriceRange.trim(),
                                  urgencyLevel: urgencyLevel,
                                  status: status,
                                  requestedByOfficerId: requestedByOfficerId,
                                  requestedByOfficerName: requestedByOfficerName,
                                  procurementRemarks: procurementRemarks.trim(),
                                );

                                bool success = false;
                                if (isEdit && widget.requirementToEdit != null) {
                                  success = await ref
                                      .read(productRequirementControllerProvider.notifier)
                                      .updateRequirement(widget.requirementToEdit!.id, request);
                                } else {
                                  success = await ref
                                      .read(productRequirementControllerProvider.notifier)
                                      .saveRequirement(request);
                                }

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product requirement committed successfully!'), backgroundColor: AppTheme.success),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.swap_horiz, size: 18),
                              label: Text(isEdit ? 'Update Requirement' : 'Commit Requirement Ledger'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: AppTheme.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
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

  Widget _buildNumberedStepLabel(int stepNum, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(
              child: Text(
                stepNum.toString(),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.indigoDark),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}