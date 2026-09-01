// ── Stock Status Constants ─────────────────────────────────────────────
class StockStatus {
  static const inStock = 'IN_STOCK';
  static const lowStock = 'LOW_STOCK';
  static const outOfStock = 'OUT_OF_STOCK';
  static const values = [inStock, lowStock, outOfStock];
}

/// UI badge/label metadata for Stock Status.
class StockStatusMeta {
  static const Map<String, String> label = {
    StockStatus.inStock: 'In Stock',
    StockStatus.lowStock: 'Low Stock',
    StockStatus.outOfStock: 'Out of Stock',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Inventory Request Model ────────────────────────────────────────────
class InventoryRequestModel {
  InventoryRequestModel({
    required this.productId,
    required this.warehouseId,
    required this.quantityOnHand,
    required this.quantityReserved,
    this.locationStatus,
    this.expiryDate,
    required this.stockStatus,
  });

  final int productId;
  final int warehouseId;
  final int quantityOnHand;
  final int quantityReserved;
  final String? locationStatus;
  final String? expiryDate;
  final String stockStatus;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'warehouseId': warehouseId,
    'quantityOnHand': quantityOnHand,
    'quantityReserved': quantityReserved,
    if (locationStatus != null) 'locationStatus': locationStatus,
    if (expiryDate != null) 'expiryDate': expiryDate,
    'stockStatus': stockStatus,
  };
}

// ── Inventory Response Model ───────────────────────────────────────────
class InventoryResponseModel {
  InventoryResponseModel({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantityOnHand,
    required this.quantityReserved,
    required this.availableQuantity,
    required this.locationStatus,
    required this.expiryDate,
    required this.stockStatus,
    required this.lastUpdated,
  });

  final int id;
  final int productId;
  final String productCode;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final int quantityOnHand;
  final int quantityReserved;
  final int availableQuantity;
  final String locationStatus;
  final String expiryDate;
  final String stockStatus;
  final String lastUpdated;

  factory InventoryResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return InventoryResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      productId: (asNum(json['productId']) ?? 0).toInt(),
      productCode: (json['productCode'] ?? '') as String,
      productName: (json['productName'] ?? '') as String,
      warehouseId: (asNum(json['warehouseId']) ?? 0).toInt(),
      warehouseName: (json['warehouseName'] ?? '') as String,
      quantityOnHand: (asNum(json['quantityOnHand']) ?? 0).toInt(),
      quantityReserved: (asNum(json['quantityReserved']) ?? 0).toInt(),
      availableQuantity: (asNum(json['availableQuantity']) ?? 0).toInt(),
      locationStatus: (json['locationStatus'] ?? '') as String,
      expiryDate: (json['expiryDate'] ?? '') as String,
      stockStatus: (json['stockStatus'] ?? StockStatus.inStock) as String,
      lastUpdated: (json['lastUpdated'] ?? '') as String,
    );
  }
}