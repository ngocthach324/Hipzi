<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.util.List"%>
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
        if ("certified_pedagogy".equals(teacherType)) return "Có chứng chỉ sư phạm";
        if ("degree_specialist".equals(teacherType)) return "Chuyên gia có bằng cấp";
        return "Giảng viên HIPZI";
    }

    private String subjectLabel(String subject) {
        if ("Tất cả".equals(subject)) return "Tất cả môn học";
        return subject;
    }

    private String enc(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private String teacherFilterUrl(String contextPath, String subject, String teacherType, String searchQuery) {
        StringBuilder url = new StringBuilder(contextPath).append("/teachers?subject=").append(enc(subject));
        if (teacherType != null && !teacherType.trim().isEmpty()) {
            url.append("&teacherType=").append(enc(teacherType));
        }
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            url.append("&q=").append(enc(searchQuery));
        }
        return url.toString();
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    String initials = "H";
    if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().trim().split("\\s+");
        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
    }
    List<TeacherApplication> teachers = (List<TeacherApplication>) request.getAttribute("teachers");
    String searchQuery = valueOr((String) request.getAttribute("searchQuery"), "");
    String currentSubject = valueOr((String) request.getAttribute("currentSubject"), "Tất cả");
    String currentTeacherType = valueOr((String) request.getAttribute("currentTeacherType"), "ALL");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tìm giảng viên - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/materials.css">
    <style>
        .teacher-market .repo-header {
            background:
                radial-gradient(circle at 12% 18%, rgba(14, 165, 233, 0.14), transparent 28%),
                radial-gradient(circle at 88% 12%, rgba(34, 197, 94, 0.16), transparent 26%),
                var(--bg);
        }

        .teacher-market .repo-header p {
            max-width: 720px;
        }

        .teacher-market .main-results {
            min-height: auto;
        }

        .teacher-market .filter-card {
            border-radius: 8px;
        }

        .teacher-market .teacher-sidebar a.active {
            background-color: var(--color-info, #0ea5e9);
            color: #ffffff;
            font-weight: 700;
            box-shadow: 0 8px 18px rgba(14, 165, 233, 0.22);
        }

        .teacher-card {
            border-radius: 8px;
            overflow: hidden;
            gap: 1rem;
            min-height: 360px;
        }

        .teacher-card-top {
            display: flex;
            align-items: flex-start;
            gap: 0.9rem;
        }

        .teacher-avatar {
            width: 72px;
            height: 72px;
            flex: 0 0 72px;
            border-radius: 18px;
            background: linear-gradient(135deg, #0ea5e9, #22c55e);
            color: #ffffff;
            display: grid;
            place-items: center;
            font-size: 1.35rem;
            font-weight: 900;
            overflow: hidden;
            box-shadow: 0 14px 28px rgba(14, 165, 233, 0.2);
        }

        .teacher-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .teacher-card h3 {
            margin: 0 0 0.4rem 0;
            line-height: 1.25;
        }

        .teacher-verified {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.25rem 0.6rem;
            border-radius: 999px;
            background: #ecfdf5;
            color: #047857;
            font-size: 0.78rem;
            font-weight: 800;
        }

        .teacher-summary {
            color: #475569;
            font-size: 0.92rem;
            line-height: 1.55;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .teacher-meta-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.7rem;
        }

        .teacher-meta-item {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 0.7rem;
            background: #f8fafc;
            min-width: 0;
        }

        .teacher-meta-item span,
        .teacher-subjects span {
            display: block;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 800;
            text-transform: uppercase;
        }

        .teacher-meta-item strong {
            display: block;
            margin-top: 0.18rem;
            color: #0f172a;
            font-size: 0.92rem;
            overflow-wrap: anywhere;
        }

        .teacher-subjects {
            border-top: 1px solid #e2e8f0;
            padding-top: 1rem;
        }

        .teacher-subject-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.45rem;
            margin-top: 0.55rem;
        }

        .teacher-subject-tags b {
            border-radius: 999px;
            background: #e0f2fe;
            color: #0369a1;
            padding: 0.35rem 0.65rem;
            font-size: 0.78rem;
        }

        .teacher-count-pill {
            color: #64748b;
            font-weight: 700;
        }

        @media (max-width: 640px) {
            .teacher-card-top,
            .results-header {
                align-items: flex-start;
            }

            .teacher-meta-grid {
                grid-template-columns: 1fr;
            }

            .search-input-wrapper {
                align-items: stretch;
                border-radius: 24px;
                flex-direction: column;
                padding: 1rem;
            }

            .search-icon {
                display: none;
            }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
</head>
<body class="teacher-market">

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">

                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>


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

    <section class="repo-header">
        <div class="repo-container">
            <h1>Tìm giảng viên phù hợp</h1>
            <p>Các hồ sơ bên dưới được lấy trực tiếp từ danh sách giảng viên đã đăng ký và được HIPZI phê duyệt.</p>

            <div class="search-bar">
                <form action="${pageContext.request.contextPath}/teachers" method="GET">
                    <input type="hidden" name="subject" value="<%= h(currentSubject) %>">
                    <input type="hidden" name="teacherType" value="<%= h(currentTeacherType) %>">
                    <div class="search-input-wrapper">
                        <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                        <input type="text" name="q" placeholder="Tìm theo tên, môn học, chuyên môn, trường..." class="search-input" value="<%= h(searchQuery) %>">
                        <button type="submit" class="btn btn-primary search-btn" style="background: var(--color-info, #0ea5e9);">Tìm kiếm</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <section id="content-area" class="repo-content">
        <div class="repo-container layout-grid">
            <aside class="sidebar-filters">
                <div class="filter-card">
                    <h3>Môn học</h3>
                    <ul class="subject-list teacher-sidebar">
                        <%
                            String[] subjects = {"Tất cả", "Toán", "Văn", "Anh", "Lý", "Hóa", "Sinh Học", "Lịch Sử", "Địa Lý", "Công Nghệ", "Tin Học"};
                            for (String subject : subjects) {
                        %>
                            <li>
                                <a href="<%= h(teacherFilterUrl(request.getContextPath(), subject, currentTeacherType, searchQuery)) %>"
                                   class="<%= subject.equalsIgnoreCase(currentSubject) ? "active" : "" %>"><%= h(subjectLabel(subject)) %></a>
                            </li>
                        <% } %>
                    </ul>
                </div>

                <div class="filter-card" style="margin-top: 1.5rem;">
                    <h3>Loại hồ sơ</h3>
                    <ul class="subject-list teacher-sidebar">
                        <li><a href="<%= h(teacherFilterUrl(request.getContextPath(), currentSubject, "ALL", searchQuery)) %>" class="<%= "ALL".equals(currentTeacherType) ? "active" : "" %>">Tất cả giảng viên</a></li>
                        <li><a href="<%= h(teacherFilterUrl(request.getContextPath(), currentSubject, "student_tutor", searchQuery)) %>" class="<%= "student_tutor".equals(currentTeacherType) ? "active" : "" %>">Gia sư sinh viên</a></li>
                        <li><a href="<%= h(teacherFilterUrl(request.getContextPath(), currentSubject, "certified_pedagogy", searchQuery)) %>" class="<%= "certified_pedagogy".equals(currentTeacherType) ? "active" : "" %>">Chứng chỉ sư phạm</a></li>
                        <li><a href="<%= h(teacherFilterUrl(request.getContextPath(), currentSubject, "degree_specialist", searchQuery)) %>" class="<%= "degree_specialist".equals(currentTeacherType) ? "active" : "" %>">Chuyên gia bằng cấp</a></li>
                    </ul>
                </div>
            </aside>

            <main class="main-results" id="materials-results">
                <div class="results-header">
                    <div>
                        <h2>Giảng viên <%= "Tất cả".equalsIgnoreCase(currentSubject) ? "đã xác minh" : h(currentSubject) %></h2>
                        <p class="teacher-count-pill"><%= teachers == null ? 0 : teachers.size() %> hồ sơ phù hợp</p>
                    </div>
                    <a class="btn btn-ghost" href="${pageContext.request.contextPath}/teachers">Xóa lọc</a>
                </div>

                <div class="material-grid">
                    <% if (teachers == null || teachers.isEmpty()) { %>
                        <div class="empty-state">
                            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 15h8"/><path d="M9 9h.01"/><path d="M15 9h.01"/></svg>
                            <h3>Chưa có hồ sơ giảng viên phù hợp</h3>
                            <p>Hãy thử bỏ bớt bộ lọc hoặc tìm bằng môn học/chuyên môn khác.</p>
                        </div>
                    <% } else {
                        for (TeacherApplication teacher : teachers) {
                            String name = valueOr(teacher.getApplicantName(), "Giảng viên HIPZI");
                            String[] subjectParts = valueOr(teacher.getTeachingSubjects(), "Đang cập nhật").split("\\s*,\\s*");
                    %>
                        <article class="material-card teacher-card">
                            <div class="teacher-card-top">
                                <div class="teacher-avatar">
                                    <% if (teacher.getApplicantAvatarUrl() != null && !teacher.getApplicantAvatarUrl().trim().isEmpty()) { %>
                                        <img src="<%= h(teacher.getApplicantAvatarUrl()) %>" alt="<%= h(name) %>">
                                    <% } else { %>
                                        <%= h(initialsFor(name)) %>
                                    <% } %>
                                </div>
                                <div>
                                    <h3 class="material-title"><%= h(name) %></h3>
                                    <span class="teacher-verified">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M20 6 9 17l-5-5"/></svg>
                                        Đã xác minh
                                    </span>
                                </div>
                            </div>

                            <p class="teacher-summary"><%= h(valueOr(teacher.getTeacherBio(), "Giảng viên đang cập nhật phần giới thiệu cá nhân.")) %></p>

                            <div class="teacher-meta-grid">
                                <div class="teacher-meta-item">
                                    <span>Chuyên môn</span>
                                    <strong><%= h(valueOr(teacher.getSpecialization(), "Đang cập nhật")) %></strong>
                                </div>
                                <div class="teacher-meta-item">
                                    <span>Loại hồ sơ</span>
                                    <strong><%= h(teacherTypeLabel(teacher.getTeacherType())) %></strong>
                                </div>
                                <div class="teacher-meta-item">
                                    <span>Đơn vị</span>
                                    <strong><%= h(valueOr(teacher.getInstitutionName(), valueOr(teacher.getWorkplace(), "Đang cập nhật"))) %></strong>
                                </div>
                                <div class="teacher-meta-item">
                                    <span>Kinh nghiệm</span>
                                    <strong><%= h(valueOr(teacher.getTeachingExperience(), "Đang cập nhật")) %></strong>
                                </div>
                            </div>

                            <div class="teacher-subjects">
                                <span>Môn có thể dạy</span>
                                <div class="teacher-subject-tags">
                                    <% for (String subject : subjectParts) { %>
                                        <b><%= h(valueOr(subject, "Đang cập nhật")) %></b>
                                    <% } %>
                                </div>
                            </div>

                            <div class="material-card-footer">
                                <a href="${pageContext.request.contextPath}/teachers/detail?id=<%= h(teacher.getId()) %>" class="btn btn-primary btn-full" style="background: var(--color-info, #0ea5e9); border-color: var(--color-info, #0ea5e9); color: #ffffff;">Xem hồ sơ</a>
                            </div>
                        </article>
                    <% }
                    } %>
                </div>
            </main>
        </div>
    </section>

    <footer class="footer">
        <div class="footer-card">
            <div class="footer-bottom-bar">
                <div class="footer-copyright">&copy; 2026 HIPZI Platform. Bản quyền được bảo hộ.</div>
                <div class="footer-legal-links">
                    <a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a>
                    <a href="${pageContext.request.contextPath}/classes">Lớp học</a>
                    <a href="${pageContext.request.contextPath}/register">Đăng ký giảng dạy</a>
                </div>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
