class CustomerRequestModel {
  final String name;
  final String email;
  final String phone;
  final String? password; // এডিট মোডে পাসওয়ার্ড অপশনাল
  final String address;
  final String gender;
  final String dob; // "YYYY-MM-DD" ফরম্যাট স্ট্রিং
  final String nidNumber;
  final int policeStationId;

  CustomerRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    this.password,
    required this.address,
    required this.gender,
    required this.dob,
    required this.nidNumber,
    required this.policeStationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password,
      'address': address,
      'gender': gender,
      'dob': dob,
      'nidNumber': nidNumber,
      'policeStationId': policeStationId,
    };
  }
}

class CustomerResponseModel {
  final int id;
  final int userId;
  final int countryId;
  final int divisionId;
  final int districtId;
  final int policeStationId;

  final String name;
  final String email;
  final String phone;
  final String role;
  final String address;
  final String gender;
  final String dob;
  final String nidNumber;
  final String image;
  final String createdAt;

  final String countryName;
  final String divisionName;
  final String districtName;
  final String policeStationName;

  CustomerResponseModel({
    required this.id,
    required this.userId,
    required this.countryId,
    required this.divisionId,
    required this.districtId,
    required this.policeStationId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    required this.gender,
    required this.dob,
    required this.nidNumber,
    required this.image,
    required this.createdAt,
    required this.countryName,
    required this.divisionName,
    required this.districtName,
    required this.policeStationName,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      countryId: json['countryId'] ?? 0,
      divisionId: json['divisionId'] ?? 0,
      districtId: json['districtId'] ?? 0,
      policeStationId: json['policeStationId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      nidNumber: json['nidNumber'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['createdAt'] ?? '',
      countryName: json['countryName'] ?? '',
      divisionName: json['divisionName'] ?? '',
      districtName: json['districtName'] ?? '',
      policeStationName: json['policeStationName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'countryId': countryId,
      'divisionId': divisionId,
      'districtId': districtId,
      'policeStationId': policeStationId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'gender': gender,
      'dob': dob,
      'nidNumber': nidNumber,
      'image': image,
      'createdAt': createdAt,
      'countryName': countryName,
      'divisionName': divisionName,
      'districtName': districtName,
      'policeStationName': policeStationName,
    };
  }
}