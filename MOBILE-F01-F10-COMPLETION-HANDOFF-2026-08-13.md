# School Management Mobile — F01–F10 Completion Handoff

**Ngày chốt:** 13/08/2026

**Mobile repo:** `/Users/a1234/School Management System FE/School-Management-System-Mobile-FE`

**Backend dùng kiểm thử:** `http://127.0.0.1:4000`, profile `demo`, dữ liệu thật trong DB demo
**Mobile Web để nghiệm thu:** `http://127.0.0.1:8080/#/login`

## 1. Kết luận

Phần Mobile của F01–F10 đã được hoàn thiện trong phạm vi API Backend hiện có. Mobile không tạo namespace API riêng, không dùng mock API trong luồng release, không tự gọi callback thanh toán và chỉ có bốn role: `ADMIN`, `TEACHER`, `STUDENT`, `PARENT`.

Các gate đã chạy trên repo chính:

| Gate | Kết quả |
|---|---|
| `flutter analyze` | PASS — 0 issue |
| `flutter test` mặc định | PASS — 29 pass, 5 live case được skip có chủ đích |
| Live integration với Backend thật | PASS — 5/5 |
| `flutter build web --release` | PASS |
| Browser ở viewport 390×844 | PASS login, Admin dashboard, Đào tạo, Auto TKB readiness |

`5 live case` trong suite mặc định chỉ chạy khi truyền `RUN_LIVE_INTEGRATION=true` và mật khẩu UAT. Không được ghi là PASS nếu chỉ chạy suite mặc định.

## 2. Những phần Mobile đã hoàn thiện

### F01 — Authentication và reset

- Login, refresh, logout, forgot/reset bằng token và deep link dùng API thật.
- Nút quay về đăng nhập ở forgot/reset hoạt động.
- Logout đóng SSE; login tài khoản khác mở một phiên realtime mới, tránh nhận event của tài khoản cũ.
- Role ngoài bốn role chính thức vào màn Không có quyền, không fallback sang Admin.
- Tài khoản demo chỉ hiện khi build có `--dart-define=SHOW_DEMO_ACCOUNTS=true`; mặc định bị ẩn.
- Admin reset mật khẩu phân biệt tài khoản LOCAL và SSO theo response Backend.

### F02 — Cơ cấu, tài khoản và phân lớp

- Admin tạo user với email và số điện thoại bắt buộc; mã user do Backend sinh.
- Giáo viên chọn `mainSubjectId` từ danh mục môn thật.
- Luồng năm học, học kỳ, lớp, môn, phòng, GVCN và phân lớp dùng API thật.
- Preview phân lớp cho phép chọn sĩ số, số lớp, ca học, tự tạo lớp và cân bằng giới tính.
- Có thể khóa từng học sinh vào lớp trong preview; hệ thống tự cân bằng những học sinh còn lại.
- Chỉ cho xác nhận khi `unassignedCount = 0`.

### F03 — Import Excel

- Dùng một luồng duy nhất: template → preview → commit.
- Mobile dùng đúng strategy `SKIP_ERRORS` hoặc `ALL_OR_NOTHING`; không gọi API import trực tiếp cũ.
- Preview và commit dùng file/token Backend trả về; lỗi được hiển thị theo kết quả thật.

### F04 — Kế hoạch đào tạo

- CRUD requirement thật gồm số tiết tuần, tổng tiết, ngày bắt đầu/kết thúc, cửa sổ thi và milestone.
- Auto TKB chặn khi thiếu curriculum, không fallback sang dữ liệu giả.
- Danh sách môn thi F08 được derive và khóa từ `examWindow` của curriculum cùng học kỳ/khối.

### F05 — Tự xếp và công bố TKB

- Readiness → preview → apply draft → kiểm tra version → publish dùng API Backend.
- Draft không được hiển thị cho Teacher/Student/Parent.
- Teacher, Student và Parent refetch khi nhận `TIMETABLE_PUBLISHED`, khi app resume và khi kéo làm mới.
- Màn chỉnh TKB thủ công không còn hardcode 5 tiết/giờ; cấu hình được suy ra từ slot của học kỳ.

### F06–F07 — Ngoại lệ, lịch bù và tiến độ

