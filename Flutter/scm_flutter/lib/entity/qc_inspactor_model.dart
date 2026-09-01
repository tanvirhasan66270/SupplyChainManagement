// ── QC Inspector Request Model ────────────────────────────────────────
class QCInspectorRequestModel {
  QCInspectorRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    this.password,
    required this.userActive,
    required this.contactPerson,
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
  });

  final String name;
  final String email;
  final String phone;
  final String? password;
  final bool userActive;
  final String contactPerson;
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    if (password != null) 'password': password,
    'userActive': userActive,
    'contactPerson': contactPerson,
    'address': address,
    'nidNumber': nidNumber,
    'passportNumber': passportNumber,
    'dob': dob,
    'gender': gender,
    'image': image,
    'joiningDate': joiningDate,
    'designation': designation,
    'language': language,
    'policeStationId': policeStationId,
  };
}

// ── QC Inspector Response Model ───────────────────────────────────────
class QCInspectorResponseModel {
  QCInspectorResponseModel({
    required this.id,
    required this.contactPerson,
    required this.address,
    required this.nidNumber,
    required this.passportNumber,
    required this.dob,
    required this.gender,
    required this.image,
    required this.joiningDate,
    required this.designation,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.userActive,
    required this.policeStationId,
    required this.policeStationName,
    required this.districtName,
    required this.divisionName,
  });

  final int id;
  final String contactPerson;
  final String address;
  final String nidNumber;
  final String passportNumber;
  final String dob;
  final String gender;
  final String image;
  final String joiningDate;
  final String designation;
  final String language;
  final String createdAt;
  final String updatedAt;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool userActive;
  final int policeStationId;
  final String policeStationName;
  final String districtName;
  final String divisionName;

  factory QCInspectorResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return QCInspectorResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      contactPerson: (json['contactPerson'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      nidNumber: (json['nidNumber'] ?? '') as String,
      passportNumber: (json['passportNumber'] ?? '') as String,
      dob: (json['dob'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      joiningDate: (json['joiningDate'] ?? '') as String,
      designation: (json['designation'] ?? '') as String,
      language: (json['language'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      userId: (asNum(json['userId']) ?? 0).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: (json['role'] ?? '') as String,
      userActive: (json['userActive'] ?? false) as bool,
      policeStationId: (asNum(json['policeStationId']) ?? 0).toInt(),
      policeStationName: (json['policeStationName'] ?? '') as String,
      districtName: (json['districtName'] ?? '') as String,
      divisionName: (json['divisionName'] ?? '') as String,
    );
  }
}