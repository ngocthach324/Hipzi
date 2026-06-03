# HIPZI Codebase Feedback

Ngay kiem tra: 2026-06-03

## Ket luan ngan

Codebase da co nen tang chay duoc cho demo noi bo: JSP da duoc chuyen vao `WEB-INF/views`, static assets dang tra dung MIME type, cac route public chinh nhu `/index`, `/login`, `/register` dang load duoc.

Tuy nhien he thong chua nen xem la on dinh/clean cho production. Cac rui ro lon nhat hien nam o phan phan quyen, secret bi hardcode, password security, va thieu test tu dong. Can sua cac muc Critical/High ben duoi truoc khi demo cong khai hoac deploy voi du lieu that.

## Pham vi da ra soat

- Mapping servlet va JSP forward.
- JSP include, asset noi bo, va link route noi bo.
- Static smoke test tren Tomcat dang chay local.
- Cac controller chinh: auth, profile, notification, classroom, material, file download.
- Cac service/DAO lien quan den password, email, storage, database.
- Do sach cua repo: build artifacts, file compiled, test coverage, kich thuoc JSP/controller.

## Ket qua smoke test nhanh

| Endpoint | Ket qua |
| --- | --- |
| `/index` | 200 `text/html;charset=UTF-8` |
| `/login` | 200 `text/html;charset=UTF-8` |
| `/register` | 200 `text/html;charset=UTF-8` |
| `/forgot-password` | 200 `text/html;charset=UTF-8` |
| `/assets/css/landing.css?v=5` | 200 `text/css` |
| `/assets/js/navbar.js?v=2` | 200 `text/javascript` |
| `/assets/images/favicon.png` | 200 `image/png` |
| `/practice` | 302 ve `/HipZi/login` khi chua dang nhap |
| `/exam-room` | 302 ve `/HipZi/login` khi chua dang nhap |

Luu y: `ant` khong co trong PATH nen chua chay duoc full Ant build. Thu muc `test/` hien khong co test code thuc te.

## Critical

### 1. Co the leo quyen khi dang ky tai khoan

`RegisterServlet` luu role tu request vao session ma khong whitelist server-side:

- `src/java/com/hipzi/controller/RegisterServlet.java:66`

Sau khi OTP thanh cong, `VerifyOtpServlet` lay role nay va goi `RoleDao.findRoleByName(...)`:

- `src/java/com/hipzi/controller/VerifyOtpServlet.java:136`
- `src/java/com/hipzi/controller/VerifyOtpServlet.java:152`

Rui ro: client co the tu gui `role=admin` hoac `role=staff` neu DB co role do. `AuthService.register()` co whitelist `student/parent/teacher`, nhung flow dang ky hien tai khong dung method do.

De xuat:

- Chi cho phep `student`, `parent`, `teacher` trong `RegisterServlet` hoac `VerifyOtpServlet`.
- Khong bao gio chap nhan `admin/staff` tu public registration.
- Them test cho request dang ky bi tamper role.

### 2. Profile page khong chan truy cap cheo role o GET

`ProfileServlet` chon JSP dua tren URL path, nhung khong verify user co role phu hop truoc khi load du lieu staff/admin:

- `src/java/com/hipzi/controller/ProfileServlet.java:98`
- `src/java/com/hipzi/controller/ProfileServlet.java:117`
- `src/java/com/hipzi/controller/ProfileServlet.java:134`
- `src/java/com/hipzi/controller/ProfileServlet.java:153`

Rui ro: user dang nhap binh thuong co the goi truc tiep `/admin-profile` hoac `/staff-profile` va servlet van nap du lieu quan tri/duyet ho so neu DB tra ve.

De xuat:

- Tao ham `requireRoleForPath(path, user)` va check truoc khi load data.
- Neu sai role: tra `403` hoac redirect ve profile dung role.
- Them smoke test dang nhap user thuong truy cap `/admin-profile` phai bi chan.

### 3. Hanh dong `banUser` khong co guard admin

Trong `ProfileServlet`, action `banUser` goi thang DAO ma khong check role:

- `src/java/com/hipzi/controller/ProfileServlet.java:262`
- `src/java/com/hipzi/controller/ProfileServlet.java:264`

Rui ro: user dang nhap co the POST action `banUser` neu biet endpoint/form fields.

De xuat:

- Check `hasRole(user, "admin")` truoc khi goi `adminUserDao.banUser(...)`.
- Can nhac chan khong cho ban chinh minh va khong cho ban admin khac neu chua co policy ro.

### 4. Admin notification endpoint khong yeu cau admin role

`AdminNotificationServlet` chi check user ton tai va account active:

- `src/java/com/hipzi/controller/AdminNotificationServlet.java:23`
- `src/java/com/hipzi/controller/AdminNotificationServlet.java:26`
- `src/java/com/hipzi/controller/AdminNotificationServlet.java:41`
- `src/java/com/hipzi/controller/AdminNotificationServlet.java:55`

Rui ro: bat ky user active nao co the POST broadcast hoac gui thong bao toi user khac.

