// ── Delivery Trip Status Constants ─────────────────────────────────────
class DeliveryTripStatus {
  static const pending = 'PENDING';
  static const inTransit = 'IN_TRANSIT';
  static const delivered = 'DELIVERED';
  static const cancelled = 'CANCELLED';
  static const values = [pending, inTransit, delivered, cancelled];
}

/// UI badge/label metadata for Delivery Trip Status.
class DeliveryTripStatusMeta {
  static const Map<String, String> label = {
    DeliveryTripStatus.pending: 'Pending',
    DeliveryTripStatus.inTransit: 'In Transit',
    DeliveryTripStatus.delivered: 'Delivered',
    DeliveryTripStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Delivery Trip Request Model ────────────────────────────────────────
class DeliveryTripRequestModel {
  DeliveryTripRequestModel({
    required this.dispatcherId,
    required this.customerId,
    required this.vehicleId,
    required this.driverId,
    required this.status,
    required this.customerAddress,
    this.recipientSignature,
    this.deliveryPhotoUrl,
    this.remarks,
  });

  final int dispatcherId;
  final int customerId;
  final int vehicleId;
  final int driverId;
  final String status;
  final String customerAddress;
  final String? recipientSignature;
  final String? deliveryPhotoUrl;
  final String? remarks;

  Map<String, dynamic> toJson() => {
    'dispatcherId': dispatcherId,
    'customerId': customerId,
    'vehicleId': vehicleId,
    'driverId': driverId,
    'status': status,
    'customerAddress': customerAddress,
    if (recipientSignature != null) 'recipientSignature': recipientSignature,
    if (deliveryPhotoUrl != null) 'deliveryPhotoUrl': deliveryPhotoUrl,
    if (remarks != null) 'remarks': remarks,
  };
}

// ── Delivery Trip Response Model ───────────────────────────────────────
class DeliveryTripResponseModel {
  DeliveryTripResponseModel({
    required this.id,
    required this.dispatcherId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.recipientSignature,
    this.deliveryPhotoUrl,
    required this.customerAddress,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    required this.recipientName,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.driverEmail,
    required this.vehicleId,
    required this.vehiclePlateNumber,
    this.vehicleModel,
  });

  final int id;
  final int dispatcherId;
  final String status;
  final String? startedAt;
  final String? completedAt;
  final String? recipientSignature;
  final String? deliveryPhotoUrl;
  final String customerAddress;
  final String? remarks;
  final String createdAt;
  final String updatedAt;
  final int customerId;
  final String recipientName;
  final int driverId;
  final String driverName;
  final String driverPhone;
  final String driverEmail;
  final int vehicleId;
  final String vehiclePlateNumber;
  final String? vehicleModel;

  factory DeliveryTripResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return DeliveryTripResponseModel(
      id: (json['id'] ?? 0) as int,
      dispatcherId: (asNum(json['dispatcherId']) ?? 0).toInt(),
      status: (json['status'] ?? DeliveryTripStatus.pending) as String,
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      recipientSignature: json['recipientSignature'] as String?,
      deliveryPhotoUrl: json['deliveryPhotoUrl'] as String?,
      customerAddress: (json['customerAddress'] ?? '') as String,
      remarks: json['remarks'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      customerId: (asNum(json['customerId']) ?? 0).toInt(),
      recipientName: (json['recipientName'] ?? '') as String,
      driverId: (asNum(json['driverId']) ?? 0).toInt(),
      driverName: (json['driverName'] ?? '') as String,
      driverPhone: (json['driverPhone'] ?? '') as String,
      driverEmail: (json['driverEmail'] ?? '') as String,
      vehicleId: (asNum(json['vehicleId']) ?? 0).toInt(),
      vehiclePlateNumber: (json['vehiclePlateNumber'] ?? '') as String,
      vehicleModel: json['vehicleModel'] as String?,
    );
  }
}