// ── Notification Type Constants ────────────────────────────────────────
class NotificationType {
  static const shipment = 'SHIPMENT';
  static const tripAlert = 'TRIP_ALERT';
  static const reportApproved = 'REPORT_APPROVED';
  static const values = [shipment, tripAlert, reportApproved];
}

/// UI badge/label metadata for Notification Type.
class NotificationTypeMeta {
  static const Map<String, String> label = {
    NotificationType.shipment: 'Shipment',
    NotificationType.tripAlert: 'Trip Alert',
    NotificationType.reportApproved: 'Report Approved',
  };

  static String labelFor(String type) => label[type] ?? type;
}

// ── Notification Model ────────────────────────────────────────────────
class NotificationModel {
  NotificationModel({
    this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final int? id;
  final String recipientId;
  final String type;      // 'SHIPMENT' | 'TRIP_ALERT' | 'REPORT_APPROVED'
  final String title;
  final String message;
  final bool isRead;
  final String createdAt; // ISO Date String

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      recipientId: (json['recipientId'] ?? '') as String,
      type: (json['type'] ?? 'SHIPMENT') as String,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      isRead: (json['isRead'] ?? false) as bool,
      createdAt: (json['createdAt'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'recipientId': recipientId,
    'type': type,
    'title': title,
    'message': message,
    'isRead': isRead,
    'createdAt': createdAt,
  };

  NotificationModel copyWith({
    int? id,
    String? recipientId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}