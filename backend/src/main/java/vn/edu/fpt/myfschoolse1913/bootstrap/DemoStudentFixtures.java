package vn.edu.fpt.myfschoolse1913.bootstrap;

import java.util.List;

final class DemoStudentFixtures {

	static final String DEFAULT_PASSWORD = "Password123";
	static final String ADMIN_PHONE = "0900000000";
	static final String DEMO_STUDENT_PHONE = "0900000001";

	static final List<StudentFixture> STUDENTS = List.of(
			student(1, "Nguyễn Minh Anh", "10A1"),
			student(2, "Trần Gia Huy", "10A1"),
			student(3, "Lê Khánh Linh", "10A1"),
			student(4, "Phạm Nhật Minh", "10A1"),
			student(5, "Hoàng Ngọc Anh", "10A1"),
			student(6, "Vũ Đức Anh", "10A1"),
			student(7, "Đặng Thu Hà", "10A1"),
			student(8, "Bùi Quang Huy", "10A1"),
			student(9, "Đỗ Minh Châu", "10A1"),
			student(10, "Hồ Tuấn Kiệt", "10A1"),
			student(11, "Ngô Phương Thảo", "10A1"),
			student(12, "Dương Hải Nam", "10A1"),
			student(13, "Nguyễn Thảo Vy", "10A2"),
			student(14, "Trần Minh Khang", "10A2"),
			student(15, "Lê Hoàng Anh", "10A2"),
			student(16, "Phạm Gia Bảo", "10A2"),
			student(17, "Võ Khánh An", "10A2"),
			student(18, "Mai Đức Long", "10A2"),
			student(19, "Tạ Ngọc Mai", "10A2"),
			student(20, "Trịnh Quốc Bảo", "10A2"),
			student(21, "Cao Minh Thư", "10A2"),
			student(22, "Lý Tuấn Anh", "10A2"),
			student(23, "Nguyễn Hà My", "10A2"),
			student(24, "Trần Đức Minh", "10A2"),
			student(25, "Lê Ngọc Hân", "11A1"),
			student(26, "Phạm Anh Khoa", "11A1"),
			student(27, "Hoàng Minh Ngọc", "11A1"),
			student(28, "Vũ Quỳnh Anh", "11A1"),
			student(29, "Đặng Gia Khánh", "11A1"),
			student(30, "Bùi Thanh Trúc", "11A1"),
			student(31, "Đỗ Đức Mạnh", "11A1"),
			student(32, "Hồ Bảo Ngọc", "11A1"),
			student(33, "Ngô Minh Triết", "11A1", "Bảo lưu", true),
			student(34, "Dương Khánh Vy", "11A1", "Chuyển trường", true),
			student(35, "Nguyễn Hải Đăng", "11A1", "Đang học", false),
			student(36, "Trần Phương Linh", "11A1", "Bảo lưu", false)
	);

	private DemoStudentFixtures() {
	}

	private static StudentFixture student(int number, String fullName, String className) {
		return student(number, fullName, className, "Đang học", true);
	}

	private static StudentFixture student(
			int number,
			String fullName,
			String className,
			String status,
			boolean enabled
	) {
		return new StudentFixture(
				number,
				"090000%04d".formatted(number),
				"FS26-%04d".formatted(number),
				fullName,
				className,
				status,
				enabled
		);
	}

	record StudentFixture(
			int number,
			String phoneNumber,
			String studentCode,
			String fullName,
			String className,
			String status,
			boolean enabled
	) {
	}
}