- Teacher chỉ cập nhật occurrence có ngày khớp thứ của slot đã công bố.
- Teacher khai báo tiến độ/ngoại lệ/đề xuất bù bằng API thật; Admin review trên cùng entity.
- UI không còn tuyên bố sai rằng approve đã tạo lịch bù. Trạng thái nói rõ còn chờ tạo và publish revision TKB.
- Admin được dẫn sang màn vận hành TKB để hoàn tất bước thủ công hiện tại.

### F08 — Tự xếp lịch thi

- Auto-plan preview/apply gọi endpoint Backend có idempotency key; Mobile không tự xếp bằng thuật toán local.
- Môn thi lấy từ kế hoạch đào tạo, không cho chọn môn tùy ý.
- Selector giám thị dùng danh sách eligible do Backend trả.
- Teacher xem riêng lịch coi thi và nhiệm vụ chấm; Student/Parent xem lịch/kết quả đúng scope.
- Nhập điểm thi có expected version; phúc khảo dùng cùng endpoint Web/Backend.

### F09 — Điểm danh

- Teacher đọc session/version rồi bulk save với `expectedVersion`.
- Khi `409`, UI reload dữ liệu và yêu cầu kiểm tra lại thay vì ghi đè.
- Student/Parent refetch theo event và app resume.
- Trạng thái `LATE` không còn bị tính thành vắng trong dashboard Parent.

### F10 — Nhập và hiển thị điểm

- Giữ nhiều đầu điểm cùng category bằng `assessmentIndex`.
- Writer gửi `expectedVersion` và reason; `409` reload rõ ràng.
- Student/Parent đang mở màn hình refetch theo event grade.
- Detail lọc đúng môn và học kỳ; dashboard Parent dùng `/grades/summary` của Backend.
- Bỏ nhãn “đã công bố” đối với điểm thường vì contract hiện tại là hiển thị ngay sau save.
- Phân bố điểm Teacher dùng trọng số category và chỉ tính khi đủ đầu điểm, không trung bình cộng tùy ý.

### Các luồng liên quan đã sửa cùng đợt

- Assignment Teacher tạo/publish từ teaching assignment thật; Student mở detail/upload/submit thật.
- Teacher xem submission, attachment metadata, attempt history, chấm và cho nộp lại bằng API thật.
- Parent có màn “Bài tập của con”, ghép assignment với submission/score/feedback thật và refetch theo event/resume.
- Chat/notification dùng endpoint phân trang canonical và unread count Backend.
- Thanh toán chỉ tạo payment instruction; Mobile tuyệt đối không gọi sandbox callback/IPN.

## 3. Bằng chứng live đã PASS

| Case | Kết quả |
|---|---|
| Đăng nhập API đủ bốn role | PASS |
| Student login qua UI và vào đúng home | PASS |
| Parent chỉ đọc published timetable của con liên kết | PASS |
| Teacher sửa điểm bằng `POST /grades/bulk`; Student/Parent nhận event và đọc version mới | PASS |
| Teacher điểm danh bằng `/attendance/bulk`; Student/Parent nhận event; stale version bị từ chối | PASS |

Case điểm danh được chạy với Backend demo có fixed clock nằm trong học kỳ. Nếu dùng ngày hệ thống trước ngày bắt đầu học kỳ, Backend phải chặn và test phải FAIL/BLOCKED, không được đổi sang PASS giả.

## 4. Phần còn phụ thuộc Backend, Mobile không được tự làm giả

