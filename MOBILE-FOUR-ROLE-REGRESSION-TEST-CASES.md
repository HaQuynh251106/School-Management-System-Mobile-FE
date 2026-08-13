# Mobile Four-Role Regression Test Cases

## 1. Mục tiêu

Xác nhận ứng dụng Mobile chỉ còn bốn vai trò sản phẩm và việc hợp nhất nghiệp vụ không làm mất chức năng:

- `ADMIN`: quản trị hệ thống, cơ cấu/đào tạo, lịch thi và tài chính.
- `TEACHER`: lịch dạy, điểm danh, điểm, tiến độ và bài tập.
- `STUDENT`: lịch học, bài tập, kết quả và chuyên cần.
- `PARENT`: theo dõi con, kết quả, chuyên cần và thanh toán.

Giáo vụ và Kế toán là nhóm nghiệp vụ thuộc Admin, không còn tài khoản, route hoặc workspace độc lập.

## 2. Phạm vi ảnh hưởng

| Thành phần | Thay đổi | Cần kiểm tra |
|---|---|---|
| Đăng nhập | Bỏ nút Giáo vụ/Kế toán | Chỉ thấy bốn role và đăng nhập đúng trang chủ |
| Điều hướng | Bỏ `/academic-staff`, `/accountant` | Không còn workspace thứ năm/sáu |
| Admin | Nhận toàn bộ nghiệp vụ đào tạo và tài chính | Tất cả màn hình cũ vẫn có đường truy cập |
| Backend | Chỉ nhận `ADMIN`, `TEACHER`, `STUDENT`, `PARENT` khi tạo/import user | Role cũ phải bị từ chối, không tự nâng thành Admin |
| Dữ liệu demo | Xóa hai tài khoản demo tạo sai | Còn 6 user: 1 Admin, 2 giáo viên, 2 học sinh, 1 phụ huynh |
| API | Không xóa API đào tạo/tài chính | Admin gọi được API hiện có; Web/Mobile dùng chung contract |
| Luồng liên vai trò | Actor nguồn đổi từ Giáo vụ/Kế toán sang Admin | Dữ liệu publish vẫn đến đúng giáo viên, học sinh, phụ huynh |

## 3. Môi trường và tài khoản

- Mobile: `http://127.0.0.1:8080`
- Backend health: `http://127.0.0.1:4000/actuator/health`

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `Admin123@@` |
| Giáo viên | `gv.nguyenminh` | `nguyenminh123@` |
| Học sinh | `hs.nguyenminhan` | `nguyenminhanh123@@` |
| Phụ huynh | `ph.nguyenvanhung` | `nguyenvanhung123@` |

Quy ước kết quả: `PASS`, `FAIL`, `BLOCKED`, `NOT RUN`.

## 4. Smoke test sau khi hợp nhất role

| ID | Ưu tiên | Các bước chính | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| R01 | P0 | Mở trang đăng nhập | Chỉ có Quản trị, Giáo viên, Học sinh, Phụ huynh | NOT RUN |
| R02 | P0 | Lần lượt dùng bốn nút đăng nhập nhanh | Điều hướng lần lượt đến `/admin`, `/teacher`, `/student`, `/parent` | NOT RUN |
| R03 | P0 | Nhập `giaovu` hoặc `ketoan` và mật khẩu demo cũ | Đăng nhập thất bại; không tạo lại tài khoản | NOT RUN |
| R04 | P0 | Đăng nhập Admin rồi mở URL `/academic-staff` và `/accountant` | Không xuất hiện workspace role riêng; ứng dụng không lộ dữ liệu ngoài route hợp lệ | NOT RUN |
| R05 | P0 | Đăng nhập từng role, reload trang | Giữ phiên và trở về đúng workspace của role đó | NOT RUN |
| R06 | P0 | Đăng xuất từng role rồi dùng nút Back | Không quay lại màn hình đã xác thực; token bị thu hồi | NOT RUN |
| R07 | P0 | Admin mở danh sách người dùng và đếm dữ liệu demo | Có 6 tài khoản, chỉ thuộc bốn role đã chốt | NOT RUN |
| R08 | P0 | Tạo user bằng role `ACCOUNTANT` hoặc `ACADEMIC_STAFF` qua API/form/import | Backend trả lỗi validation; không tạo và không đổi ngầm thành Admin | NOT RUN |

## 5. Admin — kiểm thử chức năng được hợp nhất

Đường truy cập nghiệp vụ nâng cao: **Admin → Tiện ích**.

