import 'package:flutter/foundation.dart';

@immutable
class StudentNotifications {
  const StudentNotifications({required this.notifications});

  final List<StudentNotification> notifications;
}

@immutable
class StudentNotification {
  const StudentNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.publishedAt,
    required this.pinned,
    required this.read,
  });

  final String id;
  final String title;
  final String body;
  final StudentNotificationCategory category;
  final DateTime publishedAt;
  final bool pinned;
  final bool read;
}

@immutable
class StudentNotificationDetail {
  const StudentNotificationDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.publishedAt,
    required this.pinned,
    required this.read,
  });

  final String id;
  final String title;
  final String body;
  final StudentNotificationCategory category;
  final DateTime publishedAt;
  final bool pinned;
  final bool read;
}

enum StudentNotificationCategory {
  academic('ACADEMIC', 'Học tập'),
  event('EVENT', 'Sự kiện'),
  service('SERVICE', 'Dịch vụ'),
  general('GENERAL', 'Chung');

  const StudentNotificationCategory(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static StudentNotificationCategory fromWireValue(String value) {
    return switch (value) {
      'ACADEMIC' => StudentNotificationCategory.academic,
      'EVENT' => StudentNotificationCategory.event,
      'SERVICE' => StudentNotificationCategory.service,
      _ => StudentNotificationCategory.general,
    };
  }
}
