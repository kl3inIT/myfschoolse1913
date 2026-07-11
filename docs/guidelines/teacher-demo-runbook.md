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
npm run dev

# terminal 3
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Credentials:

- Admin: `0900000000 / Password123`
- Student: `0900000001 / Password123`

## Walkthrough

1. Admin dashboard: show 36 students, three classes, pending applications, two
   locked accounts, recent notifications, and the six indexed AI documents.
2. Student home: show profile `Nguyễn Minh Anh`, the current-day timetable,
   grades, events, applications, clubs, and notifications.
3. Cross-surface application:
   - student creates a new absence application;
   - admin opens `Đơn từ`, finds it at the top, and approves it with a note;
   - student refreshes `Đã duyệt` and sees the approved application.
4. Assistant personal grounding: ask `Điểm trung bình môn Toán của mình là bao
   nhiêu?`; expected answer is `8.5` with the score components.
5. Assistant RAG grounding: ask `Theo nội quy, mình có được tự ý dùng điện
   thoại trong giờ học không?`; expected answer says no unless the teacher
   permits it and cites `Nội quy học sinh - Bản demo 2026-2027`.
6. Log out from both clients.

## Verified Baseline (2026-07-11)

- Flyway version 16 on a freshly recreated database.
- 37 users, 36 students, three classes, 288 grades, 129 timetable slots,
  18 post-walkthrough applications, eight clubs, six documents, six vectors.
- Flutter Web application creation returned 201; admin approval moved pending
  from 7 to 6 and approved from 6 to 7; the student API returned `APPROVED`.
- Both assistant prompts streamed successfully in Flutter Web with HTTP 200.
