<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.ClassroomEnrollment"%>
<%@page import="com.hipzi.model.ClassroomHomeworkSubmission"%>
<%@page import="com.hipzi.model.ClassroomMaterial"%>
<%@page import="com.hipzi.model.User"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }
%>
<%
    Classroom classroom = (Classroom) request.getAttribute("classroom");
    User user = (User) session.getAttribute("loggedUser");
    boolean canManageClassroom = Boolean.TRUE.equals(request.getAttribute("canManageClassroom"));
    boolean canReviewEnrollments = Boolean.TRUE.equals(request.getAttribute("canReviewEnrollments"));
    boolean canSubmitHomework = Boolean.TRUE.equals(request.getAttribute("canSubmitHomework"));
    List<ClassroomEnrollment> pendingEnrollments = (List<ClassroomEnrollment>) request.getAttribute("pendingEnrollments");
    List<ClassroomEnrollment> acceptedEnrollments = (List<ClassroomEnrollment>) request.getAttribute("acceptedEnrollments");
    List<ClassroomMaterial> classMaterials = (List<ClassroomMaterial>) request.getAttribute("classMaterials");
    List<ClassroomMaterial> classHomework = (List<ClassroomMaterial>) request.getAttribute("classHomework");
    List<ClassroomHomeworkSubmission> homeworkSubmissions = (List<ClassroomHomeworkSubmission>) request.getAttribute("homeworkSubmissions");

    String title = classroom != null ? classroom.getTitle() : "Lớp học HIPZI";
    String subject = classroom != null ? classroom.getSubject() : "Môn học";
    String teacherName = classroom != null && classroom.getTeacherName() != null && !classroom.getTeacherName().isEmpty() ? classroom.getTeacherName() : "Giảng viên HIPZI";
    String schedule = classroom != null && classroom.getSchedule() != null ? classroom.getSchedule() : "Lịch học đang cập nhật";
    String statusLabel = classroom != null ? classroom.getStatusLabel() : "Đang mở";
    String onlineRoomHref = "https://meet.google.com/new";
    int pendingCount = pendingEnrollments != null ? pendingEnrollments.size() : 0;
    int acceptedCount = acceptedEnrollments != null ? acceptedEnrollments.size() : 0;
    int materialCount = classMaterials != null ? classMaterials.size() : 0;
    int homeworkCount = classHomework != null ? classHomework.size() : 0;
    String initials = "H";
    if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().trim().split("\\s+");
        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= h(title) %> - Không gian lớp học HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <style>
        body {
            min-height: 100vh;
            background:
                radial-gradient(circle at 12% 10%, rgba(109, 40, 217, 0.12), transparent 28%),
                radial-gradient(circle at 92% 18%, rgba(14, 165, 233, 0.12), transparent 26%),
                #f8fafc;
            color: #0f172a;
        }

        .classroom-shell {
            max-width: 1180px;
            margin: 0 auto;
            padding: 7rem 1.25rem 4rem;
        }

        .classroom-hero {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 1.5rem;
            align-items: end;
            padding: 2rem;
            border-radius: 1.35rem;
            background:
                linear-gradient(135deg, rgba(109, 40, 217, 0.96), rgba(14, 165, 233, 0.86)),
                #6d28d9;
            color: #ffffff;
            box-shadow: 0 24px 60px rgba(79, 70, 229, 0.2);
            overflow: hidden;
            position: relative;
        }

        .classroom-hero::after {
            content: "";
            position: absolute;
            width: 360px;
            height: 360px;
            right: -120px;
            top: -130px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.18);
        }

        .classroom-hero h1 {
            position: relative;
            margin: 0;
            font-size: clamp(2rem, 5vw, 4.2rem);
            line-height: 1;
            letter-spacing: 0;
        }

        .classroom-meta {
            position: relative;
            display: flex;
            flex-wrap: wrap;
            gap: 0.65rem;
            margin-top: 1rem;
        }

        .classroom-pill {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.45rem 0.85rem;
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.28);
            font-weight: 850;
            font-size: 0.88rem;
        }

        .online-room-btn {
            position: relative;
            z-index: 1;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            min-width: 210px;
            border-radius: 999px;
            padding: 0.95rem 1.35rem;
            background: #ffffff;
            color: #6d28d9;
            font-weight: 950;
            text-decoration: none;
            box-shadow: 0 16px 36px rgba(15, 23, 42, 0.2);
        }

        .classroom-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 360px;
            gap: 1.25rem;
            align-items: start;
            margin-top: 1.25rem;
        }

        .classroom-grid.classroom-tabbed {
            display: block;
        }

        .classroom-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.2rem;
            box-shadow: 0 16px 34px rgba(15, 23, 42, 0.05);
        }

        .classroom-card + .classroom-card {
            margin-top: 1.25rem;
        }

        .classroom-card h2 {
            margin: 0 0 0.9rem;
            font-size: 1.2rem;
            color: #0f172a;
        }

        .classroom-tabs-shell {
            margin-top: 1.25rem;
            background: rgba(255, 255, 255, 0.84);
            border: 1px solid #e2e8f0;
            border-radius: 1.1rem;
            box-shadow: 0 18px 42px rgba(15, 23, 42, 0.06);
            overflow: hidden;
        }

        .classroom-tab-list {
            display: flex;
            align-items: center;
            gap: 0.45rem;
            overflow-x: auto;
            padding: 0.8rem;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            scrollbar-width: thin;
        }

        .classroom-tab-btn {
            border: 1px solid #e2e8f0;
            border-radius: 999px;
            background: #f8fafc;
            color: #334155;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            flex: 0 0 auto;
            font-family: inherit;
            font-size: 0.9rem;
            font-weight: 900;
            min-height: 42px;
            padding: 0 1rem;
            transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease, transform 0.2s ease;
        }

        .classroom-tab-btn:hover {
            border-color: #a7f3d0;
            color: #047857;
            transform: translateY(-1px);
        }

        .classroom-tab-btn.active {
            background: #ecfdf5;
            border-color: #34d399;
            color: #047857;
            box-shadow: 0 10px 22px rgba(5, 150, 105, 0.12);
        }

        .tab-count {
            min-width: 22px;
            height: 22px;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 0.4rem;
            background: #e2e8f0;
            color: #475569;
            font-size: 0.75rem;
            font-weight: 950;
        }

        .classroom-tab-btn.active .tab-count {
            background: #059669;
            color: #ffffff;
        }

        .classroom-tab-content {
            padding: 1.25rem;
        }

        .classroom-tab-panel {
            display: none;
            animation: classroomTabIn 0.22s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .classroom-tab-panel.active {
            display: block;
        }

        .classroom-tabbed .classroom-card.classroom-tab-panel {
            margin-top: 0;
        }

        .classroom-tabbed .classroom-tab-panel.active ~ .classroom-tab-panel.active {
            margin-top: 1.25rem;
        }

        @keyframes classroomTabIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .tab-section-title {
            margin: 0 0 0.9rem;
            color: #0f172a;
            font-size: 1.2rem;
        }

        .tab-section-title:not(:first-child) {
            margin-top: 1.4rem;
        }

        .classroom-placeholder-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.85rem;
        }

        .classroom-placeholder-card {
            border: 1px solid #e2e8f0;
            border-radius: 0.95rem;
            background: #f8fafc;
            padding: 1rem;
        }

        .classroom-placeholder-card strong {
            display: block;
            color: #0f172a;
            margin-bottom: 0.35rem;
        }

        .classroom-placeholder-card span {
            color: #64748b;
            line-height: 1.55;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.85rem;
        }

        .info-item {
            border-radius: 0.85rem;
            background: #f8fafc;
            border: 1px solid #edf2f7;
            padding: 0.9rem;
        }

        .info-item span {
            display: block;
            color: #64748b;
            font-size: 0.76rem;
            text-transform: uppercase;
            font-weight: 900;
            margin-bottom: 0.35rem;
        }

        .info-item strong {
            display: block;
            color: #0f172a;
            line-height: 1.45;
        }

        .student-list {
            display: grid;
            gap: 0.75rem;
        }

        .student-row {
            display: grid;
            grid-template-columns: 44px minmax(0, 1fr) auto;
            gap: 0.75rem;
            align-items: center;
            padding: 0.75rem;
            border-radius: 0.85rem;
            background: #f8fafc;
            border: 1px solid #edf2f7;
        }

        .student-avatar {
            width: 44px;
            height: 44px;
            border-radius: 999px;
            display: grid;
            place-items: center;
            background: #ede9fe;
            color: #6d28d9;
            font-weight: 950;
        }

        .student-row strong,
        .student-row span {
            display: block;
        }

        .student-row span {
            color: #64748b;
            font-size: 0.88rem;
            margin-top: 0.1rem;
        }

        .review-actions {
            display: flex;
            gap: 0.4rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .mini-btn {
            border: 1px solid #e2e8f0;
            border-radius: 999px;
            padding: 0.55rem 0.8rem;
            background: #ffffff;
            color: #334155;
            font-weight: 850;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            font-family: inherit;
        }

        .mini-btn.primary {
            background: #6d28d9;
            border-color: #6d28d9;
            color: #ffffff;
        }

        .mini-btn.preview {
            border-color: #bbf7d0;
            background: #f0fdf4;
            color: #15803d;
        }

        .mini-btn.danger {
            color: #b91c1c;
        }

        .empty-state {
            border: 1px dashed #cbd5e1;
            border-radius: 0.85rem;
            background: #f8fafc;
            color: #64748b;
            padding: 1rem;
            line-height: 1.6;
        }

        .resource-list {
            display: grid;
            gap: 0.75rem;
        }

        .resource-item {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 0.8rem;
            align-items: center;
            padding: 0.9rem;
            border-radius: 0.85rem;
            background: #f8fafc;
            border: 1px solid #edf2f7;
        }

        .resource-item strong {
            display: block;
            margin-bottom: 0.2rem;
        }

        .resource-item span {
            color: #64748b;
            line-height: 1.55;
        }

        .resource-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 0.45rem;
            margin-top: 0.45rem;
        }

        .resource-chip {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.2rem 0.55rem;
            background: #ecfdf5;
            color: #047857;
            font-size: 0.72rem;
            font-weight: 900;
        }

        .resource-actions {
            display: flex;
            gap: 0.45rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .upload-panel {
            border: 1px solid #d1fae5;
            border-radius: 0.9rem;
            background: #f0fdf4;
            padding: 1rem;
            margin-bottom: 1rem;
        }

        .upload-panel h3 {
            margin: 0 0 0.8rem;
            font-size: 0.98rem;
            color: #065f46;
        }

        .upload-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.75rem;
        }

        .upload-field {
            display: grid;
            gap: 0.35rem;
        }

        .upload-field.full {
            grid-column: 1 / -1;
        }

        .upload-field label {
            color: #0f172a;
            font-size: 0.78rem;
            font-weight: 900;
        }

        .upload-field input,
        .upload-field select,
        .upload-field textarea {
            width: 100%;
            border: 1px solid #bbf7d0;
            border-radius: 0.72rem;
            padding: 0.7rem 0.85rem;
            outline: none;
            font-family: inherit;
            color: #0f172a;
            background: #ffffff;
        }

        .teacher-action-hint {
            color: #6d28d9;
            font-weight: 850;
            margin-top: 0.75rem;
        }

        .custom-toast-container {
            position: fixed;
            top: 90px;
            right: 22px;
            z-index: 2000;
            display: grid;
            gap: 0.7rem;
        }

        .custom-toast-msg {
            background: #16a34a;
            color: #ffffff;
            border-radius: 0.85rem;
            padding: 0.85rem 1rem;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.18);
            font-weight: 850;
            max-width: 340px;
        }

        .custom-toast-msg.error {
            background: #dc2626;
        }

        @media (max-width: 900px) {
            .classroom-hero,
            .classroom-grid {
                grid-template-columns: 1fr;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .classroom-placeholder-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 640px) {
            .classroom-shell {
                padding-inline: 1rem;
            }

            .student-row {
                grid-template-columns: 44px minmax(0, 1fr);
            }

            .review-actions {
                grid-column: 1 / -1;
                justify-content: flex-start;
            }

            .resource-item,
            .upload-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
                <img src="${pageContext.request.contextPath}/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes" class="active">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/practice">Luyện tập</a></li>
                <li><a href="${pageContext.request.contextPath}/teachers">Tìm giảng viên</a></li>
            </ul>
            <div class="navbar-user-controls">
                <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                <div class="nav-avatar-dropdown">
                    <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                        <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                            <img src="<%= h(user.getAvatarUrl()) %>" alt="Avatar">
                        <% } else { %>
                            <span class="nav-avatar-initials"><%= h(initials) %></span>
                        <% } %>
                    </div>
                    <div class="dropdown-menu-popup">
                        <a href="${pageContext.request.contextPath}/profile"><span><%= profileMenuLabel %></span></a>
                        <div style="height:1px; background:var(--border-dark); margin:0.35rem 0;"></div>
                        <a href="${pageContext.request.contextPath}/logout" class="danger-link"><span>Đăng xuất</span></a>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <main class="classroom-shell">
        <section class="classroom-hero">
            <div>
                <h1><%= h(title) %></h1>
                <div class="classroom-meta">
                    <span class="classroom-pill"><%= h(subject) %></span>
                    <span class="classroom-pill"><%= h(statusLabel) %></span>
                    <span class="classroom-pill"><%= h(schedule) %></span>
                </div>
            </div>
            <a class="online-room-btn" href="<%= h(onlineRoomHref) %>" target="_blank" rel="noopener">Vào phòng học online</a>
        </section>

        <section class="classroom-tabs-shell" aria-label="Nội dung lớp học">
            <div class="classroom-tab-list" role="tablist">
                <button type="button" class="classroom-tab-btn active" data-classroom-tab="info" role="tab" aria-selected="true">Thông tin lớp học</button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="materials" role="tab" aria-selected="false">
                    Tài liệu lớp học
                    <span class="tab-count"><%= materialCount + homeworkCount %></span>
                </button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="quiz" role="tab" aria-selected="false">Luyện tập trắc nghiệm</button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="leaderboard" role="tab" aria-selected="false">Bảng thành tích</button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="rules" role="tab" aria-selected="false">Nội quy lớp</button>
            </div>
        </section>

        <section class="classroom-grid classroom-tabbed">
            <div>
                <section class="classroom-card classroom-tab-panel active" data-classroom-panel="info">
                    <h2>Thông tin lớp học</h2>
                    <div class="info-grid">
                        <div class="info-item">
                            <span>Tên lớp học</span>
                            <strong><%= h(title) %></strong>
                        </div>
                        <div class="info-item">
                            <span>Môn học</span>
                            <strong><%= h(subject) %></strong>
                        </div>
                        <div class="info-item">
                            <span>Giảng viên phụ trách</span>
                            <strong><%= h(teacherName) %></strong>
                        </div>
                        <div class="info-item">
                            <span>Trạng thái lớp</span>
                            <strong><%= h(statusLabel) %></strong>
                        </div>
                        <div class="info-item">
                            <span>Lịch học gần nhất</span>
                            <strong><%= h(schedule) %></strong>
                        </div>
                    </div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="materials">
                    <h2>Tài liệu lớp học</h2>
                    <% if (canManageClassroom) { %>
                        <form class="upload-panel" action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="uploadClassMaterial">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <h3>Đăng tải tài liệu nội bộ</h3>
                            <div class="upload-grid">
                                <div class="upload-field">
                                    <label>Tiêu đề</label>
                                    <input type="text" name="materialTitle" placeholder="Ví dụ: Bài giảng buổi 1" required>
                                </div>
                                <div class="upload-field">
                                    <label>Loại tài liệu</label>
                                    <select name="materialCategory" required>
                                        <option value="teaching">Tài liệu giảng dạy</option>
                                        <option value="theory">Lý thuyết</option>
                                        <option value="exam">Đề thi riêng</option>
                                        <option value="homework">Bài tập về nhà</option>
                                    </select>
                                </div>
                                <div class="upload-field full">
                                    <label>Mô tả</label>
                                    <textarea name="materialDescription" rows="2" placeholder="Ghi chú ngắn cho học viên..."></textarea>
                                </div>
                                <div class="upload-field full">
                                    <label>File</label>
                                    <input type="file" name="materialFile" accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp" required>
                                </div>
                            </div>
                            <div class="review-actions" style="margin-top:0.85rem;">
                                <button class="mini-btn primary" type="submit">Đăng tải</button>
                            </div>
                        </form>
                    <% } %>
                    <div class="resource-list">
                        <% if (classMaterials == null || classMaterials.isEmpty()) { %>
                            <div class="empty-state">Chưa có tài liệu nào được đăng tải cho lớp này.</div>
                        <% } else {
                            for (ClassroomMaterial material : classMaterials) {
                        %>
                            <div class="resource-item">
                                <div>
                                    <strong><%= h(material.getTitle()) %></strong>
                                    <% if (material.getDescription() != null && !material.getDescription().isEmpty()) { %>
                                        <span><%= h(material.getDescription()) %></span>
                                    <% } %>
                                    <div class="resource-meta">
                                        <span class="resource-chip"><%= h(material.getCategoryLabel()) %></span>
                                        <span class="resource-chip"><%= h(material.getFormattedFileSize()) %></span>
                                    </div>
                                </div>
                                <div class="resource-actions">
                                    <a class="mini-btn preview" href="${pageContext.request.contextPath}/classroom-preview?id=<%= h(material.getId()) %>" target="_blank" rel="noopener">Xem trước</a>
                                    <a class="mini-btn primary" href="${pageContext.request.contextPath}/classroom-file?id=<%= h(material.getId()) %>">Tải file</a>
                                    <% if (canManageClassroom) { %>
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa tài liệu này?');">
                                            <input type="hidden" name="action" value="deleteClassMaterial">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="materialId" value="<%= h(material.getId()) %>">
                                            <button class="mini-btn danger" type="submit">Xóa</button>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="materials">
                    <h2>Bài tập về nhà</h2>
                    <div class="resource-list">
                        <% if (classHomework == null || classHomework.isEmpty()) { %>
                            <div class="empty-state">Chưa có bài tập về nhà. Khi giảng viên đăng file với loại “Bài tập về nhà”, học viên sẽ thấy tại đây.</div>
                        <% } else {
                            for (ClassroomMaterial material : classHomework) {
                        %>
                            <div class="resource-item">
                                <div>
                                    <strong><%= h(material.getTitle()) %></strong>
                                    <% if (material.getDescription() != null && !material.getDescription().isEmpty()) { %>
                                        <span><%= h(material.getDescription()) %></span>
                                    <% } %>
                                    <div class="resource-meta">
                                        <span class="resource-chip"><%= h(material.getFormattedFileSize()) %></span>
                                    </div>
                                </div>
                                <div class="resource-actions">
                                    <a class="mini-btn preview" href="${pageContext.request.contextPath}/classroom-preview?id=<%= h(material.getId()) %>" target="_blank" rel="noopener">Xem trước</a>
                                    <a class="mini-btn primary" href="${pageContext.request.contextPath}/classroom-file?id=<%= h(material.getId()) %>">Tải file</a>
                                    <% if (canManageClassroom) { %>
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa bài tập này?');">
                                            <input type="hidden" name="action" value="deleteClassMaterial">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="materialId" value="<%= h(material.getId()) %>">
                                            <button class="mini-btn danger" type="submit">Xóa</button>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>
                    <% if (canSubmitHomework) { %>
                        <form class="upload-panel" action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data" style="margin-top:1rem;">
                            <input type="hidden" name="action" value="submitHomework">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <h3>Nộp bài tập</h3>
                            <div class="upload-grid">
                                <div class="upload-field">
                                    <label>Tiêu đề bài nộp</label>
                                    <input type="text" name="submissionTitle" placeholder="Ví dụ: Bài tập buổi 1">
                                </div>
                                <div class="upload-field">
                                    <label>File bài tập</label>
                                    <input type="file" name="submissionFile" accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp" required>
                                </div>
                                <div class="upload-field full">
                                    <label>Ghi chú</label>
                                    <textarea name="submissionNote" rows="2" placeholder="Ghi chú ngắn cho giảng viên..."></textarea>
                                </div>
                            </div>
                            <div class="review-actions" style="margin-top:0.85rem;">
                                <button class="mini-btn primary" type="submit">Nộp bài</button>
                            </div>
                        </form>
                    <% } %>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="materials">
                    <h2><%= canManageClassroom ? "Bài tập học viên đã nộp" : "Bài tập đã nộp" %></h2>
                    <div class="resource-list">
                        <% if (homeworkSubmissions == null || homeworkSubmissions.isEmpty()) { %>
                            <div class="empty-state"><%= canManageClassroom ? "Chưa có học viên nào nộp bài tập." : "Bạn chưa nộp bài tập nào cho lớp này." %></div>
                        <% } else {
                            for (ClassroomHomeworkSubmission submission : homeworkSubmissions) {
                                String studentName = submission.getStudentName() != null && !submission.getStudentName().isEmpty() ? submission.getStudentName() : "Học viên";
                        %>
                            <div class="resource-item">
                                <div>
                                    <strong><%= h(submission.getTitle()) %></strong>
                                    <% if (canManageClassroom) { %>
                                        <span><%= h(studentName) %><%= submission.getStudentEmail() != null && !submission.getStudentEmail().isEmpty() ? " · " + h(submission.getStudentEmail()) : "" %></span>
                                    <% } %>
                                    <% if (submission.getNote() != null && !submission.getNote().isEmpty()) { %>
                                        <span><%= h(submission.getNote()) %></span>
                                    <% } %>
                                    <div class="resource-meta">
                                        <span class="resource-chip"><%= h(submission.getOriginalFileName()) %></span>
                                        <span class="resource-chip"><%= h(submission.getFormattedFileSize()) %></span>
                                    </div>
                                </div>
                                <div class="resource-actions">
                                    <a class="mini-btn primary" href="${pageContext.request.contextPath}/homework-submission-file?id=<%= h(submission.getId()) %>">Tải file</a>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="quiz">
                    <h2>Luyện tập trắc nghiệm</h2>
                    <div class="classroom-placeholder-grid">
                        <div class="classroom-placeholder-card">
                            <strong>Bộ câu hỏi theo buổi học</strong>
                            <span>Giảng viên sẽ có thể tạo quiz ngắn để học viên luyện tập ngay sau mỗi buổi.</span>
                        </div>
                        <div class="classroom-placeholder-card">
                            <strong>Chấm điểm tự động</strong>
                            <span>Hệ thống sẽ ghi nhận điểm, thời gian làm bài và số lần luyện tập.</span>
                        </div>
                        <div class="classroom-placeholder-card">
                            <strong>Ôn tập theo tiến độ</strong>
                            <span>Học viên có thể xem lại câu sai và luyện thêm theo chủ đề yếu.</span>
                        </div>
                    </div>
                    <div class="empty-state" style="margin-top:1rem;">Tính năng luyện tập trắc nghiệm sẽ được thiết kế ở bước sau.</div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="leaderboard">
                    <h2>Bảng thành tích</h2>
                    <div class="student-list">
                        <% if (acceptedEnrollments == null || acceptedEnrollments.isEmpty()) { %>
                            <div class="empty-state">Chưa có học viên để xếp hạng thành tích.</div>
                        <% } else {
                            int rank = 1;
                            for (ClassroomEnrollment enrollment : acceptedEnrollments) {
                                String name = enrollment.getStudentName() != null && !enrollment.getStudentName().isEmpty() ? enrollment.getStudentName() : "Học viên";
                        %>
                            <div class="student-row">
                                <div class="student-avatar">#<%= rank %></div>
                                <div>
                                    <strong><%= h(name) %></strong>
                                    <span>Điểm luyện tập sẽ được cập nhật khi chức năng quiz hoàn thiện.</span>
                                </div>
                                <span class="resource-chip">0 điểm</span>
                            </div>
                        <%      rank++;
                            }
                        } %>
                    </div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="rules">
                    <h2>Nội quy lớp học</h2>
                    <div class="resource-list">
                        <div class="resource-item">
                            <strong>Tôn trọng giờ học</strong>
                            <span>Học viên nên vào lớp đúng giờ, chuẩn bị thiết bị và tài liệu trước buổi học.</span>
                        </div>
                        <div class="resource-item">
                            <strong>Hoàn thành bài luyện tập</strong>
                            <span>Bài tập sau buổi học giúp giảng viên theo dõi tiến độ và điều chỉnh lộ trình phù hợp.</span>
                        </div>
                        <% if (canManageClassroom) { %>
                            <div class="teacher-action-hint">Giảng viên có thể tùy chỉnh nội quy riêng cho lớp ở bước tiếp theo.</div>
                        <% } %>
                    </div>
                </section>
            </div>

            <aside>
                <% if (canReviewEnrollments) { %>
                    <section class="classroom-card classroom-tab-panel active" data-classroom-panel="info">
                        <h2>Hàng chờ học viên</h2>
                        <div class="student-list">
                            <% if (pendingEnrollments == null || pendingEnrollments.isEmpty()) { %>
                                <div class="empty-state">Hiện chưa có học viên nào đang chờ duyệt.</div>
                            <% } else {
                                for (ClassroomEnrollment enrollment : pendingEnrollments) {
                                    String name = enrollment.getStudentName() != null && !enrollment.getStudentName().isEmpty() ? enrollment.getStudentName() : "Học viên";
                            %>
                                <div class="student-row">
                                    <div class="student-avatar"><%= h(name.substring(0, 1).toUpperCase()) %></div>
                                    <div>
                                        <strong><%= h(name) %></strong>
                                        <span><%= h(enrollment.getStudentEmail()) %></span>
                                    </div>
                                    <div class="review-actions">
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST">
                                            <input type="hidden" name="action" value="reviewEnrollment">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="enrollmentId" value="<%= h(enrollment.getId()) %>">
                                            <input type="hidden" name="decision" value="accepted">
                                            <button class="mini-btn primary" type="submit">Chấp nhận</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST">
                                            <input type="hidden" name="action" value="reviewEnrollment">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="enrollmentId" value="<%= h(enrollment.getId()) %>">
                                            <input type="hidden" name="decision" value="rejected">
                                            <button class="mini-btn danger" type="submit">Từ chối</button>
                                        </form>
                                    </div>
                                </div>
                            <%  }
                            } %>
                        </div>
                    </section>
                <% } %>

                <section class="classroom-card classroom-tab-panel active" data-classroom-panel="info">
                    <h2>Học viên trong lớp</h2>
                    <div class="student-list">
                        <% if (acceptedEnrollments == null || acceptedEnrollments.isEmpty()) { %>
                            <div class="empty-state">Danh sách học viên trong lớp đang trống.</div>
                        <% } else {
                            for (ClassroomEnrollment enrollment : acceptedEnrollments) {
                                String name = enrollment.getStudentName() != null && !enrollment.getStudentName().isEmpty() ? enrollment.getStudentName() : "Học viên";
                        %>
                            <div class="student-row">
                                <div class="student-avatar"><%= h(name.substring(0, 1).toUpperCase()) %></div>
                                <div>
                                    <strong><%= h(name) %></strong>
                                    <span><%= h(enrollment.getStudentEmail()) %></span>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>
                </section>
            </aside>
        </section>
    </main>

    <script>
        function switchClassroomTab(tabId, replaceHash = false) {
            const buttons = document.querySelectorAll('[data-classroom-tab]');
            const panels = document.querySelectorAll('[data-classroom-panel]');
            const targetButton = document.querySelector('[data-classroom-tab="' + tabId + '"]');
            if (!targetButton) {
                tabId = 'info';
            }

            buttons.forEach(button => {
                const isActive = button.dataset.classroomTab === tabId;
                button.classList.toggle('active', isActive);
                button.setAttribute('aria-selected', isActive ? 'true' : 'false');
            });

            panels.forEach(panel => {
                panel.classList.toggle('active', panel.dataset.classroomPanel === tabId);
            });

            const targetHash = '#tab-' + tabId;
            if (window.location.hash !== targetHash) {
                if (replaceHash) {
                    history.replaceState(null, '', targetHash);
                } else {
                    history.pushState(null, '', targetHash);
                }
            }
        }

        document.querySelectorAll('[data-classroom-tab]').forEach(button => {
            button.addEventListener('click', () => switchClassroomTab(button.dataset.classroomTab));
        });

        window.addEventListener('DOMContentLoaded', () => {
            const initialTab = window.location.hash && window.location.hash.startsWith('#tab-')
                ? window.location.hash.replace('#tab-', '')
                : 'info';
            switchClassroomTab(initialTab, true);
        });

        window.addEventListener('popstate', () => {
            const tabFromHash = window.location.hash && window.location.hash.startsWith('#tab-')
                ? window.location.hash.replace('#tab-', '')
                : 'info';
            switchClassroomTab(tabFromHash, true);
        });

        function showToast(message, type = 'success') {
            let container = document.getElementById('custom-toast-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'custom-toast-container';
                container.className = 'custom-toast-container';
                document.body.appendChild(container);
            }
            const toast = document.createElement('div');
            toast.className = 'custom-toast-msg ' + (type === 'error' ? 'error' : '');
            toast.textContent = message;
            container.appendChild(toast);
            setTimeout(() => toast.remove(), 3200);
        }

        <% if (session.getAttribute("toastMsg") != null) {
            String msg = (String) session.getAttribute("toastMsg");
            String type = (String) session.getAttribute("toastType");
            session.removeAttribute("toastMsg");
            session.removeAttribute("toastType");
        %>
        window.addEventListener('DOMContentLoaded', () => {
            showToast("<%= msg.replace("\\", "\\\\").replace("\"", "\\\"") %>", "<%= type != null ? type : "success" %>");
        });
        <% } %>
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
</body>
</html>
