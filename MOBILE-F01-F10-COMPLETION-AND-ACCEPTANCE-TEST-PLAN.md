# Mobile F01–F10 Completion and Acceptance Test Plan

## 1. Mục đích tài liệu

Tài liệu này là checklist nghiệm thu duy nhất cho các luồng Mobile F01–F10. Tài liệu được lập sau khi đối chiếu:

- Flutter Mobile FE hiện tại.
- API contract dùng chung cho Web và Mobile.
- Backend Spring Boot và các controller/service hiện có.
- Kết quả kiểm thử trình duyệt trước đó và bộ test tự động hiện tại.

Tài liệu chỉ sử dụng bốn vai trò chính thức: **Admin, Giáo viên, Học sinh, Phụ huynh**. Không tạo thêm vai trò Giáo vụ hoặc Kế toán trên Mobile. Các nghiệp vụ quản trị đào tạo trong F02–F05 và F08 do **Admin** thực hiện.

## 2. Kết luận mức độ hoàn thiện hiện tại

**Chưa thể xác nhận F01–F10 đã hoàn thành 100%.** Mười luồng đều đã có nền tảng API và màn hình chính, nhưng một số luồng còn lỗi hoặc chưa được test xuyên suốt bằng dữ liệu ghi thật.

| Luồng | Chức năng | Trạng thái hiện tại | Kết luận |
|---|---|---|---|
| F01 | Reset authentication LOCAL/SSO | Backend đã có xử lý LOCAL/SSO và thu hồi phiên; Mobile đã gọi API | **Hoàn thiện một phần**: thiếu xác nhận trước reset và chưa nghiệm thu đủ token một lần/SSO trên Mobile |
| F02 | Cơ cấu năm học đến phân lớp | Có màn hình và API tạo năm học, học kỳ mặc định, lớp, môn, phòng, GVCN, preview/apply phân lớp | **Hoàn thiện một phần**: preview không có ứng viên từng trả sai `1 lớp mới`; cần chạy lại E2E |
| F03 | Import học sinh Excel | Có template, preview, commit và UI xem lỗi từng dòng | **Chưa hoàn thành**: tải template trên Flutter Web lỗi; Mobile gửi sai strategy `SKIP_INVALID` thay vì `SKIP_ERRORS` |
| F04 | Kế hoạch đào tạo | Có CRUD curriculum requirement và validation backend | **Sẵn sàng UAT**: chưa có chu kỳ test ghi/sửa/xóa trọn vẹn trên dữ liệu riêng |
| F05 | Tự xếp và công bố TKB | Có preview/apply/version/publish; thuật toán giới hạn lệch tối đa 2 ngày; backend integration test đạt | **Sẵn sàng UAT**: cần bộ dữ liệu có slot thiếu/conflict để nghiệm thu thuật toán thực tế |
| F06 | Ngoại lệ và lịch bù | Giáo viên tạo ngoại lệ; Admin duyệt/từ chối qua cùng resource tiến độ | **Sẵn sàng UAT**: seed hiện tại chưa có yêu cầu lịch bù; một thông báo UI còn dùng từ “Giáo vụ” |
| F07 | Tiến độ thực dạy | Có upsert tiến độ, scope giáo viên và màn hình cân bằng tiến độ | **Sẵn sàng UAT**: cần dữ liệu ít nhất hai lớp cùng khối/môn để kiểm tra cảnh báo lệch |
| F08 | Tự xếp và công bố lịch thi | Backend workflow và integration test đạt; Admin có preview/apply/publish | **Hoàn thiện một phần**: Teacher Mobile mới đọc nhiệm vụ chấm thi, chưa đọc đầy đủ agenda coi thi |
| F09 | Điểm danh | Có session status, unlock, bulk upsert và màn hình Student/Parent | **Hoàn thiện một phần**: lịch sử Giáo viên có thể hỏng toàn màn hình nếu một slot trả `403` |
| F10 | Nhập điểm và đồng bộ kết quả | Có gradebook, bulk save, log sửa, Student/Parent view | **Chưa hoàn thành**: công thức Phổ điểm và tổng quan Phụ huynh chưa thống nhất; Mobile chưa gửi `expectedVersion` khi sửa điểm |

Kết quả kiểm tra kỹ thuật tại thời điểm lập tài liệu:

- Backend `mvn test`: **56 test đạt, 0 lỗi**.
- Mobile `flutter analyze`: **đạt, không có issue**.
- Mobile `flutter test`: **4 test đạt, 2 integration case bị skip theo runner hiện tại**.
- Test tự động đạt không thay thế cho các bước UAT đa vai trò bên dưới.

## 3. Môi trường và tài khoản kiểm thử

| Thành phần | Địa chỉ local |
|---|---|
| Mobile | `http://127.0.0.1:8080` |
| Backend | `http://127.0.0.1:4000` |
| Health check | `GET /actuator/health` |
| API contract | Backend `docs/openapi/MOBILE-F01-F10-API-CONTRACT.md` |

