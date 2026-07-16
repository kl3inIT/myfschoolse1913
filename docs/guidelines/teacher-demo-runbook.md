# Teacher Demo Runbook

Use this runbook for a clean local teacher-review environment. All fixture
identities and policies are synthetic.

## One-Time Reset

The PostgreSQL container is shared. Reset only `myfschoolse1913`:

```powershell
docker exec northstar-postgres-1 psql -U northstar -d postgres `
  -c "DROP DATABASE IF EXISTS myfschoolse1913 WITH (FORCE);"
docker exec northstar-postgres-1 psql -U northstar -d postgres `
  -c "CREATE DATABASE myfschoolse1913 OWNER northstar;"

cd backend
$env:SEED_DEMO_USER='true'
.\gradlew.bat bootRun
```

Wait until all six `Embedded document ... as ... chunk(s)` messages appear.
Then stop the backend, clear the seed flag, and start it normally:

```powershell
Remove-Item Env:SEED_DEMO_USER -ErrorAction SilentlyContinue
.\gradlew.bat bootRun
```

Do not delete the `northstar` database, the PostgreSQL container, or Gradle
caches.

## Start The Clients

```powershell
# terminal 2
cd admin-web
pnpm dev

# terminal 3
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Credentials:

- Admin: `0900000000 / Password123`
- Teacher: `0911000001 / Password123`
- Parent: `0922000001 / Password123`
- Student: `0900000001 / Password123`

## Walkthrough

1. Admin dashboard: show 36 students, three classes, pending applications, two
   locked accounts, recent notifications, and the six indexed AI documents.
2. Student home: show profile `Nguyễn Minh Anh`, the current-day timetable,
   grades, events, applications, clubs, and notifications.
3. Admin school work: open `Phân công & liên kết`, show the two teachers,
   subject/homeroom assignments, verified guardian links, and the published
   grade correction form.
4. Teacher React: log in as `0911000001`, show the scoped 10A1 Math roster,
   attendance, gradebook, homeroom applications, and per-student conduct form.
5. Parent Flutter: log in as `0922000001`, switch linked children, and show only
   published grades, attendance, schedule, notifications, and applications.
6. Cross-surface application:
   - student creates a new absence application;
   - the 10A1 homeroom teacher approves an eligible request of at most three
     days; longer/document cases stay with admin;
   - the student or linked parent refreshes and sees `Đã duyệt`.
7. Assistant personal grounding: ask `Điểm trung bình môn Toán của mình là bao
   nhiêu?`; expected answer is `8.5` with the score components.
8. Assistant RAG grounding: ask `Theo nội quy, mình có được tự ý dùng điện
   thoại trong giờ học không?`; expected answer says no unless the teacher
   permits it and cites `Nội quy học sinh - Bản demo 2026-2027`.
9. Log out from all clients.

## Verified Four-Role Baseline (2026-07-16)

- Flyway version 18; two teachers, two assignments, two parents, and three
  active guardian links.
- Backend clean tests, React lint/build, Flutter analyze/5 tests/APK build all
  passed.
- Admin correction wrote an audit row and teachers were blocked from changing
  the published result.
- Admin, Teacher React, and Parent Flutter were verified in real browsers with
  no console errors.

## Verified Baseline (2026-07-11)

- Flyway version 16 on a freshly recreated database.
- 37 users, 36 students, three classes, 288 grades, 129 timetable slots,
  18 post-walkthrough applications, eight clubs, six documents, six vectors.
- Flutter Web application creation returned 201; admin approval moved pending
  from 7 to 6 and approved from 6 to 7; the student API returned `APPROVED`.
- Both assistant prompts streamed successfully in Flutter Web with HTTP 200.
