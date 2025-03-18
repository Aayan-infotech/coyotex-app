enum NotificationType {
  tripUpdate,
  huntAlert,
  weatherAlert,
  photoReminder,
  safetyNotification,
  tripSummary;

  factory NotificationType.fromString(String value) {
    switch (value) {
      case 'trip_update':
        return NotificationType.tripUpdate;
      case 'hunt_alert':
        return NotificationType.huntAlert;
      case 'weather_alert':
        return NotificationType.weatherAlert;
      case 'photo_reminder':
        return NotificationType.photoReminder;
      case 'safety_notification':
        return NotificationType.safetyNotification;
      case 'trip_summary':
        return NotificationType.tripSummary;
      default:
        throw ArgumentError('Invalid notification type: $value');
    }
  }
  String toJson() {
    switch (this) {
      case NotificationType.tripUpdate:
        return 'trip_update';
      case NotificationType.huntAlert:
        return 'hunt_alert';
      case NotificationType.weatherAlert:
        return 'weather_alert';
      case NotificationType.photoReminder:
        return 'photo_reminder';
      case NotificationType.safetyNotification:
        return 'safety_notification';
      case NotificationType.tripSummary:
        return 'trip_summary';
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final String createdAt;
  final int v;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
    required this.v,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: NotificationType.fromString(json['type'] ?? ''),
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toJson(),
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt,
      '__v': v,
    };
  }
}