| Vai trò | Tài khoản mặc định | Mục đích |
|---|---|---|
| Admin | `admin` | F01–F05, F08 và kiểm tra dashboard/audit |
| Giáo viên | `gv.nguyenminh` | F06, F07, F09, F10 và nhận TKB/lịch thi |
| Học sinh | `hs.nguyenminhan` | Nhận TKB, chuyên cần, điểm và lịch thi |
| Phụ huynh | `ph.nguyenvanhung` | Kiểm tra dữ liệu đúng từng con |

Mỗi người test phải dùng mã dữ liệu riêng, ví dụ `UAT-F02-<TEN>-<NGAYGIO>`, và ghi lại toàn bộ `yearId`, `semesterId`, `classId`, `subjectId`, `roomId`, `slotId`, `studentId`. Không dùng chung một bộ dữ liệu đang chỉnh sửa với thành viên khác.

## 4. Quy tắc nghiệm thu chung

1. Không bật `mock-server`; mọi dữ liệu nghiệp vụ phải truy được về response backend thật.
2. Khi API lỗi hoặc rỗng, Mobile phải hiển thị loading/error/empty state, không thay bằng số hoặc danh sách mẫu.
3. Preview không được ghi database. Chỉ Apply/Commit/Publish sau xác nhận mới được thay đổi dữ liệu.
4. Mọi thao tác lặp phải idempotent hoặc upsert đúng khóa nghiệp vụ; không sinh bản ghi trùng.
5. Dữ liệu nháp của Admin không được xuất hiện ở Giáo viên/Học sinh/Phụ huynh trước khi publish.
6. Một mutation của Giáo viên phải xuất hiện ở đúng Học sinh và Phụ huynh liên kết sau reload.
7. Role ngoài phạm vi phải nhận `401/403`; giao diện không được để lại nút ghi dữ liệu có thể sử dụng.
8. Mỗi case FAIL phải lưu: thời gian, tài khoản, entity ID, request/response, ảnh màn hình và bước tái hiện ngắn nhất.

## 5. Thứ tự chạy để tránh xung đột dữ liệu

1. Chạy **Preflight** và F01 trên tài khoản test riêng.
2. Chạy F02 để tạo bộ cơ cấu mới.
3. Chạy F03 để bổ sung học sinh vào đúng bộ cơ cấu.
4. Chạy F04 để tạo định mức môn học.
5. Tạo teaching assignment, sau đó chạy F05.
6. Giáo viên dùng TKB đã publish để chạy F06, F07 và F09.
7. Admin chạy F08; các role còn lại kiểm tra lịch thi sau publish.
8. Giáo viên chạy F10; Học sinh/Phụ huynh/Admin đối chiếu cùng bản ghi.

Không chạy Apply/Publish của hai tester trên cùng `semesterId`.

## 6. Preflight

| ID | Bước test | Kết quả mong đợi |
|---|---|---|
| PF-01 | Mở `GET /actuator/health`. | Trả `UP`. |
| PF-02 | Mở Mobile khi backend đang chạy. | Không xuất hiện dữ liệu mock hoặc lỗi kết nối. |
| PF-03 | Đăng nhập lần lượt bốn tài khoản. | Điều hướng đúng bốn role; không có role Giáo vụ/Kế toán. |
| PF-04 | Tắt backend rồi reload một tab dữ liệu. | Có trạng thái lỗi và nút thử lại; không hiện dữ liệu mẫu. |
| PF-05 | Bật lại backend, bấm thử lại. | Dữ liệu thật được tải lại mà không cần xóa ứng dụng. |

---

## 7. F01 — Reset authentication LOCAL/SSO

### Use case F01-UC01 — Admin reset tài khoản LOCAL

| Thuộc tính | Nội dung |
|---|---|
| Actor chính | Admin |
| Actor nhận kết quả | Người dùng LOCAL |
| Điểm vào | Admin → Người dùng → Chi tiết người dùng → menu ba chấm → Đặt lại mật khẩu |
| API chuẩn | `POST /users/{id}/reset-password` |
| Kết quả bắt buộc | Gửi link/token một lần, đặt `mustChangePassword=true`, thu hồi toàn bộ refresh session cũ, không trả mật khẩu plaintext |

Luồng chính:

1. Admin mở một tài khoản có `authType=LOCAL`.
2. Mobile phải hiển thị hộp xác nhận, nêu rõ các phiên cũ sẽ bị đăng xuất.
3. Admin xác nhận; Mobile gọi duy nhất `POST /users/{id}/reset-password`.
4. Backend tự quyết định nhánh theo `authType`; client không gửi mật khẩu mới hoặc loại xác thực.
5. Mobile hiển thị thông báo link đặt lại đã được gửi.
6. Người dùng dùng token đúng một lần để đặt mật khẩu mới.
7. Phiên refresh cũ và token đã dùng lại đều bị từ chối.

### Use case F01-UC02 — Admin xử lý tài khoản SSO

1. Admin mở fixture có `authType=SSO` và chọn reset.
2. Backend trả `action=CONTACT_SSO_ADMIN`.
3. Không tạo LOCAL reset token, không đổi password hash và không hiển thị mật khẩu.
4. Mobile hướng dẫn liên hệ quản trị IdP.

### Test case F01

