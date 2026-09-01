// ── Invoice Status Constants ───────────────────────────────────────────
import 'package:scm_flutter/entity/customerOrderModel.dart';

class InvoiceStatus {
  static const draft = 'DRAFT';
  static const issued = 'ISSUED';
  static const cancelled = 'CANCELLED';
  static const values = [draft, issued, cancelled];
}

/// UI badge/label metadata for Invoice Status.
class InvoiceStatusMeta {
  static const Map<String, String> label = {
    InvoiceStatus.draft: 'Draft',
    InvoiceStatus.issued: 'Issued',
    InvoiceStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Invoice Request Model ──────────────────────────────────────────────
class InvoiceRequestModel {
  InvoiceRequestModel({
    this.customerOrderId,
    this.salesOfficerId,
    required this.subtotal,
    required this.taxRate,
    required this.discountAmount,
    required this.discountPercentage,
    required this.shippingFees,
    required this.paidAmount,
    this.paymentMethod,
    this.transactionReference,
    required this.invoiceStatus,
    this.deliveryDate,
    required this.deliveryAddress,
    this.notes,
    this.cancelledReason,
  });

  final int? customerOrderId;
  final int? salesOfficerId;
  final double subtotal;
  final double taxRate;
  final double discountAmount;
  final double discountPercentage;
  final double shippingFees;
  final double paidAmount;
  final String? paymentMethod;
  final String? transactionReference;
  final String invoiceStatus;
  final String? deliveryDate;
  final String deliveryAddress;
  final String? notes;
  final String? cancelledReason;

  Map<String, dynamic> toJson() => {
    if (customerOrderId != null) 'customerOrderId': customerOrderId,
    if (salesOfficerId != null) 'salesOfficerId': salesOfficerId,
    'subtotal': subtotal,
    'taxRate': taxRate,
    'discountAmount': discountAmount,
    'discountPercentage': discountPercentage,
    'shippingFees': shippingFees,
    'paidAmount': paidAmount,
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (transactionReference != null) 'transactionReference': transactionReference,
    'invoiceStatus': invoiceStatus,
    if (deliveryDate != null) 'deliveryDate': deliveryDate,
    'deliveryAddress': deliveryAddress,
    if (notes != null) 'notes': notes,
    if (cancelledReason != null) 'cancelledReason': cancelledReason,
  };
}

// ── Invoice Response Model ─────────────────────────────────────────────
class InvoiceResponseModel {
  InvoiceResponseModel({
    required this.id,
    required this.invoiceNumber,
    this.customerOrderId,
    required this.customerEmail,
    this.salesOfficerId,
    required this.issuedToName,
    required this.currency,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discountAmount,
    required this.discountPercentage,
    required this.shippingFees,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.transactionReference,
    required this.invoiceStatus,
    this.deliveryDate,
    required this.deliveryAddress,
    this.notes,
    this.cancelledReason,
    this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
  });

  final int id;
  final String invoiceNumber;
  final int? customerOrderId;
  final String customerEmail;
  final int? salesOfficerId;
  final String issuedToName;
  final String currency;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double discountPercentage;
  final double shippingFees;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? transactionReference;
  final String invoiceStatus;
  final String? deliveryDate;
  final String deliveryAddress;
  final String? notes;
  final String? cancelledReason;
  final String? issuedAt;
  final String createdAt;
  final String updatedAt;
  final String? cancelledAt;

  factory InvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return InvoiceResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      invoiceNumber: (json['invoiceNumber'] ?? '') as String,
      customerOrderId: json['customerOrderId'] != null ? (asNum(json['customerOrderId'])!).toInt() : null,
      customerEmail: (json['customerEmail'] ?? '') as String,
      salesOfficerId: json['salesOfficerId'] != null ? (asNum(json['salesOfficerId'])!).toInt() : null,
      issuedToName: (json['issuedToName'] ?? '') as String,
      currency: (json['currency'] ?? 'BDT') as String,
      subtotal: (asNum(json['subtotal']) ?? 0).toDouble(),
      taxRate: (asNum(json['taxRate']) ?? 0).toDouble(),
      taxAmount: (asNum(json['taxAmount']) ?? 0).toDouble(),
      discountAmount: (asNum(json['discountAmount']) ?? 0).toDouble(),
      discountPercentage: (asNum(json['discountPercentage']) ?? 0).toDouble(),
      shippingFees: (asNum(json['shippingFees']) ?? 0).toDouble(),
      totalAmount: (asNum(json['totalAmount']) ?? 0).toDouble(),
      paidAmount: (asNum(json['paidAmount']) ?? 0).toDouble(),
      dueAmount: (asNum(json['dueAmount']) ?? 0).toDouble(),
      paymentStatus: (json['paymentStatus'] ?? PaymentStatus.unpaid) as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionReference: json['transactionReference'] as String?,
      invoiceStatus: (json['invoiceStatus'] ?? InvoiceStatus.draft) as String,
      deliveryDate: json['deliveryDate'] as String?,
      deliveryAddress: (json['deliveryAddress'] ?? '') as String,
      notes: json['notes'] as String?,
      cancelledReason: json['cancelledReason'] as String?,
      issuedAt: json['issuedAt'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      cancelledAt: json['cancelledAt'] as String?,
    );
  }
}