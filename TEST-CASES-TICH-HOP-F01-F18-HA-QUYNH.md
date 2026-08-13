# TEST CASE TICH HOP MOBILE F01-F18

Cap nhat: 13/08/2026

Nhanh Mobile: `integration-haquynh-f01-f18`

Nhanh Backend: `integration-haquynh-f01-f18`

## 1. Muc tieu nghiem thu

- Xac nhan cac luong F01-F10 cua Ha Quynh van hoat dong sau khi ghep voi F11-F18.
- Xac nhan ung dung giu du 6 vai tro: Quan tri, Giao vu, Ke toan, Giao vien, Hoc sinh va Phu huynh.
- Kiem tra du lieu Mobile lay tu Backend that, khong roi ve fixture/mock khi API loi.
- Kiem tra phan quyen theo vai tro va theo doi tuong: lop duoc giao, hoc sinh hien tai, con cua phu huynh.

## 2. Moi truong va tai khoan

- Backend: `http://127.0.0.1:4000`
- Mobile Flutter Web: `http://127.0.0.1:5180`
- PostgreSQL va Backend phai o trang thai `healthy` truoc khi test.

| Vai tro | Tai khoan | Mat khau |
|---|---|---|
| Quan tri | `admin` | `Admin123@@` |
| Giao vu | `giaovu` | `Giaovu123@@` |
| Ke toan | `ketoan` | `Ketoan123@@` |
| Giao vien | `gv.nguyenminh` | `nguyenminh123@` |
| Hoc sinh | `hs.nguyenminhan` | `nguyenminhanh123@@` |
| Phu huynh | `ph.nguyenvanhung` | `nguyenvanhung123@` |

Quy uoc ket qua: `PASS` khi ket qua thuc te trung ket qua mong doi; `FAIL` khi sai nghiep vu, sai phan quyen, hien du lieu mau hoac UI khong cho thao tac hop le.

## 3. Smoke test tich hop bat buoc

| Ma | Uu tien | Buoc kiem tra | Ket qua mong doi |
|---|---:|---|---|
| INT-01 | P0 | Dang nhap lan luot 6 tai khoan tren | Moi tai khoan vao dung workspace; khong dung o Splash va khong bi day ve trang vai tro khac |
| INT-02 | P0 | Refresh trinh duyet sau khi dang nhap, sau do dang xuat | Phien duoc khoi phuc dung vai tro; dang xuat xoa token va ve Login |
| INT-03 | P0 | Tat Backend roi tai lai mot man dang co du lieu | Hien loi tieng Viet va nut Thu lai; khong hien fixture/mock thay cho du lieu that |
| INT-04 | P0 | Parent truy cap hoc sinh khong phai con minh; Teacher truy cap lop khong duoc giao | Backend tra `403`; Mobile hien thong bao tu choi phu hop |
| INT-05 | P1 | Thu nho/mo rong cua so Flutter Web va mo tren Android | Khong tran chu, chong nut, mat tab hoac mat thao tac chinh |

## 4. Test case F01-F10 cua Ha Quynh sau khi ghep