| ID | Bước test | Kết quả mong đợi | Trạng thái hiện tại |
|---|---|---|---|
| F01-T01 | Reset một user LOCAL từ Mobile. | Có xác nhận trước khi gọi API; trả `RESET_LINK_SENT`. | **FAIL hiện tại**: chưa có xác nhận trước thao tác |
| F01-T02 | Kiểm tra request reset trong Network. | Body rỗng; không có `newPassword`, `authType`. | **FAIL hiện tại**: client còn gửi `newPassword: null` |
| F01-T03 | Giữ refresh token cũ, reset rồi gọi refresh. | Refresh cũ bị từ chối. | CẦN TEST |
| F01-T04 | Dùng reset token hai lần. | Lần một thành công; lần hai bị từ chối. | CẦN TEST |
| F01-T05 | Reset fixture SSO. | Trả `CONTACT_SSO_ADMIN`, không sinh LOCAL token. | CẦN SEED SSO |
| F01-T06 | Thử forgot/change-password LOCAL với user SSO. | Backend từ chối, không thay đổi tài khoản. | CẦN SEED SSO |
| F01-T07 | Đăng nhập Teacher/Student/Parent rồi gọi reset user khác. | `403`, không phát sinh reset token. | CẦN TEST |

---

## 8. F02 — Cơ cấu năm học đến phân lớp

### Use case F02-UC01 — Tạo cơ cấu đào tạo

| Thuộc tính | Nội dung |
|---|---|
| Actor chính | Admin |
| Điểm vào | Admin → Tiện ích → Cơ cấu & phân lớp tự động |
| API chuẩn | `/academicYears`, `/semesters`, `/classes`, `/subjects`, `/rooms`, `PUT /classes/{id}/homeroom-teacher` |
| Kết quả bắt buộc | Có chuỗi Year → 2 Semester mặc định → Class/Subject/Room → GVCN hợp lệ |

Luồng chính:

1. Admin tạo năm học với mã, tên, ngày bắt đầu và kết thúc.
2. Backend tạo hai học kỳ mặc định nằm trong năm học.
3. Admin tạo môn và phòng.
4. Admin tạo lớp, chọn khối, ca học, sức chứa và phòng chính.
5. Admin gán một Giáo viên làm GVCN.
6. Reload màn hình và đối chiếu toàn bộ ID/quan hệ vẫn còn.

### Use case F02-UC02 — Preview và xác nhận phân lớp

1. Admin chọn năm học, khối và sĩ số tối đa.
2. Mobile gọi preview và hiển thị ứng viên, lớp hiện hữu/lớp mới, số được xếp, số chưa xếp và cảnh báo.
3. Preview không thay đổi enrollment.
4. Admin chỉ xác nhận khi không còn blocker.
5. Backend apply đúng proposal và tạo một enrollment hợp lệ cho mỗi học sinh/năm.
6. Chạy lại không tạo enrollment trùng.

### Test case F02

| ID | Bước test | Kết quả mong đợi | Trạng thái |
|---|---|---|---|
| F02-T01 | Tạo năm học ngày bắt đầu trước ngày kết thúc. | Năm học được lưu; hai học kỳ mặc định xuất hiện sau reload. | CẦN TEST GHI THẬT |
| F02-T02 | Tạo năm học có ngày bắt đầu sau ngày kết thúc. | Validation lỗi; không sinh năm/học kỳ. | CẦN TEST |
| F02-T03 | Tạo môn và phòng với mã hợp lệ. | Dữ liệu xuất hiện trong selector tạo lớp/TKB/lịch thi. | CẦN TEST |
| F02-T04 | Tạo lớp và gán phòng chính. | Lớp thuộc đúng năm/khối/ca/phòng và tồn tại sau reload. | CẦN TEST |
| F02-T05 | Gán GVCN cho lớp. | `homeroomTeacherId/name` đúng sau reload. | CẦN TEST |
| F02-T06 | Gán cùng giáo viên làm GVCN hai lớp cùng năm. | Backend chặn theo unique rule. | CẦN TEST |
| F02-T07 | Preview khi `candidateCount=0`. | `newClassCount=0`, không đánh dấu lớp hiện hữu là lớp mới. | **CẦN RETEST lỗi cũ** |
| F02-T08 | Preview khi có ứng viên. | Số ứng viên = được xếp + chưa xếp; chưa thay đổi roster. | CẦN DỮ LIỆU |
| F02-T09 | Apply proposal hợp lệ rồi reload roster. | Học sinh nằm đúng lớp và có một enrollment trong năm. | CẦN DỮ LIỆU |
| F02-T10 | Apply lại cùng proposal. | Không tạo enrollment trùng hoặc trả kết quả idempotent. | CẦN TEST |

---

## 9. F03 — Import học sinh bằng Excel

### Use case F03-UC01 — Template → Preview → Commit

| Thuộc tính | Nội dung |
|---|---|
| Actor chính | Admin |
| Điểm vào | Admin → Người dùng → biểu tượng Import Excel |
| API chuẩn | `GET /users/import-template`, `POST /users/import/preview`, `POST /users/import/commit` |
| Kết quả bắt buộc | Chỉ ghi dữ liệu sau preview; commit dùng đúng file/checksum/token và strategy chuẩn |

Luồng chính:

