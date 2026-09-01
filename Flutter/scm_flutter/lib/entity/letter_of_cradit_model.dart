// ── Letter of Credit Status Constants ──────────────────────────────────
class LCStatus {
  static const draft = 'DRAFT';
  static const opened = 'OPENED';
  static const amended = 'AMENDED';
  static const expired = 'EXPIRED';
  static const cancelled = 'CANCELLED';
  static const values = [draft, opened, amended, expired, cancelled];
}

/// UI badge/label metadata for Letter of Credit Status.
class LCStatusMeta {
  static const Map<String, String> label = {
    LCStatus.draft: 'Draft',
    LCStatus.opened: 'Opened',
    LCStatus.amended: 'Amended',
    LCStatus.expired: 'Expired',
    LCStatus.cancelled: 'Cancelled',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Letter of Credit Request Model ─────────────────────────────────────
class LetterOfCreditRequestModel {
  LetterOfCreditRequestModel({
    required this.purchaseOrderId,
    required this.issuingBankId,
    required this.shipmentIncoTerms,
    required this.latestShipmentDate,
    required this.portOfLoading,
    required this.portOfDischarge,
    required this.amount,
    required this.supplierId,
    required this.currency,
    required this.expiryDate,
    required this.lcStatus,
    required this.documentVaultUrl,
  });

  final int purchaseOrderId;
  final int issuingBankId;
  final String shipmentIncoTerms;
  final String latestShipmentDate;
  final String portOfLoading;
  final String portOfDischarge;
  final double amount;
  final int supplierId;
  final String currency;
  final String expiryDate;
  final String lcStatus;
  final String documentVaultUrl;

  Map<String, dynamic> toJson() => {
    'purchaseOrderId': purchaseOrderId,
    'issuingBankId': issuingBankId,
    'shipmentIncoTerms': shipmentIncoTerms,
    'latestShipmentDate': latestShipmentDate,
    'portOfLoading': portOfLoading,
    'portOfDischarge': portOfDischarge,
    'amount': amount,
    'supplierId': supplierId,
    'currency': currency,
    'expiryDate': expiryDate,
    'lcStatus': lcStatus,
    'documentVaultUrl': documentVaultUrl,
  };
}

// ── Letter of Credit Response Model ────────────────────────────────────
class LetterOfCreditResponseModel {
  LetterOfCreditResponseModel({
    required this.id,
    required this.lcNumber,
    required this.purchaseOrderId,
    required this.poNumber,
    required this.issuingBankId,
    required this.issuingBankName,
    required this.issuingBankSwiftCode,
    required this.issuingBankBranch,
    required this.issuingBankaddress,
    required this.shipmentIncoTerms,
    required this.latestShipmentDate,
    required this.portOfLoading,
    required this.portOfDischarge,
    required this.amendmentCount,
    required this.amount,
    required this.supplierId,
    required this.supplierName,
    required this.supplierEmail,
    required this.currency,
    required this.expiryDate,
    required this.lcStatus,
    required this.documentVaultUrl,
    required this.openedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String lcNumber;
  final int purchaseOrderId;
  final String poNumber;
  final int issuingBankId;
  final String issuingBankName;
  final String issuingBankSwiftCode;
  final String issuingBankBranch;
  final String issuingBankaddress;
  final String shipmentIncoTerms;
  final String latestShipmentDate;
  final String portOfLoading;
  final String portOfDischarge;
  final int amendmentCount;
  final double amount;
  final int supplierId;
  final String supplierName;
  final String supplierEmail;
  final String currency;
  final String expiryDate;
  final String lcStatus;
  final String documentVaultUrl;
  final String openedAt;
  final String createdAt;
  final String updatedAt;

  factory LetterOfCreditResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return LetterOfCreditResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      lcNumber: (json['lcNumber'] ?? '') as String,
      purchaseOrderId: (asNum(json['purchaseOrderId']) ?? 0).toInt(),
      poNumber: (json['poNumber'] ?? '') as String,
      issuingBankId: (asNum(json['issuingBankId']) ?? 0).toInt(),
      issuingBankName: (json['issuingBankName'] ?? '') as String,
      issuingBankSwiftCode: (json['issuingBankSwiftCode'] ?? '') as String,
      issuingBankBranch: (json['issuingBankBranch'] ?? '') as String,
      issuingBankaddress: (json['issuingBankaddress'] ?? '') as String,
      shipmentIncoTerms: (json['shipmentIncoTerms'] ?? '') as String,
      latestShipmentDate: (json['latestShipmentDate'] ?? '') as String,
      portOfLoading: (json['portOfLoading'] ?? '') as String,
      portOfDischarge: (json['portOfDischarge'] ?? '') as String,
      amendmentCount: (asNum(json['amendmentCount']) ?? 0).toInt(),
      amount: (asNum(json['amount']) ?? 0).toDouble(),
      supplierId: (asNum(json['supplierId']) ?? 0).toInt(),
      supplierName: (json['supplierName'] ?? '') as String,
      supplierEmail: (json['supplierEmail'] ?? '') as String,
      currency: (json['currency'] ?? 'BDT') as String,
      expiryDate: (json['expiryDate'] ?? '') as String,
      lcStatus: (json['lcStatus'] ?? LCStatus.draft) as String,
      documentVaultUrl: (json['documentVaultUrl'] ?? '') as String,
      openedAt: (json['openedAt'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
    );
  }
}