// ── GRN Status Constants ───────────────────────────────────────────────
class GRNStatus {
  static const pending = 'PENDING';
  static const received = 'RECEIVED';
  static const approved = 'APPROVED';
  static const rejected = 'REJECTED';
  static const values = [pending, received, approved, rejected];
}

/// UI badge/label metadata for GRN Status.
class GRNStatusMeta {
  static const Map<String, String> label = {
    GRNStatus.pending: 'Pending',
    GRNStatus.received: 'Received',
    GRNStatus.approved: 'Approved',
    GRNStatus.rejected: 'Rejected',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── GRN Line Item Request Model ────────────────────────────────────────
class GRNLineItemRequestModel {
  GRNLineItemRequestModel({
    this.id,
    this.grnId,
    required this.productId,
    required this.quantityOrdered,
    required this.quantityReceived,
  });

  final int? id;
  final int? grnId;
  final int productId;
  final int quantityOrdered;
  final int quantityReceived;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (grnId != null) 'grnId': grnId,
    'productId': productId,
    'quantityOrdered': quantityOrdered,
    'quantityReceived': quantityReceived,
  };
}

// ── GRN Line Item Response Model ───────────────────────────────────────
class GRNLineItemResponseModel {
  GRNLineItemResponseModel({
    required this.id,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.grnId,
    required this.grnNumber,
    required this.productId,
    required this.productName,
  });

  final int id;
  final int quantityOrdered;
  final int quantityReceived;
  final int grnId;
  final String grnNumber;
  final int productId;
  final String productName;

  factory GRNLineItemResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return GRNLineItemResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      quantityOrdered: (asNum(json['quantityOrdered']) ?? 0).toInt(),
      quantityReceived: (asNum(json['quantityReceived']) ?? 0).toInt(),
      grnId: (asNum(json['grnId']) ?? 0).toInt(),
      grnNumber: (json['grnNumber'] ?? '') as String,
      productId: (asNum(json['productId']) ?? 0).toInt(),
      productName: (json['productName'] ?? '') as String,
    );
  }
}

// ── Goods Received Note Request Model ──────────────────────────────────
class GoodsReceivedNoteRequestModel {
  GoodsReceivedNoteRequestModel({
    required this.poId,
    this.productId,
    required this.receivedQuantity,
    required this.receivedBy,
    required this.warehouseId,
    required this.receivedAt,
    required this.status,
    required this.remarks,
    this.inspectedBy,
    this.inspectionDate,
    required this.lineItems,
  });

  final int poId;
  final int? productId;
  final int receivedQuantity;
  final int receivedBy;
  final int warehouseId;
  final String receivedAt;
  final String status;
  final String remarks;
  final int? inspectedBy;
  final String? inspectionDate;
  final List<GRNLineItemRequestModel> lineItems;

  Map<String, dynamic> toJson() => {
    'poId': poId,
    if (productId != null) 'productId': productId,
    'receivedQuantity': receivedQuantity,
    'receivedBy': receivedBy,
    'warehouseId': warehouseId,
    'receivedAt': receivedAt,
    'status': status,
    'remarks': remarks,
    if (inspectedBy != null) 'inspectedBy': inspectedBy,
    if (inspectionDate != null) 'inspectionDate': inspectionDate,
    'lineItems': lineItems.map((e) => e.toJson()).toList(),
  };
}

// ── Goods Received Note Response Model ─────────────────────────────────
class GoodsReceivedNoteResponseModel {
  GoodsReceivedNoteResponseModel({
    required this.id,
    required this.grnNumber,
    required this.quantity,
    required this.receivedQuantity,
    required this.receivedAt,
    required this.status,
    required this.remarks,
    this.inspectionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.poId,
    required this.poNumber,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.receivedBy,
    required this.receivedByName,
    this.inspectedBy,
    this.inspectedByName,
    this.lineItems,
  });

  final int id;
  final String grnNumber;
  final int quantity;
  final int receivedQuantity;
  final String receivedAt;
  final String status;
  final String remarks;
  final String? inspectionDate;
  final String createdAt;
  final String updatedAt;
  final int poId;
  final String poNumber;
  final int productId;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final int receivedBy;
  final String receivedByName;
  final int? inspectedBy;
  final String? inspectedByName;
  final List<GRNLineItemResponseModel>? lineItems;

  factory GoodsReceivedNoteResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return GoodsReceivedNoteResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      grnNumber: (json['grnNumber'] ?? '') as String,
      quantity: (asNum(json['quantity']) ?? 0).toInt(),
      receivedQuantity: (asNum(json['receivedQuantity']) ?? 0).toInt(),
      receivedAt: (json['receivedAt'] ?? '') as String,
      status: (json['status'] ?? GRNStatus.pending) as String,
      remarks: (json['remarks'] ?? '') as String,
      inspectionDate: json['inspectionDate'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      poId: (asNum(json['poId']) ?? 0).toInt(),
      poNumber: (json['poNumber'] ?? '') as String,
      productId: (asNum(json['productId']) ?? 0).toInt(),
      productName: (json['productName'] ?? '') as String,
      warehouseId: (asNum(json['warehouseId']) ?? 0).toInt(),
      warehouseName: (json['warehouseName'] ?? '') as String,
      receivedBy: (asNum(json['receivedBy']) ?? 0).toInt(),
      receivedByName: (json['receivedByName'] ?? '') as String,
      inspectedBy: json['inspectedBy'] != null ? (asNum(json['inspectedBy'])!).toInt() : null,
      inspectedByName: json['inspectedByName'] as String?,
      lineItems: json['lineItems'] != null
          ? (json['lineItems'] as List<dynamic>)
          .map((e) => GRNLineItemResponseModel.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }
}