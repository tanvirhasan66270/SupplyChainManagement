// import 'package:dio/dio.dart';
// import 'package:scm_flutter/entity/invoiceModel.dart';
//
// import 'package:scm_flutter/util/apiConstants.dart';
//
// class InvoiceRepository {
//   InvoiceRepository(this._apiClient);
//
//   final dynamic _apiClient;
//   Dio get _dio => _apiClient.dio;
//
//   ///(POST /api/invoices)
//   Future<InvoiceResponseModel> createInvoice(InvoiceRequestModel dto) async {
//     final res = await _dio.post(ApiConstants.invoices, data: dto.toJson());
//     return InvoiceResponseModel.fromJson(res.data as Map<String, dynamic>);
//   }
//
//   ///(GET /api/invoices)
//   Future<List<InvoiceResponseModel>> getAllInvoices() async {
//     final res = await _dio.get(ApiConstants.invoices);
//     if (res.statusCode == 204 || res.data == null) return [];
//     return (res.data as List)
//         .map((e) => InvoiceResponseModel.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }
//
//   ///(GET /api/invoices/{id})
//   Future<InvoiceResponseModel> getInvoiceById(int id) async {
//     final res = await _dio.get(ApiConstants.invoiceById(id));
//     return InvoiceResponseModel.fromJson(res.data as Map<String, dynamic>);
//   }
//
//   ///(PUT /api/invoices/{id})
//   Future<InvoiceResponseModel> updateInvoice(int id, InvoiceRequestModel dto) async {
//     final res = await _dio.put(ApiConstants.invoiceById(id), data: dto.toJson());
//     return InvoiceResponseModel.fromJson(res.data as Map<String, dynamic>);
//   }
//
//   ///(DELETE /api/invoices/{id})
//   Future<String> deleteInvoice(int id) async {
//     final res = await _dio.delete(ApiConstants.invoiceById(id));
//     return res.data.toString();
//   }
// }