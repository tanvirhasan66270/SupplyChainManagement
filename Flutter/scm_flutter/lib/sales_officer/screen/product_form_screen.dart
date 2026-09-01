import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scm_flutter/entity/catagory_model.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/product/provider/catagory_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/product/screen/product_data_screen.dart';
import 'package:scm_flutter/them/allAppThim.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productToEdit});

  final ProductResponseModel? productToEdit;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String productName;
  late String productCode;
  int? categoryId;
  late double unitCost;
  late double sellingPrice;
  late int quantity;
  late String unitType;
  bool _isLoading = false;

  File? selectedFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    productName = p?.name ?? '';
    productCode = p?.productCode ?? 'PRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    categoryId = p?.categoryId;
    unitCost = p?.unitCost ?? 0.0;
    sellingPrice = p?.sellingPrice ?? 0.0;
    quantity = p?.quantity ?? 0;
    unitType = p?.unit ?? 'PCS';
  }

  Future<void> _pickFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
      });
    }
  }

  Future<void> _submitForm(List<CategoryResponseModel> categories) async {
    if (!_formKey.currentState!.validate()) return;
    if (categoryId == null && categories.isNotEmpty) {
      categoryId = categories.first.id;
    }
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a category first!'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(productRepositoryProvider);
      MultipartFile? imgFile;
      if (selectedFile != null) {
        imgFile = await MultipartFile.fromFile(selectedFile!.path, filename: selectedFile!.path.split('/').last);
      }

      final dto = ProductRequestModel(
        id: widget.productToEdit?.id ?? 0,
        productCode: productCode.trim().isNotEmpty ? productCode.trim() : 'PRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: productName.trim(),
        unit: unitType,
        reorderPoint: widget.productToEdit?.reorderPoint ?? 10,
        unitCost: unitCost,
        quantity: quantity,
        sellingPrice: sellingPrice,
        hasExpiryDate: widget.productToEdit?.hasExpiryDate ?? 'NO',
        weight: widget.productToEdit?.weight ?? 1.0,
        isActive: widget.productToEdit?.isActive ?? true,
        availability: widget.productToEdit?.availability ?? 'IN_STOCK',
        image: widget.productToEdit?.image ?? '',
        categoryId: categoryId!,
      );

      if (widget.productToEdit != null) {
        await repo.updateProduct(widget.productToEdit!.id, dto, imageFile: imgFile);
      } else {
        await repo.addProduct(dto, imageFile: imgFile);
      }

      ref.invalidate(productListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productToEdit != null
                ? 'Product updated successfully!'
                : 'Product published successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;
    const primaryGreen = AppTheme.primary;
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.value ?? [];

    if (categoryId == null && categories.isNotEmpty) {
      categoryId = categories.first.id;
    }

    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        child: Column(
          children: [
            // Top Green Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: primaryGreen,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: AppTheme.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isEdit ? 'Modify Product Core' : 'Register New Product Core',
                            style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.white,
                      side: BorderSide(color: AppTheme.white.withValues(alpha: 0.7)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.list_alt, size: 14),
                    label: const Text('View All Products', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductDataScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      _buildLabel('PRODUCT NAME', Icons.local_offer_outlined, primaryGreen),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: productName,
                        decoration: _inputDecoration(primaryGreen).copyWith(
                          hintText: 'Enter product name...',
                          prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppTheme.secondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Product name is required!' : null,
                        onChanged: (val) => productName = val,
                      ),
                      const SizedBox(height: 16),

                      // Code & Category
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('PRODUCT CODE / SKU', Icons.qr_code, primaryGreen),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: productCode,
                                  decoration: _inputDecoration(primaryGreen),
                                  onChanged: (val) => productCode = val,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 _buildLabel('CATEGORY', Icons.category_outlined, primaryGreen),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  initialValue: categoryId,
                                  decoration: _inputDecoration(primaryGreen),
                                  hint: const Text('Select Category', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                  items: categories.map((c) => DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(c.categoryName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (val) => setState(() => categoryId = val),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Unit Cost & Selling Price
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('UNIT COST (৳)', Icons.attach_money, primaryGreen),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: unitCost.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(primaryGreen),
                                  onChanged: (val) => unitCost = double.tryParse(val) ?? 0.0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('SELLING PRICE (৳)', Icons.sell_outlined, primaryGreen),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: sellingPrice.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(primaryGreen),
                                  onChanged: (val) => sellingPrice = double.tryParse(val) ?? 0.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quantity & Unit Type
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('QUANTITY', Icons.format_list_numbered, primaryGreen),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: quantity.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(primaryGreen),
                                  onChanged: (val) => quantity = int.tryParse(val) ?? 0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('UNIT TYPE', Icons.layers_outlined, primaryGreen),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: unitType,
                                  decoration: _inputDecoration(primaryGreen),
                                  items: const [
                                    DropdownMenuItem(value: 'PCS', child: Text('PCS', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'KG', child: Text('KG', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'BOX', child: Text('BOX', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  ],
                                  onChanged: (val) => setState(() => unitType = val ?? 'PCS'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image Upload
                      _buildLabel('PRODUCT IMAGE', Icons.image_outlined, primaryGreen),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.light,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.borderGrey),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.image_outlined, size: 16, color: primaryGreen),
                                    SizedBox(width: 4),
                                    Text('Choose File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFile?.path.split('/').last ?? 'No file chosen',
                                  style: TextStyle(fontSize: 12, color: selectedFile != null ? AppTheme.dark : AppTheme.secondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Footer Action Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _submitForm(categories),
                              icon: _isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.cloud_upload_outlined, size: 18),
                              label: Text(_isLoading ? 'Publishing...' : 'Publish Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppTheme.borderGrey),
                                foregroundColor: primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
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

  Widget _buildLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.dark, letterSpacing: 0.5),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(Color focusColor) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: focusColor, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      isDense: true,
      filled: true,
      fillColor: AppTheme.surfaceWhite,
    );
  }
}