1. Admin tải template `.xlsx` từ backend.
2. Admin điền dữ liệu, không đổi tên header bắt buộc.
3. Mobile upload file vào preview.
4. Mobile hiển thị tổng dòng, hợp lệ, lỗi và lý do từng dòng.
5. Nếu còn lỗi, Admin chọn `ALL_OR_NOTHING` hoặc `SKIP_ERRORS`.
6. Mobile commit lại đúng file và preview token.
7. Backend tạo user/student/enrollment đúng một lần và trả báo cáo kết quả.

### Test case F03

| ID | Bước test | Kết quả mong đợi | Trạng thái hiện tại |
|---|---|---|---|
| F03-T01 | Bấm Tải tệp mẫu trên bản chạy `:8080`. | Trình duyệt tải file `.xlsx`. | **BLOCKED**: `FilePicker.saveFile` chưa hoạt động trên Flutter Web |
| F03-T02 | Upload file đúng hoàn toàn. | Preview đúng số dòng; database chưa đổi. | CẦN TEST SAU F03-T01 |
| F03-T03 | Upload dòng thiếu username, sai role, trùng user hoặc sai lớp. | Mỗi dòng lỗi có lý do cụ thể. | CẦN TEST |
| F03-T04 | Commit file lỗi với `ALL_OR_NOTHING`. | Không dòng nào được ghi. | CẦN TEST |
| F03-T05 | Commit file lỗi với chế độ bỏ dòng lỗi. | Request gửi `strategy=SKIP_ERRORS`; chỉ dòng hợp lệ được ghi. | **FAIL hiện tại**: UI gửi `SKIP_INVALID` |
| F03-T06 | Preview file A rồi commit file B bằng token A. | Backend từ chối checksum không khớp. | CẦN TEST |
| F03-T07 | Commit lại token đã dùng. | Bị từ chối hoặc trả idempotent; không tạo user trùng. | CẦN TEST |
| F03-T08 | Gọi preview/commit bằng Teacher. | `403`; không có dữ liệu mới. | CẦN TEST |

---

## 10. F04 — Kế hoạch đào tạo

### Use case F04-UC01 — Khóa định mức môn học theo học kỳ

| Thuộc tính | Nội dung |
|---|---|
| Actor chính | Admin |
| Điểm vào | Admin → Tiện ích → Kế hoạch & tiến độ đào tạo → Kế hoạch |
| API chuẩn | `GET /curriculum-requirements`, `PUT /curriculum-requirements`, `DELETE /curriculum-requirements/{id}` |
| Khóa nghiệp vụ | `semesterId + gradeLevel + subjectId` |

Luồng chính:

1. Admin chọn học kỳ.
2. Admin chọn khối và môn.
3. Nhập số tiết/tuần, tổng số tiết, ngày bắt đầu/kết thúc, cửa sổ thi và mốc kiến thức.
4. Mobile lưu bằng PUT upsert.
5. Reload phải trả đúng requirement vừa lưu.
6. F05 dùng requirement này làm đầu vào xếp TKB; F07 dùng để so sánh tiến độ.

### Test case F04

| ID | Bước test | Kết quả mong đợi |
|---|---|---|
| F04-T01 | Tạo requirement hợp lệ. | Lưu thành công và còn sau reload. |
| F04-T02 | Nhập ngày ngoài học kỳ. | Backend chặn và nêu trường ngày sai. |
| F04-T03 | Nhập `startDate > endDate`. | Không lưu. |
| F04-T04 | Nhập cửa sổ thi không hợp lệ. | Không lưu. |
| F04-T05 | Lưu lại cùng semester–grade–subject với số tiết khác. | Update bản cũ, không tạo tuple trùng. |
| F04-T06 | Xóa requirement rồi reload. | Bản ghi biến mất và không còn là đầu vào active của F05. |
| F04-T07 | Gọi mutation bằng Teacher/Student/Parent. | `403`. |

---

## 11. F05 — Tự xếp, lưu bản và công bố thời khóa biểu

### Use case F05-UC01 — Preview và Apply

| Thuộc tính | Nội dung |
|---|---|
| Actor chính | Admin |
| Điểm vào | Admin → Tiện ích → Tự xếp & phát hành thời khóa biểu |
| API chuẩn | `POST /timetableSlots/auto-plan` |
| Quy tắc | Không trùng lớp/GV/phòng; cùng môn giữa các lớp cùng khối lệch tối đa 2 ngày |

1. Chọn học kỳ đã có F04, lớp, teaching assignment, phòng và ca học.
2. Bấm **Xem phương án** với `apply=false`.
3. Kiểm tra `existingSlots`, `proposedSlots`, `unscheduledSlots`, từng item và warning.
4. Nếu còn conflict và `allowPartial=false`, Apply phải bị chặn.
5. Khi hợp lệ, bấm **Áp dụng phương án**.
6. Các slot được lưu nhưng vẫn là draft.

### Use case F05-UC02 — Version và Publish đa vai trò

1. Admin lưu một timetable version từ workspace hiện tại.
2. Trước publish, Giáo viên/Học sinh reload và không thấy slot draft.
3. Admin publish version.
4. Giáo viên thấy đúng slot theo `teacherId`; Học sinh thấy đúng slot theo `classId`.
5. Version khác được publish phải thay thế trạng thái published có kiểm soát.

