package vn.edu.fpt.myfschoolse1913.document;

import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SchoolDocumentRepository extends JpaRepository<SchoolDocument, UUID> {

	// :search rides as '' (never null) and pre-lowercased — a null String
	// parameter binds as bytea on PostgreSQL and breaks lower().
	@Query("""
			select document
			from SchoolDocument document
			where :search = ''
				or lower(document.title) like concat('%', :search, '%')
				or lower(document.fileName) like concat('%', :search, '%')
				or lower(coalesce(document.subjectName, '')) like concat('%', :search, '%')
			""")
	Page<SchoolDocument> searchForAdmin(@Param("search") String search, Pageable pageable);

	@Query("""
			select document
			from SchoolDocument document
			where document.category = :category
				and (:search = ''
					or lower(document.title) like concat('%', :search, '%')
					or lower(document.fileName) like concat('%', :search, '%')
					or lower(coalesce(document.subjectName, '')) like concat('%', :search, '%'))
			""")
	Page<SchoolDocument> searchForAdminByCategory(
			@Param("search") String search,
			@Param("category") SchoolDocumentCategory category,
			Pageable pageable
	);
}
