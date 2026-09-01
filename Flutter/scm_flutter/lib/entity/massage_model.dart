// ── Message Priority Constants ─────────────────────────────────────────
class MessagePriority {
  static const low = 'LOW';
  static const medium = 'MEDIUM';
  static const high = 'HIGH';
  static const values = [low, medium, high];
}

// ── Message Status Constants ───────────────────────────────────────────
class MessageStatus {
  static const unread = 'UNREAD';
  static const read = 'READ';
  static const values = [unread, read];
}

/// UI badge/label metadata for Message Priority.
class MessagePriorityMeta {
  static const Map<String, String> label = {
    MessagePriority.low: 'Low',
    MessagePriority.medium: 'Medium',
    MessagePriority.high: 'High',
  };

  static String labelFor(String priority) => label[priority] ?? priority;
}

// ── Message Request Model ─────────────────────────────────────────────
class MessageRequestModel {
  MessageRequestModel({
    this.recipientId,
    required this.subject,
    required this.body,
    required this.priority,
  });

  final String? recipientId;
  final String subject;
  final String body;
  final String priority; // 'LOW' | 'MEDIUM' | 'HIGH'

  Map<String, dynamic> toJson() => {
    if (recipientId != null) 'recipientId': recipientId,
    'subject': subject,
    'body': body,
    'priority': priority,
  };
}

// ── Message Response Model ────────────────────────────────────────────
class MessageResponseModel {
  MessageResponseModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.subject,
    required this.body,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String senderId;
  final String senderName;
  final String subject;
  final String body;
  final String priority; // 'LOW' | 'MEDIUM' | 'HIGH'
  final String status;   // 'UNREAD' | 'READ'
  final String createdAt;

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      id: (json['id'] ?? 0) as int,
      senderId: (json['senderId'] ?? '') as String,
      senderName: (json['senderName'] ?? '') as String,
      subject: (json['subject'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      priority: (json['priority'] ?? 'LOW') as String,
      status: (json['status'] ?? 'UNREAD') as String,
      createdAt: (json['createdAt'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'subject': subject,
    'body': body,
    'priority': priority,
    'status': status,
    'createdAt': createdAt,
  };
}

class ChatContactModel {
  ChatContactModel({
    required this.contactId,
    required this.contactName,
    required this.role,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String contactId;
  final String contactName;
  final String role;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  factory ChatContactModel.fromJson(Map<String, dynamic> json) {
    return ChatContactModel(
      contactId: (json['contactId'] ?? json['userId'] ?? json['id'] ?? '').toString(),
      contactName: (json['contactName'] ?? json['name'] ?? json['driverName'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime: json['lastMessageTime']?.toString(),
      unreadCount: json['unreadCount'] != null ? (json['unreadCount'] as num).toInt() : 0,
    );
  }
}