De xuat:

- Check role `admin` truoc moi action.
- Them CSRF token cho form admin.
- Log audit nguoi gui, noi dung, thoi diem.

### 5. Secret that dang bi hardcode trong source

Co credential/API key hardcoded tai:

- `src/java/com/hipzi/util/DBContext.java:11`
- `src/java/com/hipzi/util/DBContext.java:12`
- `src/java/com/hipzi/util/DBContext.java:13`
- `src/java/com/hipzi/util/EmailService.java:26`
- `src/java/com/hipzi/service/B2StorageService.java:25`
- `src/java/com/hipzi/service/B2StorageService.java:26`
- `src/java/com/hipzi/service/SupabaseStorageService.java:27`

Rui ro: lo DB password, email API key, storage key. Neu repo da tung push, can coi cac secret nay da bi lo.

De xuat:

- Rotate tat ca secret lien quan ngay khi co the.
- Doc config tu environment variable hoac Tomcat context config.
- Fallback nen la `REPLACE_ME` va fail closed, khong dung secret that.
- Them `.env.example` chi chua ten bien, khong chua gia tri that.

## High

### 6. Password hashing chua an toan

`PasswordUtil` dung SHA-256 don thuan, khong salt, khong work factor:

- `src/java/com/hipzi/util/PasswordUtil.java:16`

Ham check con chap nhan password plain text bang cach so truc tiep:

- `src/java/com/hipzi/util/PasswordUtil.java:27`

Rui ro: neu DB leak, password de bi brute force. Plain-text fallback lam yeu policy mat khau.

De xuat:

- Chuyen sang BCrypt, PBKDF2, Argon2, hoac scrypt.
- Migration: neu hash cu dung SHA-256, khi user login thanh cong thi rehash sang format moi.
- Bo fallback plain-text sau khi seed/test account da duoc migrate.

### 7. Forgot password gui mat khau moi qua email

Flow reset tao password moi, cap nhat DB, roi gui password do qua email:

- `src/java/com/hipzi/controller/ForgotPasswordServlet.java:50`
- `src/java/com/hipzi/controller/ForgotPasswordServlet.java:51`
- `src/java/com/hipzi/controller/ForgotPasswordServlet.java:55`

Rui ro: email khong nen la kenh truyen mat khau. Neu email bi forward/log/lo, password bi lo.

De xuat:

- Dung reset token mot lan, het han ngan.
- User dat mat khau moi tren form HTTPS.
- Khong gui password plain qua email.

### 8. `/practice` se loi runtime sau khi user dang nhap

`PracticeServlet` forward toi JSP khong ton tai:

- `src/java/com/hipzi/controller/PracticeServlet.java:37`

File thieu: `web/WEB-INF/views/practice.jsp`

Rui ro: user dang nhap vao `/practice` co kha nang gap 500.

De xuat:

- Tao `practice.jsp`, doi servlet forward sang trang dung, hoac redirect ve `/exam-room` neu feature da doi ten.
- Them static check route -> JSP trong build/test.

### 9. Download tai lieu kho chung chua check trang thai/visibility

`RepositoryMaterialFileServlet` chi `findById`, co file path thi tao signed URL:

- `src/java/com/hipzi/controller/RepositoryMaterialFileServlet.java:22`
- `src/java/com/hipzi/controller/RepositoryMaterialFileServlet.java:30`

Rui ro: user da dang nhap va biet `id` co the lay file cua material chua duyet/bi an neu DAO khong loc trong `findById`.

De xuat:

- Check material status la `approved/published` truoc khi tao signed URL.
- Neu teacher/staff/admin co quyen preview ban nhap, tach endpoint/permission ro.

### 10. Thieu CSRF protection cho POST

Nhieu POST thay doi du lieu/hang muc quan tri hien khong co CSRF token, vi du:

- `src/java/com/hipzi/controller/ProfileServlet.java:171`
- `src/java/com/hipzi/controller\AdminNotificationServlet.java:16`
- `src/java/com/hipzi/controller/StudentTrackingServlet.java:18`
- `src/java/com/hipzi/controller/MaterialRepositoryServlet.java:95`

Rui ro: neu user dang nhap, trang ngoai co the kich POST thay doi du lieu.

De xuat:

- Them CSRF token trong session va hidden input cho form.
- Validate token cho moi POST state-changing.
- Cookie remember-me nen can nhac `SameSite=Lax/Strict`.

## Medium

### 11. `StudentTrackingServlet` khong check role parent

Endpoint `/parent/tracking` chi check co dang nhap:

- `src/java/com/hipzi/controller/StudentTrackingServlet.java:28`
- `src/java/com/hipzi/controller/StudentTrackingServlet.java:61`
- `src/java/com/hipzi/controller/StudentTrackingServlet.java:74`

Rui ro: role khac co the tao lien ket parent-student neu biet student code.

De xuat:

- Check user co role `parent`.
- Can nhac workflow xac nhan tu hoc sinh/phu huynh thay vi link truc tiep bang code.

### 12. Public contact/support co nguy co spam va treo request

