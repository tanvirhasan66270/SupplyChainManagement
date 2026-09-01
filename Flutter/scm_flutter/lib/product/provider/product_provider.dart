import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/product/data/product_repository.dart';


final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(apiClientProvider));
});


///(All Products)
final productListProvider = FutureProvider.autoDispose<List<ProductResponseModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getAll();
});


///(Single Product By ID)
final singleProductProvider = FutureProvider.autoDispose.family<ProductResponseModel, int>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});