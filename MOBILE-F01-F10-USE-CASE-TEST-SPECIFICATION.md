# Mobile F01–F10 Use Case Test Specification

## 1. Document information

| Field | Value |
|---|---|
| Scope | Mobile F01–F10 and directly connected Student/Parent views |
| Mobile URL | `http://127.0.0.1:8080` |
| Backend URL | `http://127.0.0.1:4000` |
| API contract | `MOBILE-F01-F10-API-CONTRACT.md` in Backend repository |
| Data policy | Only persisted API data; no mock response, local sample list or fake counter |
| Test result values | `PASS`, `FAIL`, `BLOCKED`, `NOT RUN` |

## 2. Test accounts

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `Admin123@@` |
| Academic Staff | `giaovu` | `Giaovu123@@` |
| Teacher | `gv.nguyenminh` | `nguyenminh123@` |
| Student | `hs.nguyenminhan` | `nguyenminhanh123@@` |
| Parent | `ph.nguyenvanhung` | `nguyenvanhung123@` |

The demo Parent account is linked to two students. Always record the selected `studentId` when testing Parent data isolation.

## 3. General acceptance rules

1. Every displayed business value must be traceable to a backend response.
2. When the backend is unavailable, Mobile must show loading/error/retry state and must not show sample data.
3. A mutation made by one role must be visible to the authorized downstream role after reload or re-login.
4. Unauthorized roles must receive `401` or `403`; Mobile must not expose a usable mutation control.
5. Preview actions must not persist data. Apply, commit or publish actions must require explicit confirmation.
6. Repeated idempotent/upsert operations must not create duplicate enrollment, attendance, invoice-like, grade or progress records.
7. Record the request, response, affected entity ID and screenshot for every failed test.

## 4. F01 — Reset authentication LOCAL/SSO

### Use case

| Field | Value |
|---|---|
| Primary actor | Admin |
| Supporting actor | Local user or SSO identity administrator |
| Entry point | Admin → **Người dùng** → user detail |
| Main APIs | `POST /users/{id}/reset-password`, auth reset/session APIs |
| Success result | Correct reset branch is selected from persisted `authType`; old sessions are revoked |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F01-T01 | Open a LOCAL user → **Đặt lại mật khẩu** → confirm. | Response action is `RESET_LINK_SENT`; no password is displayed; `mustChangePassword=true`. | NOT RUN |
| F01-T02 | Use the one-time LOCAL reset token once, then try it again. | First request succeeds; reuse is rejected. | NOT RUN |
| F01-T03 | Keep an old refresh session, perform Admin reset, then refresh with the old session. | Old session is rejected. | NOT RUN |
| F01-T04 | Open an SSO fixture user → reset. | Response action is `CONTACT_SSO_ADMIN`; no LOCAL token or password is created. | NOT RUN |
| F01-T05 | Attempt LOCAL login/forgot/change-password for an SSO account. | Backend rejects LOCAL authentication operations. | NOT RUN |
| F01-T06 | Log in as Teacher/Student and call Admin reset endpoint. | `403`; no account state changes. | NOT RUN |

## 5. F02 — Academic structure and class placement

### Use case

| Field | Value |
|---|---|
| Primary actor | Academic Staff |
| Entry point | Academic Staff → **Cơ cấu** |
| Main APIs | Academic years, semesters, classes, subjects, rooms, GVCN and intake placement APIs |
| Success result | A valid Year → Semester → Class/Subject/Room → GVCN → Enrollment structure exists |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F02-T01 | Tab **Năm học** → create a year with valid start/end dates. | New year is returned by API and remains after reload. | NOT RUN |
| F02-T02 | Create a semester fully inside the selected year. | Semester is nested under the correct year. | NOT RUN |
| F02-T03 | Create a semester outside the year date range. | Validation error; no semester is persisted. | NOT RUN |
| F02-T04 | Tab **Lớp & GVCN** → create class → assign a Teacher as GVCN. | Class contains the selected homeroom teacher after reload. | NOT RUN |
| F02-T05 | Assign the same Teacher as GVCN to an invalid second class in the same year. | Backend enforces the homeroom uniqueness rule. | NOT RUN |
| F02-T06 | Tab **Môn & Phòng** → create a subject and room. | Both resources appear in later scheduling selectors. | NOT RUN |
| F02-T07 | Tab **Phân lớp** → select year/grade → **Chạy preview**. | Proposal and warnings are shown; enrollment tables are unchanged. | NOT RUN |
| F02-T08 | Confirm a valid placement preview. | Students receive one valid enrollment for the year and appear in class roster. | NOT RUN |
| F02-T09 | Repeat the same placement confirmation. | No duplicate enrollment is created. | NOT RUN |

