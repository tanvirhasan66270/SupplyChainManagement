// ── Quotation Status Constants ─────────────────────────────────────────
class QuotationStatus {
  static const pending = 'PENDING';
  static const underReview = 'UNDER_REVIEW';
  static const approved = 'APPROVED';
  static const rejected = 'REJECTED';
  static const expired = 'EXPIRED';
  static const values = [
    pending,
    underReview,
    approved,
    rejected,
    expired
  ];
}

/// UI badge/label metadata for Quotation Status.
class QuotationStatusMeta {
  static const Map<String, String> label = {
    QuotationStatus.pending: 'Pending',
    QuotationStatus.underReview: 'Under Review',
    QuotationStatus.approved: 'Approved',
    QuotationStatus.rejected: 'Rejected',
    QuotationStatus.expired: 'Expired',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Quotation Request Model ────────────────────────────────────────────
class QuotationRequestModel {
  QuotationRequestModel({
    required this.supplierId,
    required this.purchaseRequisitionId,
    required this.leadTimeDays,
    required this.receivedAt,
    required this.status,
    required this.productDescription,
    required this.unitPrice,
    required this.quantity,
    required this.deliveryTime,
    required this.warranty,
    required this.notes,
    this.attachmentUrl,
  });

  final int supplierId;
  final int purchaseRequisitionId;
  final int leadTimeDays;
  final String receivedAt;
  final String status;
  final String productDescription;
  final double unitPrice;
  final int quantity;
  final String deliveryTime;
  final String warranty;
  final String notes;
  final String? attachmentUrl;

  Map<String, dynamic> toJson() => {
    'supplierId': supplierId,
    'purchaseRequisitionId': purchaseRequisitionId,
    'leadTimeDays': leadTimeDays,
    'receivedAt': receivedAt,
    'status': status,
    'productDescription': productDescription,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'deliveryTime': deliveryTime,
    'warranty': warranty,
    'notes': notes,
    if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
  };
}

// ── Quotation Response Model ───────────────────────────────────────────
class QuotationResponseModel {
  QuotationResponseModel({
    required this.id,
    required this.quotationNumber,
    required this.validUntil,
    required this.leadTimeDays,
    required this.receivedAt,
    required this.status,
    required this.productDescription,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryTime,
    required this.warranty,
    required this.notes,
    required this.attachmentUrl,
    required this.createdAt,
    required this.supplierId,
    required this.supplierName,
    required this.supplierEmail,
    required this.productIds,
    required this.productName,
    required this.purchaseRequisitionId,
  });

  final int id;
  final String quotationNumber;
  final String validUntil;
  final int leadTimeDays;
  final String receivedAt;
  final String status;
  final String productDescription;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String deliveryTime;
  final String warranty;
  final String notes;
  final String attachmentUrl;
  final String createdAt;
  final int supplierId;
  final String supplierName;
  final String supplierEmail;
  final int productIds;
  final String productName;
  final int purchaseRequisitionId;

  factory QuotationResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return QuotationResponseModel(
      id: (json['id'] ?? 0) as int,
      quotationNumber: (json['quotationNumber'] ?? '') as String,
      validUntil: (json['validUntil'] ?? '') as String,
      leadTimeDays: (asNum(json['leadTimeDays']) ?? 0).toInt(),
      receivedAt: (json['receivedAt'] ?? '') as String,
      status: (json['status'] ?? QuotationStatus.pending) as String,
      productDescription: (json['productDescription'] ?? '') as String,
      unitPrice: (asNum(json['unitPrice']) ?? 0).toDouble(),
      quantity: (asNum(json['quantity']) ?? 0).toInt(),
      totalPrice: (asNum(json['totalPrice']) ?? 0).toDouble(),
      deliveryTime: (json['deliveryTime'] ?? '') as String,
      warranty: (json['warranty'] ?? '') as String,
      notes: (json['notes'] ?? '') as String,
      attachmentUrl: (json['attachmentUrl'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      supplierId: (json['supplierId'] ?? 0) as int,
      supplierName: (json['supplierName'] ?? '') as String,
      supplierEmail: (json['supplierEmail'] ?? '') as String,
      productIds: (asNum(json['productIds']) ?? 0).toInt(),
      productName: (json['productName'] ?? '') as String,
      purchaseRequisitionId: (asNum(json['purchaseRequisitionId']) ?? 0).toInt(),
    );
  }
}