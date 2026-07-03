import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';

class StudentNotificationsDto {
  const StudentNotificationsDto({required this.notifications});

  factory StudentNotificationsDto.fromJson(Map<String, Object?> json) {
    return StudentNotificationsDto(
      notifications: (json['notifications'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(StudentNotificationDto.fromJson)
          .toList(growable: false),
    );
  }

  final List<StudentNotificationDto> notifications;

  StudentNotifications toDomain() {
    return StudentNotifications(
      notifications: notifications
          .map((notification) => notification.toDomain())
          .toList(growable: false),
    );
  }
}

class StudentNotificationDto {
  const StudentNotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.publishedAt,
    required this.pinned,
  });

  factory StudentNotificationDto.fromJson(Map<String, Object?> json) {
    return StudentNotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String? ?? 'GENERAL',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      pinned: json['pinned'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime publishedAt;
  final bool pinned;

  StudentNotification toDomain() {
    return StudentNotification(
      id: id,
      title: title,
      body: body,
      category: StudentNotificationCategory.fromWireValue(category),
      publishedAt: publishedAt,
      pinned: pinned,
    );
  }
}
