package vn.edu.fpt.myfschoolse1913.event;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.edu.fpt.myfschoolse1913.student.AcademicYear;
import vn.edu.fpt.myfschoolse1913.student.SchoolClass;

public interface SchoolEventRepository extends JpaRepository<SchoolEvent, UUID> {

	@Query("""
			select event
			from SchoolEvent event
			where event.published = true
				and event.academicYear = :academicYear
				and (event.schoolClass is null or event.schoolClass = :schoolClass)
			order by event.startsAt
			""")
	List<SchoolEvent> findVisibleEvents(
			@Param("academicYear") AcademicYear academicYear,
			@Param("schoolClass") SchoolClass schoolClass
	);

	Optional<SchoolEvent> findByTitleAndStartsAt(String title, Instant startsAt);
}
