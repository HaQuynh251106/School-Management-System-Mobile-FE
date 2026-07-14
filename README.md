# Smart School Ecosystem Mobile

Ứng dụng Flutter cho Admin, giáo viên, học sinh và phụ huynh. Ứng dụng gọi trực tiếp SSE Backend và lưu access/refresh token bằng secure storage của hệ điều hành.

## Chạy local

```bash
flutter pub get

# Chrome/Web
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000

# Android Emulator (localhost của máy phát triển là 10.0.2.2)
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Thiết bị thật phải dùng HTTPS URL hoặc địa chỉ LAN truy cập được từ thiết bị. Không đưa secret vào `--dart-define`; Mobile chỉ cần URL public của API.

## Kiểm tra trước khi phát hành

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.example.com
flutter build ipa --release --dart-define=API_BASE_URL=https://api.example.com
```

Việc ký Android/iOS cần keystore, Apple Distribution certificate và provisioning profile của chủ sản phẩm; các khóa này phải đặt trong secret store của CI, không commit vào Git.
