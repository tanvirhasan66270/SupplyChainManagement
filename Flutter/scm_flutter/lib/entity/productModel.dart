class ProductRequestModel {
  ProductRequestModel({
    required this.id,
    required this.productCode,
    required this.name,
    required this.unit,
    required this.reorderPoint,
    required this.unitCost,
    required this.quantity,
    required this.sellingPrice,
    required this.hasExpiryDate,
    required this.weight,
    required this.isActive,
    required this.availability,
    required this.image,
    required this.categoryId,
  });

  final int id;
  final String productCode;
  final String name;
  final String unit;
  final int reorderPoint;
  final double unitCost;
  final int quantity;
  final double sellingPrice;
  final String hasExpiryDate;
  final double weight;
  final bool isActive;
  final String availability;
  final String image;
  final int categoryId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'name': name,
      'unit': unit,
      'reorderPoint': reorderPoint,
      'unitCost': unitCost,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'hasExpiryDate': hasExpiryDate,
      'weight': weight,
      'isActive': isActive,
      'availability': availability,
      'image': image,
      'categoryId': categoryId,
    };
  }

  ProductRequestModel copyWith({
    int? id,
    String? productCode,
    String? name,
    String? unit,
    int? reorderPoint,
    double? unitCost,
    int? quantity,
    double? sellingPrice,
    String? hasExpiryDate,
    double? weight,
    bool? isActive,
    String? availability,
    String? image,
    int? categoryId,
  }) {
    return ProductRequestModel(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unitCost: unitCost ?? this.unitCost,
      quantity: quantity ?? this.quantity,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      hasExpiryDate: hasExpiryDate ?? this.hasExpiryDate,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
      availability: availability ?? this.availability,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class ProductResponseModel {
  ProductResponseModel({
    required this.id,
    required this.productCode,
    required this.name,
    required this.unit,
    required this.reorderPoint,
    required this.unitCost,
    required this.quantity,
    required this.sellingPrice,
    required this.hasExpiryDate,
    required this.weight,
    required this.isActive,
    required this.availability,
    required this.image,
    required this.categoryId,
    required this.categoryName,
  });

  final int id;
  final String productCode;
  final String name;
  final String unit;
  final int reorderPoint;
  final double unitCost;
  final int quantity;
  final double sellingPrice;
  final String hasExpiryDate;
  final double weight;
  final bool isActive;
  final String availability;
  final String image;
  final int categoryId;
  final String categoryName;

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return ProductResponseModel(
      id: (json['id'] ?? 0) as int,
      productCode: (json['productCode'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      unit: (json['unit'] ?? '') as String,
      reorderPoint: (json['reorderPoint'] ?? 0) as int,
      unitCost: (asNum(json['unitCost']) ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0) as int,
      sellingPrice: (asNum(json['sellingPrice']) ?? 0).toDouble(),
      hasExpiryDate: (json['hasExpiryDate'] ?? '') as String,
      weight: (asNum(json['weight']) ?? 0).toDouble(),
      isActive: (json['isActive'] ?? false) as bool,
      availability: (json['availability'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      categoryId: (json['categoryId'] ?? 0) as int,
      categoryName: (json['categoryName'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'name': name,
      'unit': unit,
      'reorderPoint': reorderPoint,
      'unitCost': unitCost,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'hasExpiryDate': hasExpiryDate,
      'weight': weight,
      'isActive': isActive,
      'availability': availability,
      'image': image,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}