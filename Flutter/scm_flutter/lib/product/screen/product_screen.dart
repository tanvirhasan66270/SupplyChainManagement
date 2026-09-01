import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/product/provider/catagory_provider.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  int selectedCategoryIndex = 0;
  String searchQuery = '';
  int? selectedCategoryId;

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
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    final productsAsync = selectedCategoryId == null
        ? ref.watch(productListProvider)
        : ref.watch(productsByCategoryIdProvider(selectedCategoryId!));

    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Marketplace',
              style: TextStyle(color: AppTheme.dark, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Browse corporate products, review pricing, and place allocations.',
              style: TextStyle(color: AppTheme.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.dark),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.dark),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: AppTheme.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search products, categories...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                      filled: true,
                      fillColor: AppTheme.surfaceWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: AppTheme.dark),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Category ListView
          SizedBox(
            height: 45,
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length + 1, // +1 for "All Products"
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final categoryName = isAll ? 'All Products' : categories[index - 1].categoryName;
                    final catId = isAll ? null : categories[index - 1].id;
                    final isSelected = selectedCategoryIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(categoryName),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.dark,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: AppTheme.surfaceWhite,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategoryIndex = index;
                            selectedCategoryId = catId;
                          });
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (err, st) => const SizedBox(),
            ),
          ),
          const SizedBox(height: 8),

          // Product Grid View
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filteredProducts = products.where((p) =>
                p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    p.productCode.toLowerCase().contains(searchQuery.toLowerCase())
                ).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductCard(product, index + 1);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // Card Design
  Widget _buildProductCard(ProductResponseModel product, int indexNumber) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/product-details', arguments: product);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: () {
                      final imageUrl = _resolveImageUrl(product.image);
                      return imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const Icon(Icons.image, size: 40, color: AppTheme.grey))
                          : const Icon(Icons.image_not_supported, size: 40, color: AppTheme.grey);
                    }(),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.dark.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('#$indexNumber', style: const TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.infoLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ELECTRONICS', style: TextStyle(color: AppTheme.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.dark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.productCode,
                      style: const TextStyle(color: AppTheme.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price:', style: TextStyle(color: AppTheme.grey, fontSize: 10)),
                        Text(
                          '৳${product.sellingPrice.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.borderGrey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/product-details', arguments: product);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('View Details', style: TextStyle(color: AppTheme.primary, fontSize: 11)),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 14, color: AppTheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}