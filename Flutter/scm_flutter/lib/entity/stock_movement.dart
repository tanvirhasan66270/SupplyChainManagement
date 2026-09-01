// ── Stock Movement Type Constants ──────────────────────────────────────
class StockMovementType {
  static const inward = 'INWARD';
  static const outward = 'OUTWARD';
  static const transfer = 'TRANSFER';
  static const adjustment = 'ADJUSTMENT';
  static const values = [inward, outward, transfer, adjustment];
}

/// UI badge/label metadata for Stock Movement Type.
class StockMovementTypeMeta {
  static const Map<String, String> label = {
    StockMovementType.inward: 'Inward',
    StockMovementType.outward: 'Outward',
    StockMovementType.transfer: 'Transfer',
    StockMovementType.adjustment: 'Adjustment',
  };

  static String labelFor(String type) => label[type] ?? type;
}

// ── Stock Movement Request Model ───────────────────────────────────────
class StockMovementRequestModel {
  StockMovementRequestModel({
    required this.productId,
    required this.warehouseId,
    this.sourceWarehouseId,
    required this.movementType,
    required this.quantity,
    required this.referenceId,
    required this.performedBy,
    this.remarks,
  });

  final int productId;
  final int warehouseId;
  final int? sourceWarehouseId;
  final String movementType;
  final int quantity;
  final String referenceId;
  final int performedBy;
  final String? remarks;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'warehouseId': warehouseId,
    if (sourceWarehouseId != null) 'sourceWarehouseId': sourceWarehouseId,
    'movementType': movementType,
    'quantity': quantity,
    'referenceId': referenceId,
    'performedBy': performedBy,
    if (remarks != null) 'remarks': remarks,
  };
}

// ── Stock Movement Response Model ──────────────────────────────────────
class StockMovementResponseModel {
  StockMovementResponseModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    this.sourceWarehouseId,
    this.sourceWarehouseName,
    required this.movementType,
    required this.quantity,
    required this.referenceId,
    required this.performedBy,
    required this.performedByName,
    required this.movedAt,
    required this.remarks,
  });

  final int id;
  final int productId;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final int? sourceWarehouseId;
  final String? sourceWarehouseName;
  final String movementType;
  final int quantity;
  final String referenceId;
  final int performedBy;
  final String performedByName;
  final String movedAt;
  final String remarks;

  factory StockMovementResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return StockMovementResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      productId: (asNum(json['productId']) ?? 0).toInt(),
      productName: (json['productName'] ?? '') as String,
      warehouseId: (asNum(json['warehouseId']) ?? 0).toInt(),
      warehouseName: (json['warehouseName'] ?? '') as String,
      sourceWarehouseId: json['sourceWarehouseId'] != null ? (asNum(json['sourceWarehouseId'])!).toInt() : null,
      sourceWarehouseName: json['sourceWarehouseName'] as String?,
      movementType: (json['movementType'] ?? StockMovementType.inward) as String,
      quantity: (asNum(json['quantity']) ?? 0).toInt(),
      referenceId: (json['referenceId'] ?? '') as String,
      performedBy: (asNum(json['performedBy']) ?? 0).toInt(),
      performedByName: (json['performedByName'] ?? '') as String,
      movedAt: (json['movedAt'] ?? '') as String,
      remarks: (json['remarks'] ?? '') as String,
    );
  }
}