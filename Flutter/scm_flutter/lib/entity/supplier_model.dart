class SupplierRequestDTO {
  final String name;
  final String email;
  final String phone;
  final String? password;
  final String contactPerson;
  final String address;
  final String nidNumber;
  final String passportNumber;
  final String gender;
  final String dob;
  final String image;
  final double rating;
  final int averageLeadTimeDays;
  final int policeStationId;

  SupplierRequestDTO({
    required this.name,
    required this.email,
    required this.phone,
    this.password,
    required this.contactPerson,
    required this.address,
    required this.nidNumber,
    required this.passportNumber,
    required this.gender,
    required this.dob,
    required this.image,
    required this.rating,
    required this.averageLeadTimeDays,
    required this.policeStationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password,
      'contactPerson': contactPerson,
      'address': address,
      'nidNumber': nidNumber,
      'passportNumber': passportNumber,
      'gender': gender,
      'dob': dob,
      'image': image,
      'rating': rating,
      'averageLeadTimeDays': averageLeadTimeDays,
      'policeStationId': policeStationId,
    };
  }
}

class SupplierResponseDTO {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String contactPerson;
  final String address;
  final String nidNumber;
  final String passportNumber;
  final String gender;
  final String dob;
  final String image;
  final double rating;
  final int averageLeadTimeDays;
  final String createdAt;
  final String updatedAt;
  final int policeStationId;
  final String policeStationName;
  final String districtName;
  final String divisionName;

  SupplierResponseDTO({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.contactPerson,
    required this.address,
    required this.nidNumber,
    required this.passportNumber,
    required this.gender,
    required this.dob,
    required this.image,
    required this.rating,
    required this.averageLeadTimeDays,
    required this.createdAt,
    required this.updatedAt,
    required this.policeStationId,
    required this.policeStationName,
    required this.districtName,
    required this.divisionName,
  });

  factory SupplierResponseDTO.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return SupplierResponseDTO(
      id: (asNum(json['id']) ?? 0).toInt(),
      userId: (asNum(json['userId']) ?? 0).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: (json['role'] ?? '') as String,
      contactPerson: (json['contactPerson'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      nidNumber: (json['nidNumber'] ?? '') as String,
      passportNumber: (json['passportNumber'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      dob: (json['dob'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      rating: (asNum(json['rating']) ?? 0.0).toDouble(),
      averageLeadTimeDays: (asNum(json['averageLeadTimeDays']) ?? 0).toInt(),
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      policeStationId: (asNum(json['policeStationId']) ?? 0).toInt(),
      policeStationName: (json['policeStationName'] ?? '') as String,
      districtName: (json['districtName'] ?? '') as String,
      divisionName: (json['divisionName'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'contactPerson': contactPerson,
      'address': address,
      'nidNumber': nidNumber,
      'passportNumber': passportNumber,
      'gender': gender,
      'dob': dob,
      'image': image,
      'rating': rating,
      'averageLeadTimeDays': averageLeadTimeDays,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'policeStationId': policeStationId,
      'policeStationName': policeStationName,
      'districtName': districtName,
      'divisionName': divisionName,
    };
  }
}