### Test case F05

| ID | Bước test | Kết quả mong đợi |
|---|---|---|
| F05-T01 | Preview hợp lệ. | Không tăng số slot trong DB; hiện proposal đầy đủ. |
| F05-T02 | Tạo dữ liệu trùng giáo viên/lớp/phòng cùng ca. | Conflict ghi đúng entity; không apply âm thầm. |
| F05-T03 | So sánh lần học thứ `n` của cùng môn ở hai lớp cùng khối. | Chênh ngày `<=2`; nếu bất khả thi thì `UNSCHEDULED`. |
| F05-T04 | Apply proposal hai lần. | Không sinh slot trùng. |
| F05-T05 | Lưu timetable version. | Version có snapshot và số tiết đúng. |
| F05-T06 | Kiểm tra Teacher/Student trước publish. | Không thấy slot draft. |
| F05-T07 | Publish version rồi đăng nhập Teacher. | Teacher chỉ thấy slot được giao và tên lớp/môn/phòng thân thiện, không hiện ID `c-*`. |
| F05-T08 | Đăng nhập Student cùng lớp và Student lớp khác. | Student đúng lớp thấy slot; Student khác không thấy. |
| F05-T09 | Publish version thiếu dữ liệu bắt buộc. | Backend chặn và nêu blocker. |

---

## 12. F06 — Ngoại lệ, nghỉ dạy và lịch bù

### Use case F06-UC01 — Giáo viên báo ngoại lệ

| Thuộc tính | Nội dung |
|---|---|
| Actor tạo | Giáo viên |
| Actor duyệt | Admin |
| Điểm vào | Giáo viên → Tiến độ; Admin → Kế hoạch & tiến độ → Duyệt lịch bù |
| API chuẩn | `PUT /teaching-progress`, `PUT /teaching-progress/{id}/makeup` |

1. Giáo viên chọn một slot được phân công và đúng ngày học.
2. Chọn **Nghỉ/ngoại lệ**.
3. Nhập nội dung dự kiến, lý do và ngày bù sau ngày nghỉ.
4. Backend lưu `status=CANCELLED`, `completedPeriods=0`.
5. Admin thấy đúng request, lý do và ngày bù.
6. Admin duyệt hoặc từ chối kèm ghi chú.
7. Giáo viên reload và thấy trạng thái review.

### Test case F06

| ID | Bước test | Kết quả mong đợi |
|---|---|---|
| F06-T01 | Lưu ngoại lệ hợp lệ. | Có một progress record CANCELLED và một yêu cầu review. |
| F06-T02 | Bỏ trống lý do. | Mobile/backend chặn; không lưu. |
| F06-T03 | Chọn ngày bù bằng hoặc trước ngày nghỉ. | Backend chặn. |
| F06-T04 | Admin duyệt kèm ghi chú. | `makeupStatus=APPROVED`, Giáo viên thấy ghi chú. |
| F06-T05 | Admin từ chối request khác. | `REJECTED`, lý do review còn sau reload. |
| F06-T06 | Giáo viên sửa âm thầm record đã review. | Backend từ chối hoặc giữ audit/review nhất quán. |
| F06-T07 | Kiểm tra câu chữ Mobile sau lưu. | Phải ghi “gửi cho Admin/nhà trường”, không dùng role “Giáo vụ”. |

---

## 13. F07 — Cập nhật và cân bằng tiến độ thực dạy

### Use case F07-UC01 — Giáo viên cập nhật tiết đã dạy

1. Giáo viên mở **Tiến độ** và chọn slot đã publish thuộc mình.
2. Chọn ngày, nhập nội dung và số tiết hoàn thành.
3. Lưu `status=COMPLETED`.
4. Reload phải trả cùng record.
5. Cập nhật lại cùng `slotId + lessonDate` phải upsert, không tạo bản trùng.

### Use case F07-UC02 — Admin theo dõi chênh tiến độ

1. Chuẩn bị ít nhất hai lớp cùng khối, cùng môn, cùng học kỳ.
2. Giáo viên cập nhật ngày và số tiết khác nhau.
3. Admin mở màn hình cân bằng tiến độ.
4. Hệ thống chỉ so sánh trong cùng `gradeLevel + subjectId`.
5. Nếu ngày lệch trên 2 hoặc số tiết lệch trên 1, nêu đúng lớp chậm và gợi ý bù.

### Test case F07

| ID | Bước test | Kết quả mong đợi |
|---|---|---|
| F07-T01 | Lưu một tiết COMPLETED hợp lệ. | Persist và còn sau reload. |
| F07-T02 | Gửi slot của giáo viên khác. | `403`; không đổi dữ liệu. |
| F07-T03 | Update cùng slot/ngày. | Một record được cập nhật, không tăng count. |
| F07-T04 | So sánh hai lớp cùng khối/môn lệch đúng 2 ngày. | Trạng thái vẫn trong ngưỡng. |
| F07-T05 | Tạo chênh trên 2 ngày hoặc trên 1 tiết. | Admin thấy cảnh báo và đúng lớp chậm. |
| F07-T06 | So sánh hai lớp khác khối. | Không ghép chung một nhóm cân bằng. |
| F07-T07 | Một lớp chưa có log. | Không được đánh dấu cân bằng; hiện lớp còn thiếu cập nhật. |

