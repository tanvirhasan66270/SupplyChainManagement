// ── QC Inspection Result Constants ─────────────────────────────────────
class QCInspectionResult {
  static const good = 'GOOD';
  static const veryGood = 'VERY_GOOD';
  static const average = 'AVERAGE';
  static const bad = 'BAD';
  static const values = [good, veryGood, average, bad];
}

/// UI badge/label metadata for QC Inspection Result.
class QCInspectionResultMeta {
  static const Map<String, String> label = {
    QCInspectionResult.good: 'Good',
    QCInspectionResult.veryGood: 'Very Good',
    QCInspectionResult.average: 'Average',
    QCInspectionResult.bad: 'Bad',
  };

  static String labelFor(String result) => label[result] ?? result;
}

// ── QC Checklist Request Model ─────────────────────────────────────────
class QCChecklistRequestModel {
  QCChecklistRequestModel({
    this.inspectionId,
    required this.checkpointName,
    required this.isPassed,
    required this.remarks,
  });

  final int? inspectionId;
  final String checkpointName;
  final bool isPassed;
  final String remarks;

  Map<String, dynamic> toJson() => {
    if (inspectionId != null) 'inspectionId': inspectionId,
    'checkpointName': checkpointName,
    'isPassed': isPassed,
    'remarks': remarks,
  };
}

// ── QC Checklist Response Model ────────────────────────────────────────
class QCChecklistResponseModel {
  QCChecklistResponseModel({
    required this.id,
    required this.checkpointName,
    required this.isPassed,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.inspectionId,
    required this.inspectionType,
  });

  final int id;
  final String checkpointName;
  final bool isPassed;
  final String remarks;
  final String createdAt;
  final String updatedAt;
  final int inspectionId;
  final String inspectionType;

  factory QCChecklistResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return QCChecklistResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      checkpointName: (json['checkpointName'] ?? '') as String,
      isPassed: (json['isPassed'] ?? false) as bool,
      remarks: (json['remarks'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      inspectionId: (asNum(json['inspectionId']) ?? 0).toInt(),
      inspectionType: (json['inspectionType'] ?? '') as String,
    );
  }
}

// ── QC Inspection Request Model ────────────────────────────────────────
class QCInspectionRequestModel {
  QCInspectionRequestModel({
    this.id,
    required this.grnId,
    required this.productId,
    required this.inspectionType,
    required this.inspectedBy,
    required this.sampleSize,
    required this.defectsFound,
    required this.defectDescription,
    required this.result,
    required this.certificateRef,
    required this.labTestReport,
    required this.inspectedAt,
    required this.checklists,
  });

  final int? id;
  final int grnId;
  final int productId;
  final String inspectionType;
  final int inspectedBy;
  final int sampleSize;
  final int defectsFound;
  final String defectDescription;
  final String result;
  final String certificateRef;
  final String labTestReport;
  final String inspectedAt;
  final List<QCChecklistRequestModel> checklists;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'grnId': grnId,
    'productId': productId,
    'inspectionType': inspectionType,
    'inspectedBy': inspectedBy,
    'sampleSize': sampleSize,
    'defectsFound': defectsFound,
    'defectDescription': defectDescription,
    'result': result,
    'certificateRef': certificateRef,
    'labTestReport': labTestReport,
    'inspectedAt': inspectedAt,
    'checklists': checklists.map((e) => e.toJson()).toList(),
  };
}

// ── QC Inspection Response Model ───────────────────────────────────────
class QCInspectionResponseModel {
  QCInspectionResponseModel({
    required this.id,
    required this.inspectionType,
    required this.sampleSize,
    required this.defectsFound,
    required this.defectDescription,
    required this.result,
    required this.certificateRef,
    required this.labTestReport,
    required this.inspectedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.grnId,
    required this.grnNumber,
    required this.productId,
    required this.productName,
    required this.inspectedBy,
    required this.inspectedByName,
    required this.checklists,
  });

  final int id;
  final String inspectionType;
  final int sampleSize;
  final int defectsFound;
  final String defectDescription;
  final String result;
  final String certificateRef;
  final String labTestReport;
  final String inspectedAt;
  final String createdAt;
  final String updatedAt;
  final int grnId;
  final String grnNumber;
  final int productId;
  final String productName;
  final int inspectedBy;
  final String inspectedByName;
  final List<QCChecklistResponseModel> checklists;

  factory QCInspectionResponseModel.fromJson(Map<String, dynamic> json) {
    num? asNum(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

    return QCInspectionResponseModel(
      id: (asNum(json['id']) ?? 0).toInt(),
      inspectionType: (json['inspectionType'] ?? '') as String,
      sampleSize: (asNum(json['sampleSize']) ?? 0).toInt(),
      defectsFound: (asNum(json['defectsFound']) ?? 0).toInt(),
      defectDescription: (json['defectDescription'] ?? '') as String,
      result: (json['result'] ?? QCInspectionResult.good) as String,
      certificateRef: (json['certificateRef'] ?? '') as String,
      labTestReport: (json['labTestReport'] ?? '') as String,
      inspectedAt: (json['inspectedAt'] ?? '') as String,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      grnId: (asNum(json['grnId']) ?? 0).toInt(),
      grnNumber: (json['grnNumber'] ?? '') as String,
      productId: (asNum(json['productId']) ?? 0).toInt(),
      productName: (json['productName'] ?? '') as String,
      inspectedBy: (asNum(json['inspectedBy']) ?? 0).toInt(),
      inspectedByName: (json['inspectedByName'] ?? '') as String,
      checklists: (json['checklists'] as List<dynamic>? ?? [])
          .map((e) => QCChecklistResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}