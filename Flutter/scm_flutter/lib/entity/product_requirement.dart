// ── Product Requirement Status Constants ───────────────────────────────
class ProductRequirementStatus {
  static const pending = 'PENDING';
  static const approved = 'APPROVED';
  static const rejected = 'REJECTED';
  static const processing = 'PROCESSING';
  static const values = [pending, approved, rejected, processing];
}

/// UI badge/label metadata for Product Requirement Status.
class ProductRequirementStatusMeta {
  static const Map<String, String> label = {
    ProductRequirementStatus.pending: 'Pending',
    ProductRequirementStatus.approved: 'Approved',
    ProductRequirementStatus.rejected: 'Rejected',
    ProductRequirementStatus.processing: 'Processing',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Product Requirement Request Model ──────────────────────────────────
class ProductRequirementRequest {
  ProductRequirementRequest({
    required this.customerOrderNumber,
    required this.productName,
    required this.description,
    required this.requestedQuantity,
    required this.unit,
    required this.targetPriceRange,
    required this.urgencyLevel,
    required this.status,
    this.requestedByOfficerId,
    required this.requestedByOfficerName,
    required this.procurementRemarks,
  });

  final String customerOrderNumber;
  final String productName;
  final String description;
  final int requestedQuantity;
  final String unit;
  final String targetPriceRange;
  final String urgencyLevel;
  final String status;
  final int? requestedByOfficerId;
  final String requestedByOfficerName;
  final String procurementRemarks;

  Map<String, dynamic> toJson() => {
    'customerOrderNumber': customerOrderNumber,
    'productName': productName,
    'description': description,
    'requestedQuantity': requestedQuantity,
    'unit': unit,
    'targetPriceRange': targetPriceRange,
    'urgencyLevel': urgencyLevel,
    'status': status,
    if (requestedByOfficerId != null) 'requestedByOfficerId': requestedByOfficerId,
    'requestedByOfficerName': requestedByOfficerName,
    'procurementRemarks': procurementRemarks,
  };
}

// ── Product Requirement Response Model ─────────────────────────────────
class ProductRequirementResponse {
  ProductRequirementResponse({
    required this.id,
    required this.requestReferenceNo,
    required this.customerOrderNumber,
    required this.productName,
    required this.description,
    required this.requestedQuantity,
    required this.unit,
    required this.targetPriceRange,
    required this.urgencyLevel,
    required this.status,
    required this.requestedByOfficerId,
    required this.requestedByOfficerName,
    required this.procurementRemarks,
    required this.createdAt,
  });

  final int id;
  final String requestReferenceNo;
  final String customerOrderNumber;
  final String productName;
  final String description;
  final int requestedQuantity;
  final String unit;
  final String targetPriceRange;
  final String urgencyLevel;
  final String status;
  final int requestedByOfficerId;
  final String requestedByOfficerName;
  final String procurementRemarks;
  final String createdAt;

  factory ProductRequirementResponse.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return ProductRequirementResponse(
      id: (asNum(json['id']) ?? 0).toInt(),
      requestReferenceNo: (json['requestReferenceNo'] ?? '') as String,
      customerOrderNumber: (json['customerOrderNumber'] ?? '') as String,
      productName: (json['productName'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      requestedQuantity: (asNum(json['requestedQuantity']) ?? 0).toInt(),
      unit: (json['unit'] ?? '') as String,
      targetPriceRange: (json['targetPriceRange'] ?? '') as String,
      urgencyLevel: (json['urgencyLevel'] ?? '') as String,
      status: (json['status'] ?? ProductRequirementStatus.pending) as String,
      requestedByOfficerId: (asNum(json['requestedByOfficerId']) ?? 0).toInt(),
      requestedByOfficerName: (json['requestedByOfficerName'] ?? '') as String,
      procurementRemarks: (json['procurementRemarks'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
    );
  }
}