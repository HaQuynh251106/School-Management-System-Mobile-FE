# Mobile F01–F10 Test Guide

Danh sách test case chính thức và ô ghi kết quả nằm tại `MOBILE-F01-F10-USE-CASE-TEST-SPECIFICATION.md`.

## Môi trường đang chạy

- Mobile Web: `http://127.0.0.1:8080`
- Backend health: `http://127.0.0.1:4000/actuator/health`
- Admin: `admin` / `Admin123@@`
- Giáo viên: `gv.nguyenminh` / `nguyenminh123@`
- Học sinh: `hs.nguyenminhan` / `nguyenminhanh123@@`
- Phụ huynh: `ph.nguyenvanhung` / `nguyenvanhung123@`

Backend hiện chạy profile `demo` với H2. Dữ liệu tạo khi test sẽ mất nếu dừng backend.

## Nguyên tắc kiểm tra dữ liệu thật

- Tắt backend rồi tải lại màn hình: Mobile phải hiện trạng thái lỗi/tải lại, không được hiện số liệu mẫu thay thế.
- Tạo hoặc sửa dữ liệu ở role nguồn, đăng xuất rồi đăng nhập role nhận để kiểm tra đúng cùng bản ghi.
- Dashboard, báo cáo, Audit, lịch sử điểm danh và log sửa điểm đều phải thay đổi theo dữ liệu backend; không chấp nhận counter hoặc danh sách cố định trong ứng dụng.

## F01 — Reset authentication LOCAL/SSO

1. Đăng nhập Admin, mở tab **Người dùng** và chọn một tài khoản.
2. Nhấn **Đặt lại mật khẩu** rồi xác nhận.
3. Với LOCAL, kiểm tra thông báo `RESET_LINK_SENT`; ứng dụng không hiển thị mật khẩu tạm. Phiên cũ bị thu hồi và token demo chỉ dùng một lần.
4. Với SSO, kiểm tra thông báo `CONTACT_SSO_ADMIN`; hệ thống không tạo mật khẩu hoặc token LOCAL.

Kết quả đúng: backend tự quyết định nhánh theo `authType`; Mobile không gửi hoặc nhận mật khẩu có thể tái sử dụng.

## F02 — Cơ cấu năm học đến phân lớp

1. Đăng nhập Admin, mở tab **Đào tạo**.
2. Tab **Năm học**: tạo năm học, sau đó tạo học kỳ nằm trong khoảng ngày của năm học.
3. Tab **Lớp & GVCN**: tạo lớp và gán giáo viên chủ nhiệm.
4. Tab **Môn & Phòng**: tạo môn và phòng nếu dữ liệu chưa có.
5. Tab **Phân lớp**: chọn năm học/khối, chạy **Preview**, kiểm tra danh sách và cảnh báo, sau đó mới **Xác nhận phân lớp**.

Kết quả đúng: các bước dùng chung API với Web; không ghi phân lớp trước bước xác nhận.

## F03 — Import học sinh Excel

1. Đăng nhập Admin, mở tab **Người dùng**, nhấn biểu tượng import trên thanh tiêu đề.
2. Nhấn **Tải tệp mẫu**, điền dữ liệu và giữ nguyên cấu trúc cột.
3. Nhấn **Chọn Excel** để chạy preview.
4. Kiểm tra tổng số dòng, dòng hợp lệ và lỗi từng dòng.
5. Chọn **Không nhập nếu còn lỗi** hoặc **Bỏ dòng lỗi**, rồi nhấn **Xác nhận ghi dữ liệu**.

Kết quả đúng: commit chỉ nhận đúng file và `previewToken` vừa tạo; không dùng route import trực tiếp cũ.

## F04 — Kế hoạch đào tạo

1. Đăng nhập Admin, mở **Đào tạo** → **Kế hoạch đào tạo**.
2. Chọn học kỳ, nhấn **Thêm môn vào kế hoạch**.
3. Điền khối, môn, số tiết/tuần, tổng tiết, ngày bắt đầu/kết thúc, cửa sổ thi và milestone.
4. Lưu, tải lại màn hình và kiểm tra dữ liệu vẫn đúng.

Kết quả đúng: ngày nằm trong học kỳ, ngày bắt đầu không sau ngày kết thúc và mỗi bộ học kỳ–khối–môn chỉ có một định mức.

## F05 — Tự xếp thời khóa biểu

