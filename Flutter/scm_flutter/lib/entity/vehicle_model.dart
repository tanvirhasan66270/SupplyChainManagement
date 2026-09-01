// ── Vehicle Type Constants ─────────────────────────────────────────────
class VehicleType {
  static const truck = 'TRUCK';
  static const van = 'VAN';
  static const bike = 'BIKE';
  static const air = 'AIR';
  static const riverShip = 'RIVER_SHIP';
  static const values = [truck, van, bike, air, riverShip];
}

/// UI badge/label metadata for Vehicle Type.
class VehicleTypeMeta {
  static const Map<String, String> label = {
    VehicleType.truck: 'Truck',
    VehicleType.van: 'Van',
    VehicleType.bike: 'Bike',
    VehicleType.air: 'Air',
    VehicleType.riverShip: 'River Ship',
  };

  static String labelFor(String type) => label[type] ?? type;
}

// ── Vehicle Status Constants ───────────────────────────────────────────
class VehicleStatus {
  static const available = 'AVAILABLE';
  static const onTrip = 'ON_TRIP';
  static const maintenance = 'MAINTENANCE';
  static const outOfService = 'OUT_OF_SERVICE';
  static const values = [available, onTrip, maintenance, outOfService];
}

/// UI badge/label metadata for Vehicle Status.
class VehicleStatusMeta {
  static const Map<String, String> label = {
    VehicleStatus.available: 'Available',
    VehicleStatus.onTrip: 'On Trip',
    VehicleStatus.maintenance: 'Maintenance',
    VehicleStatus.outOfService: 'Out of Service',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Vehicle Request Model ──────────────────────────────────────────────
class VehicleRequestModel {
  VehicleRequestModel({
    required this.plateNumber,
    required this.type,
    required this.capacity,
    required this.status,
    this.lastServiceDate,
    required this.fuelLevel,
    this.driverId,
  });

  final String plateNumber;
  final String type;
  final double capacity;
  final String status;
  final String? lastServiceDate;
  final double fuelLevel;
  final int? driverId;

  Map<String, dynamic> toJson() => {
    'plateNumber': plateNumber,
    'type': type,
    'capacity': capacity,
    'status': status,
    if (lastServiceDate != null) 'lastServiceDate': lastServiceDate,
    'fuelLevel': fuelLevel,
    if (driverId != null) 'driverId': driverId,
  };
}

// ── Vehicle Response Model ─────────────────────────────────────────────
class VehicleResponseModel {
  VehicleResponseModel({
    required this.id,
    required this.plateNumber,
    required this.type,
    required this.capacity,
    required this.status,
    this.lastServiceDate,
    required this.fuelLevel,
    this.driverId,
    this.driverName,
    this.driverPhone,
  });

  final int id;
  final String plateNumber;
  final String type;
  final double capacity;
  final String status;
  final String? lastServiceDate;
  final double fuelLevel;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;

  factory VehicleResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return VehicleResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      plateNumber: (json['plateNumber'] ?? '') as String,
      type: (json['type'] ?? VehicleType.truck) as String,
      capacity: (asNum(json['capacity']) ?? 0).toDouble(),
      status: (json['status'] ?? VehicleStatus.available) as String,
      lastServiceDate: json['lastServiceDate'] as String?,
      fuelLevel: (asNum(json['fuelLevel']) ?? 0).toDouble(),
      driverId: json['driverId'] != null ? (asNum(json['driverId'])!).toInt() : null,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
    );
  }
}