<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hipzi.model.User" %>
<%@ page import="com.hipzi.model.Classroom" %>
<%@ page import="com.hipzi.model.ClassroomExam" %>
<%@ page import="com.hipzi.model.ClassroomExamQuestion" %>
<%@ page import="com.hipzi.dto.ClassroomExamAttemptDto" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Classroom classroom = (Classroom) request.getAttribute("classroom");
    ClassroomExam exam = (ClassroomExam) request.getAttribute("exam");
    List<ClassroomExamQuestion> questions = (List<ClassroomExamQuestion>) request.getAttribute("questions");
    List<ClassroomExamAttemptDto> attempts = (List<ClassroomExamAttemptDto>) request.getAttribute("attempts");

    String initials = "U";
    if (user.getDisplayName() != null && !user.getDisplayName().trim().isEmpty()) {
        initials = String.valueOf(user.getDisplayName().trim().charAt(0)).toUpperCase();
    }
    String navProfileLabel = user.getDisplayName() != null ? user.getDisplayName() : "Hồ sơ cá nhân";

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    int totalQuestions = questions != null ? questions.size() : 0;
    int totalAttempts = attempts != null ? attempts.size() : 0;

    double avgScore = 0;
    int violationSum = 0;
    int completedCount = 0;
    if (attempts != null && totalAttempts > 0) {
        double scoreSum = 0;
        int validScores = 0;
        for (ClassroomExamAttemptDto dto : attempts) {
            violationSum += dto.getAttempt().getViolationCount();
            if ("completed".equals(dto.getAttempt().getStatus())) completedCount++;
            if (dto.getAttempt().getScore() != null) {
                scoreSum += dto.getAttempt().getScore();
                validScores++;
            }
        }
        if (validScores > 0) avgScore = scoreSum / validScores;
    }
