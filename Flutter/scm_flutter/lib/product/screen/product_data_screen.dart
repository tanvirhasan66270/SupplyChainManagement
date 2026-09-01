import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/product/provider/catagory_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/sales_officer/screen/product_form_screen.dart';
import 'package:scm_flutter/system/notification/notification_icon_button.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ProductDataScreen extends ConsumerStatefulWidget {
  const ProductDataScreen({super.key});

  @override
  ConsumerState<ProductDataScreen> createState() => _ProductDataScreenState();
}

class _ProductDataScreenState extends ConsumerState<ProductDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;

  String _resolveImageUrl(String? imgPath) {
    if (imgPath == null || imgPath.trim().isEmpty) return '';
    final trimmed = imgPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/images/')) {
      return '${ApiConstants.imgUrl}${trimmed.substring(8)}';
    }
    if (trimmed.startsWith('images/')) {
      return '${ApiConstants.imgUrl}${trimmed.substring(7)}';
    }
    if (trimmed.startsWith('product/')) {
      return '${ApiConstants.imgUrl}$trimmed';
    }
    return '${ApiConstants.imgUrl}product/$trimmed';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteProduct(BuildContext context, ProductResponseModel prod) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${prod.name}" (${prod.productCode})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = ref.read(productRepositoryProvider);
                await repo.deleteProduct(prod.id);
                ref.invalidate(productListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted successfully!'), backgroundColor: AppTheme.success),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e'), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: const Text(
          'Product Directory & Inventory',
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.dark),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppTheme.primary),
            tooltip: 'Add New Product',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              );
            },
          ),
          const DynamicNotificationButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productListProvider);
          ref.invalidate(categoryListProvider);
        },
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load products: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(productListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (products) {
            final filteredProducts = products.where((prod) {
              final matchesSearch = _searchQuery.isEmpty ||
                  prod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  prod.productCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  prod.unit.toLowerCase().contains(_searchQuery.toLowerCase());

              final matchesCategory = _selectedCategoryId == null || prod.categoryId == _selectedCategoryId;

              return matchesSearch && matchesCategory;
            }).toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Summary Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.dark, AppTheme.indigoDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PRODUCT CATALOG MATRIX',
                              style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Items: ${products.length} Products Available',
                              style: const TextStyle(color: AppTheme.blueLight, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.white,
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by product name, code, SKU...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  categoriesAsync.maybeWhen(
                    data: (categories) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: _selectedCategoryId == null,
                                label: Text('All Products (${products.length})', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _selectedCategoryId == null ? AppTheme.white : AppTheme.dark)),
                                selectedColor: AppTheme.primary,
                                backgroundColor: AppTheme.white,
                                checkmarkColor: AppTheme.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedCategoryId == null ? AppTheme.primary : AppTheme.borderGrey)),
                                onSelected: (_) => setState(() => _selectedCategoryId = null),
                              ),
                            ),
                            ...categories.map((c) {
                              final isSel = _selectedCategoryId == c.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected: isSel,
                                  label: Text(c.categoryName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? AppTheme.white : AppTheme.dark)),
                                  selectedColor: AppTheme.primary,
                                  backgroundColor: AppTheme.white,
                                  checkmarkColor: AppTheme.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSel ? AppTheme.primary : AppTheme.borderGrey)),
                                  onSelected: (_) => setState(() => _selectedCategoryId = c.id),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  // Product Cards Data List
                  if (filteredProducts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.grey),
                          SizedBox(height: 12),
                          Text('No products found.', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Try adjusting your search or category filter.', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final prod = filteredProducts[index];
                        final imageUrl = _resolveImageUrl(prod.image);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderGrey),
                            boxShadow: [
                              BoxShadow(color: AppTheme.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderGrey.withValues(alpha: 0.6)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: AppTheme.primary,
                                              size: 24,
                                            ),
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: AppTheme.primary,
                                            size: 24,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              prod.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.dark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.light,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppTheme.borderGrey),
                                            ),
                                            child: Text(
                                              prod.productCode,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            'Selling: ৳${prod.sellingPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Cost: ৳${prod.unitCost.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 11, color: AppTheme.grey),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Stock: ${prod.quantity} ${prod.unit}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.dark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_note, color: AppTheme.warning, size: 20),
                                      tooltip: 'Edit Product',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => ProductFormScreen(productToEdit: prod)),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                                      tooltip: 'Delete Product',
                                      onPressed: () => _deleteProduct(context, prod),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
