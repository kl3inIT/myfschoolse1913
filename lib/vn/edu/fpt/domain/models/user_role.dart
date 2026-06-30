enum UserRole {
  parent,
  student,
  teacher,
  admin;

  factory UserRole.fromApi(String value) {
    return switch (value.toUpperCase()) {
      'PARENT' => UserRole.parent,
      'STUDENT' => UserRole.student,
      'TEACHER' => UserRole.teacher,
      'ADMIN' => UserRole.admin,
      _ => throw ArgumentError.value(value, 'value', 'Unknown user role'),
    };
  }
}

extension UserRoleLabel on UserRole {
  String get label {
    return switch (this) {
      UserRole.parent => 'Phụ huynh',
      UserRole.student => 'Học sinh',
      UserRole.teacher => 'Giáo viên',
      UserRole.admin => 'Quản trị viên',
    };
  }
}
