# OpenAPI client cho Mobile

Hai client trong `packages/` duoc sinh tu contract Backend:

- `sse_finance_api` tu `School-Management-System-BE/docs/openapi/finance.yaml`
- `sse_identity_api` tu `School-Management-System-BE/docs/openapi/identity.yaml`
- `sse_academic_api` tu `School-Management-System-BE/docs/openapi/academic.yaml`

Chay lai sau moi thay doi contract:

```powershell
powershell -ExecutionPolicy Bypass -File tools/generate_openapi_clients.ps1
```

Script ghim OpenAPI Generator `7.24.0`, sinh cac Dart Dio client, cai dependency va
chay `build_runner`. Khong sua thu cong file trong package sinh tu dong.

Sau khi generate, bat buoc chay:

```powershell
flutter analyze
flutter test
```
