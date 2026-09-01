// ── Daily Report Status Constants ──────────────────────────────────────
class DailyReportStatus {
  static const draft = 'DRAFT';
  static const submitted = 'SUBMITTED';
  static const approved = 'APPROVED';
  static const values = [draft, submitted, approved];
}

/// UI badge/label metadata for Daily Report Status.
class DailyReportStatusMeta {
  static const Map<String, String> label = {
    DailyReportStatus.draft: 'Draft',
    DailyReportStatus.submitted: 'Submitted',
    DailyReportStatus.approved: 'Approved',
  };

  static String labelFor(String status) => label[status] ?? status;
}

// ── Daily Report Request Model ─────────────────────────────────────────
class DailyReportRequestModel {
  DailyReportRequestModel({
    required this.warehouseId,
    required this.reportDate,
    required this.totalTasksDone,
    required this.issuesLogged,
    required this.summary,
  });

  final String warehouseId;
  final String reportDate;
  final int totalTasksDone;
  final int issuesLogged;
  final String summary;

  Map<String, dynamic> toJson() => {
    'warehouseId': warehouseId,
    'reportDate': reportDate,
    'totalTasksDone': totalTasksDone,
    'issuesLogged': issuesLogged,
    'summary': summary,
  };
}

// ── Notified Authority Model ───────────────────────────────────────────
class NotifiedAuthority {
  NotifiedAuthority({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  factory NotifiedAuthority.fromJson(Map<String, dynamic> json) {
    return NotifiedAuthority(
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'role': role,
  };
}

// ── Daily Report Response Model ────────────────────────────────────────
class DailyReportResponseModel {
  DailyReportResponseModel({
    required this.id,
    required this.userId,
    required this.warehouseId,
    required this.reportDate,
    required this.totalTasksDone,
    required this.issuesLogged,
    this.summary,
    required this.reportStatus,
    this.attachmentUrl,
    required this.generatedAt,
    required this.updatedAt,
    required this.notifiedAuthorities,
  });

  final int id;
  final String userId;
  final String warehouseId;
  final String reportDate;
  final int totalTasksDone;
  final int issuesLogged;
  final String? summary;
  final String reportStatus;
  final String? attachmentUrl;
  final String generatedAt;
  final String updatedAt;
  final List<NotifiedAuthority> notifiedAuthorities;

  factory DailyReportResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return DailyReportResponseModel(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? '').toString(),
      warehouseId: (json['warehouseId'] ?? '').toString(),
      reportDate: (json['reportDate'] ?? '') as String,
      totalTasksDone: (asNum(json['totalTasksDone']) ?? 0).toInt(),
      issuesLogged: (asNum(json['issuesLogged']) ?? 0).toInt(),
      summary: json['summary'] as String?,
      reportStatus: (json['reportStatus'] ?? DailyReportStatus.draft) as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      generatedAt: (json['generatedAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      notifiedAuthorities: (json['notifiedAuthorities'] as List<dynamic>? ?? [])
          .map((e) => NotifiedAuthority.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}