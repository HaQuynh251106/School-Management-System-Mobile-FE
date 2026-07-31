# Trường học số — Mobile

Ứng dụng Flutter đồng bộ với SSE Backend và website cho bốn vai trò: quản trị
viên, giáo viên, học sinh và phụ huynh.

## Chức năng

- Điều hướng thích ứng: thanh dưới trên điện thoại, thanh bên trên tablet.
- Giao diện sáng/tối theo thiết bị và lưu lựa chọn của người dùng.
- Thời khóa biểu, điểm danh, bảng điểm, bài tập và tài chính.
- Khảo thí, lịch thi, báo cáo cá nhân và quy trình xin nghỉ học.
- Thông báo và trò chuyện cập nhật thời gian thực qua SSE.
- Dữ liệu thật từ PostgreSQL thông qua backend; không sử dụng mock server.
- Thanh toán MoMo Sandbox; đã loại bỏ VNPay và chức năng ngoại khóa.

## Chạy local

```bash
flutter pub get

# Flutter Web
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:4000

# Android Emulator
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Thiết bị Android/iOS thật cần một URL API HTTPS hoặc địa chỉ LAN truy cập được
từ thiết bị. Không đưa khóa bí mật vào `--dart-define`.

## Kiểm tra và đóng gói

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.example.com
flutter build ipa --release --dart-define=API_BASE_URL=https://api.example.com
```

Android App Bundle cần keystore. Bản iOS cần Apple Distribution certificate và
provisioning profile. Các khóa phát hành phải nằm trong secret store của CI,
không commit vào Git.
