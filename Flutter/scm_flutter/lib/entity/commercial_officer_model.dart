// ── Commercial Officer Request Model ───────────────────────────────────
class CommercialOfficerRequestModel {
  CommercialOfficerRequestModel({
    required this.address,
    required this.nidNumber,
    required this.passportNumber,
    required this.dob,
    required this.gender,
    required this.joiningDate,
    required this.designation,
    required this.language,
    required this.policeStationId,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String address;
  final String nidNumber;
  final String passportNumber;
  final String dob;
  final String gender;
  final String joiningDate;
  final String designation;
  final String language;
  final int policeStationId;
  final String name;
  final String email;
  final String phone;
  final String password;

  Map<String, dynamic> toJson() => {
    'address': address,
    'nidNumber': nidNumber,
    'passportNumber': passportNumber,
    'dob': dob,
    'gender': gender,
    'joiningDate': joiningDate,
    'designation': designation,
    'language': language,
    'policeStationId': policeStationId,
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
  };
}

// ── Commercial Officer Response Model ──────────────────────────────────
class CommercialOfficerResponseModel {
  CommercialOfficerResponseModel({
    required this.id,
    required this.address,
    required this.nidNumber,
    required this.passportNumber,
    required this.dob,
    required this.gender,
    required this.image,
    required this.joiningDate,
    required this.designation,
    required this.language,
    required this.policeStationId,
    required this.policeStationName,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  final int id;
  final String address;
  final String nidNumber;
  final String passportNumber;
  final String dob;
  final String gender;
  final String image;
  final String joiningDate;
  final String designation;
  final String language;
  final int policeStationId;
  final String policeStationName;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String role;

  factory CommercialOfficerResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return CommercialOfficerResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      address: (json['address'] ?? '') as String,
      nidNumber: (json['nidNumber'] ?? '') as String,
      passportNumber: (json['passportNumber'] ?? '') as String,
      dob: (json['dob'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      joiningDate: (json['joiningDate'] ?? '') as String,
      designation: (json['designation'] ?? '') as String,
      language: (json['language'] ?? '') as String,
      policeStationId: (asNum(json['policeStationId']) ?? 0).toInt(),
      policeStationName: (json['policeStationName'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      userId: (asNum(json['userId']) ?? 0).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: (json['role'] ?? '') as String,
    );
  }
}