| Ma | Vai tro | Luong va buoc chinh | Ket qua mong doi |
|---|---|---|---|
| F01-01 | Tat ca | Dang nhap sai mat khau, sau do dang nhap dung | Sai mat khau bi tu choi; dung mat khau vao dung workspace |
| F01-02 | Tat ca | Chon Quen mat khau, gui yeu cau, mo link/token dat lai va dat mat khau moi | Token hop le doi duoc mat khau; token sai/het han bi tu choi |
| F01-03 | Quan tri | Reset mat khau mot tai khoan; khoa va mo khoa tai khoan | Mat khau cu khong con dung; tai khoan bi khoa khong dang nhap duoc; mo khoa dang nhap lai duoc |
| F02-01 | Giao vu | Mo Co cau, tao/kiem tra nam hoc, hoc ky, lop | Du lieu luu Backend va hien lai sau refresh |
| F02-02 | Giao vu | Tao lop co hau to moi nhu `10A11`, sua thong tin va xoa lop khong con rang buoc | Khong bi gioi han A1-A10; quy tac trung ma va rang buoc xoa duoc thong bao ro |
| F02-03 | Giao vu | Chay preview phan lop/intake roi xac nhan | So luong va danh sach hoc sinh dung; khong phan mot hoc sinh vao hai lop cung luc |
| F03-01 | Quan tri | Tai file Excel hop le, xem preview, sau do commit import | Preview bao dung tong hop; du lieu chi duoc tao sau commit |
| F03-02 | Quan tri | Tai file sai cot, trung ma hoac sai dinh dang | Hien loi theo dong/cot; khong import nua chung file |
| F04-01 | Giao vu | Tao ke hoach/yeu cau chuong trinh theo khoi, mon va hoc ky | Tong so tiet va phan bo duoc luu; du lieu hien dung khi mo lai |
| F04-02 | Giao vu | Nhap so tiet am, bang 0 khong hop le hoac trung yeu cau | Backend tu choi va Mobile hien loi co the hieu |
| F05-01 | Giao vu | Chon lop, hoc ky, ngay duoc phep xep; chay tao TKB o che do preview | Preview khong tu ghi vao TKB dang phat hanh |
| F05-02 | Giao vu | Bo chon mot ngay nghi/le va chay lai tao TKB | Ngay bi bo chon de trong; khong ep moi tuan phai du T2-T7 |
| F05-03 | Giao vu | Apply va phat hanh mot ban TKB hop le | Tao version moi; Hoc sinh, Giao vien va Phu huynh xem cung lich da phat hanh |
| F05-04 | Giao vu | Tao xung dot giao vien/phong/ca hoac vuot so tiet chuong trinh | Xung dot bi chan hoac liet ke ro; khong ghi lich loi |
| F06-01 | Giao vu/Giao vien | Tao ngoai le nghi tiet, doi phong hoac lich bu | Trang thai va ly do duoc luu, nguoi lien quan xem dung thay doi |
| F06-02 | Giao vu | Dat lich bu trung giao vien, phong hoac lop | Backend tra xung dot; khong tao ban ghi nua chung |
| F07-01 | Giao vien | Mo Tien do giang day, cap nhat tiet da day va noi dung thuc te | Tien do thay doi theo du lieu that va van dung sau refresh |
| F07-02 | Giao vu | Duyet tien do cua giao vien/lop | Chi thay dung pham vi; so lieu tong hop khop cac cap nhat chi tiet |
| F08-01 | Giao vu | Tao dot thi, tao lich, gan phong/giam thi/thi sinh/giao vien cham va phat hanh | Chi phat hanh khi du dieu kien; revision tang dung |
| F08-02 | Giao vu | Thu tao hai lich thi trung phong, lop hoac giam thi | Bi chan `409`; lich hop le cu khong bi thay doi |
| F08-03 | HS/PH/GV | Mo lich thi sau khi phat hanh | HS va PH thay ky thi sap dien ra, phong/SBD/cho; GV thay nhiem vu dung pham vi |
| F09-01 | Giao vien | Diem danh lop duoc giao, luu PRESENT/LATE/ABSENT_EXCUSED/ABSENT_UNEXCUSED | Luu dung trang thai; dashboard khong tinh di muon thanh vang |
| F09-02 | Giao vien | Diem danh ngoai phan cong, ngoai hoc ky hoac sua bang version cu | Bi chan `403/400/409`; du lieu goc khong doi |
| F09-03 | HS/PH | Xem lich su chuyen can cua minh/dung con | Chi thay dung pham vi; Parent chon con khac bi `403` |
| F10-01 | Giao vien | Nhap diem hop le, sua diem, bulk save va xem change log | Diem/version/log thay doi dung, khong mat cac dau diem khac |
| F10-02 | Giao vien | Nhap diem ngoai 0-10 hoac ghi de bang version cu | Bi chan `400/409`; diem hien tai duoc giu nguyen |
| F10-03 | HS/PH | Xem ket qua da cong bo | Chi hien diem duoc phep cong bo va dung hoc sinh |

## 5. Test case F11-F18 va state hoa don

