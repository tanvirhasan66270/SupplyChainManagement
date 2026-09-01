// ── Order Status Constants ─────────────────────────────────────────────
class OrderStatus {
  static const pending = 'PENDING';
  static const confirmed = 'CONFIRMED';
  static const processing = 'PROCESSING';
  static const shipped = 'SHIPPED';
  static const outForDelivery = 'OUT_FOR_DELIVERY';
  static const delivered = 'DELIVERED';
  static const cancelled = 'CANCELLED';
  static const values = [
    pending,
    confirmed,
    processing,
    shipped,
    outForDelivery,
    delivered,
    cancelled
  ];
}

// ── Payment Status Constants ───────────────────────────────────────────
class PaymentStatus {
  static const unpaid = 'UNPAID';
  static const partiallyPaid = 'PARTIALLY_PAID';
  static const paid = 'PAID';
  static const refunded = 'REFUNDED';
  static const values = [unpaid, partiallyPaid, paid, refunded];
}

// ── Service Type Constants ─────────────────────────────────────────────
class ServiceType {
  static const standard = 'STANDARD';
  static const express = 'EXPRESS';
  static const overnight = 'OVERNIGHT';
  static const sameDay = 'SAME_DAY';
  static const values = [standard, express, overnight, sameDay];
}

// ── Priority Constants ─────────────────────────────────────────────────
class Priority {
  static const low = 'LOW';
  static const normal = 'NORMAL';
  static const high = 'HIGH';
  static const urgent = 'URGENT';
  static const values = [low, normal, high, urgent];
}

// ── Payment Method Constants ───────────────────────────────────────────
class PaymentMethod {
  static const cash = 'CASH';
  static const bank = 'BANK';
  static const bkash = 'BKASH';
  static const nagad = 'NAGAD';
  static const rocket = 'ROCKET';
  static const values = [cash, bank, bkash, nagad, rocket];
}

/// UI badge/label metadata for Customer Orders.
class CustomerOrderStatusMeta {
  static const Map<String, String> label = {
    OrderStatus.pending: 'Pending',
    OrderStatus.confirmed: 'Confirmed',
    OrderStatus.processing: 'Processing',
    OrderStatus.shipped: 'Shipped',
    OrderStatus.outForDelivery: 'Out for Delivery',
    OrderStatus.delivered: 'Delivered',
    OrderStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Order Line Item Request ───────────────────────────────────────────
class OrderLineItemRequest {
  OrderLineItemRequest({
    required this.productId,
    required this.quantity,
    required this.remarks,
  });

  final int productId;
  final int quantity;
  final String remarks;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'remarks': remarks,
  };
}

// ── Order Line Item Response ──────────────────────────────────────────
class OrderLineItemResponse {
  OrderLineItemResponse({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.itemWeightTotal,
    required this.remarks,
  });

  final int id;
  final int productId;
  final String productName;
  final String productCode;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final double itemWeightTotal;
  final String remarks;

  factory OrderLineItemResponse.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return OrderLineItemResponse(
      id: (json['id'] ?? 0) as int,
      productId: (json['productId'] ?? 0) as int,
      productName: (json['productName'] ?? '') as String,
      productCode: (json['productCode'] ?? '') as String,
      quantity: (json['quantity'] ?? 0) as int,
      unitPrice: (asNum(json['unitPrice']) ?? 0).toDouble(),
      lineTotal: (asNum(json['lineTotal']) ?? 0).toDouble(),
      itemWeightTotal: (asNum(json['itemWeightTotal']) ?? 0).toDouble(),
      remarks: (json['remarks'] ?? '') as String,
    );
  }
}

// ── Customer Order Request ────────────────────────────────────────────
class CustomerOrderRequest {
  CustomerOrderRequest({
    required this.customerId,
    required this.deliveryAddress,
    required this.deliveryPhone,
    required this.estimatedDelivery,
    required this.serviceType,
    required this.priority,
    required this.currency,
    required this.codAmount,
    required this.paymentMethod,
    this.customerAccountNumber,
    this.paymentCheckImage,
    required this.status,
    required this.remarks,
    required this.items,
  });