| ID | Ưu tiên | Các bước chính | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| A01 | P0 | Mở Tổng quan | Số user/lớp/chuyên cần/cần xử lý lấy từ API; không có số mock | NOT RUN |
| A02 | P1 | Chạm từng thẻ thống kê | Mở đúng danh sách người dùng, lớp, báo cáo chuyên cần hoặc tài chính | NOT RUN |
| A03 | P0 | Vào Người dùng, lọc Giáo viên/Học sinh/Phụ huynh | Danh sách đúng role; không có bộ lọc Giáo vụ/Kế toán | NOT RUN |
| A04 | P0 | Đặt lại mật khẩu LOCAL và SSO | LOCAL thu hồi phiên/token cũ; SSO hướng dẫn liên hệ hệ thống SSO, không sinh mật khẩu LOCAL | NOT RUN |
| A05 | P0 | Import Excel có dòng hợp lệ và lỗi | Preview đúng từng dòng; chỉ commit sau xác nhận; role ngoài bốn role bị báo lỗi | NOT RUN |
| A06 | P0 | Đào tạo → Năm học; tạo năm học hợp lệ | Backend tạo năm học và hai học kỳ; tải lại vẫn còn dữ liệu | NOT RUN |
| A07 | P0 | Đào tạo → Lớp; tạo lớp và gán GVCN | Lớp/GVCN lưu thật; giáo viên thấy đúng lớp được giao | NOT RUN |
| A08 | P0 | Tiện ích → Cơ cấu & phân lớp tự động; chạy Preview | Preview không ghi enrollment; hiển thị ứng viên, lớp, cảnh báo và phân bổ | NOT RUN |
| A09 | P0 | Xác nhận kết quả phân lớp sau Preview | Mỗi học sinh có đúng một enrollment trong năm; tải lại vẫn đúng lớp | NOT RUN |
| A10 | P0 | Tiện ích → Kế hoạch & tiến độ đào tạo; thêm định mức môn | Lưu đúng học kỳ–khối–môn, tổng tiết, thời gian và milestone; không tạo bản trùng | NOT RUN |
| A11 | P0 | Cùng màn hình, xem cân bằng tiến độ | So sánh đúng lớp cùng khối/môn; cảnh báo khi chênh quá hai ngày hoặc thiếu tiết | NOT RUN |
| A12 | P0 | Tiện ích → Tự xếp & phát hành TKB; bấm Preview | Không ghi slot; trả số đề xuất/chưa xếp và conflict rõ ràng | NOT RUN |
| A13 | P0 | Apply phương án, lưu version nháp rồi Publish | Chỉ version publish được gắn `publishedPlanId`; chỉ có một version hiện hành | NOT RUN |
| A14 | P1 | Khôi phục version TKB cũ | Tạo version mới từ snapshot; version trước thành `SUPERSEDED`; lịch sử không mất | NOT RUN |
| A15 | P0 | Tiện ích → Tự xếp & công bố lịch thi | Preview ngày/ca/môn, gán phòng/giám thị/thí sinh; chỉ publish khi đủ dữ liệu | NOT RUN |
| A16 | P0 | Tiện ích → Tài chính, công nợ & đối soát | Mở Trung tâm tài chính trong phiên Admin, không yêu cầu role Kế toán | NOT RUN |
| A17 | P0 | Tạo đợt thu, khoản thu, mở đợt và sinh hóa đơn | Sinh đúng scope lớp/học sinh; chạy lại không tạo hóa đơn trùng | NOT RUN |
| A18 | P0 | Mở Công nợ, tìm kiếm và lọc Chưa thu/Quá hạn/Đã thu | Kết quả và số dashboard khớp; quá hạn được tính theo `dueDate` | NOT RUN |
| A19 | P0 | Mở Đối soát VietQR, xác nhận một giao dịch | Payment/invoice cập nhật một lần; gọi lặp không ghi nhận trùng | NOT RUN |
| A20 | P1 | Từ chối một giao dịch chờ | Giao dịch chuyển trạng thái đúng; hóa đơn không bị ghi đã thanh toán | NOT RUN |

## 6. Giáo viên

| ID | Ưu tiên | Các bước chính | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| T01 | P0 | Đăng nhập sau khi Admin publish TKB | Lịch dạy chỉ chứa slot publish đúng `teacherId`; không thấy bản nháp | NOT RUN |
| T02 | P0 | Chạm shortcut Lớp điểm danh/Môn nhập điểm/Tiến độ/Bài tập | Mở đúng tab và giữ đúng phạm vi phân công | NOT RUN |
| T03 | P0 | Điểm danh một tiết hợp lệ | Lưu đúng slot–ngày–học sinh; vắng/trễ bắt buộc có lý do | NOT RUN |
| T04 | P0 | Thử điểm danh lớp hoặc slot không được giao | Backend trả `403`; dữ liệu không thay đổi | NOT RUN |
| T05 | P0 | Cập nhật tiến độ đã dạy | Ghi đúng chủ đề, số tiết và assignment; Admin nhìn thấy cùng bản ghi | NOT RUN |
| T06 | P0 | Khai báo nghỉ/ngoại lệ và ngày bù | Tạo yêu cầu chờ Admin duyệt; ngày bù phải sau ngày nghỉ | NOT RUN |
| T07 | P0 | Nhập/sửa điểm rồi nhập lý do | Lưu điểm và change log; xung đột version không ghi đè âm thầm | NOT RUN |
| T08 | P1 | Tạo, publish, đóng bài tập | Học sinh chỉ thấy bài đã publish; trạng thái và số bài shortcut cập nhật | NOT RUN |