| Ma | Vai tro | Luong va buoc chinh | Ket qua mong doi |
|---|---|---|---|
| F11-01 | GV/HS/PH | GV tao nhap, publish; HS nop bai/nop lai; GV cham; PH xem ket qua | Bai nhap an voi HS; nop/cham dung deadline va pham vi; PH chi xem bai cua con |
| F11-02 | GV/HS | Dong bai roi thu nop; mo lai va nop lai | Khi dong tra `409`; sau mo lai ghi nhan attempt moi |
| F11-03 | GV/HS/PH | Gan tep de bai va tep bai nop, sau do tai bang tung vai tro | Chi nguoi lien quan tai duoc; tep chua gan/ngoai pham vi bi `403` |
| F12-01 | PH/GV | PH gui tin cho GVCN/GV bo mon; GV doc va tra loi | Tin co trang thai Da gui/Da xem; unread giam sau khi mo |
| F12-02 | GV/HS/PH | GV preview nguoi nhan va gui announcement theo lop | HS va PH dung lop nhan mot thong bao; gui lai cung idempotency key khong nhan doi |
| F12-03 | PH | Thu mo chat voi Admin hoac nguoi ngoai pham vi | Bi chan `403`; danh ba khong lo tai khoan toan truong |
| F13-01 | Admin/HS/PH | Tao CLB co phi/capacity; HS hoac PH dang ky; Admin duyet | Trang thai PENDING/APPROVED dung; duyet sinh dung mot hoa don |
| F13-02 | HS/PH | Dang ky trung, het cho va huy dang ky | Trung bi `409`; het cho vao WAITLIST; huy luu ly do/trang thai |
| F14-01 | 6 vai tro | Mo Dashboard tung vai tro | So lieu lay PostgreSQL, co `asOf/scope/trend/errors`; khong hien so mau |
| F14-02 | PH | Chuyen lan luot giua cac con | Dashboard thay dung con; child ngoai lien ket bi `403` |
| F15-01 | Admin/PH | Loc bao cao va export CSV/XLSX/PDF | Tep dung dinh dang, bo loc va pham vi; Parent chi export du lieu con |
| F16-01 | Admin/Ke toan | Tao dot thu DRAFT, chon nam hoc/pham vi, them khoan thu/mien giam, preview | Nguoi nhan va tong tien tinh dung; scope rong/khong co HS duoc canh bao |
| F16-02 | Admin/Ke toan | Mo dot thu, sinh hoa don hai lan, sau do dong dot thu | Trang thai DRAFT -> OPEN -> CLOSED; moi HS chi co mot hoa don |
| F17-01 | PH/Ke toan | PH tao VietQR, bao da chuyen; Ke toan doi soat | Giao dich PENDING -> SUCCESS; hoa don va bien nhan cap nhat dung |
| F17-02 | Ke toan | Thu tien mat mot phan/du, sau do hoan mot phan/toan bo | So da thu/da hoan/con lai va state chuyen dung |
| F17-03 | He thong | Gui lai callback/doi soat cung ma giao dich | Khong cong tien, tang version hoac tao bien nhan lan hai |
| F18-01 | Tich hop | Chay chuoi Assignment -> Chat -> CLB -> Hoa don -> Bao cao | ID va trang thai lien ket khop giua cac module; khong can sua DB thu cong |
| F18-02 | Giao vu/GV/HS/PH | Cham thi, khoa/cong bo, HS phuc khao, GV xu ly, Giao vu xac nhan | Diem moi, adjustment, notification va trang thai CONFIRMED dong bo dung |
| S01-01 | Ke toan/PH | Chay `UNPAID -> PARTIAL -> PAID -> PARTIALLY_REFUNDED -> REFUNDED` | Moi buoc dung so tien va lich su; thu/hoan sai state bi `409` |
| S01-02 | Ke toan | Huy hoa don hop le, sau do thu tien | State `CANCELLED`; thao tac thu bi chan `409` |

## 6. Ket qua tu dong can chay truoc khi ban giao

| Hang muc | Lenh/kiem tra | Dieu kien dat |
|---|---|---|
| Backend | `mvn clean test` | Tat ca test dat, khong co failure/error |
| Migration | Nang schema V56 len V64 voi role Giao vu va Ke toan ton tai | Hai tai khoan va role duoc giu nguyen |
| Mobile lint | `flutter analyze` | `No issues found` |
| Mobile unit/widget | `flutter test` | Tat ca test thuong dat; live test chi skip khi chua bat bien moi truong |
| Mobile live roles | Chay `live_backend_roles_test.dart` voi 6 mat khau | 6 dang nhap/API va cac UI E2E dat |
| Build | `flutter build web` | Build release thanh cong |
| Docker | Healthcheck Backend/PostgreSQL | Ca hai `healthy`, Flyway o V64 |

## 7. Mau ghi nhan ket qua

| Ma test | Ket qua | Nguoi test | Thoi gian | Du lieu/anh bang chung | Ghi chu loi |
|---|---|---|---|---|---|
| INT-01 |  |  |  |  |  |
| F05-02 |  |  |  |  |  |
| F08-03 |  |  |  |  |  |
| F11-01 |  |  |  |  |  |
| F17-01 |  |  |  |  |  |
| S01-01 |  |  |  |  |  |

Khi ghi bug, can kem: vai tro, tai khoan, URL/man hinh, request/response (neu co), cac buoc tai hien va anh chup. Khong xoa du lieu E2E ngay sau khi test de nguoi sua co the doi chieu.

## 8. Ket qua nghiem thu nhanh truoc ban giao

| Hang muc | Ket qua ngay 13/08/2026 |
|---|---|
| Backend toan bo reactor | PASS - `100/100` test, 9 module build thanh cong |
| Flyway tren PostgreSQL dang demo | PASS - nang tu V54 len V64, giu nguyen du lieu |
| Phan quyen | PASS - du 6 role; Giao vu va Ke toan khong bi doi thanh Admin |
| Dang nhap API that | PASS - `6/6` tai khoan tra dung role va access token |
| Flutter analyze | PASS - `No issues found` |
| Mobile unit/widget | PASS - `71` test dat, `7` live test skip khi chua bat co |
| Mobile live tren Backend Docker | PASS - `7/7` test dat |
| Android native emulator | PASS - `2/2` test, APK build va cai thanh cong |
| Flutter Web release | PASS - tao duoc `build/web` |
| Giao dien Flutter Web | PASS - man Ke toan tai du lieu that, khong co console error |

Luu y khong chan ban giao:

- Flutter canh bao Kotlin Gradle Plugin se can migrate trong mot phien ban Flutter tuong lai; ban hien tai van build Android thanh cong.
- Web build canh bao `flutter_secure_storage_web` chua ho tro WebAssembly; ban JavaScript Web hien tai van build va chay binh thuong.
