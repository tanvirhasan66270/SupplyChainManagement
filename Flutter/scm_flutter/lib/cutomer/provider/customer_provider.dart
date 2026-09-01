import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/helperProvider.dart';
import 'package:scm_flutter/cutomer/data/customerOrder_Repository.dart';
import 'package:scm_flutter/cutomer/data/customer_repository.dart';
import 'package:scm_flutter/entity/customerModel.dart';
import 'package:scm_flutter/entity/customerOrderModel.dart';


// import 'package:scm_flutter/cutomer/data/customer_order_repository.dart';
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(apiClientProvider));
});

final customerOrderRepositoryProvider = Provider<CustomerOrderRepository>((ref) {
  return CustomerOrderRepository(ref.watch(apiClientProvider));
});

final customerListProvider = FutureProvider.autoDispose<List<CustomerResponseModel>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return await repo.getAll();
});

/// The logged-in customer's profile — keyed off the authenticated user's
/// `userId`, mirroring `customerService.findByUserId(this.userId)` in
/// customerdashboard.ts / customer-profile-component.ts.
final currentCustomerProvider =
FutureProvider.autoDispose<CustomerResponseModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role.toUpperCase() != 'CUSTOMER') return null;
  try {
    return await ref.watch(customerRepositoryProvider).findByUserId(user.userId);
  } catch (_) {
    return null;
  }
});

/// Dashboard summary (stats + recent orders) for the current customer.
final customerOrderSummaryProvider =
FutureProvider.autoDispose<({int total, int pending, int active, int completed, int cancelled, List<CustomerOrderResponse> recent})>(
        (ref) async {
      final customer = await ref.watch(currentCustomerProvider.future);
      if (customer?.id == null) {
        return (total: 0, pending: 0, active: 0, completed: 0, cancelled: 0, recent: const <CustomerOrderResponse>[]);
      }

      final orders = await ref
          .watch(customerOrderRepositoryProvider)
          .getByCustomerEmail();

      final total = orders.length;
      final pending = orders.where((o) => o.status == OrderStatus.pending).length;
      final active = orders.where((o) =>
      o.status == OrderStatus.confirmed ||
          o.status == OrderStatus.processing ||
          o.status == OrderStatus.shipped ||
          o.status == OrderStatus.outForDelivery
      ).length;
      final completed = orders.where((o) => o.status == OrderStatus.delivered).length;
      final cancelled = orders.where((o) => o.status == OrderStatus.cancelled).length;

      final sorted = [...orders]
        ..sort((a, b) {
          final cmp = b.createdAt.compareTo(a.createdAt);
          if (cmp != 0) return cmp;
          return b.id.compareTo(a.id);
        });

      return (
        total: total,
        pending: pending,
        active: active,
        completed: completed,
        cancelled: cancelled,
        recent: sorted.take(5).toList(),
      );
    });

/// Full order list for "My Orders" screen or staff Directory view.
final myCustomerOrdersProvider =
FutureProvider.autoDispose<List<CustomerOrderResponse>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user != null && user.role.toUpperCase() != 'CUSTOMER') {
    return ref.watch(customerOrderRepositoryProvider).findAll();
  }
  final customer = await ref.watch(currentCustomerProvider.future);
  if (customer?.id == null) return <CustomerOrderResponse>[];
  return ref.watch(customerOrderRepositoryProvider).getByCustomerEmail();
});

/// Get Single Order By ID (GET /api/customerOrders/{id})
final singleOrderProvider = FutureProvider.autoDispose.family<CustomerOrderResponse, int>((ref, orderId) async {
  final repository = ref.watch(customerOrderRepositoryProvider);
  return repository.getById(orderId);
});
