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

## Notification Publishing

- Route `/notifications`, reachable from the sidebar ("Học sinh" and
  "Thông báo" are real links with route-based active state; "Tổng quan" and
  "Đơn từ" remain disabled placeholders).
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