%>
<%!
    private String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý bài thi – <%= h(exam.getTitle()) %> – HIPZI</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <style>
        :root {
            --primary:        #0f766e;
            --primary-dark:   #115e59;
            --primary-light:  #ccfbf1;
            --primary-mid:    #5eead4;
            --accent:         #7c3aed;
            --accent-light:   #ede9fe;
            --bg:             #f1f5f9;
            --surface:        #ffffff;
            --surface-2:      #f8fafc;
            --text:           #0f172a;
            --text-2:         #334155;
            --text-muted:     #64748b;
            --border:         #e2e8f0;
            --border-dark:    #cbd5e1;
            --danger:         #ef4444;
            --danger-light:   #fee2e2;
            --warning:        #f59e0b;
            --warning-light:  #fef3c7;
            --success:        #10b981;
            --success-light:  #d1fae5;
            --info:           #3b82f6;
            --info-light:     #dbeafe;
            --font:           "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;
            --r-sm:           8px;
            --r-md:           14px;
            --r-lg:           20px;
            --r-xl:           28px;
            --shadow-sm:      0 2px 8px rgba(15,23,42,.05);
            --shadow-md:      0 8px 24px rgba(15,23,42,.08);
            --shadow-lg:      0 16px 48px rgba(15,23,42,.12);
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: var(--font);
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .exam-hero {
            background: linear-gradient(135deg, #0f766e 0%, #0d9488 50%, #0891b2 100%);
            padding: calc(5.5rem + 80px) 0 6.5rem;
            margin-top: -80px;
            position: relative;
            overflow: hidden;
        }
        .exam-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background:
                radial-gradient(ellipse at 10% 50%, rgba(255,255,255,.08) 0%, transparent 60%),
                radial-gradient(ellipse at 90% 20%, rgba(255,255,255,.06) 0%, transparent 50%);
            pointer-events: none;
        }
        .exam-hero::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 0; right: 0;
            height: 64px;
            background: var(--bg);
            clip-path: ellipse(55% 100% at 50% 100%);
        }

        .hero-inner {
            max-width: 1140px;
            margin: 0 auto;
            padding: 0 1.5rem;
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }


        .hero-exam-code {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: rgba(255,255,255,.18);
            border: 1px solid rgba(255,255,255,.3);
            color: #fff;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: .08em;
            padding: 0.3rem 0.75rem;
            border-radius: 999px;
            margin-bottom: 0; /* Handled by wrapper now */
            backdrop-filter: blur(8px);
        }

        .hero-back-link {
            position: absolute;
            top: 0;
            left: 1.5rem;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            color: rgba(255,255,255,.75);
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            transition: all .2s;
            z-index: 2;
        }
        .hero-back-link:hover {
            color: #fff;
            transform: translateX(-4px);
        }

        .hero-title {
            font-size: clamp(2rem, 4vw, 3rem);
            font-weight: 800;
            color: #fff;
            line-height: 1.1;
            margin-bottom: 0; /* Handled by wrapper now */
            text-transform: capitalize;
        }

        .hero-meta {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.8rem;
            flex-wrap: wrap;
        }
        .hero-meta-item {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            color: rgba(255,255,255,.9);
            font-size: 0.9rem;
            font-weight: 600;
        }
        .hero-meta-item svg { flex-shrink: 0; opacity: .9; }
        
        .meta-separator {
            color: rgba(255,255,255,.4);
            font-size: 1.2rem;
            line-height: 1;
        }

        .hero-status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.45rem 1rem;
            border-radius: 999px;
            font-weight: 700;
            font-size: 0.82rem;
            letter-spacing: .03em;
        }
        .hero-status-badge.open   { background: rgba(16,185,129,.25); color: #6ee7b7; border: 1px solid rgba(16,185,129,.35); }
        .hero-status-badge.closed { background: rgba(239,68,68,.25);  color: #fca5a5; border: 1px solid rgba(239,68,68,.35); }
        .hero-status-badge.upcoming { background: rgba(245,158,11,.25); color: #fcd34d; border: 1px solid rgba(245,158,11,.35); }

        .main-content {
            max-width: 1140px;
            margin: 0 auto;
            width: 100%;
            padding: 2rem 1.5rem 4rem;
            flex-grow: 1;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }
        @media (max-width: 900px) { .stats-row { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 480px) { .stats-row { grid-template-columns: 1fr; } }

        .stat-card {
            background: var(--surface);
            border-radius: var(--r-lg);
            padding: 1.4rem 1.5rem;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            display: flex;
            align-items: center;
            gap: 1.1rem;
            transition: box-shadow .2s, transform .2s;
        }
        .stat-card:hover { box-shadow: var(--shadow-md); transform: translateY(-2px); }

        .stat-icon {
            width: 52px; height: 52px;
            border-radius: var(--r-md);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .stat-icon.blue   { background: var(--info-light);    color: var(--info); }
        .stat-icon.green  { background: var(--success-light); color: var(--success); }
        .stat-icon.red    { background: var(--danger-light);  color: var(--danger); }
        .stat-icon.amber  { background: var(--warning-light); color: var(--warning); }

        .stat-label { font-size: 0.78rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: .06em; margin-bottom: 0.25rem; }
        .stat-value { font-size: 2rem; font-weight: 800; color: var(--text); line-height: 1; }
        .stat-sub { font-size: 0.75rem; color: var(--text-muted); margin-top: 0.2rem; }

        .tab-bar {
            display: flex; gap: 0;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--r-lg);
            padding: 0.4rem;
            margin-bottom: 1.5rem;
            box-shadow: var(--shadow-sm);
            overflow-x: auto; scrollbar-width: none;
        }
        .tab-bar::-webkit-scrollbar { display: none; }

        .tab-btn {
            flex: 1; display: flex; align-items: center; justify-content: center; gap: 0.5rem;
            background: none; border: none;
            padding: 0.7rem 1.2rem; border-radius: var(--r-md);
            font-size: 0.88rem; font-weight: 600; font-family: var(--font); color: var(--text-muted);
            cursor: pointer; transition: all .2s; white-space: nowrap;
        }
        .tab-btn:hover { background: var(--surface-2); color: var(--text); }
        .tab-btn.active {
            background: linear-gradient(135deg, var(--primary) 0%, #0891b2 100%);
            color: #fff; box-shadow: 0 4px 12px rgba(15,118,110,.3);
        }
        .tab-btn .tab-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 20px; height: 20px; border-radius: 999px;
            font-size: 0.72rem; font-weight: 700; padding: 0 5px;
        }
        .tab-btn.active .tab-count { background: rgba(255,255,255,.25); color: #fff; }
        .tab-btn:not(.active) .tab-count { background: var(--border); color: var(--text-muted); }

        .tab-pane { display: none; }
        .tab-pane.active { display: block; }

        .card { background: var(--surface); border-radius: var(--r-lg); border: 1px solid var(--border); box-shadow: var(--shadow-sm); overflow: hidden; }

        .card-header { display: flex; align-items: center; justify-content: space-between; padding: 1.2rem 1.5rem; border-bottom: 1px solid var(--border); gap: 1rem; }
        .card-header-title { font-size: 0.95rem; font-weight: 700; color: var(--text); display: flex; align-items: center; gap: 0.5rem; }
        .card-header-title svg { color: var(--primary); }

        .card-search { display: flex; align-items: center; gap: 0.5rem; background: var(--surface-2); border: 1px solid var(--border); border-radius: var(--r-sm); padding: 0.45rem 0.8rem; }
        .card-search input { background: none; border: none; outline: none; font-size: 0.85rem; font-family: var(--font); color: var(--text); width: 180px; }
        .card-search input::placeholder { color: var(--text-muted); }
        .card-search svg { color: var(--text-muted); flex-shrink: 0; }

        .attempts-table { width: 100%; border-collapse: collapse; }
        .attempts-table thead tr { background: var(--surface-2); }
        .attempts-table th { padding: 0.85rem 1.25rem; font-size: 0.75rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .06em; text-align: left; border-bottom: 1px solid var(--border); white-space: nowrap; }
        .attempts-table td { padding: 1rem 1.25rem; border-bottom: 1px solid var(--border); vertical-align: middle; font-size: 0.9rem; }
        .attempts-table tbody tr:last-child td { border-bottom: none; }
        .attempts-table tbody tr { transition: background .15s; }
        .attempts-table tbody tr:hover { background: #f8fafc; }

        .stu-cell { display: flex; align-items: center; gap: 0.75rem; }
        .stu-avatar { width: 38px; height: 38px; border-radius: 50%; background: linear-gradient(135deg, var(--primary-light), var(--primary-mid)); color: var(--primary-dark); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.9rem; flex-shrink: 0; object-fit: cover; }
        .stu-name { font-weight: 600; color: var(--text); font-size: 0.9rem; }
        .stu-email { font-size: 0.78rem; color: var(--text-muted); }

        .badge { display: inline-flex; align-items: center; gap: 0.3rem; padding: 0.28rem 0.7rem; border-radius: 999px; font-size: 0.75rem; font-weight: 700; }
        .badge::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .badge.submitted { background: var(--success-light); color: #047857; }
        .badge.in-progress { background: var(--warning-light); color: #92400e; }

        .score-chip { display: inline-flex; align-items: center; padding: 0.3rem 0.75rem; border-radius: var(--r-sm); font-weight: 700; font-size: 0.88rem; }
        .score-chip.high   { background: var(--success-light); color: #047857; }
        .score-chip.medium { background: var(--warning-light); color: #92400e; }
        .score-chip.low    { background: var(--danger-light);  color: #991b1b; }
        .score-chip.pending { background: var(--surface-2); color: var(--text-muted); border: 1px solid var(--border); }

        .violation-chip { display: inline-flex; align-items: center; gap: 0.35rem; font-size: 0.82rem; font-weight: 600; }
        .violation-chip.safe   { color: var(--success); }
        .violation-chip.flagged { color: var(--danger); }

        .empty-state { padding: 5rem 2rem; text-align: center; }
        .empty-icon { width: 72px; height: 72px; background: var(--surface-2); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.25rem; color: var(--border-dark); }
        .empty-state h3 { font-size: 1.05rem; font-weight: 700; color: var(--text-2); margin-bottom: 0.4rem; }
        .empty-state p { font-size: 0.88rem; color: var(--text-muted); }

        .q-list { display: flex; flex-direction: column; gap: 1rem; }
        .q-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--r-lg); overflow: hidden; box-shadow: var(--shadow-sm); transition: box-shadow .2s; }
        .q-card:hover { box-shadow: var(--shadow-md); }
        .q-card-header { display: flex; align-items: center; gap: 1rem; padding: 1rem 1.4rem; background: var(--surface-2); border-bottom: 1px solid var(--border); }
        .q-num { width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, var(--primary) 0%, #0891b2 100%); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.85rem; flex-shrink: 0; }
        .q-pts { margin-left: auto; background: var(--primary-light); color: var(--primary-dark); padding: 0.2rem 0.65rem; border-radius: 999px; font-size: 0.75rem; font-weight: 700; }
        .q-body { padding: 1.25rem 1.4rem; }
        .q-text { font-size: 1rem; font-weight: 600; color: var(--text); line-height: 1.6; margin-bottom: 1.25rem; }
        .q-options { list-style: none; display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
        @media (max-width: 600px) { .q-options { grid-template-columns: 1fr; } }
        .q-opt { display: flex; align-items: flex-start; gap: 0.7rem; padding: 0.85rem 1rem; border-radius: var(--r-md); border: 2px solid var(--border); background: var(--surface-2); font-size: 0.9rem; color: var(--text-2); transition: all .15s; }
        .q-opt.correct { background: var(--success-light); border-color: var(--success); color: #065f46; font-weight: 600; }
        .q-opt-key { width: 24px; height: 24px; border-radius: 6px; background: var(--border); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.75rem; color: var(--text-muted); flex-shrink: 0; }
        .q-opt.correct .q-opt-key { background: var(--success); color: #fff; }
        .q-opt-text { line-height: 1.5; padding-top: 0.05rem; }

        @media (max-width: 768px) { .attempts-table { display: block; overflow-x: auto; } .card-search { display: none; } }

        /* Transparent navbar overrides when over the dark green hero */
        .navbar:not(.scrolled) {
            background: transparent !important;
            border-bottom-color: transparent !important;
            box-shadow: none !important;
        }
        .navbar:not(.scrolled) .logo {
            color: #ffffff !important;
        }
        .navbar:not(.scrolled) .nav-links a {
            color: rgba(255,255,255,0.85) !important;
        }
        .navbar:not(.scrolled) .nav-links a:hover,
        .navbar:not(.scrolled) .nav-links a.active {
            color: #ffffff !important;
            background: rgba(255,255,255,0.15) !important;
            border-color: transparent !important;
            box-shadow: none !important;
        }
        .navbar:not(.scrolled) .nav-bell-trigger {
            color: #ffffff !important;
        }
        .navbar:not(.scrolled) .nav-avatar-frame {
            border-color: rgba(255,255,255,0.4) !important;
            background: rgba(255,255,255,0.1) !important;
        }
        .navbar:not(.scrolled) .nav-avatar-initials {
            color: #ffffff !important;
        }
        .student-result-card {
            border: 1px solid var(--border-light);
            border-radius: 12px;
            margin-bottom: 1rem;
            background: #fff;
            overflow: hidden;
            transition: box-shadow .2s, border-color .2s;
        }
        .student-result-card:hover {
            box-shadow: 0 4px 15px rgba(0,0,0,.05);
            border-color: var(--border-dark);
        }
        .student-row-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr 1.5fr;
            align-items: center;
            gap: 1rem;
        }
        .student-list-header {
            padding: 0 1.5rem 0.8rem;
            color: var(--text-muted);
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .05em;
        }
        .student-list-header > div {
            text-align: center;
        }
        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.25rem 0.75rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        .status-not-started { background: #f1f3f5; color: #868e96; }
        .status-in-progress { background: #e7f5ff; color: #228be6; }
        .status-completed { background: #ebfbee; color: #40c057; }
        .student-list-header > div:first-child {
            text-align: left;
            padding-left: 55px;
        }
        .student-list-header > div:last-child {
            text-align: right;
            padding-right: 85px;
        }
        .student-summary-row {
            padding: 1rem 1.5rem;
        }
        .student-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .student-info .stu-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            object-fit: cover;
            background: var(--bg);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: var(--primary);
            border: 1px solid var(--border-light);
            flex-shrink: 0;
        }
        .student-stat {
            text-align: center;
        }
        .student-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: flex-end;
        }
        .btn-history {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            padding: 0 1.2rem;
            font-size: 0.85rem;
            font-weight: 600;
            border-radius: 50px;
            white-space: nowrap;
            height: 36px;
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-history:hover, .btn-history.active {
            background: #e2e8f0;
            color: #0f172a;
            border-color: #cbd5e1;
        }
        .student-history-pane {
            background: var(--bg);
            border-top: 1px solid var(--border-light);
            padding: 1.2rem 1.5rem;
            display: none;
        }
        .student-history-pane.active {
            display: block;
            animation: slideDown .3s ease;
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .history-table {
            width: 100%;
            border-collapse: collapse;
        }
        .history-table th {
            text-align: left;
            font-size: 0.8rem;
            color: var(--text-muted);
            padding-bottom: 0.6rem;
            border-bottom: 1px solid var(--border-light);
            font-weight: 600;
        }
        .history-table td {
            padding: 0.8rem 0;
            font-size: 0.9rem;
            color: var(--text-main);
            border-bottom: 1px dashed var(--border-light);
        }
        .history-table tr:last-child td {
            border-bottom: none;
        }
    </style>
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
                    <div class="nav-avatar-frame" title="<%= navProfileLabel %>">
                        <% if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                            <img src="<%= h(user.getAvatarUrl()) %>" alt="Avatar">
                        <% } else { %>
                            <span class="nav-avatar-initials"><%= h(initials) %></span>
                        <% } %>
                    </div>
                    <div class="dropdown-menu-popup">
                        <a href="${pageContext.request.contextPath}/profile">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
                            <span><%= navProfileLabel %></span>
                        </a>
                        <div style="height:1px;background:var(--border-dark);margin:.35rem 0;"></div>
                        <a href="${pageContext.request.contextPath}/logout" class="danger-link">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                            <span>Đăng xuất</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <div class="exam-hero">
        <div class="hero-inner">
            <a href="${pageContext.request.contextPath}/classroom?id=<%= h(classroom.getId()) %>#tab-exams"
               class="hero-back-link" title="Trở lại lớp học">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="m15 18-6-6 6-6"/></svg>
                Quay trở lại lớp học
            </a>

            <div class="hero-top-row" style="margin-bottom: 1.5rem;">
                <div class="hero-exam-code">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 7h10M7 12h6"/></svg>
                    Quản lý bài thi
                </div>
            </div>

            <div class="hero-title-row" style="display: flex; align-items: center; justify-content: center; gap: 1rem; margin-bottom: 0.8rem;">
                <h1 class="hero-title">Tổng Quan Bài Thi</h1>
            </div>

            <div class="hero-meta">
                <span class="hero-meta-item">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    <%= h(classroom.getTitle()) %>
                </span>
                <span class="meta-separator">•</span>
                <span class="hero-meta-item">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    <%= exam.getDurationMinutes() %> phút
                </span>
                <span class="meta-separator">•</span>
                <span class="hero-meta-item">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                    Mã đề: <%= h(exam.getExamCode()) %>
                </span>
                <span class="meta-separator">•</span>
                <span class="hero-status-badge open">Đang mở</span>
            </div>
        </div>
    </div>

    <main class="main-content">
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-icon blue">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Lượt nộp bài</div>
                    <div class="stat-value"><%= totalAttempts %></div>
                    <div class="stat-sub"><%= completedCount %> hoàn thành</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Điểm trung bình</div>
                    <div class="stat-value"><%= totalAttempts > 0 ? String.format("%.1f", avgScore) : "—" %></div>
                    <% if (exam.getMaxScore() != null && totalAttempts > 0) { %>
                    <div class="stat-sub">trên <%= String.format("%.0f", exam.getMaxScore()) %> điểm</div>
                    <% } else { %><div class="stat-sub">Chưa có dữ liệu</div><% } %>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Tổng vi phạm</div>
                    <div class="stat-value"><%= violationSum %></div>
                    <div class="stat-sub">trong tất cả bài thi</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Số câu hỏi</div>
                    <div class="stat-value"><%= totalQuestions %></div>
                    <div class="stat-sub">câu trắc nghiệm</div>
                </div>
            </div>
        </div>

        <div class="tab-bar" role="tablist">
            <button class="tab-btn active" data-pane="pane-submissions" role="tab">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                Danh sách bài nộp
                <span class="tab-count"><%= totalAttempts %></span>
            </button>
            <button class="tab-btn" data-pane="pane-questions" role="tab">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                Cấu trúc đề thi
                <span class="tab-count"><%= totalQuestions %></span>
            </button>
        </div>

        <div id="pane-submissions" class="tab-pane active">
            <div class="card">
                <div class="card-header">
                    <div class="card-header-title">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                        Kết quả học viên
                    </div>
                    <div class="card-search">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" id="search-attempts" placeholder="Tìm học viên..." autocomplete="off">
                    </div>
                </div>

                <%
                    boolean isEmpty = (attempts == null || attempts.isEmpty());
                %>
                
                <div class="student-result-list" style="margin-top: 1rem;">
                    <% if (isEmpty) { %>
                        <div class="card" style="box-shadow: none; border: 1px dashed var(--border-color); text-align: center; padding: 3rem 1rem;">
                            <div class="empty-icon" style="margin-bottom: 1rem;">
                                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                            </div>
                            <h3 style="color: var(--text-main); font-size: 1.1rem; margin-bottom: 0.5rem;">Lớp học chưa có học viên nào</h3>
                            <p style="color: var(--text-muted); font-size: 0.9rem;">Kết quả làm bài sẽ xuất hiện ở đây khi có học viên trong lớp.</p>
                        </div>
                    <% } else { %>
                        <div class="student-list-header student-row-grid">
                            <div>Học viên</div>
                            <div>Trạng thái</div>
                            <div>Vi phạm</div>
                            <div>Điểm số</div>
                            <div>Thao tác</div>
                        </div>

                        <% for (ClassroomExamAttemptDto dto : attempts) {
                            String sName = dto.getStudentName() != null ? dto.getStudentName() : "Unknown";
                            String sEmail = dto.getStudentEmail() != null ? dto.getStudentEmail() : "";
                            String sInitials = "H";
                            String sAvatar = dto.getStudentAvatar() != null ? dto.getStudentAvatar() : "";
                            int viols = dto.getAttempt().getViolationCount();
                            double sc = dto.getAttempt().getScore() != null ? dto.getAttempt().getScore() : 0.0;
                            String statusStr = dto.getAttempt().getStatus();
                            String badgeClass = "status-not-started";
                            String badgeText = "Chưa làm";
                            if ("completed".equals(statusStr)) {
                                badgeClass = "status-completed";
                                badgeText = "Đã làm";
                            } else if ("in_progress".equals(statusStr)) {
                                badgeClass = "status-in-progress";
                                badgeText = "Đang làm";
                            }
                            
                            String subTime = dto.getAttempt().getSubmittedAt() != null ? sdf.format(dto.getAttempt().getSubmittedAt()) : ("completed".equals(statusStr) ? "Đã nộp" : "Chưa có");
                            String startTime = dto.getAttempt().getStartedAt() != null ? sdf.format(dto.getAttempt().getStartedAt()) : "Chưa bắt đầu";
                            
                            long durationMs = 0;
                            if (dto.getAttempt().getSubmittedAt() != null && dto.getAttempt().getStartedAt() != null) {
                                durationMs = dto.getAttempt().getSubmittedAt().getTime() - dto.getAttempt().getStartedAt().getTime();
                            }
                            long durationMins = durationMs / 60000;
                            if (durationMins == 0 && durationMs > 0) durationMins = 1;

                            if (sName != null && !sName.trim().isEmpty()) {
                                sInitials = String.valueOf(sName.trim().charAt(0)).toUpperCase();
                            }

                            String scoreChipClass = "high";
                            if (exam.getMaxScore() != null && exam.getMaxScore() > 0) {
                                double pct = sc / exam.getMaxScore();
                                if (pct >= 0.8) scoreChipClass = "high";
                                else if (pct >= 0.5) scoreChipClass = "medium";
                                else scoreChipClass = "low";
                            }
                        %>
                        <div class="student-result-card attempt-row">
                            <div class="student-summary-row student-row-grid">
                                <div class="student-info">
                                    <% if (sAvatar != null && !sAvatar.isEmpty()) { %>
                                        <img class="stu-avatar" src="<%= h(sAvatar) %>" alt="">
                                    <% } else { %>
                                        <div class="stu-avatar"><%= sInitials %></div>
                                    <% } %>
                                    <div>
                                        <div class="stu-name" data-search-key style="font-weight: 600; font-size: 1rem; color: var(--text-main);"><%= h(sName) %></div>
                                        <div class="stu-email" style="font-size: 0.85rem; color: var(--text-muted);"><%= h(sEmail) %></div>
                                    </div>
                                </div>

                                <div class="student-stat">
                                    <span class="status-badge <%= badgeClass %>"><%= badgeText %></span>
                                </div>

                                <div class="student-stat">
                                    <span class="violation-chip <%= viols > 0 ? "flagged" : "safe" %>" style="font-size:0.85rem; padding:0.2rem 0.6rem;">
                                        <% if (viols > 0) { %>
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                        <% } else { %>
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                        <% } %>
                                        <%= viols %> lần
                                    </span>
                                </div>

                                <div class="student-stat">
                                    <% if ("completed".equals(statusStr)) { %>
                                        <span class="score-chip <%= scoreChipClass %>" style="font-size:0.95rem; font-weight:700;"><%= String.format("%.2f", sc) %></span>
                                    <% } else { %>
                                        <span style="color: var(--text-muted);">-</span>
                                    <% } %>
                                </div>

                                <div class="student-actions">
                                    <button type="button" class="btn-history" onclick="toggleHistory(this)">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                        Lịch sử
                                    </button>
                                    <a href="#" class="btn btn-primary" style="display:inline-flex; align-items:center; justify-content:center; gap:0.4rem; padding:0 1.2rem; font-size:0.85rem; font-weight:500; border-radius:50px; white-space:nowrap; height:36px; text-decoration:none; color:#fff; background:var(--primary); border:none; cursor:pointer; transition:all 0.2s;">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                                        Chi tiết
                                    </a>
                                </div>
                            </div>

                            <div class="student-history-pane">
                                <table class="history-table">
                                    <thead>
                                        <tr>
                                            <th>Lượt làm</th>
                                            <th>Bắt đầu lúc</th>
                                            <th>Hoàn thành lúc</th>
                                            <th>Thời gian làm</th>
                                            <th>Điểm số</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td style="font-weight:600;">Lượt 1</td>
                                            <td><%= startTime %></td>
                                            <td><%= subTime %></td>
                                            <td><%= durationMins %> phút</td>
                                            <td><span class="score-chip <%= scoreChipClass %>"><%= String.format("%.2f", sc) %></span></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>

        <div id="pane-questions" class="tab-pane">
            <% if (questions == null || questions.isEmpty()) { %>
                <div class="card">
                    <div class="empty-state">
                        <div class="empty-icon">
                            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        </div>
                        <h3>Chưa có câu hỏi nào</h3>
                        <p>Đề thi này chưa có câu hỏi nào được thêm vào.</p>
                    </div>
                </div>
            <% } else { %>
                <div class="q-list">
                    <% for (int i = 0; i < questions.size(); i++) {
                        ClassroomExamQuestion q = questions.get(i);
                        String correct = q.getCorrectOption() != null ? q.getCorrectOption().toUpperCase() : "";
                    %>
                    <div class="q-card">
                        <div class="q-card-header">
                            <div class="q-num"><%= i + 1 %></div>
                            <span style="font-size:.85rem;font-weight:600;color:var(--text-2);">Câu hỏi <%= i + 1 %></span>
                            <span class="q-pts"><%= q.getPoints() != null ? String.format("%.2f", q.getPoints()) : "1.00" %> điểm</span>
                        </div>
                        <div class="q-body">
                            <div class="q-text"><%= h(q.getQuestionText()) %></div>
                            <ul class="q-options">
                                <li class="q-opt <%= "A".equals(correct) ? "correct" : "" %>">
                                    <span class="q-opt-key">A</span>
                                    <span class="q-opt-text"><%= h(q.getOptionA()) %></span>
                                </li>
                                <li class="q-opt <%= "B".equals(correct) ? "correct" : "" %>">
                                    <span class="q-opt-key">B</span>
                                    <span class="q-opt-text"><%= h(q.getOptionB()) %></span>
                                </li>
                                <li class="q-opt <%= "C".equals(correct) ? "correct" : "" %>">
                                    <span class="q-opt-key">C</span>
                                    <span class="q-opt-text"><%= h(q.getOptionC()) %></span>
                                </li>
                                <li class="q-opt <%= "D".equals(correct) ? "correct" : "" %>">
                                    <span class="q-opt-key">D</span>
                                    <span class="q-opt-text"><%= h(q.getOptionD()) %></span>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </div>

    </main>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
    <script>
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
                btn.classList.add('active');
                document.getElementById(btn.dataset.pane).classList.add('active');
            });
        });

        const searchInput = document.getElementById('search-attempts');
        if (searchInput) {
            searchInput.addEventListener('input', () => {
                const q = searchInput.value.trim().toLowerCase();
                document.querySelectorAll('.attempt-row').forEach(row => {
                    const name = row.querySelector('[data-search-key]')?.textContent.toLowerCase() || '';
                    row.style.display = name.includes(q) ? '' : 'none';
                });
            });
        }

        function toggleHistory(btn) {
            const card = btn.closest('.student-result-card');
            const pane = card.querySelector('.student-history-pane');
            pane.classList.toggle('active');
            if (pane.classList.contains('active')) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        }
    </script>
</body>
</html>