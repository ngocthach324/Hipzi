# HipZi Course And Google Drive Tasks

## Da hoan thanh trong phien nay

### Course foundation
- Tao migration `database/15-courses.sql` cho he thong khoa hoc.
- Them cac bang nen:
  - `courses`
  - `course_modules`
  - `course_lessons`
  - `course_enrollments`
  - `course_access_grants`
- Thiet ke schema co san lien ket voi wallet qua `purchase_transaction_id`.
- Them soft delete cho course bang `deleted_at`, `deleted_by`, `delete_reason`.
- Them cac field dac thu cho card course:
  - title, subject, teacher, price, thumbnail/logo, badge, lessons count, students count, rating, progress.
- Them field Google Drive metadata:
  - `google_drive_url`
  - `google_drive_file_id`
  - `google_drive_folder_id`
  - `drive_owner_email`
  - `access_instructions`
  - `require_drive_grant`

### Backend course
- Them `Course.java`.
- Them `CourseDao.java`.
- Cap nhat `CourseServlet.java` de lay course that tu database thay vi chi forward static JSP.
- Cap nhat `ProfileServlet.java`:
  - Teacher co the dang khoa hoc.
  - Staff co the duyet khoa hoc.
  - Staff co the soft delete khoa hoc.
  - Course chi hien public khi `status = approved`, `visibility = public`, `deleted_at IS NULL`.

### UI course
- Cap nhat `teacher-profile.jsp`:
  - Them tab dang khoa hoc.
  - Them danh sach khoa hoc teacher da gui.
  - Them form tao khoa hoc.
  - Cho upload logo/thumbnail khoa hoc.
- Cap nhat `staff-profile.jsp`:
  - Them tab quan ly khoa hoc.
  - Staff co the approve, reject, needs revision.
  - Staff co the soft delete khoa hoc.
- Cap nhat `courses.jsp`:
  - Da render course tu database.
  - Da tat fake sample data khi database chua co course that.
  - Khi khong co course that thi hien empty state.

### Session/logout investigation
- Kiem tra nguyen nhan bi logout sau 1-3 phut.
- Xac dinh session timeout Tomcat la 30 phut, khong phai 1-3 phut.
- Xac dinh nguyen nhan chinh la Tomcat/NetBeans redeploy/reload context `/HipZi`, lam mat session in-memory.
- Them `/courses` vao public page trong `RememberMeFilter` de trang danh sach khoa hoc khong bi day ve login khi mat session.

### Google Drive OAuth foundation
- Them migration `database/16-teacher-google-drive.sql`.
- Them bang `teacher_google_accounts` de luu ket noi Google Drive cua teacher.
- Them `TeacherGoogleAccount.java`.
- Them `TeacherGoogleAccountDao.java`.
- Them `TokenCrypto.java` de ma hoa token bang AES-GCM.
- Them `GoogleDriveOAuthService.java`:
  - Exchange OAuth code lay access token/refresh token.
  - Lay Google profile.
  - Refresh access token.
  - Kiem tra file/folder Drive co the share.
- Them `TeacherDriveOAuthServlet.java`:
  - `/teacher-drive/connect`
  - `/teacher-drive/callback`
  - `/teacher-drive/disconnect`
- Cap nhat `teacher-profile.jsp`:
  - Hien trang thai ket noi Google Drive.
  - Co nut connect/disconnect Google Drive.
  - Chan tao course neu teacher chua connect Drive.
- Cap nhat `ProfileServlet.java`:
  - Khi teacher dang course thi yeu cau da connect Drive.
  - Tu extract file/folder ID tu Google Drive URL.
  - Goi Drive API kiem tra resource co quyen share truoc khi gui staff duyet.
- Them config mau trong `web/META-INF/context.xml`:
  - `GOOGLE_DRIVE_REDIRECT_URI`
  - `HIPZI_TOKEN_ENCRYPTION_KEY`
- Cap nhat `.gitignore` de khong ignore migration `15` va `16`.

### Verification
- Compile Java cac class lien quan da pass bang `javac`.
- Da copy class/JSP/context sang `build/web` de san sang cho lan restart/redeploy tiep theo.

### Cau hinh Google Cloud de test OAuth Drive
- [x] Them redirect URI vao Google Cloud OAuth Client:
  - `http://localhost:8080/HipZi/teacher-drive/callback`
- [x] Dam bao OAuth consent screen co scope:
  - `openid`
  - `email`
  - `profile`
  - `https://www.googleapis.com/auth/drive.file`
- [ ] Dung key rieng cho `HIPZI_TOKEN_ENCRYPTION_KEY` khi len production.

### Google Picker
- [x] Them nut "Chon tu Google Drive" trong form dang khoa hoc.
- [x] Tich hop Google Picker API.
- [x] Khi teacher chon file/folder:
  - Tu dien `courseGoogleDriveUrl`.
  - Tu dien `courseGoogleDriveFileId` hoac `courseGoogleDriveFolderId`.
  - Tu dien ten resource neu can.
- [x] Giam viec nhap tay link/ID de phu hop hon voi scope `drive.file`.

## Viec can lam tiep theo

### 1. Course detail va purchase flow
- [ ] Tao trang chi tiet khoa hoc.
- [ ] Them nut mua/ghi danh khoa hoc.
- [ ] Neu course mien phi:
  - Tao enrollment truc tiep.
- [ ] Neu course co phi:
  - Noi vao wallet/payment flow.
  - Sau thanh toan thanh cong tao `course_enrollments`.

### 2. Grant Drive permission sau khi mua
- [ ] Tao service cap quyen Drive:
  - Lay Google token cua teacher.
  - Lay file/folder ID cua course.
  - Goi Drive API `permissions.create`.
  - Cap `role = reader`, `type = user`, `emailAddress = student.email`.
- [ ] Luu ket qua vao:
  - `course_enrollments.drive_permission_id`
  - `course_enrollments.access_granted_at`
  - `course_access_grants.drive_permission_id`
  - `course_access_grants.status`
  - `course_access_grants.last_error`

### 3. Email thong bao truy cap
- [ ] Them email template thong bao student da duoc cap quyen khoa hoc.
- [ ] Sau khi grant Drive thanh cong:
  - Gui email cho student.
  - Luu `email_sent_at`.
  - Luu `last_access_email_sent_at`.

### 4. Retry, revoke, refund
- [ ] Them queue/list cac access grant failed cho staff hoac teacher retry.
- [ ] Khi refund hoac revoke course:
  - Goi Drive API xoa permission bang `drive_permission_id`.
  - Update enrollment thanh `refunded` hoac `revoked`.
  - Update access grant thanh `revoked`.

### 5. Security hardening
- [ ] Khong luu secret/key production trong repo.
- [ ] Chuyen Google client secret va token encryption key sang environment variables.
- [ ] Xem lai quyen staff/teacher cho cac endpoint moi.
- Them CSRF protection cho action disconnect/review/delete neu project bat dau co middleware bao mat.

### 8. Testing
- Test teacher connect Google Drive.
- Test teacher dang course bang Drive URL hop le.
- Test course bi tu choi neu Drive resource khong share duoc.
- Test staff approve course.
- Test `/courses` chi hien approved public course that.
- Test flow mua course sau khi wallet duoc implement.
