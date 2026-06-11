<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.ClassroomEnrollment"%>
<%@page import="com.hipzi.model.ClassroomExam"%>
<%@page import="com.hipzi.model.ClassroomExamQuestion"%>
<%@page import="com.hipzi.model.ClassroomHomeworkSubmission"%>
<%@page import="com.hipzi.model.ClassroomMaterial"%>
<%@page import="com.hipzi.model.ClassroomQuiz"%>
<%@page import="com.hipzi.model.ClassroomQuizAttempt"%>
<%@page import="com.hipzi.model.ClassroomQuizQuestion"%>
<%@page import="com.hipzi.dto.ClassroomExamAttemptDto"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="java.util.Map"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.text.SimpleDateFormat"%>
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

    private String formatExamTime(Timestamp value) {
        return value != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(value) : "Chưa thiết lập";
    }

    private String examDatePart(String value) {
        return value != null && value.length() >= 10 ? value.substring(0, 10) : "";
    }

    private String examHourPart(String value) {
        return value != null && value.length() >= 13 ? value.substring(11, 13) : "";
    }

    private String examMinutePart(String value) {
        return value != null && value.length() >= 16 ? value.substring(14, 16) : "";
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
    Map<String, ClassroomExamAttemptDto> classExamAttemptUsage = (Map<String, ClassroomExamAttemptDto>) request.getAttribute("classExamAttemptUsage");

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
    Timestamp currentTimestamp = new Timestamp(System.currentTimeMillis());
    String quizDraftTitle = (String) session.getAttribute("quizDraftTitle");
    String quizDraftDescription = (String) session.getAttribute("quizDraftDescription");
    String quizDraftScanText = (String) session.getAttribute("quizDraftScanText");
    List<ClassroomQuizQuestion> quizDraftQuestions = (List<ClassroomQuizQuestion>) session.getAttribute("quizDraftQuestions");
    session.removeAttribute("quizDraftTitle");
    session.removeAttribute("quizDraftDescription");
    session.removeAttribute("quizDraftScanText");
    session.removeAttribute("quizDraftQuestions");
    String examDraftTitle = (String) session.getAttribute("examDraftTitle");
    String examDraftCode = (String) session.getAttribute("examDraftCode");
    String examDraftDescription = (String) session.getAttribute("examDraftDescription");
    String examDraftType = (String) session.getAttribute("examDraftType");
    String examDraftStartAt = (String) session.getAttribute("examDraftStartAt");
    String examDraftEndAt = (String) session.getAttribute("examDraftEndAt");
    Number examDraftDurationValue = (Number) session.getAttribute("examDraftDuration");
    Number examDraftAttemptLimitValue = (Number) session.getAttribute("examDraftAttemptLimit");
    Number examDraftMaxScoreValue = (Number) session.getAttribute("examDraftMaxScore");
    String examDraftSourceMaterialId = (String) session.getAttribute("examDraftSourceMaterialId");
    String examDraftSourceText = (String) session.getAttribute("examDraftSourceText");
    String examDraftCreationMode = (String) session.getAttribute("examDraftCreationMode");
    List<ClassroomExamQuestion> examDraftQuestions = (List<ClassroomExamQuestion>) session.getAttribute("examDraftQuestions");
    session.removeAttribute("examDraftTitle");
    session.removeAttribute("examDraftCode");
    session.removeAttribute("examDraftDescription");
    session.removeAttribute("examDraftType");
    session.removeAttribute("examDraftStartAt");
    session.removeAttribute("examDraftEndAt");
    session.removeAttribute("examDraftDuration");
    session.removeAttribute("examDraftAttemptLimit");
    session.removeAttribute("examDraftMaxScore");
    session.removeAttribute("examDraftSourceMaterialId");
    session.removeAttribute("examDraftSourceText");
    session.removeAttribute("examDraftCreationMode");
    session.removeAttribute("examDraftQuestions");
    examDraftTitle = examDraftTitle != null ? examDraftTitle : "";
    examDraftCode = examDraftCode != null ? examDraftCode : "";
    examDraftDescription = examDraftDescription != null ? examDraftDescription : "";
    examDraftType = "essay".equals(examDraftType) ? "essay" : "multiple_choice";
    examDraftStartAt = examDraftStartAt != null ? examDraftStartAt : "";
    examDraftEndAt = examDraftEndAt != null ? examDraftEndAt : "";
    int examDraftDuration = examDraftDurationValue != null ? examDraftDurationValue.intValue() : 45;
    int examDraftAttemptLimit = examDraftAttemptLimitValue != null ? examDraftAttemptLimitValue.intValue() : 1;
    double examDraftMaxScore = examDraftMaxScoreValue != null ? examDraftMaxScoreValue.doubleValue() : 10.0;
    examDraftSourceMaterialId = examDraftSourceMaterialId != null ? examDraftSourceMaterialId : "";
    examDraftSourceText = examDraftSourceText != null ? examDraftSourceText : "";
    examDraftCreationMode = "ai".equals(examDraftCreationMode) ? "ai" : "manual";
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        body {
            min-height: 100vh;
            color: #0f172a;
        }

        .classroom-shell {
            width: 100%;
            max-width: 1400px;
            margin: 0 auto;
            padding: max(0.75rem, calc(7rem - 70px)) 1.25rem 4rem;
            box-sizing: border-box;
        }

        .classroom-hero {
            position: relative;
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(260px, 0.38fr);
            gap: 2rem;
            align-items: stretch;
            min-height: 330px;
            padding: 100px 3.25rem calc(3rem + 40px);
            border: 1px solid rgba(203, 213, 225, 0.72);
            border-radius: 1.15rem;
            background:
                linear-gradient(90deg, rgba(255, 255, 255, 0.28), rgba(255, 255, 255, 0.16) 45%, rgba(240, 253, 250, 0.12)),
                url('${pageContext.request.contextPath}/assets/images/classroom-hero.png') center / cover no-repeat,
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
            position: static;
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
            color: #059669;
            transform: translateX(-2px);
        }

        .online-room-btn {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: max-content;
            min-width: 0;
            border-radius: 999px;
            position: absolute;
            left: 49px;
            bottom: 32px;
            z-index: 2;
            margin-top: 0;
            padding: 0.78rem 1.25rem;
            background: #059669;
            color: #ffffff;
            font-weight: 950;
            text-decoration: none;
            box-shadow: 0 14px 30px rgba(5, 150, 105, 0.22);
            transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
        }

        .online-room-btn:hover {
            transform: translateY(-1px);
            background: #047857;
            box-shadow: 0 18px 38px rgba(5, 150, 105, 0.28);
        }

        .classroom-teacher-card {
            display: grid;
            place-items: center;
            min-height: auto;
            border: 0;
            border-radius: 0;
            padding: 0;
            background: transparent;
            box-shadow: none;
            animation: teacherAvatarIn 700ms ease both;
        }

        .classroom-teacher-photo {
            align-self: center;
            justify-self: center;
            width: min(255px, 66.3%);
            aspect-ratio: 1;
            border-radius: 999px;
            padding: 0.45rem;
            background: linear-gradient(135deg, #059669, #ccfbf1);
            box-shadow: 0 24px 54px rgba(5, 150, 105, 0.18);
            animation: teacherAvatarFloat 4.8s ease-in-out infinite alternate;
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
            color: #059669;
            font-size: 3.2rem;
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
            width: 100%;
            box-sizing: border-box;
        }

        .classroom-tab-list {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            overflow-x: auto;
            padding: 0.8rem;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            border-radius: 1.1rem 1.1rem 0 0;
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

        @keyframes teacherAvatarIn {
            from { opacity: 0; transform: translateY(12px) scale(0.96); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        @keyframes teacherAvatarFloat {
            from { transform: translateY(-4px); }
            to { transform: translateY(8px); }
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
            background: #d1fae5;
            color: #059669;
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

        .student-card-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 1rem;
        }

        @media (max-width: 1024px) {
            .student-card-grid {
                grid-template-columns: repeat(4, minmax(0, 1fr));
            }
        }

        @media (max-width: 768px) {
            .student-card-grid {
                grid-template-columns: repeat(3, minmax(0, 1fr));
            }
        }

        @media (max-width: 480px) {
            .student-card-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        .student-card {
            display: grid;
            grid-template-columns: auto 1fr;
            align-items: center;
            text-align: left;
            gap: 0.5rem 0.85rem;
            padding: 1.15rem 1rem;
            border-radius: 1rem;
            background: #f8fafc;
            border: 1px solid #edf2f7;
            position: relative;
            transition: all 0.2s ease;
        }

        .student-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            transform: translateY(-2px);
            border-color: #e2e8f0;
        }

        .student-card .student-avatar {
            width: 44px;
            height: 44px;
            font-size: 1.1rem;
            margin-bottom: 0;
            grid-row: 1;
            grid-column: 1;
        }

        .student-card strong {
            color: #0f172a;
            font-size: 0.95rem;
            margin-bottom: 0;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.3;
            grid-row: 1;
            grid-column: 2;
            padding-right: 1.5rem; /* Space for the absolute positioned remove button */
        }

        .student-card .review-actions {
            margin-top: 0.5rem;
            display: flex;
            gap: 0.5rem;
            width: 100%;
            justify-content: center;
            grid-row: 2;
            grid-column: 1 / span 2;
        }

        .student-card .review-actions form {
            flex: 1;
        }

        .student-card .review-actions .mini-btn {
            width: 100%;
            padding: 0.4rem;
        }

        .student-card-remove {
            position: absolute;
            top: 0.4rem;
            right: 0.4rem;
            background: transparent;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            width: 28px;
            height: 28px;
            display: grid;
            place-items: center;
            border-radius: 999px;
            transition: all 0.2s ease;
        }

        .student-card-remove:hover {
            background: #fee2e2;
            color: #ef4444;
        }

        .review-actions {
            display: flex;
            gap: 0.4rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .mini-btn {
            box-sizing: border-box;
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
            transition: all 0.2s ease;
        }

        .mini-btn:hover {
            border-color: #059669;
            color: #059669;
            background: #ecfdf5;
        }

        .mini-btn.primary {
            background: #059669;
            border-color: #059669;
            color: #ffffff;
        }

        .mini-btn.primary:hover {
            background: #047857 !important;
            border-color: #047857 !important;
        }

        .mini-btn.preview {
            border-color: #bbf7d0;
            background: #f0fdf4;
            color: #15803d;
        }

        .mini-btn.danger {
            background: #ef4444;
            border-color: #ef4444;
            color: #ffffff;
        }

        .mini-btn.danger:hover {
            background: #dc2626 !important;
            border-color: #dc2626 !important;
            color: #ffffff;
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
            padding: 0.2rem 0.4rem;
            background: #f4fdf8;
            color: #047857;
            font-size: 0.72rem;
            font-weight: 600;
        }

        .resource-actions {
            display: flex;
            gap: 0.45rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .class-exam-summary {
            display: grid;
            gap: 0.9rem;
            margin-bottom: 1rem;
        }

        .class-exam-summary-head {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .class-exam-summary-head h3 {
            margin: 0;
            color: #0f172a;
            font-size: 1.02rem;
        }

        .class-exam-summary-head p {
            margin: 0.18rem 0 0;
            color: #64748b;
            font-size: 0.86rem;
            line-height: 1.55;
        }

        .class-exam-total {
            display: inline-flex;
            align-items: center;
            margin-left: auto;
            border-radius: 999px;
            padding: 0.42rem 0.7rem;
            background: #ecfdf5;
            color: #047857;
            font-size: 0.78rem;
            font-weight: 950;
            white-space: nowrap;
        }

        .class-exam-card-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.2rem;
        }
        
        @media (max-width: 768px) {
            .class-exam-card-grid {
                grid-template-columns: 1fr;
            }
        }

        .class-exam-card {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 1.25rem;
            min-width: 0;
            padding: 1.4rem 1.6rem;
            border: 1px solid #dceee9;
            border-radius: 0.95rem;
            background:
                radial-gradient(circle at top right, rgba(94, 234, 212, 0.12), transparent 36%),
                #ffffff;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
        }

        .class-exam-card-left {
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
            flex: 1 1 auto;
        }

        .class-exam-card-right {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: space-between;
            gap: 1.25rem;
            align-self: stretch;
            flex: 0 0 auto;
        }

        @media (max-width: 600px) {
            .class-exam-card-right {
                align-items: flex-start;
                align-self: auto;
                width: 100%;
            }
        }

        .class-exam-card-head {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 0.5rem;
        }

        .class-exam-code {
            display: inline-flex;
            align-items: center;
            align-self: flex-start;
            font-size: 0.88rem;
            color: #475569;
            font-weight: 600;
        }

        .class-exam-code strong {
            background: #f1f5f9;
            border-radius: 6px;
            padding: 0.2rem 0.5rem;
            line-height: 1.25;
            margin-left: -0.5rem;
            font-weight: 700;
        }

        .class-exam-attempt-badge {
            flex-shrink: 0;
            border-radius: 999px;
            padding: 0.34rem 0.62rem;
            background: #eef2ff;
            color: #4338ca;
            font-size: 0.72rem;
            font-weight: 950;
            white-space: nowrap;
        }

        .class-exam-card h3 {
            margin: 0;
            color: #0f172a;
            font-size: 1.08rem;
            line-height: 1.35;
        }

        .class-exam-card p {
            margin: 0.28rem 0 0;
            color: #64748b;
            font-size: 0.86rem;
            line-height: 1.55;
        }

        .class-exam-status {
            flex-shrink: 0;
            border-radius: 999px;
            padding: 0.34rem 0.62rem;
            background: #dcfce7;
            color: #166534;
            font-size: 0.72rem;
            font-weight: 950;
            white-space: nowrap;
        }

        .class-exam-status.upcoming {
            background: #fef3c7;
            color: #b45309;
        }

        .class-exam-status.closed {
            background: #fee2e2;
            color: #b91c1c;
        }

        .class-exam-status.draft {
            background: #f1f5f9;
            color: #475569;
        }

        .class-exam-meta {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 0.85rem;
        }

        .class-exam-actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-top: auto;
        }

        @media (max-width: 600px) {
            .class-exam-actions {
                width: 100%;
            }
        }

        .class-exam-actions .mini-btn {
            padding: 0.45rem 0.9rem;
            font-size: 0.93rem;
        }

        .classroom-section-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-bottom: 0.9rem;
        }

        .classroom-section-heading h2 {
            margin: 0;
        }

        .upload-panel {
            border: 1px solid #e2e8f0;
            border-radius: 0.9rem;
            background: #f8fafc;
            padding: 1rem;
            margin-bottom: 1rem;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.03);
        }

        .upload-panel h3 {
            margin: 0 0 0.8rem;
            font-size: 0.98rem;
            color: #0f172a;
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

        .exam-datetime-fields {
            display: flex;
            flex-wrap: nowrap;
            align-items: center;
            gap: 0.4rem;
            min-width: 0;
        }

        .exam-datetime-fields input[type="date"] {
            flex: 1 1 90px;
            min-width: 90px;
            padding-left: 0.3rem;
            padding-right: 0.2rem;
        }

        .exam-datetime-fields select {
            flex: 0 0 62px;
            width: 62px;
            text-align: center;
            padding-left: 0.15rem;
            padding-right: 0.15rem;
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
            border: 1px solid #cbd5e1;
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

        .exam-builder-shell {
            gap: 0;
            padding: 0;
            border-color: #e5eeec;
            border-radius: 1.25rem;
            background: #ffffff;
            box-shadow: 0 14px 34px rgba(15, 23, 42, 0.06);
        }

        .exam-builder-shell .upload-grid {
            row-gap: 1.1rem;
            column-gap: 0.95rem;
        }

        .exam-builder-shell .upload-field {
            gap: 0.5rem;
        }

        .exam-builder-heading {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            padding: 1.25rem 1.35rem;
            border-bottom: 1px solid #dceee9;
            border-radius: 1.25rem 1.25rem 0 0;
            background:
                radial-gradient(circle at top right, rgba(94, 234, 212, 0.24), transparent 34%),
                linear-gradient(135deg, #f0fdfa 0%, #f8fffd 58%, #eff6ff 100%);
        }

        .exam-builder-heading h3 {
            margin: 0.2rem 0 0.35rem;
            color: #0f172a;
            font-size: 1.18rem;
        }

        .exam-builder-heading p,
        .exam-section-heading p,
        .exam-mode-description {
            margin: 0;
            color: #64748b;
            font-size: 0.82rem;
            line-height: 1.55;
        }

        .exam-builder-eyebrow {
            color: #059669;
            font-size: 0.68rem;
            font-weight: 950;
            letter-spacing: 0.14em;
        }

        .exam-builder-step-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            flex: 0 0 auto;
            border: 1px solid #a7f3d0;
            border-radius: 999px;
            padding: 0.65rem 1.25rem;
            background: #ffffff;
            color: #059669;
            font-size: 1.1rem;
            font-weight: 950;
            box-shadow: 0 4px 12px rgba(5, 150, 105, 0.08);
        }

        .exam-builder-step-pill::before {
            width: 10px;
            height: 10px;
            border-radius: 999px;
            background: #10b981;
            content: "";
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.16);
        }

        .exam-builder-section {
            padding: 1.45rem 1.35rem;
            border-bottom: 0;
        }

        .exam-builder-section + .exam-builder-section {
            padding-top: 1.65rem;
        }

        .exam-section-heading {
            display: flex;
            align-items: flex-start;
            gap: 0.7rem;
            margin-bottom: 1.15rem;
        }

        .exam-section-heading strong {
            display: block;
            margin-bottom: 0.15rem;
            color: #0f172a;
            font-size: 0.9rem;
        }

        .exam-section-number {
            display: grid;
            width: 30px;
            height: 30px;
            flex: 0 0 auto;
            place-items: center;
            border-radius: 0.65rem;
            background: #ccfbf1;
            color: #059669;
            font-size: 0.72rem;
            font-weight: 950;
        }

        .exam-mode-native {
            position: absolute;
            width: 1px;
            height: 1px;
            overflow: hidden;
            clip: rect(0 0 0 0);
            clip-path: inset(50%);
            white-space: nowrap;
        }

        .exam-mode-picker {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.85rem;
        }

        .exam-mode-card {
            display: grid;
            grid-template-columns: 48px minmax(0, 1fr) auto;
            gap: 0.8rem;
            align-items: center;
            min-height: 104px;
            border: 1px solid transparent;
            border-radius: 1rem;
            padding: 0.95rem;
            background: #f8fafc;
            color: #0f172a;
            cursor: pointer;
            font-family: inherit;
            text-align: left;
            transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease, background 0.2s ease;
        }

        .exam-mode-card:hover {
            border-color: #ccfbf1;
            transform: translateY(-2px);
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.1);
        }

        .exam-mode-card.active {
            border-color: #5eead4;
            background: linear-gradient(135deg, #f0fdfa, #f8fffd);
            box-shadow: 0 10px 22px rgba(5, 150, 105, 0.1);
        }

        .exam-mode-card-icon {
            display: grid;
            width: 48px;
            height: 48px;
            place-items: center;
            border-radius: 0.9rem;
            background: #f1f5f9;
            color: #475569;
        }

        .exam-mode-card.active .exam-mode-card-icon {
            background: #ccfbf1;
            color: #059669;
        }

        .exam-mode-card-icon svg {
            width: 23px;
            height: 23px;
        }

        .exam-mode-card strong {
            display: block;
            margin-bottom: 0.2rem;
            font-size: 0.9rem;
        }

        .exam-mode-description {
            display: block;
        }

        .exam-mode-check {
            display: grid;
            width: 22px;
            height: 22px;
            place-items: center;
            border: 1px solid #cbd5e1;
            border-radius: 999px;
            color: transparent;
            font-size: 0.7rem;
            font-weight: 950;
        }

        .exam-mode-card.active .exam-mode-check {
            border-color: #10b981;
            background: #059669;
            color: #ffffff;
        }

        .exam-ai-section {
            margin: 0 0.9rem;
            border-radius: 1rem;
            background:
                radial-gradient(circle at top right, rgba(45, 212, 191, 0.12), transparent 30%),
                #f8fffd;
        }

        .exam-ai-heading {
            gap: 0.85rem;
            margin-bottom: 1rem;
        }

        .exam-ai-heading .exam-section-number {
            width: 40px;
            height: 40px;
            border-radius: 0.85rem;
            background: linear-gradient(135deg, #99f6e4, #ccfbf1);
            box-shadow: 0 8px 18px rgba(5, 150, 105, 0.14);
            font-size: 0.78rem;
        }

        .exam-ai-heading strong {
            margin-bottom: 0.22rem;
            color: #0f172a;
            font-size: 1.05rem;
        }

        .exam-ai-workspace {
            padding: 0;
            border: 0;
            background: transparent;
        }

        .exam-ai-textarea {
            min-height: 238px;
            max-height: 320px;
            resize: vertical;
            line-height: 1.55;
        }

        .exam-builder-shell .upload-field input,
        .exam-builder-shell .upload-field select,
        .exam-builder-shell .upload-field textarea {
            padding-top: 0.88rem;
            padding-bottom: 0.88rem;
            border-color: #e2e8f0;
            background: rgba(255, 255, 255, 0.94);
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .exam-builder-shell .upload-field input:focus,
        .exam-builder-shell .upload-field select:focus,
        .exam-builder-shell .upload-field textarea:focus {
            border-color: #5eead4;
            box-shadow: 0 0 0 3px rgba(45, 212, 191, 0.12);
        }

        .exam-ai-upload-input {
            position: absolute;
            width: 1px;
            height: 1px;
            overflow: hidden;
            clip: rect(0 0 0 0);
            clip-path: inset(50%);
            white-space: nowrap;
        }

        .exam-ai-upload-card {
            display: grid;
            min-height: 238px;
            place-items: center;
            border: 1.5px dashed #a7f3d0;
            border-radius: 0.9rem;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.62);
            color: #475569;
            cursor: pointer;
            text-align: center;
            transition: border-color 0.2s ease, background 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
        }

        .exam-ai-upload-card:hover,
        .exam-ai-upload-card.dragging {
            border-color: #10b981;
            background: #f0fdfa;
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.12);
            transform: translateY(-2px);
        }

        .exam-ai-upload-empty {
            display: grid;
            justify-items: center;
            gap: 0.42rem;
        }

        .exam-ai-upload-icon {
            display: grid;
            width: 54px;
            height: 54px;
            place-items: center;
            border-radius: 1rem;
            background: #ccfbf1;
            color: #059669;
        }

        .exam-ai-upload-icon svg {
            width: 27px;
            height: 27px;
        }

        .exam-ai-upload-empty strong {
            color: #0f172a;
            font-size: 0.9rem;
        }

        .exam-ai-upload-empty span {
            color: #64748b;
            font-size: 0.76rem;
            line-height: 1.5;
        }

        .exam-ai-upload-empty em {
            border-radius: 999px;
            padding: 0.38rem 0.7rem;
            background: #ecfdf5;
            color: #047857;
            font-size: 0.72rem;
            font-style: normal;
            font-weight: 900;
        }

        .exam-ai-upload-card img {
            width: 100%;
            max-height: 192px;
            object-fit: contain;
        }

        .exam-ai-upload-preview {
            display: grid;
            width: 100%;
            gap: 0.55rem;
            justify-items: center;
        }

        .exam-ai-upload-preview span {
            max-width: 100%;
            overflow: hidden;
            color: #059669;
            font-size: 0.75rem;
            font-weight: 850;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .quiz-actions.exam-ai-actions {
            justify-content: center;
            margin-top: 0.75rem;
        }

        .exam-ai-action-group {
            display: grid;
            gap: 0.38rem;
            justify-items: center;
        }

        .exam-ai-submit {
            gap: 0.42rem;
            border-color: #059669;
            padding: 0.72rem 1.25rem;
            background: linear-gradient(135deg, #059669, #047857);
            color: #ffffff;
            box-shadow: 0 10px 20px rgba(5, 150, 105, 0.2);
            transition: transform 0.15s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.15s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .exam-ai-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 14px 26px rgba(5, 150, 105, 0.26);
            color: #ffffff;
            background: linear-gradient(135deg, #059669, #047857);
            border-color: #059669;
        }

        .exam-ai-submit:active {
            transform: scale(0.96) translateY(0);
            box-shadow: 0 4px 10px rgba(5, 150, 105, 0.15);
        }

        .exam-ai-submit svg {
            width: 17px;
            height: 17px;
        }

        .exam-ai-note {
            color: #64748b;
            font-size: 0.78rem;
            font-weight: 700;
            text-align: right;
        }

        .quiz-card.exam-question-workspace {
            padding: 0;
            padding-bottom: 2.25rem;
            border: 0;
            background: transparent;
        }

        .exam-question-workspace .quiz-question {
            position: relative;
            border: 0;
            border-left: 3px solid #99f6e4;
            border-radius: 0.35rem 0.8rem 0.8rem 0.35rem;
            background: #f8fafc;
            box-shadow: none;
        }

        .exam-question-workspace .quiz-question[data-removable-exam-question] {
            padding-right: 3.2rem;
        }

        .exam-question-remove {
            position: absolute;
            top: 0.7rem;
            right: 0.7rem;
            width: 32px;
            height: 32px;
            padding: 0;
            border-color: #fecaca;
            background: #fff7f7;
            color: #b91c1c;
            font-size: 1.1rem;
            line-height: 1;
            z-index: 2;
        }

        .exam-question-remove:hover {
            border-color: #ef4444;
            background: #fef2f2;
            color: #991b1b;
        }

        .exam-question-workspace .quiz-actions {
            margin-top: calc(0.9rem + 35px);
            margin-bottom: 1rem;
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

        .math-preview {
            display: none;
            margin-top: 0;
            padding: 0.88rem 0.85rem;
            border: 1px solid #e2e8f0;
            border-radius: 0.72rem;
            background: rgba(255, 255, 255, 0.94);
            color: #0f172a;
            cursor: default;
            font-size: 1rem;
            font-weight: 400;
            letter-spacing: 0;
            line-height: 1.45;
            min-height: 3.05rem;
            overflow-x: auto;
            white-space: normal;
        }

        .math-preview.visible {
            display: block;
        }

        .math-source-hidden {
            display: none !important;
        }

        .math-preview:focus {
            border-color: #5eead4;
            box-shadow: 0 0 0 3px rgba(45, 212, 191, 0.12);
            outline: none;
        }

        .quiz-option-grid label .math-preview {
            font-weight: 400;
        }

        .quiz-option-grid .math-preview {
            min-height: 3.08rem;
            padding-top: 0.76rem;
            padding-bottom: 0.76rem;
        }

        .math-root {
            display: inline-flex;
            align-items: flex-start;
            white-space: nowrap;
            margin: 0 0.08rem;
            vertical-align: -0.12em;
        }

        .math-root-index {
            min-width: 0.55em;
            margin-right: -0.08em;
            color: #334155;
            font-size: 0.65em;
            font-weight: 500;
            line-height: 1;
            text-align: right;
            transform: translate(0.16em, -0.34em);
        }

        .math-root-symbol {
            font-size: 1.12em;
            font-weight: 400;
            line-height: 1.05;
        }

        .math-root-radicand {
            min-height: 1.12em;
            margin-top: 0.08em;
            padding: 0.02em 0.22em 0;
            border-top: 1.5px solid currentColor;
            line-height: 1.15;
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
            justify-content: flex-end;
            margin-top: 0.9rem;
        }

        .exam-add-btn {
            border-color: #a7f3d0 !important;
            background: #ecfdf5 !important;
            color: #047857 !important;
        }

        .exam-create-btn {
            border-color: #059669 !important;
            background: #059669 !important;
            color: #ffffff !important;
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
            color: #059669;
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
                min-height: auto;
                padding: 2rem;
            }

            .classroom-teacher-card {
                order: -1;
            }

            .classroom-teacher-photo {
                width: min(190px, 62%);
            }

            .online-room-btn {
                position: static;
                margin-top: 1rem;
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
            .class-exam-card-grid,
            .upload-grid,
            .quiz-scan-preview,
            .quiz-card-head,
            .quiz-option-grid,
            .exam-mode-picker {
                grid-template-columns: 1fr;
            }

            .class-exam-card-head {
                display: grid;
            }

            .class-exam-actions {
                justify-content: flex-start;
            }

            .exam-builder-heading {
                display: grid;
            }

            .exam-mode-card {
                grid-template-columns: 44px minmax(0, 1fr) auto;
            }

            .exam-mode-card-icon {
                width: 44px;
                height: 44px;
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

                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes" class="active">Lớp học</a></li>


                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
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
                <a class="online-room-btn" href="<%= h(onlineRoomHref) %>" target="_blank" rel="noopener">Vào phòng học online</a>
            </div>
            <aside class="classroom-teacher-card" aria-label="Thông tin giảng viên">
                <div class="classroom-teacher-photo">
                    <% if (!teacherAvatarUrl.isEmpty()) { %>
                        <img src="<%= h(teacherAvatarUrl) %>" alt="">
                    <% } else { %>
                        <div class="classroom-teacher-placeholder"><%= h(teacherName.substring(0, 1).toUpperCase()) %></div>
                    <% } %>
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
                        <div class="student-card-grid">
                            <% if (pendingEnrollments == null || pendingEnrollments.isEmpty()) { %>
                                <div class="empty-state" style="grid-column: 1 / -1;">Hiện chưa có học viên nào đang chờ duyệt.</div>
                            <% } else {
                                for (ClassroomEnrollment enrollment : pendingEnrollments) {
                                    String name = enrollment.getStudentName() != null && !enrollment.getStudentName().isEmpty() ? enrollment.getStudentName() : "Học viên";
                            %>
                                <div class="student-card">
                                    <div class="student-avatar"><%= h(name.substring(0, 1).toUpperCase()) %></div>
                                    <strong><%= h(name) %></strong>
                                    <div class="review-actions">
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST">
                                            <input type="hidden" name="action" value="reviewEnrollment">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="enrollmentId" value="<%= h(enrollment.getId()) %>">
                                            <input type="hidden" name="decision" value="accepted">
                                            <button class="mini-btn primary" type="submit">Duyệt</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/classroom" method="POST">
                                            <input type="hidden" name="action" value="reviewEnrollment">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="enrollmentId" value="<%= h(enrollment.getId()) %>">
                                            <input type="hidden" name="decision" value="rejected">
                                            <button class="mini-btn danger" type="submit">Hủy</button>
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
                    <div class="student-card-grid">
                        <% if (acceptedEnrollments == null || acceptedEnrollments.isEmpty()) { %>
                            <div class="empty-state" style="grid-column: 1 / -1;">Danh sách học viên trong lớp đang trống.</div>
                        <% } else {
                            for (ClassroomEnrollment enrollment : acceptedEnrollments) {
                                String name = enrollment.getStudentName() != null && !enrollment.getStudentName().isEmpty() ? enrollment.getStudentName() : "Học viên";
                        %>
                            <div class="student-card">
                                <% if (canReviewEnrollments) { %>
                                    <form action="${pageContext.request.contextPath}/classroom" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn xóa học viên này khỏi lớp?');">
                                        <input type="hidden" name="action" value="reviewEnrollment">
                                        <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                        <input type="hidden" name="enrollmentId" value="<%= h(enrollment.getId()) %>">
                                        <input type="hidden" name="decision" value="rejected">
                                        <button class="student-card-remove" type="submit" title="Xóa khỏi lớp">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                        </button>
                                    </form>
                                <% } %>
                                <div class="student-avatar"><%= h(name.substring(0, 1).toUpperCase()) %></div>
                                <strong><%= h(name) %></strong>
                            </div>
                        <%  }
                        } %>
                    </div>
                </section>

                <section class="classroom-card classroom-tab-panel" data-classroom-panel="materials">
                    <div class="classroom-section-heading">
                        <h2>Tài liệu lớp học</h2>
                        <% if (canManageClassroom) { %>
                            <button class="mini-btn primary" type="button" data-upload-toggle="class-material-upload" aria-controls="class-material-upload" aria-expanded="false">Đăng tải tài liệu</button>
                        <% } %>
                    </div>
                    <% if (canManageClassroom) { %>
                        <form class="upload-panel" id="class-material-upload" action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data" hidden>
                            <input type="hidden" name="action" value="uploadClassMaterial">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <h3>Đăng tải tài liệu</h3>
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
                    <div class="classroom-section-heading">
                        <h2>Bài tập về nhà</h2>
                        <% if (canManageClassroom) { %>
                            <button class="mini-btn primary" type="button" data-upload-toggle="class-homework-upload" aria-controls="class-homework-upload" aria-expanded="false">Đăng bài tập về nhà</button>
                        <% } %>
                    </div>
                    <% if (canManageClassroom) { %>
                        <form class="upload-panel" id="class-homework-upload" action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data" hidden>
                            <input type="hidden" name="action" value="uploadClassMaterial">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <input type="hidden" name="materialCategory" value="homework">
                            <h3>Đăng bài tập về nhà</h3>
                            <div class="upload-grid">
                                <div class="upload-field full">
                                    <label>Tiêu đề bài tập</label>
                                    <input type="text" name="materialTitle" placeholder="Ví dụ: Bài tập chương 1" required>
                                </div>
                                <div class="upload-field full">
                                    <label>Mô tả</label>
                                    <textarea name="materialDescription" rows="2" placeholder="Ghi chú yêu cầu bài tập cho học viên..."></textarea>
                                </div>
                                <div class="upload-field full">
                                    <label>File bài tập</label>
                                    <input type="file" name="materialFile" accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp" required>
                                </div>
                            </div>
                            <div class="review-actions" style="margin-top:0.85rem;">
                                <button class="mini-btn primary" type="submit">Đăng bài tập</button>
                            </div>
                        </form>
                    <% } %>
                    <div class="resource-list">
                        <% if (classHomework == null || classHomework.isEmpty()) { %>
                            <div class="empty-state">Chưa có bài tập về nhà nào được đăng tải cho lớp này.</div>
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


                <section class="classroom-card classroom-tab-panel" data-classroom-panel="exams">
                    <h2>Phòng thi lớp học</h2>
                    <div class="class-exam-summary">
                        <div class="class-exam-summary-head">
                            <span class="class-exam-total"><%= examCount %> bài thi</span>
                        </div>
                        <% if (classroomExams == null || classroomExams.isEmpty()) { %>
                            <div class="empty-state"><%= canManageClassroom ? "Chưa có bài thi lớp học nào. Hãy thiết lập đề thi đầu tiên cho lớp." : "Lớp chưa có bài thi nào được giảng viên mở." %></div>
                        <% } else { %>
                            <div class="class-exam-card-grid">
                                <% for (ClassroomExam exam : classroomExams) {
                                    String examHref = request.getContextPath()
                                            + "/class-exam-room?classId=" + u(classroom.getId())
                                            + "&code=" + u(exam.getExamCode());
                                    String manageHref = request.getContextPath()
                                            + "/class-exam-manage?classId=" + u(classroom.getId())
                                            + "&code=" + u(exam.getExamCode());
                                    boolean isExamOpenNow = "open".equals(exam.getStatus())
                                            && exam.getStartAt() != null
                                            && exam.getEndAt() != null
                                            && !currentTimestamp.before(exam.getStartAt())
                                            && !currentTimestamp.after(exam.getEndAt());
                                    boolean isExamUpcoming = "open".equals(exam.getStatus())
                                            && exam.getStartAt() != null
                                            && currentTimestamp.before(exam.getStartAt());
                                    String examStatusClass = "draft".equals(exam.getStatus()) ? "draft" : (isExamOpenNow ? "" : (isExamUpcoming ? "upcoming" : "closed"));
                                    String examStatusLabel = "draft".equals(exam.getStatus()) ? "Bản nháp" : (isExamOpenNow ? "Đang mở" : (isExamUpcoming ? "Chưa mở" : "Đã đóng"));
                                    ClassroomExamAttemptDto examUsage = classExamAttemptUsage != null ? classExamAttemptUsage.get(exam.getId()) : null;
                                    int usedAttempts = examUsage != null ? examUsage.getAttemptCount() : 0;
                                    int allowedAttempts = examUsage != null ? examUsage.getAllowedAttemptCount() : Math.max(1, exam.getAttemptLimit());
                                    boolean hasActiveAttempt = examUsage != null && examUsage.getAttempt() != null && "in_progress".equals(examUsage.getAttempt().getStatus());
                                    boolean outOfAttempts = usedAttempts >= allowedAttempts && !hasActiveAttempt;
                                %>
                                    <article class="class-exam-card">
                                        <div class="class-exam-card-left">
                                            <div class="class-exam-card-head">
                                                <h3><%= h(exam.getTitle()) %></h3>
                                                <span class="class-exam-code"><strong>Mã đề: <%= h(exam.getExamCode()) %></strong></span>
                                            </div>
                                            <div class="class-exam-meta">
                                                <span class="resource-chip" style="background:transparent; padding:0; color:#475569; font-weight:500; font-size: 0.95rem;">Mở: <%= h(formatExamTime(exam.getStartAt())) %></span>
                                                <span class="resource-chip" style="background:transparent; padding:0; color:#475569; font-weight:500; font-size: 0.95rem;">Đóng: <%= h(formatExamTime(exam.getEndAt())) %></span>
                                            </div>
                                        </div>
                                        <div class="class-exam-card-right">
                                            <div style="display: flex; align-items: center; justify-content: flex-end; gap: 0.6rem; width: 100%;">
                                                <% if (!canManageClassroom) { %>
                                                    <span class="class-exam-attempt-badge">Lượt làm: <%= usedAttempts %>/<%= allowedAttempts %></span>
                                                <% } %>
                                                <span class="class-exam-status <%= h(examStatusClass) %>"><%= h(examStatusLabel) %></span>
                                                <% if (canManageClassroom) { %>
                                                    <form action="${pageContext.request.contextPath}/classroom" method="POST" style="display:inline; margin:0; line-height: 1;" onsubmit="return confirm('Bạn chắc chắn muốn xóa bài thi này?');">
                                                        <input type="hidden" name="action" value="deleteClassExam">
                                                        <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                                        <input type="hidden" name="examId" value="<%= h(exam.getId()) %>">
                                                        <button type="submit" title="Xóa bài thi" style="background:none; border:none; padding:0; color:#ef4444; cursor:pointer; font-size:1.5rem; display:flex; align-items:center; justify-content:center; width:24px; height:24px; transition:color 0.2s; font-weight: bold;" onmouseover="this.style.color='#b91c1c'" onmouseout="this.style.color='#ef4444'">
                                                            &times;
                                                        </button>
                                                    </form>
                                                <% } %>
                                            </div>
                                            <div class="class-exam-actions">
                                                <% if (canManageClassroom) { %>
                                                    <a class="mini-btn primary" href="<%= h(manageHref) %>">Quản lý</a>
                                                <% } else { %>
                                                    <% if (outOfAttempts) { %>
                                                        <button type="button" class="mini-btn preview" disabled style="cursor:not-allowed; opacity:0.78;">Đã hết lượt làm bài</button>
                                                        <button type="button" class="mini-btn primary" disabled title="Phát triển sau" style="cursor:not-allowed; opacity:0.78;">Xem kết quả</button>
                                                    <% } else { %>
                                                        <button type="button" class="mini-btn primary" onclick="openExamRulesModal('<%= h(examHref + "&autoStart=true") %>')">Vào làm bài</button>
                                                    <% } %>
                                                <% } %>
                                                <% if (exam.getSourceMaterialId() != null && !exam.getSourceMaterialId().isEmpty()) { %>
                                                    <a class="mini-btn preview" href="${pageContext.request.contextPath}/classroom-preview?id=<%= h(exam.getSourceMaterialId()) %>" target="_blank" rel="noopener">Xem đề</a>
                                                <% } %>
                                                <% if (canManageClassroom) { %>
                                                    <button type="button" class="mini-btn preview" 
                                                            data-id="<%= h(exam.getId()) %>" 
                                                            data-title="<%= h(exam.getTitle()) %>"
                                                            data-code="<%= h(exam.getExamCode()) %>"
                                                            data-duration="<%= exam.getDurationMinutes() %>"
                                                            data-start-date="<%= h(examDatePart(exam.getStartAt() != null ? exam.getStartAt().toString() : "")) %>"
                                                            data-start-hour="<%= h(examHourPart(exam.getStartAt() != null ? exam.getStartAt().toString() : "")) %>"
                                                            data-start-minute="<%= h(examMinutePart(exam.getStartAt() != null ? exam.getStartAt().toString() : "")) %>"
                                                            data-end-date="<%= h(examDatePart(exam.getEndAt() != null ? exam.getEndAt().toString() : "")) %>"
                                                            data-end-hour="<%= h(examHourPart(exam.getEndAt() != null ? exam.getEndAt().toString() : "")) %>"
                                                            data-end-minute="<%= h(examMinutePart(exam.getEndAt() != null ? exam.getEndAt().toString() : "")) %>"
                                                            data-desc="<%= h(exam.getDescription()) %>"
                                                            style="background: #f0fdf4 !important; border-color: #bbf7d0 !important; color: #15803d !important; cursor: pointer;" 
                                                            onclick="openExamEditModal(this)">Chỉnh sửa</button>
                                                <% } %>
                                            </div>
                                        </div>
                                    </article>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                    <% if (canManageClassroom) { %>
                        <form class="upload-panel quiz-builder exam-builder-shell" action="${pageContext.request.contextPath}/classroom" method="POST" enctype="multipart/form-data" data-exam-builder novalidate>
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <div class="exam-builder-heading">
                                <span class="exam-builder-step-pill">Thiết lập đề thi mới</span>
                            </div>
                            <section class="exam-builder-section">
                                <div class="exam-section-heading">
                                    <span class="exam-section-number">01</span>
                                    <div>
                                        <strong>Chọn cách tạo câu hỏi</strong>
                                        <p>Nhập trực tiếp từng câu hoặc để AI đọc đề từ ảnh và văn bản.</p>
                                    </div>
                                </div>
                                <select class="exam-mode-native" name="examCreationMode" data-exam-mode aria-label="Cách tạo câu hỏi">
                                    <option value="manual" <%= "manual".equals(examDraftCreationMode) ? "selected" : "" %>>Nhập tay</option>
                                    <option value="ai" <%= "ai".equals(examDraftCreationMode) ? "selected" : "" %>>AI scan ảnh hoặc text</option>
                                </select>
                                <div class="exam-mode-picker">
                                    <button class="exam-mode-card" type="button" data-exam-mode-option="manual" aria-pressed="false">
                                        <span class="exam-mode-card-icon">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                <path d="M4 19.5V5a2 2 0 0 1 2-2h10l4 4v12.5a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 19.5Z"/>
                                                <path d="M15 3v5h5M8 12h8M8 16h6"/>
                                            </svg>
                                        </span>
                                        <span>
                                            <strong>Nhập tay</strong>
                                            <span class="exam-mode-description">Tự điền câu hỏi, đáp án và thang điểm theo từng câu.</span>
                                        </span>
                                        <span class="exam-mode-check">✓</span>
                                    </button>
                                    <button class="exam-mode-card" type="button" data-exam-mode-option="ai" aria-pressed="false">
                                        <span class="exam-mode-card-icon">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                <path d="M8 3H5a2 2 0 0 0-2 2v3M16 3h3a2 2 0 0 1 2 2v3M8 21H5a2 2 0 0 1-2-2v-3M16 21h3a2 2 0 0 0 2-2v-3"/>
                                                <path d="m12 7 .9 2.1L15 10l-2.1.9L12 13l-.9-2.1L9 10l2.1-.9L12 7ZM17 12l.5 1.2 1.2.5-1.2.5L17 15l-.5-.8-1.2-.5 1.2-.5L17 12Z"/>
                                            </svg>
                                        </span>
                                        <span>
                                            <strong>Scan bằng AI</strong>
                                            <span class="exam-mode-description">Tải ảnh hoặc dán text đề để AI điền trước nội dung.</span>
                                        </span>
                                        <span class="exam-mode-check">✓</span>
                                    </button>
                                </div>
                            </section>
                            <section class="exam-builder-section">
                                <div class="exam-section-heading">
                                    <span class="exam-section-number">02</span>
                                    <div>
                                        <strong>Thông tin bài thi</strong>
                                        <p>Thiết lập mã đề, thời lượng, thời gian mở đóng và loại câu hỏi trước khi soạn nội dung.</p>
                                    </div>
                                </div>
                                <div class="upload-grid">
                                    <div class="upload-field">
                                        <label>Tiêu đề bài thi</label>
                                        <input type="text" name="examTitle" placeholder="Ví dụ: Kiểm tra chương 1" value="<%= h(examDraftTitle) %>" required>
                                    </div>
                                    <div class="upload-field">
                                        <label>Mã đề</label>
                                        <input type="text" name="examCode" placeholder="VD: HIPZI-TOAN10-01" value="<%= h(examDraftCode) %>" required>
                                    </div>
                                    <div class="upload-field">
                                        <label>Thời lượng (phút)</label>
                                        <input type="number" name="durationMinutes" min="1" value="<%= examDraftDuration %>" required>
                                    </div>
                                    <div class="upload-field">
                                        <label>Tổng điểm tối đa</label>
                                        <input type="number" name="examMaxScore" id="createExamMaxScore" step="0.01" min="0" value="<%= examDraftMaxScore %>" required>
                                    </div>
                                    <div class="upload-field">
                                        <label>Dạng bài thi</label>
                                        <select name="examType" data-exam-type>
                                            <option value="multiple_choice" <%= "multiple_choice".equals(examDraftType) ? "selected" : "" %>>Trắc nghiệm</option>
                                            <option value="essay" <%= "essay".equals(examDraftType) ? "selected" : "" %>>Tự luận</option>
                                            <option value="flashcard" disabled>Flashcard (sắp triển khai)</option>
                                        </select>
                                    </div>
                                    <div class="upload-field">
                                        <label>Số lượt làm</label>
                                        <input type="number" name="attemptLimit" min="1" value="<%= examDraftAttemptLimit %>" required>
                                    </div>
                                    <div class="upload-field">
                                        <label>Thời gian mở đề</label>
                                        <div class="exam-datetime-fields" data-exam-datetime>
                                            <input type="date" name="examStartDate" value="<%= h(examDatePart(examDraftStartAt)) %>" required>
                                            <select name="examStartHour" aria-label="Giờ mở đề" required>
                                                <option value="">Giờ</option>
                                                <% for (int hour = 0; hour < 24; hour++) {
                                                    String hourValue = String.format("%02d", hour); %>
                                                    <option value="<%= hourValue %>" <%= hourValue.equals(examHourPart(examDraftStartAt)) ? "selected" : "" %>><%= hourValue %></option>
                                                <% } %>
                                            </select>
                                            <select name="examStartMinute" aria-label="Phút mở đề" required>
                                                <option value="">Phút</option>
                                                <% for (int minute = 0; minute < 60; minute++) {
                                                    String minuteValue = String.format("%02d", minute); %>
                                                    <option value="<%= minuteValue %>" <%= minuteValue.equals(examMinutePart(examDraftStartAt)) ? "selected" : "" %>><%= minuteValue %></option>
                                                <% } %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="upload-field">
                                        <label>Thời gian đóng đề</label>
                                        <div class="exam-datetime-fields" data-exam-datetime>
                                            <input type="date" name="examEndDate" value="<%= h(examDatePart(examDraftEndAt)) %>" required>
                                            <select name="examEndHour" aria-label="Giờ đóng đề" required>
                                                <option value="">Giờ</option>
                                                <% for (int hour = 0; hour < 24; hour++) {
                                                    String hourValue = String.format("%02d", hour); %>
                                                    <option value="<%= hourValue %>" <%= hourValue.equals(examHourPart(examDraftEndAt)) ? "selected" : "" %>><%= hourValue %></option>
                                                <% } %>
                                            </select>
                                            <select name="examEndMinute" aria-label="Phút đóng đề" required>
                                                <option value="">Phút</option>
                                                <% for (int minute = 0; minute < 60; minute++) {
                                                    String minuteValue = String.format("%02d", minute); %>
                                                    <option value="<%= minuteValue %>" <%= minuteValue.equals(examMinutePart(examDraftEndAt)) ? "selected" : "" %>><%= minuteValue %></option>
                                                <% } %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="upload-field full">
                                        <label>Mô tả</label>
                                        <textarea name="examDescription" rows="2" placeholder="Ghi chú, phạm vi kiến thức, quy định làm bài..."><%= h(examDraftDescription) %></textarea>
                                    </div>
                                </div>
                            </section>
                            <section class="exam-builder-section exam-ai-section" data-exam-ai-source>
                                <div class="exam-section-heading exam-ai-heading">
                                    <span class="exam-section-number">AI</span>
                                    <div>
                                        <strong>Đưa đề vào AI</strong>
                                        <p>Dán nội dung hoặc tải ảnh đề rõ nét. AI sẽ nhận diện câu hỏi và điền trước để bạn rà soát.</p>
                                    </div>
                                </div>
                                <div class="quiz-scan-preview exam-ai-workspace">
                                    <div class="upload-field">
                                        <label>Text đề để AI nhận diện</label>
                                        <textarea class="exam-ai-textarea" name="examSourceText" rows="8" placeholder="Dán câu hỏi tại đây. AI sẽ tự nhận diện nội dung, các lựa chọn và đáp án nếu có.

Ví dụ:
Câu 1. Mặt trăng là gì?
A. ...
B. ...
C. ...
D. ...
Đáp án: B"><%= h(examDraftSourceText) %></textarea>
                                    </div>
                                    <div class="upload-field">
                                        <label>Hoặc tải file đề</label>
                                        <input class="exam-ai-upload-input" id="exam-source-image" type="file" name="examSourceImage" accept="image/png,image/jpeg,image/webp,application/pdf,.pdf,.docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document" capture="environment" data-exam-image-input>
                                        <label class="exam-ai-upload-card" for="exam-source-image" data-exam-image-dropzone>
                                            <span class="exam-ai-upload-empty" data-exam-image-preview>
                                                <span class="exam-ai-upload-icon">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                        <path d="M12 16V4m0 0-4 4m4-4 4 4"/>
                                                        <path d="M5 14v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4"/>
                                                    </svg>
                                                </span>
                                                <strong>Kéo thả ảnh vào đây</strong>
                                                <span>Hỗ trợ PNG, JPG, WEBP, PDF hoặc DOCX. Ưu tiên ảnh rõ nét, không bị nghiêng.</span>
                                                <em>Chọn ảnh từ máy</em>
                                            </span>
                                        </label>
                                    </div>
                                </div>
                                <div class="quiz-actions exam-ai-actions" data-exam-ai-actions>
                                    <div class="exam-ai-action-group">
                                        <button class="mini-btn exam-ai-submit" type="submit" name="action" value="scanClassExamAi" formnovalidate>
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                <path d="m12 3 1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3ZM19 15l.7 2.3L22 18l-2.3.7L19 21l-.7-2.3L16 18l2.3-.7L19 15Z"/>
                                            </svg>
                                            Phân tích bằng AI
                                        </button>
                                    </div>
                                </div>
                            </section>
                            <section class="exam-builder-section">
                                <div class="exam-section-heading">
                                    <span class="exam-section-number">03</span>
                                    <div>
                                        <strong>Rà soát câu hỏi</strong>
                                        <p>Kiểm tra nội dung và đáp án trước khi tạo bài thi chính thức.</p>
                                    </div>
                                </div>
                                <div class="quiz-card exam-question-workspace">
                                <div class="quiz-question-list" data-exam-question-list>
                                    <% if (examDraftQuestions != null && !examDraftQuestions.isEmpty()) {
                                        int examDraftQuestionIndex = 1;
                                        for (ClassroomExamQuestion question : examDraftQuestions) {
                                    %>
                                        <div class="quiz-question" data-exam-question>
                                            <h4>Câu <%= examDraftQuestionIndex++ %></h4>
                                            <div class="upload-grid" style="margin-top:0.65rem;">
                                                <div class="upload-field full">
                                                    <label>Nội dung câu hỏi</label>
                                                    <textarea name="examQuestionText" rows="2" required><%= h(question.getQuestionText()) %></textarea>
                                                </div>
                                                <div class="upload-field">
                                                    <label>Điểm</label>
                                                    <input type="number" name="examPoints" step="0.01" min="0" class="exam-question-points" value="<%= question.getPoints() != null && question.getPoints() > 0 ? question.getPoints() : 1.0 %>">
                                                </div>
                                            </div>
                                            <div data-exam-multiple-choice-fields>
                                                <div class="quiz-option-grid">
                                                    <label>A <input type="text" name="examOptionA" value="<%= h(question.getOptionA()) %>"></label>
                                                    <label>B <input type="text" name="examOptionB" value="<%= h(question.getOptionB()) %>"></label>
                                                    <label>C <input type="text" name="examOptionC" value="<%= h(question.getOptionC()) %>"></label>
                                                    <label>D <input type="text" name="examOptionD" value="<%= h(question.getOptionD()) %>"></label>
                                                </div>
                                                <div class="upload-field" style="margin-top:0.75rem;">
                                                    <label>Đáp án đúng</label>
                                                    <select name="examCorrectOption">
                                                        <option value="">Chưa chọn</option>
                                                        <option value="A" <%= "A".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>A</option>
                                                        <option value="B" <%= "B".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>B</option>
                                                        <option value="C" <%= "C".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>C</option>
                                                        <option value="D" <%= "D".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>D</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="upload-field" data-exam-essay-fields style="margin-top:0.75rem;">
                                                <label>Đáp án tham khảo</label>
                                                <textarea name="examReferenceAnswer" rows="2" placeholder="Có thể để trống nếu chưa cần đáp án mẫu."><%= h(question.getReferenceAnswer()) %></textarea>
                                            </div>
                                        </div>
                                    <%  }
                                    } else { %>
                                        <div class="quiz-question" data-exam-question>
                                            <h4>Câu 1</h4>
                                            <div class="upload-grid" style="margin-top:0.65rem;">
                                                <div class="upload-field full">
                                                    <label>Nội dung câu hỏi</label>
                                                    <textarea name="examQuestionText" rows="2" required></textarea>
                                                </div>
                                                <div class="upload-field">
                                                    <label>Điểm</label>
                                                    <input type="number" name="examPoints" step="0.01" min="0" class="exam-question-points" value="1.0">
                                                </div>
                                            </div>
                                            <div data-exam-multiple-choice-fields>
                                                <div class="quiz-option-grid">
                                                    <label>A <input type="text" name="examOptionA"></label>
                                                    <label>B <input type="text" name="examOptionB"></label>
                                                    <label>C <input type="text" name="examOptionC"></label>
                                                    <label>D <input type="text" name="examOptionD"></label>
                                                </div>
                                                <div class="upload-field" style="margin-top:0.75rem;">
                                                    <label>Đáp án đúng</label>
                                                    <select name="examCorrectOption">
                                                        <option value="">Chưa chọn</option>
                                                        <option value="A">A</option>
                                                        <option value="B">B</option>
                                                        <option value="C">C</option>
                                                        <option value="D">D</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="upload-field" data-exam-essay-fields style="margin-top:0.75rem;">
                                                <label>Đáp án tham khảo</label>
                                                <textarea name="examReferenceAnswer" rows="2" placeholder="Có thể để trống nếu chưa cần đáp án mẫu."></textarea>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                                <div class="quiz-actions">
                                    <button class="mini-btn exam-add-btn" type="button" data-add-exam-question>Thêm câu hỏi</button>
                                    <button class="mini-btn exam-create-btn" type="submit" name="action" value="createClassExam">Tạo bài thi</button>
                                </div>
                            </div>
                            </section>
                        </form>
                    <% } %>
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
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                        <h2 style="margin: 0;">Nội quy lớp học</h2>
                        <% if (canManageClassroom) { %>
                            <div style="display: flex; gap: 0.5rem;">
                                <button type="button" class="btn btn-outline" style="border-radius: 999px; color: #059669; border: 1.5px solid #a7f3d0; padding: 0.4rem 1.2rem; font-weight: 700; background: transparent; cursor: pointer;" onclick="openManageRulesModal()">Chỉnh sửa</button>
                                <button type="button" class="btn btn-primary" style="border-radius: 999px; background: #059669; color: white; border: none; padding: 0.4rem 1.2rem; font-weight: 700; cursor: pointer;" onclick="openAddRuleModal()">Thêm</button>
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="resource-list">
                        <% 
                        List<com.hipzi.model.ClassroomRule> classroomRules = (List<com.hipzi.model.ClassroomRule>) request.getAttribute("classroomRules");
                        if (classroomRules != null && !classroomRules.isEmpty()) {
                            for (com.hipzi.model.ClassroomRule rule : classroomRules) {
                        %>
                        <div class="resource-item">
                            <strong><%= h(rule.getTitle()) %></strong>
                            <span><%= h(rule.getRuleText()) %></span>
                        </div>
                        <%  }
                        } else { %>
                        <div class="empty-state">Chưa có nội quy nào được thiết lập.</div>
                        <% } %>
                        <% if (canManageClassroom && (classroomRules == null || classroomRules.isEmpty())) { %>
                            <div class="teacher-action-hint">Hãy thêm nội quy để học viên nắm rõ yêu cầu của lớp.</div>
                        <% } %>
                    </div>
                </section>
            </div>
        </section>
    </main>

    <div id="class-rule-add-modal" class="exam-modal-overlay" hidden>
        <div class="exam-modal-content">
            <div class="exam-modal-header">
                <h3>Thêm nội quy mới</h3>
                <button class="exam-modal-close" type="button" onclick="closeAddRuleModal()">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/classroom" method="POST" class="upload-grid">
                <input type="hidden" name="action" value="addClassroomRule">
                <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                <div class="upload-field full">
                    <label>Tiêu đề</label>
                    <input type="text" name="ruleTitle" placeholder="Ví dụ: Tôn trọng giờ học" required>
                </div>
                <div class="upload-field full">
                    <label>Nội dung chi tiết</label>
                    <textarea name="ruleText" rows="3" placeholder="Ví dụ: Học viên nên vào lớp đúng giờ..." required></textarea>
                </div>
                <div class="upload-field">
                    <label>Thứ tự sắp xếp</label>
                    <input type="number" name="sortOrder" value="1" min="1" required>
                </div>
                <div class="upload-field full" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 0.5rem;">
                    <button type="button" class="btn" style="background: #f1f5f9; color: #475569;" onclick="closeAddRuleModal()">Hủy</button>
                    <button type="submit" class="btn btn-primary" style="background: #10b981; color: #ffffff; border-color: #10b981;">Lưu nội quy</button>
                </div>
            </form>
        </div>
    </div>

    <div id="class-rule-manage-modal" class="exam-modal-overlay" hidden>
        <div class="exam-modal-content" style="max-width: 700px; max-height: 80vh; overflow-y: auto;">
            <div class="exam-modal-header" style="position: sticky; top: 0; background: white; z-index: 10;">
                <h3>Chỉnh sửa nội quy</h3>
                <button class="exam-modal-close" type="button" onclick="closeManageRulesModal()">&times;</button>
            </div>
            <div style="margin-top: 1rem;">
                <% 
                List<com.hipzi.model.ClassroomRule> manageClassroomRules = (List<com.hipzi.model.ClassroomRule>) request.getAttribute("classroomRules");
                if (manageClassroomRules != null && !manageClassroomRules.isEmpty()) {
                    for (com.hipzi.model.ClassroomRule rule : manageClassroomRules) { %>
                <form action="${pageContext.request.contextPath}/classroom" method="POST" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 1rem; margin-bottom: 1rem;">
                    <input type="hidden" name="action" value="updateClassroomRule">
                    <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                    <input type="hidden" name="ruleId" value="<%= h(rule.getId()) %>">
                    <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                        <div class="upload-field" style="flex: 1; min-width: 200px;">
                            <label>Tiêu đề</label>
                            <input type="text" name="ruleTitle" value="<%= h(rule.getTitle()) %>" required>
                        </div>
                        <div class="upload-field" style="width: 80px;">
                            <label>Thứ tự</label>
                            <input type="number" name="sortOrder" value="<%= rule.getSortOrder() %>" min="1" required>
                        </div>
                        <div class="upload-field" style="flex: 2; min-width: 250px;">
                            <label>Nội dung</label>
                            <input type="text" name="ruleText" value="<%= h(rule.getRuleText()) %>" required>
                        </div>
                        <div style="display: flex; gap: 0.5rem; width: 100%; justify-content: flex-end; align-items: center;">
                            <button type="submit" class="btn" style="border-radius: 999px; padding: 0.4rem 1.2rem; font-weight: 600; font-size: 0.85rem; background: #059669; color: white; border: none; cursor: pointer;">Cập nhật</button>
                            <button type="button" class="btn" style="border-radius: 999px; padding: 0.4rem 1.2rem; font-weight: 600; font-size: 0.85rem; background: #ef4444; color: white; border: none; cursor: pointer;" onclick="if(confirm('Bạn có chắc chắn muốn xóa nội quy này?')) { this.nextElementSibling.submit(); }">Xóa</button>
                        </div>
                    </div>
                </form>
                <form action="${pageContext.request.contextPath}/classroom" method="POST" style="display:none;">
                    <input type="hidden" name="action" value="deleteClassroomRule">
                    <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                    <input type="hidden" name="ruleId" value="<%= h(rule.getId()) %>">
                </form>
                <%  }
                } else { %>
                <p style="text-align: center; color: #64748b;">Chưa có nội quy nào để chỉnh sửa.</p>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        function openAddRuleModal() {
            document.getElementById('class-rule-add-modal').removeAttribute('hidden');
        }
        function closeAddRuleModal() {
            document.getElementById('class-rule-add-modal').setAttribute('hidden', '');
        }
        function openManageRulesModal() {
            document.getElementById('class-rule-manage-modal').removeAttribute('hidden');
        }
        function closeManageRulesModal() {
            document.getElementById('class-rule-manage-modal').setAttribute('hidden', '');
        }
    </script>

    <style>
        .exam-modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            display: flex; align-items: center; justify-content: center;
            z-index: 1000; opacity: 0; pointer-events: none; transition: opacity 0.2s;
        }
        .exam-modal-overlay:not([hidden]) {
            opacity: 1; pointer-events: auto;
        }
        .exam-modal-content {
            background: #ffffff; border-radius: 1rem; padding: 1.5rem;
            width: 90%; max-width: 600px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
            transform: translateY(20px); transition: transform 0.2s;
        }
        .exam-modal-overlay:not([hidden]) .exam-modal-content {
            transform: translateY(0);
        }
        .exam-modal-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 1.25rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.75rem;
        }
        .exam-modal-header h3 { margin: 0; font-size: 1.15rem; color: #0f172a; }
        .exam-modal-close { background: none; border: none; font-size: 1.5rem; color: #64748b; cursor: pointer; padding: 0; line-height: 1; }
    </style>

    <div id="class-exam-edit-modal" class="exam-modal-overlay" hidden>
        <div class="exam-modal-content">
            <div class="exam-modal-header">
                <h3>Chỉnh sửa thông tin bài thi</h3>
                <button class="exam-modal-close" type="button" onclick="closeExamEditModal()">&times;</button>
            </div>
            <form action="${pageContext.request.contextPath}/classroom" method="POST" class="upload-grid">
                <input type="hidden" name="action" value="updateClassExam">
                <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                <input type="hidden" name="examId" id="editExamId">
                <input type="hidden" name="examMaxScore" id="editExamMaxScore">
                <div class="upload-field full">
                    <label>Tiêu đề bài thi</label>
                    <input type="text" name="examTitle" id="editExamTitle" required>
                </div>
                <div class="upload-field">
                    <label>Mã đề</label>
                    <input type="text" name="examCode" id="editExamCode" required>
                </div>
                <div class="upload-field">
                    <label>Thời lượng (phút)</label>
                    <input type="number" name="durationMinutes" id="editExamDuration" min="1" required>
                </div>
                <div class="upload-field full">
                    <label>Thời gian mở đề</label>
                    <div class="exam-datetime-fields">
                        <input type="date" name="examStartDate" id="editExamStartDate" required>
                        <select name="examStartHour" id="editExamStartHour" required>
                            <option value="">Giờ</option>
                            <% for (int hour = 0; hour < 24; hour++) {
                                String hourValue = String.format("%02d", hour); %>
                                <option value="<%= hourValue %>"><%= hourValue %></option>
                            <% } %>
                        </select>
                        <select name="examStartMinute" id="editExamStartMinute" required>
                            <option value="">Phút</option>
                            <% for (int minute = 0; minute < 60; minute++) {
                                String minuteValue = String.format("%02d", minute); %>
                                <option value="<%= minuteValue %>"><%= minuteValue %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="upload-field full">
                    <label>Thời gian đóng đề</label>
                    <div class="exam-datetime-fields">
                        <input type="date" name="examEndDate" id="editExamEndDate" required>
                        <select name="examEndHour" id="editExamEndHour" required>
                            <option value="">Giờ</option>
                            <% for (int hour = 0; hour < 24; hour++) {
                                String hourValue = String.format("%02d", hour); %>
                                <option value="<%= hourValue %>"><%= hourValue %></option>
                            <% } %>
                        </select>
                        <select name="examEndMinute" id="editExamEndMinute" required>
                            <option value="">Phút</option>
                            <% for (int minute = 0; minute < 60; minute++) {
                                String minuteValue = String.format("%02d", minute); %>
                                <option value="<%= minuteValue %>"><%= minuteValue %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="upload-field full">
                    <label>Mô tả</label>
                    <textarea name="examDescription" id="editExamDesc" rows="2"></textarea>
                </div>
                <div class="upload-field full" style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 0.5rem;">
                    <button type="button" class="btn" style="background: #f1f5f9; color: #475569;" onclick="closeExamEditModal()">Hủy</button>
                    <button type="submit" class="btn" style="background: #10b981; color: #ffffff; border-color: #10b981;">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>

    <style>
        .exam-rules-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.5); backdrop-filter: blur(4px);
            display: flex; align-items: center; justify-content: center;
            z-index: 1100; opacity: 0; pointer-events: none; transition: opacity 0.2s;
        }
        .exam-rules-overlay:not([hidden]) {
            opacity: 1; pointer-events: auto;
        }
        .exam-rules-content {
            background: #ffffff; border-radius: 1.5rem;
            padding: 2.5rem; width: 90%; max-width: 850px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.15);
            transform: translateY(20px); transition: transform 0.2s;
            color: #334155;
            font-family: var(--font-sans);
        }
        .exam-rules-overlay:not([hidden]) .exam-rules-content {
            transform: translateY(0);
        }
        .exam-rules-header {
            text-align: center; margin-bottom: 2.5rem;
        }
        .exam-rules-header h3 {
            margin: 0; font-size: 1.5rem; font-weight: 700; color: #0f172a;
        }
        .exam-rules-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 2.5rem;
        }
        .exam-rule-card {
            background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 1rem; padding: 2rem 1.5rem;
            text-align: center; display: flex; flex-direction: column; align-items: center; justify-content: flex-start;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); transition: transform 0.2s;
        }
        .exam-rule-card:hover {
            transform: translateY(-4px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        .exam-rule-icon {
            font-size: 2.5rem; margin-bottom: 1.25rem; line-height: 1;
            width: 80px; height: 80px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
        }
        .exam-rule-icon.blue { background: #e0e7ff; }
        .exam-rule-icon.red { background: #fee2e2; }
        .exam-rule-icon.green { background: #dcfce7; }
        
        .exam-rule-text {
            font-size: 0.95rem; line-height: 1.6; color: #475569; font-weight: 500;
        }
        .exam-rules-actions {
            display: flex; justify-content: center; gap: 1rem;
        }
        .exam-rules-btn {
            background: #f1f5f9; border: none; color: #475569;
            padding: 0.75rem 2.5rem; border-radius: 0.75rem; font-size: 1rem; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
        }
        .exam-rules-btn:hover {
            background: #e2e8f0;
        }
        .exam-rules-btn.primary {
            background: #10b981; color: #ffffff; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.3);
        }
        .exam-rules-btn.primary:hover {
            background: #059669; box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.4);
        }
        @media (max-width: 768px) {
            .exam-rules-grid { grid-template-columns: 1fr; gap: 1rem; }
            .exam-rule-card { padding: 1.5rem 1rem; }
            .exam-rules-content { padding: 1.5rem; }
        }
    </style>

    <div id="class-exam-rules-modal" class="exam-rules-overlay" hidden>
        <div class="exam-rules-content">
            <div class="exam-rules-header">
                <h3>Quy tắc thi của lớp học</h3>
            </div>
            <div class="exam-rules-grid">
                <div class="exam-rule-card">
                    <div class="exam-rule-icon blue">💻</div>
                    <div class="exam-rule-text">Kiểm tra thiết bị thi, unikey, pin, âm thanh trước khi bắt đầu.</div>
                </div>
                <div class="exam-rule-card">
                    <div class="exam-rule-icon red">🚫</div>
                    <div class="exam-rule-text">Tuyệt đối không được rời khỏi không gian thi, chuyển tab. Sẽ bị ghi lại vi phạm nếu rời.</div>
                </div>
                <div class="exam-rule-card">
                    <div class="exam-rule-icon green">⏱️</div>
                    <div class="exam-rule-text">Làm bài trung thực, nộp bài trước thời gian bài kết thúc.</div>
                </div>
            </div>
            <div class="exam-rules-actions">
                <button type="button" class="exam-rules-btn" onclick="closeExamRulesModal()">Hủy bỏ</button>
                <button type="button" class="exam-rules-btn primary" id="btn-exam-rules-confirm">Xác nhận</button>
            </div>
        </div>
    </div>

    <script>
        function openExamRulesModal(url) {
            document.getElementById('btn-exam-rules-confirm').onclick = function() {
                window.location.href = url;
            };
            document.getElementById('class-exam-rules-modal').hidden = false;
        }

        function closeExamRulesModal() {
            document.getElementById('class-exam-rules-modal').hidden = true;
        }

        function openExamEditModal(btn) {
            document.getElementById('editExamId').value = btn.dataset.id || '';
            document.getElementById('editExamTitle').value = btn.dataset.title || '';
            document.getElementById('editExamCode').value = btn.dataset.code || '';
            document.getElementById('editExamDuration').value = btn.dataset.duration || '';
            document.getElementById('editExamMaxScore').value = btn.dataset.maxScore || '10.0';
            document.getElementById('editExamStartDate').value = btn.dataset.startDate || '';
            document.getElementById('editExamStartHour').value = btn.dataset.startHour || '';
            document.getElementById('editExamStartMinute').value = btn.dataset.startMinute || '';
            document.getElementById('editExamEndDate').value = btn.dataset.endDate || '';
            document.getElementById('editExamEndHour').value = btn.dataset.endHour || '';
            document.getElementById('editExamEndMinute').value = btn.dataset.endMinute || '';
            document.getElementById('editExamDesc').value = btn.dataset.desc || '';
            document.getElementById('class-exam-edit-modal').hidden = false;
        }

        function closeExamEditModal() {
            document.getElementById('class-exam-edit-modal').hidden = true;
        }

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

        document.querySelectorAll('[data-upload-toggle]').forEach(button => {
            button.addEventListener('click', () => {
                const panel = document.getElementById(button.dataset.uploadToggle);
                if (!panel) return;
                const willOpen = panel.hidden;
                panel.hidden = !willOpen;
                button.dataset.closedLabel ||= button.textContent;
                button.textContent = willOpen ? 'Đóng biểu mẫu' : button.dataset.closedLabel;
                button.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
                if (willOpen) {
                    panel.querySelector('input:not([type="hidden"]), textarea, select')?.focus();
                }
            });
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

        function recalculateExamPoints(builder) {
            if (!builder) return;
            const maxScoreInput = builder.querySelector('input[name="examMaxScore"]');
            const pointsInputs = builder.querySelectorAll('.exam-question-points');
            if (!maxScoreInput || pointsInputs.length === 0) return;
            const maxScore = parseFloat(maxScoreInput.value) || 10.0;
            const pointsPerQuestion = (maxScore / pointsInputs.length).toFixed(2);
            pointsInputs.forEach(input => input.value = pointsPerQuestion);
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

        function renderExamImagePreview(input) {
            const preview = input.closest('form')?.querySelector('[data-exam-image-preview]');
            const file = input.files && input.files[0];
            if (!preview) return;
            if (!file) {
                preview.innerHTML = `
                    <span class="exam-ai-upload-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <path d="M12 16V4m0 0-4 4m4-4 4 4"/>
                            <path d="M5 14v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4"/>
                        </svg>
                    </span>
                    <strong>Kéo thả ảnh vào đây</strong>
                    <span>Hỗ trợ PNG, JPG, WEBP, PDF hoặc DOCX. Ưu tiên ảnh rõ nét, không bị nghiêng.</span>
                    <em>Chọn ảnh từ máy</em>
                `;
                preview.className = 'exam-ai-upload-empty';
                return;
            }
            const wrapper = document.createElement('span');
            wrapper.className = 'exam-ai-upload-preview';
            const name = document.createElement('span');
            name.textContent = file.name || 'File đề thi đã chọn';
            if (file.type && file.type.startsWith('image/')) {
                const img = document.createElement('img');
                img.alt = file.name || 'Ảnh đề thi';
                img.src = URL.createObjectURL(file);
                img.onload = () => URL.revokeObjectURL(img.src);
                wrapper.append(img, name);
            } else {
                wrapper.append(name);
            }
            preview.className = 'exam-ai-upload-preview';
            preview.replaceChildren(...wrapper.childNodes);
        }

        document.querySelectorAll('[data-exam-image-input]').forEach(input => {
            const dropzone = input.closest('.upload-field')?.querySelector('[data-exam-image-dropzone]');
            input.addEventListener('change', () => renderExamImagePreview(input));
            if (!dropzone) return;
            ['dragenter', 'dragover'].forEach(eventName => {
                dropzone.addEventListener(eventName, event => {
                    event.preventDefault();
                    dropzone.classList.add('dragging');
                });
            });
            ['dragleave', 'drop'].forEach(eventName => {
                dropzone.addEventListener(eventName, event => {
                    event.preventDefault();
                    dropzone.classList.remove('dragging');
                });
            });
            dropzone.addEventListener('drop', event => {
                const files = event.dataTransfer?.files;
                if (!files || !files.length) return;
                const transfer = new DataTransfer();
                transfer.items.add(files[0]);
                input.files = transfer.files;
                renderExamImagePreview(input);
            });
        });

        const examMathPreviewSelector = [
            'textarea[name="examQuestionText"]',
            'textarea[name="examReferenceAnswer"]',
            'input[name="examOptionA"]',
            'input[name="examOptionB"]',
            'input[name="examOptionC"]',
            'input[name="examOptionD"]'
        ].join(',');

        function escapeMathHtml(value) {
            return String(value || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function findMatchingParen(text, openIndex) {
            if (!text || text.charAt(openIndex) !== '(') return -1;
            let depth = 0;
            for (let i = openIndex; i < text.length; i++) {
                const char = text.charAt(i);
                if (char === '(') depth++;
                if (char === ')') depth--;
                if (depth === 0) return i;
            }
            return -1;
        }

        function normalizeMathPreviewInput(value) {
            return String(value || '')
                .replace(/\\sqrt\[(\d+)\]\{([^{}]+)\}/g, (_, index, inside) => {
                    if (index === '3') return '\u221b(' + inside + ')';
                    if (index === '4') return '\u221c(' + inside + ')';
                    return index + '\u221a(' + inside + ')';
                })
                .replace(/\\sqrt\{([^{}]+)\}/g, (_, inside) => '\u221a(' + inside + ')');
        }

        function renderPlainMathText(value) {
            return escapeMathHtml(value)
                .replace(/\^\{([^{}]+)\}/g, '<sup>$1</sup>')
                .replace(/\^([0-9A-Za-z+\-]+)/g, '<sup>$1</sup>');
        }

        function rootTokenAt(text, index) {
            const char = text.charAt(index);
            const next = text.charAt(index + 1);
            if (char === '\u221a') return { index: '', length: 1 };
            if (char === '\u221b') return { index: '3', length: 1 };
            if (char === '\u221c') return { index: '4', length: 1 };
            if ((char === '\u00b3' || char === '3') && next === '\u221a') return { index: '3', length: 2 };
            if ((char === '\u2074' || char === '4') && next === '\u221a') return { index: '4', length: 2 };
            return null;
        }

        function renderRootHtml(index, radicandHtml) {
            const indexHtml = index
                ? '<span class="math-root-index">' + escapeMathHtml(index) + '</span>'
                : '';
            return '<span class="math-root">' + indexHtml
                + '<span class="math-root-symbol">&radic;</span>'
                + '<span class="math-root-radicand">' + radicandHtml + '</span>'
                + '</span>';
        }

        function renderMathPreviewHtml(value) {
            const text = normalizeMathPreviewInput(value);
            let html = '';
            let plainStart = 0;
            for (let i = 0; i < text.length; i++) {
                const token = rootTokenAt(text, i);
                if (!token) continue;
                let bodyStart = i + token.length;
                while (bodyStart < text.length && /\s/.test(text.charAt(bodyStart))) bodyStart++;
                if (text.charAt(bodyStart) !== '(') continue;
                const bodyEnd = findMatchingParen(text, bodyStart);
                if (bodyEnd < 0) continue;
                html += renderPlainMathText(text.slice(plainStart, i));
                html += renderRootHtml(token.index, renderMathPreviewHtml(text.slice(bodyStart + 1, bodyEnd)));
                i = bodyEnd;
                plainStart = bodyEnd + 1;
            }
            html += renderPlainMathText(text.slice(plainStart));
            return html;
        }

        function needsMathPreview(value) {
            return /\\sqrt|\u221a|\u221b|\u221c|\u00b3\u221a|\u2074\u221a/.test(String(value || ''));
        }

        function syncMathPreview(field) {
            if (!field) return;
            let preview = field.nextElementSibling;
            if (!preview || !preview.matches('[data-math-preview]')) {
                preview = document.createElement('div');
                preview.className = 'math-preview';
                preview.dataset.mathPreview = 'true';
                preview.setAttribute('role', 'button');
                preview.setAttribute('tabindex', '0');
                preview.title = 'Nhấn đúp hoặc Enter để chỉnh sửa';
                field.insertAdjacentElement('afterend', preview);
            }
            const shouldRender = needsMathPreview(field.value) && document.activeElement !== field;
            field.classList.toggle('math-source-hidden', shouldRender);
            preview.classList.toggle('visible', shouldRender);
            preview.setAttribute('aria-hidden', shouldRender ? 'false' : 'true');
            preview.innerHTML = shouldRender ? renderMathPreviewHtml(field.value) : '';
        }

        function editMathPreviewField(field) {
            if (!field) return;
            const preview = field.nextElementSibling;
            field.classList.remove('math-source-hidden');
            preview?.classList.remove('visible');
            preview?.setAttribute('aria-hidden', 'true');
            window.setTimeout(() => {
                field.focus();
                if (typeof field.selectionStart === 'number') {
                    const end = field.value.length;
                    field.setSelectionRange(end, end);
                }
            }, 0);
        }

        function attachMathPreviews(scope) {
            const root = scope || document;
            root.querySelectorAll(examMathPreviewSelector).forEach(field => {
                if (field.dataset.mathPreviewBound === 'true') {
                    syncMathPreview(field);
                    return;
                }
                field.dataset.mathPreviewBound = 'true';
                field.addEventListener('input', () => syncMathPreview(field));
                field.addEventListener('focus', () => syncMathPreview(field));
                field.addEventListener('blur', () => syncMathPreview(field));
                syncMathPreview(field);
                const preview = field.nextElementSibling;
                preview?.addEventListener('dblclick', () => editMathPreviewField(field));
                preview?.addEventListener('keydown', event => {
                    if (event.key !== 'Enter' && event.key !== ' ') return;
                    event.preventDefault();
                    editMathPreviewField(field);
                });
            });
        }

        function renumberExamQuestions(list) {
            list.querySelectorAll('[data-exam-question]').forEach((question, index) => {
                const heading = question.querySelector('h4');
                if (heading) {
                    heading.textContent = 'Câu ' + (index + 1);
                }
                let removeButton = question.querySelector('[data-remove-exam-question]');
                if (index === 0) {
                    question.removeAttribute('data-removable-exam-question');
                    removeButton?.remove();
                    return;
                }
                question.setAttribute('data-removable-exam-question', 'true');
                if (!removeButton) {
                    removeButton = document.createElement('button');
                    removeButton.type = 'button';
                    removeButton.className = 'mini-btn exam-question-remove';
                    removeButton.dataset.removeExamQuestion = 'true';
                    removeButton.setAttribute('aria-label', 'Xóa câu hỏi này');
                    removeButton.title = 'Xóa câu hỏi';
                    removeButton.textContent = '×';
                    question.appendChild(removeButton);
                }
            });
            const builder = list.closest('[data-exam-builder]');
            if (builder) recalculateExamPoints(builder);
        }

        function syncExamBuilder(builder) {
            if (!builder) return;
            const type = builder.querySelector('[data-exam-type]')?.value || 'multiple_choice';
            const mode = builder.querySelector('[data-exam-mode]')?.value || 'manual';
            const isEssay = type === 'essay';
            builder.querySelectorAll('[data-exam-mode-option]').forEach(button => {
                const isActive = button.dataset.examModeOption === mode;
                button.classList.toggle('active', isActive);
                button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
            });
            builder.querySelectorAll('[data-exam-ai-source], [data-exam-ai-actions]').forEach(element => {
                element.style.display = mode === 'ai' ? '' : 'none';
            });
            builder.querySelectorAll('[data-exam-multiple-choice-fields]').forEach(element => {
                element.style.display = isEssay ? 'none' : '';
                element.querySelectorAll('input, select').forEach(field => {
                    field.required = !isEssay;
                });
            });
            builder.querySelectorAll('[data-exam-essay-fields]').forEach(element => {
                element.style.display = isEssay ? '' : 'none';
            });
        }

        function createExamQuestionTemplate() {
            return `
                <div class="quiz-question" data-exam-question>
                    <h4>Câu</h4>
                    <div class="upload-grid" style="margin-top:0.65rem;">
                        <div class="upload-field full">
                            <label>Nội dung câu hỏi</label>
                            <textarea name="examQuestionText" rows="2" required></textarea>
                        </div>
                        <div class="upload-field">
                            <label>Điểm</label>
                            <input type="number" name="examPoints" step="0.01" min="0" class="exam-question-points" value="1.0">
                        </div>
                    </div>
                    <div data-exam-multiple-choice-fields>
                        <div class="quiz-option-grid">
                            <label>A <input type="text" name="examOptionA"></label>
                            <label>B <input type="text" name="examOptionB"></label>
                            <label>C <input type="text" name="examOptionC"></label>
                            <label>D <input type="text" name="examOptionD"></label>
                        </div>
                        <div class="upload-field" style="margin-top:0.75rem;">
                            <label>Đáp án đúng</label>
                            <select name="examCorrectOption">
                                <option value="">Chưa chọn</option>
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                        </div>
                    </div>
                    <div class="upload-field" data-exam-essay-fields style="margin-top:0.75rem;">
                        <label>Đáp án tham khảo</label>
                        <textarea name="examReferenceAnswer" rows="2" placeholder="Có thể để trống nếu chưa cần đáp án mẫu."></textarea>
                    </div>
                </div>
            `;
        }

        document.querySelectorAll('[data-exam-builder]').forEach(builder => {
            builder.querySelector('[data-exam-type]')?.addEventListener('change', () => syncExamBuilder(builder));
            builder.querySelector('[data-exam-mode]')?.addEventListener('change', () => syncExamBuilder(builder));
            builder.querySelectorAll('[data-exam-mode-option]').forEach(button => {
                button.addEventListener('click', () => {
                    const select = builder.querySelector('[data-exam-mode]');
                    if (!select) return;
                    select.value = button.dataset.examModeOption;
                    select.dispatchEvent(new Event('change', { bubbles: true }));
                });
            });
            builder.querySelector('input[name="examMaxScore"]')?.addEventListener('input', () => {
                recalculateExamPoints(builder);
            });
            builder.querySelector('[data-add-exam-question]')?.addEventListener('click', () => {
                const list = builder.querySelector('[data-exam-question-list]');
                if (!list) return;
                list.insertAdjacentHTML('beforeend', createExamQuestionTemplate());
                renumberExamQuestions(list);
                syncExamBuilder(builder);
                attachMathPreviews(list.lastElementChild);
                list.lastElementChild?.querySelector('textarea')?.focus();
            });
            builder.querySelector('[data-exam-question-list]')?.addEventListener('click', event => {
                const removeButton = event.target.closest('[data-remove-exam-question]');
                if (!removeButton) return;
                const list = builder.querySelector('[data-exam-question-list]');
                const question = removeButton.closest('[data-exam-question]');
                if (!list || !question) return;
                question.remove();
                renumberExamQuestions(list);
                syncExamBuilder(builder);
                list.lastElementChild?.querySelector('textarea')?.focus();
            });
            const initialExamQuestionList = builder.querySelector('[data-exam-question-list]');
            if (initialExamQuestionList) {
                renumberExamQuestions(initialExamQuestionList);
            }
            syncExamBuilder(builder);
            attachMathPreviews(builder);
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
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
