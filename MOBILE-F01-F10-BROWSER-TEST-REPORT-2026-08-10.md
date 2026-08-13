# Mobile F01–F10 Browser Test Report

## 1. Thông tin kiểm thử

- Thời điểm: 10/08/2026, múi giờ Asia/Ho_Chi_Minh.
- Mobile FE: `master` tại commit `b25e0c2`.
- Backend: `main` tại commit `cd44104`.
- Mobile URL: `http://127.0.0.1:8080/#/login`.
- Backend URL: `http://127.0.0.1:4000`; `/actuator/health` trả `UP`.
- Phương pháp: kiểm thử thủ công trên trình duyệt, quan sát UI và đối chiếu trực tiếp response API thật.
- Tài khoản đã dùng: `admin`, `giaovu`, `gv.nguyenminh`, `hs.nguyenminhan`, `ph.nguyenvanhung`.
- Không dùng mock API trong quá trình kiểm thử.

Quy ước trạng thái:

- **PASS**: chức năng/điều kiện đã kiểm tra hoạt động đúng.
- **FAIL**: có lỗi tái hiện được.
- **BLOCKED**: màn hình hoạt động nhưng dữ liệu seed chưa đủ để chạy trọn luồng ghi dữ liệu.

## 2. Kết quả tổng quan

Đã thực hiện **32 kịch bản**:

- **21 PASS**.
- **7 FAIL**.
- **4 BLOCKED** do chưa có dữ liệu nghiệp vụ phù hợp.

Các lỗi cần ưu tiên nhất:

1. F03 không tải được tệp Excel mẫu trên Flutter Web.
2. F09 lịch sử điểm danh giáo viên không tải được vì dữ liệu TKB và phân quyền điểm danh không thống nhất.
3. F10 dùng hai công thức điểm trung bình khác nhau giữa Bảng điểm và Phổ điểm.
4. Tổng quan phụ huynh tính điểm trung bình và số buổi vắng khác với màn chi tiết.
5. Hồ sơ giáo viên còn thông tin cố định `Toán • 4 lớp`, không lấy từ API.

## 3. Danh sách kịch bản đã test