---

## 14. F08 — Tự xếp và công bố lịch thi

### Use case F08-UC01 — Admin tạo lịch thi tự động

| Thuộc tính | Nội dung |
|---|---|
| Actor chính | Admin |
| Actor nhận | Giáo viên, Học sinh, Phụ huynh |
| Điểm vào | Admin → Tiện ích → Tự xếp & công bố lịch thi |
| API chuẩn | `/exam-periods`, schedule, room, allocate, graders, publish-schedule và `/me/exam-agenda` |

1. Admin tạo/chọn kỳ thi, năm học, học kỳ, khối và khoảng ngày.
2. Mobile lấy môn, lớp, học sinh, phòng và giáo viên thật từ API.
3. Bấm **Xem phương án**; chưa ghi database.
4. Hệ thống đề xuất ngày, môn, lớp, phòng, giám thị và số thí sinh.
5. Admin chỉ chỉnh ngoại lệ thực tế.
6. Bấm **Lưu phương án** để tạo schedule, room allocation, candidate và grader.
7. Backend chỉ publish khi đủ lớp, phòng, giám thị chính, thí sinh và người chấm.
8. Sau publish, các role đọc cùng schedule bằng API chuẩn.

### Test case F08

| ID | Bước test | Kết quả mong đợi | Trạng thái hiện tại |
|---|---|---|---|
| F08-T01 | Tạo kỳ thi và preview. | Không ghi schedule; proposal dùng dữ liệu thật. | CẦN UAT |
| F08-T02 | Chọn ngày ngoài period hoặc Chủ nhật. | Không tạo ca thi không hợp lệ. | CẦN TEST |
| F08-T03 | Thiếu phòng đủ sức chứa hoặc thiếu giáo viên. | Preview/apply dừng và nêu tài nguyên thiếu. | CẦN DATA CONFLICT |
| F08-T04 | Lưu proposal hợp lệ. | Có schedule, room, candidates và grader đúng class/subject. | Backend integration test ĐẠT; Mobile cần UAT |
| F08-T05 | Publish khi thiếu một thành phần. | Backend từ chối và period vẫn chưa publish. | CẦN TEST |
| F08-T06 | Publish đầy đủ rồi mở Student. | Student thấy ngày, môn, giờ, phòng, SBD/chỗ ngồi. | CẦN UAT |
| F08-T07 | Mở Parent và đổi con. | Chỉ thấy agenda của con đang chọn. | CẦN UAT |
| F08-T08 | Mở Teacher được gán chấm thi. | Thấy đúng nhiệm vụ chấm. | CẦN UAT |
| F08-T09 | Mở Teacher chỉ được gán coi thi. | Thấy nhiệm vụ coi thi từ `/me/exam-agenda`. | **FAIL thiết kế hiện tại**: Mobile chỉ gọi `/me/exam-grading` cho Teacher |

---

## 15. F09 — Điểm danh và đồng bộ đa vai trò

### Use case F09-UC01 — Giáo viên ghi điểm danh

| Thuộc tính | Nội dung |
|---|---|
| Actor ghi | Giáo viên |
| Actor đọc | Học sinh, Phụ huynh, Admin dashboard |
| Điểm vào | Giáo viên → Điểm danh |
| API chuẩn | `GET /attendance`, `GET /attendance/session-status`, `POST /attendance/unlock`, `POST /attendance/bulk` |

1. Giáo viên chọn slot đã publish thuộc mình và ngày hợp lệ.
2. Mobile đọc session status trước khi cho lưu.
3. Mobile tải roster thật cùng dữ liệu điểm danh đã có.
4. Giáo viên đánh dấu PRESENT/ABSENT_EXCUSED/ABSENT_UNEXCUSED/LATE.
5. Trạng thái khác PRESENT bắt buộc có ghi chú.
6. Session quá hạn phải unlock bằng lý do ít nhất 10 ký tự.
7. Bulk save upsert theo `slotId + date + studentId`.
8. Student, Parent và dashboard Admin nhận cùng kết quả.

### Test case F09

