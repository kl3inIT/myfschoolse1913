# Student Mobile Spec

Current behavior for the student-facing Flutter experience.

## Scope

The mobile experience is scoped to the `STUDENT` role.

Implemented feature areas:

- home dashboard;
- semester grades;
- schedule;
- events;
- applications;
- clubs;
- notifications;
- account;
- AI assistant (see `assistant.md`).

## Navigation

Bottom navigation has four primary destinations:

- `Trang chủ` -> `/home`
- `Lịch` -> `/schedule`
- `Thông báo` -> `/notifications`
- `Tài khoản` -> `/account`

Additional student features are opened through home shortcuts:

- `Điểm học kỳ` -> `/semester-grades`
- `Lịch học` -> `/schedule`
- `Sự kiện` -> `/events`
- `Đơn từ` -> `/applications`
- `CLB` -> `/clubs`
- `Trợ lý AI` -> `/assistant`
- `Thông tin học sinh` (from Account) -> `/account/profile`

Every screen shares `StudentTopAppBar` (64lp, orange painted behind the
status bar, light status icons, adaptive back chevron). Home is the only
screen without a back button; the other screens navigate back to home or
their parent.

## Student Dashboard

The dashboard shows:

- student summary;
- class and school year;
- feature shortcuts;
- today's schedule;
- notification entry point.

## Feature Behavior

- Semester grades display subject score data from the backend.
- Schedule displays timetable data and supports adjacent-week loading.
- Events display school events.
- Applications list existing applications and allow creating a new application.
- Clubs list clubs and support registration.
- Account displays current user information and logout; `Thông tin học
  sinh` opens the profile page (role, class, school year, status, phone
  from the dashboard API), while `Cài đặt` and `Hỗ trợ` show a
  coming-soon snackbar.
- The AI assistant answers Vietnamese questions about the student's own
  schedule, grades, notifications, and applications (`assistant.md`).

## Copy And Scope Rules

- User-facing text is Vietnamese.
- Screen/file/internal names are English.
- Do not add parent-specific copy or child-management flows.
- Do not add chat/messages, attendance, reward, or discipline screens unless
  scope changes.