1. Đăng nhập Admin, mở **Đào tạo** → **Xếp TKB**.
2. Chọn học kỳ, giữ tắt **Cho phép phương án chưa xếp đủ** và nhấn **Preview**.
3. Kiểm tra số slot hiện có, đề xuất, chưa xếp và danh sách conflict/warning.
4. Chỉ khi preview đạt yêu cầu mới nhấn **Áp dụng**.
5. Nhấn **Lưu bản nháp**, kiểm tra phiên bản rồi **Phát hành**.

Kết quả đúng: preview không ghi dữ liệu; áp dụng và phát hành là hai bước riêng.

## F06 — Ngoại lệ và lịch bù

1. Đăng nhập Giáo viên, mở tab **Tiến độ**.
2. Chọn tiết/ngày, chọn **Nghỉ/ngoại lệ**, nhập lý do và ngày học bù rồi lưu.
3. Đăng xuất, đăng nhập Admin, mở **Đào tạo** → **Duyệt lịch bù**.
4. Kiểm tra yêu cầu, nhập ghi chú và **Duyệt** hoặc **Từ chối**.

Kết quả đúng: tiết hủy có số tiết hoàn thành bằng 0; lịch bù phải sau ngày nghỉ; log đã duyệt không bị sửa âm thầm.

## F07 — Giáo viên cập nhật tiến độ thực dạy

1. Đăng nhập Giáo viên, mở tab **Tiến độ**.
2. Chọn đúng tiết được phân công, ngày dạy, số tiết và chủ đề.
3. Chọn **Đã dạy** và lưu.
4. Đăng nhập Admin, mở **Đào tạo** → **Cân bằng tiến độ** để so sánh các lớp cùng khối/môn.

Kết quả đúng: giáo viên chỉ cập nhật slot được giao; hệ thống cảnh báo khi tiến độ các lớp lệch quá hai ngày.

## F08 — Tự xếp lịch thi

1. Đăng nhập Admin, mở **Đào tạo** → **Kỳ thi**.
2. Tạo/chọn kỳ thi, chọn các môn cố định và khoảng ngày.
3. Nhấn **Tạo preview**, kiểm tra ngày, ca, môn và cảnh báo.
4. Nhấn **Áp dụng**, gán phòng, hai giám thị khác nhau và thí sinh.
5. Chỉ nhấn **Công bố** khi các lịch đều đủ dữ liệu.

Kết quả đúng: Mobile ghép proposal bằng các resource kỳ thi hiện có, không tạo API `auto-exam` riêng.

## F09 — Điểm danh

1. Đăng nhập Giáo viên, mở tab **Điểm danh** → **Hôm nay**.
2. Chọn tiết, chạm ngày để chọn đúng ngày diễn ra tiết học.
3. Kiểm tra thông báo trạng thái phiên. Phiên tương lai/ngày nghỉ bị khóa; phiên trễ yêu cầu **Mở khóa** với lý do ít nhất 10 ký tự.
4. Chọn trạng thái từng học sinh. Với vắng hoặc muộn, nhập lý do/ghi chú bắt buộc.
5. Nhấn **Lưu điểm danh**, sau đó mở **Lịch sử** và kéo xuống để tải lại.
6. Đăng nhập Học sinh → **Chuyên cần**, sau đó đăng nhập Phụ huynh → chọn đúng con → **Chuyên cần**; đối chiếu cùng môn, ngày, tiết, trạng thái và ghi chú.

Kết quả đúng: lịch sử lấy dữ liệu thật; backend kiểm tra quyền quản lý slot, ngày/giờ và upsert theo slot–ngày–học sinh.

Lưu ý dữ liệu demo hiện có học kỳ bắt đầu ngày `17/08/2026`; trước ngày này, trạng thái `UPCOMING` và nút lưu bị khóa là hành vi đúng.

## F10 — Nhập và công bố điểm

1. Đăng nhập Giáo viên, mở tab **Bảng điểm** → **Bảng điểm**.
2. Chọn lớp, học kỳ và môn được phép dạy.
3. Nhập điểm Miệng/15 phút/Giữa kỳ/Cuối kỳ rồi lưu.
4. Khi sửa điểm đã có, nhập lý do; backend kiểm tra `expectedVersion` để tránh ghi đè đồng thời.
5. Mở **Phổ điểm** để kiểm tra thống kê và **Log sửa điểm** để xem lịch sử thật; kéo xuống để tải lại.
6. Đăng nhập Học sinh → **Điểm số**, sau đó đăng nhập Phụ huynh → chọn đúng con → **Học tập**; kiểm tra các đầu điểm và điểm trung bình được tính từ cùng bản ghi.

Kết quả đúng: giáo viên chỉ thấy phạm vi được phân công; log hiển thị điểm cũ/mới, lý do, người sửa và thời gian từ `/grades/{id}/change-logs`.