| ID | Bước test | Kết quả mong đợi | Trạng thái hiện tại |
|---|---|---|---|
| F09-T01 | Chọn slot/ngày hợp lệ. | Roster, marks và session status tải đúng. | CẦN UAT |
| F09-T02 | Chọn ngày tương lai hoặc ngoài học kỳ. | Trạng thái UPCOMING/invalid; nút lưu bị khóa. | ĐÃ KIỂM TRA validation |
| F09-T03 | Unlock bằng lý do dưới 10 ký tự. | Bị từ chối. | CẦN TEST |
| F09-T04 | Unlock bằng lý do hợp lệ. | Session writable; lưu lý do và thời gian unlock. | CẦN TEST |
| F09-T05 | Đánh dấu vắng/muộn không ghi chú. | Mobile/backend chặn. | CẦN TEST |
| F09-T06 | Lưu danh sách hợp lệ rồi lưu lại với thay đổi. | Update cùng record, không tăng count bất thường. | Backend automation ĐẠT; Mobile cần UAT |
| F09-T07 | Mở Lịch sử điểm danh Giáo viên. | Slot lỗi riêng không làm hỏng toàn bộ danh sách; tên lớp thân thiện. | **FAIL hiện tại**: `Future.wait` có thể fail toàn màn hình khi một slot trả 403 |
| F09-T08 | Student mở Chuyên cần. | Thấy đúng ngày, tiết, môn, trạng thái và ghi chú vừa lưu. | CẦN E2E GHI THẬT |
| F09-T09 | Parent chọn đúng con rồi mở Chuyên cần. | Dữ liệu khớp Student; con khác không bị lộ. | CẦN E2E GHI THẬT |
| F09-T10 | Admin reload dashboard. | Metric chuyên cần/cảnh báo thay đổi theo aggregation thật. | CẦN E2E GHI THẬT |

---

## 16. F10 — Nhập điểm, log thay đổi và hiển thị kết quả

### Use case F10-UC01 — Giáo viên nhập/sửa điểm

| Thuộc tính | Nội dung |
|---|---|
| Actor ghi | Giáo viên |
| Actor đọc | Học sinh, Phụ huynh, Admin Audit |
| Điểm vào | Giáo viên → Bảng điểm |
| API chuẩn | `GET /me/gradebook-context`, `GET /grades`, `POST /grades/bulk`, `GET /grades/{id}/change-logs` |
| Công thức chuẩn | Trọng số theo loại điểm; cùng một công thức cho mọi role và mọi tab |

1. Giáo viên chọn lớp, học kỳ và môn trong scope.
2. Mobile lấy gradebook context để quyết định read/write.
3. Nhập điểm 0–10 và lưu.
4. Khi sửa điểm cũ, bắt buộc có lý do và `expectedVersion` hiện tại.
5. Backend ghi change log gồm old/new score, reason, actor và time.
6. Student và Parent đọc cùng grade record; không dựng điểm mẫu cục bộ.
7. “Phổ điểm”, bảng điểm và tổng quan phải dùng cùng công thức.

Lưu ý: contract hiện tại không tạo API publish điểm riêng. Với flow hiện hành, điểm hợp lệ sau khi lưu được đọc ngay bởi downstream role. Nếu nghiệp vụ cần trạng thái nháp/công bố riêng, phải sửa contract và backend trước, không tự thêm endpoint Mobile.

### Test case F10

| ID | Bước test | Kết quả mong đợi | Trạng thái hiện tại |
|---|---|---|---|
| F10-T01 | Chọn lớp/học kỳ/môn trong scope. | Roster và điểm thật tải đúng; editability đúng context. | ĐÃ KIỂM TRA đọc |
| F10-T02 | Chọn/gửi lớp hoặc môn ngoài assignment. | Nút sửa bị ẩn hoặc API trả `403`. | CẦN TEST |
| F10-T03 | Nhập điểm 0, 10 và giá trị thập phân hợp lệ. | Persist và còn sau reload. | CẦN UAT GHI THẬT |
| F10-T04 | Nhập `<0`, `>10` hoặc không phải số. | Không lưu. | CẦN TEST |
| F10-T05 | Sửa điểm nhưng bỏ trống lý do. | Mobile chặn. | Có validation UI; cần test backend |
| F10-T06 | Sửa với lý do và `expectedVersion` đúng. | Update thành công; log đầy đủ. | **FAIL hiện tại**: Mobile chưa gửi `expectedVersion` |
| F10-T07 | Sửa bằng version cũ. | Backend trả conflict; không ghi đè dữ liệu mới. | **BLOCKED bởi F10-T06** |
| F10-T08 | So Bảng điểm và Phổ điểm cùng học sinh. | Cùng kết quả trung bình có trọng số. | **FAIL hiện tại**: Phổ điểm đang tính trung bình cộng |
| F10-T09 | Student mở Kết quả/chi tiết môn. | Thấy đúng điểm mới và cùng công thức. | CẦN E2E GHI THẬT |
| F10-T10 | Parent mở Học tập và Tổng quan. | Điểm/TB khớp Student; không gộp LATE thành vắng. | **FAIL hiện tại** ở phần tổng quan Parent |
| F10-T11 | Admin tìm Audit theo actor/entity. | Có event tương ứng với lần tạo/sửa điểm. | CẦN E2E GHI THẬT |

---

## 17. Các kịch bản xuyên vai trò bắt buộc

### E2E-01 — Cơ cấu đến TKB được công bố

1. Admin hoàn thành F02.
2. Admin tạo requirement F04 và teaching assignment.
3. Admin preview/apply/version/publish F05.
4. Giáo viên mở **Lịch dạy**.
5. Học sinh đúng lớp mở **Lịch học**.
6. Dùng một Giáo viên và Học sinh không thuộc scope để kiểm tra âm tính.

Kỳ vọng: mọi màn hình dùng cùng `slotId`, `classId`, `subjectId`, `roomId`; draft không rò rỉ; role ngoài scope không thấy slot.