## 6. F03 — Import students from Excel

### Use case

| Field | Value |
|---|---|
| Primary actor | Admin |
| Entry point | Admin → **Người dùng** → import icon |
| Main APIs | `GET /users/import-template`, `POST /users/import/preview`, `POST /users/import/commit` |
| Success result | Valid users/students/enrollments are committed only after reviewed preview |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F03-T01 | Download the Excel template. | A valid `.xlsx` template is downloaded; required headers are present. | NOT RUN |
| F03-T02 | Upload a valid completed template. | Preview shows correct total and valid row counts; database is unchanged. | NOT RUN |
| F03-T03 | Upload rows with missing required fields, duplicate username or invalid class relation. | Preview identifies each invalid row and reason. | NOT RUN |
| F03-T04 | Select **Không nhập nếu còn lỗi** and commit a preview containing errors. | Entire commit is rejected; no partial user creation. | NOT RUN |
| F03-T05 | Select **Bỏ dòng lỗi** and commit. | Only valid rows are created; rejected rows remain reported. | NOT RUN |
| F03-T06 | Preview file A, then commit a changed file B with token A. | Checksum/token validation rejects the commit. | NOT RUN |
| F03-T07 | Reuse a completed preview token. | Reuse is rejected or returns an idempotent result without duplicate users. | NOT RUN |

## 7. F04 — Curriculum plan

### Use case

| Field | Value |
|---|---|
| Primary actor | Academic Staff |
| Entry point | Academic Staff → **Kế hoạch** → **Kế hoạch** |
| Main APIs | Curriculum requirement APIs |
| Success result | One fixed curriculum requirement exists per semester, grade and subject |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F04-T01 | Select semester → add grade, subject, weekly periods, total periods and milestone. | Requirement is persisted and restored after reload. | NOT RUN |
| F04-T02 | Set start/end dates outside the semester. | Validation error; invalid plan is not saved. | NOT RUN |
| F04-T03 | Set `startDate > endDate` or invalid exam window. | Validation error identifies the invalid date relation. | NOT RUN |
| F04-T04 | Save the same semester–grade–subject combination again with changed values. | Existing requirement is updated; no duplicate tuple is created. | NOT RUN |
| F04-T05 | Delete a requirement and reload. | Requirement no longer appears and cannot be selected as an active planning input. | NOT RUN |

## 8. F05 — Automatic timetable planning

### Use case

| Field | Value |
|---|---|
| Primary actor | Academic Staff or authorized Admin |
| Entry point | Academic Staff → **Xếp lịch**; Admin → **Đào tạo** → **Xếp TKB** |
| Main APIs | Auto-plan, timetable version and publish APIs |
| Success result | A reviewed, conflict-controlled timetable version is published |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F05-T01 | Select semester → **Preview** with `allowPartial=false`. | Proposal includes existing/proposed/unscheduled counts and warnings; no slots are persisted. | NOT RUN |
| F05-T02 | Preview a dataset containing Teacher/Room/Class conflict. | Conflict is shown with the real affected IDs; apply is blocked or explicitly controlled. | NOT RUN |
| F05-T03 | Apply a valid preview. | Proposed slots are persisted once. | NOT RUN |
| F05-T04 | Save a timetable draft version. | Draft version appears in the version list. | NOT RUN |
| F05-T05 | Publish the reviewed version. | Version becomes published; Teacher `/me/timetable` returns assigned slots. | NOT RUN |
| F05-T06 | Compare Admin and Academic Staff F05 screens for the same semester. | Both clients display the same backend proposal/version state. | NOT RUN |

## 9. F06 — Exception and makeup workflow

### Use case

| Field | Value |
|---|---|
| Primary actor | Teacher |
| Approver | Academic Staff |
| Entry point | Teacher → **Tiến độ**; Academic Staff → **Kế hoạch** → **Duyệt lịch bù** |
| Main APIs | Teaching progress read/upsert/review APIs |
| Success result | A cancelled lesson produces one reviewable makeup request |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F06-T01 | Teacher selects assigned slot/date → **Nghỉ/ngoại lệ** → enters reason and makeup date. | Progress is saved as `CANCELLED`, completed periods are `0`. | NOT RUN |
| F06-T02 | Save cancellation without reason. | Validation error; record is not persisted. | NOT RUN |
| F06-T03 | Select a makeup date on/before lesson date. | Validation error. | NOT RUN |
| F06-T04 | Academic Staff opens **Duyệt lịch bù**. | The exact Teacher request and reason are visible. | NOT RUN |
| F06-T05 | Approve with a review note. | Status becomes `APPROVED`; Teacher sees the reviewed state. | NOT RUN |
| F06-T06 | Reject another request. | Status becomes `REJECTED`; review note is retained. | NOT RUN |
| F06-T07 | Teacher attempts to silently rewrite a reviewed source log. | Backend rejects an invalid rewrite or preserves review audit. | NOT RUN |

