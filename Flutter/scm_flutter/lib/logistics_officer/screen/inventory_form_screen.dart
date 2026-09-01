import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/inventory_model.dart';
import 'package:scm_flutter/logistics_officer/provider/inventory_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/warehouse_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class InventoryFormScreen extends ConsumerStatefulWidget {
  const InventoryFormScreen({super.key, this.inventoryToEdit});

  final InventoryResponseModel? inventoryToEdit;

  @override
  ConsumerState<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int productId = 0;
  int warehouseId = 0;
  int quantityOnHand = 0;
  int quantityReserved = 0;
  String locationStatus = '';
  String expiryDate = '';
  String stockStatus = StockStatus.inStock;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.inventoryToEdit != null) {
      final i = widget.inventoryToEdit!;
      productId = i.productId;
      warehouseId = i.warehouseId;
      quantityOnHand = i.quantityOnHand;
      quantityReserved = i.quantityReserved;
      locationStatus = i.locationStatus;
      expiryDate = i.expiryDate;
      stockStatus = i.stockStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.inventoryToEdit != null;
    final productsAsync = ref.watch(productListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modify Storage Variables' : 'Allocate Inventory Ledger',
          style: const TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
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
                // Header Banner Box
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
                      const Icon(Icons.layers, color: AppTheme.surfaceWhite, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Inventory Control Vector',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Manage stock levels, location placement, and safety thresholds',
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

                // 1. Target Product Selector
                _buildStepLabel(1, 'TARGET CARGO PRODUCT MATERIAL *'),
                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading products: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (products) {
                    return DropdownButtonFormField<int>(
                      initialValue: productId != 0 && products.any((p) => p.id == productId) ? productId : null,
                      decoration: _inputDecoration('Select Catalog Product Vector', Icons.inventory_2_outlined),
                      items: products.map((p) {
                        return DropdownMenuItem<int>(
                          value: p.id,
                          child: Text('${p.name} (Code: ${p.productCode})', style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: isEdit ? null : (val) => setState(() => productId = val ?? 0),
                      validator: (val) => (val == null || val == 0) ? 'Product selection required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. Storage Warehouse Selector
                _buildStepLabel(2, 'OPERATIONAL STORAGE WAREHOUSE NODE *'),
                warehousesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading warehouses: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (warehouses) {
                    return DropdownButtonFormField<int>(
                      initialValue: warehouseId != 0 && warehouses.any((w) => w.id == warehouseId) ? warehouseId : null,
                      decoration: _inputDecoration('Select Storage Warehouse Location', Icons.store),
                      items: warehouses.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Text(w.name, style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: isEdit ? null : (val) => setState(() => warehouseId = val ?? 0),
                      validator: (val) => (val == null || val == 0) ? 'Warehouse selection required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. Quantity On Hand
                _buildStepLabel(3, 'QUANTITY ON HAND *'),
                TextFormField(
                  initialValue: quantityOnHand.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('100', Icons.onetwothree),
                  validator: (val) {
                    final parsed = int.tryParse(val ?? '');
                    if (parsed == null || parsed < 0) return 'Valid qty required';
                    return null;
                  },
                  onSaved: (val) => quantityOnHand = int.tryParse(val ?? '0') ?? 0,
                ),
                const SizedBox(height: 16),

                // 4. Quantity Reserved
                _buildStepLabel(4, 'QUANTITY RESERVED *'),
                TextFormField(
                  initialValue: quantityReserved.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('15', Icons.bookmark_border),
                  validator: (val) {
                    final parsed = int.tryParse(val ?? '');
                    if (parsed == null || parsed < 0) return 'Valid reserved required';
                    return null;
                  },
                  onSaved: (val) => quantityReserved = int.tryParse(val ?? '0') ?? 0,
                ),
                const SizedBox(height: 16),

                // 5. Warehouse Placement (Location Status)
                _buildStepLabel(5, 'WAREHOUSE RACK / ROW LOCATION STATUS'),
                TextFormField(
                  initialValue: locationStatus,
                  decoration: _inputDecoration('e.g. Rack-B3, Row-4', Icons.pin_drop_outlined),
                  onSaved: (val) => locationStatus = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // 6. Expiration Date
                _buildStepLabel(6, 'BATCH EXPIRATION BOUNDARY DATE'),
                TextFormField(
                  initialValue: expiryDate,
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
                            expiryDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                  onSaved: (val) => expiryDate = val?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // 7. Stock Status Dropdown
                _buildStepLabel(7, 'STOCK TRACKING STATUS *'),
                DropdownButtonFormField<String>(
                  initialValue: stockStatus,
                  decoration: _inputDecoration('Select Stock Status', Icons.shield_outlined),
                  items: const [
                    DropdownMenuItem(value: StockStatus.inStock, child: Text('IN_STOCK', style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: StockStatus.lowStock, child: Text('LOW_STOCK', style: TextStyle(fontSize: 12, color: AppTheme.warning, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: StockStatus.outOfStock, child: Text('OUT_OF_STOCK', style: TextStyle(fontSize: 12, color: AppTheme.danger, fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (val) => setState(() => stockStatus = val ?? StockStatus.inStock),
                ),
                const SizedBox(height: 28),

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
                            : const Icon(Icons.check_circle_outline, color: AppTheme.surfaceWhite),
                        label: Text(
                          isEdit ? 'Update Stock Coordinates' : 'Commit Stock Ledger',
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

    if (productId == 0 || warehouseId == 0) {
      setState(() => errorMessage = 'Validation Fault: Targeted Product and Warehouse Node must be specified.');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final payload = InventoryRequestModel(
      productId: productId,
      warehouseId: warehouseId,
      quantityOnHand: quantityOnHand,
      quantityReserved: quantityReserved,
      locationStatus: locationStatus,
      expiryDate: expiryDate.isNotEmpty ? expiryDate : null,
      stockStatus: stockStatus,
    );

    bool success = false;
    if (widget.inventoryToEdit != null) {
      success = await ref.read(inventoryControllerProvider.notifier).updateInventory(widget.inventoryToEdit!.id, payload);
    } else {
      success = await ref.read(inventoryControllerProvider.notifier).createInventory(payload);
    }

    setState(() => isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.inventoryToEdit != null ? 'Inventory Stock metrics updated successfully.' : 'New Stock record committed successfully.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => errorMessage = 'Failed to commit stock ledger entry.');
    }
  }
}