`ContactServlet` public goi email service truc tiep trong request:

- `src/java/com/hipzi/controller/ContactServlet.java:19`
- `src/java/com/hipzi/controller/ContactServlet.java:42`

`EmailService` dung `HttpURLConnection` nhung chua set connect/read timeout:

- `src/java/com/hipzi/util/EmailService.java:93`

Rui ro: spam email support hoac request bi treo khi provider cham.

De xuat:

- Rate limit theo IP/email/session.
- Them CAPTCHA hoac honeypot cho contact public.
- Set timeout cho HTTP call va can nhac queue async.

### 13. Upload avatar/evidence ghi vao webapp local

`ProfileServlet` ghi file vao path trong webapp:

- `src/java/com/hipzi/controller/ProfileServlet.java:224`
- `src/java/com/hipzi/controller/ProfileServlet.java:583`

Rui ro: file co the mat khi redeploy, scale nhieu server se khong dong bo.

De xuat:

- Dung storage service chung.
- Kiem tra extension/content sniffing ky hon, gioi han loai file va random file name.

### 14. Error handling/logging chua nhat quan

Con nhieu `System.out`, `printStackTrace`, va catch rong/ignored:

- `src/java/com/hipzi/util/DBContext.java:33`
- `src/java/com/hipzi/util/DBContext.java:36`
- `src/java/com/hipzi/controller/LoginServlet.java:108`
- `src/java/com/hipzi/controller/StudentTrackingServlet.java:46`

De xuat:

- Dung SLF4J logger thay cho `System.out`/`printStackTrace`.
- Khong tra exception message raw ra UI o cac path nhay cam.
- Tach audit log cho hanh dong admin/staff.

## Cleanliness / Maintainability

### 15. JSP va servlet qua lon

Line count lon nhat:

| File | Lines |
| --- | ---: |
| `web/WEB-INF/views/student-profile.jsp` | 3352 |
| `web/WEB-INF/views/teacher-profile.jsp` | 3293 |
| `web/WEB-INF/views/staff-profile.jsp` | 3206 |
| `web/WEB-INF/views/admin-profile.jsp` | 3020 |
| `web/WEB-INF/views/classroom.jsp` | 2696 |
| `src/java/com/hipzi/controller/ClassroomSpaceServlet.java` | 1085 |
| `src/java/com/hipzi/controller/ProfileServlet.java` | 643 |

Trong 4 profile JSP lon co khoang 855 lan `<style`, `style=`, `<script`, va inline event handler.

De xuat:

- Tach common profile layout thanh fragments.
- Dua CSS/JS lap lai vao `web/assets/css/dashboard.css` va `web/assets/js/...`.
- Tach `ProfileServlet` theo domain action: account, teacher application, admin users, classes.

### 16. Build artifacts va compiled classes lan vao repo

Dang thay:

- `dist/HipZi.war` bi track/modified.
- `src/java/com/hipzi/service/B2StorageService.class`
- `src/java/com/hipzi/service/SupabaseStorageService.class`
- `tools/RefactorJspTool.class`
- `tools/UploadTool.class`

`.gitignore` hien chua ignore `dist/`, `*.class`, `*.war`.

De xuat:

- Them `dist/`, `*.class`, `*.war` vao `.gitignore`.
- Neu can giu jar dependency vi chua co Maven/Gradle, giu rieng `web/WEB-INF/lib`; khong commit class/war build output.

### 17. Thieu test tu dong thuc te

`test/` hien khong co file test. Tai lieu `docs/12-testing-strategy.md` da co chien luoc, nhung chua co implementation.

De xuat test toi thieu:

- Unit test cho `PasswordUtil` sau khi migrate hash.
- Servlet/integration test cho role guard: `admin-profile`, `staff-profile`, `banUser`, `admin/notification`.
- Static test: moi `getRequestDispatcher("/WEB-INF/...")` phai co file ton tai.
- Smoke test asset: CSS/JS/image phai tra dung MIME type.

## Tinh trang tot hien co

- Sau khi bo mapping `/` khoi `IndexServlet`, static assets da duoc Tomcat default servlet phuc vu dung.
- JSP include noi bo khong bao thieu.
- Asset noi bo duoi `/assets/...` khong bao thieu.
- Link route noi bo co dang `${contextPath}/...` va `request.getContextPath() + ...` khop voi servlet route hien co.
- File download classroom va homework submission da co permission check theo teacher/staff/admin/enrollment.
- Remember-me token duoc tach selector/validator va validator duoc hash trong DB.

## Thu tu sua de xuat

1. Rotate secret va chuyen config sang env/system property.
2. Fix role registration tampering.
3. Them role guard cho `ProfileServlet` GET va POST admin/staff actions.
4. Fix `AdminNotificationServlet` chi admin duoc dung.
5. Them `practice.jsp` hoac doi route `/practice`.
6. Doi password hashing va reset password flow.
7. Them CSRF token cho POST.
8. Them smoke/static tests toi thieu.
9. Tach dan JSP/servlet lon sau khi cac rui ro tren da on.