## 10. F07 — Actual teaching progress

### Use case

| Field | Value |
|---|---|
| Primary actor | Teacher |
| Monitoring actor | Academic Staff |
| Entry point | Teacher → **Tiến độ**; Academic Staff → **Kế hoạch** → **Cân bằng tiến độ** |
| Main APIs | `GET/PUT /teaching-progress` |
| Success result | Actual taught content is recorded against an assigned timetable slot |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F07-T01 | Teacher selects assigned slot/date, enters topic and completed periods, then selects **Đã dạy**. | One progress record is persisted and restored after reload. | NOT RUN |
| F07-T02 | Teacher attempts to update a slot assigned to another Teacher. | `403`; no progress record changes. | NOT RUN |
| F07-T03 | Update the same slot/date again. | Existing record is updated by canonical upsert; no duplicate is created. | NOT RUN |
| F07-T04 | Academic Staff opens **Cân bằng tiến độ**. | The Teacher update appears under the correct grade/subject/class. | NOT RUN |
| F07-T05 | Create progress difference greater than two days between same-grade classes. | Mobile shows a progress-gap warning requiring follow-up/makeup handling. | NOT RUN |

## 11. F08 — Exam schedule planning

### Use case

| Field | Value |
|---|---|
| Primary actor | Academic Staff |
| Downstream actors | Assigned Teacher, Student and Parent |
| Entry point | Academic Staff → **Kỳ thi** |
| Main APIs | Exam period, schedule, room, candidate/proctor allocation and publish APIs |
| Success result | A complete exam schedule is published without a duplicate Mobile-only API |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F08-T01 | Create/select exam period, fixed subjects and valid date window → **Tạo preview**. | Reviewable proposal is created from API-loaded period/subjects; persisted schedules are unchanged. | NOT RUN |
| F08-T02 | Use a date outside the exam period. | Validation error; no schedule is applied. | NOT RUN |
| F08-T03 | Apply a valid proposal. | Schedules are created through canonical exam schedule resources. | NOT RUN |
| F08-T04 | Assign room, candidates and two different proctors. | Allocation is persisted and returned after reload. | NOT RUN |
| F08-T05 | Try to publish a schedule missing room/proctor/candidates. | Publish is rejected with actionable validation. | NOT RUN |
| F08-T06 | Publish a complete schedule. | Period/schedule becomes published and is available to authorized downstream views. | NOT RUN |

## 12. F09 — Attendance

### Use case

| Field | Value |
|---|---|
| Primary actor | Teacher |
| Downstream actors | Student, Parent and Admin dashboard |
| Entry point | Teacher → **Điểm danh** |
| Main APIs | Attendance list, session status, unlock and bulk-upsert APIs |
| Success result | Attendance is recorded once per slot/date/student and visible to related roles |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F09-T01 | Select an assigned slot and valid session date. | Real class roster, existing marks and session status are loaded. | NOT RUN |
| F09-T02 | Select a future session. | State is `UPCOMING`; save is disabled. | NOT RUN |
| F09-T03 | Select a locked late session → **Mở khóa** with fewer than 10 characters. | Unlock is rejected. | NOT RUN |
| F09-T04 | Unlock with a valid reason. | Session becomes writable; reason and unlock time are retained. | NOT RUN |
| F09-T05 | Mark a student absent/late without note. | Mobile blocks submit and requests a note. | NOT RUN |
| F09-T06 | Save valid marks. | Backend upserts by slot/date/student; Teacher history shows the saved session. | NOT RUN |
| F09-T07 | Save the same session again with changed status. | Existing attendance is updated; count does not increase unexpectedly. | NOT RUN |
| F09-T08 | Log in as Student → **Chuyên cần**. | Student sees the same subject/date/period/status/note. | NOT RUN |
| F09-T09 | Log in as linked Parent → select child → **Chuyên cần**. | Parent sees the same record as Student; another child cannot expose it. | NOT RUN |
| F09-T10 | Open Admin dashboard after saving absence/late data. | Real attendance/alert metrics change according to backend aggregation. | NOT RUN |

