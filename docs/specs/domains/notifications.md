# Notifications Spec

Current behavior for student notifications.

## List

- `GET /api/students/me/notifications` returns active notifications ordered by
  pinned state and publish date.
- The Flutter notifications page loads the list after first render.
- Cards show category, pinned state, date, title, body preview, and read state.
- Selecting a notification opens `/notifications/:notificationId`.

## Detail And Read State

- `GET /api/students/me/notifications/{notificationId}` returns notification
  detail.
- Loading detail marks the notification as read for the current student.
- Read state is stored in `student_notification_reads`.
- The list reloads after returning from detail so read state can update.

## Error And Session Behavior

- A 401 result logs the user out and routes to `/login`.
- Non-session failures show retry UI.
- Unknown notification IDs return not found from the backend.

## Status

Notification detail/read-state is currently implemented in the working tree but
still needs focused tests and runtime verification.
