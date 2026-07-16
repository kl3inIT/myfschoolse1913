import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/models/parent_workspace_dto.dart';

void main() {
  test('maps linked children and published school data', () {
    final workspace = ParentWorkspaceDto.fromJson({
      'children': [
        {
          'id': 'student-1',
          'studentCode': 'FS26-0001',
          'fullName': 'Nguyễn Minh Anh',
          'className': '10A1',
          'relationship': 'MOTHER',
          'primaryContact': true,
        },
      ],
      'selectedChild': {
        'child': {
          'id': 'student-1',
          'studentCode': 'FS26-0001',
          'fullName': 'Nguyễn Minh Anh',
          'className': '10A1',
          'relationship': 'MOTHER',
          'primaryContact': true,
        },
        'academicYear': '2026-2027',
        'semester': 'Học kỳ 1',
        'schedule': <Object?>[],
        'grades': [
          {
            'subjectId': 'math',
            'subjectName': 'Toán học',
            'average': 8.6,
            'assessments': [
              {
                'type': 'REGULAR',
                'sequenceNumber': 1,
                'title': 'Kiểm tra thường xuyên 1',
                'score': 8.0,
                'comment': null,
              },
            ],
          },
        ],
        'attendance': <Object?>[],
        'conduct': <Object?>[],
        'applications': <Object?>[],
        'notifications': <Object?>[],
      },
    }).toDomain();

    expect(workspace.children.single.fullName, 'Nguyễn Minh Anh');
    expect(workspace.selectedChild?.grades.single.average, 8.6);
    expect(
      workspace.selectedChild?.grades.single.assessments.single.score,
      8.0,
    );
  });
}
