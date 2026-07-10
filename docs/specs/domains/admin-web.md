# Admin Web

Current behavior of the React admin surface in `admin-web/` and its backend
admin APIs. Product intent lives in
`docs/increments/active/2026-07-09-admin-web-mvp/`.

## Login

- Route `/login`; phone number + password against `POST /api/auth/login`.
- The form is the official shadcn `login-01` block (`Field` components in
  `src/components/login-form.tsx`) adapted to phone/password and Vietnamese
  copy; non-`ADMIN` accounts are rejected client-side after login.
- Session (tokens + user) is stored in `localStorage` under
  `myfschool_admin_session`.
- Authorized requests clear the stored session on 401/403 and immediately
  redirect to `/login` (hard navigation, skipped when already on `/login`).
- Backend gates `/api/admin/**` with `ROLE_ADMIN` (`SecurityConfig`).

## Dashboard

- Route `/` ("Tổng quan" in the sidebar) — the landing page after login.
- Four stat cards reuse existing stats endpoints (no dashboard-specific
  API): total students, class count, pending applications, locked accounts.
- Two panels: "Đơn từ chờ duyệt" (top 5 pending applications) and
  "Thông báo mới nhất" (5 latest notifications, recalled ones muted with a
  badge), each with a "Xem tất cả" link to the resource page. Dashboard
  queries live under the same `['admin-*']` prefixes, so mutations made on
  other pages refresh it.
- The student list moved from `/` to `/students`; detail stays at
  `/students/:studentId` and back-links target `/students`.

## Student Import

- `POST /api/admin/students/import` creates or updates `STUDENT` accounts plus
  linked `students` rows; academic year and class are created on demand.
- The import sheet parses CSV client-side (required columns `studentCode`,
  `fullName`, `phoneNumber`; optional `academicYearName`, `className`,
  `password`, `status`), previews rows, and applies form defaults for year,
  class, and temporary password.
- Dropzones (students and grades) also accept Excel (`.xlsx`/`.xls`): the
  first sheet is converted to CSV client-side via SheetJS
  (`lib/spreadsheet.ts`) and flows through the same CSV parser.
- After a successful import the sheet switches to a result view: summary tiles
  (created users, created students, updated, skipped) and a per-row table with
  CREATED/UPDATED/SKIPPED badges and messages. The student list query is
  invalidated so the table refreshes.

## Student List

- `GET /api/admin/students?search=&page=&size=` returns
  `{page, size, totalItems, totalPages, items[]}` sorted by `studentCode`.
- Each item: `id`, `studentCode`, `fullName`, `phoneNumber`, `className`,
  `academicYearName`, `status`, `accountEnabled`.
- `search` matches student code, full name, phone number, or class name
  (case-insensitive contains). `size` is clamped to 1..200, default 20.
- `GET /api/admin/students/stats` returns
  `{totalStudents, activeStudents, lockedAccounts, totalClasses}`;
  `activeStudents` counts status `Đang học`.
- The page (`StudentManagementPage`) shows four stat cards from the stats
  endpoint, a 300 ms debounced search box, and 20-row pages with prev/next
  paging. The grid is the shared TanStack-Table-based `DataTable`
  (`features/students/columns.tsx` defines the columns; mã/tên/lớp are
  client-sortable) and the pagination bar is fixed at the bottom of the
  viewport-height panel. Clicking a row navigates to the student detail
  route; a trailing actions column offers icon buttons Xem (detail) and Sửa
  (detail with `?edit=true`, which opens edit mode immediately). Both list
  and stats queries share the `['admin-students']` key prefix and refresh
  after an import.

## Academic Year And Class Master Data

- Route `/classes` ("Lớp học" in the sidebar).
- `GET /api/admin/academic-years` returns all years (current year first, then
  name descending), each with its classes sorted by name and per-class student
  counts.
- `POST /api/admin/academic-years` creates a year (`name` ≤40 unique — 409 on
  duplicate; optional `startsOn`/`endsOn` ISO dates; `currentYear` flag). When
  `currentYear` is true, the previous current year is unset.
- `POST /api/admin/academic-years/{yearId}/classes` creates a class in a year
  (`name` ≤40, unique per year — 409 on duplicate; 404 for unknown year).
- The page shows one card per year (date range, class count, total students,
  "Năm hiện tại" badge, inline add-class form); "Thêm năm học" is a header
  action opening a centered dialog. CSV import still auto-creates missing
  years/classes by name; this page makes that master data visible and
  manageable.

