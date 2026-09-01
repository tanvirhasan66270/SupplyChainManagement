// ── LC Bank Request Model ──────────────────────────────────────────────
class LCBankRequestModel {
  LCBankRequestModel({
    required this.name,
    required this.swiftCode,
    required this.branchName,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
  });

  final String name;
  final String swiftCode;
  final String branchName;
  final String address;
  final String contactEmail;
  final String contactPhone;

  Map<String, dynamic> toJson() => {
    'name': name,
    'swiftCode': swiftCode,
    'branchName': branchName,
    'address': address,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
  };
}

// ── LC Bank Response Model ─────────────────────────────────────────────
class LCBankResponseModel {
  LCBankResponseModel({
    required this.id,
    required this.name,
    required this.swiftCode,
    required this.branchName,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String swiftCode;
  final String branchName;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String? createdAt;
  final String? updatedAt;

  factory LCBankResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return LCBankResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      name: (json['name'] ?? '') as String,
      swiftCode: (json['swiftCode'] ?? '') as String,
      branchName: (json['branchName'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      contactEmail: (json['contactEmail'] ?? '') as String,
      contactPhone: (json['contactPhone'] ?? '') as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}