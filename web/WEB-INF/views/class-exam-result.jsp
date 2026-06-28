<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.dto.ClassroomExamResultAttemptDto"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.ClassroomExam"%>
<%@page import="com.hipzi.model.ClassroomExamAttempt"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>
<%
    if (!Boolean.TRUE.equals(request.getAttribute("classExamResultRequest"))) {
        response.sendRedirect(request.getContextPath() + "/classroom");
        return;
    }
    User user = (User) session.getAttribute("loggedUser");
    Classroom classroom = (Classroom) request.getAttribute("classroom");
    ClassroomExam exam = (ClassroomExam) request.getAttribute("exam");
    List<ClassroomExamResultAttemptDto> resultAttempts =
            (List<ClassroomExamResultAttemptDto>) request.getAttribute("resultAttempts");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String classroomTitle = classroom != null ? classroom.getTitle() : "Lớp học";
    String examTitle = exam != null ? exam.getTitle() : "Bài thi";
    String examCode = exam != null ? exam.getExamCode() : "";
    double maxScore = exam != null && exam.getMaxScore() != null ? exam.getMaxScore() : 10.0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả bài thi - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        :root {
            --primary: #059669;
            --primary-dark: #047857;
            --ink: #0f172a;
            --muted: #64748b;
            --line: #dbeafe;
            --soft: #ecfdf5;
            --surface: #ffffff;
        }

        body {
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(180deg, #f8fffb 0%, #e6fff2 100%);
            color: var(--ink);
            font-family: "Inter", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .result-shell {
            width: min(1180px, calc(100% - 2rem));
            margin: 0 auto;
            padding: 2rem 0 3rem;
        }

        .result-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .back-link,
        .profile-chip {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 40px;
            padding: 0 1rem;
            border-radius: 999px;
            border: 1px solid rgba(15, 23, 42, 0.1);
            background: rgba(255, 255, 255, 0.84);
            color: var(--ink);
            font-weight: 800;
            text-decoration: none;
            box-shadow: 0 12px 24px rgba(15, 23, 42, 0.08);
        }

        .profile-chip {
            color: var(--primary-dark);
        }

        .result-hero {
            padding: 2rem;
            border-radius: 8px;
            background: linear-gradient(135deg, rgba(255,255,255,0.96), rgba(236,253,245,0.96));
            border: 1px solid rgba(16, 185, 129, 0.2);
            box-shadow: 0 22px 54px rgba(15, 23, 42, 0.12);
        }

        .result-hero h1 {
            margin: 0 0 0.5rem;
            font-size: clamp(1.8rem, 4vw, 3rem);
            line-height: 1.05;
            letter-spacing: 0;
        }

        .result-hero p {
            margin: 0;
            color: var(--muted);
            font-size: 1rem;
            font-weight: 700;
        }

        .summary-strip {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.85rem;
            margin-top: 1.25rem;
        }

        .summary-item {
            padding: 1rem;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.84);
            border: 1px solid rgba(148, 163, 184, 0.25);
        }

        .summary-label {
            color: var(--muted);
            font-size: 0.85rem;
            font-weight: 800;
        }

        .summary-value {
            margin-top: 0.3rem;
            font-size: 1.55rem;
            font-weight: 900;
            color: var(--primary-dark);
        }

        .result-panel {
            margin-top: 1rem;
            padding: 1.2rem;
            border-radius: 8px;
            background: var(--surface);
            border: 1px solid rgba(148, 163, 184, 0.22);
            box-shadow: 0 18px 42px rgba(15, 23, 42, 0.1);
            overflow-x: auto;
        }

        .result-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 0.65rem;
            min-width: 760px;
        }

        .result-table th {
            text-align: left;
            padding: 0 1rem;
            color: var(--muted);
            font-size: 0.86rem;
            font-weight: 900;
        }

        .result-table td {
            padding: 1rem;
            background: #f8fafc;
            border-top: 1px solid rgba(148, 163, 184, 0.18);
            border-bottom: 1px solid rgba(148, 163, 184, 0.18);
            font-weight: 750;
        }

        .result-table td:first-child {
            border-left: 1px solid rgba(148, 163, 184, 0.18);
            border-radius: 8px 0 0 8px;
        }

        .result-table td:last-child {
            border-right: 1px solid rgba(148, 163, 184, 0.18);
            border-radius: 0 8px 8px 0;
        }

        .score-pill,
        .count-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 72px;
            min-height: 34px;
            padding: 0 0.75rem;
            border-radius: 999px;
            font-weight: 900;
        }

        .score-pill {
            background: #dcfce7;
            color: #047857;
        }

        .count-pill.good {
            background: #ecfdf5;
            color: #047857;
        }

        .count-pill.bad {
            background: #fee2e2;
            color: #b91c1c;
        }

        .empty-result {
            padding: 2rem;
            text-align: center;
            color: var(--muted);
            font-weight: 800;
        }

        @media (max-width: 720px) {
            .result-shell {
                width: min(100% - 1rem, 1180px);
                padding-top: 1rem;
            }

            .result-topbar,
            .summary-strip {
                grid-template-columns: 1fr;
            }

            .result-topbar {
                align-items: stretch;
                flex-direction: column;
            }

            .result-hero,
            .result-panel {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <main class="result-shell">
        <div class="result-topbar">
            <a class="back-link" href="${pageContext.request.contextPath}/classroom?id=<%= h(classroom != null ? classroom.getId() : "") %>#tab-exams">Quay lại phòng thi lớp</a>
            <span class="profile-chip"><%= h(user != null && user.getDisplayName() != null ? user.getDisplayName() : "Học sinh") %></span>
        </div>

        <section class="result-hero">
            <h1>Kết quả <%= h(examTitle) %></h1>
            <p><%= h(classroomTitle) %> · Mã đề: <%= h(examCode) %></p>
            <div class="summary-strip">
                <div class="summary-item">
                    <div class="summary-label">Số lượt đã nộp</div>
                    <div class="summary-value"><%= resultAttempts != null ? resultAttempts.size() : 0 %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Thang điểm</div>
                    <div class="summary-value"><%= String.format("%.2f", maxScore) %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Bài thi</div>
                    <div class="summary-value"><%= h(examCode) %></div>
                </div>
            </div>
        </section>

        <section class="result-panel">
            <% if (resultAttempts == null || resultAttempts.isEmpty()) { %>
                <div class="empty-result">Chưa có lượt làm bài nào đã nộp để hiển thị kết quả.</div>
            <% } else { %>
                <table class="result-table">
                    <thead>
                        <tr>
                            <th>Lượt làm</th>
                            <th>Nộp bài lúc</th>
                            <th>Điểm</th>
                            <th>Số câu đúng</th>
                            <th>Số câu sai</th>
                            <th>Tổng câu</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (ClassroomExamResultAttemptDto item : resultAttempts) {
                            ClassroomExamAttempt attempt = item.getAttempt();
                            String submittedAt = attempt != null && attempt.getSubmittedAt() != null
                                    ? sdf.format(attempt.getSubmittedAt())
                                    : "Đã nộp";
                            Double score = attempt != null ? attempt.getScore() : null;
                        %>
                            <tr>
                                <td>Lượt <%= item.getAttemptNumber() %></td>
                                <td><%= h(submittedAt) %></td>
                                <td>
                                    <span class="score-pill"><%= score != null ? String.format("%.2f", score) : "-" %></span>
                                </td>
                                <td>
                                    <span class="count-pill good"><%= item.getCorrectCount() %></span>
                                </td>
                                <td>
                                    <span class="count-pill bad"><%= item.getWrongCount() %></span>
                                </td>
                                <td><%= item.getTotalCount() %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>
    </main>
</body>
</html>