  final int customerId;
  final String deliveryAddress;
  final String deliveryPhone;
  final String estimatedDelivery;
  final String serviceType;
  final String priority;
  final String currency;
  final double codAmount;
  final String paymentMethod;
  final String? customerAccountNumber;
  final String? paymentCheckImage;
  final String status;
  final String remarks;
  final List<OrderLineItemRequest> items;

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'deliveryAddress': deliveryAddress,
    'deliveryPhone': deliveryPhone,
    'estimatedDelivery': estimatedDelivery,
    'serviceType': serviceType,
    'priority': priority,
    'currency': currency,
    'codAmount': codAmount,
    'paymentMethod': paymentMethod,
    if (customerAccountNumber != null) 'customerAccountNumber': customerAccountNumber,
    if (paymentCheckImage != null) 'paymentCheckImage': paymentCheckImage,
    'status': status,
    'remarks': remarks,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

// ── Customer Order Response ───────────────────────────────────────────
class CustomerOrderResponse {
  CustomerOrderResponse({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.itemSubtotal,
    required this.weight,
    required this.serviceType,
    required this.priority,
    required this.currency,
    required this.codAmount,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.customerAccountNumber,
    this.paymentCheckImage,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryPhone,
    required this.remarks,
    required this.estimatedDelivery,
    required this.createdAt,
    required this.lineItems,
  });

  final int id;
  final String orderNumber;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final double itemSubtotal;
  final double weight;
  final String serviceType;
  final String priority;
  final String currency;
  final double codAmount;
  final double deliveryCharge;
  final double totalAmount;
  final dynamic paidAmount;
  final dynamic dueAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String? customerAccountNumber;
  final String? paymentCheckImage;
  final String status;
  final String deliveryAddress;
  final String deliveryPhone;
  final String remarks;
  final String estimatedDelivery;
  final String createdAt;
  final List<OrderLineItemResponse> lineItems;

  factory CustomerOrderResponse.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return CustomerOrderResponse(
      id: (json['id'] ?? 0) as int,
      orderNumber: (json['orderNumber'] ?? '') as String,
      customerId: (json['customerId'] ?? 0) as int,
      customerName: (json['customerName'] ?? '') as String,
      customerEmail: (json['customerEmail'] ?? '') as String,
      itemSubtotal: (asNum(json['itemSubtotal']) ?? 0).toDouble(),
      weight: (asNum(json['weight']) ?? 0).toDouble(),
      serviceType: (json['serviceType'] ?? '') as String,
      priority: (json['priority'] ?? '') as String,
      currency: (json['currency'] ?? '') as String,
      codAmount: (asNum(json['codAmount']) ?? 0).toDouble(),
      deliveryCharge: (asNum(json['deliveryCharge']) ?? 0).toDouble(),
      totalAmount: (asNum(json['totalAmount']) ?? 0).toDouble(),
      paidAmount: json['paidAmount'] ?? 0,
      dueAmount: json['dueAmount'] ?? 0,
      paymentStatus: (json['paymentStatus'] ?? '') as String,
      paymentMethod: (json['paymentMethod'] ?? '') as String,
      customerAccountNumber: json['customerAccountNumber'] as String?,
      paymentCheckImage: json['paymentCheckImage'] as String?,
      status: (json['status'] ?? '') as String,
      deliveryAddress: (json['deliveryAddress'] ?? '') as String,
      deliveryPhone: (json['deliveryPhone'] ?? '') as String,
      remarks: (json['remarks'] ?? '') as String,
      estimatedDelivery: (json['estimatedDelivery'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      lineItems: (json['lineItems'] as List<dynamic>? ?? [])
          .map((e) => OrderLineItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}