| Luồng | Giới hạn Backend hiện tại | Cách Mobile đang xử lý an toàn |
|---|---|---|
| F01 SSO | Chưa có login/exchange SSO hoàn chỉnh | Không dựng nút SSO giả; chỉ reset Admin phân nhánh auth type |
| F01 Email reset | SMTP cần cấu hình môi trường và test inbox thật | Hiển thị kết quả public của Backend; không tạo mail/link local |
| F02 apply placement | Chưa bind apply với preview token/version và idempotency đầy đủ | Mobile preview lại sau mỗi thay đổi; không tuyên bố chống race |
| F03 commit import | Preview token còn có thể replay nếu Backend chưa lưu operation | Mobile không tự retry commit mù; cần Backend idempotency |
| F04 lifecycle plan | Chưa có version/audit/lock riêng | Mobile tuân khóa semester hiện có; không tạo endpoint plan khác |
| F06 lịch bù | Approve mới đổi trạng thái, chưa sinh slot/revision TKB | UI ghi “chờ xếp và phát hành”, dẫn Admin sang TKB |
| F07 balance | Chưa có balance summary/action canonical từ Backend | Mobile chỉ hiển thị cảnh báo tham khảo, không tự mutation |
| F08 availability | Backend cần sửa chuẩn `MON`/`MONDAY` và test conflict | Mobile dùng kết quả Backend; không tự bỏ qua giám thị |

## 5. Cách chạy lại test

### Gate mặc định

```bash
cd "/Users/a1234/School Management System FE/School-Management-System-Mobile-FE"
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:4000
```

### Live integration

```bash
flutter test test/integration/live_backend_roles_test.dart \
  --dart-define=RUN_LIVE_INTEGRATION=true \
  --dart-define=API_BASE_URL=http://127.0.0.1:4000 \
  --dart-define=E2E_ADMIN_PASSWORD='<password>' \
  --dart-define=E2E_TEACHER_PASSWORD='<password>' \
  --dart-define=E2E_STUDENT_PASSWORD='<password>' \
  --dart-define=E2E_SECOND_STUDENT_PASSWORD='<password>' \
  --dart-define=E2E_PARENT_PASSWORD='<password>'
```

Không commit mật khẩu thật vào source hoặc tài liệu.

## 6. Checklist nghiệm thu thủ công theo vai trò

### Admin

1. Login → xác nhận dashboard gọi số thật.
2. Người dùng → tạo mỗi role; bỏ email/phone phải bị chặn; Teacher phải chọn môn từ dropdown.
3. Đào tạo → tạo/kiểm tra năm, học kỳ, lớp, môn, phòng và GVCN.
4. Phân lớp → preview, mở từng lớp, bấm **Giữ lớp**, preview lại, chỉ xác nhận khi không còn unassigned.
5. Kế hoạch đào tạo → khai báo đủ curriculum và exam window.
6. Xếp TKB → readiness, preview, tạo draft, kiểm tra, publish.
7. Lịch thi → xác nhận môn thi bị khóa theo curriculum; preview/apply/publish.

### Teacher

1. Lịch dạy chỉ chứa published slot được phân công.
2. Điểm danh đúng buổi; thử sửa từ phiên cũ phải nhận 409/reload.
3. Bảng điểm giữ nhiều đầu điểm, sửa có reason, Student/Parent thấy lại.
4. Tiến độ: chọn sai thứ/ngày phải bị chặn; ngoại lệ/lịch bù hiển thị đúng trạng thái chờ publish.
5. Bài tập: tạo/publish → xem submission → chấm → cho nộp lại → xem attempt history.
6. Khảo thí: kiểm tra cả **Lịch coi thi** và **Nhiệm vụ chấm**.

### Student

1. Lịch học cập nhật sau publish, không thấy draft.
2. Bài tập mở detail thật, upload/nộp và reload vẫn còn.
3. Điểm và chuyên cần đổi theo event hoặc pull-to-refresh, không cần đăng nhập lại.
4. Lịch thi/kết quả/phúc khảo đúng scope.

### Parent

1. Đổi con và xác nhận mọi tab reload theo child đang chọn.
2. Lịch học chỉ từ `/children/{id}/timetable`.
3. Điểm/chuyên cần cập nhật theo event; `LATE` không tính là vắng.
4. **Bài tập của con** hiển thị submission, score và feedback thật.
5. Tài chính tạo payment instruction nhưng Network không có request tới callback URL.

## 7. Tiêu chí bàn giao

Phần Mobile được coi là hoàn thiện ở mức code/build và live slice đã nêu. Toàn hệ thống chưa được gọi là release-ready cho tới khi các blocker Backend ở mục 4 được sửa và toàn bộ P0 trong `SCHOOL-MANAGEMENT-MOBILE-V2-RELEASE-TEST-PLAN.md` được chạy trên cùng cặp commit Backend/Mobile.
