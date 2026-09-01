// ── Shipment Request Model ─────────────────────────────────────────────
class ShipmentRequestModel {
  ShipmentRequestModel({
    required this.poId,
    required this.supplierId,
    required this.vehicleNumber,
    required this.captainRegistrationNumber,
    required this.assignedByEmail,
    required this.origin,
    required this.sendByAddress,
    required this.estimatedDelivery,
    required this.transportCost,
    this.shipmentQuantity,
    required this.podFileUrl,
  });

  final int poId;
  final int supplierId;
  final String vehicleNumber;
  final String captainRegistrationNumber;
  final String assignedByEmail;
  final String origin;
  final String sendByAddress;
  final String estimatedDelivery;
  final double transportCost;
  final int? shipmentQuantity;
  final String podFileUrl;

  Map<String, dynamic> toJson() => {
    'poId': poId,
    'supplierId': supplierId,
    'vehicleNumber': vehicleNumber,
    'captainRegistrationNumber': captainRegistrationNumber,
    'assignedByEmail': assignedByEmail,
    'origin': origin,
    'sendByAddress': sendByAddress,
    'estimatedDelivery': estimatedDelivery,
    'transportCost': transportCost,
    if (shipmentQuantity != null) 'shipmentQuantity': shipmentQuantity,
    'podFileUrl': podFileUrl,
  };
}

// ── Shipment Response Model ────────────────────────────────────────────
class ShipmentResponseModel {
  ShipmentResponseModel({
    required this.id,
    required this.shipmentNumber,
    required this.poId,
    this.customPoNumber,
    required this.poQuantity,
    required this.poTotalAmount,
    required this.supplierId,
    required this.supplierName,
    required this.supplierContactPerson,
    required this.supplierEmail,
    required this.supplierPhone,
    required this.supplierAddress,
    required this.vehicleNumber,
    required this.captainRegistrationNumber,
    required this.assignedByEmail,
    required this.origin,
    required this.sendByAddress,
    required this.estimatedDelivery,
    required this.transportCost,
    required this.shipmentQuantity,
    required this.podFileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String shipmentNumber;
  final int poId;
  final String? customPoNumber;
  final int poQuantity;
  final double poTotalAmount;
  final int supplierId;
  final String supplierName;
  final String supplierContactPerson;
  final String supplierEmail;
  final String supplierPhone;
  final String supplierAddress;
  final String vehicleNumber;
  final String captainRegistrationNumber;
  final String assignedByEmail;
  final String origin;
  final String sendByAddress;
  final String estimatedDelivery;
  final double transportCost;
  final int shipmentQuantity;
  final String podFileUrl;
  final String createdAt;
  final String updatedAt;

  String get poNumber => (customPoNumber != null && customPoNumber!.isNotEmpty)
      ? customPoNumber!
      : (poId > 0 ? 'PO-$poId' : '');

  factory ShipmentResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return ShipmentResponseModel(
      id: (json['id'] ?? 0) as int,
      shipmentNumber: (json['shipmentNumber'] ?? '') as String,
      poId: (json['poId'] ?? 0) as int,
      customPoNumber: json['poNumber']?.toString(),
      poQuantity: (asNum(json['poQuantity']) ?? 0).toInt(),
      poTotalAmount: (asNum(json['poTotalAmount']) ?? 0).toDouble(),
      supplierId: (json['supplierId'] ?? 0) as int,
      supplierName: (json['supplierName'] ?? '') as String,
      supplierContactPerson: (json['supplierContactPerson'] ?? '') as String,
      supplierEmail: (json['supplierEmail'] ?? '') as String,
      supplierPhone: (json['supplierPhone'] ?? '') as String,
      supplierAddress: (json['supplierAddress'] ?? '') as String,
      vehicleNumber: (json['vehicleNumber'] ?? '') as String,
      captainRegistrationNumber: (json['captainRegistrationNumber'] ?? '') as String,
      assignedByEmail: (json['assignedByEmail'] ?? '') as String,
      origin: (json['origin'] ?? '') as String,
      sendByAddress: (json['sendByAddress'] ?? '') as String,
      estimatedDelivery: (json['estimatedDelivery'] ?? '') as String,
      transportCost: (asNum(json['transportCost']) ?? 0).toDouble(),
      shipmentQuantity: (asNum(json['shipmentQuantity']) ?? 0).toInt(),
      podFileUrl: (json['podFileUrl'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
    );
  }
}