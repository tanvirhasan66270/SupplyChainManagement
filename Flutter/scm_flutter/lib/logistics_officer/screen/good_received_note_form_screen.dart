import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/grn_model.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/logistics_officer/provider/good_received_note_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/warehouse_provider.dart';
import 'package:scm_flutter/logistics_officer/screen/good_received_note_data_screen.dart';
import 'package:scm_flutter/procourment/provider/purchase_order_provider.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/qc_inspactor/provider/qc_inspector_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class GoodReceivedNoteFormScreen extends ConsumerStatefulWidget {
  const GoodReceivedNoteFormScreen({super.key, this.grnToEdit});

  final GoodsReceivedNoteResponseModel? grnToEdit;

  @override
  ConsumerState<GoodReceivedNoteFormScreen> createState() => _GoodReceivedNoteFormScreenState();
}

class _GoodReceivedNoteFormScreenState extends ConsumerState<GoodReceivedNoteFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int poId = 0;
  int? productId;
  int receivedQuantity = 0;
  int receivedBy = 0;
  int warehouseId = 0;
  String receivedAt = '';
  String status = 'PENDING';
  String remarks = '';
  int? inspectedBy;
  String? inspectionDate;
  List<GRNLineItemRequestModel> lineItems = [];
  String? receivedQuantityError;
  String? errorMessage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    receivedBy = currentUser?.userId ?? 0;
    receivedAt = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    if (widget.grnToEdit != null) {
      final g = widget.grnToEdit!;
      poId = g.poId;
      productId = g.productId;
      receivedQuantity = g.receivedQuantity;
      receivedBy = g.receivedBy;
      warehouseId = g.warehouseId;
      receivedAt = g.receivedAt;
      status = g.status;
      remarks = g.remarks;
      inspectedBy = g.inspectedBy;
      inspectionDate = g.inspectionDate;
      if (g.lineItems != null) {
        lineItems = g.lineItems!
            .map((item) => GRNLineItemRequestModel(
                  id: item.id,
                  grnId: item.grnId,
                  productId: item.productId,
                  quantityOrdered: item.quantityOrdered,
                  quantityReceived: item.quantityReceived,
                ))
            .toList();
      }
    }
  }

  void _addLineItem() {
    setState(() {
      lineItems.add(GRNLineItemRequestModel(
        productId: 0,
        quantityOrdered: 0,
        quantityReceived: 0,
      ));
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      lineItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userRole = currentUser?.role.toUpperCase() ?? '';
    final isQcInspector = userRole == 'QC_INSPECTOR' || userRole == 'ROLE_QC_INSPECTOR' || userRole == 'QC' || userRole == 'QC_INSPACTOR' || userRole == 'ROLE_QC_INSPACTOR';

    if (isQcInspector) {
      return Scaffold(
        backgroundColor: AppTheme.light,
        appBar: AppBar(
          title: const Text('Access Restricted', style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          leading: const BackButton(color: AppTheme.dark),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block_outlined, color: AppTheme.danger, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Form Access Restricted',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.dark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'QC Inspectors are authorized for read-only view of Goods Received Notes (GRN). Form creation and modification are restricted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.secondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.surfaceWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GoodReceivedNoteDataScreen()),
                    );
                  },
                  icon: const Icon(Icons.table_chart_outlined, size: 18),
                  label: const Text('View GRN Registry Data'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isEdit = widget.grnToEdit != null;
    final purchaseOrdersAsync = ref.watch(purchaseOrderListProvider);
    final purchaseRequisitionsAsync = ref.watch(purchaseRequisitionListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);
    final productsAsync = ref.watch(productListProvider);
    final inspectorsAsync = ref.watch(qcInspectorListProvider);

    final poList = purchaseOrdersAsync.value ?? [];
    final prList = purchaseRequisitionsAsync.value ?? [];
    final allProducts = productsAsync.value ?? [];

    // Filter products based on selected Purchase Order (poId)
    List<ProductResponseModel> filteredProducts = allProducts;
    if (poId != 0 && poList.isNotEmpty) {
      final selectedPo = poList.firstWhereOrNull((p) => p.id == poId);
      if (selectedPo != null) {
        final selectedPr = prList.firstWhereOrNull((r) => r.id == selectedPo.purchaseRequisitionId);
        if (selectedPr != null && selectedPr.productIds.isNotEmpty) {
          filteredProducts = allProducts.where((p) => selectedPr.productIds.contains(p.id)).toList();
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modify GRN Allocation Metadata' : 'Process Inbound Cargo (GRN)',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppTheme.surfaceWhite, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Goods Received Note (GRN) Registry',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Log arriving fleet consignments & execute quality inspector validations',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.danger),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
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
                  const SizedBox(height: 16),
                ],

                // 1. Source Purchase Order Selector
                _buildStepLabel(1, 'SOURCE PURCHASE ORDER VECTOR *'),
                purchaseOrdersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading POs: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (poList) {
                    return DropdownButtonFormField<int>(
                      initialValue: poId != 0 && poList.any((p) => p.id == poId) ? poId : null,
                      decoration: _inputDecoration('-- Link Core Procurement PO --', Icons.description_outlined),
                      items: poList.map((po) {
                        return DropdownMenuItem<int>(
                          value: po.id,
                          child: Text('PO #${po.poNumber} (Volume: ${po.quantity} Units)', style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: isEdit
                          ? null
                          : (val) {
                              setState(() {
                                poId = val ?? 0;

                                // Filter products matching selected PO's requisition
                                List<ProductResponseModel> newFiltered = allProducts;
                                if (poId != 0 && poList.isNotEmpty) {
                                  final selectedPo = poList.firstWhereOrNull((p) => p.id == poId);
                                  if (selectedPo != null) {
                                    final selectedPr = prList.firstWhereOrNull((r) => r.id == selectedPo.purchaseRequisitionId);
                                    if (selectedPr != null && selectedPr.productIds.isNotEmpty) {
                                      newFiltered = allProducts.where((p) => selectedPr.productIds.contains(p.id)).toList();
                                    }
                                  }
                                }

                                // Reset any line item whose product is not in newFiltered
                                for (int i = 0; i < lineItems.length; i++) {
                                  if (!newFiltered.any((p) => p.id == lineItems[i].productId)) {
                                    lineItems[i] = GRNLineItemRequestModel(
                                      id: lineItems[i].id,
                                      grnId: lineItems[i].grnId,
                                      productId: 0,
                                      quantityOrdered: lineItems[i].quantityOrdered,
                                      quantityReceived: lineItems[i].quantityReceived,
                                    );
                                  }
                                }
                              });
                            },
                      validator: (val) => (val == null || val == 0) ? 'Source PO selection required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. Destination Vault (Warehouse Allocation)
                _buildStepLabel(2, 'DESTINATION VAULT (WAREHOUSE ALLOCATION) *'),
                warehousesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading warehouses: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (warehousesList) {
                    return DropdownButtonFormField<int>(
                      initialValue: warehouseId != 0 && warehousesList.any((w) => w.id == warehouseId) ? warehouseId : null,
                      decoration: _inputDecoration('-- Select Destination Terminal --', Icons.store_outlined),
                      items: warehousesList.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Text('${w.name} (${w.address.isNotEmpty ? w.address : "Central Zone"})', style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => warehouseId = val ?? 0),
                      validator: (val) => (val == null || val == 0) ? 'Destination warehouse required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. Total Received Volume
                _buildStepLabel(3, 'TOTAL RECEIVED VOLUME *'),
                TextFormField(
                  initialValue: receivedQuantity == 0 ? '' : receivedQuantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('e.g. 500', Icons.numbers).copyWith(
                    errorText: receivedQuantityError,
                  ),
                  validator: (val) {
                    final parsed = int.tryParse(val ?? '');
                    if (parsed == null || parsed < 0) return 'Valid qty required';
                    return null;
                  },
                  onSaved: (val) => receivedQuantity = int.tryParse(val ?? '0') ?? 0,
                ),
                const SizedBox(height: 16),

                // 4. Arrival Log Date
                _buildStepLabel(4, 'ARRIVAL LOG DATE *'),
                TextFormField(
                  initialValue: receivedAt,
                  readOnly: true,
                  decoration: _inputDecoration('YYYY-MM-DD', Icons.calendar_today_outlined).copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month, color: AppTheme.primary),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            receivedAt = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                  validator: (val) => (val == null || val.isEmpty) ? 'Arrival date required' : null,
                  onSaved: (val) => receivedAt = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // 5 & 6. Quality Assurance Checkpoints (QC Inspector & Inspection Timestamp)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.info),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_user_outlined, color: AppTheme.indigo, size: 18),
                          SizedBox(width: 6),
                          Text('Quality Assurance Checkpoints', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildStepLabel(5, 'QC AUTHORIZED INSPECTOR'),
                      inspectorsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('Error: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 10)),
                        data: (inspectorsList) {
                          return DropdownButtonFormField<int>(
                            initialValue: inspectedBy,
                            decoration: _inputDecoration('-- Map Inspector --', Icons.person_outline),
                            items: inspectorsList.map((i) {
                              return DropdownMenuItem<int>(
                                value: i.userId,
                                child: Text('${i.name} (${i.role})', style: const TextStyle(fontSize: 11, color: AppTheme.dark)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => inspectedBy = val),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildStepLabel(6, 'INSPECTION TIMESTAMP'),
                      TextFormField(
                        initialValue: inspectionDate ?? '',
                        readOnly: true,
                        decoration: _inputDecoration('YYYY-MM-DD', Icons.event_available_outlined).copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month, color: AppTheme.primary),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setState(() {
                                  inspectionDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                        onSaved: (val) => inspectionDate = val?.trim().isNotEmpty == true ? val?.trim() : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Bulk Item Line Cargo Allocation (Line Items)
                if (!isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bulk Item Line Cargo Allocation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark)),
                            TextButton.icon(
                              onPressed: _addLineItem,
                              icon: const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                              label: const Text('Add Product Row', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (lineItems.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.light,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderGrey, style: BorderStyle.solid),
                            ),
                            child: const Text(
                              'No specific child line-items added yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: AppTheme.secondary),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: lineItems.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = lineItems[index];
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.light,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderGrey),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: DropdownButtonFormField<int>(
                                        isExpanded: true,
                                        initialValue: item.productId != 0 && filteredProducts.any((p) => p.id == item.productId) ? item.productId : null,
                                        decoration: _inputDecoration('Select Product', Icons.inventory_2_outlined).copyWith(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          prefixIcon: const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.secondary),
                                        ),
                                        items: filteredProducts.map((p) {
                                          return DropdownMenuItem<int>(
                                            value: p.id,
                                            child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.dark)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            lineItems[index] = GRNLineItemRequestModel(
                                              id: item.id,
                                              grnId: item.grnId,
                                              productId: val ?? 0,
                                              quantityOrdered: item.quantityOrdered,
                                              quantityReceived: item.quantityReceived,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        initialValue: item.quantityOrdered == 0 ? '' : item.quantityOrdered.toString(),
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration('Ordered Qty', Icons.numbers).copyWith(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                          prefixIcon: const Icon(Icons.numbers, size: 14, color: AppTheme.secondary),
                                        ),
                                        onChanged: (val) {
                                          lineItems[index] = GRNLineItemRequestModel(
                                            id: item.id,
                                            grnId: item.grnId,
                                            productId: item.productId,
                                            quantityOrdered: int.tryParse(val) ?? 0,
                                            quantityReceived: item.quantityReceived,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        initialValue: item.quantityReceived == 0 ? '' : item.quantityReceived.toString(),
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration('Received Qty', Icons.check).copyWith(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                          prefixIcon: const Icon(Icons.check, size: 14, color: AppTheme.primary),
                                        ),
                                        onChanged: (val) {
                                          lineItems[index] = GRNLineItemRequestModel(
                                            id: item.id,
                                            grnId: item.grnId,
                                            productId: item.productId,
                                            quantityOrdered: item.quantityOrdered,
                                            quantityReceived: int.tryParse(val) ?? 0,
                                          );
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _removeLineItem(index),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(Icons.cancel, color: AppTheme.danger, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 8. Operational Remarks
                _buildStepLabel(8, 'OPERATIONAL TERMINAL REMARKS'),
                TextFormField(
                  initialValue: remarks,
                  maxLines: 3,
                  decoration: _inputDecoration('Consignment damage logs, missing parts descriptions...', Icons.notes),
                  onSaved: (val) => remarks = val?.trim() ?? '',
                ),
                const SizedBox(height: 24),

                // 7. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.borderGrey),
                          foregroundColor: AppTheme.dark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppTheme.surfaceWhite, strokeWidth: 2))
                            : const Icon(Icons.cloud_upload_outlined, color: AppTheme.surfaceWhite),
                        label: Text(
                          isEdit ? 'Commit Allocation Ledger' : 'Authorize & Stream Stock',
                          style: const TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepLabel(int stepNum, String text) {
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
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppTheme.secondary),
      filled: true,
      fillColor: AppTheme.surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (poId == 0 || warehouseId == 0 || receivedBy == 0) {
      setState(() => errorMessage = 'Validation Fault: Linked PO Node, Destination Warehouse, and Receiver Context are mandatory.');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
      receivedQuantityError = null;
    });

    final payload = GoodsReceivedNoteRequestModel(
      poId: poId,
      productId: productId,
      receivedQuantity: receivedQuantity,
      receivedBy: receivedBy,
      warehouseId: warehouseId,
      receivedAt: receivedAt,
      status: status,
      remarks: remarks,
      inspectedBy: inspectedBy,
      inspectionDate: inspectionDate,
      lineItems: lineItems,
    );

    bool success = false;
    if (widget.grnToEdit != null) {
      success = await ref.read(goodReceivedNoteControllerProvider.notifier).updateGRN(widget.grnToEdit!.id, payload);
    } else {
      success = await ref.read(goodReceivedNoteControllerProvider.notifier).saveGRN(payload);
    }

    setState(() => isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.grnToEdit != null ? 'Goods Received Note modified cleanly.' : 'New GRN Ledger generated successfully.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => errorMessage = 'Inventory integration exception.');
    }
  }
}