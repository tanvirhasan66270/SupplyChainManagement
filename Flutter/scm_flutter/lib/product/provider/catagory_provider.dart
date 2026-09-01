import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/catagory_model.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/product/data/catagory_repository.dart';
import 'package:scm_flutter/product/provider/product_provider.dart';



final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});

/// (GET /api/category)
final categoryListProvider = FutureProvider.autoDispose<List<CategoryResponseModel>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getAll();
});

/// (GET /api/category/public)
final publicCategoryListProvider = FutureProvider.autoDispose<List<CategoryResponseModel>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getAll();
});

// ///(GET /api/category/{id})
// final singleCategoryProvider = FutureProvider.autoDispose.family<CategoryResponseModel, int>((ref, id) async {
//   final repository = ref.watch(categoryRepositoryProvider);
//   return repository.getPro(id);
// });

final productsByCategoryIdProvider = FutureProvider.autoDispose.family<List<ProductResponseModel>, int>((ref, categoryId) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsByCategoryId(categoryId);
});

