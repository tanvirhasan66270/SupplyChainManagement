import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/po_line_item_model.dart';
import 'package:scm_flutter/suppplier/provider/po_line_item_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class POLineItemFormScreen extends ConsumerStatefulWidget {
  final POLineItemResponseDTO? itemToEdit;

  const POLineItemFormScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<POLineItemFormScreen> createState() => _POLineItemFormScreenState();
}

class _POLineItemFormScreenState extends ConsumerState<POLineItemFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ফর্ম ফিল্ড স্টেটস
  int poId = 0;
  int productId = 0;
  int quantity = 1;
  double unitPrice = 0.0;
  String quotationRef = '';
  String shipmentMethod = '';
  String deliveryDate = '';
  String notes = '';
  String status = 'PENDING';
  String poNumber = '';

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      poId = item.poId;
      productId = item.productId;
      quantity = item.quantity;
      unitPrice = item.unitPrice;
      quotationRef = item.quotationRef;
      shipmentMethod = item.shipmentMethod;
      deliveryDate = item.deliveryDate;
      notes = item.notes;
      status = item.status;
      poNumber = item.poNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Enterprise Bar (Fully Dynamic) ──
            const DynamicScmTopNavBar(
              title: 'Line Item Entry',
              showBackButton: true,
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── 2. Purple Gradient Form Header ──
                    _buildFormHeader(),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step 1: Parent PO Matrix
                            _buildNumberedStepLabel(1, 'PARENT PURCHASE ORDER MATRIX *'),
                            _buildThemedDropdown<int>(
                              value: poId == 0 ? null : poId,
                              hint: '-- Link Master Purchase Order --',
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('PO-1783503003037 (Aggregate Vol: \$4,800.00)', style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(value: 2, child: Text('PO-1783503881700 (Aggregate Vol: \$4,800.00)', style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) => setState(() => poId = val ?? 0),
                            ),
                            const SizedBox(height: 20),

                            // Step 2: Target SKUs
                            _buildNumberedStepLabel(2, 'TARGET SKUS PRODUCT MODULE *'),
                            _buildThemedDropdown<int>(
                              value: productId == 0 ? null : productId,
                              hint: '-- Select Catalog Product --',
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Industrial Sewing Machine (SKU: SKU-001)', style: TextStyle(fontSize: 13))),
                                DropdownMenuItem(value: 2, child: Text('Garments Cutting Unit (SKU: SKU-002)', style: TextStyle(fontSize: 13))),
                              ],
                              onChanged: (val) => setState(() => productId = val ?? 0),
                            ),
                            const SizedBox(height: 20),

                            // Step 3: Allocated Volume
                            _buildNumberedStepLabel(3, 'ALLOCATED VOLUME (QTY) *'),
                            _buildThemedField(
                              initialValue: quantity.toString(),
                              icon: Icons.inventory_2_outlined,
                              iconColor: AppTheme.primary,
                              onChanged: (val) => quantity = int.tryParse(val) ?? 1,
                            ),
                            const SizedBox(height: 20),

                            // Step 4: Explicit Base Price
                            _buildNumberedStepLabel(4, 'EXPLICIT BASE PRICE (\$) *'),
                            _buildThemedField(
                              initialValue: unitPrice.toStringAsFixed(2),
                              icon: Icons.attach_money,
                              iconColor: AppTheme.success,
                              onChanged: (val) => unitPrice = double.tryParse(val) ?? 0.0,
                            ),
                            const SizedBox(height: 20),

                            // Step 5: Quotation Reference
                            _buildNumberedStepLabel(5, 'QUOTATION REFERENCE'),
                            _buildThemedField(
                              hintText: 'e.g. QT-9982',
                              icon: Icons.description_outlined,
                              iconColor: AppTheme.purple,
                              onChanged: (val) => quotationRef = val,
                            ),
                            const SizedBox(height: 20),

                            // Step 6: Shipment Method Pathway
                            _buildNumberedStepLabel(6, 'SHIPMENT METHOD PATHWAY'),
                            _buildThemedField(
                              hintText: 'e.g. DHL Air Cargo',
                              icon: Icons.local_shipping_outlined,
                              iconColor: AppTheme.orange,
                              onChanged: (val) => shipmentMethod = val,
                            ),
                            const SizedBox(height: 20),

                            // Step 7: Target Delivery Date
                            _buildNumberedStepLabel(7, 'TARGET DELIVERY DATE'),
                            _buildThemedField(
                              hintText: 'mm/dd/yyyy',
                              icon: Icons.calendar_today_outlined,
                              iconColor: AppTheme.pink,
                              suffixIcon: Icons.calendar_month,
                              onChanged: (val) => deliveryDate = val,
                            ),
                            const SizedBox(height: 20),

                            // Step 8: Sourcing Pipeline Directives
                            _buildNumberedStepLabel(8, 'SOURCING PIPELINE DIRECTIVES'),
                            _buildThemedField(
                              hintText: 'Enter custom pipeline allocation logistics notes context...',
                              icon: Icons.assignment_outlined,
                              iconColor: AppTheme.indigo,
                              maxLines: 4,
                              onChanged: (val) => notes = val,
                            ),
                            const SizedBox(height: 32),

                            // Action Buttons
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                                label: const Text('PUBLISH ALLOCATION SLIPS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _clearForm,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: AppTheme.borderGrey),
                                  foregroundColor: AppTheme.dark,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.indigo, AppTheme.indigoDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.note_add_outlined, color: AppTheme.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Append Order Line Distribution',
              style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.white.withValues(alpha: 0.7), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedStepLabel(int stepNum, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: AppTheme.blueLight, shape: BoxShape.circle),
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedField({
    String? hintText,
    String? initialValue,
    required IconData icon,
    required Color iconColor,
    IconData? suffixIcon,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.dark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.secondary, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20, color: AppTheme.dark) : null,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppTheme.secondary, fontWeight: FontWeight.normal)),
          decoration: const InputDecoration(border: InputBorder.none),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.secondary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 'Dashboard', false),
          _buildNavItem(Icons.assignment_outlined, 'Requisitions', false),
          _buildNavItem(Icons.shopping_cart_outlined, 'Orders', true),
          _buildNavItem(Icons.people_outline_rounded, 'Suppliers', false),
          _buildNavItem(Icons.more_horiz_rounded, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? AppTheme.primary : AppTheme.secondary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primary : AppTheme.secondary, fontWeight: isActive ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (poId == 0 || productId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Parent PO and Catalog Product!'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    final request = POLineItemRequestDTO(
      poId: poId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      quotationRef: quotationRef,
      poNumber: poNumber,
      deliveryDate: deliveryDate.isEmpty ? '2026-06-30' : deliveryDate,
      shipmentMethod: shipmentMethod,
      notes: notes,
      status: status,
    );

    final success = await ref.read(poLineItemControllerProvider.notifier).createLineItem(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚀 Distribution slip published successfully!'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      poId = 0;
      productId = 0;
      quantity = 1;
      unitPrice = 0.0;
      quotationRef = '';
      shipmentMethod = '';
      deliveryDate = '';
      notes = '';
    });
  }
}