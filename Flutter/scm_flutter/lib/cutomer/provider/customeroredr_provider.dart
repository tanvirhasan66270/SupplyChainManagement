import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/cutomer/data/customerOrder_Repository.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';

/// CustomerOrderRepository প্
final customerOrderRepositoryProvider = Provider<CustomerOrderRepository>((ref) {
  return CustomerOrderRepository(ref.watch(apiClientProvider));
});

/// (GET /api/customerOrders)
final customerOrderListProvider = FutureProvider.autoDispose<List<CustomerOrderResponse>>((ref) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.findAll();
});

/// (GET /api/customerOrders/customer)
final customerOrdersByEmailProvider = FutureProvider.autoDispose<List<CustomerOrderResponse>>((ref) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.getByCustomerEmail();
});

///  (GET /api/customerOrders/{id})
final singleCustomerOrderProvider = FutureProvider.autoDispose.family<CustomerOrderResponse, int>((ref, id) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.getById(id);
});

/// (GET /api/customerOrders/track)
final trackCustomerOrderProvider = FutureProvider.autoDispose.family<CustomerOrderResponse, String>((ref, orderNumber) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.trackOrderByNumber(orderNumber);
});