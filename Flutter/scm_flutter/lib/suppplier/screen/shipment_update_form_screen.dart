import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/purchase-order_model.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/suppplier/provider/shipment_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class ShipmentUpdateFormScreen extends ConsumerStatefulWidget {
  const ShipmentUpdateFormScreen({super.key});

  @override
  ConsumerState<ShipmentUpdateFormScreen> createState() => _ShipmentUpdateFormScreenState();
}

class _ShipmentUpdateFormScreenState extends ConsumerState<ShipmentUpdateFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String searchTerm = '';
  PurchaseOrderResponse? selectedPo;

  String vehicleNumber = '';
  String captainRegistrationNumber = '';
  String origin = '';
  int shipmentQuantity = 0;
  double transportCost = 0.0;
  String estimatedDelivery = '';
  String sendByAddress = '';
  File? selectedFile;

  String? errorMessage;
  bool isSubmitting = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _captainController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final defaultDelivery = DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0];
    estimatedDelivery = defaultDelivery;
    _deliveryController.text = defaultDelivery;
    _quantityController.text = '0';
    _costController.text = '0.00';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vehicleController.dispose();
    _captainController.dispose();
    _originController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _deliveryController.dispose();
    _addressController.dispose();
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

  int _getRemainingQuantity(PurchaseOrderResponse po, List<ShipmentResponseModel> shipments) {
    final poQty = po.quantity;
    final prevShipped = shipments.where((s) => s.poId == po.id).fold(0, (sum, s) => sum + s.shipmentQuantity);
    final rem = poQty - prevShipped;
    return rem > 0 ? rem : 0;
  }

  bool _isQtyInvalid(PurchaseOrderResponse po, List<ShipmentResponseModel> shipments) {
    if (shipmentQuantity <= 0) return false;
    final remaining = _getRemainingQuantity(po, shipments);
    return shipmentQuantity > remaining;
  }

  void _selectPo(PurchaseOrderResponse po) {
    setState(() {
      selectedPo = po;
      searchTerm = po.poNumber;
      _searchController.text = po.poNumber;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final supplierListAsync = ref.watch(supplierListProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);

    final userRole = (currentUser?.role ?? 'SUPPLIER').toUpperCase();
    final isSupplierRole = userRole == 'SUPPLIER';

    final suppliers = supplierListAsync.value ?? [];
    final allPOs = purchaseOrdersAsync.value ?? [];
    final allShipments = shipmentsAsync.value ?? [];

    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;
    final currentSupplierId = currentSupplier?.id ?? (suppliers.isNotEmpty ? suppliers.first.id : 1);

    final posAvailable = isSupplierRole && currentSupplierId > 0
        ? allPOs.where((po) => po.supplierId == currentSupplierId).toList()
        : allPOs;

    final suggestions = searchTerm.trim().isEmpty
        ? <PurchaseOrderResponse>[]
        : posAvailable.where((p) => p.poNumber.toLowerCase().contains(searchTerm.toLowerCase()) || p.id.toString() == searchTerm.trim()).toList();

    final maxAllowedQty = selectedPo != null ? _getRemainingQuantity(selectedPo!, allShipments) : 0;
    final qtyInvalid = selectedPo != null ? _isQtyInvalid(selectedPo!, allShipments) : false;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Header Bar (Fully Dynamic) ──
            DynamicScmTopNavBar(
              title: 'Shipment Update',
              showBackButton: true,
              onRefresh: () {
                ref.invalidate(purchaseOrderListProvider);
                ref.invalidate(shipmentListProvider);
              },
            ),

            // ── 2. Error Message Banner ──
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

            // ── 3. Scrollable Form Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: SEARCH PURCHASE ORDER NUMBER
                      _buildNumberedStepLabel(1, 'SEARCH PURCHASE ORDER NUMBER *'),
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: _inputDecoration().copyWith(
                          hintText: 'Type PO Number (e.g. PO-17868...)',
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.secondary),
                          suffixIcon: searchTerm.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    setState(() {
                                      searchTerm = '';
                                      selectedPo = null;
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {
                            searchTerm = val;
                            if (selectedPo != null && !selectedPo!.poNumber.toLowerCase().contains(val.toLowerCase())) {
                              selectedPo = null;
                            }
                          });
                        },
                      ),

                      // PO Suggestions Dropdown List
                      if (suggestions.isNotEmpty && selectedPo == null) ...[
                        const SizedBox(height: 6),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderGrey),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            separatorBuilder: (c, i) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final po = suggestions[idx];
                              return ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    const Icon(Icons.description_outlined, size: 16, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                subtitle: Text('Status: ${po.status}', style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
                                trailing: Text('\$${po.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A), fontSize: 11)),
                                onTap: () => _selectPo(po),
                              );
                            },
                          ),
                        ),
                      ],

                      // ── New Add Shipment Form Section ──
                      if (selectedPo != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.add_box_outlined, color: Color(0xFF2563EB), size: 18),
                                      const SizedBox(width: 6),
                                      const Text('New Add Shipment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(20)),
                                    child: Text(selectedPo!.status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('PO Number:', style: TextStyle(fontSize: 10, color: AppTheme.secondary)),
                                      Text(selectedPo!.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Order Valuation:', style: TextStyle(fontSize: 10, color: AppTheme.secondary)),
                                      Text('\$${selectedPo!.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF16A34A))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Step 2: VEHICLE FLEET PLATE NO
                        _buildNumberedStepLabel(2, 'VEHICLE FLEET PLATE NO *'),
                        TextFormField(
                          controller: _vehicleController,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          decoration: _inputDecoration().copyWith(hintText: 'e.g. DHAKA-METRO-T-1122'),
                          onChanged: (val) => vehicleNumber = val,
                        ),
                        const SizedBox(height: 14),

                        // Step 3: CAPTAIN LICENSE REG NO
                        _buildNumberedStepLabel(3, 'CAPTAIN LICENSE REG NO *'),
                        TextFormField(
                          controller: _captainController,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          decoration: _inputDecoration().copyWith(hintText: 'e.g. BRTA-DL-99228'),
                          onChanged: (val) => captainRegistrationNumber = val,
                        ),
                        const SizedBox(height: 14),

                        // Step 4: FREIGHT SOURCING ORIGIN
                        _buildNumberedStepLabel(4, 'FREIGHT SOURCING ORIGIN *'),
                        TextFormField(
                          controller: _originController,
                          style: const TextStyle(fontSize: 12),
                          decoration: _inputDecoration().copyWith(hintText: 'e.g. Chittagong Port Yard'),
                          onChanged: (val) => origin = val,
                        ),
                        const SizedBox(height: 14),

                        // Step 5: SHIPMENT QTY
                        _buildNumberedStepLabel(5, 'SHIPMENT QTY *'),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: qtyInvalid ? Colors.red : Colors.black87,
                          ),
                          decoration: _inputDecoration().copyWith(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: qtyInvalid ? Colors.red : AppTheme.borderGrey),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              shipmentQuantity = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                        if (qtyInvalid) ...[
                          const SizedBox(height: 4),
                          Text(
                            '⚠️ Shipment quantity cannot exceed remaining PO quantity (Max: $maxAllowedQty Units).',
                            style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Step 6: EST COST ($)
                        _buildNumberedStepLabel(6, 'EST COST (\$) *'),
                        TextFormField(
                          controller: _costController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          decoration: _inputDecoration(),
                          onChanged: (val) => transportCost = double.tryParse(val) ?? 0.0,
                        ),
                        const SizedBox(height: 14),

                        // Step 7: TARGET EXPECTED DELIVERY DATE
                        _buildNumberedStepLabel(7, 'TARGET EXPECTED DELIVERY DATE *'),
                        TextFormField(
                          controller: _deliveryController,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          decoration: _inputDecoration().copyWith(
                            hintText: 'yyyy-mm-dd',
                            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.secondary),
                          ),
                          onChanged: (val) => estimatedDelivery = val,
                        ),
                        const SizedBox(height: 14),

                        // Step 8: CONSIGNMENT DESTINATION ADDRESS
                        _buildNumberedStepLabel(8, 'CONSIGNMENT TARGET DESTINATION ADDRESS *'),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12),
                          decoration: _inputDecoration().copyWith(hintText: 'Full delivery terminal address details...'),
                          onChanged: (val) => sendByAddress = val,
                        ),
                        const SizedBox(height: 14),

                        // Step 9: PROOF OF DELIVERY FILE ATTACHMENT
                        _buildNumberedStepLabel(9, 'PROOF OF DELIVERY (PDF/IMAGE POD)'),
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
                                    selectedFile != null ? selectedFile!.path.split('/').last : 'Attach signed POD file...',
                                    style: TextStyle(fontSize: 11, color: selectedFile != null ? Colors.black87 : AppTheme.secondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SUBMIT BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: (isSubmitting || qtyInvalid)
                                ? null
                                : () async {
                                    setState(() => errorMessage = null);

                                    if (vehicleNumber.isEmpty || captainRegistrationNumber.isEmpty) {
                                      setState(() => errorMessage = 'Validation Error: Vehicle and Captain registration details are required.');
                                      return;
                                    }

                                    if (qtyInvalid) {
                                      setState(() => errorMessage = 'Validation Error: Shipment quantity exceeds remaining PO limit.');
                                      return;
                                    }

                                    setState(() => isSubmitting = true);

                                    final req = ShipmentRequestModel(
                                      poId: selectedPo!.id,
                                      supplierId: selectedPo!.supplierId > 0 ? selectedPo!.supplierId : 1,
                                      vehicleNumber: vehicleNumber,
                                      captainRegistrationNumber: captainRegistrationNumber,
                                      assignedByEmail: currentUser?.email ?? 'supplier@scm.com',
                                      origin: origin.isEmpty ? 'Supplier Warehouse' : origin,
                                      sendByAddress: sendByAddress.isEmpty ? 'Central Terminal' : sendByAddress,
                                      estimatedDelivery: estimatedDelivery,
                                      transportCost: transportCost,
                                      shipmentQuantity: shipmentQuantity,
                                      podFileUrl: '',
                                    );

                                    final success = await ref.read(shipmentControllerProvider.notifier).createShipment(req, selectedFile);

                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('🚀 Cargo shipment dispatched and registered successfully!'),
                                          backgroundColor: Color(0xFF16A34A),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      setState(() {
                                        isSubmitting = false;
                                        errorMessage = 'Failed to dispatch cargo shipment.';
                                      });
                                    }
                                  },
                            icon: isSubmitting
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.cloud_upload_outlined, size: 18),
                            label: const Text(
                              'LAUNCH CONSIGNMENT TRACK',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: const [
                              Icon(Icons.search, size: 48, color: AppTheme.secondary),
                              SizedBox(height: 10),
                              Text(
                                'No Purchase Order Selected',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Type and select an active Purchase Order above to proceed with the shipment update.',
                                style: TextStyle(fontSize: 11, color: AppTheme.secondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
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
