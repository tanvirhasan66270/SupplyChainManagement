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

class ShipmentFormScreen extends ConsumerStatefulWidget {
  final ShipmentResponseModel? shipmentToEdit;

  const ShipmentFormScreen({super.key, this.shipmentToEdit});

  @override
  ConsumerState<ShipmentFormScreen> createState() => _ShipmentFormScreenState();
}

class _ShipmentFormScreenState extends ConsumerState<ShipmentFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int poId = 0;
  int supplierId = 0;
  String vehicleNumber = '';
  String captainRegistrationNumber = '';
  String origin = '';
  int shipmentQuantity = 0;
  double transportCost = 0.0;
  String estimatedDelivery = '';
  String assignedByEmail = '';
  String sendByAddress = '';
  File? selectedFile;

  String? errorMessage;
  bool isEdit = false;
  int? currentEditId;

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

    if (widget.shipmentToEdit != null) {
      final s = widget.shipmentToEdit!;
      isEdit = true;
      currentEditId = s.id;
      poId = s.poId;
      supplierId = s.supplierId;
      vehicleNumber = s.vehicleNumber;
      captainRegistrationNumber = s.captainRegistrationNumber;
      origin = s.origin;
      shipmentQuantity = s.shipmentQuantity;
      transportCost = s.transportCost;
      estimatedDelivery = s.estimatedDelivery;
      assignedByEmail = s.assignedByEmail;
      sendByAddress = s.sendByAddress;

      _vehicleController.text = s.vehicleNumber;
      _captainController.text = s.captainRegistrationNumber;
      _originController.text = s.origin;
      _quantityController.text = s.shipmentQuantity.toString();
      _costController.text = s.transportCost.toString();
      _deliveryController.text = s.estimatedDelivery;
      _addressController.text = s.sendByAddress;
    }
  }

  @override
  void dispose() {
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

  int _getRemainingQuantity(PurchaseOrderResponse? po, List<ShipmentResponseModel> shipments) {
    if (po == null) return 0;
    final poQty = po.quantity;
    final prevShipped = shipments
        .where((s) => s.poId == po.id && s.id != currentEditId)
        .fold(0, (sum, s) => sum + s.shipmentQuantity);
    final rem = poQty - prevShipped;
    return rem > 0 ? rem : 0;
  }

  bool _isQtyInvalid(PurchaseOrderResponse? po, List<ShipmentResponseModel> shipments) {
    if (po == null || shipmentQuantity <= 0) return false;
    final remaining = _getRemainingQuantity(po, shipments);
    return shipmentQuantity > remaining;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final supplierListAsync = ref.watch(supplierListProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final shipmentsAsync = ref.watch(shipmentListProvider);
    final shipmentControllerState = ref.watch(shipmentControllerProvider);

    final userRole = (currentUser?.role ?? 'SUPPLIER').toUpperCase();
    final isSupplierRole = userRole == 'SUPPLIER';

    final suppliers = supplierListAsync.value ?? [];
    final allPOs = purchaseOrdersAsync.value ?? [];
    final allShipments = shipmentsAsync.value ?? [];

    final currentSupplier = suppliers.where((s) => s.userId == currentUser?.userId).firstOrNull;
    final currentSupplierId = currentSupplier?.id ?? (suppliers.isNotEmpty ? suppliers.first.id : 1);
    final currentSupplierName = currentSupplier?.name ?? currentUser?.name ?? 'Your Supplier Account';

    if (assignedByEmail.isEmpty && currentUser != null) {
      assignedByEmail = currentUser.email;
    }

    if (isSupplierRole && supplierId == 0) {
      supplierId = currentSupplierId;
    }

    final posAvailable = isSupplierRole && currentSupplierId > 0
        ? allPOs.where((po) => po.supplierId == currentSupplierId).toList()
        : allPOs;

    final selectedPo = posAvailable.where((p) => p.id == poId).firstOrNull;
    final remainingQty = _getRemainingQuantity(selectedPo, allShipments);
    final qtyInvalid = _isQtyInvalid(selectedPo, allShipments);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Fully Dynamic)
            DynamicScmTopNavBar(
              title: isEdit ? 'Modify Shipment' : 'Add Shipment',
              showBackButton: true,
              onRefresh: () {
                ref.invalidate(purchaseOrderListProvider);
                ref.invalidate(shipmentListProvider);
              },
            ),

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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: TARGET PURCHASE ORDER VECTOR
                      _buildNumberedStepLabel(1, 'TARGET PURCHASE ORDER VECTOR *'),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: poId == 0 ? null : poId,
                        hint: const Text('-- Link Master Purchase Order --', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
                        decoration: _inputDecoration(),
                        items: posAvailable.map((po) {
                          return DropdownMenuItem<int>(
                            value: po.id,
                            child: Text(
                              'PO #${po.poNumber} (Valuation: \$${po.totalAmount.toStringAsFixed(2)})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: isEdit
                            ? null
                            : (val) {
                                setState(() {
                                  poId = val ?? 0;
                                  if (poId > 0) {
                                    final matchedPo = posAvailable.where((p) => p.id == poId).firstOrNull;
                                    if (matchedPo != null && matchedPo.supplierId > 0) {
                                      supplierId = matchedPo.supplierId;
                                    }
                                  }
                                });
                              },
                      ),
                      const SizedBox(height: 14),

                      // Step 2: ASSIGNED SUPPLIER VENDOR
                      _buildNumberedStepLabel(2, 'ASSIGNED SUPPLIER VENDOR *'),
                      if (isSupplierRole)
                        TextFormField(
                          readOnly: true,
                          initialValue: '$currentSupplierName (Your Supplier Account)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          decoration: _inputDecoration(),
                        )
                      else
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: supplierId == 0 ? null : supplierId,
                          hint: const Text('-- Map Dispatch Supplier Node --', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
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

                      // Step 3: VEHICLE FLEET PLATE NO
                      _buildNumberedStepLabel(3, 'VEHICLE FLEET PLATE NO *'),
                      TextFormField(
                        controller: _vehicleController,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        decoration: _inputDecoration().copyWith(hintText: 'e.g. DHAKA-METRO-T-1122'),
                        onChanged: (val) => vehicleNumber = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 4: CAPTAIN LICENSE REG NO
                      _buildNumberedStepLabel(4, 'CAPTAIN LICENSE REG NO *'),
                      TextFormField(
                        controller: _captainController,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        decoration: _inputDecoration().copyWith(hintText: 'e.g. BRTA-DL-99228'),
                        onChanged: (val) => captainRegistrationNumber = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 5: FREIGHT SOURCING ORIGIN
                      _buildNumberedStepLabel(5, 'FREIGHT SOURCING ORIGIN *'),
                      TextFormField(
                        controller: _originController,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration().copyWith(hintText: 'e.g. Chittagong Port Yard'),
                        onChanged: (val) => origin = val,
                      ),
                      const SizedBox(height: 14),

                      // Step 6: SHIPMENT QTY
                      _buildNumberedStepLabel(6, 'SHIPMENT QTY *'),
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
                          '⚠️ Shipment quantity cannot exceed remaining PO quantity (Max: $remainingQty Units).',
                          style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Step 7: EST COST ($)
                      _buildNumberedStepLabel(7, 'EST COST (\$) *'),
                      TextFormField(
                        controller: _costController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        decoration: _inputDecoration(),
                        onChanged: (val) => transportCost = double.tryParse(val) ?? 0.0,
                      ),
                      const SizedBox(height: 14),

                      // Step 8: TARGET EXPECTED DELIVERY DATE
                      _buildNumberedStepLabel(8, 'TARGET EXPECTED DELIVERY DATE *'),
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

                      // Step 9: ASSIGNED CONTROLLER EMAIL
                      _buildNumberedStepLabel(9, 'ASSIGNED CONTROLLER EMAIL'),
                      TextFormField(
                        readOnly: true,
                        initialValue: assignedByEmail,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppTheme.secondary),
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 14),

                      // Step 10: CONSIGNMENT DESTINATION ADDRESS
                      _buildNumberedStepLabel(10, 'CONSIGNMENT TARGET DESTINATION ADDRESS *'),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12),
                        decoration: _inputDecoration().copyWith(hintText: 'Full delivery terminal address details...'),
                        onChanged: (val) => sendByAddress = val,
                      ),
                      const SizedBox(height: 14),

                      // Proof of Delivery File Attachment
                      _buildNumberedStepLabel(11, 'PROOF OF DELIVERY (PDF/IMAGE POD)'),
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
                                  selectedFile != null ? selectedFile!.path.split('/').last : (widget.shipmentToEdit?.podFileUrl ?? 'No file chosen'),
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
                          onPressed: (shipmentControllerState.isLoading || qtyInvalid)
                              ? null
                              : () async {
                                  setState(() => errorMessage = null);

                                  if (poId == 0) {
                                    setState(() => errorMessage = 'Please select a Purchase Order to link this shipment.');
                                    return;
                                  }

                                  if (supplierId == 0) {
                                    setState(() => errorMessage = 'Validation Error: Dispatch Supplier Node reference is required.');
                                    return;
                                  }

                                  if (vehicleNumber.isEmpty || captainRegistrationNumber.isEmpty) {
                                    setState(() => errorMessage = 'Vehicle and Captain registration details are required.');
                                    return;
                                  }

                                  if (qtyInvalid) {
                                    setState(() => errorMessage = 'Shipment quantity cannot exceed remaining PO quantity (Max: $remainingQty Units).');
                                    return;
                                  }

                                  final req = ShipmentRequestModel(
                                    poId: poId,
                                    supplierId: supplierId,
                                    vehicleNumber: vehicleNumber,
                                    captainRegistrationNumber: captainRegistrationNumber,
                                    assignedByEmail: assignedByEmail,
                                    origin: origin.isEmpty ? 'Supplier Warehouse' : origin,
                                    sendByAddress: sendByAddress.isEmpty ? 'Central Terminal' : sendByAddress,
                                    estimatedDelivery: estimatedDelivery,
                                    transportCost: transportCost,
                                    shipmentQuantity: shipmentQuantity,
                                    podFileUrl: widget.shipmentToEdit?.podFileUrl ?? '',
                                  );

                                  bool success = false;
                                  if (isEdit && currentEditId != null) {
                                    success = await ref.read(shipmentControllerProvider.notifier).updateShipment(currentEditId!, req, selectedFile);
                                  } else {
                                    success = await ref.read(shipmentControllerProvider.notifier).createShipment(req, selectedFile);
                                  }

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isEdit ? 'Shipment logistics registry updated successfully.' : 'New Cargo Dispatch Node authorized and registered.'),
                                        backgroundColor: const Color(0xFF16A34A),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                },
                          icon: shipmentControllerState.isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: Text(
                            isEdit ? 'COMMIT FREIGHT CHANGES' : 'LAUNCH CONSIGNMENT TRACK',
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