| ID | Luồng | Vai trò | Kịch bản đã kiểm tra | Kết quả thực tế | Trạng thái |
|---|---|---|---|---|---|
| BT-01 | F01 | Admin | Đăng nhập LOCAL | Vào đúng ứng dụng Admin, phiên và role hợp lệ | PASS |
| BT-02 | Chung | Admin | Dashboard dùng dữ liệu thật | Hiển thị 8 tài khoản, 3 lớp, 0.0% chuyên cần, 2 mục cần xử lý | PASS |
| BT-03 | F01 | Admin | Mở danh sách người dùng | Tải được 8 người dùng thật từ backend | PASS |
| BT-04 | F03 | Admin | Bấm `Tải tệp mẫu` tại Import Excel | Báo `UnimplementedError: saveFile() has not been implemented` | FAIL |
| BT-05 | F01 | Admin | Reset mật khẩu người dùng `gv.minh` | Trả thông báo gửi link một lần và thu hồi phiên cũ; không lộ mật khẩu plaintext | PASS |
| BT-06 | Chung | Admin | Báo cáo tài khoản/lớp | Số liệu role và sĩ số khớp dữ liệu backend | PASS |
| BT-07 | Chung | Admin | Audit đăng nhập/đăng xuất | Có log đăng nhập và các request logout vừa thực hiện | PASS |
| BT-08 | F02 | Admin | Xem năm học/học kỳ | Tải được năm học 2026–2027, trạng thái ACTIVE | PASS |
| BT-09 | F02 | Admin | Xem lớp và GVCN | Tải được 10A1, 10A2, 8A1 cùng sĩ số/GVCN thật | PASS |
| BT-10 | F02 | Admin | Xem môn học và phòng | Tải được 5 môn và 3 phòng | PASS |
| BT-11 | F02 | Admin | Preview phân lớp khối 10 | 0 ứng viên nhưng kết quả lại ghi `1 lớp mới` và dùng mã lớp hiện có 10A1 | FAIL |
| BT-12 | F04 | Admin | Mở Kế hoạch đào tạo | Empty state đúng; chưa có định mức môn học để test lưu/xóa | BLOCKED |
| BT-13 | F05 | Admin | Preview tự xếp TKB | Preview 8 tiết hiện có, 0 đề xuất, 0 chưa xếp; chưa thay đổi dữ liệu; nút Apply chỉ bật sau preview | PASS |
| BT-14 | F06/F07 | Admin | Mở Cân bằng tiến độ | Empty state đúng; chưa có tiến độ giáo viên để duyệt/đối chiếu | BLOCKED |
| BT-15 | F06 | Admin | Mở Duyệt lịch bù | Empty state đúng; chưa có đề xuất lịch bù để duyệt/từ chối | BLOCKED |
| BT-16 | F08 | Admin | Mở Tự xếp lịch thi | Tải được 5 môn; chưa có kỳ thi nên Preview/Apply/Publish bị khóa | BLOCKED |
| BT-17 | F05/F09 | Giáo viên | Xem TKB cá nhân và scope tiết dạy | API trả cả môn ngoài chuyên ngành; UI hiển thị raw ID `c-10a1`, `c-8a1` thay cho 10A1, 8A1 | FAIL |
| BT-18 | F07 | Giáo viên | Lưu tiến độ khi thiếu nội dung | Chặn lưu và báo `Hãy chọn tiết và nhập nội dung bài học` | PASS |
| BT-19 | F09 | Giáo viên | Chọn ngày ngoài học kỳ để điểm danh | Báo ngày không thuộc lịch/học kỳ và khóa nút lưu | PASS |
| BT-20 | F09 | Giáo viên | Mở tab Lịch sử điểm danh | Không tải được, chỉ hiện nút `Tải lại lịch sử`; retry vẫn lỗi | FAIL |
| BT-21 | F10 | Giáo viên | Xem Bảng điểm 10A1/Toán/HK1 | Tải đúng học sinh và bốn đầu điểm; TB có trọng số là 8.07 | PASS |
| BT-22 | F10 | Giáo viên | Xem Phổ điểm của cùng dữ liệu | Hiển thị TB 8.25, khác Bảng điểm 8.07 | FAIL |
| BT-23 | Chung | Giáo viên | Xem hồ sơ/phạm vi giảng dạy | Hiển thị cố định `Lớp chủ nhiệm 10A1`, `Toán • 4 lớp`; số lớp không khớp dữ liệu TKB | FAIL |
| BT-24 | F05 | Học sinh | Xem lịch học | Tải được các tiết Toán, Vật lý, Ngữ văn từ API | PASS |
| BT-25 | F10 | Học sinh | Xem kết quả HK1 | Hiển thị TB học kỳ 7.53 cùng bốn môn thật | PASS |
| BT-26 | F10 | Học sinh | Xem chi tiết Toán | Hiển thị 9.0, 8.5, 7.5, 8.0 và TB có trọng số 8.07 | PASS |
| BT-27 | F09 | Học sinh | Xem chuyên cần và chi tiết buổi vắng | Hiển thị 2 có mặt, 1 vắng phép, 1 vắng KP, 1 muộn; chi tiết có ngày, tiết và ghi chú | PASS |
| BT-28 | F09/F10 | Phụ huynh | Xem Tổng quan Nguyễn Minh An | Điểm TB 7.9 và `3 Vắng` không khớp màn chi tiết 7.53; lượt muộn bị gộp vào vắng | FAIL |
| BT-29 | F10 | Phụ huynh | Xem kết quả Nguyễn Minh An | Dữ liệu và TB 7.53 khớp màn Học sinh | PASS |
| BT-30 | F09 | Phụ huynh | Xem chuyên cần Nguyễn Minh An | Các trạng thái và lịch sử khớp màn Học sinh | PASS |
| BT-31 | Liên kết role | Phụ huynh | Chuyển từ Nguyễn Minh An sang Phạm Hoài Bình | Tải đúng dữ liệu riêng: TB 8.75 và chuyên cần 100% | PASS |
| BT-32 | F01 | Tất cả role | Đăng xuất sau kiểm thử | Quay về trang đăng nhập; audit có ghi nhận logout | PASS |

## 4. Chi tiết lỗi và cách tái hiện

### BUG-01 — F03 không tải được file mẫu Excel trên Web

- Mức độ: **High**.
- Vai trò: Admin.
- Bước tái hiện:
  1. Đăng nhập Admin.
  2. Mở `Người dùng` → `Import Excel`.
  3. Bấm `Tải tệp mẫu`.