### E2E-02 — Ngoại lệ đến duyệt lịch bù

1. Giáo viên tạo một progress COMPLETED và một progress CANCELLED.
2. Admin mở cân bằng tiến độ và duyệt request lịch bù.
3. Giáo viên reload lịch sử tiến độ.

Kỳ vọng: hai role thấy cùng progress ID, nội dung, lý do, ngày bù và review status.

### E2E-03 — Điểm danh đến Student/Parent/Admin

1. Giáo viên lưu một buổi có PRESENT, LATE và ABSENT.
2. Student kiểm tra lịch sử.
3. Parent chọn đúng con và kiểm tra cùng record.
4. Admin reload dashboard.

Kỳ vọng: dữ liệu chi tiết giống nhau; Parent không xem được con không liên kết; dashboard lấy aggregation thật.

### E2E-04 — Điểm đến Student/Parent/Audit

1. Giáo viên tạo một điểm.
2. Giáo viên sửa điểm bằng reason và version đúng.
3. Student và Parent đối chiếu điểm/TB.
4. Admin tìm log audit.

Kỳ vọng: mọi role thấy điểm mới nhất; log vẫn giữ giá trị cũ, mới, lý do và người sửa.

### E2E-05 — Lịch thi sau publish

1. Admin tạo/apply/publish kỳ thi đầy đủ.
2. Teacher được gán coi thi kiểm tra agenda.
3. Teacher được gán chấm thi kiểm tra grading task.
4. Student kiểm tra lịch, phòng, SBD và chỗ.
5. Parent chọn đúng con và đối chiếu cùng schedule.

Kỳ vọng: các role đọc cùng dữ liệu đã publish; không có agenda dựng riêng trên Mobile.

## 18. Blocker cần sửa trước khi xác nhận hoàn thành

| Mã | Luồng | Blocker | Điều kiện đóng |
|---|---|---|---|
| BL-01 | F01 | Reset chạy ngay, chưa có xác nhận; request còn `newPassword:null` | Có dialog xác nhận và request body đúng contract |
| BL-02 | F02 | Preview 0 ứng viên từng trả/hiện một lớp mới | Retest trả `newClassCount=0` và không gắn nhãn sai |
| BL-03 | F03 | Download template lỗi trên Flutter Web | Tải được `.xlsx` từ bản chạy `:8080` |
| BL-04 | F03 | Strategy UI `SKIP_INVALID` không khớp backend `SKIP_ERRORS` | Request commit dùng đúng enum contract |
| BL-05 | F05/F09 | Card TKB Giáo viên còn ưu tiên `classId` ở một vị trí | Toàn bộ UI ưu tiên `classCode/className` |
| BL-06 | F06 | Thông báo còn nhắc role “Giáo vụ” | Đổi thành Admin/nhà trường |
| BL-07 | F08 | Teacher workspace không tải agenda coi thi | Ghép `/me/exam-agenda` và `/me/exam-grading` không trùng task |
| BL-08 | F09 | Lịch sử dùng `Future.wait` all-or-nothing | Một slot 403 không làm mất các slot hợp lệ; scope BE/FE thống nhất |
| BL-09 | F10 | Mobile không gửi `expectedVersion` | Update có optimistic locking và test stale version |
| BL-10 | F10 | Phổ điểm dùng trung bình cộng | Dùng cùng trọng số/domain calculator với bảng điểm |
| BL-11 | F09/F10 | Tổng quan Parent tự tính sai TB và gộp mọi non-PRESENT thành vắng | Summary khớp màn chi tiết hoặc lấy summary chuẩn từ backend |
| BL-12 | Chung | Hồ sơ Giáo viên còn `10A1`, `Toán • 4 lớp` cố định | Lấy GVCN/môn/số lớp từ API |

## 19. Tiêu chí kết thúc F01–F10

Chỉ đánh dấu toàn bộ F01–F10 là hoàn thành khi:

- [ ] BL-01 đến BL-12 đã đóng hoặc có quyết định loại khỏi scope bằng văn bản.
- [ ] Tất cả test case main flow F01–F10 đạt.
- [ ] E2E-01 đến E2E-05 đạt bằng entity ID đã ghi lại.
- [ ] Không có dữ liệu mock/fallback business trong màn hình thuộc phạm vi.
- [ ] Không có API riêng cho Mobile trùng chức năng API Web.
- [ ] Draft không rò sang downstream role.
- [ ] Kiểm tra `401/403`, idempotency và cross-child isolation đạt.
- [ ] `flutter analyze`, `flutter test` và backend `mvn test` đều đạt trong cùng commit nghiệm thu.

## 20. Biên bản chạy test

| Cycle | Ngày | Mobile commit | Backend commit | Tester | PASS | FAIL | BLOCKED | Ghi chú |
|---|---|---|---|---|---:|---:|---:|---|
| 1 |  |  |  |  |  |  |  |  |
| 2 |  |  |  |  |  |  |  |  |

Với mỗi case, tester đổi trạng thái thành `PASS`, `FAIL`, `BLOCKED` hoặc `NOT RUN` trực tiếp trong bản sao biên bản của cycle; không sửa mô tả expected result để hợp thức hóa kết quả thực tế.
