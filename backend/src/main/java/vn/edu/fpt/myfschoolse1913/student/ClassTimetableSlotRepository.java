package vn.edu.fpt.myfschoolse1913.student;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

public interface ClassTimetableSlotRepository extends JpaRepository<ClassTimetableSlot, UUID> {

	@Query(
			value = """
					select slot
					from ClassTimetableSlot slot
					join fetch slot.schoolClass schoolClass
					join fetch schoolClass.academicYear academicYear
					join fetch slot.semester semester
					left join fetch slot.subject subject
					where :search = ''
						or lower(schoolClass.name) like concat('%', :search, '%')
						or lower(slot.title) like concat('%', :search, '%')
						or lower(coalesce(slot.roomName, '')) like concat('%', :search, '%')
						or lower(coalesce(slot.teacherName, '')) like concat('%', :search, '%')
						or lower(coalesce(subject.code, '')) like concat('%', :search, '%')
					""",
			countQuery = """
					select count(slot)
					from ClassTimetableSlot slot
					join slot.schoolClass schoolClass
					left join slot.subject subject
					where :search = ''
						or lower(schoolClass.name) like concat('%', :search, '%')
						or lower(slot.title) like concat('%', :search, '%')
						or lower(coalesce(slot.roomName, '')) like concat('%', :search, '%')
						or lower(coalesce(slot.teacherName, '')) like concat('%', :search, '%')
						or lower(coalesce(subject.code, '')) like concat('%', :search, '%')
					"""
	)
	Page<ClassTimetableSlot> searchForAdmin(@Param("search") String search, Pageable pageable);

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
