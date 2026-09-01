// ── Driver Request Model ───────────────────────────────────────────────
class DriverRequestModel {
  DriverRequestModel({
    required this.id,
    required this.driverName,
    required this.phone,
    required this.address,
    required this.nidNumber,
    required this.gender,
    required this.email,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.dob,
    required this.rating,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.image,
    required this.password,
    required this.policeStationId,
    required this.warehouseIds,
  });

  final int id;
  final String driverName;
  final String phone;
  final String address;
  final String nidNumber;
  final String gender;
  final String email;
  final String vehicleType;
  final String vehicleNumber;
  final String dob;
  final double rating;
  final int totalDeliveries;
  final double totalEarnings;
  final String image;
  final String password;
  final int policeStationId;
  final List<int> warehouseIds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'driverName': driverName,
    'phone': phone,
    'address': address,
    'nidNumber': nidNumber,
    'gender': gender,
    'email': email,
    'vehicleType': vehicleType,
    'vehicleNumber': vehicleNumber,
    'dob': dob,
    'rating': rating,
    'totalDeliveries': totalDeliveries,
    'totalEarnings': totalEarnings,
    'image': image,
    'password': password,
    'policeStationId': policeStationId,
    'warehouseIds': warehouseIds,
  };
}

// ── Driver Response Model ──────────────────────────────────────────────
class DriverResponseModel {
  DriverResponseModel({
    required this.id,
    required this.driverName,
    required this.phone,
    required this.address,
    required this.nidNumber,
    required this.gender,
    required this.email,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.dob,
    required this.rating,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.role,
    required this.policeStationId,
    required this.policeStationName,
    required this.districtName,
    required this.divisionName,
    required this.warehouseNames,
  });

  final int id;
  final String driverName;
  final String phone;
  final String address;
  final String nidNumber;
  final String gender;
  final String email;
  final String vehicleType;
  final String vehicleNumber;
  final String dob;
  final double rating;
  final int totalDeliveries;
  final double totalEarnings;
  final String image;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final String role;
  final int policeStationId;
  final String policeStationName;
  final String districtName;
  final String divisionName;
  final List<String> warehouseNames;

  factory DriverResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return DriverResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      driverName: (json['driverName'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      nidNumber: (json['nidNumber'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      vehicleType: (json['vehicleType'] ?? '') as String,
      vehicleNumber: (json['vehicleNumber'] ?? '') as String,
      dob: (json['dob'] ?? '') as String,
      rating: (asNum(json['rating']) ?? 0).toDouble(),
      totalDeliveries: (asNum(json['totalDeliveries']) ?? 0).toInt(),
      totalEarnings: (asNum(json['totalEarnings']) ?? 0).toDouble(),
      image: (json['image'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      userId: (asNum(json['userId']) ?? 0).toInt(),
      role: (json['role'] ?? '') as String,
      policeStationId: (asNum(json['policeStationId']) ?? 0).toInt(),
      policeStationName: (json['policeStationName'] ?? '') as String,
      districtName: (json['districtName'] ?? '') as String,
      divisionName: (json['divisionName'] ?? '') as String,
      warehouseNames: (json['warehouseNames'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}