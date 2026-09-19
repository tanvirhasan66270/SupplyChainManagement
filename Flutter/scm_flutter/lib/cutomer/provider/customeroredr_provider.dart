import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/cutomer/data/customerOrder_Repository.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';

final customerOrderRepositoryProvider = Provider<CustomerOrderRepository>((ref) {
  return CustomerOrderRepository(ref.watch(apiClientProvider));
});

final customerOrderListProvider = FutureProvider.autoDispose<List<CustomerOrderResponse>>((ref) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.findAll();
});

final customerOrdersByEmailProvider = FutureProvider.autoDispose<List<CustomerOrderResponse>>((ref) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.getByCustomerEmail();
});

final singleCustomerOrderProvider = FutureProvider.autoDispose.family<CustomerOrderResponse, int>((ref, id) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.getById(id);
});

final trackCustomerOrderProvider = FutureProvider.autoDispose.family<CustomerOrderResponse, String>((ref, orderNumber) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.trackOrderByNumber(orderNumber);
});