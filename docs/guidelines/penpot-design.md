# Penpot Design Guidelines

Use Penpot for layout, design system, and prototype flow before implementing
complex screens in Flutter.

## Component Discipline

- Keep component sources on the design-system page, not mixed into app screens.
- If a component is missing, create it in the design system before using it on
  screens.
- Do not duplicate raw shapes for repeated UI such as app bars, bottom
  navigation, list rows, chips, buttons, or feature cards.
- Use native Penpot interactions. Do not draw fake prototype wires manually.

## Flutter Mapping

- Keep Material widgets as primitives: `FilledButton`, `TextFormField`,
  `IconButton`, `NavigationBar`, `Card`, `ListTile`.
- Style primitives through `ThemeData` where possible.
- Create custom Flutter widgets only for repeated app-specific patterns or
  behavior: auth layouts, loading buttons, student navigation, feature
  shortcuts, status chips, and school list rows.
- Do not wrap every Material primitive just for abstraction.

## Student Scope

- Board/screen names should be English.
- Visible user text should be Vietnamese.
- Home greeting should refer to `Học sinh`, not `Phụ huynh`.
- Keep student self-service features first: semester grades, schedule, events,
  applications, clubs, notifications, and account.
- Do not add chat/messages, attendance, reward, or discipline screens unless the
  user expands scope.
- Avoid parent-only flows unless parent scope is explicitly added.

## Sketch Mapping

- `ListDiemHK` -> `Mobile - Semester Grades` / `Điểm học kỳ`.
- `LichHoc` -> `Mobile - Schedule` / `Lịch học`.
- `SuKien` -> `Mobile - Events` / `Sự kiện`.
- `DonTu` -> `Mobile - Applications` / `Đơn từ`.
- `CLB` -> `Mobile - Clubs` / `CLB`.
