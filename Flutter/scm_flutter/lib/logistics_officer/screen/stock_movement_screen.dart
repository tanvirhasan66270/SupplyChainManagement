import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/stock_movement.dart';
import 'package:scm_flutter/logistics_officer/provider/inventory_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/stock_movement_provider.dart';
import 'package:scm_flutter/logistics_officer/provider/warehouse_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key});

  @override
  ConsumerState<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int productId = 0;
  int warehouseId = 0;
  int? sourceWarehouseId;
  String movementType = 'INWARD';
  int quantity = 0;
  String referenceId = '';
  String remarks = '';

  bool isSaving = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.userId ?? 0;

    final inventoriesAsync = ref.watch(inventoryListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);
    final productsAsync = ref.watch(productListProvider);

    final stocks = inventoriesAsync.value ?? [];

    final matchedStock = stocks.firstWhereOrNull(
      (s) => s.productId == productId,
    );
    final availableQtyStr = productId == 0
        ? 'Select a product to view available stock...'
        : '${matchedStock?.availableQuantity ?? matchedStock?.quantityOnHand ?? 0} Units Available';

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Log Stock Transaction',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
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
                // Top Header Banner Box
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
                      const Icon(Icons.swap_horiz, color: AppTheme.surfaceWhite, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Record Stock Movement',
                              style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Log inbound, outbound, or inter-warehouse transfer transactions',
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

                // 1. Movement Type Dropdown
                _buildLabel('OPERATION PROCESS TYPE *'),
                DropdownButtonFormField<String>(
                  initialValue: movementType,
                  decoration: _inputDecoration('Select Movement Type', Icons.download_outlined),
                  items: const [
                    DropdownMenuItem(value: 'INWARD', child: Text('📥 INWARD (Vendor Receipt/GRN)', style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'OUTWARD', child: Text('📤 OUTWARD (Customer Dispatch/Sales)', style: TextStyle(fontSize: 12, color: AppTheme.danger, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'TRANSFER', child: Text('🔄 TRANSFER (Inter-Warehouse Shift)', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'ADJUSTMENT', child: Text('⚙️ ADJUSTMENT (Audit / Damage Balancing)', style: TextStyle(fontSize: 12, color: AppTheme.warning, fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (val) => setState(() => movementType = val ?? 'INWARD'),
                ),
                const SizedBox(height: 16),

                // 2. Select Product Material
                _buildLabel('SELECT PRODUCT MATERIAL *'),
                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading products: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (productsList) {
                    return DropdownButtonFormField<int>(
                      initialValue: productId != 0 && productsList.any((p) => p.id == productId) ? productId : null,
                      decoration: _inputDecoration('-- Choose SCM Catalog Product --', Icons.inventory_2_outlined),
                      items: productsList.map((p) {
                        return DropdownMenuItem<int>(
                          value: p.id,
                          child: Text('${p.name} (Code: ${p.productCode})', style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          productId = val ?? 0;
                          final match = stocks.firstWhereOrNull((s) => s.productId == productId);
                          if (match != null) {
                            warehouseId = match.warehouseId;
                          }
                        });
                      },
                      validator: (val) => (val == null || val == 0) ? 'Product selection required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. Available Stock Quantity Display
                _buildLabel('AVAILABLE STOCK QUANTITY'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        availableQtyStr,
                        style: const TextStyle(fontSize: 12, color: AppTheme.tealPrimary, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.copy_outlined, size: 18, color: AppTheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Source Warehouse Node (Required for TRANSFER)
                if (movementType == 'TRANSFER') ...[
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
                        _buildLabel('SOURCE WAREHOUSE NODE (FROM) *'),
                        warehousesAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => Text('Error loading warehouses: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                          data: (warehousesList) {
                            if (sourceWarehouseId == null && warehousesList.isNotEmpty) {
                              int? matchedId;
                              if (currentUser?.hubId != null) {
                                final found = warehousesList.firstWhereOrNull((w) => w.id == currentUser!.hubId);
                                if (found != null) matchedId = found.id;
                              }
                              final hubName = currentUser?.hubName;
                              if (matchedId == null && hubName != null && hubName.isNotEmpty) {
                                final found = warehousesList.firstWhereOrNull((w) => w.name.toLowerCase().contains(hubName.toLowerCase()));
                                if (found != null) matchedId = found.id;
                              }
                              matchedId ??= warehousesList.first.id;
                              sourceWarehouseId = matchedId;
                            }

                            final sourceWh = warehousesList.firstWhereOrNull((w) => w.id == sourceWarehouseId);
                            final sourceWhName = sourceWh?.name ?? currentUser?.hubName ?? 'Assigned Warehouse Node';

                            return TextFormField(
                              key: ValueKey(sourceWhName),
                              readOnly: true,
                              initialValue: sourceWhName,
                              decoration: _inputDecoration('Source Warehouse', Icons.warehouse_outlined),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.dark),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Target Destination Warehouse Node
                _buildLabel(
                  movementType == 'OUTWARD'
                      ? 'EXTERNAL DESTINATION WAREHOUSE *'
                      : (movementType == 'TRANSFER' ? 'DESTINATION WAREHOUSE NODE (TO) *' : 'TARGET WAREHOUSE NODE *'),
                ),
                warehousesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading warehouses: $err', style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
                  data: (warehousesList) {
                    return DropdownButtonFormField<int>(
                      initialValue: warehouseId != 0 && warehousesList.any((w) => w.id == warehouseId) ? warehouseId : null,
                      decoration: _inputDecoration('-- Choose Destination Facility --', Icons.store),
                      items: warehousesList.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Text(w.name, style: const TextStyle(fontSize: 12, color: AppTheme.dark)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => warehouseId = val ?? 0),
                      validator: (val) => (val == null || val == 0) ? 'Destination warehouse required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 6. Row: Movement Quantity & Reference Identifier
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('MOVEMENT QUANTITY *'),
                          TextFormField(
                            initialValue: quantity == 0 ? '' : quantity.toString(),
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('e.g. 50', Icons.numbers),
                            validator: (val) {
                              final parsed = int.tryParse(val ?? '');
                              if (parsed == null || parsed <= 0) return 'Quantity must be >= 1';
                              return null;
                            },
                            onSaved: (val) => quantity = int.tryParse(val ?? '0') ?? 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('REFERENCE IDENTIFIER *'),
                          TextFormField(
                            initialValue: referenceId,
                            decoration: _inputDecoration('e.g. GRN-994, INV-12', Icons.confirmation_number_outlined),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Reference required' : null,
                            onSaved: (val) => referenceId = val?.trim() ?? '',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7. System Audit Remarks
                _buildLabel('SYSTEM AUDIT REMARKS'),
                TextFormField(
                  initialValue: remarks,
                  maxLines: 3,
                  decoration: _inputDecoration('Log cause of movement or operation variables...', Icons.notes),
                  onSaved: (val) => remarks = val?.trim() ?? '',
                ),
                const SizedBox(height: 24),

                // 8. Action Buttons
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
                        onPressed: isSaving ? null : () => _submitMovement(currentUserId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppTheme.surfaceWhite, strokeWidth: 2))
                            : const Icon(Icons.cloud_upload, color: AppTheme.surfaceWhite),
                        label: const Text(
                          'Log Stock Transaction',
                          style: TextStyle(color: AppTheme.surfaceWhite, fontWeight: FontWeight.bold),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary, letterSpacing: 0.3),
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

  Future<void> _submitMovement(int currentUserId) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (productId == 0 || warehouseId == 0) {
      setState(() => errorMessage = 'Validation Fault: Product specs and Target Warehouse node must be assigned.');
      return;
    }

    if (sourceWarehouseId != null && warehouseId == sourceWarehouseId) {
      setState(() => errorMessage = 'Business Conflict: Source warehouse and Target destination warehouse cannot be identical.');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final payload = StockMovementRequestModel(
      productId: productId,
      warehouseId: warehouseId,
      sourceWarehouseId: movementType == 'TRANSFER' ? sourceWarehouseId : null,
      movementType: movementType,
      quantity: quantity,
      referenceId: referenceId,
      performedBy: currentUserId,
      remarks: remarks,
    );

    final success = await ref.read(stockMovementControllerProvider.notifier).logMovement(payload);

    setState(() => isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock Movement Transaction Logged successfully.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => errorMessage = 'Failed to log stock movement transaction.');
    }
  }
}