## Grade List And Import

- Route `/grades` ("Điểm số" in the sidebar).
- `GET /api/admin/grades?search=&page=&size=` returns
  `{page, size, totalItems, totalPages, items[]}` sorted by `updatedAt`
  descending (latest imports first). Each item: `id`, `studentCode`,
  `fullName`, `className`, `academicYearName`, `semesterName`, `subjectCode`,
  `subjectName`, component scores (`formativeScore`/`midtermScore`/
  `finalScore`), `averageScore`, `teacherComment`, `updatedAt`. `search`
  matches student code, full name, class name, subject code, or subject name
  (case-insensitive contains); `size` is clamped to 1..200, default 20.
- `POST /api/admin/grades/import` takes `{academicYearName, semesterName,
  grades[]}` (max 500 rows). The year must exist (404 otherwise); the semester
  is resolved by name within the year and auto-created when missing (it
  becomes the year's current semester if none is marked yet).
- Each row: `studentCode` + `subjectCode` required; optional `subjectName`
  (used to auto-create an unknown subject — without it the row is skipped),
  `formativeScore`/`midtermScore`/`finalScore`/`averageScore` (0..10), and
  `teacherComment`.
- When `averageScore` is blank the server computes a weighted average over
  the provided components (TX ×1, GK ×2, CK ×3, one decimal, HALF_UP). Rows
  with no scores at all are skipped. `detail` is generated as
  `TX x · GK y · CK z`.
- Upsert per (student, semester, subject): existing grades are updated
  (UPDATED), new ones created (CREATED); duplicates within the file and
  unknown students are SKIPPED with a Vietnamese reason.
- The page (`GradeManagementPage`) follows the list pattern: a 300 ms
  debounced search box plus toolbar actions "Tải mẫu CSV" and "Nhập điểm"
  above the shared `DataTable` (`features/grades/columns.tsx`; mã/tên/lớp/môn
  and TB are client-sortable) with the pagination bar fixed at the bottom.
- The import sheet holds year/semester defaults, a CSV/Excel dropzone, an
  editable CSV textarea, a validation alert, and a preview table. After
  submit the sheet switches to a result view (summary tiles Ghi mới/Đã cập
  nhật/Bị bỏ qua + per-row table with badges) and the `['admin-grades']`
  queries are invalidated so the list refreshes. The student app reflects
  imported grades immediately in the semester grades screen.

## Timetable List And Import

- Route `/timetable` ("Thời khóa biểu" in the sidebar).
- `GET /api/admin/timetable?search=&page=&size=` returns
  `{page, size, totalItems, totalPages, items[]}` sorted by class name, then
  day, then lesson number. Each item: `id`, `className`, `academicYearName`,
  `semesterName`, `dayIndex` (1 = Monday .. 7 = Sunday), `lessonNumber`,
  `slotType` (`SUBJECT|MEAL|ACTIVITY`), `title`, `subjectCode`, `roomName`,
  `teacherName`, `startsAt`/`endsAt` (`HH:mm`), `updatedAt`. `search` matches
  class name, title, room, teacher, or subject code; `size` clamped 1..200.
- `POST /api/admin/timetable/import` takes `{academicYearName, semesterName,
  defaultClassName?, slots[]}` (max 500 rows). The year must exist (404); the
  semester is resolved by name and auto-created when missing (same rule as
  grade import); classes are auto-created within the year by name.
- Each row: `dayIndex` (1..7) + `lessonNumber` (1..20) + `startsAt`/`endsAt`
  (`HH:mm`, end must be after start) required; `className` falls back to
  `defaultClassName` (row skipped when both are blank); `slotType` defaults
  to `SUBJECT`; `title` falls back to the subject name (skipped when neither
  is present); an unknown `subjectCode` needs `subjectName` to auto-create
  the subject.
- Upsert per (class, semester, day, lesson): existing slots are UPDATED, new
  ones CREATED; in-file duplicates and invalid rows are SKIPPED with a
  Vietnamese reason.
- The page (`TimetableManagementPage`) follows the list pattern: debounced
  search + toolbar actions "Tải mẫu CSV" and "Nhập TKB" (sheet with
  year/semester/default-class fields, CSV/Excel dropzone, editable textarea,
  validation alert, preview). After submit the sheet switches to a result
  view and `['admin-timetable']` queries are invalidated. The student app
  reflects imported slots immediately in the schedule and dashboard APIs.
- A toolbar toggle switches between "Danh sách" (the DataTable) and
  "Lưới tuần" (`features/timetable/weekly-grid.tsx`): a read-only weekly
  matrix (columns = days with slots, rows = lesson numbers) for one class
  (select fed by the academic-years endpoint) and semester (select shown
  when the class has more than one), with cells colored by slot type
  (SUBJECT = primary, MEAL = muted, ACTIVITY = sky). Built with plain CSS
  grid — no calendar library; the OpenEduCat-style multi-view pattern for
  the same resource.

## Application Review

- Route `/applications` ("Đơn từ" in the sidebar).
- `GET /api/admin/applications?search=&status=&page=&size=` returns
  `{page, size, totalItems, totalPages, items[]}` sorted by `createdAt`
  descending. Each item: `id`, student identity (code/name/class/year),
  `type` (`ABSENCE|LATE_ARRIVAL|EARLY_LEAVE|DOCUMENT_REQUEST|EARLY_PICKUP|
  MEAL_REGISTRATION`), `status` (`PENDING|APPROVED|REJECTED`), `targetDate`,
  `requestedTime`, `reason`, `details`, `reviewerNote`, `createdAt`,
  `reviewedAt`. `search` matches student code, name, class, or reason;
  `status` filters by one status (400 on an unknown value, blank = all);
  `size` clamped 1..200.
- `GET /api/admin/applications/stats` returns
  `{totalApplications, pendingApplications, approvedApplications,
  rejectedApplications}`.
- `PUT /api/admin/applications/{id}` reviews a pending application:
  `{decision: APPROVED|REJECTED, reviewerNote?}` (note ≤500). 404 for an
  unknown id, 409 when the application was already reviewed, 400 when the
  decision is `PENDING`. The review stamps `reviewedAt` and the student app
  sees the new status on next fetch (reviewer note stays admin-only).
- The page (`ApplicationManagementPage`) shows four stat cards, a debounced
  search box plus a status filter select (defaults to "Chờ duyệt"), and the
  shared `DataTable` with status badges and the reviewer note under the
  badge. Pending rows expose inline "Duyệt"/"Từ chối" actions that open a
  centered confirm dialog (application summary + optional reviewer note);
  confirming invalidates the `['admin-applications']` queries.

## Notification Publishing

- Route `/notifications`, reachable from the sidebar (every sidebar item is
  a real link with route-based active state; no placeholders remain).
- `POST /api/admin/notifications` publishes a `SchoolNotification`
  (`title` ≤160, `body` ≤1000, category `ACADEMIC|EVENT|SERVICE|GENERAL`,
  audience `ALL_STUDENTS|HIGH_SCHOOL`, optional `pinned`); `publishedAt` is
  server time and the notification is active immediately, so the student app
  sees it on next fetch.
- `GET /api/admin/notifications?page=&size=` lists all notifications
  (including deactivated) newest-first; size clamped to 1..100, default 20.
- `DELETE /api/admin/notifications/{id}` soft-deactivates (thu hồi): the row
  stays in the admin list with a "Đã thu hồi" badge but disappears from the
  student API. 404 when the id is unknown or already deactivated.
- The page is a full-width published list rendered through the shared
  `DataTable` (`features/notifications/columns.tsx`; tiêu đề/đăng lúc are
  client-sortable, pin icon, recall button per active row, deactivated rows
  muted); "Đăng thông báo" is a header action opening a centered dialog
  with the publish form (react-hook-form + zod, category and audience
  selects, pinned checkbox). Publishing closes the dialog and invalidates the
  `['admin-notifications']` query.

## Student Detail And Edit

- Route `/students/:studentId` backed by `GET /api/admin/students/{id}`
  (404 with a Vietnamese message when missing).
- The page shows profile, class, and login-account cards plus status badges
  (`Đang học` default badge, locked accounts destructive) and a back link to
  the list. Unknown ids render a not-found empty state instead of a crash.
- "Chỉnh sửa" switches the cards to in-place edit mode (Jmix-style): the same
  fields render as inputs, with Lưu/Hủy in the page header. Extra edit-only
  fields: new password (blank keeps the current one) and an account-enabled
  checkbox.
- `PUT /api/admin/students/{id}` updates full name, phone, student code,
  year/class, status, and account enabled; optionally re-encodes a new
  password. Conflicts return 409 (phone belongs to another account, student
  code belongs to another student); the year must exist (404) and the class
  is auto-created inside it when missing.
