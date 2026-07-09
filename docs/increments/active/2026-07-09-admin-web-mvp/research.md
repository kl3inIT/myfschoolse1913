# Admin Web Domain Research

## Rule

Do not invent admin workflows before checking comparable school portals, SIS
systems, and Vietnamese parent-school apps. Treat unsupported modules as
candidate use cases, not committed requirements.

## Sources Reviewed

| Product | Source | Useful signals |
| --- | --- | --- |
| MyFPTSchools | https://play.google.com/store/apps/details?id=com.myfptschool&hl=vi and https://apps.apple.com/vn/app/myfptschools/id1573857025 | FPT Schools parent/student app surface: notifications, grades, attendance, dormitory, timetable, contact/communication, news, clubs, rewards and discipline. |
| FPT Schools | https://fschool.fpt.edu.vn/ | Multi-campus K-12 context; school services, timetable, extracurriculars, achievements, parent handbook, and school operations matter. |
| FPT Da Nang My Fschool Student guide | https://danang12-school.fpt.edu.vn/cai-dat-my-fschool-student-2021-2022/ | Parent-school connection; campus selection; login; parent can switch students when they have multiple children. |
| vnEdu Connect | https://play.google.com/store/apps/details?id=com.vnptit.vnedu.parent&hl=vi and https://apps.apple.com/us/app/vnedu-connect/id1448464007 | Parent app includes attendance, timetable, behavior/reporting, teacher comments, messaging, notifications/news, service registration, online payment, meal menu, photos, pickup authorization, medicine reminders, health tracking. |
| SMAS / Viettel school management | https://solutions.viettel.vn/vi/giao-duc-so/he-thong-quan-ly-nha-truong-smas.html | Back-office/admin modules: school setup and input data, timetable, data-entry monitoring, data transfer/restore, student/staff records, attendance, violations, evaluation, rewards, teaching assignments, homeroom assignment, medical notebook, family-school contact, reports, catalogs. |
| Edu.One / SMAS family app | https://smsedu.smas.edu.vn/ and https://apps.apple.com/us/app/edu-one/id1191770148 | Login uses phone number/password; reset/password issuance is a service flow, not normal public student self-registration. |
| MISA EMIS / SISAP | https://newpaymentapi.qlth.vn/bao-gia/ and https://emishelp.misa.vn/kb/764/ | Modules cover admissions, student records, learning and conduct, graduation, movement, health/insurance, timetable, fee collection, library, device management, staff records. SISAP teacher attendance flow includes attendance statuses and notifying parents by student/status/all. |
| eNetViet | https://play.google.com/store/apps/details?id=enetviet.corp.qi.enetvietnew&hl=en_US | Manager/teacher/parent pattern: managers use contacts, notifications, real-time reports/statistics, QR meeting attendance; teachers input data and communicate with parents; parents receive school data. |
| OpenEduCat | https://openeducat.org/features/ and https://openeducat.org/open-source-education-erp/ | Generic school ERP pattern: SIS, LMS, attendance, fees, timetable, parent portal, exams, gradebook, mobile access to grades/attendance/timetables/assignments/fees/library/push notifications, role-based permissions. |
| PowerSchool SIS | https://www.powerschool.com/products/student-information/sis/ and https://go.powerschool.com/rs/861-RMI-846/images/PowerSchool-Portfolio-SISs_Overview_Flyer.pdf | SIS pattern: centralized enrollment, student records, schedules, attendance, grades, portals, payments, teacher communication, reports, health, incidents/discipline, importing/exporting. |

## Repeated Domain Patterns

### 1. Identity, roles, and provisioning

Comparable systems do not treat student/parent portal access as an ordinary
public signup flow. Accounts are tied to school records and often recovered or
issued through school staff, homeroom teachers, or a service flow.

Project implication:

- Keep "no public student registration" as a valid rule.
- Admin import/provisioning is a legitimate first slice because every downstream
  module needs trusted student identity, class, academic year, and contact data.

### 2. Master data before workflows

Admin systems first need reliable school structure:

- campus/school;
- academic year;
- grade level;
- class;
- student;
- staff/teacher;
- parent/guardian contact;
- homeroom and teaching assignment.

Project implication:

- After student import, the next admin work should probably be class/year master
  data and teacher assignment, not random dashboard widgets.

### 3. Student records and lifecycle

Repeated student-record modules:

- profile/demographics;
- enrollment/admission;
- class assignment;
- academic status;
- student movement/transfer;
- graduation or completion;
- health and insurance.

Project implication:

- Do not collapse `Student` into only login data. Account and student profile are
  related but not the same business object.

### 4. Timetable and teaching assignment

SMAS, vnEdu, MISA EMIS, OpenEduCat, PowerSchool, and MyFPTSchools all point to
timetable/scheduling as a core school operation.

Project implication:

- Timetable is a strong candidate after master data.
- Admin side owns importing/maintaining timetable data; mobile side displays it.

### 5. Attendance

Attendance appears across every comparable system. MISA SISAP shows a teacher
flow with statuses like late, excused, and unexcused, plus parent notification.

Project implication:

- Attendance likely needs teacher/staff data-entry workflow later.
- For admin MVP, keep it as candidate import/manage/reporting rather than
  building a full teacher UI immediately.

### 6. Grades, conduct, rewards, and discipline

MyFPTSchools exposes grades and rewards/discipline. SMAS includes assessment,
violations, evaluation, and rewards. MISA EMIS includes learning/conduct and
graduation.

Project implication:

- Grade import/display is a strong student-facing and admin-facing candidate.
- Rewards/discipline is real domain vocabulary, but not MVP unless teacher asks.

### 7. Notifications and family-school communication

All comparable apps emphasize notices, news, messaging, contact, and parent
communication.

Project implication:

- Admin "notifications/news publishing" is a strong candidate.
- Chat/messaging should not be added casually; it has more workflow and
  moderation complexity than one-way notices.

### 8. Services, payments, meals, health, hostel/transport

vnEdu includes service registration, payment, meal menu, pickup authorization,
medicine reminders, and health tracking. MyFPTSchools includes dormitory.
OpenEduCat and PowerSchool include fees/payments, library, health, and other
service modules.

Project implication:

- These are real school-platform modules, but they are not basic MVP unless the
  teacher requires them.
- Hostel/dormitory should be modeled only if FPT Schools scope for this class
  project explicitly includes boarding/dorm data.

## Use Case Backlog From Evidence

### High-confidence for this project

1. Admin login and role-gated admin web.
2. Import/provision student accounts.
3. Maintain student profile fields separately from auth fields.
4. Manage academic year, class, and class assignment.
5. Import or maintain timetable data for display in mobile.
6. Publish school notifications/news.
7. Import or maintain grade/semester result data.

### Medium-confidence candidates

1. Attendance records and attendance reports.
2. Teacher/homeroom assignment.
3. Parent/guardian contact linking.
4. Rewards and discipline records.
5. Clubs and extracurricular enrollment.
6. Applications/leave requests.

### Low-confidence / defer until requirement is explicit

1. Payments and fee collection.
2. Meal services.
3. Pickup authorization.
4. Medicine reminders and health workflows.
5. Dormitory/hostel.
6. Transport.
7. Chat or full messaging.
8. Admissions/public application workflow.

## MVP Boundary

The current admin MVP should stay narrow:

1. Admin login.
2. Student account import.
3. Student/class/year data capture.
4. Import result review.

Do not implement broad admin modules until the next screen is selected from the
evidence-backed backlog above.