- Kỳ vọng: trình duyệt tải `mau-nhap-hoc-sinh.xlsx`.
- Thực tế: `Không thể tải tệp mẫu: UnimplementedError: saveFile() has not been implemented.`
- Nguyên nhân xác nhận ở FE: `user_import_page.dart` gọi `FilePicker.platform.saveFile(...)`; cách này chưa có implementation trên nền tảng Web đang chạy.
- Ảnh hưởng: không thể bắt đầu đúng luồng import Excel bằng file mẫu.

### BUG-02 — F09 lịch sử điểm danh giáo viên luôn lỗi

- Mức độ: **High**.
- Vai trò: Giáo viên `gv.nguyenminh`.
- Bước tái hiện:
  1. Đăng nhập Giáo viên.
  2. Mở `Điểm danh` → `Lịch sử`.
  3. Bấm `Tải lại lịch sử`.
- Kỳ vọng: hiển thị các buổi điểm danh thuộc tiết giáo viên được phép quản lý.
- Thực tế: màn hình tiếp tục chỉ hiện nút `Tải lại lịch sử`.
- Đối chiếu API:

| Slot | Môn | `/attendance?slotId=...` |
|---|---|---|
| `tt-1` | Toán | 200 |
| `tt-3` | Ngữ văn | 403 — giáo viên chỉ được điểm danh đúng môn chuyên ngành |
| `tt-7` | Toán | 200 |
| `tt-5` | Sinh học | 403 — giáo viên chỉ được điểm danh đúng môn chuyên ngành |
| `tt-6` | Toán | 200 |

- Nguyên nhân:
  - `/me/timetable` trả cả `tt-3` và `tt-5` cho giáo viên này.
  - `/attendance` lại từ chối đúng hai slot đó theo môn chuyên ngành.
  - FE dùng `Future.wait` tải lịch sử của toàn bộ slot; một request 403 làm hỏng toàn bộ màn hình.
  - FE che mất nội dung lỗi, nên người dùng không biết vì sao retry thất bại.
- Cần thống nhất một quy tắc: backend chỉ trả slot hợp lệ trong `/me/timetable`, hoặc quyền attendance phải theo teaching assignment hợp lệ. FE vẫn cần xử lý lỗi từng slot thay vì làm hỏng toàn bộ danh sách.

### BUG-03 — F10 Phổ điểm tính sai công thức so với Bảng điểm

- Mức độ: **High** vì ảnh hưởng kết quả học tập.
- Dữ liệu Toán của Nguyễn Minh An: Miệng 9.0, 15 phút 8.5, Giữa kỳ 7.5, Cuối kỳ 8.0.
- Kỳ vọng theo trọng số 1–1–2–3: `(9 + 8.5 + 7.5×2 + 8×3) / 7 = 8.07`.
- Bảng điểm và màn Học sinh hiển thị đúng 8.07.
- Phổ điểm giáo viên hiển thị 8.25 vì đang cộng đều bốn đầu điểm rồi chia 4.
- Cần dùng duy nhất một hàm/công thức trung bình do backend hoặc domain service cung cấp cho mọi role.

### BUG-04 — Tổng quan phụ huynh không khớp màn chi tiết

- Mức độ: **High** vì phụ huynh nhìn thấy số liệu tổng quan sai.
- Với Nguyễn Minh An:
  - Tổng quan: `Điểm TB 7.9`, `2/5 Có mặt`, `3 Vắng`.
  - Màn Kết quả: `TB 7.53`.
  - Màn Chuyên cần: 2 có mặt, 1 vắng phép, 1 vắng không phép, 1 muộn.
- Nguyên nhân FE xác nhận:
  - Tổng quan lấy trung bình cộng trực tiếp mọi `score`, không áp dụng trọng số/môn học.
  - Tổng quan tính mọi trạng thái khác `PRESENT` là `Vắng`, nên `LATE` cũng bị gộp vào vắng.
- Cần lấy summary chuẩn từ backend hoặc dùng cùng domain calculator với màn chi tiết.

### BUG-05 — TKB và dropdown điểm danh hiển thị ID kỹ thuật của lớp

