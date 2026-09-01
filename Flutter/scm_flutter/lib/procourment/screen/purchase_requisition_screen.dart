import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/entity/supplier_model.dart';
import 'package:scm_flutter/procourment/provider/purchase_requisition_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/suppplier/provider/supplier_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/widget/dynamic_scm_top_nav_bar.dart';

class PurchaseRequisitionScreen extends ConsumerStatefulWidget {
  const PurchaseRequisitionScreen({super.key});

  @override
  ConsumerState<PurchaseRequisitionScreen> createState() => _PurchaseRequisitionScreenState();
}

class _PurchaseRequisitionScreenState extends ConsumerState<PurchaseRequisitionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State selections
  final List<int> _selectedProductIds = [];
  final List<int> _selectedSupplierIds = [];
  int _quantityRequired = 1;
  String _urgencyLevel = UrgencyLevel.low;
  DateTime? _selectedDate;

  late TextEditingController _quantityController;
  late TextEditingController _dateController;
  late TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _dateController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _dateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedProductIds.clear();
      _selectedSupplierIds.clear();
      _quantityRequired = 1;
      _quantityController.text = '1';
      _urgencyLevel = UrgencyLevel.low;
      _selectedDate = null;
      _dateController.clear();
      _remarksController.clear();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productListProvider);
    final supplierListAsync = ref.watch(supplierListProvider);

    final List<ProductResponseModel> products = productListAsync.value ?? [];
    final List<SupplierResponseDTO> suppliers = supplierListAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header Navigation Bar (Fully Dynamic) ──
            DynamicScmTopNavBar(
              onRefresh: () {
                ref.invalidate(productListProvider);
                ref.invalidate(supplierListProvider);
              },
            ),

            // ── Blue Banner Header Card ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Purchase Requisition',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.only(left: 28.0),
                          child: Text(
                            'Create and dispatch new purchase requisition',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/purchase-requisitions');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.list_alt, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'View All',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.description_outlined, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form Scrollable Area ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. PRODUCT SPECIFICATION VECTOR ──
                      _buildNumberedStepLabel(1, 'PRODUCT SPECIFICATION VECTOR *'),
                      _buildProductDropdown(products),
                      const SizedBox(height: 8),
                      _buildProductChipsStack(products),
                      const SizedBox(height: 16),

                      // ── 2. TARGET PREFERRED SUPPLIER ROUTING NODES ──
                      _buildNumberedStepLabel(2, 'TARGET PREFERRED SUPPLIER ROUTING NODES'),
                      _buildSupplierDropdown(suppliers, supplierListAsync.isLoading),
                      const SizedBox(height: 8),
                      _buildSupplierChipsStack(suppliers),
                      const SizedBox(height: 16),

                      // ── 3. REQUIRED CONSIGNMENT UNITS ──
                      _buildNumberedStepLabel(3, 'REQUIRED CONSIGNMENT UNITS *'),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        decoration: _inputDecoration(icon: Icons.format_list_numbered),
                        onChanged: (val) {
                          _quantityRequired = int.tryParse(val) ?? 1;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── 4. URGENCY STRATUM LEVEL ──
                      _buildNumberedStepLabel(4, 'URGENCY STRATUM LEVEL *'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _urgencyLevel,
                        decoration: _inputDecoration(icon: Icons.warning_amber_rounded),
                        items: const [
                          DropdownMenuItem(value: 'LOW', child: Text('LOW Urgency', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM Pipeline', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'HIGH', child: Text('HIGH Accelerated', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'CRITICAL', child: Text('CRITICAL Vector', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _urgencyLevel = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── 5. TARGET REQUIRED DATE DEADLINE ──
                      _buildNumberedStepLabel(5, 'TARGET REQUIRED DATE DEADLINE'),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        decoration: _inputDecoration(icon: Icons.calendar_today_outlined, hintText: 'mm/dd/yyyy'),
                      ),
                      const SizedBox(height: 16),

                      // ── 6. CURRENCY SETTLEMENT ──
                      _buildNumberedStepLabel(6, 'CURRENCY SETTLEMENT'),
                      TextFormField(
                        enabled: false,
                        initialValue: 'USD (\$) Fixed Gateway',
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                        decoration: _inputDecoration(icon: Icons.attach_money),
                      ),
                      const SizedBox(height: 16),

                      // ── 7. SPECIAL REQUISITION DIRECTIVES & REMARKS ──
                      _buildNumberedStepLabel(7, 'SPECIAL REQUISITION DIRECTIVES & REMARKS'),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Input logistics reasonings context...',
                          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                          contentPadding: const EdgeInsets.all(12),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 6. Action Buttons (Clear & Dispatch) ──
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              onPressed: _resetForm,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('CLEAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _submitRequisition,
                              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                              label: const Text('DISPATCH REQUISITION NODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // Helper Widget for Section Labels
  Widget _buildNumberedStepLabel(int stepNum, String label) {
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
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon, String? hintText}) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Dynamic Product Dropdown Widget
  Widget _buildProductDropdown(List<ProductResponseModel> products) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        hint: const Text('-- Select Product or Requirement --', style: TextStyle(fontSize: 12, color: Colors.grey)),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB), size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        items: products.map((p) {
          final isSelected = _selectedProductIds.contains(p.id);
          final catLabel = p.categoryName.isNotEmpty ? ' (${p.categoryName})' : '';
          return DropdownMenuItem<int>(
            value: p.id,
            enabled: !isSelected,
            child: Text(
              '${p.name}$catLabel',
              style: TextStyle(fontSize: 12, color: isSelected ? Colors.grey : Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null && !_selectedProductIds.contains(val)) {
            setState(() {
              _selectedProductIds.add(val);
            });
          }
        },
      ),
    );
  }

  // Dynamic Product Chips Stack Widget
  Widget _buildProductChipsStack(List<ProductResponseModel> products) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _selectedProductIds.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Text('Selected item chips stack here...', style: TextStyle(color: Colors.grey, fontSize: 11)),
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedProductIds.map((pId) {
                final prod = products.firstWhere(
                  (p) => p.id == pId,
                  orElse: () => ProductResponseModel(
                    id: pId,
                    productCode: 'PROD-$pId',
                    name: 'Product #$pId',
                    unit: 'PCS',
                    reorderPoint: 0,
                    unitCost: 0,
                    quantity: 0,
                    sellingPrice: 0,
                    hasExpiryDate: 'NO',
                    weight: 0,
                    isActive: true,
                    availability: 'IN_STOCK',
                    image: '',
                    categoryId: 0,
                    categoryName: '',
                  ),
                );
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(prod.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProductIds.remove(pId);
                          });
                        },
                        child: const Icon(Icons.cancel, color: Colors.amber, size: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // Dynamic Supplier Dropdown Widget
  Widget _buildSupplierDropdown(List<SupplierResponseDTO> suppliers, bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        hint: isLoading
            ? const Text('Loading suppliers...', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)))
            : (suppliers.isEmpty
                ? const Text('No suppliers found in system', style: TextStyle(fontSize: 12, color: Colors.red))
                : const Text('-- Select Supplier to Add --', style: TextStyle(fontSize: 12, color: Colors.grey))),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.business_outlined, color: Color(0xFF2563EB), size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        items: suppliers.map((s) {
          final isSelected = _selectedSupplierIds.contains(s.id);
          return DropdownMenuItem<int>(
            value: s.id,
            enabled: !isSelected,
            child: Text(
              s.name,
              style: TextStyle(fontSize: 12, color: isSelected ? Colors.grey : Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null && !_selectedSupplierIds.contains(val)) {
            setState(() {
              _selectedSupplierIds.add(val);
            });
          }
        },
      ),
    );
  }

  // Dynamic Supplier Chips Stack Widget
  Widget _buildSupplierChipsStack(List<SupplierResponseDTO> suppliers) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _selectedSupplierIds.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Text('Selected vendor chips stack here...', style: TextStyle(color: Colors.grey, fontSize: 11)),
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedSupplierIds.map((sId) {
                final supp = suppliers.firstWhere(
                  (s) => s.id == sId,
                  orElse: () => SupplierResponseDTO(
                    id: sId,
                    userId: 0,
                    name: 'Supplier #$sId',
                    email: '',
                    phone: '',
                    role: 'SUPPLIER',
                    contactPerson: '',
                    address: '',
                    nidNumber: '',
                    passportNumber: '',
                    gender: '',
                    dob: '',
                    image: '',
                    rating: 0.0,
                    averageLeadTimeDays: 0,
                    createdAt: '',
                    updatedAt: '',
                    policeStationId: 0,
                    policeStationName: '',
                    districtName: '',
                    divisionName: '',
                  ),
                );
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(supp.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSupplierIds.remove(sId);
                          });
                        },
                        child: const Icon(Icons.cancel, color: Colors.amber, size: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // Form Submission Logic
  Future<void> _submitRequisition() async {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validation Error: Please select at least one product specification node.')),
      );
      return;
    }

    if (_selectedSupplierIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validation Error: Please select at least one target supplier routing node.')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final requestedById = currentUser?.userId ?? 1;

    final formattedDate = _dateController.text.isNotEmpty
        ? _dateController.text
        : "${DateTime.now().add(const Duration(days: 7)).year}-${DateTime.now().add(const Duration(days: 7)).month.toString().padLeft(2, '0')}-${DateTime.now().add(const Duration(days: 7)).day.toString().padLeft(2, '0')}";

    final request = PurchaseRequisitionRequest(
      requestedBy: requestedById,
      productIds: List.from(_selectedProductIds),
      supplierIds: List.from(_selectedSupplierIds),
      currency: 'USD',
      quantityRequired: _quantityRequired,
      urgencyLevel: _urgencyLevel,
      requiredByDate: formattedDate,
      remarks: _remarksController.text.trim(),
    );

    final success = await ref
        .read(purchaseRequisitionControllerProvider.notifier)
        .saveRequisition(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Purchase Requisition dispatched successfully to cluster registry!'),
        ),
      );
      Navigator.pop(context);
    }
  }
}