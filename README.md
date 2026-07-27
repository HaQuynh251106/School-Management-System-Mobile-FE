# Trường học số Mobile V2

Ứng dụng Flutter mới dành cho hệ thống quản lý trường học, dùng chung API và
dữ liệu PostgreSQL với website.

## Kiến trúc trải nghiệm

- Điều hướng riêng cho quản trị viên, giáo viên, học sinh và phụ huynh.
- Dashboard theo vai trò, chỉ hiển thị thông tin cần quan tâm.
- Chức năng được nhóm theo công việc: Con người/Vận hành, Giảng dạy/Công việc,
  Học tập/Nhiệm vụ và Học tập/Gia đình.
- Có tìm kiếm danh sách, trạng thái tải/trống/lỗi và thao tác thêm mới.
- Hộp thư hợp nhất thông báo và trao đổi.
- Material 3 responsive, hỗ trợ light mode và dark mode.

## Kết nối backend

Không có dữ liệu demo trong ứng dụng. API được cấu hình khi chạy hoặc build:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000
```

Android Emulator dùng địa chỉ máy chủ:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Thiết bị thật cần dùng IP LAN hoặc tên miền HTTPS của backend.

## Kiểm tra

```powershell
flutter analyze
flutter test
flutter build web
flutter build apk
```
