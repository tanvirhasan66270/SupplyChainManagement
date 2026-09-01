// ── Urgency Level Constants ─────────────────────────────────────────────
class UrgencyLevel {
  static const low = 'LOW';
  static const medium = 'MEDIUM';
  static const high = 'HIGH';
  static const critical = 'CRITICAL';
  static const values = [low, medium, high, critical];
}

// ── Approval Status Constants ──────────────────────────────────────────
class ApprovalStatus {
  static const pending = 'PENDING';
  static const approved = 'APPROVED';
  static const rejected = 'REJECTED';
  static const cancelled = 'CANCELLED';
  static const values = [pending, approved, rejected, cancelled];
}

/// UI badge/label metadata for Approval Status.
class ApprovalStatusMeta {
  static const Map<String, String> label = {
    ApprovalStatus.pending: 'Pending',
    ApprovalStatus.approved: 'Approved',
    ApprovalStatus.rejected: 'Rejected',
    ApprovalStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Purchase Requisition Request ──────────────────────────────────────
class PurchaseRequisitionRequest {
  PurchaseRequisitionRequest({
    required this.requestedBy,
    required this.productIds,
    required this.supplierIds,
    required this.currency,
    required this.quantityRequired,
    required this.urgencyLevel,
    required this.requiredByDate,
    required this.remarks,
  });

  final int requestedBy;
  final List<int> productIds;
  final List<int> supplierIds;
  final String currency;
  final int quantityRequired;
  final String urgencyLevel;
  final String requiredByDate;
  final String remarks;

  Map<String, dynamic> toJson() => {
    'requestedBy': requestedBy,
    'productIds': productIds,
    'supplierIds': supplierIds,
    'currency': currency,
    'quantityRequired': quantityRequired,
    'urgencyLevel': urgencyLevel,
    'requiredByDate': requiredByDate,
    'remarks': remarks,
  };
}

// ── Purchase Requisition Response ─────────────────────────────────────
class PurchaseRequisitionResponse {
  PurchaseRequisitionResponse({
    required this.id,
    required this.requestedBy,
    required this.currency,
    required this.quantityRequired,
    required this.urgencyLevel,
    required this.requiredByDate,
    required this.approvalStatus,
    this.approvedBy,
    this.approvedByName,
    this.remarks,
    required this.createdAt,
    required this.productIds,
    required this.productNames,
    required this.supplierIds,
    required this.supplierNames,
  });

  final int id;
  final int requestedBy;
  final String currency;
  final int quantityRequired;
  final String urgencyLevel;
  final String requiredByDate;
  final String approvalStatus;
  final int? approvedBy;
  final String? approvedByName;
  final String? remarks;
  final String createdAt;
  final List<int> productIds;
  final List<String> productNames;
  final List<int> supplierIds;
  final List<String> supplierNames;

  factory PurchaseRequisitionResponse.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return PurchaseRequisitionResponse(
      id: (json['id'] ?? 0) as int,
      requestedBy: (json['requestedBy'] ?? 0) as int,
      currency: (json['currency'] ?? '') as String,
      quantityRequired: (asNum(json['quantityRequired']) ?? 0).toInt(),
      urgencyLevel: (json['urgencyLevel'] ?? UrgencyLevel.low) as String,
      requiredByDate: (json['requiredByDate'] ?? '') as String,
      approvalStatus: (json['approvalStatus'] ?? ApprovalStatus.pending) as String,
      approvedBy: json['approvedBy'] != null ? (json['approvedBy'] as num).toInt() : null,
      approvedByName: json['approvedByName'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
      productIds: (json['productIds'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      productNames: (json['productNames'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      supplierIds: (json['supplierIds'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      supplierNames: (json['supplierNames'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}