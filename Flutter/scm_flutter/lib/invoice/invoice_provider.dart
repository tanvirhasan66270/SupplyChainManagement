// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:scm_flutter/auth/helperProvider.dart';
// import 'package:scm_flutter/entity/invoiceModel.dart';
// import 'package:scm_flutter/invoice/invoice_repository.dart';
//
//
// ///  InvoiceRepository
// final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
//   return InvoiceRepository(ref.watch(apiClientProvider));
// });
//
// /// (GET /api/invoices)
// final invoiceListProvider = FutureProvider.autoDispose<List<InvoiceResponseModel>>((ref) async {
//   final repository = ref.watch(invoiceRepositoryProvider);
//   return repository.getAllInvoices();
// });
//
// /// (GET /api/invoices/{id})
// final singleInvoiceProvider = FutureProvider.autoDispose.family<InvoiceResponseModel, int>((ref, id) async {
//   final repository = ref.watch(invoiceRepositoryProvider);
//   return repository.getInvoiceById(id);
// });
//
//
