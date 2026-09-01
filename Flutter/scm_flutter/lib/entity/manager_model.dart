class ManagerRequestModel {
  final int? id;
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
  final String? password; 

  ManagerRequestModel({
    this.id,
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
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
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
      if (password != null) 'password': password,
    };
  }
}

class ManagerResponseModel {
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

  ManagerResponseModel({
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

  factory ManagerResponseModel.fromJson(Map<String, dynamic> json) {
    return ManagerResponseModel(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      nidNumber: json['nidNumber'] ?? '',
      passportNumber: json['passportNumber'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      joiningDate: json['joiningDate'] ?? '',
      designation: json['designation'] ?? '',
      language: json['language'] ?? '',
      policeStationId: json['policeStationId'] ?? 0,
      policeStationName: json['policeStationName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'policeStationName': policeStationName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}