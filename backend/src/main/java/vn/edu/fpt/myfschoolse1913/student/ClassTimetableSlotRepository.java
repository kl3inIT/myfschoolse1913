package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

public interface ClassTimetableSlotRepository extends JpaRepository<ClassTimetableSlot, UUID> {

	List<ClassTimetableSlot> findBySchoolClassAndSemesterOrderByDayIndexAscLessonNumberAsc(
			SchoolClass schoolClass,
			Semester semester
	);

	List<ClassTimetableSlot> findBySchoolClassAndSemesterAndDayIndexOrderByLessonNumberAsc(
			SchoolClass schoolClass,
			Semester semester,
			short dayIndex
	);

	Optional<ClassTimetableSlot> findBySchoolClassAndSemesterAndDayIndexAndLessonNumber(
			SchoolClass schoolClass,
			Semester semester,
			short dayIndex,
			int lessonNumber
	);

	@Transactional
	void deleteBySchoolClassAndSemester(SchoolClass schoolClass, Semester semester);
}
