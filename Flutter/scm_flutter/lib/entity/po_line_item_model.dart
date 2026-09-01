// ── PO Line Item Status Constants ──────────────────────────────────────
class POLineItemStatus {
  static const pending = 'PENDING';
  static const approved = 'APPROVED';
  static const shipped = 'SHIPPED';
  static const delivered = 'DELIVERED';
  static const cancelled = 'CANCELLED';
  static const values = [
    pending,
    approved,
    shipped,
    delivered,
    cancelled
  ];
}

/// UI badge/label metadata for PO Line Item Status.
class POLineItemStatusMeta {
  static const Map<String, String> label = {
    POLineItemStatus.pending: 'Pending',
    POLineItemStatus.approved: 'Approved',
    POLineItemStatus.shipped: 'Shipped',
    POLineItemStatus.delivered: 'Delivered',
    POLineItemStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── PO Line Item Request DTO ───────────────────────────────────────────
class POLineItemRequestDTO {
  POLineItemRequestDTO({
    required this.poId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.quotationRef,
    required this.poNumber,
    required this.deliveryDate,
    required this.shipmentMethod,
    required this.notes,
    required this.status,
  });

  final int poId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final String quotationRef;
  final String poNumber;
  final String deliveryDate;
  final String shipmentMethod;
  final String notes;
  final String status;

  Map<String, dynamic> toJson() => {
    'poId': poId,
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'quotationRef': quotationRef,
    'poNumber': poNumber,
    'deliveryDate': deliveryDate,
    'shipmentMethod': shipmentMethod,
    'notes': notes,
    'status': status,
  };
}

// ── PO Line Item Response DTO ──────────────────────────────────────────
class POLineItemResponseDTO {
  POLineItemResponseDTO({
    required this.id,
    required this.poId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.supplierId,
    required this.supplierName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.totalAmount,
    required this.quotationRef,
    required this.poNumber,
    required this.deliveryDate,
    required this.shipmentMethod,
    required this.trackingNumber,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int poId;
  final int productId;
  final String productName;
  final String productCode;
  final String supplierId;
  final String supplierName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final double totalAmount;
  final String quotationRef;
  final String poNumber;
  final String deliveryDate;
  final String shipmentMethod;
  final String trackingNumber;
  final String notes;
  final String status;
  final String createdAt;

  factory POLineItemResponseDTO.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return POLineItemResponseDTO(
      id: (json['id'] ?? 0) as int,
      poId: (json['poId'] ?? 0) as int,
      productId: (json['productId'] ?? 0) as int,
      productName: (json['productName'] ?? '') as String,
      productCode: (json['productCode'] ?? '') as String,
      supplierId: (json['supplierId'] ?? '').toString(),
      supplierName: (json['supplierName'] ?? '') as String,
      quantity: (asNum(json['quantity']) ?? 0).toInt(),
      unitPrice: (asNum(json['unitPrice']) ?? 0).toDouble(),
      lineTotal: (asNum(json['lineTotal']) ?? 0).toDouble(),
      totalAmount: (asNum(json['totalAmount']) ?? 0).toDouble(),
      quotationRef: (json['quotationRef'] ?? '') as String,
      poNumber: (json['poNumber'] ?? '') as String,
      deliveryDate: (json['deliveryDate'] ?? '') as String,
      shipmentMethod: (json['shipmentMethod'] ?? '') as String,
      trackingNumber: (json['trackingNumber'] ?? '') as String,
      notes: (json['notes'] ?? '') as String,
      status: (json['status'] ?? POLineItemStatus.pending) as String,
      createdAt: (json['createdAt'] ?? '') as String,
    );
  }
}