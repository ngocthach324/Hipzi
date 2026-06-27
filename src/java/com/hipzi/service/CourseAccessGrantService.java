package com.hipzi.service;

import com.hipzi.dao.CourseAccessGrantDao;
import com.hipzi.model.CourseAccessGrantJob;

import java.util.List;
import jakarta.servlet.ServletContext;

public class CourseAccessGrantService {
    private final CourseAccessGrantDao grantDao = new CourseAccessGrantDao();
    private final GoogleDriveOAuthService driveOAuthService = new GoogleDriveOAuthService();

    public void processOrderAccessGrants(String orderCode, ServletContext servletContext) {
        List<CourseAccessGrantJob> jobs = grantDao.listGrantableByOrderCode(orderCode);
        if (jobs == null || jobs.isEmpty()) {
            return;
        }

        String clientId = config(servletContext, "GOOGLE_CLIENT_ID");
        String clientSecret = config(servletContext, "GOOGLE_CLIENT_SECRET");
        String encryptionKey = tokenEncryptionKey(servletContext);

        for (CourseAccessGrantJob job : jobs) {
            processOne(job, clientId, clientSecret, encryptionKey);
        }
    }

    private void processOne(CourseAccessGrantJob job, String clientId, String clientSecret, String encryptionKey) {
        try {
            if (!job.isRequireDriveGrant()) {
                grantDao.markGranted(job, null);
                return;
            }
            String driveResourceId = job.getDriveResourceId();
            if (isBlank(driveResourceId)) {
                throw new IllegalStateException("Khoa hoc chua luu Google Drive file/folder id.");
            }
            if (isBlank(job.getStudentEmail())) {
                throw new IllegalStateException("Hoc vien chua co email de cap quyen.");
            }
            if (isBlank(clientId) || isBlank(clientSecret) || isBlank(encryptionKey)) {
                throw new IllegalStateException("Google Drive OAuth chua duoc cau hinh tren server.");
            }
            if (isBlank(job.getTeacherGoogleScope()) || !job.getTeacherGoogleScope().contains("https://www.googleapis.com/auth/drive")) {
                throw new IllegalStateException("Giang vien can ket noi lai Google Drive de cap quyen full Drive cho khoa hoc.");
            }

            String accessToken = driveOAuthService.accessTokenForTeacher(
                    job.getTeacherId(),
                    clientId,
                    clientSecret,
                    encryptionKey
            );
            String permissionId = driveOAuthService.createReaderPermission(
                    accessToken,
                    driveResourceId,
                    job.getStudentEmail()
            );
            grantDao.markGranted(job, permissionId);
        } catch (Exception e) {
            grantDao.markFailed(job, e.getMessage() != null ? e.getMessage() : "Khong cap duoc quyen khoa hoc.");
        }
    }

    private String tokenEncryptionKey(ServletContext servletContext) {
        String value = config(servletContext, "HIPZI_TOKEN_ENCRYPTION_KEY");
        return isBlank(value) ? config(servletContext, "TOKEN_ENCRYPTION_KEY") : value;
    }

    private String config(ServletContext servletContext, String name) {
        String value = null;
        if (servletContext != null) {
            value = servletContext.getInitParameter(name);
            if (isBlank(value)) {
                value = servletContext.getInitParameter(name.toLowerCase().replace('_', '.'));
            }
        }
        if (isBlank(value)) {
            value = System.getProperty(name);
        }
        if (isBlank(value)) {
            value = System.getenv(name);
        }
        return value;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
