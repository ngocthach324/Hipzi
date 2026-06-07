<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.ClassroomExam"%>
<%@page import="com.hipzi.model.ClassroomExamQuestion"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String js(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\r", "\\r")
                    .replace("\n", "\\n")
                    .replace("\t", "\\t")
                    .replace("\u2028", "\\u2028")
                    .replace("\u2029", "\\u2029")
                    .replace("<", "\\u003c")
                    .replace(">", "\\u003e")
                    .replace("&", "\\u0026");
    }

    private String formatExamTime(Timestamp value) {
        return value != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(value) : "Chưa thiết lập";
    }
%>
<%
    if (!Boolean.TRUE.equals(request.getAttribute("classExamRoomRequest"))) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/class-exam-room"
                + (query != null && !query.isEmpty() ? "?" + query : ""));
        return;
    }
    User user = (User) session.getAttribute("loggedUser");
    Classroom classroom = (Classroom) request.getAttribute("classroom");
    ClassroomExam classroomExam = (ClassroomExam) request.getAttribute("classroomExam");
    String classId = (String) request.getAttribute("classId");
    String examCode = (String) request.getAttribute("examCode");
    String examLookupError = (String) request.getAttribute("examLookupError");
    String examAvailabilityMessage = (String) request.getAttribute("examAvailabilityMessage");
    boolean canEnterExam = Boolean.TRUE.equals(request.getAttribute("canEnterExam"));
    boolean hasClassExamContext = classroomExam != null;
    List<ClassroomExamQuestion> storedExamQuestions = hasClassExamContext ? classroomExam.getQuestions() : null;
    List<ClassroomExamQuestion> examQuestions = canEnterExam ? storedExamQuestions : null;
    int examQuestionCount = storedExamQuestions != null ? storedExamQuestions.size() : 0;
    int examDurationMinutes = hasClassExamContext ? classroomExam.getDurationMinutes() : 45;
    String examTitle = hasClassExamContext ? classroomExam.getTitle() : "";
    String examType = hasClassExamContext ? classroomExam.getExamType() : "multiple_choice";
    String classroomTitle = classroom != null ? classroom.getTitle() : "";
    String examStartLabel = hasClassExamContext ? formatExamTime(classroomExam.getStartAt()) : "Chưa thiết lập";
    String examEndLabel = hasClassExamContext ? formatExamTime(classroomExam.getEndAt()) : "Chưa thiết lập";
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
    <title>Bài thi lớp học - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        html,
        body {
            min-height: 100%;
        }

        body {
            min-height: 100vh;
            overflow-x: hidden;
            overflow-y: auto;
            background: linear-gradient(135deg, #e8f3f6 0%, #f6fbfc 52%, #ffffff 100%);
            color: #0f172a;
        }

        body.exam-running {
            overflow: hidden;
        }

        .class-exam-page {
            position: relative;
            box-sizing: border-box;
            min-height: calc(100vh - 80px);
            padding: 1.15rem 1.5rem 2rem;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            gap: 0.95rem;
            overflow: visible;
        }

        .class-exam-topbar {
            width: min(1180px, 100%);
            margin: 0 auto -0.05rem;
            position: relative;
            z-index: 1;
        }

        .class-exam-back {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: #64748b;
            text-decoration: none;
            font-size: 0.98rem;
            font-weight: 800;
            transition: color 0.2s ease, transform 0.2s ease;
        }

        .class-exam-back:hover {
            color: #0f766e;
            transform: translateX(-2px);
        }

        .class-exam-page::before {
            content: "";
            position: absolute;
            left: 50%;
            bottom: 0.25rem;
            width: min(820px, 82vw);
            height: 120px;
            transform: translateX(-50%);
            border-radius: 999px;
            background: rgba(15, 118, 110, 0.12);
            filter: blur(42px);
            pointer-events: none;
        }

        .class-exam-intro {
            width: min(1180px, 100%);
            margin: 0 auto 0.35rem;
            text-align: center;
            position: relative;
            z-index: 1;
        }

        .class-exam-shell {
            width: min(1080px, 100%);
            margin: 10px auto 0;
            position: relative;
            overflow: hidden;
            border: 1px solid rgba(148, 163, 184, 0.22);
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
            box-shadow:
                0 40px 90px rgba(15, 23, 42, 0.1),
                0 18px 42px rgba(15, 118, 110, 0.08),
                inset 0 1px 0 rgba(255, 255, 255, 0.86);
            padding: 1.25rem;
        }

        .class-exam-shell::before {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: inherit;
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.72), transparent 45%);
            pointer-events: none;
        }

        .class-exam-hero {
            position: relative;
            z-index: 1;
        }

        .class-exam-intro h1 {
            margin: 0;
            font-size: clamp(1.85rem, 3.1vw, 3rem);
            line-height: 1.08;
            letter-spacing: 0;
            font-weight: 900;
            white-space: nowrap;
        }

        .class-exam-intro p {
            max-width: 780px;
            margin: 0.95rem auto 0;
            color: #475569;
            font-size: 0.96rem;
            line-height: 1.48;
        }

        .class-exam-points {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.75rem;
            margin-top: 0.85rem;
            border: 1px solid rgba(226, 232, 240, 0.9);
            border-radius: 18px;
            background: rgba(248, 250, 252, 0.78);
            padding: 0.75rem;
        }

        .class-exam-point {
            position: relative;
            overflow: hidden;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.86);
            border: 1px solid rgba(226, 232, 240, 0.84);
            padding: 0.86rem 0.9rem;
            box-shadow: 0 10px 28px rgba(15, 23, 42, 0.04);
            transition: transform 0.22s ease, border-color 0.22s ease, box-shadow 0.22s ease, background 0.22s ease;
        }

        .class-exam-point:hover {
            transform: translateY(-2px);
            border-color: rgba(20, 184, 166, 0.28);
            background: #ffffff;
            box-shadow: 0 18px 42px rgba(15, 118, 110, 0.1);
        }

        .class-exam-point-head {
            display: flex;
            align-items: center;
            gap: 0.62rem;
            margin-bottom: 0.38rem;
        }

        .class-exam-point-icon {
            display: inline-flex;
            width: 2rem;
            height: 2rem;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            background: linear-gradient(135deg, rgba(20, 184, 166, 0.14), rgba(59, 130, 246, 0.1));
            color: #0f766e;
            flex: 0 0 auto;
            box-shadow: inset 0 0 0 1px rgba(20, 184, 166, 0.12);
        }

        .class-exam-point strong {
            display: block;
            color: #0f172a;
            font-size: 0.88rem;
        }

        .class-exam-point span {
            color: #64748b;
            font-size: 0.79rem;
            line-height: 1.34;
        }

        .exam-code-panel {
            position: relative;
            isolation: isolate;
            overflow: hidden;
            border: 1px solid rgba(20, 184, 166, 0.2);
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.94);
            padding: 1.25rem 1.3rem;
            box-shadow: 0 22px 52px rgba(15, 118, 110, 0.1), 0 10px 26px rgba(15, 23, 42, 0.04);
        }

        .exam-code-panel::before {
            content: "";
            position: absolute;
            inset: 0 0 auto;
            height: 3px;
            background: linear-gradient(90deg, #0f766e, #14b8a6, #38bdf8);
            opacity: 0.7;
            z-index: -1;
        }

        .exam-code-panel::after {
            content: "";
            position: absolute;
            inset: 3px;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.68);
            pointer-events: none;
            z-index: -1;
        }

        .exam-code-title {
            display: flex;
            align-items: center;
            gap: 0.65rem;
        }

        .exam-code-icon {
            display: inline-flex;
            width: 2.15rem;
            height: 2.15rem;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            background: linear-gradient(135deg, rgba(20, 184, 166, 0.18), rgba(56, 189, 248, 0.12));
            color: #0f766e;
            flex: 0 0 auto;
            box-shadow: inset 0 0 0 1px rgba(20, 184, 166, 0.12);
        }

        .exam-code-panel h2,
        .exam-result-panel h2 {
            margin: 0;
            font-size: 1.16rem;
            line-height: 1.25;
            letter-spacing: 0;
        }

        .exam-code-panel p {
            margin: 0.42rem 0 0.65rem;
            color: #64748b;
            line-height: 1.42;
            font-size: 0.88rem;
        }

        .exam-code-form {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(190px, auto);
            align-items: center;
            gap: 0.85rem;
        }

        .exam-code-input {
            width: 100%;
            min-height: 3.25rem;
            box-sizing: border-box;
            border: 1px solid rgba(148, 163, 184, 0.55);
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.94);
            color: #0f172a;
            padding: 0.78rem 1rem;
            font-size: 0.96rem;
            font-weight: 800;
            letter-spacing: 0.04em;
            outline: none;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.82), 0 8px 18px rgba(15, 23, 42, 0.035);
            transition: none;
        }

        .exam-code-input:focus {
            border-color: #14b8a6;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(20, 184, 166, 0.16), 0 14px 30px rgba(15, 118, 110, 0.11);
        }

        .exam-code-submit {
            position: relative;
            overflow: hidden;
            display: inline-flex;
            min-height: 3.25rem;
            align-items: center;
            justify-content: center;
            gap: 0.55rem;
            border: none;
            border-radius: 999px;
            padding: 0.78rem 1.1rem;
            background: linear-gradient(135deg, #0f766e 0%, #059669 52%, #0ea5e9 125%);
            color: #ffffff;
            font-size: 0.95rem;
            font-weight: 900;
            cursor: pointer;
            box-shadow: 0 14px 30px rgba(15, 118, 110, 0.24);
            transition: transform 0.2s ease, box-shadow 0.2s ease, opacity 0.2s ease;
        }

        .exam-code-submit::after {
            content: "";
            position: absolute;
            inset: 0;
            transform: translateX(-120%);
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.28), transparent);
            transition: transform 0.45s ease;
        }

        .exam-code-submit:not(:disabled):hover {
            transform: translateY(-2px) scale(1.015);
            box-shadow: 0 20px 42px rgba(15, 118, 110, 0.28);
        }

        .exam-code-submit:not(:disabled):hover::after {
            transform: translateX(120%);
        }

        .exam-code-submit:disabled {
            cursor: not-allowed;
            opacity: 0.54;
            box-shadow: none;
        }

        .exam-code-help {
            grid-column: 1 / -1;
            color: #94a3b8;
            font-size: 0.78rem;
            line-height: 1.35;
        }

        .exam-result-panel {
            display: none;
            margin-top: 1rem;
            padding: 1.2rem;
            border: 1px solid rgba(148, 163, 184, 0.24);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.82);
        }

        .exam-result-panel.active {
            display: block;
        }

        .exam-found-label {
            display: inline-flex;
            margin-bottom: 0.8rem;
            border-radius: 999px;
            padding: 0.34rem 0.7rem;
            background: #dcfce7;
            color: #15803d;
            font-size: 0.78rem;
            font-weight: 900;
        }

        .exam-meta-list {
            display: grid;
            gap: 0.55rem;
            margin: 1rem 0 1.2rem;
        }

        .exam-meta-item {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 0.55rem;
            color: #64748b;
            font-size: 0.86rem;
        }

        .exam-meta-item strong {
            color: #0f172a;
            text-align: right;
        }

        .exam-enter-btn {
            display: inline-flex;
            width: 100%;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            padding: 0.9rem 1rem;
            text-decoration: none;
            background: #0f766e;
            color: #ffffff;
            font-weight: 900;
        }

        .exam-code-error {
            display: none;
            grid-column: 1 / -1;
            color: #b91c1c;
            font-size: 0.82rem;
            font-weight: 700;
        }

        .exam-code-error.active {
            display: block;
        }

        .exam-workspace {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: none;
            flex-direction: column;
            overflow: hidden;
            background: #f4f8fb;
            color: #172033;
        }

        .exam-workspace.active {
            display: flex;
        }

        .exam-workspace-header {
            display: flex;
            min-height: 72px;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            border-bottom: 1px solid #d9e4ec;
            background: #ffffff;
            padding: 0.85rem 1.4rem;
            box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
        }

        .exam-workspace-brand,
        .exam-workspace-meta,
        .exam-status-pill,
        .exam-violation-pill {
            display: flex;
            align-items: center;
        }

        .exam-workspace-brand {
            gap: 0.7rem;
        }

        .exam-workspace-brand img {
            width: 42px;
            height: 42px;
            border-radius: 12px;
        }

        .exam-workspace-brand strong,
        .exam-workspace-title strong {
            display: block;
            color: #0f172a;
            font-size: 0.94rem;
        }

        .exam-workspace-brand span,
        .exam-workspace-title span {
            display: block;
            margin-top: 0.15rem;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 700;
        }

        .exam-workspace-title {
            min-width: 0;
            text-align: center;
        }

        .exam-workspace-title strong {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: 1.02rem;
        }

        .exam-workspace-meta {
            justify-content: flex-end;
            gap: 0.55rem;
        }

        .exam-status-pill,
        .exam-violation-pill {
            gap: 0.42rem;
            border-radius: 999px;
            padding: 0.5rem 0.72rem;
            font-size: 0.74rem;
            font-weight: 900;
        }

        .exam-enter-btn.disabled {
            cursor: not-allowed;
            background: #94a3b8;
        }

        .exam-status-pill {
            background: #ecfdf5;
            color: #047857;
        }

        .exam-violation-pill {
            background: #fff7ed;
            color: #c2410c;
        }

        .exam-workspace-body {
            display: grid;
            min-height: 0;
            flex: 1;
            grid-template-columns: 280px minmax(0, 1fr);
            gap: 1rem;
            padding: 1rem;
        }

        .exam-sidebar,
        .exam-question-card {
            border: 1px solid #dde7ef;
            border-radius: 18px;
            background: #ffffff;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.06);
        }

        .exam-sidebar {
            display: flex;
            min-height: 0;
            flex-direction: column;
            gap: 1rem;
            padding: 1rem;
            overflow-y: auto;
        }

        .exam-timer {
            border-radius: 16px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            padding: 1rem;
            color: #ffffff;
        }

        .exam-timer span,
        .exam-sidebar-section-title {
            display: block;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .exam-timer strong {
            display: block;
            margin-top: 0.32rem;
            font-size: 1.65rem;
            letter-spacing: 0.06em;
        }

        .exam-progress-track {
            height: 7px;
            overflow: hidden;
            border-radius: 999px;
            background: #e2e8f0;
        }

        .exam-progress-track span {
            display: block;
            width: 0;
            height: 100%;
            border-radius: inherit;
            background: #14b8a6;
            transition: width 0.2s ease;
        }

        .exam-question-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 0.45rem;
        }

        .exam-question-number {
            aspect-ratio: 1;
            border: 1px solid #cbd5e1;
            border-radius: 9px;
            background: #ffffff;
            color: #475569;
            cursor: pointer;
            font-size: 0.78rem;
            font-weight: 900;
            transition: border-color 0.18s ease, background 0.18s ease, color 0.18s ease;
        }

        .exam-question-number.current {
            border-color: #0f766e;
            background: #ccfbf1;
            color: #0f766e;
        }

        .exam-question-number.answered {
            border-color: #0f766e;
            background: #0f766e;
            color: #ffffff;
        }

        .exam-question-number.current.answered {
            box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.2);
        }

        .exam-sidebar-note {
            margin-top: auto;
            border-radius: 14px;
            background: #fff7ed;
            padding: 0.8rem;
            color: #9a3412;
            font-size: 0.74rem;
            font-weight: 700;
            line-height: 1.55;
        }

        .exam-question-card {
            display: flex;
            min-height: 0;
            flex-direction: column;
            padding: 1.35rem;
            overflow-y: auto;
        }

        .exam-question-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 1rem;
        }

        .exam-question-head span {
            color: #0f766e;
            font-size: 0.8rem;
            font-weight: 900;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .exam-question-head strong {
            color: #64748b;
            font-size: 0.8rem;
        }

        .exam-question-content {
            padding: 1.45rem 0;
        }

        .exam-question-content h2 {
            margin: 0;
            color: #0f172a;
            font-size: clamp(1.1rem, 2vw, 1.35rem);
            line-height: 1.6;
        }

        .exam-option-list {
            display: grid;
            gap: 0.75rem;
            margin-top: 1.4rem;
        }

        .exam-option {
            display: flex;
            align-items: center;
            gap: 0.9rem;
            border: 1px solid #dbe5ed;
            border-radius: 14px;
            background: #ffffff;
            padding: 0.9rem 1rem;
            color: #334155;
            cursor: pointer;
            font-size: 0.92rem;
            font-weight: 700;
            text-align: left;
            transition: border-color 0.18s ease, background 0.18s ease, transform 0.18s ease;
        }

        .exam-option:hover {
            border-color: #5eead4;
            background: #f0fdfa;
            transform: translateY(-1px);
        }

        .exam-option.selected {
            border-color: #0f766e;
            background: #ccfbf1;
            color: #115e59;
        }

        .exam-option-key {
            display: inline-flex;
            width: 32px;
            height: 32px;
            flex: 0 0 auto;
            align-items: center;
            justify-content: center;
            border-radius: 9px;
            background: #f1f5f9;
            color: #475569;
            font-size: 0.82rem;
            font-weight: 900;
        }

        .exam-option.selected .exam-option-key {
            background: #0f766e;
            color: #ffffff;
        }

        .exam-essay-answer {
            box-sizing: border-box;
            width: 100%;
            min-height: 220px;
            resize: vertical;
            border: 1px solid #dbe5ed;
            border-radius: 14px;
            background: #ffffff;
            padding: 1rem;
            color: #334155;
            font: inherit;
            line-height: 1.6;
        }

        .exam-essay-answer:focus {
            border-color: #0f766e;
            outline: 3px solid rgba(20, 184, 166, 0.16);
        }

        .exam-question-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            margin-top: auto;
            border-top: 1px solid #e2e8f0;
            padding-top: 1rem;
        }

        .exam-nav-btn,
        .exam-submit-btn,
        .exam-lock-btn,
        .exam-confirm-btn,
        .exam-cancel-btn {
            border: 0;
            border-radius: 999px;
            cursor: pointer;
            padding: 0.78rem 1rem;
            font-size: 0.82rem;
            font-weight: 900;
        }

        .exam-nav-btn {
            background: #eef2f7;
            color: #334155;
        }

        .exam-submit-btn,
        .exam-lock-btn,
        .exam-confirm-btn {
            background: #0f766e;
            color: #ffffff;
        }

        .exam-submit-btn {
            margin-left: auto;
        }

        .exam-lock-overlay {
            position: absolute;
            inset: 0;
            z-index: 3;
            display: none;
            align-items: center;
            justify-content: center;
            background: rgba(15, 23, 42, 0.76);
            padding: 1rem;
        }

        .exam-lock-overlay.active {
            display: flex;
        }

        .exam-submit-overlay {
            position: absolute;
            inset: 0;
            z-index: 4;
            display: none;
            align-items: center;
            justify-content: center;
            background: rgba(15, 23, 42, 0.58);
            padding: 1rem;
            backdrop-filter: blur(5px);
            -webkit-backdrop-filter: blur(5px);
        }

        .exam-submit-overlay.active {
            display: flex;
        }

        .exam-submit-card {
            width: min(440px, 100%);
            border: 1px solid rgba(148, 163, 184, 0.28);
            border-radius: 20px;
            background: #ffffff;
            padding: 1.45rem;
            text-align: center;
            box-shadow: 0 28px 72px rgba(15, 23, 42, 0.3);
        }

        .exam-submit-icon {
            display: inline-flex;
            width: 52px;
            height: 52px;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: #ccfbf1;
            color: #0f766e;
            font-size: 1.35rem;
            font-weight: 900;
        }

        .exam-submit-card h2 {
            margin: 0.85rem 0 0;
            color: #0f172a;
            font-size: 1.22rem;
        }

        .exam-submit-card p {
            margin: 0.65rem 0 0;
            color: #64748b;
            font-size: 0.86rem;
            line-height: 1.6;
        }

        .exam-submit-summary {
            margin-top: 0.9rem;
            border-radius: 14px;
            background: #f8fafc;
            padding: 0.78rem;
            color: #334155;
            font-size: 0.82rem;
            font-weight: 800;
        }

        .exam-submit-actions {
            display: flex;
            justify-content: center;
            gap: 0.65rem;
            margin-top: 1rem;
        }

        .exam-cancel-btn {
            background: #eef2f7;
            color: #475569;
        }

        .exam-lock-card {
            width: min(430px, 100%);
            border-radius: 18px;
            background: #ffffff;
            padding: 1.4rem;
            text-align: center;
            box-shadow: 0 24px 64px rgba(15, 23, 42, 0.28);
        }

        .exam-lock-card h2 {
            margin: 0;
            color: #9a3412;
            font-size: 1.18rem;
        }

        .exam-lock-card p {
            margin: 0.72rem 0 1rem;
            color: #64748b;
            font-size: 0.85rem;
            line-height: 1.6;
        }

        .exam-toast {
            position: fixed;
            right: 1rem;
            bottom: 1rem;
            z-index: 10001;
            display: none;
            max-width: min(380px, calc(100vw - 2rem));
            border-radius: 14px;
            background: #9a3412;
            padding: 0.85rem 1rem;
            color: #ffffff;
            font-size: 0.82rem;
            font-weight: 800;
            box-shadow: 0 14px 32px rgba(15, 23, 42, 0.22);
        }

        .exam-toast.active {
            display: block;
        }

        @media (max-width: 980px) {
            html,
            body {
                height: auto;
                overflow: visible;
            }

            .class-exam-page {
                min-height: auto;
                height: auto;
                overflow: visible;
                justify-content: flex-start;
            }

            .class-exam-intro h1 {
                white-space: normal;
            }

            .exam-code-form {
                grid-template-columns: 1fr;
            }

            .exam-workspace-body {
                grid-template-columns: 220px minmax(0, 1fr);
            }
        }

        @media (max-width: 680px) {
            .class-exam-page {
                padding: 5.8rem 1rem 2rem;
            }

            .class-exam-points {
                grid-template-columns: 1fr;
            }

            .class-exam-shell {
                padding: 1.15rem;
            }

            .exam-workspace-header {
                min-height: auto;
                flex-wrap: wrap;
                padding: 0.7rem;
            }

            .exam-workspace-title {
                order: 3;
                width: 100%;
                text-align: left;
            }

            .exam-workspace-body {
                grid-template-columns: 1fr;
                overflow-y: auto;
                padding: 0.7rem;
            }

            .exam-sidebar {
                min-height: auto;
            }

            .exam-question-card {
                min-height: 520px;
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
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>


                <li><a href="${pageContext.request.contextPath}/exam-room" class="active">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
            </ul>

            <% if (user != null) { %>
                <div class="navbar-user-controls">
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                    <div class="nav-avatar-dropdown">
                        <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                            <% if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                <img src="<%= h(user.getAvatarUrl()) %>" alt="Avatar">
                            <% } else { %>
                                <span class="nav-avatar-initials"><%= h(initials) %></span>
                            <% } %>
                        </div>
                        <div class="dropdown-menu-popup">
                            <a href="${pageContext.request.contextPath}/profile">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
                                <span><%= profileMenuLabel %></span>
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

    <main class="class-exam-page">
        <div class="class-exam-topbar">
            <a class="class-exam-back" href="<%= classId != null && !classId.trim().isEmpty()
                    ? request.getContextPath() + "/classroom?id=" + h(classId) + "#tab-exams"
                    : request.getContextPath() + "/exam-room" %>">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M19 12H5"/>
                    <path d="m12 19-7-7 7-7"/>
                </svg>
                <span>Quay trở lại</span>
            </a>
        </div>

        <% if (!hasClassExamContext) { %>
        <section class="class-exam-intro">
            <h1>Nhập mã đề thi lớp học</h1>
            <p>Mỗi bài thi lớp học chỉ mở cho học viên hợp lệ trong lớp. Hãy nhập đúng mã đề thi do giảng viên cung cấp để xem thông tin bài, thời lượng và trạng thái làm bài.</p>
        </section>
        <% } else { %>
        <section class="class-exam-intro" style="text-align: center;">
            <h1>Chuẩn bị làm bài thi</h1>
            <p>Vui lòng đảm bảo kết nối mạng ổn định và chuẩn bị sẵn sàng trước khi vào phòng thi. Thời gian sẽ bắt đầu đếm ngược ngay khi bạn click bắt đầu.</p>
        </section>
        <% } %>

        <div class="class-exam-shell" <%= hasClassExamContext ? "style=\"max-width: 720px;\"" : "" %>>
            <section class="class-exam-hero">
                <% if (!hasClassExamContext) { %>
                <section class="exam-code-panel">
                    <div class="exam-code-title">
                        <span class="exam-code-icon" aria-hidden="true">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M15 7h3a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2h3"/>
                                <path d="M9 7a3 3 0 0 1 6 0"/>
                                <path d="M9 7h6"/>
                                <path d="M9 13h6"/>
                                <path d="M9 17h4"/>
                            </svg>
                        </span>
                        <h2>Mã đề thi</h2>
                    </div>
                    <p>Nhập mã đề thi được gửi trong lớp học hoặc thông báo từ giảng viên.</p>
                    <form class="exam-code-form" id="classExamCodeForm" action="${pageContext.request.contextPath}/class-exam-room" method="GET">
                        <% if (classId != null && !classId.trim().isEmpty()) { %>
                            <input type="hidden" name="classId" value="<%= h(classId) %>">
                        <% } %>
                        <input class="exam-code-input" id="classExamCode" type="text" name="code" autocomplete="off" placeholder="VD: HIPZI-TOAN10-01" aria-label="Mã đề thi" value="<%= h(examCode) %>">
                        <button class="exam-code-submit" id="classExamCodeSubmit" type="submit" <%= hasClassExamContext ? "" : "disabled" %>>Hiển thị bài thi <span aria-hidden="true">›</span></button>
                        <div class="exam-code-error <%= examLookupError != null && !examLookupError.isEmpty() ? "active" : "" %>" id="classExamCodeError"><%= h(examLookupError != null && !examLookupError.isEmpty() ? examLookupError : "Vui lòng nhập mã đề thi trước khi tiếp tục.") %></div>
                        <div class="exam-code-help">Mã đề được giáo viên cung cấp trong lớp học. Vui lòng nhập đúng chữ hoa, số và dấu gạch ngang nếu có.</div>
                    </form>
                </section>
                <% } %>

                <section class="exam-result-panel <%= hasClassExamContext ? "active" : "" %>" id="classExamResult" aria-live="polite" <%= hasClassExamContext ? "style=\"margin-top: 0; padding-top: 0;\"" : "" %>>
                    <div class="exam-found-label">Đã tìm thấy bài thi</div>
                    <h2 id="examResultTitle"><%= h(examTitle != null && !examTitle.trim().isEmpty() ? examTitle : "Bài kiểm tra lớp học") %></h2>
                    <div class="exam-meta-list">
                        <div class="exam-meta-item">
                            <span>Mã đề</span>
                            <strong id="examResultCode"><%= h(hasClassExamContext ? examCode : "HIPZI-CLASS") %></strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Thời lượng</span>
                            <strong><%= examDurationMinutes %> phút</strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Lớp học</span>
                            <strong><%= h(classroomTitle) %></strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Thời gian mở đề</span>
                            <strong><%= h(examStartLabel) %></strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Thời gian đóng đề</span>
                            <strong><%= h(examEndLabel) %></strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Quyền truy cập</span>
                            <strong><%= h(examAvailabilityMessage != null ? examAvailabilityMessage : "Học viên trong lớp") %></strong>
                        </div>
                    </div>
                    <a href="#" class="exam-enter-btn <%= canEnterExam ? "" : "disabled" %>" id="examEnterBtn" aria-disabled="<%= canEnterExam ? "false" : "true" %>"><%= canEnterExam ? "Vào phòng làm bài" : "Chưa thể vào phòng làm bài" %></a>
                </section>

                <div class="class-exam-points">
                    <div class="class-exam-point">
                        <div class="class-exam-point-head">
                            <span class="class-exam-point-icon" aria-hidden="true">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                                    <circle cx="9" cy="7" r="4"/>
                                    <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
                                    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                                </svg>
                            </span>
                            <strong>Riêng theo lớp</strong>
                        </div>
                        <span>Chỉ học viên trong lớp mới truy cập được đề thi.</span>
                    </div>
                    <div class="class-exam-point">
                        <div class="class-exam-point-head">
                            <span class="class-exam-point-icon" aria-hidden="true">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="9"/>
                                    <path d="M12 7v5l3 2"/>
                                </svg>
                            </span>
                            <strong>Có thời hạn</strong>
                        </div>
                        <span>Giảng viên có thể đặt giờ mở bài và hạn nộp.</span>
                    </div>
                    <div class="class-exam-point">
                        <div class="class-exam-point-head">
                            <span class="class-exam-point-icon" aria-hidden="true">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M3 3v18h18"/>
                                    <path d="m7 14 4-4 3 3 5-6"/>
                                </svg>
                            </span>
                            <strong>Theo dõi tiến độ</strong>
                        </div>
                        <span>Kết quả hỗ trợ đánh giá quá trình học trong lớp.</span>
                    </div>
                </div>
            </section>
        </div>
    </main>

    <section class="exam-workspace" id="examWorkspace" aria-label="Không gian làm bài thi">
        <header class="exam-workspace-header">
            <div class="exam-workspace-brand">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="">
                <div>
                    <strong>HIPZI Classroom Exam</strong>
                    <span>Không gian làm bài tập trung</span>
                </div>
            </div>
            <div class="exam-workspace-title">
                <strong><%= h(examTitle) %></strong>
                <span>Mã đề <%= h(examCode) %> · <%= examQuestionCount %> câu hỏi · Tự động ghi nhận vi phạm</span>
            </div>
            <div class="exam-workspace-meta">
                <span class="exam-status-pill">Đang làm bài</span>
                <span class="exam-violation-pill">Vi phạm: <strong id="examViolationCount">0</strong></span>
            </div>
        </header>

        <div class="exam-workspace-body">
            <aside class="exam-sidebar">
                <div class="exam-timer">
                    <span>Thời gian còn lại</span>
                    <strong id="examTimer">45:00</strong>
                </div>
                <div>
                    <span class="exam-sidebar-section-title">Tiến độ làm bài</span>
                    <div class="exam-progress-track" style="margin-top: 0.55rem;"><span id="examProgressBar"></span></div>
                    <span id="examProgressText" style="display:block; margin-top:0.45rem; color:#64748b; font-size:0.75rem; font-weight:800;">Đã trả lời 0/<%= examQuestionCount %> câu</span>
                </div>
                <div>
                    <span class="exam-sidebar-section-title">Danh sách câu hỏi</span>
                    <div class="exam-question-grid" id="examQuestionGrid" style="margin-top: 0.65rem;"></div>
                </div>
                <div class="exam-sidebar-note">
                    Không rời tab, đổi cửa sổ hoặc thoát toàn màn hình trong khi làm bài. Mỗi lần vi phạm đều được ghi nhận.
                </div>
            </aside>

            <section class="exam-question-card">
                <div class="exam-question-head">
                    <span id="examQuestionLabel">Câu hỏi 1</span>
                    <strong id="examQuestionMode"><%= "essay".equals(examType) ? "Nhập câu trả lời" : "Chọn một đáp án đúng" %></strong>
                </div>
                <div class="exam-question-content">
                    <h2 id="examQuestionText"></h2>
                    <div class="exam-option-list" id="examOptionList"></div>
                </div>
                <footer class="exam-question-footer">
                    <button class="exam-nav-btn" id="examPrevBtn" type="button">Câu trước</button>
                    <button class="exam-nav-btn" id="examNextBtn" type="button">Câu tiếp theo</button>
                    <button class="exam-submit-btn" id="examSubmitBtn" type="button">Nộp bài</button>
                </footer>
            </section>
        </div>

        <div class="exam-lock-overlay" id="examLockOverlay">
            <div class="exam-lock-card">
                <h2>Đã ghi nhận rời không gian làm bài</h2>
                <p id="examLockMessage">Bạn cần quay lại chế độ toàn màn hình để tiếp tục làm bài.</p>
                <button class="exam-lock-btn" id="examReturnFullscreenBtn" type="button">Quay lại toàn màn hình</button>
            </div>
        </div>
        <div class="exam-submit-overlay" id="examSubmitOverlay" role="dialog" aria-modal="true" aria-labelledby="examSubmitTitle">
            <div class="exam-submit-card">
                <div class="exam-submit-icon" aria-hidden="true">✓</div>
                <h2 id="examSubmitTitle">Xác nhận nộp bài?</h2>
                <p>Sau khi xác nhận, bài làm sẽ kết thúc và bạn không thể tiếp tục chỉnh sửa đáp án.</p>
                <div class="exam-submit-summary" id="examSubmitSummary">Bạn đã trả lời 0/<%= examQuestionCount %> câu.</div>
                <div class="exam-submit-actions">
                    <button class="exam-cancel-btn" id="examCancelSubmitBtn" type="button">Tiếp tục làm bài</button>
                    <button class="exam-confirm-btn" id="examConfirmSubmitBtn" type="button">Xác nhận nộp bài</button>
                </div>
            </div>
        </div>
        <div class="exam-toast" id="examToast"></div>
    </section>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
    <script>
    (function () {
        var form = document.getElementById('classExamCodeForm');
        var input = document.getElementById('classExamCode');
        var error = document.getElementById('classExamCodeError');
        var result = document.getElementById('classExamResult');
        var submit = document.getElementById('classExamCodeSubmit');
        var enterBtn = document.getElementById('examEnterBtn');
        var workspace = document.getElementById('examWorkspace');
        var timer = document.getElementById('examTimer');
        var progressBar = document.getElementById('examProgressBar');
        var progressText = document.getElementById('examProgressText');
        var questionGrid = document.getElementById('examQuestionGrid');
        var questionLabel = document.getElementById('examQuestionLabel');
        var questionMode = document.getElementById('examQuestionMode');
        var questionText = document.getElementById('examQuestionText');
        var optionList = document.getElementById('examOptionList');
        var prevBtn = document.getElementById('examPrevBtn');
        var nextBtn = document.getElementById('examNextBtn');
        var examSubmitBtn = document.getElementById('examSubmitBtn');
        var violationCount = document.getElementById('examViolationCount');
        var lockOverlay = document.getElementById('examLockOverlay');
        var lockMessage = document.getElementById('examLockMessage');
        var returnFullscreenBtn = document.getElementById('examReturnFullscreenBtn');
        var submitOverlay = document.getElementById('examSubmitOverlay');
        var submitSummary = document.getElementById('examSubmitSummary');
        var cancelSubmitBtn = document.getElementById('examCancelSubmitBtn');
        var confirmSubmitBtn = document.getElementById('examConfirmSubmitBtn');
        var toast = document.getElementById('examToast');

        var examQuestions = [
        <% if (examQuestions != null) {
            for (int i = 0; i < examQuestions.size(); i++) {
                ClassroomExamQuestion question = examQuestions.get(i);
        %>
            {
                id: "<%= js(question.getId()) %>",
                text: "<%= js(question.getQuestionText()) %>",
                options: ["<%= js(question.getOptionA()) %>", "<%= js(question.getOptionB()) %>", "<%= js(question.getOptionC()) %>", "<%= js(question.getOptionD()) %>"]
            }<%= i + 1 < examQuestions.size() ? "," : "" %>
        <%  }
        } %>
        ];

        var activeExamCode = input ? input.value.trim().toUpperCase() : '';
        var examType = "<%= js(examType) %>";
        var examDurationMinutes = <%= examDurationMinutes %>;
        var hasLoadedExam = <%= hasClassExamContext && examQuestionCount > 0 ? "true" : "false" %>;
        var canEnterExam = <%= canEnterExam ? "true" : "false" %>;
        var activeAttemptId = '';
        var answers = {};
        var currentQuestion = 0;
        var secondsLeft = examDurationMinutes * 60;
        var timerInterval = null;
        var examRunning = false;
        var fullscreenReady = false;
        var violations = [];
        var lastViolationAt = 0;
        var toastTimeout = null;
        var isAutoStart = "<%= "true".equals(request.getParameter("autoStart")) %>" === "true";

        // Nếu là autoStart, không cần form/input/result – chạy thẳng vào exam
        if (!isAutoStart && (!form || !input || !result)) return;

        function syncSubmitState() {
            if (submit) submit.disabled = input.value.trim().length === 0;
        }

        function showToast(message) {
            if (!toast) return;
            toast.textContent = message;
            toast.classList.add('active');
            clearTimeout(toastTimeout);
            toastTimeout = setTimeout(function () {
                toast.classList.remove('active');
            }, 3200);
        }

        function formatTime(value) {
            var minutes = Math.floor(value / 60);
            var seconds = value % 60;
            return String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
        }

        function renderTimer() {
            timer.textContent = formatTime(secondsLeft);
        }

        function answeredCount() {
            return Object.keys(answers).length;
        }

        function renderProgress() {
            var completed = answeredCount();
            progressBar.style.width = Math.round((completed / examQuestions.length) * 100) + '%';
            progressText.textContent = 'Đã trả lời ' + completed + '/' + examQuestions.length + ' câu';
        }

        function renderQuestionGrid() {
            questionGrid.innerHTML = '';
            examQuestions.forEach(function (_, index) {
                var button = document.createElement('button');
                button.type = 'button';
                button.className = 'exam-question-number';
                if (index === currentQuestion) button.classList.add('current');
                if (answers[index]) button.classList.add('answered');
                button.textContent = index + 1;
                button.addEventListener('click', function () {
                    currentQuestion = index;
                    renderQuestion();
                });
                questionGrid.appendChild(button);
            });
        }

        function renderQuestion() {
            var question = examQuestions[currentQuestion];
            questionLabel.textContent = 'Câu hỏi ' + (currentQuestion + 1);
            questionText.textContent = question.text;
            optionList.innerHTML = '';
            if (examType === 'essay') {
                questionMode.textContent = 'Nhập câu trả lời';
                var textarea = document.createElement('textarea');
                textarea.className = 'exam-essay-answer';
                textarea.placeholder = 'Nhập câu trả lời của bạn tại đây...';
                textarea.value = answers[currentQuestion] || '';
                textarea.addEventListener('input', function () {
                    var value = textarea.value.trim();
                    if (value) {
                        answers[currentQuestion] = textarea.value;
                    } else {
                        delete answers[currentQuestion];
                    }
                    renderQuestionGrid();
                    renderProgress();
                });
                optionList.appendChild(textarea);
            } else {
                questionMode.textContent = 'Chọn một đáp án đúng';
                question.options.forEach(function (option, index) {
                    var key = String.fromCharCode(65 + index);
                    var button = document.createElement('button');
                    button.type = 'button';
                    button.className = 'exam-option';
                    if (answers[currentQuestion] === key) button.classList.add('selected');
                    button.innerHTML = '<span class="exam-option-key">' + key + '</span><span></span>';
                    button.lastChild.textContent = option;
                    button.addEventListener('click', function () {
                        answers[currentQuestion] = key;
                        renderQuestion();
                        renderQuestionGrid();
                        renderProgress();
                    });
                    optionList.appendChild(button);
                });
            }
            prevBtn.disabled = currentQuestion === 0;
            nextBtn.disabled = currentQuestion === examQuestions.length - 1;
            renderQuestionGrid();
            renderProgress();
        }

        function persistViolations() {
            try {
                localStorage.setItem('hipziClassExamViolations:' + activeExamCode, JSON.stringify({
                    examCode: activeExamCode,
                    count: violations.length,
                    events: violations
                }));
            } catch (ignored) {
            }
        }

        function recordViolation(reason) {
            if (!examRunning) return;
            var now = Date.now();
            if (now - lastViolationAt < 900) return;
            lastViolationAt = now;
            violations.push({
                number: violations.length + 1,
                reason: reason,
                occurredAt: new Date(now).toISOString()
            });
            violationCount.textContent = violations.length;
            persistViolations();
            showToast('Đã ghi nhận vi phạm #' + violations.length + ': ' + reason + '.');
        }

        function showLock(message) {
            if (!lockOverlay) return;
            lockMessage.textContent = message;
            lockOverlay.classList.add('active');
        }

        function hideLock() {
            if (lockOverlay) lockOverlay.classList.remove('active');
        }

        function showSubmitConfirmation() {
            submitSummary.textContent = 'Bạn đã trả lời ' + answeredCount() + '/' + examQuestions.length
                    + ' câu. Vi phạm ghi nhận: ' + violations.length + '.';
            submitOverlay.classList.add('active');
            cancelSubmitBtn.focus();
        }

        function hideSubmitConfirmation() {
            submitOverlay.classList.remove('active');
        }

        function requestExamFullscreen(isInitial) {
            if (!workspace.requestFullscreen) {
                hideLock();
                return Promise.resolve();
            }
            return workspace.requestFullscreen().then(function () {
                fullscreenReady = true;
                hideLock();
            }).catch(function () {
                var title = document.querySelector('#examLockOverlay h2');
                if (isInitial) {
                    if (title) {
                        title.textContent = 'Sẵn sàng làm bài';
                        title.style.color = '#0f766e';
                    }
                    returnFullscreenBtn.textContent = 'Bắt đầu toàn màn hình';
                    showLock('Nhấn nút bên dưới để cấp quyền toàn màn hình và làm bài.');
                } else {
                    if (title) {
                        title.textContent = 'Đã ghi nhận rời không gian làm bài';
                        title.style.color = '';
                    }
                    returnFullscreenBtn.textContent = 'Quay lại toàn màn hình';
                    showLock('Trình duyệt chưa cho phép toàn màn hình. Hãy bấm nút bên dưới để tiếp tục.');
                }
            });
        }

        var examSubmitting = false;

        function finishExam(autoSubmit) {
            if (!examRunning || examSubmitting) return;
            examSubmitting = true;
            clearInterval(timerInterval);
            document.body.classList.remove('exam-running');
            workspace.classList.remove('active');
            hideLock();
            hideSubmitConfirmation();
            if (document.fullscreenElement && document.exitFullscreen) {
                document.exitFullscreen().catch(function () {});
            }
            
            examSubmitBtn.disabled = true;
            examSubmitBtn.textContent = 'Đang nộp...';

            var payload = {
                examId: "<%= hasClassExamContext ? classroomExam.getId() : "" %>",
                attemptId: activeAttemptId,
                violationCount: violations.length,
                answers: (function() {
                    // Convert index-keyed {0: 'A'} to UUID-keyed {'uuid': 'A'}
                    var uuidAnswers = {};
                    Object.keys(answers).forEach(function(indexStr) {
                        var idx = parseInt(indexStr, 10);
                        if (examQuestions[idx]) {
                            uuidAnswers[examQuestions[idx].id] = answers[indexStr];
                        }
                    });
                    return uuidAnswers;
                })()
            };

            fetch('<%= request.getContextPath() %>/api/class-exam/submit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            })
            .then(function(res) {
                if (res.status === 401) {
                    throw new Error('SESSION_EXPIRED');
                }
                return res.json();
            })
            .then(function(data) {
                examRunning = false;
                examSubmitting = false;
                if (data.success) {
                    window.alert((autoSubmit ? 'Đã hết giờ. ' : '') + 'Nộp bài thành công!\nĐiểm của bạn: ' + data.score + '\nVi phạm ghi nhận: ' + violations.length);
                } else {
                    window.alert('Thông báo: ' + data.message);
                }
                <% if (classId != null && !classId.trim().isEmpty()) { %>
                    window.location.href = "<%= request.getContextPath() %>/classroom?id=<%= h(classId) %>#tab-exams";
                <% } else { %>
                    window.location.href = "<%= request.getContextPath() %>/exam-room";
                <% } %>
            })
            .catch(function(err) {
                examSubmitting = false;
                if (err && err.message === 'SESSION_EXPIRED') {
                    window.alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại để nộp bài.');
                    window.location.href = '<%= request.getContextPath() %>/login';
                    return;
                }
                window.alert('Lỗi mạng: Không thể nộp bài, hệ thống sẽ lưu tạm. Vui lòng kiểm tra kết nối và ấn Nộp lại.');
                examSubmitBtn.disabled = false;
                examSubmitBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"></path><path d="m12 5 7 7-7 7"></path></svg> Nộp bài';
                document.body.classList.add('exam-running');
                workspace.classList.add('active');
            });
        }

        function startExam() {
            answers = {};
            currentQuestion = 0;
            secondsLeft = examDurationMinutes * 60;
            violations = [];
            lastViolationAt = 0;
            fullscreenReady = false;
            activeAttemptId = '';
            violationCount.textContent = '0';
            persistViolations();
            renderTimer();
            renderQuestion();
            document.body.classList.add('exam-running');
            workspace.classList.add('active');
            examRunning = true;
            window.history.pushState({ hipziClassExam: true }, '', window.location.href);
            requestExamFullscreen(true);
            
            // Notify server that exam has started
            fetch('<%= request.getContextPath() %>/api/class-exam/start', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ examId: "<%= hasClassExamContext ? classroomExam.getId() : "" %>" })
            }).then(function(response) {
                return response.json().then(function(data) {
                    if (!response.ok || !data.success) {
                        throw new Error(data.message || 'Không thể bắt đầu lượt làm bài.');
                    }
                    activeAttemptId = data.attemptId || '';
                });
            }).catch(function(e) {
                console.warn("Lỗi đồng bộ trạng thái bắt đầu làm bài:", e);
                window.alert(e.message || "Không thể bắt đầu lượt làm bài.");
                examRunning = false;
                if (timerInterval) clearInterval(timerInterval);
                workspace.classList.remove('active');
                document.body.classList.remove('exam-running');
            });

            timerInterval = setInterval(function () {
                secondsLeft -= 1;
                renderTimer();
                if (secondsLeft <= 0) {
                    finishExam(true);
                }
            }, 1000);
        }

        if (input) {
            input.addEventListener('input', function () {
                syncSubmitState();
                if (input.value.trim()) {
                    error.classList.remove('active');
                }
            });
            syncSubmitState();
        }

        if (form) {
            form.addEventListener('submit', function (event) {
                var code = input.value.trim();
                if (!code) {
                    event.preventDefault();
                    error.classList.add('active');
                    result.classList.remove('active');
                    input.focus();
                }
            });
        }

        if (enterBtn) {
            enterBtn.addEventListener('click', function (event) {
                event.preventDefault();
                if (!hasLoadedExam || !canEnterExam) {
                    window.alert("<%= js(examAvailabilityMessage != null && !examAvailabilityMessage.isEmpty() ? examAvailabilityMessage : "Đề thi chưa có câu hỏi hoặc bạn chưa có quyền truy cập.") %>");
                    if (input) input.focus();
                    return;
                }
                startExam();
            });
        }


        prevBtn.addEventListener('click', function () {
            if (currentQuestion > 0) {
                currentQuestion -= 1;
                renderQuestion();
            }
        });

        nextBtn.addEventListener('click', function () {
            if (currentQuestion < examQuestions.length - 1) {
                currentQuestion += 1;
                renderQuestion();
            }
        });

        examSubmitBtn.addEventListener('click', function () {
            showSubmitConfirmation();
        });

        cancelSubmitBtn.addEventListener('click', function () {
            hideSubmitConfirmation();
            examSubmitBtn.focus();
        });

        confirmSubmitBtn.addEventListener('click', function () {
            finishExam(false);
        });

        returnFullscreenBtn.addEventListener('click', function () {
            requestExamFullscreen();
        });

        document.addEventListener('visibilitychange', function () {
            if (examRunning && document.hidden) {
                recordViolation('Rời tab làm bài');
            }
        });

        window.addEventListener('blur', function () {
            if (examRunning) {
                recordViolation('Chuyển sang cửa sổ khác');
            }
        });

        document.addEventListener('fullscreenchange', function () {
            if (!examRunning) return;
            if (document.fullscreenElement === workspace) {
                fullscreenReady = true;
                hideLock();
                return;
            }
            if (fullscreenReady) {
                recordViolation('Thoát chế độ toàn màn hình');
            }
            showLock('Bạn cần quay lại chế độ toàn màn hình để tiếp tục làm bài.');
        });

        window.addEventListener('popstate', function () {
            if (!examRunning) return;
            recordViolation('Dùng nút quay lại của trình duyệt');
            window.history.pushState({ hipziClassExam: true }, '', window.location.href);
        });

        document.addEventListener('keydown', function (event) {
            if (!examRunning) return;
            var key = event.key.toLowerCase();
            var blocked = event.key === 'F5'
                    || event.key === 'F11'
                    || event.key === 'Escape'
                    || ((event.ctrlKey || event.metaKey) && ['l', 'n', 'r', 't', 'w'].indexOf(key) >= 0)
                    || (event.altKey && event.key === 'ArrowLeft');
            if (blocked) {
                event.preventDefault();
                recordViolation('Dùng phím tắt rời không gian làm bài');
            }
        });

        window.addEventListener('beforeunload', function (event) {
            if (!examRunning) return;
            event.preventDefault();
            event.returnValue = '';
        });

        workspace.addEventListener('contextmenu', function (event) {
            if (examRunning) event.preventDefault();
        });

        if (isAutoStart) {
            if (hasLoadedExam && canEnterExam) {
                var pageEl = document.querySelector('.class-exam-page');
                var navEl = document.querySelector('.navbar');
                if (pageEl) pageEl.style.display = 'none';
                if (navEl) navEl.style.display = 'none';
                startExam();
            } else {
                window.alert("<%= js(examAvailabilityMessage != null && !examAvailabilityMessage.isEmpty() ? examAvailabilityMessage : "Đề thi chưa có câu hỏi hoặc bạn chưa có quyền truy cập.") %>");
            }
        }
    })();
    </script>
</body>
</html>
