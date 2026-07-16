import 'package:myfschoolse1913/vn/edu/fpt/domain/models/parent_workspace.dart';

class ParentWorkspaceDto {
  const ParentWorkspaceDto({required this.json});

  factory ParentWorkspaceDto.fromJson(Map<String, Object?> json) {
    return ParentWorkspaceDto(json: json);
  }

  final Map<String, Object?> json;

  ParentWorkspace toDomain() {
    final children = _list(
      json['children'],
    ).map((item) => _child(_map(item))).toList();
    final selectedJson = json['selectedChild'];
    return ParentWorkspace(
      children: children,
      selectedChild: selectedJson is Map<String, Object?>
          ? _details(selectedJson)
          : null,
    );
  }

  ParentChildDetails _details(Map<String, Object?> value) {
    return ParentChildDetails(
      child: _child(_map(value['child'])),
      academicYear: _string(value['academicYear']),
      semester: value['semester'] as String?,
      schedule: _list(value['schedule']).map((item) {
        final map = _map(item);
        return ParentScheduleItem(
          dayIndex: _int(map['dayIndex']),
          lessonNumber: _int(map['lessonNumber']),
          title: _string(map['title']),
          roomName: map['roomName'] as String?,
          teacherName: map['teacherName'] as String?,
          startsAt: _string(map['startsAt']),
          endsAt: _string(map['endsAt']),
        );
      }).toList(),
      grades: _list(value['grades']).map((item) {
        final map = _map(item);
        return ParentSubjectGrade(
          subjectName: _string(map['subjectName']),
          average: _doubleOrNull(map['average']),
          assessments: _list(map['assessments']).map((assessment) {
            final assessmentMap = _map(assessment);
            return ParentAssessmentItem(
              type: _string(assessmentMap['type']),
              sequenceNumber: _int(assessmentMap['sequenceNumber']),
              title: _string(assessmentMap['title']),
              score: _doubleOrNull(assessmentMap['score']),
              comment: assessmentMap['comment'] as String?,
            );
          }).toList(),
        );
      }).toList(),
      attendance: _list(value['attendance']).map((item) {
        final map = _map(item);
        return ParentAttendanceItem(
          date: DateTime.parse(_string(map['date'])),
          lessonNumber: _int(map['lessonNumber']),
          subjectName: _string(map['subjectName']),
          status: _string(map['status']),
          note: map['note'] as String?,
        );
      }).toList(),
      conduct: _list(value['conduct']).map((item) {
        final map = _map(item);
        return ParentConductItem(
          semesterName: _string(map['semesterName']),
          level: _string(map['level']),
          comment: map['comment'] as String?,
        );
      }).toList(),
      applications: _list(value['applications']).map((item) {
        final map = _map(item);
        return ParentApplicationItem(
          id: _string(map['id']),
          type: _string(map['type']),
          status: _string(map['status']),
          startDate: DateTime.parse(_string(map['startDate'])),
          endDate: DateTime.parse(_string(map['endDate'])),
          requestedTime: map['requestedTime'] as String?,
          reason: _string(map['reason']),
          reviewerNote: map['reviewerNote'] as String?,
        );
      }).toList(),
      notifications: _list(value['notifications']).map((item) {
        final map = _map(item);
        return ParentNotificationItem(
          id: _string(map['id']),
          title: _string(map['title']),
          body: _string(map['body']),
          category: _string(map['category']),
          publishedAt: DateTime.parse(_string(map['publishedAt'])),
          pinned: map['pinned'] == true,
        );
      }).toList(),
    );
  }

  ParentChild _child(Map<String, Object?> value) {
    return ParentChild(
      id: _string(value['id']),
      studentCode: _string(value['studentCode']),
      fullName: _string(value['fullName']),
      className: _string(value['className']),
      relationship: _string(value['relationship']),
      primaryContact: value['primaryContact'] == true,
    );
  }

  List<Object?> _list(Object? value) => value is List ? value : const [];
  Map<String, Object?> _map(Object? value) =>
      value is Map<String, Object?> ? value : const {};
  String _string(Object? value) => value?.toString() ?? '';
  int _int(Object? value) => value is num ? value.toInt() : 0;
  double? _doubleOrNull(Object? value) =>
      value is num ? value.toDouble() : null;
}
