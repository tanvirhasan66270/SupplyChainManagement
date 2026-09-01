// ── Payment Statement Status Constants ─────────────────────────────────
class PaymentStatementStatus {
  static const pendingVerification = 'PENDING_VERIFICATION';
  static const confirmedByOfficer = 'CONFIRMED_BY_OFFICER';
  static const failedOrRejected = 'FAILED_OR_REJECTED';
  static const values = [pendingVerification, confirmedByOfficer, failedOrRejected];
}

/// UI badge/label metadata for Payment Statement Status.
class PaymentStatementStatusMeta {
  static const Map<String, String> label = {
    PaymentStatementStatus.pendingVerification: 'Pending Verification',
    PaymentStatementStatus.confirmedByOfficer: 'Confirmed by Officer',
    PaymentStatementStatus.failedOrRejected: 'Failed or Rejected',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Payment Statement Request Model ───────────────────────────────────
class PaymentStatementRequest {
  PaymentStatementRequest({
    required this.customerOrderId,
    required this.paidAmount,
    required this.paymentMethod,
    this.issueStatus,
    this.transactionId,
    this.customerAccountNumber,
    this.paymentCheckImage,
  });

  final int customerOrderId;
  final double paidAmount;
  final String paymentMethod; // 'CASH', 'BANK', 'BKASH', 'NAGAD', 'ROCKET'
  final String? issueStatus; // 'PENDING_VERIFICATION', 'CONFIRMED_BY_OFFICER', 'FAILED_OR_REJECTED'
  final String? transactionId;
  final String? customerAccountNumber;
  final String? paymentCheckImage;

  Map<String, dynamic> toJson() => {
    'customerOrderId': customerOrderId,
    'paidAmount': paidAmount,
    'paymentMethod': paymentMethod,
    if (issueStatus != null) 'issueStatus': issueStatus,
    if (transactionId != null) 'transactionId': transactionId,
    if (customerAccountNumber != null) 'customerAccountNumber': customerAccountNumber,
    if (paymentCheckImage != null) 'paymentCheckImage': paymentCheckImage,
  };
}

// ── Payment Statement Response Model ──────────────────────────────────
class PaymentStatementResponse {
  PaymentStatementResponse({
    required this.id,
    required this.paidAmount,
    required this.oldPaidAmount,
    required this.paymentMethod,
    required this.issueStatus,
    required this.transactionId,
    this.customerAccountNumber,
    required this.paymentCheckImage,
    required this.createdAt,
    required this.updatedAt,
    required this.customerOrderId,
    required this.orderNumber,
  });

  final int id;
  final double paidAmount;
  final double oldPaidAmount;
  final String paymentMethod;
  final String issueStatus;
  final String transactionId;
  final String? customerAccountNumber;
  final String paymentCheckImage;
  final String createdAt;
  final String updatedAt;
  final int customerOrderId;
  final String orderNumber;

  factory PaymentStatementResponse.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return PaymentStatementResponse(
      id: (json['id'] ?? 0) as int,
      paidAmount: (asNum(json['paidAmount']) ?? 0).toDouble(),
      oldPaidAmount: (asNum(json['oldPaidAmount']) ?? 0).toDouble(),
      paymentMethod: (json['paymentMethod'] ?? '') as String,
      issueStatus: (json['issueStatus'] ?? '') as String,
      transactionId: (json['transactionId'] ?? '') as String,
      customerAccountNumber: json['customerAccountNumber'] as String?,
      paymentCheckImage: (json['paymentCheckImage'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      customerOrderId: (json['customerOrderId'] ?? 0) as int,
      orderNumber: (json['orderNumber'] ?? '') as String,
    );
  }
}