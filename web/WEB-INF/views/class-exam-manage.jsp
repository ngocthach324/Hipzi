<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hipzi.model.User" %>
<%@ page import="com.hipzi.model.Classroom" %>
<%@ page import="com.hipzi.model.ClassroomExam" %>
<%@ page import="com.hipzi.model.ClassroomExamAttempt" %>
<%@ page import="com.hipzi.model.ClassroomExamQuestion" %>
<%@ page import="com.hipzi.model.ClassroomExamAnswer" %>
<%@ page import="com.hipzi.dto.ClassroomExamAnswerDetailDto" %>
<%@ page import="com.hipzi.dto.ClassroomExamAttemptDto" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
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
    Map<String, List<ClassroomExamAttempt>> attemptHistories = (Map<String, List<ClassroomExamAttempt>>) request.getAttribute("attemptHistories");
    ClassroomExamAttemptDto selectedAttempt = (ClassroomExamAttemptDto) request.getAttribute("selectedAttempt");
    List<ClassroomExamAnswerDetailDto> selectedAnswers = (List<ClassroomExamAnswerDetailDto>) request.getAttribute("selectedAnswers");

    String initials = "U";
    if (user.getDisplayName() != null && !user.getDisplayName().trim().isEmpty()) {
        initials = String.valueOf(user.getDisplayName().trim().charAt(0)).toUpperCase();
    }
    String navProfileLabel = user.getDisplayName() != null ? user.getDisplayName() : "Hồ sơ cá nhân";

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    int totalQuestions = questions != null ? questions.size() : 0;
    int totalStudents = attempts != null ? attempts.size() : 0;
    int maxAttemptCount = 0;
    if (attempts != null) {
        for (ClassroomExamAttemptDto dto : attempts) {
            if (dto != null && dto.getAttemptCount() > maxAttemptCount) {
                maxAttemptCount = dto.getAttemptCount();
            }
        }
    }
    String attemptView = request.getParameter("attemptView");
    int selectedAttemptRound = 0;
    if (attemptView != null && !"all".equalsIgnoreCase(attemptView)) {
        try {
            selectedAttemptRound = Integer.parseInt(attemptView);
            if (selectedAttemptRound < 1 || selectedAttemptRound > maxAttemptCount) {
                selectedAttemptRound = 0;
            }
        } catch (NumberFormatException ignored) {
            selectedAttemptRound = 0;
        }
    }
    String selectedAttemptViewValue = selectedAttemptRound > 0 ? String.valueOf(selectedAttemptRound) : "all";

    double avgScore = 0;
    int violationSum = 0;
    int completedCount = 0;
    int startedCount = 0;
    int scoredStudentCount = 0;
    long avgDurationMs = 0;
    int durationCount = 0;
    if (attempts != null && totalStudents > 0) {
        double scoreSum = 0;
        for (ClassroomExamAttemptDto dto : attempts) {
            List<ClassroomExamAttempt> histories = attemptHistories != null && dto.getAttempt() != null
                    ? attemptHistories.get(dto.getAttempt().getStudentId())
                    : null;
            if (selectedAttemptRound > 0) {
                ClassroomExamAttempt selectedRoundAttempt = attemptAt(histories, selectedAttemptRound);
                if (selectedRoundAttempt != null) {
                    violationSum += selectedRoundAttempt.getViolationCount();
                    if ("completed".equals(selectedRoundAttempt.getStatus())) completedCount++;
                    if ("completed".equals(selectedRoundAttempt.getStatus()) || "in_progress".equals(selectedRoundAttempt.getStatus())) startedCount++;
                    if (selectedRoundAttempt.getScore() != null) {
                        scoreSum += selectedRoundAttempt.getScore();
                        scoredStudentCount++;
                    }
                    Long selectedDuration = completedDurationMillis(selectedRoundAttempt);
                    if (selectedDuration != null) {
                        avgDurationMs += selectedDuration;
                        durationCount++;
                    }
                }
            } else {
                boolean hasCompletedAttempt = false;
                if (histories != null) {
                    for (ClassroomExamAttempt item : histories) {
                        violationSum += item.getViolationCount();
                        if ("completed".equals(item.getStatus())) {
                            hasCompletedAttempt = true;
                        }
                    }
                } else if (dto.getAttempt() != null) {
                    violationSum += dto.getAttempt().getViolationCount();
                    hasCompletedAttempt = "completed".equals(dto.getAttempt().getStatus());
                }
                if (hasCompletedAttempt) completedCount++;
                if (dto.getAttemptCount() > 0) startedCount++;
                if (dto.getBestScore() != null) {
                    scoreSum += dto.getBestScore();
                    scoredStudentCount++;
                }
                Long bestDuration = bestCompletedDurationMillis(histories);
                if (bestDuration != null) {
                    avgDurationMs += bestDuration;
                    durationCount++;
                }
            }
        }
        if (scoredStudentCount > 0) avgScore = scoreSum / scoredStudentCount;
        if (durationCount > 0) avgDurationMs = avgDurationMs / durationCount;
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

    private String optionText(ClassroomExamQuestion q, String option) {
        if (q == null || option == null) return "";
        if ("A".equalsIgnoreCase(option)) return q.getOptionA();
        if ("B".equalsIgnoreCase(option)) return q.getOptionB();
        if ("C".equalsIgnoreCase(option)) return q.getOptionC();
        if ("D".equalsIgnoreCase(option)) return q.getOptionD();
        return "";
    }

    private Long bestCompletedDurationMillis(List<ClassroomExamAttempt> histories) {
        if (histories == null || histories.isEmpty()) return null;
        Double bestScore = null;
        Long bestDuration = null;
        for (ClassroomExamAttempt item : histories) {
            if (item == null
                    || !"completed".equals(item.getStatus())
                    || item.getScore() == null
                    || item.getStartedAt() == null
                    || item.getSubmittedAt() == null) {
                continue;
            }
            long duration = item.getSubmittedAt().getTime() - item.getStartedAt().getTime();
            if (duration < 0) continue;
            double score = item.getScore();
            if (bestScore == null
                    || score > bestScore
                    || (Math.abs(score - bestScore) < 0.0001 && (bestDuration == null || duration < bestDuration))) {
                bestScore = score;
                bestDuration = duration;
            }
        }
        return bestDuration;
    }

    private ClassroomExamAttempt attemptAt(List<ClassroomExamAttempt> histories, int round) {
        if (histories == null || round < 1 || round > histories.size()) return null;
        return histories.get(round - 1);
    }

    private Long completedDurationMillis(ClassroomExamAttempt attempt) {
        if (attempt == null
                || !"completed".equals(attempt.getStatus())
                || attempt.getStartedAt() == null
                || attempt.getSubmittedAt() == null) {
            return null;
        }
        long duration = attempt.getSubmittedAt().getTime() - attempt.getStartedAt().getTime();
        return duration >= 0 ? duration : null;
    }

    private String formatDuration(long millis) {
        if (millis <= 0) return "0 phút";
        long minutes = (long) Math.ceil(millis / 60000.0);
        if (minutes < 60) return minutes + " phút";
        long hours = minutes / 60;
        long rest = minutes % 60;
        return rest > 0 ? hours + " giờ " + rest + " phút" : hours + " giờ";
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
            max-width: 1320px;
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

        .result-tools { display: flex; align-items: center; justify-content: flex-end; gap: 0.75rem; flex-wrap: wrap; }
        .attempt-view-form {
            display: flex;
            align-items: center;
            margin: 0;
        }
        .attempt-view-select {
            min-width: 190px;
            min-height: 44px;
            appearance: none;
            background:
                linear-gradient(45deg, transparent 50%, var(--text-muted) 50%) calc(100% - 18px) 19px / 7px 7px no-repeat,
                linear-gradient(135deg, var(--text-muted) 50%, transparent 50%) calc(100% - 13px) 19px / 7px 7px no-repeat,
                linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid var(--border);
            border-radius: 12px;
            box-shadow: inset 0 1px 0 rgba(255,255,255,.7), 0 6px 16px rgba(15,23,42,.04);
            color: var(--text);
            cursor: pointer;
            font-family: var(--font);
            font-size: 0.85rem;
            font-weight: 700;
            outline: 0;
            padding: 0 2.4rem 0 0.85rem;
            transition: border-color .2s, box-shadow .2s, background .2s;
        }
        .attempt-view-select:focus {
            border-color: rgba(15,118,110,.45);
            box-shadow: 0 0 0 4px rgba(15,118,110,.08), 0 8px 22px rgba(15,23,42,.06);
            background:
                linear-gradient(45deg, transparent 50%, var(--text-muted) 50%) calc(100% - 18px) 19px / 7px 7px no-repeat,
                linear-gradient(135deg, var(--text-muted) 50%, transparent 50%) calc(100% - 13px) 19px / 7px 7px no-repeat,
                #fff;
        }
        .card-search {
            display: flex;
            align-items: center;
            gap: 0.55rem;
            min-height: 44px;
            background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 0 0.85rem;
            box-shadow: inset 0 1px 0 rgba(255,255,255,.7), 0 6px 16px rgba(15,23,42,.04);
            transition: border-color .2s, box-shadow .2s, background .2s;
        }
        .card-search:focus-within {
            border-color: rgba(15,118,110,.45);
            box-shadow: 0 0 0 4px rgba(15,118,110,.08), 0 8px 22px rgba(15,23,42,.06);
            background: #fff;
        }
        .card-search input { background: transparent; border: 0; outline: 0; box-shadow: none; font-size: 0.85rem; font-family: var(--font); color: var(--text); }
        .card-search input { width: 240px; }
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

        @media (max-width: 768px) {
            .attempts-table { display: block; overflow-x: auto; }
            .card-header { align-items: flex-start; flex-direction: column; }
            .result-tools, .attempt-view-form, .attempt-view-select, .card-search { width: 100%; }
            .card-search input { width: 100%; }
        }

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
            grid-template-columns: minmax(260px, 2fr) minmax(110px, 0.8fr) minmax(95px, 0.7fr) minmax(105px, 0.8fr) minmax(95px, 0.7fr) minmax(310px, 1.45fr);
            align-items: center;
            gap: 1rem;
        }
        .student-actions {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.55rem;
            flex-wrap: wrap;
        }
        .grant-attempt-form { display: inline-flex; margin: 0; }
        .btn-grant-attempt {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.35rem;
            height: 36px;
            padding: 0 0.95rem;
            border-radius: 999px;
            border: 1px solid #bae6fd;
            background: #ecfeff;
            color: #0e7490;
            font-family: var(--font);
            font-size: 0.8rem;
            font-weight: 700;
            cursor: pointer;
            transition: transform .15s, box-shadow .15s, border-color .15s;
            white-space: nowrap;
        }
        .btn-grant-attempt:hover {
            transform: translateY(-1px);
            border-color: #67e8f9;
            box-shadow: 0 8px 18px rgba(14,116,144,.14);
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
        .attempt-count-chip {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 68px;
            padding: 0.26rem 0.72rem;
            border-radius: 999px;
            background: #eef2ff;
            color: #4338ca;
            font-size: 0.84rem;
            font-weight: 700;
            white-space: nowrap;
        }
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
        .attempt-detail-card {
            margin-top: 1.25rem;
            border: 1px solid var(--border);
            border-radius: var(--r-lg);
            background: var(--surface);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .attempt-detail-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1rem;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
            background: var(--surface-2);
        }
        .attempt-detail-header h3 { margin: 0 0 0.35rem; font-size: 1.05rem; }
        .attempt-detail-header p { margin: 0; color: var(--text-muted); font-size: 0.88rem; }
        .attempt-detail-body {
            display: grid;
            gap: 1rem;
            padding: 1.25rem 1.5rem;
        }
        .detail-history-card {
            border: 1px solid var(--border);
            border-radius: var(--r-md);
            background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
            padding: 1rem;
        }
        .detail-history-title {
            display: flex;
            align-items: center;
            gap: 0.45rem;
            margin-bottom: 0.85rem;
            color: var(--text);
            font-weight: 800;
            font-size: 0.95rem;
        }
        .history-detail-link,
        .history-current-chip {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 30px;
            padding: 0 0.75rem;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 800;
            text-decoration: none;
            white-space: nowrap;
        }
        .history-detail-link {
            background: var(--primary);
            color: #fff;
        }
        .history-current-chip {
            background: var(--primary-light);
            color: var(--primary-dark);
        }
        .answer-detail-card {
            border: 1px solid var(--border);
            border-radius: var(--r-md);
            background: #fff;
            padding: 1rem;
        }
        .answer-detail-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 0.75rem;
        }
        .answer-detail-title { font-weight: 700; color: var(--text); }
        .answer-status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            padding: 0.22rem 0.62rem;
            font-size: 0.78rem;
            font-weight: 700;
            white-space: nowrap;
        }
        .answer-status.correct { background: var(--success-light); color: #047857; }
        .answer-status.wrong { background: var(--danger-light); color: #991b1b; }
        .answer-status.pending { background: var(--surface-2); color: var(--text-muted); border: 1px solid var(--border); }
        .answer-question-text {
            color: var(--text-2);
            line-height: 1.6;
            margin-bottom: 0.9rem;
        }
        .answer-option-list {
            display: grid;
            gap: 0.45rem;
            margin: 0;
            padding: 0;
            list-style: none;
        }
        .answer-option {
            display: grid;
            grid-template-columns: 28px minmax(0, 1fr);
            gap: 0.6rem;
            align-items: start;
            border: 1px solid var(--border);
            border-radius: var(--r-sm);
            padding: 0.58rem 0.7rem;
            color: var(--text-2);
            background: var(--surface-2);
        }
        .answer-option.selected { border-color: #38bdf8; background: #e0f2fe; }
        .answer-option.correct { border-color: var(--success); background: var(--success-light); }
        .answer-option-key {
            width: 24px;
            height: 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
            background: var(--border);
            font-size: 0.75rem;
            font-weight: 800;
        }
        .feedback-form {
            border-top: 1px solid var(--border);
            padding: 1.25rem 1.5rem;
            background: #fff;
        }
        .feedback-form label {
            display: block;
            margin-bottom: 0.55rem;
            font-weight: 700;
            color: var(--text);
        }
        .feedback-form textarea {
            width: 100%;
            min-height: 130px;
            resize: vertical;
            border: 1px solid var(--border);
            border-radius: var(--r-md);
            padding: 0.9rem 1rem;
            font-family: var(--font);
            font-size: 0.95rem;
            color: var(--text);
            outline: none;
        }
        .feedback-form textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(15, 118, 110, 0.12);
        }
        .feedback-actions {
            display: flex;
            justify-content: flex-end;
            margin-top: 0.9rem;
        }
        body.modal-open {
            overflow: hidden;
        }
        .modal-overlay {
            position: fixed;
            inset: 0;
            z-index: 3000;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 1.25rem;
            background: rgba(15, 23, 42, 0.42);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }
        .modal-overlay.active {
            display: flex;
        }
        .modal-panel {
            width: min(980px, 100%);
            max-height: calc(100vh - 2.5rem);
            overflow: auto;
            border: 1px solid rgba(226, 232, 240, 0.95);
            border-radius: var(--r-lg);
            background: #fff;
            box-shadow: 0 28px 90px rgba(15, 23, 42, 0.24);
        }
        .modal-overlay .attempt-detail-card {
            width: min(1080px, 100%);
            max-height: calc(100vh - 2.5rem);
            margin: 0;
            overflow: auto;
            box-shadow: 0 28px 90px rgba(15, 23, 42, 0.24);
        }
        .modal-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            padding: 1.1rem 1.3rem;
            border-bottom: 1px solid var(--border);
            background: var(--surface-2);
        }
        .modal-head h3 {
            margin: 0;
            font-size: 1rem;
        }
        .modal-close {
            width: 36px;
            height: 36px;
            border: 1px solid var(--border);
            border-radius: 999px;
            background: #fff;
            color: var(--text);
            cursor: pointer;
            font-size: 1.25rem;
            line-height: 1;
        }
        .modal-body {
            padding: 1.2rem 1.3rem;
        }
        .modal-body .student-history-pane {
            display: block;
            padding: 0;
            border: 0;
            background: transparent;
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
                    <div class="stat-label">Học viên đã nộp</div>
                    <div class="stat-value"><%= completedCount %></div>
                    <div class="stat-sub"><%= startedCount %>/<%= totalStudents %> học viên đã bắt đầu</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Điểm trung bình</div>
                    <div class="stat-value"><%= scoredStudentCount > 0 ? String.format("%.1f", avgScore) : "—" %></div>
                    <div class="stat-sub"><%= scoredStudentCount > 0 ? (selectedAttemptRound > 0 ? ("theo lượt " + selectedAttemptRound) : "theo lượt điểm cao nhất") : "Chưa có dữ liệu" %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Tổng vi phạm</div>
                    <div class="stat-value"><%= violationSum %></div>
                    <div class="stat-sub"><%= selectedAttemptRound > 0 ? ("trong lượt " + selectedAttemptRound) : "trong tất cả lượt làm" %></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon amber">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
                <div class="stat-body">
                    <div class="stat-label">Thời gian trung bình</div>
                    <div class="stat-value"><%= durationCount > 0 ? formatDuration(avgDurationMs) : "—" %></div>
                    <div class="stat-sub"><%= durationCount > 0 ? (selectedAttemptRound > 0 ? ("theo lượt " + selectedAttemptRound) : "theo lượt điểm cao nhất") : "Chưa có dữ liệu" %></div>
                </div>
            </div>
        </div>

        <div class="tab-bar" role="tablist">
            <button class="tab-btn active" data-pane="pane-submissions" role="tab">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                Danh sách bài nộp
                <span class="tab-count"><%= totalStudents %></span>
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
                    <div class="result-tools">
                        <form class="attempt-view-form" method="get" action="${pageContext.request.contextPath}/class-exam-manage">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <input type="hidden" name="code" value="<%= h(exam.getExamCode()) %>">
                            <select class="attempt-view-select" name="attemptView" aria-label="Chọn lượt làm" onchange="this.form.submit()">
                                <option value="all" <%= "all".equals(selectedAttemptViewValue) ? "selected" : "" %>>Tổng số lượt</option>
                                <% for (int attemptOption = 1; attemptOption <= maxAttemptCount; attemptOption++) { %>
                                    <option value="<%= attemptOption %>" <%= selectedAttemptRound == attemptOption ? "selected" : "" %>>Lượt <%= attemptOption %></option>
                                <% } %>
                            </select>
                        </form>
                        <select class="attempt-view-select" id="score-sort-trigger" aria-label="Sắp xếp theo điểm">
                            <option value="default" selected>Sắp xếp mặc định</option>
                            <option value="score_desc">Điểm cao đến thấp</option>
                            <option value="score_asc">Điểm thấp đến cao</option>
                        </select>
                        <div class="card-search">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                            <input type="text" id="search-attempts" placeholder="Tìm học viên..." autocomplete="off">
                        </div>
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
                            <div>Lượt làm</div>
                            <div>Vi phạm</div>
                            <div>Điểm số</div>
                            <div>Thao tác</div>
                        </div>

                        <% int rowIndex = 0;
                           for (ClassroomExamAttemptDto dto : attempts) {
                            String sName = dto.getStudentName() != null ? dto.getStudentName() : "Unknown";
                            String sEmail = dto.getStudentEmail() != null ? dto.getStudentEmail() : "";
                            String sInitials = "H";
                            String sAvatar = dto.getStudentAvatar() != null ? dto.getStudentAvatar() : "";
                            List<ClassroomExamAttempt> studentHistories = attemptHistories != null
                                    ? attemptHistories.get(dto.getAttempt().getStudentId())
                                    : null;
                            ClassroomExamAttempt rowAttempt = selectedAttemptRound > 0
                                    ? attemptAt(studentHistories, selectedAttemptRound)
                                    : dto.getAttempt();
                            int viols = 0;
                            if (selectedAttemptRound > 0) {
                                viols = rowAttempt != null ? rowAttempt.getViolationCount() : 0;
                            } else if (studentHistories != null) {
                                for (ClassroomExamAttempt item : studentHistories) {
                                    viols += item.getViolationCount();
                                }
                            } else {
                                viols = dto.getAttempt().getViolationCount();
                            }
                            Double bestScore = dto.getBestScore();
                            Double displayScore = selectedAttemptRound > 0 && rowAttempt != null ? rowAttempt.getScore() : bestScore;
                            double sc = displayScore != null ? displayScore : 0.0;
                            String statusStr = rowAttempt != null && rowAttempt.getStatus() != null ? rowAttempt.getStatus() : "not_started";
                            String badgeClass = "status-not-started";
                            String badgeText = "Chưa làm";
                            boolean hasCompletedScore = displayScore != null;
                            if ("in_progress".equals(statusStr)) {
                                badgeClass = "status-in-progress";
                                badgeText = "Đang làm";
                            } else if ("completed".equals(statusStr) || hasCompletedScore) {
                                badgeClass = "status-completed";
                                badgeText = "Đã làm";
                            }
                            int attemptCount = dto.getAttemptCount();
                            int allowedAttemptCount = dto.getAllowedAttemptCount();
                            String attemptCountText = selectedAttemptRound > 0 ? String.valueOf(selectedAttemptRound) : (attemptCount + "/" + allowedAttemptCount);
                            String detailAttemptId = rowAttempt != null ? rowAttempt.getId() : null;

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
                        <div class="student-result-card attempt-row" data-score="<%= displayScore != null ? String.format(java.util.Locale.US, "%.4f", displayScore) : "-1" %>" data-original-index="<%= rowIndex++ %>">
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
                                    <span class="attempt-count-chip"><%= attemptCountText %></span>
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
                                    <% if (hasCompletedScore) { %>
                                        <span class="score-chip <%= scoreChipClass %>" style="font-size:0.95rem; font-weight:700;"><%= String.format("%.2f", sc) %></span>
                                    <% } else { %>
                                        <span style="color: var(--text-muted);">-</span>
                                    <% } %>
                                </div>

                                <div class="student-actions">
                                    <form class="grant-attempt-form" method="post" action="${pageContext.request.contextPath}/class-exam-manage">
                                        <input type="hidden" name="action" value="grantExtraAttempt">
                                        <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                        <input type="hidden" name="code" value="<%= h(exam.getExamCode()) %>">
                                        <input type="hidden" name="attemptView" value="<%= h(selectedAttemptViewValue) %>">
                                        <input type="hidden" name="studentId" value="<%= h(dto.getAttempt().getStudentId()) %>">
                                        <button type="submit" class="btn-grant-attempt" title="Cấp thêm 1 lượt làm bài">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M12 5v14"/><path d="M5 12h14"/></svg>
                                            Thêm lượt
                                        </button>
                                    </form>
                                    <a href="${pageContext.request.contextPath}/class-exam-manage?classId=<%= h(classroom.getId()) %>&code=<%= h(exam.getExamCode()) %>&attemptView=<%= h(selectedAttemptViewValue) %>&attemptId=<%= h(detailAttemptId != null ? detailAttemptId : "") %>" class="btn btn-primary" style="display:inline-flex; align-items:center; justify-content:center; gap:0.4rem; padding:0 1.2rem; font-size:0.85rem; font-weight:500; border-radius:50px; white-space:nowrap; height:36px; text-decoration:none; color:#fff; background:<%= detailAttemptId != null ? "var(--primary)" : "#94a3b8" %>; border:none; cursor:<%= detailAttemptId != null ? "pointer" : "not-allowed" %>; transition:all 0.2s; <%= detailAttemptId != null ? "" : "opacity:0.72; pointer-events:none;" %>">
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
                                        <%
                                            List<ClassroomExamAttempt> histories = studentHistories;
                                            boolean missingSelectedHistory = selectedAttemptRound > 0
                                                    && (histories == null || histories.size() < selectedAttemptRound);
                                            if (histories == null || histories.isEmpty() || missingSelectedHistory) {
                                        %>
                                            <tr>
                                                <td colspan="5" style="color:var(--text-muted);"><%= selectedAttemptRound > 0 ? "Chưa có lượt làm này" : "Chưa có lượt làm nào" %></td>
                                            </tr>
                                        <% } else {
                                            int historyStart = selectedAttemptRound > 0 ? selectedAttemptRound - 1 : 0;
                                            int historyEnd = selectedAttemptRound > 0 ? selectedAttemptRound : histories.size();
                                            for (int hi = historyStart; hi < historyEnd; hi++) {
                                                ClassroomExamAttempt item = histories.get(hi);
                                                String itemStart = item.getStartedAt() != null ? sdf.format(item.getStartedAt()) : "Chưa bắt đầu";
                                                String itemSubmit = item.getSubmittedAt() != null ? sdf.format(item.getSubmittedAt()) : ("completed".equals(item.getStatus()) ? "Đã nộp" : "Đang làm");
                                                long itemDurationMs = item.getSubmittedAt() != null && item.getStartedAt() != null
                                                        ? item.getSubmittedAt().getTime() - item.getStartedAt().getTime()
                                                        : 0;
                                                long itemDurationMins = Math.max(1, itemDurationMs / 60000);
                                                Double itemScore = item.getScore();
                                                String itemScoreClass = "pending";
                                                if (itemScore != null && exam.getMaxScore() != null && exam.getMaxScore() > 0) {
                                                    double itemPct = itemScore / exam.getMaxScore();
                                                    if (itemPct >= 0.8) itemScoreClass = "high";
                                                    else if (itemPct >= 0.5) itemScoreClass = "medium";
                                                    else itemScoreClass = "low";
                                                }
                                        %>
                                            <tr>
                                                <td style="font-weight:600;">Lượt <%= hi + 1 %></td>
                                                <td><%= itemStart %></td>
                                                <td><%= itemSubmit %></td>
                                                <td><%= item.getSubmittedAt() != null ? (itemDurationMins + " phút") : "-" %></td>
                                                <td>
                                                    <% if (itemScore != null) { %>
                                                        <span class="score-chip <%= itemScoreClass %>"><%= String.format("%.2f", itemScore) %></span>
                                                    <% } else { %>
                                                        <span class="score-chip pending">-</span>
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <%  }
                                        } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>

        <% if (selectedAttempt != null) {
            String selectedStatus = selectedAttempt.getAttempt().getStatus();
            Double selectedScore = selectedAttempt.getAttempt().getScore();
            String selectedFeedback = selectedAttempt.getAttempt().getTeacherFeedback() != null
                    ? selectedAttempt.getAttempt().getTeacherFeedback()
                    : "";
            List<ClassroomExamAttempt> selectedHistories = attemptHistories != null
                    ? attemptHistories.get(selectedAttempt.getAttempt().getStudentId())
                    : null;
        %>
        <div class="modal-overlay active" id="attemptDetailModal">
        <section class="attempt-detail-card" id="attempt-detail" role="dialog" aria-modal="true" aria-label="Chi tiết bài làm">
            <div class="attempt-detail-header">
                <div>
                    <h3>Chi tiết bài làm của <%= h(selectedAttempt.getStudentName()) %></h3>
                    <p>
                        <%= h(selectedAttempt.getStudentEmail()) %>
                        · Trạng thái: <%= "completed".equals(selectedStatus) ? "Đã làm" : ("in_progress".equals(selectedStatus) ? "Đang làm" : "Chưa làm") %>
                        · Điểm: <%= selectedScore != null ? String.format("%.2f", selectedScore) : "-" %>
                        · Vi phạm: <%= selectedAttempt.getAttempt().getViolationCount() %> lần
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/class-exam-manage?classId=<%= h(classroom.getId()) %>&code=<%= h(exam.getExamCode()) %>&attemptView=<%= h(selectedAttemptViewValue) %>"
                   class="btn-history" style="text-decoration:none;">Đóng chi tiết</a>
            </div>

            <div class="attempt-detail-body">
                <section class="detail-history-card">
                    <div class="detail-history-title">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        Lịch sử các lượt làm
                    </div>
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Lượt làm</th>
                                <th>Bắt đầu lúc</th>
                                <th>Hoàn thành lúc</th>
                                <th>Thời gian làm</th>
                                <th>Điểm số</th>
                                <th>Chi tiết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (selectedHistories == null || selectedHistories.isEmpty()
                                    || (selectedAttemptRound > 0 && selectedHistories.size() < selectedAttemptRound)) { %>
                                <tr>
                                    <td colspan="6" style="color:var(--text-muted);"><%= selectedAttemptRound > 0 ? "Chưa có lượt làm này" : "Chưa có lịch sử làm bài" %></td>
                                </tr>
                            <% } else {
                                int selectedHistoryStart = selectedAttemptRound > 0 ? Math.min(selectedAttemptRound - 1, selectedHistories.size()) : 0;
                                int selectedHistoryEnd = selectedAttemptRound > 0 ? Math.min(selectedAttemptRound, selectedHistories.size()) : selectedHistories.size();
                                for (int hi = selectedHistoryStart; hi < selectedHistoryEnd; hi++) {
                                    ClassroomExamAttempt item = selectedHistories.get(hi);
                                    String itemStart = item.getStartedAt() != null ? sdf.format(item.getStartedAt()) : "Chưa bắt đầu";
                                    String itemSubmit = item.getSubmittedAt() != null ? sdf.format(item.getSubmittedAt()) : ("completed".equals(item.getStatus()) ? "Đã nộp" : "Đang làm");
                                    long itemDurationMs = item.getSubmittedAt() != null && item.getStartedAt() != null
                                            ? item.getSubmittedAt().getTime() - item.getStartedAt().getTime()
                                            : 0;
                                    long itemDurationMins = Math.max(1, itemDurationMs / 60000);
                                    Double itemScore = item.getScore();
                                    String itemScoreClass = "pending";
                                    if (itemScore != null && exam.getMaxScore() != null && exam.getMaxScore() > 0) {
                                        double itemPct = itemScore / exam.getMaxScore();
                                        if (itemPct >= 0.8) itemScoreClass = "high";
                                        else if (itemPct >= 0.5) itemScoreClass = "medium";
                                        else itemScoreClass = "low";
                                    }
                                    boolean viewingThisAttempt = item.getId() != null && item.getId().equals(selectedAttempt.getAttempt().getId());
                            %>
                                <tr>
                                    <td style="font-weight:700;">Lượt <%= hi + 1 %></td>
                                    <td><%= itemStart %></td>
                                    <td><%= itemSubmit %></td>
                                    <td><%= item.getSubmittedAt() != null ? (itemDurationMins + " phút") : "-" %></td>
                                    <td>
                                        <% if (itemScore != null) { %>
                                            <span class="score-chip <%= itemScoreClass %>"><%= String.format("%.2f", itemScore) %></span>
                                        <% } else { %>
                                            <span class="score-chip pending">-</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (viewingThisAttempt) { %>
                                            <span class="history-current-chip">Đang xem</span>
                                        <% } else if (item.getId() != null) { %>
                                            <a class="history-detail-link" href="${pageContext.request.contextPath}/class-exam-manage?classId=<%= h(classroom.getId()) %>&code=<%= h(exam.getExamCode()) %>&attemptView=<%= h(selectedAttemptViewValue) %>&attemptId=<%= h(item.getId()) %>">Xem lượt này</a>
                                        <% } else { %>
                                            <span style="color:var(--text-muted);">-</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <%  }
                            } %>
                        </tbody>
                    </table>
                </section>

                <% if (selectedAnswers == null || selectedAnswers.isEmpty()) { %>
                    <div class="empty-state" style="padding: 2rem;">
                        <h3>Chưa có dữ liệu câu trả lời</h3>
                        <p>Học viên chưa nộp câu trả lời hoặc dữ liệu bài làm chưa được lưu.</p>
                    </div>
                <% } else {
                    for (int i = 0; i < selectedAnswers.size(); i++) {
                        ClassroomExamAnswerDetailDto detail = selectedAnswers.get(i);
                        ClassroomExamQuestion q = detail.getQuestion();
                        ClassroomExamAnswer ans = detail.getAnswer();
                        String selected = ans != null ? ans.getSelectedOption() : "";
                        String correct = q != null && q.getCorrectOption() != null ? q.getCorrectOption().toUpperCase() : "";
                        boolean answered = selected != null && !selected.trim().isEmpty();
                        boolean isCorrectAnswer = ans != null && ans.getId() != null && ans.isCorrect();
                        String statusClass = !answered ? "pending" : (isCorrectAnswer ? "correct" : "wrong");
                        String statusText = !answered ? "Chưa trả lời" : (isCorrectAnswer ? "Đúng" : "Sai");
                %>
                    <article class="answer-detail-card">
                        <div class="answer-detail-top">
                            <div class="answer-detail-title">Câu <%= i + 1 %> · <%= q != null && q.getPoints() != null ? String.format("%.2f", q.getPoints()) : "1.00" %> điểm</div>
                            <span class="answer-status <%= statusClass %>"><%= statusText %></span>
                        </div>
                        <div class="answer-question-text"><%= h(q != null ? q.getQuestionText() : "") %></div>

                        <ul class="answer-option-list">
                            <% String[] keys = {"A", "B", "C", "D"};
                               for (String key : keys) {
                                   String optionValue = optionText(q, key);
                                   if (optionValue == null || optionValue.trim().isEmpty()) {
                                       continue;
                                   }
                                   String optionClass = "";
                                   if (key.equalsIgnoreCase(correct)) optionClass += " correct";
                                   if (answered && key.equalsIgnoreCase(selected)) optionClass += " selected";
                            %>
                            <li class="answer-option<%= optionClass %>">
                                <span class="answer-option-key"><%= key %></span>
                                <span><%= h(optionValue) %>
                                    <% if (answered && key.equalsIgnoreCase(selected)) { %>
                                        <strong> · Học viên chọn</strong>
                                    <% } %>
                                    <% if (key.equalsIgnoreCase(correct)) { %>
                                        <strong> · Đáp án đúng</strong>
                                    <% } %>
                                </span>
                            </li>
                            <% } %>
                        </ul>
                    </article>
                <%  }
                } %>
            </div>

            <form class="feedback-form" method="post" action="${pageContext.request.contextPath}/class-exam-manage">
                <input type="hidden" name="action" value="saveFeedback">
                <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                <input type="hidden" name="code" value="<%= h(exam.getExamCode()) %>">
                <input type="hidden" name="attemptView" value="<%= h(selectedAttemptViewValue) %>">
                <input type="hidden" name="attemptId" value="<%= h(selectedAttempt.getAttempt().getId()) %>">
                <label for="teacherFeedback">Feedback gửi cho học viên</label>
                <textarea id="teacherFeedback" name="teacherFeedback" placeholder="Nhập nhận xét, gợi ý ôn tập hoặc lời nhắn cho học viên..."><%= h(selectedFeedback) %></textarea>
                <% if (selectedAttempt.getAttempt().getFeedbackAt() != null) { %>
                    <p style="margin:0.6rem 0 0;color:var(--text-muted);font-size:0.85rem;">Đã lưu lần gần nhất lúc <%= sdf.format(selectedAttempt.getAttempt().getFeedbackAt()) %></p>
                <% } %>
                <div class="feedback-actions">
                    <button type="submit" class="btn btn-primary" style="display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 1.2rem;border-radius:999px;border:0;background:var(--primary);color:#fff;font-weight:700;cursor:pointer;">Lưu feedback</button>
                </div>
            </form>
        </section>
        </div>
        <% } %>

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

    <div class="modal-overlay" id="historyModal" aria-hidden="true">
        <section class="modal-panel" role="dialog" aria-modal="true" aria-labelledby="historyModalTitle">
            <div class="modal-head">
                <h3 id="historyModalTitle">Lịch sử làm bài</h3>
                <button type="button" class="modal-close" onclick="closeHistoryModal()" aria-label="Đóng">×</button>
            </div>
            <div class="modal-body" id="historyModalBody"></div>
        </section>
    </div>

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
        const sortTrigger = document.getElementById('score-sort-trigger');
        const resultList = document.querySelector('.student-result-list');

        function applyResultTools() {
            const q = searchInput ? searchInput.value.trim().toLowerCase() : '';
            const sortMode = sortTrigger ? sortTrigger.value : 'default';
            const rows = Array.from(document.querySelectorAll('.attempt-row'));

            rows.sort((a, b) => {
                if (sortMode === 'score_desc' || sortMode === 'score_asc') {
                    const scoreA = Number(a.dataset.score || '-1');
                    const scoreB = Number(b.dataset.score || '-1');
                    const diff = sortMode === 'score_desc' ? scoreB - scoreA : scoreA - scoreB;
                    if (diff !== 0) return diff;
                }
                return Number(a.dataset.originalIndex || '0') - Number(b.dataset.originalIndex || '0');
            });

            rows.forEach(row => {
                const name = row.querySelector('[data-search-key]')?.textContent.toLowerCase() || '';
                const email = row.querySelector('.stu-email')?.textContent.toLowerCase() || '';
                row.style.display = (name + ' ' + email).includes(q) ? '' : 'none';
                if (resultList) resultList.appendChild(row);
            });
        }

        if (searchInput) searchInput.addEventListener('input', applyResultTools);
        if (sortTrigger) {
            sortTrigger.addEventListener('change', applyResultTools);
        }

        function toggleHistory(btn) {
            const card = btn.closest('.student-result-card');
            const pane = card.querySelector('.student-history-pane');
            const modal = document.getElementById('historyModal');
            const body = document.getElementById('historyModalBody');
            const title = document.getElementById('historyModalTitle');
            const studentName = card.querySelector('[data-search-key]')?.textContent.trim() || 'học viên';
            if (!pane || !modal || !body || !title) return;
            const content = pane.cloneNode(true);
            content.classList.add('active');
            body.replaceChildren(content);
            title.textContent = 'Lịch sử làm bài - ' + studentName;
            modal.classList.add('active');
            modal.setAttribute('aria-hidden', 'false');
            document.body.classList.add('modal-open');
        }

        function closeHistoryModal() {
            const modal = document.getElementById('historyModal');
            const body = document.getElementById('historyModalBody');
            if (!modal || !body) return;
            modal.classList.remove('active');
            modal.setAttribute('aria-hidden', 'true');
            body.replaceChildren();
            document.body.classList.remove('modal-open');
        }

        document.getElementById('historyModal')?.addEventListener('click', event => {
            if (event.target.id === 'historyModal') {
                closeHistoryModal();
            }
        });

        document.getElementById('attemptDetailModal')?.addEventListener('click', event => {
            if (event.target.id === 'attemptDetailModal') {
                window.location.href = '${pageContext.request.contextPath}/class-exam-manage?classId=<%= h(classroom.getId()) %>&code=<%= h(exam.getExamCode()) %>&attemptView=<%= h(selectedAttemptViewValue) %>';
            }
        });

        if (document.getElementById('attemptDetailModal')) {
            document.body.classList.add('modal-open');
        }

        document.addEventListener('keydown', event => {
            if (event.key !== 'Escape') return;
            if (document.getElementById('historyModal')?.classList.contains('active')) {
                closeHistoryModal();
                return;
            }
            if (document.getElementById('attemptDetailModal')) {
                window.location.href = '${pageContext.request.contextPath}/class-exam-manage?classId=<%= h(classroom.getId()) %>&code=<%= h(exam.getExamCode()) %>&attemptView=<%= h(selectedAttemptViewValue) %>';
            }
        });

        const scrollKey = 'scrollPos_' + new URLSearchParams(window.location.search).get('classId') + '_' + new URLSearchParams(window.location.search).get('code');
        window.addEventListener('beforeunload', () => {
            sessionStorage.setItem(scrollKey, window.scrollY);
        });

        document.addEventListener('DOMContentLoaded', () => {
            const pos = sessionStorage.getItem(scrollKey);
            if (pos) {
                sessionStorage.removeItem(scrollKey);
                setTimeout(() => window.scrollTo({ top: parseInt(pos, 10), behavior: 'instant' }), 0);
            }
        });
    </script>
</body>
</html>
