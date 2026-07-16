class ParentWorkspace {
  const ParentWorkspace({required this.children, required this.selectedChild});

  final List<ParentChild> children;
  final ParentChildDetails? selectedChild;
}

class ParentChild {
  const ParentChild({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.className,
    required this.relationship,
    required this.primaryContact,
  });

  final String id;
  final String studentCode;
  final String fullName;
  final String className;
  final String relationship;
  final bool primaryContact;
}

class ParentChildDetails {
  const ParentChildDetails({
    required this.child,
    required this.academicYear,
    required this.semester,
    required this.schedule,
    required this.grades,
    required this.attendance,
    required this.conduct,
    required this.applications,
    required this.notifications,
  });

  final ParentChild child;
  final String academicYear;
  final String? semester;
  final List<ParentScheduleItem> schedule;
  final List<ParentSubjectGrade> grades;
  final List<ParentAttendanceItem> attendance;
  final List<ParentConductItem> conduct;
  final List<ParentApplicationItem> applications;
  final List<ParentNotificationItem> notifications;
}

class ParentScheduleItem {
  const ParentScheduleItem({
    required this.dayIndex,
    required this.lessonNumber,
    required this.title,
    required this.roomName,
    required this.teacherName,
    required this.startsAt,
    required this.endsAt,
  });

  final int dayIndex;
  final int lessonNumber;
  final String title;
  final String? roomName;
  final String? teacherName;
  final String startsAt;
  final String endsAt;
}

class ParentSubjectGrade {
  const ParentSubjectGrade({
    required this.subjectName,
    required this.assessments,
    required this.average,
  });

  final String subjectName;
  final List<ParentAssessmentItem> assessments;
  final double? average;
}

class ParentAssessmentItem {
  const ParentAssessmentItem({
    required this.type,
    required this.sequenceNumber,
    required this.title,
    required this.score,
    required this.comment,
  });

  final String type;
  final int sequenceNumber;
  final String title;
  final double? score;
  final String? comment;
}

class ParentAttendanceItem {
  const ParentAttendanceItem({
    required this.date,
    required this.lessonNumber,
    required this.subjectName,
    required this.status,
    required this.note,
  });

  final DateTime date;
  final int lessonNumber;
  final String subjectName;
  final String status;
  final String? note;
}

class ParentConductItem {
  const ParentConductItem({
    required this.semesterName,
    required this.level,
    required this.comment,
  });

  final String semesterName;
  final String level;
  final String? comment;
}

class ParentApplicationItem {
  const ParentApplicationItem({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.requestedTime,
    required this.reason,
    required this.reviewerNote,
  });

  final String id;
  final String type;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? requestedTime;
  final String reason;
  final String? reviewerNote;
}

class ParentNotificationItem {
  const ParentNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.publishedAt,
    required this.pinned,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime publishedAt;
  final bool pinned;
}
