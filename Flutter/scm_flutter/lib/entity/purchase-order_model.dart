// ── Purchase Order Status Constants ────────────────────────────────────
class PurchaseOrderStatus {
  static const draft = 'DRAFT';
  static const issued = 'ISSUED';
  static const partiallyReceived = 'PARTIALLY_RECEIVED';
  static const received = 'RECEIVED';
  static const cancelled = 'CANCELLED';
  static const values = [
    draft,
    issued,
    partiallyReceived,
    received,
    cancelled
  ];
}

/// UI badge/label metadata for Purchase Order Status.
class PurchaseOrderStatusMeta {
  static const Map<String, String> label = {
    PurchaseOrderStatus.draft: 'Draft',
    PurchaseOrderStatus.issued: 'Issued',
    PurchaseOrderStatus.partiallyReceived: 'Partially Received',
    PurchaseOrderStatus.received: 'Received',
    PurchaseOrderStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Purchase Order Request ─────────────────────────────────────────────
class PurchaseOrderRequest {
  PurchaseOrderRequest({
    required this.quotationId,
    required this.issuedBy,
    this.issuedByName,
    required this.totalAmount,
    required this.quantity,
    required this.currency,
    required this.expectedDeliveryDate,
    required this.status,
    this.poNumber,
    this.supplierName,
    this.supplierEmail,
    this.purchaseRequisitionId,
    this.createdAt,
  });

  final int quotationId;
  final int issuedBy;
  final String? issuedByName;
  final double totalAmount;
  final int quantity;
  final String currency;
  final String expectedDeliveryDate;
  final String status;
  final String? poNumber;
  final String? supplierName;
  final String? supplierEmail;
  final int? purchaseRequisitionId;
  final String? createdAt;

  Map<String, dynamic> toJson() => {
    'quotationId': quotationId,
    'issuedBy': issuedBy,
    if (issuedByName != null) 'issuedByName': issuedByName,
    'totalAmount': totalAmount,
    'quantity': quantity,
    'currency': currency,
    'expectedDeliveryDate': expectedDeliveryDate,
    'status': status,
    if (poNumber != null) 'poNumber': poNumber,
    if (supplierName != null) 'supplierName': supplierName,
    if (supplierEmail != null) 'supplierEmail': supplierEmail,
    if (purchaseRequisitionId != null) 'purchaseRequisitionId': purchaseRequisitionId,
    if (createdAt != null) 'createdAt': createdAt,
  };
}

// ── Purchase Order Response ────────────────────────────────────────────
class PurchaseOrderResponse {
  PurchaseOrderResponse({
    required this.id,
    required this.poNumber,
    required this.quantity,
    required this.totalAmount,
    required this.currency,
    required this.expectedDeliveryDate,
    required this.status,
    required this.issuedBy,
    this.issuedByName = 'Procurement Officer',
    required this.createdAt,
    required this.updatedAt,
    required this.supplierId,
    required this.supplierName,
    required this.supplierEmail,
    required this.purchaseRequisitionId,
    required this.quotationId,
  });

  final int id;
  final String poNumber;
  final int quantity;
  final double totalAmount;
  final String currency;
  final String expectedDeliveryDate;
  final String status;
  final int issuedBy;
  final String issuedByName;
  final String createdAt;
  final String updatedAt;
  final int supplierId;
  final String supplierName;
  final String supplierEmail;
  final int purchaseRequisitionId;
  final int quotationId;

  factory PurchaseOrderResponse.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return PurchaseOrderResponse(
      id: (json['id'] ?? 0) as int,
      poNumber: (json['poNumber'] ?? '') as String,
      quantity: (asNum(json['quantity']) ?? 0).toInt(),
      totalAmount: (asNum(json['totalAmount']) ?? 0).toDouble(),
      currency: (json['currency'] ?? '') as String,
      expectedDeliveryDate: (json['expectedDeliveryDate'] ?? '') as String,
      status: (json['status'] ?? PurchaseOrderStatus.draft) as String,
      issuedBy: (json['issuedBy'] ?? 0) as int,
      issuedByName: (json['issuedByName'] ?? 'Procurement Officer') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      supplierId: (json['supplierId'] ?? 0) as int,
      supplierName: (json['supplierName'] ?? '') as String,
      supplierEmail: (json['supplierEmail'] ?? '') as String,
      purchaseRequisitionId: (json['purchaseRequisitionId'] ?? 0) as int,
      quotationId: (json['quotationId'] ?? 0) as int,
    );
  }
}