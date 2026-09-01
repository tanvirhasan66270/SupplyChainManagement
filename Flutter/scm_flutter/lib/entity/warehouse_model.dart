// ── Warehouse Request Model ────────────────────────────────────────────
class WarehouseRequestModel {
  WarehouseRequestModel({
    required this.name,
    required this.email,
    required this.location,
    required this.address,
    required this.capacity,
    required this.managerId,
    required this.isActive,
    required this.policeStationId,
  });

  final String name;
  final String email;
  final String location;
  final String address;
  final double capacity;
  final int managerId;
  final bool isActive;
  final int policeStationId;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'location': location,
    'address': address,
    'capacity': capacity,
    'managerId': managerId,
    'isActive': isActive,
    'policeStationId': policeStationId,
  };
}

// ── Warehouse Response Model ───────────────────────────────────────────
class WarehouseResponseModel {
  WarehouseResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.location,
    required this.address,
    required this.capacity,
    required this.managerId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.policeStationId,
    required this.policeStationName,
    required this.districtName,
    required this.divisionName,
  });

  final int id;

  // সুবিধার্থে warehouseId গেটার যোগ করা হলো, যাতে w.warehouseId লিখলেও কাজ করে
  int get warehouseId => id;

  final String name;
  final String email;
  final String location;
  final String address;
  final double capacity;
  final int managerId;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final int policeStationId;
  final String policeStationName;
  final String districtName;
  final String divisionName;

  factory WarehouseResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return WarehouseResponseModel(
      // ব্যাকএন্ড থেকে যদি কখনো সরাসরি 'warehouseId' বা 'id' আসে, দুটোর যেকোনো একটা হ্যান্ডেল করবে
      id: (asNum(json['id'] ?? json['warehouseId']) ?? 0).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      capacity: (asNum(json['capacity']) ?? 0).toDouble(),
      managerId: (asNum(json['managerId']) ?? 0).toInt(),
      isActive: (json['isActive'] ?? false) as bool,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      policeStationId: (asNum(json['policeStationId']) ?? 0).toInt(),
      policeStationName: (json['policeStationName'] ?? '') as String,
      districtName: (json['districtName'] ?? '') as String,
      divisionName: (json['divisionName'] ?? '') as String,
    );
  }
}