Demo note: the seeded semester begins on `17/08/2026`. Before that date, `UPCOMING` and disabled save are correct behavior.

## 13. F10 — Grade entry, update and publication result

### Use case

| Field | Value |
|---|---|
| Primary actor | Teacher |
| Downstream actors | Student, Parent and Admin Audit |
| Entry point | Teacher → **Bảng điểm** |
| Main APIs | Gradebook context, grade list/bulk and change-log APIs |
| Success result | Grades are saved inside Teacher scope and downstream roles read the same records |

| Test ID | Scenario and steps | Expected result | Status |
|---|---|---|---|
| F10-T01 | Select assigned class, semester and subject. | Real roster/grades load; editability matches gradebook context. | NOT RUN |
| F10-T02 | Select a class/subject outside Teacher assignment. | Mutation is hidden or rejected with `403`. | NOT RUN |
| F10-T03 | Enter valid ORAL/15M/MID/FINAL scores and save. | Grade records are persisted and returned after reload. | NOT RUN |
| F10-T04 | Enter a score outside the accepted range. | Validation error; invalid score is not saved. | NOT RUN |
| F10-T05 | Edit an existing score without reason. | Update is blocked. | NOT RUN |
| F10-T06 | Edit with reason and current `expectedVersion`. | Score is updated; change log contains old/new score, reason, actor and time. | NOT RUN |
| F10-T07 | Update using a stale `expectedVersion`. | Conflict is returned; newer score is not overwritten. | NOT RUN |
| F10-T08 | Open **Phổ điểm** and **Log sửa điểm**. | Both tabs are calculated/read from current backend records, not local samples. | NOT RUN |
| F10-T09 | Log in as Student → **Điểm số**. | Student sees the same grade entries. | NOT RUN |
| F10-T10 | Log in as linked Parent → select child → **Học tập**. | Parent sees the same grade entries and computed average; another child remains isolated. | NOT RUN |
| F10-T11 | Open Admin → **Audit** and search for the affected entity/actor. | Corresponding persisted audit event is returned by API. | NOT RUN |

## 14. Cross-role end-to-end scenarios

### E2E-01 — Academic setup to Teacher timetable

1. Academic Staff creates year, semester, class, subject and room.
2. Academic Staff assigns GVCN/teaching relation and places students.
3. Academic Staff creates curriculum requirement.
4. Academic Staff previews, applies and publishes timetable.
5. Teacher logs in and opens **Lịch dạy**.

Expected: Teacher sees only the published slots assigned to that Teacher; all labels refer to the same persisted class/subject/room IDs.

### E2E-02 — Teacher progress to Academic monitoring

1. Teacher records a completed lesson.
2. Teacher records one cancelled lesson with makeup date.
3. Academic Staff opens balance and makeup-review tabs.
4. Academic Staff approves or rejects the request.
5. Teacher reloads **Tiến độ**.

Expected: both roles see the same progress ID, status, topic, reason, makeup date and review state.

### E2E-03 — Teacher attendance to Student/Parent/Admin

1. Teacher saves attendance for one class session.
2. Student opens attendance history.
3. Linked Parent selects that Student and opens attendance history.
4. Admin reloads dashboard.

Expected: Teacher, Student and Parent show the same record; Admin metrics are backend-derived; an unrelated Parent/Student receives no data.

### E2E-04 — Teacher grades to Student/Parent/Audit

1. Teacher creates a score.
2. Teacher changes it with a reason.
3. Student opens grade view.
4. Linked Parent selects the Student and opens grade view.
5. Admin searches Audit.

Expected: Student and Parent show the latest score; Teacher log and Admin audit preserve the mutation history.

## 15. Test execution record

| Test cycle | Date | Build/commit | Tester | Passed | Failed | Blocked | Notes |
|---|---|---|---|---:|---:|---:|---|
| Cycle 1 |  |  |  |  |  |  |  |
| Cycle 2 |  |  |  |  |  |  |  |

## 16. Release exit criteria

- All priority F01–F10 main-flow tests pass.
- No unresolved authorization or cross-child data-isolation failure exists.
- No screen in scope displays sample business data when the API is empty or unavailable.
- Cross-role E2E-01 through E2E-04 pass using persisted IDs.
- Backend, Flutter analysis and automated tests pass for the release build.
