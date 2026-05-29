<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.ClassroomEnrollment"%>
<%@page import="com.hipzi.model.ClassroomExam"%>
<%@page import="com.hipzi.model.ClassroomHomeworkSubmission"%>
<%@page import="com.hipzi.model.ClassroomMaterial"%>
<%@page import="com.hipzi.model.ClassroomQuiz"%>
<%@page import="com.hipzi.model.ClassroomQuizAttempt"%>
<%@page import="com.hipzi.model.ClassroomQuizQuestion"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="java.util.Map"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String u(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
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
    List<ClassroomMaterial> classExamMaterials = (List<ClassroomMaterial>) request.getAttribute("classExamMaterials");
    List<ClassroomExam> classroomExams = (List<ClassroomExam>) request.getAttribute("classroomExams");
    List<ClassroomHomeworkSubmission> homeworkSubmissions = (List<ClassroomHomeworkSubmission>) request.getAttribute("homeworkSubmissions");
    List<ClassroomQuiz> classroomQuizzes = (List<ClassroomQuiz>) request.getAttribute("classroomQuizzes");
    Map<String, ClassroomQuizAttempt> latestQuizAttempts = (Map<String, ClassroomQuizAttempt>) request.getAttribute("latestQuizAttempts");

    String title = classroom != null ? classroom.getTitle() : "Lớp học HIPZI";
    String subject = classroom != null ? classroom.getSubject() : "Môn học";
    String grade = classroom != null && classroom.getGrade() != null && !classroom.getGrade().isEmpty() ? classroom.getGrade() : "Lớp học";
    String teacherName = classroom != null && classroom.getTeacherName() != null && !classroom.getTeacherName().isEmpty() ? classroom.getTeacherName() : "Giảng viên HIPZI";
    String teacherAvatarUrl = classroom != null && classroom.getTeacherAvatarUrl() != null ? classroom.getTeacherAvatarUrl().trim() : "";
    String schedule = classroom != null && classroom.getSchedule() != null ? classroom.getSchedule() : "Lịch học đang cập nhật";
    String statusLabel = classroom != null ? classroom.getStatusLabel() : "Đang mở";
    String onlineRoomHref = "https://meet.google.com/new";
    int pendingCount = pendingEnrollments != null ? pendingEnrollments.size() : 0;
    int acceptedCount = acceptedEnrollments != null ? acceptedEnrollments.size() : 0;
    int materialCount = classMaterials != null ? classMaterials.size() : 0;
    int homeworkCount = classHomework != null ? classHomework.size() : 0;
    int examCount = classroomExams != null ? classroomExams.size() : 0;
    int quizCount = classroomQuizzes != null ? classroomQuizzes.size() : 0;
    String quizDraftTitle = (String) session.getAttribute("quizDraftTitle");
    String quizDraftDescription = (String) session.getAttribute("quizDraftDescription");
    String quizDraftScanText = (String) session.getAttribute("quizDraftScanText");
    List<ClassroomQuizQuestion> quizDraftQuestions = (List<ClassroomQuizQuestion>) session.getAttribute("quizDraftQuestions");
    session.removeAttribute("quizDraftTitle");
    session.removeAttribute("quizDraftDescription");
    session.removeAttribute("quizDraftScanText");
    session.removeAttribute("quizDraftQuestions");
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
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=3">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
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
            width: 100%;
            max-width: 1424px;
            margin: 0 auto;
            padding: 7rem 1.25rem 4rem;
            box-sizing: border-box;
            overflow: hidden;
        }

        .classroom-hero {
            position: relative;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(250px, 0.34fr);
            gap: 1.25rem;
            align-items: stretch;
            padding: 1.35rem;
            border: 1px solid rgba(203, 213, 225, 0.72);
            border-radius: 1.15rem;
            background:
                linear-gradient(135deg, rgba(255, 255, 255, 0.96), rgba(240, 253, 250, 0.9)),
                #ffffff;
            color: #0f172a;
            box-shadow: 0 22px 60px rgba(15, 23, 42, 0.08), 0 14px 34px rgba(15, 118, 110, 0.08);
            overflow: hidden;
        }

        .classroom-hero::after {
            content: none;
        }

        .classroom-hero-main {
            display: flex;
            min-width: 0;
            flex-direction: column;
            justify-content: center;
            padding-right: 0.5rem;
        }

        .classroom-back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            margin: 0 0 0.75rem;
            color: #64748b;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 850;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .classroom-back-link:hover {
            color: #0f766e;
            transform: translateX(-2px);
        }

        .classroom-hero h1 {
            margin: 0;
            font-size: clamp(1.8rem, 3vw, 2.65rem);
            line-height: 1.12;
            letter-spacing: 0;
        }

        .classroom-hero-desc {
            max-width: 720px;
            margin: 0.75rem 0 0;
            color: #64748b;
            font-size: 0.98rem;
            font-weight: 650;
            line-height: 1.55;
        }

        .classroom-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 0.55rem;
            margin-bottom: 0.85rem;
        }

        .classroom-pill {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.38rem 0.78rem;
            background: #ecfdf5;
            border: 1px solid #bbf7d0;
            color: #047857;
            font-weight: 900;
            font-size: 0.78rem;
        }

        .classroom-pill.muted {
            background: #f8fafc;
            border-color: #e2e8f0;
            color: #475569;
        }

        .online-room-btn {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: max-content;
            min-width: 0;
            border-radius: 999px;
            margin-top: 1.1rem;
            padding: 0.78rem 1.25rem;
            background: #0f766e;
            color: #ffffff;
            font-weight: 950;
            text-decoration: none;
            box-shadow: 0 14px 30px rgba(15, 118, 110, 0.22);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .online-room-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 18px 38px rgba(15, 118, 110, 0.28);
        }

        .classroom-teacher-card {
            display: grid;
            grid-template-rows: auto 1fr auto;
            gap: 0.85rem;
            min-height: 210px;
            border: 1px solid rgba(148, 163, 184, 0.24);
            border-radius: 1rem;
            padding: 1rem;
            background:
                linear-gradient(180deg, rgba(240, 253, 250, 0.96), rgba(255, 255, 255, 0.96)),
                #ffffff;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.92), 0 18px 36px rgba(15, 118, 110, 0.1);
        }

        .classroom-teacher-badge {
            display: inline-flex;
            width: max-content;
            align-items: center;
            border-radius: 999px;
            padding: 0.34rem 0.7rem;
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #bbf7d0;
            font-size: 0.75rem;
            font-weight: 900;
        }

        .classroom-teacher-photo {
            align-self: center;
            justify-self: center;
            width: min(150px, 55%);
            aspect-ratio: 1;
            border-radius: 999px;
            padding: 0.35rem;
            background: linear-gradient(135deg, #14b8a6, #d1fae5);
            box-shadow: 0 18px 34px rgba(15, 118, 110, 0.18);
        }

        .classroom-teacher-photo img,
        .classroom-teacher-placeholder {
            width: 100%;
            height: 100%;
            border-radius: inherit;
            border: 4px solid #ffffff;
            object-fit: cover;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8fafc;
            color: #0f766e;
            font-size: 2.6rem;
            font-weight: 950;
        }

        .classroom-teacher-meta {
            text-align: center;
            display: grid;
            gap: 0.2rem;
        }

        .classroom-teacher-meta strong {
            color: #0f172a;
            font-size: 1rem;
            line-height: 1.25;
        }

        .classroom-teacher-meta span {
            color: #64748b;
            font-size: 0.84rem;
            font-weight: 750;
        }

        .classroom-grid {
            display: block;
            width: 100%;
            max-width: 100%;
            margin-top: calc(1.25rem - 15px);
            box-sizing: border-box;
            overflow: hidden;
        }
        
        .classroom-grid > div {
            width: 100%;
            max-width: 100%;
            display: block;
            box-sizing: border-box;
        }

        .classroom-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.2rem;
            box-shadow: 0 16px 34px rgba(15, 23, 42, 0.05);
            width: 100%;
            box-sizing: border-box;
            overflow: hidden;
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
            width: 100%;
            box-sizing: border-box;
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
            width: 100%;
            box-sizing: border-box;
            animation: classroomTabIn 0.22s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .classroom-tab-panel.active {
            display: block;
        }

        .classroom-tabbed .classroom-card.classroom-tab-panel {
            margin-top: 0;
            width: 100%;
            max-width: 100%;
            box-sizing: border-box;
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

        .mini-btn:disabled {
            opacity: 0.55;
            cursor: not-allowed;
            transform: none;
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

        .quiz-builder {
            display: grid;
            gap: 1rem;
        }

        .quiz-scan-preview {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(220px, 0.45fr);
            gap: 1rem;
            align-items: start;
        }

        .quiz-image-preview {
            min-height: 180px;
            border: 1px dashed #cbd5e1;
            border-radius: 0.85rem;
            background: #ffffff;
            display: grid;
            place-items: center;
            color: #64748b;
            overflow: hidden;
            text-align: center;
            padding: 0.9rem;
        }

        .quiz-image-preview img {
            width: 100%;
            max-height: 280px;
            object-fit: contain;
            display: block;
        }

        .quiz-list {
            display: grid;
            gap: 1rem;
        }

        .quiz-card {
            border: 1px solid #e2e8f0;
            border-radius: 0.85rem;
            background: #ffffff;
            padding: 1rem;
        }

        .quiz-card-head {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 0.85rem;
            align-items: start;
            margin-bottom: 0.85rem;
        }

        .quiz-card h3,
        .quiz-question h4 {
            margin: 0;
            color: #0f172a;
        }

        .quiz-status {
            border-radius: 999px;
            padding: 0.35rem 0.7rem;
            font-weight: 900;
            font-size: 0.78rem;
            background: #fef3c7;
            color: #92400e;
            white-space: nowrap;
        }

        .quiz-status.published {
            background: #dcfce7;
            color: #166534;
        }

        .quiz-question-list {
            display: grid;
            gap: 0.85rem;
        }

        .quiz-question {
            border: 1px solid #e2e8f0;
            border-radius: 0.8rem;
            background: #f8fafc;
            padding: 0.9rem;
        }

        .quiz-option-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.7rem;
            margin-top: 0.75rem;
        }

        .quiz-option-grid label,
        .quiz-answer-option {
            display: grid;
            gap: 0.35rem;
            color: #334155;
            font-weight: 750;
        }

        .quiz-option-grid input,
        .quiz-option-grid select {
            width: 100%;
            border: 1px solid #cbd5e1;
            border-radius: 0.7rem;
            padding: 0.65rem 0.75rem;
            font-family: inherit;
            color: #0f172a;
        }

        .quiz-answer-option input[type="radio"] {
            width: auto;
            margin-top: 0.2rem;
            border: 0;
            padding: 0;
        }

        .quiz-answer-option {
            grid-template-columns: auto minmax(0, 1fr);
            align-items: start;
            border: 1px solid #e2e8f0;
            border-radius: 0.75rem;
            background: #ffffff;
            padding: 0.65rem;
        }

        .quiz-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 0.6rem;
            align-items: center;
            margin-top: 0.9rem;
        }

        .quiz-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            color: #64748b;
            font-size: 0.9rem;
            margin-top: 0.35rem;
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
            .classroom-hero {
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
            .upload-grid,
            .quiz-scan-preview,
            .quiz-card-head,
            .quiz-option-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
</head>
<body>
    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes" class="active">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>

                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index.jsp#ai-roadmap">Hipzi AI</a></li>
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
        <a class="classroom-back-link" href="${pageContext.request.contextPath}/class-detail?id=<%= h(classroom.getId()) %>">
            <span>←</span>
            <span>Quay lại</span>
        </a>

        <section class="classroom-hero">
            <div class="classroom-hero-main">
                <h1><%= h(title) %></h1>
                <p class="classroom-hero-desc">Không gian học tập của lớp cùng giảng viên <strong><%= h(teacherName) %></strong>. Theo dõi tài liệu, bài tập và trao đổi trong phòng học riêng của HIPZI.</p>
                <div class="classroom-meta">
                    <span class="classroom-pill"><%= h(statusLabel) %></span>
                    <span class="classroom-pill muted"><%= h(subject) %></span>
                    <span class="classroom-pill muted"><%= h(grade) %></span>
                    <span class="classroom-pill muted"><%= h(schedule) %></span>
                </div>
                <a class="online-room-btn" href="<%= h(onlineRoomHref) %>" target="_blank" rel="noopener">Vào phòng học online</a>
            </div>
            <aside class="classroom-teacher-card" aria-label="Thông tin giảng viên">
                <span class="classroom-teacher-badge">Giảng viên</span>
                <div class="classroom-teacher-photo">
                    <% if (!teacherAvatarUrl.isEmpty()) { %>
                        <img src="<%= h(teacherAvatarUrl) %>" alt="">
                    <% } else { %>
                        <div class="classroom-teacher-placeholder"><%= h(teacherName.substring(0, 1).toUpperCase()) %></div>
                    <% } %>
                </div>
                <div class="classroom-teacher-meta">
                    <strong><%= h(teacherName) %></strong>
                    <span><%= h(subject) %> · <%= h(grade) %></span>
                </div>
            </aside>
        </section>

        <section class="classroom-tabs-shell" aria-label="Nội dung lớp học">
            <div class="classroom-tab-list" role="tablist">
                <button type="button" class="classroom-tab-btn active" data-classroom-tab="info" role="tab" aria-selected="true">Thông tin lớp học</button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="materials" role="tab" aria-selected="false">
                    Tài liệu lớp học
                    <span class="tab-count"><%= materialCount + homeworkCount %></span>
                </button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="quiz" role="tab" aria-selected="false">
                    Luyện tập trắc nghiệm
                    <span class="tab-count"><%= quizCount %></span>
                </button>
                <button type="button" class="classroom-tab-btn" data-classroom-tab="exams" role="tab" aria-selected="false">
                    Phòng thi
                    <span class="tab-count"><%= examCount %></span>
                </button>
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
                    <% if (canManageClassroom) { %>
                        <form class="upload-panel quiz-builder" action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <h3>Tạo đề từ ảnh scan</h3>
                            <div class="upload-grid">
                                <div class="upload-field">
                                    <label>Tiêu đề đề luyện tập</label>
                                    <input type="text" name="quizTitle" placeholder="Ví dụ: Luyện tập chương 1" value="<%= h(quizDraftTitle) %>" required>
                                </div>
                                <div class="upload-field">
                                    <label>Ảnh đề</label>
                                    <input type="file" name="quizSourceImage" accept="image/png,image/jpeg,image/webp" capture="environment" data-quiz-image-input>
                                </div>
                                <div class="upload-field full">
                                    <label>Mô tả</label>
                                    <textarea name="quizDescription" rows="2" placeholder="Ghi chú ngắn cho học viên..."><%= h(quizDraftDescription) %></textarea>
                                </div>
                            </div>
                            <div class="quiz-scan-preview">
                                <div class="upload-field">
                                    <label>Nội dung scan</label>
                                    <textarea name="quizScanText" rows="12" placeholder="Câu 1. ...
A. ...
B. ...
C. ...
D. ...
Đáp án: A"><%= h(quizDraftScanText) %></textarea>
                                </div>
                                <div class="quiz-image-preview" data-quiz-image-preview>Chưa chọn ảnh</div>
                            </div>
                            <div class="quiz-actions">
                                <button class="mini-btn preview" type="submit" name="action" value="scanQuizImage">Scan miễn phí</button>
                                <button class="mini-btn" type="submit" name="action" value="scanQuizImageAi" title="Scan AI dùng OCR text và AI để tách câu hỏi chính xác hơn.">Scan AI</button>
                                <button class="mini-btn primary" type="submit" name="action" value="createQuizDraft">Tạo bản nháp</button>
                            </div>
                        </form>
                    <% } %>

                    <% if (canManageClassroom && quizDraftQuestions != null && !quizDraftQuestions.isEmpty()) { %>
                        <div class="quiz-card" style="margin-bottom:1rem;">
                            <div class="quiz-card-head">
                                <div>
                                    <h3>Câu hỏi đã nhận diện</h3>
                                    <div class="quiz-meta">
                                        <span><%= quizDraftQuestions.size() %> câu từ ảnh scan</span>
                                        <span>Giảng viên kiểm tra nội dung và chọn đáp án đúng trước khi lưu.</span>
                                    </div>
                                </div>
                                <span class="quiz-status">Chưa lưu</span>
                            </div>
                            <form action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data" data-quiz-edit-form>
                                <input type="hidden" name="action" value="createQuizDraft">
                                <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                <div class="upload-grid">
                                    <div class="upload-field">
                                        <label>Tiêu đề</label>
                                        <input type="text" name="quizTitle" value="<%= h(quizDraftTitle) %>" required>
                                    </div>
                                    <div class="upload-field">
                                        <label>Trạng thái</label>
                                        <select name="quizStatus" disabled>
                                            <option>Bản nháp</option>
                                        </select>
                                    </div>
                                    <div class="upload-field full">
                                        <label>Mô tả</label>
                                        <textarea name="quizDescription" rows="2"><%= h(quizDraftDescription) %></textarea>
                                    </div>
                                    <div class="upload-field full">
                                        <label>Nội dung scan gốc</label>
                                        <textarea name="quizScanText" rows="4"><%= h(quizDraftScanText) %></textarea>
                                    </div>
                                </div>
                                <div class="quiz-question-list" data-question-list style="margin-top:0.9rem;">
                                    <%
                                        int draftQuestionIndex = 1;
                                        for (ClassroomQuizQuestion question : quizDraftQuestions) {
                                    %>
                                        <div class="quiz-question">
                                            <h4>Câu <%= draftQuestionIndex++ %></h4>
                                            <div class="upload-field" style="margin-top:0.65rem;">
                                                <label>Nội dung câu hỏi</label>
                                                <textarea name="questionText" rows="2" required><%= h(question.getQuestionText()) %></textarea>
                                            </div>
                                            <div class="quiz-option-grid">
                                                <label>A <input type="text" name="optionA" value="<%= h(question.getOptionA()) %>"></label>
                                                <label>B <input type="text" name="optionB" value="<%= h(question.getOptionB()) %>"></label>
                                                <label>C <input type="text" name="optionC" value="<%= h(question.getOptionC()) %>"></label>
                                                <label>D <input type="text" name="optionD" value="<%= h(question.getOptionD()) %>"></label>
                                            </div>
                                            <div class="upload-grid" style="margin-top:0.75rem;">
                                                <div class="upload-field">
                                                    <label>Đáp án đúng</label>
                                                    <select name="correctOption">
                                                        <option value="">Chưa chọn</option>
                                                        <option value="A" <%= "A".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>A</option>
                                                        <option value="B" <%= "B".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>B</option>
                                                        <option value="C" <%= "C".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>C</option>
                                                        <option value="D" <%= "D".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>D</option>
                                                    </select>
                                                </div>
                                                <div class="upload-field">
                                                    <label>Giải thích</label>
                                                    <input type="text" name="explanation" value="<%= h(question.getExplanation()) %>">
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                                <div class="quiz-actions">
                                    <button class="mini-btn preview" type="button" data-add-question>Thêm câu</button>
                                    <button class="mini-btn primary" type="submit">Lưu bản nháp</button>
                                </div>
                            </form>
                        </div>
                    <% } %>

                    <div class="quiz-list">
                        <% if (classroomQuizzes == null || classroomQuizzes.isEmpty()) { %>
                            <div class="empty-state"><%= canManageClassroom ? "Chưa có đề luyện tập nào. Giảng viên có thể tạo bản nháp từ ảnh đề." : "Lớp chưa có đề luyện tập được publish." %></div>
                        <% } else {
                            for (ClassroomQuiz quiz : classroomQuizzes) {
                                ClassroomQuizAttempt latestAttempt = latestQuizAttempts != null ? latestQuizAttempts.get(quiz.getId()) : null;
                        %>
                            <div class="quiz-card" id="quiz-<%= h(quiz.getId()) %>">
                                <div class="quiz-card-head">
                                    <div>
                                        <h3><%= h(quiz.getTitle()) %></h3>
                                        <% if (quiz.getDescription() != null && !quiz.getDescription().isEmpty()) { %>
                                            <div class="quiz-meta"><span><%= h(quiz.getDescription()) %></span></div>
                                        <% } %>
                                        <div class="quiz-meta">
                                            <span><%= quiz.getQuestionCount() %> câu hỏi</span>
                                            <% if (latestAttempt != null) { %>
                                                <span>Điểm gần nhất: <%= h(latestAttempt.getScoreLabel()) %></span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <span class="quiz-status <%= quiz.isPublished() ? "published" : "" %>"><%= quiz.isPublished() ? "Đã publish" : "Bản nháp" %></span>
                                </div>

                                <% if (canManageClassroom) { %>
                                    <form action="${pageContext.request.contextPath}/classroom" method="POST" data-quiz-edit-form>
                                        <input type="hidden" name="action" value="updateQuizDraft">
                                        <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                        <input type="hidden" name="quizId" value="<%= h(quiz.getId()) %>">
                                        <div class="upload-grid">
                                            <div class="upload-field">
                                                <label>Tiêu đề</label>
                                                <input type="text" name="quizTitle" value="<%= h(quiz.getTitle()) %>" required>
                                            </div>
                                            <div class="upload-field">
                                                <label>Trạng thái</label>
                                                <select name="quizStatus">
                                                    <option value="draft" <%= quiz.isPublished() ? "" : "selected" %>>Bản nháp</option>
                                                    <option value="published" <%= quiz.isPublished() ? "selected" : "" %>>Publish cho lớp</option>
                                                </select>
                                            </div>
                                            <div class="upload-field full">
                                                <label>Mô tả</label>
                                                <textarea name="quizDescription" rows="2"><%= h(quiz.getDescription()) %></textarea>
                                            </div>
                                            <div class="upload-field full">
                                                <label>Nội dung scan gốc</label>
                                                <textarea name="quizScanText" rows="4"><%= h(quiz.getRawScanText()) %></textarea>
                                            </div>
                                        </div>
                                        <div class="quiz-question-list" data-question-list style="margin-top:0.9rem;">
                                            <% if (quiz.getQuestions() != null) {
                                                int questionIndex = 1;
                                                for (ClassroomQuizQuestion question : quiz.getQuestions()) {
                                            %>
                                                <div class="quiz-question">
                                                    <h4>Câu <%= questionIndex++ %></h4>
                                                    <div class="upload-field" style="margin-top:0.65rem;">
                                                        <label>Nội dung câu hỏi</label>
                                                        <textarea name="questionText" rows="2" required><%= h(question.getQuestionText()) %></textarea>
                                                    </div>
                                                    <div class="quiz-option-grid">
                                                        <label>A <input type="text" name="optionA" value="<%= h(question.getOptionA()) %>"></label>
                                                        <label>B <input type="text" name="optionB" value="<%= h(question.getOptionB()) %>"></label>
                                                        <label>C <input type="text" name="optionC" value="<%= h(question.getOptionC()) %>"></label>
                                                        <label>D <input type="text" name="optionD" value="<%= h(question.getOptionD()) %>"></label>
                                                    </div>
                                                    <div class="upload-grid" style="margin-top:0.75rem;">
                                                        <div class="upload-field">
                                                            <label>Đáp án đúng</label>
                                                            <select name="correctOption">
                                                                <option value="">Chưa chọn</option>
                                                                <option value="A" <%= "A".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>A</option>
                                                                <option value="B" <%= "B".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>B</option>
                                                                <option value="C" <%= "C".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>C</option>
                                                                <option value="D" <%= "D".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>D</option>
                                                            </select>
                                                        </div>
                                                        <div class="upload-field">
                                                            <label>Giải thích</label>
                                                            <input type="text" name="explanation" value="<%= h(question.getExplanation()) %>">
                                                        </div>
                                                    </div>
                                                </div>
                                            <%  }
                                            } %>
                                        </div>
                                        <div class="quiz-actions">
                                            <button class="mini-btn preview" type="button" data-add-question>Thêm câu</button>
                                            <button class="mini-btn primary" type="submit">Lưu đề</button>
                                        </div>
                                    </form>
                                    <div class="quiz-actions">
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="quizId" value="<%= h(quiz.getId()) %>">
                                            <input type="hidden" name="action" value="<%= quiz.isPublished() ? "unpublishQuiz" : "publishQuiz" %>">
                                            <button class="mini-btn <%= quiz.isPublished() ? "" : "primary" %>" type="submit"><%= quiz.isPublished() ? "Đưa về nháp" : "Publish" %></button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa đề này?');">
                                            <input type="hidden" name="action" value="deleteQuiz">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="quizId" value="<%= h(quiz.getId()) %>">
                                            <button class="mini-btn danger" type="submit">Xóa đề</button>
                                        </form>
                                    </div>
                                <% } else { %>
                                    <form action="${pageContext.request.contextPath}/classroom" method="POST">
                                        <input type="hidden" name="action" value="submitQuizAttempt">
                                        <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                        <input type="hidden" name="quizId" value="<%= h(quiz.getId()) %>">
                                        <div class="quiz-question-list">
                                            <% if (quiz.getQuestions() != null) {
                                                int studentQuestionIndex = 1;
                                                for (ClassroomQuizQuestion question : quiz.getQuestions()) {
                                            %>
                                                <div class="quiz-question">
                                                    <h4>Câu <%= studentQuestionIndex++ %></h4>
                                                    <p style="margin:0.45rem 0 0;color:#0f172a;line-height:1.6;"><%= h(question.getQuestionText()) %></p>
                                                    <div class="quiz-option-grid">
                                                        <% if (question.getOptionA() != null && !question.getOptionA().isEmpty()) { %>
                                                            <label class="quiz-answer-option"><input type="radio" name="answer_<%= h(question.getId()) %>" value="A"> <span>A. <%= h(question.getOptionA()) %></span></label>
                                                        <% } %>
                                                        <% if (question.getOptionB() != null && !question.getOptionB().isEmpty()) { %>
                                                            <label class="quiz-answer-option"><input type="radio" name="answer_<%= h(question.getId()) %>" value="B"> <span>B. <%= h(question.getOptionB()) %></span></label>
                                                        <% } %>
                                                        <% if (question.getOptionC() != null && !question.getOptionC().isEmpty()) { %>
                                                            <label class="quiz-answer-option"><input type="radio" name="answer_<%= h(question.getId()) %>" value="C"> <span>C. <%= h(question.getOptionC()) %></span></label>
                                                        <% } %>
                                                        <% if (question.getOptionD() != null && !question.getOptionD().isEmpty()) { %>
                                                            <label class="quiz-answer-option"><input type="radio" name="answer_<%= h(question.getId()) %>" value="D"> <span>D. <%= h(question.getOptionD()) %></span></label>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            <%  }
                                            } %>
                                        </div>
                                        <div class="quiz-actions">
                                            <button class="mini-btn primary" type="submit">Nộp bài</button>
                                        </div>
                                    </form>
                                <% } %>
                            </div>
                        <%  }
                        } %>
                    </div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="exams">
                    <h2>Phòng thi lớp học</h2>
                    <% if (canManageClassroom) { %>
                        <form class="upload-panel" action="${pageContext.request.contextPath}/classroom" method="POST">
                            <input type="hidden" name="action" value="createClassExam">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <h3>Tạo bài thi lớp học</h3>
                            <div class="upload-grid">
                                <div class="upload-field">
                                    <label>Tiêu đề bài thi</label>
                                    <input type="text" name="examTitle" placeholder="Ví dụ: Kiểm tra chương 1" required>
                                </div>
                                <div class="upload-field">
                                    <label>Mã đề</label>
                                    <input type="text" name="examCode" placeholder="VD: HIPZI-TOAN10-01" required>
                                </div>
                                <div class="upload-field">
                                    <label>Thời lượng</label>
                                    <input type="number" name="durationMinutes" min="1" value="45" required>
                                </div>
                                <div class="upload-field">
                                    <label>Trạng thái</label>
                                    <select name="examStatus">
                                        <option value="open">Đang mở</option>
                                        <option value="draft">Bản nháp</option>
                                        <option value="closed">Đã đóng</option>
                                    </select>
                                </div>
                                <div class="upload-field full">
                                    <label>Gắn file đề đã upload</label>
                                    <select name="sourceMaterialId">
                                        <option value="">Không gắn file</option>
                                        <% if (classExamMaterials != null) {
                                            for (ClassroomMaterial material : classExamMaterials) {
                                        %>
                                            <option value="<%= h(material.getId()) %>"><%= h(material.getTitle()) %></option>
                                        <%  }
                                        } %>
                                    </select>
                                </div>
                                <div class="upload-field full">
                                    <label>Mô tả</label>
                                    <textarea name="examDescription" rows="2" placeholder="Ghi chú, phạm vi kiến thức, quy định làm bài..."></textarea>
                                </div>
                            </div>
                            <div class="quiz-actions">
                                <button class="mini-btn primary" type="submit">Tạo bài thi</button>
                            </div>
                        </form>
                    <% } %>
                    <div class="resource-list">
                        <% if (classroomExams == null || classroomExams.isEmpty()) { %>
                            <div class="empty-state"><%= canManageClassroom ? "Chưa có bài thi lớp học nào." : "Lớp chưa có bài thi nào đang mở." %></div>
                        <% } else {
                            for (ClassroomExam exam : classroomExams) {
                                String examHref = request.getContextPath()
                                        + "/class-exam-room.jsp?classId=" + u(classroom.getId())
                                        + "&code=" + u(exam.getExamCode())
                                        + "&title=" + u(exam.getTitle());
                        %>
                            <div class="resource-item">
                                <div>
                                    <strong><%= h(exam.getTitle()) %></strong>
                                    <% if (exam.getDescription() != null && !exam.getDescription().isEmpty()) { %>
                                        <span><%= h(exam.getDescription()) %></span>
                                    <% } %>
                                    <div class="resource-meta">
                                        <span class="resource-chip">Bài thi lớp học</span>
                                        <span class="resource-chip"><%= h(exam.getExamCode()) %></span>
                                        <span class="resource-chip"><%= h(exam.getStatusLabel()) %></span>
                                        <span class="resource-chip"><%= exam.getDurationMinutes() %> phút</span>
                                    </div>
                                </div>
                                <div class="resource-actions">
                                    <a class="mini-btn primary" href="<%= h(examHref) %>">Vào phòng thi</a>
                                    <% if (exam.getSourceMaterialId() != null && !exam.getSourceMaterialId().isEmpty()) { %>
                                        <a class="mini-btn preview" href="${pageContext.request.contextPath}/classroom-preview?id=<%= h(exam.getSourceMaterialId()) %>" target="_blank" rel="noopener">Xem đề</a>
                                    <% } %>
                                    <% if (canManageClassroom) { %>
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa bài thi này?');">
                                            <input type="hidden" name="action" value="deleteClassExam">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="examId" value="<%= h(exam.getId()) %>">
                                            <button class="mini-btn danger" type="submit">Xóa</button>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>
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

        document.querySelectorAll('[data-quiz-image-input]').forEach(input => {
            input.addEventListener('change', () => {
                const preview = input.closest('form')?.querySelector('[data-quiz-image-preview]');
                const file = input.files && input.files[0];
                if (!preview) return;
                if (!file) {
                    preview.textContent = 'Chưa chọn ảnh';
                    return;
                }
                const img = document.createElement('img');
                img.alt = file.name || 'Ảnh đề';
                img.src = URL.createObjectURL(file);
                img.onload = () => URL.revokeObjectURL(img.src);
                preview.replaceChildren(img);
            });
        });

        function renumberQuizQuestions(list) {
            list.querySelectorAll('.quiz-question h4').forEach((heading, index) => {
                heading.textContent = 'Câu ' + (index + 1);
            });
        }

        document.querySelectorAll('[data-add-question]').forEach(button => {
            button.addEventListener('click', () => {
                const form = button.closest('form');
                const list = form ? form.querySelector('[data-question-list]') : null;
                if (!list) return;
                list.insertAdjacentHTML('beforeend', `
                    <div class="quiz-question">
                        <h4>Câu</h4>
                        <div class="upload-field" style="margin-top:0.65rem;">
                            <label>Nội dung câu hỏi</label>
                            <textarea name="questionText" rows="2" required></textarea>
                        </div>
                        <div class="quiz-option-grid">
                            <label>A <input type="text" name="optionA"></label>
                            <label>B <input type="text" name="optionB"></label>
                            <label>C <input type="text" name="optionC"></label>
                            <label>D <input type="text" name="optionD"></label>
                        </div>
                        <div class="upload-grid" style="margin-top:0.75rem;">
                            <div class="upload-field">
                                <label>Đáp án đúng</label>
                                <select name="correctOption">
                                    <option value="">Chưa chọn</option>
                                    <option value="A">A</option>
                                    <option value="B">B</option>
                                    <option value="C">C</option>
                                    <option value="D">D</option>
                                </select>
                            </div>
                            <div class="upload-field">
                                <label>Giải thích</label>
                                <input type="text" name="explanation">
                            </div>
                        </div>
                    </div>
                `);
                renumberQuizQuestions(list);
                list.lastElementChild?.querySelector('textarea')?.focus();
            });
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