## 7. Học sinh

| ID | Ưu tiên | Các bước chính | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| S01 | P0 | Mở Lịch học sau khi Admin publish TKB | Chỉ thấy lịch đúng `classId`, version publish và phòng/giáo viên chính xác | NOT RUN |
| S02 | P1 | Chạm bốn shortcut đầu trang | Mở đúng tiết trong ngày, bài chưa nộp, kết quả và chuyên cần | NOT RUN |
| S03 | P0 | Đối chiếu điểm vừa được giáo viên lưu/publish | Đúng môn, đầu điểm, điểm trung bình; không xem được học sinh khác | NOT RUN |
| S04 | P0 | Đối chiếu bản ghi điểm danh vừa tạo | Đúng ngày, tiết, môn, trạng thái và ghi chú | NOT RUN |
| S05 | P0 | Nộp bài tập đã publish | Submission lưu thật; tải lại còn dữ liệu; bài đóng không cho nộp | NOT RUN |
| S06 | P0 | Thử gọi API quản trị/giáo viên | Trả `403`; không lộ danh sách hoặc dữ liệu quản trị | NOT RUN |

## 8. Phụ huynh

| ID | Ưu tiên | Các bước chính | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| P01 | P0 | Đăng nhập và đổi giữa các con | Mỗi lần đổi con, toàn bộ điểm/chuyên cần/hóa đơn đổi theo `childId` | NOT RUN |
| P02 | P1 | Chạm shortcut Điểm TB/Có mặt/Vắng/Hóa đơn | Mở đúng tab chi tiết của con đang chọn | NOT RUN |
| P03 | P0 | Đối chiếu điểm và chuyên cần do giáo viên vừa cập nhật | Dữ liệu khớp học sinh; phụ huynh khác không truy cập được (`403`) | NOT RUN |
| P04 | P0 | Mở hóa đơn do Admin vừa sinh | Đúng học sinh, lớp, khoản thu, số tiền, hạn và trạng thái | NOT RUN |
| P05 | P0 | Tạo thanh toán VietQR | Nhận URL/QR/nội dung chuyển khoản được ký; invoice chưa thành PAID trước đối soát | NOT RUN |
| P06 | P0 | Admin đối soát rồi phụ huynh tải lại | Hóa đơn chuyển đúng trạng thái, có lịch sử/biên nhận và không cộng tiền hai lần | NOT RUN |

## 9. Luồng liên vai trò bắt buộc

| ID | Luồng | Chuỗi kiểm tra | Kết quả cuối |
|---|---|---|---|
| X01 | TKB | Admin tạo/preview/apply/publish → Giáo viên xem lịch dạy → Học sinh xem lịch học | Ba màn hình cùng version; nháp không lộ |
| X02 | Điểm danh | Giáo viên lưu → Học sinh xem → Phụ huynh chọn đúng con và xem | Cùng slot, ngày, trạng thái, lý do |
| X03 | Điểm số | Giáo viên nhập/sửa → Học sinh xem → Phụ huynh xem | Cùng đầu điểm và log; đúng quyền sở hữu |
| X04 | Tiến độ | Giáo viên cập nhật/nghỉ → Admin cân bằng và duyệt lịch bù | Trạng thái chuyển đúng; cảnh báo chênh lệch chính xác |
| X05 | Tài chính | Admin tạo đợt/sinh invoice → Phụ huynh tạo VietQR → Admin đối soát → Phụ huynh xem biên nhận | Invoice/payment đồng bộ, idempotent |
| X06 | Mất backend | Tắt backend rồi tải lại cả bốn workspace | Hiện lỗi/thử lại; tuyệt đối không hiện dữ liệu mock thay thế |

## 10. Điều kiện hoàn thành

Chỉ chấp nhận bản điều chỉnh khi:

1. Toàn bộ case `P0` đạt.
2. Không còn màn hình đăng nhập hoặc route riêng cho Giáo vụ/Kế toán.
3. Admin truy cập được đủ cơ cấu, kế hoạch, TKB, kỳ thi, tài chính và đối soát.
4. Không có API mới trùng chức năng giữa Web và Mobile.
5. Dữ liệu publish truyền đúng sang Giáo viên, Học sinh và Phụ huynh.
6. Không có fallback mock khi API lỗi hoặc trả danh sách rỗng.

## 11. Tổng hợp kết quả

| Tổng case | PASS | FAIL | BLOCKED | NOT RUN | Người test | Ngày test |
|---:|---:|---:|---:|---:|---|---|
| 54 | 0 | 0 | 0 | 54 |  |  |
