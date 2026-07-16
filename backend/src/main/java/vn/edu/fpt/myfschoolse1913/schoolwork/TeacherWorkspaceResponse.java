package vn.edu.fpt.myfschoolse1913.schoolwork;

import java.util.List;
import java.util.UUID;

public record TeacherWorkspaceResponse(
    UUID teacherId,
    String employeeCode,
    String fullName,
    List<AdminSchoolWorkResponse.TeachingAssignmentItem> teachingAssignments,
    List<AdminSchoolWorkResponse.HomeroomAssignmentItem> homeroomAssignments) {}