- Mức độ: **Medium**.
- Thực tế: hiển thị `c-10a1`, `c-8a1`.
- API đã trả `classCode: 10A1/8A1`, nên FE phải ưu tiên `classCode` hoặc `className`, chỉ fallback về `classId` khi thật sự thiếu.
- Vị trí thấy lỗi: thẻ TKB giáo viên và `Chọn tiết` trong màn Điểm danh.

### BUG-06 — Hồ sơ giáo viên còn dữ liệu cố định

- Mức độ: **Medium**, vi phạm yêu cầu không dùng dữ liệu mock/tĩnh.
- Thực tế: luôn hiện `Lớp chủ nhiệm 10A1` và `Toán • 4 lớp`.
- Code hiện tại dùng `const ListTile` với chuỗi cố định; số lớp không được tính từ `/me/timetable` hoặc teaching assignment.
- Cần lấy GVCN, môn và số lớp từ API dùng chung với các màn TKB/Bảng điểm.

### BUG-07 — Preview phân lớp tạo “lớp mới” khi không có ứng viên

- Mức độ: **Medium**.
- Input: năm học 2026–2027, khối 10, sức chứa 45.
- Response/UI: `0 ứng viên · 0 được xếp · 1 lớp mới`, bên dưới là `10A1 · mới 0/45 HS`.
- Kỳ vọng: không đề xuất lớp mới khi không có học sinh cần xếp; lớp 10A1 hiện hữu cũng không được gắn nhãn `mới`.
- Cần sửa logic preview backend hoặc tên trường/nhãn hiển thị nếu response đang mang nghĩa khác.

### BUG-08 — Reset mật khẩu chạy ngay, không có bước xác nhận

- Mức độ: **Low**.
- Chọn menu `Đặt lại mật khẩu` thực thi ngay và thu hồi phiên cũ.
- Đây là thao tác ảnh hưởng đăng nhập của người khác; nên có hộp xác nhận nêu rõ hậu quả trước khi gọi API.
- Trong lần test này, thao tác đã được thực hiện với user `gv.minh`.

## 5. Các luồng chưa thể test trọn vẹn

| Luồng | Lý do | Dữ liệu cần bổ sung để test |
|---|---|---|
| F03 Import Excel preview/commit | Tải file mẫu bị lỗi ở bước đầu | Sửa download Web hoặc cung cấp file `.xlsx` hợp lệ/lỗi |
| F04 Tạo/sửa/xóa kế hoạch đào tạo | Chưa có định mức môn học | Seed một curriculum requirement hoặc cho phép tạo mới từ UI |
| F05 Apply/publish TKB | Preview không có đề xuất mới; test tránh ghi dữ liệu ngoài ý muốn | Bộ dữ liệu có slot chưa xếp và tiêu chí conflict |
| F06 Duyệt lịch bù | Không có đề xuất | Một giáo viên tạo buổi nghỉ và đề xuất lịch bù |
| F07 Đối chiếu/cân bằng tiến độ | Chưa có actual progress | Tiến độ ít nhất hai lớp cùng khối/cùng môn |
| F08 Apply/publish lịch thi | Chưa có exam period | Một exam period hợp lệ cùng phòng và availability giám thị |
| F09 Lưu một buổi điểm danh hợp lệ | Lần test chỉ kiểm tra validation, không ghi thay đổi | Chọn ngày trong học kỳ và xác nhận cho phép tạo dữ liệu test |
| F10 Nhập/công bố điểm | Lần test chỉ đọc và đối chiếu công thức | Bộ dữ liệu riêng cho phép thay đổi/công bố mà không ảnh hưởng demo |

## 6. Thứ tự đề nghị xử lý

1. Sửa BUG-02 để thống nhất teaching assignment, `/me/timetable` và quyền `/attendance`.
2. Chuẩn hóa một công thức điểm trung bình cho BUG-03 và BUG-04; ưu tiên tính ở backend.
3. Sửa BUG-01 để mở khóa luồng F03.
4. Loại bỏ dữ liệu cố định và raw ID ở BUG-05/BUG-06.
5. Sửa semantic preview phân lớp ở BUG-07.
6. Thêm xác nhận cho thao tác reset mật khẩu ở BUG-08.

Sau khi sửa nhóm 1–4, cần chạy lại toàn bộ kịch bản BT-04, BT-17, BT-20, BT-22, BT-23, BT-28 và bổ sung dữ liệu seed cho các luồng đang BLOCKED.
