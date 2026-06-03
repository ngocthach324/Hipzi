<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.TeacherApplication"%>
<%@page import="com.hipzi.model.User"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String valueOr(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private String initialsFor(String name) {
        String safeName = valueOr(name, "HIPZI");
        String[] parts = safeName.trim().split("\\s+");
        String first = parts.length > 0 ? parts[0].substring(0, 1) : "H";
        String last = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
        return (first + last).toUpperCase();
    }

    private String teacherTypeLabel(String teacherType) {
        if ("student_tutor".equals(teacherType)) return "Gia sư sinh viên";
        if ("certified_pedagogy".equals(teacherType)) return "Giảng viên có chứng chỉ sư phạm";
        if ("degree_specialist".equals(teacherType)) return "Giảng viên chuyên môn có bằng cấp";
        return "Giảng viên HIPZI";
    }

    private String studyYearLabel(String studyYear) {
        if ("year_1".equals(studyYear)) return "Năm 1";
        if ("year_2".equals(studyYear)) return "Năm 2";
        if ("year_3".equals(studyYear)) return "Năm 3";
        if ("year_4".equals(studyYear)) return "Năm 4";
        if ("year_5_plus".equals(studyYear)) return "Năm 5 trở lên";
        if ("graduated".equals(studyYear)) return "Đã tốt nghiệp";
        return "Không áp dụng";
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    String initials = "H";
    if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().trim().split("\\s+");
        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
    }

    TeacherApplication teacher = (TeacherApplication) request.getAttribute("teacher");
    List<Classroom> teacherClassrooms = (List<Classroom>) request.getAttribute("teacherClassrooms");
    String name = teacher != null ? valueOr(teacher.getApplicantName(), "Giảng viên HIPZI") : "Không tìm thấy giảng viên";
    String[] subjectParts = teacher != null ? valueOr(teacher.getTeachingSubjects(), "Đang cập nhật").split("\\s*,\\s*") : new String[0];
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= h(name) %> - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/materials.css">
    <style>
        body {
            background: #f6fbf8;
        }

        .teacher-detail-shell {
            padding-top: 5rem;
        }

        .teacher-detail-container {
            max-width: 1180px;
            margin: 0 auto;
            padding: 0 1rem;
        }

        .teacher-detail-hero {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 340px;
            gap: 1.5rem;
            align-items: stretch;
            padding: 2rem 0;
        }

        .teacher-hero-panel,
        .teacher-side-panel,
        .teacher-section {
            background: #ffffff;
            border: 1px solid #dbeafe;
            border-radius: 8px;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.08);
        }

        .teacher-hero-panel {
            padding: 1.5rem;
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 1.25rem;
            min-width: 0;
        }

        .teacher-photo {
            width: 132px;
            height: 132px;
            border-radius: 24px;
            background: linear-gradient(135deg, #0ea5e9, #22c55e);
            color: #ffffff;
            display: grid;
            place-items: center;
            font-size: 2.35rem;
            font-weight: 950;
            overflow: hidden;
            box-shadow: 0 18px 38px rgba(14, 165, 233, 0.24);
        }

        .teacher-photo img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .teacher-hero-content {
            min-width: 0;
        }

        .teacher-status-row {
            display: flex;
            gap: 0.55rem;
            flex-wrap: wrap;
            margin-bottom: 0.75rem;
        }

        .teacher-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            border-radius: 999px;
            padding: 0.35rem 0.75rem;
            background: #ecfdf5;
            color: #047857;
            font-size: 0.78rem;
            font-weight: 850;
        }

        .teacher-pill.info {
            background: #e0f2fe;
            color: #0369a1;
        }

        .teacher-detail-title {
            margin: 0;
            color: #0f172a;
            font-size: 2.25rem;
            line-height: 1.1;
            overflow-wrap: anywhere;
        }

        .teacher-detail-subtitle {
            margin: 0.65rem 0 1rem 0;
            color: #475569;
            font-weight: 700;
        }

        .teacher-bio {
            color: #334155;
            line-height: 1.75;
            margin: 0;
            white-space: pre-line;
        }

        .teacher-side-panel {
            padding: 1.25rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .teacher-side-title {
            margin: 0;
            color: #0f172a;
            font-size: 1.05rem;
        }

        .teacher-side-grid {
            display: grid;
            gap: 0.7rem;
        }

        .teacher-side-item {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 0.8rem;
            background: #f8fafc;
        }

        .teacher-side-item span,
        .teacher-section-kicker {
            display: block;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 850;
            text-transform: uppercase;
        }

        .teacher-side-item strong {
            display: block;
            margin-top: 0.2rem;
            color: #0f172a;
            overflow-wrap: anywhere;
        }

        .teacher-detail-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 340px;
            gap: 1.5rem;
            padding-bottom: 3rem;
        }

        .teacher-section {
            padding: 1.35rem;
            margin-bottom: 1.5rem;
        }

        .teacher-section h2 {
            margin: 0.25rem 0 1rem 0;
            color: #0f172a;
            font-size: 1.35rem;
        }

        .subject-chip-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.55rem;
        }

        .subject-chip-row a,
        .subject-chip-row span {
            border-radius: 999px;
            background: #e0f2fe;
            color: #0369a1;
            padding: 0.45rem 0.75rem;
            text-decoration: none;
            font-weight: 850;
            font-size: 0.88rem;
        }

        .detail-copy {
            margin: 0;
            color: #334155;
            line-height: 1.75;
            white-space: pre-line;
        }

        .classroom-mini-list {
            display: grid;
            gap: 0.8rem;
        }

        .classroom-mini-card {
            display: grid;
            gap: 0.55rem;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 1rem;
            background: #ffffff;
            text-decoration: none;
            color: inherit;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .classroom-mini-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(15, 23, 42, 0.08);
        }

        .classroom-mini-card strong {
            color: #0f172a;
            font-size: 1rem;
        }

        .classroom-mini-card span {
            color: #64748b;
            font-size: 0.9rem;
        }

        .teacher-empty {
            min-height: 62vh;
            display: grid;
            place-items: center;
            text-align: center;
            padding: 2rem 1rem;
        }

        .teacher-empty-card {
            max-width: 520px;
            background: #ffffff;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            padding: 2rem;
        }

        @media (max-width: 900px) {
            .teacher-detail-hero,
            .teacher-detail-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 640px) {
            .teacher-hero-panel {
                grid-template-columns: 1fr;
            }

            .teacher-photo {
                width: 104px;
                height: 104px;
                font-size: 1.8rem;
            }

            .teacher-detail-title {
                font-size: 1.75rem;
            }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
</head>
<body>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/index">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>

                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
            </ul>

            <% if (user != null) { %>
                <div class="navbar-user-controls">
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                    <div class="nav-avatar-dropdown">
                        <div class="nav-avatar-frame" title="<%= h(profileMenuLabel) %>">
                            <% if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                <img src="<%= h(user.getAvatarUrl()) %>" alt="Avatar">
                            <% } else { %>
                                <span class="nav-avatar-initials"><%= h(initials) %></span>
                            <% } %>
                        </div>
                        <div class="dropdown-menu-popup">
                            <a href="${pageContext.request.contextPath}/profile">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
                                <span><%= h(profileMenuLabel) %></span>
                            </a>
                            <div style="height:1px; background:var(--border-dark); margin:0.35rem 0;"></div>
                            <a href="${pageContext.request.contextPath}/logout" class="danger-link">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                                <span>Đăng xuất</span>
                            </a>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="nav-actions">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Bắt đầu</a>
                </div>
            <% } %>
        </div>
    </header>

    <% if (teacher == null) { %>
        <main class="teacher-detail-shell teacher-empty">
            <div class="teacher-empty-card">
                <h1>Không tìm thấy hồ sơ giảng viên</h1>
                <p>Hồ sơ này có thể chưa được phê duyệt hoặc đã ngừng hiển thị.</p>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/teachers">Quay lại danh sách</a>
            </div>
        </main>
    <% } else { %>
        <main class="teacher-detail-shell">
            <div class="teacher-detail-container">
                <section class="teacher-detail-hero">
                    <div class="teacher-hero-panel">
                        <div class="teacher-photo">
                            <% if (teacher.getApplicantAvatarUrl() != null && !teacher.getApplicantAvatarUrl().trim().isEmpty()) { %>
                                <img src="<%= h(teacher.getApplicantAvatarUrl()) %>" alt="<%= h(name) %>">
                            <% } else { %>
                                <%= h(initialsFor(name)) %>
                            <% } %>
                        </div>
                        <div class="teacher-hero-content">
                            <div class="teacher-status-row">
                                <span class="teacher-pill">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M20 6 9 17l-5-5"/></svg>
                                    Hồ sơ đã phê duyệt
                                </span>
                                <span class="teacher-pill info"><%= h(teacherTypeLabel(teacher.getTeacherType())) %></span>
                            </div>
                            <h1 class="teacher-detail-title"><%= h(name) %></h1>
                            <p class="teacher-detail-subtitle"><%= h(valueOr(teacher.getSpecialization(), "Chuyên môn đang cập nhật")) %> · <%= h(valueOr(teacher.getInstitutionName(), valueOr(teacher.getWorkplace(), "HIPZI"))) %></p>
                            <p class="teacher-bio"><%= h(valueOr(teacher.getTeacherBio(), "Giảng viên đang cập nhật phần giới thiệu cá nhân.")) %></p>
                        </div>
                    </div>

                    <aside class="teacher-side-panel">
                        <h2 class="teacher-side-title">Tổng quan hồ sơ</h2>
                        <div class="teacher-side-grid">
                            <div class="teacher-side-item">
                                <span>Ngày duyệt/cập nhật</span>
                                <strong><%= teacher.getUpdatedAt() != null ? h(dateFormat.format(teacher.getUpdatedAt())) : "Đang cập nhật" %></strong>
                            </div>
                            <div class="teacher-side-item">
                                <span>Môn có thể dạy</span>
                                <strong><%= h(valueOr(teacher.getTeachingSubjects(), "Đang cập nhật")) %></strong>
                            </div>
                            <div class="teacher-side-item">
                                <span>Lớp đang mở</span>
                                <strong><%= teacherClassrooms == null ? 0 : teacherClassrooms.size() %> lớp</strong>
                            </div>
                        </div>
                        <a class="btn btn-primary btn-full" href="#teacher-classes" style="background:#0ea5e9;border-color:#0ea5e9;color:#fff;">Xem lớp của giảng viên</a>
                        <a class="btn btn-ghost btn-full" href="${pageContext.request.contextPath}/teachers">Quay lại danh sách</a>
                    </aside>
                </section>

                <section class="teacher-detail-grid">
                    <div>
                        <section class="teacher-section">
                            <span class="teacher-section-kicker">Môn học</span>
                            <h2>Các môn giảng viên có thể dạy</h2>
                            <div class="subject-chip-row">
                                <% for (String subject : subjectParts) { %>
                                    <a href="${pageContext.request.contextPath}/teachers?subject=<%= java.net.URLEncoder.encode(valueOr(subject, ""), java.nio.charset.StandardCharsets.UTF_8) %>"><%= h(valueOr(subject, "Đang cập nhật")) %></a>
                                <% } %>
                            </div>
                        </section>

                        <section class="teacher-section">
                            <span class="teacher-section-kicker">Kinh nghiệm</span>
                            <h2>Kinh nghiệm giảng dạy</h2>
                            <p class="detail-copy"><%= h(valueOr(teacher.getTeachingExperience(), "Giảng viên chưa bổ sung phần kinh nghiệm giảng dạy.")) %></p>
                        </section>

                        <section class="teacher-section">
                            <span class="teacher-section-kicker">Năng lực</span>
                            <h2>Thành tích, chứng chỉ và bằng cấp</h2>
                            <p class="detail-copy"><%= h(valueOr(teacher.getCredentialsSummary(), "Thông tin chứng chỉ/bằng cấp đang được cập nhật.")) %></p>
                        </section>

                        <section id="teacher-classes" class="teacher-section">
                            <span class="teacher-section-kicker">Lớp học</span>
                            <h2>Lớp công khai của giảng viên</h2>
                            <% if (teacherClassrooms == null || teacherClassrooms.isEmpty()) { %>
                                <p class="detail-copy">Giảng viên chưa có lớp đang mở hoặc sắp khai giảng.</p>
                            <% } else { %>
                                <div class="classroom-mini-list">
                                    <% for (Classroom classroom : teacherClassrooms) { %>
                                        <a class="classroom-mini-card" href="${pageContext.request.contextPath}/class-detail?id=<%= h(classroom.getId()) %>">
                                            <strong><%= h(classroom.getTitle()) %></strong>
                                            <span><%= h(classroom.getSubject()) %> · <%= h(valueOr(classroom.getGrade(), "Tất cả khối")) %> · <%= h(classroom.getStatusLabel()) %></span>
                                            <span><%= h(valueOr(classroom.getSchedule(), "Lịch học đang cập nhật")) %></span>
                                        </a>
                                    <% } %>
                                </div>
                            <% } %>
                        </section>
                    </div>

                    <aside>
                        <section class="teacher-section">
                            <span class="teacher-section-kicker">Học vấn/công tác</span>
                            <h2>Thông tin nền tảng</h2>
                            <p class="detail-copy"><strong>Đơn vị:</strong> <%= h(valueOr(teacher.getInstitutionName(), "Đang cập nhật")) %></p>
                            <p class="detail-copy"><strong>Năm học:</strong> <%= h(studyYearLabel(teacher.getCurrentStudyYear())) %></p>
                            <p class="detail-copy"><strong>Nơi công tác:</strong> <%= h(valueOr(teacher.getWorkplace(), "Đang cập nhật")) %></p>
                        </section>

                        <section class="teacher-section">
                            <span class="teacher-section-kicker">Xác minh</span>
                            <h2>Cam kết chất lượng</h2>
                            <p class="detail-copy">Hồ sơ này đã qua bước phê duyệt của HIPZI trước khi hiển thị công khai cho học viên và phụ huynh.</p>
                        </section>
                    </aside>
                </section>
            </div>
        </main>
    <% } %>

    <footer class="footer">
        <div class="footer-card">
            <div class="footer-bottom-bar">
                <div class="footer-copyright">&copy; 2026 HIPZI Platform. Bản quyền được bảo hộ.</div>
                <div class="footer-legal-links">
                    <a href="${pageContext.request.contextPath}/teachers">Tìm giảng viên</a>
                    <a href="${pageContext.request.contextPath}/classes">Lớp học</a>
                    <a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a>
                </div>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>