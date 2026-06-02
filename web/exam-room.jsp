<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
    User user = (User) session.getAttribute("loggedUser");
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
    <title>Phòng thi - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=3">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        html,
        body {
            height: 100%;
            overflow: hidden;
        }

        body {
            background: linear-gradient(135deg, #e8f3f6 0%, #f7fbfc 46%, #ffffff 100%);
        }

        .exam-gateway {
            padding: 5.55rem 1.5rem 1.25rem;
            height: 100vh;
            box-sizing: border-box;
            overflow: hidden;
        }

        .exam-gateway-inner {
            width: min(1180px, 100%);
            margin: 0 auto;
        }

        .exam-hero {
            max-width: 840px;
            margin: 0 auto 1.55rem;
            text-align: center;
        }

        .exam-kicker {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            margin-bottom: 0.7rem;
            color: #0f766e;
            font-weight: 800;
            font-size: 0.82rem;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .exam-kicker::before {
            content: "";
            width: 10px;
            height: 10px;
            border-radius: 999px;
            background: #14b8a6;
            box-shadow: 0 0 0 6px rgba(20, 184, 166, 0.14);
        }

        .exam-hero h1 {
            margin: 0;
            color: #0f172a;
            font-size: clamp(2.15rem, 4vw, 3.65rem);
            line-height: 1.08;
            font-weight: 900;
            letter-spacing: 0;
        }

        .exam-hero p {
            margin: 0.85rem auto 0;
            color: #475569;
            font-size: 1rem;
            line-height: 1.7;
            max-width: 720px;
        }

        .exam-card-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 1rem;
        }

        .exam-entry-card {
            position: relative;
            min-height: 260px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            overflow: hidden;
            text-decoration: none;
            color: #0f172a;
            background: rgba(255, 255, 255, 0.82);
            border: 1px solid rgba(148, 163, 184, 0.3);
            border-radius: 8px;
            padding: 1.25rem;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
            transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
        }

        .exam-entry-card::after {
            content: "";
            position: absolute;
            inset: auto -18% -34% auto;
            width: 190px;
            height: 190px;
            border-radius: 50%;
            background: rgba(20, 184, 166, 0.11);
        }

        .exam-entry-card:hover {
            transform: translateY(-5px);
            border-color: rgba(20, 184, 166, 0.5);
            box-shadow: 0 30px 72px rgba(15, 23, 42, 0.12);
        }

        .exam-entry-card[data-tone="class"]::after {
            background: rgba(59, 130, 246, 0.11);
        }

        .exam-entry-card[data-tone="contest"]::after {
            background: rgba(245, 158, 11, 0.14);
        }

        .exam-card-code {
            display: inline-flex;
            align-items: center;
            width: max-content;
            border-radius: 999px;
            padding: 0.34rem 0.72rem;
            background: rgba(20, 184, 166, 0.12);
            color: #0f766e;
            font-size: 0.78rem;
            font-weight: 900;
            letter-spacing: 0;
        }

        .exam-entry-card h2 {
            margin: 1rem 0 0.75rem;
            color: #0f172a;
            font-size: 1.55rem;
            line-height: 1.2;
            letter-spacing: 0;
        }

        .exam-entry-card p {
            margin: 0;
            color: #64748b;
            line-height: 1.65;
            font-size: 0.95rem;
        }

        .exam-card-bottom {
            position: relative;
            z-index: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            align-self: flex-start;
            gap: 0.55rem;
            margin-top: 1.35rem;
            color: #ffffff;
            font-weight: 800;
            font-size: 0.92rem;
            border-radius: 999px;
            padding: 0.72rem 0.95rem 0.72rem 1.1rem;
            background: #0f766e;
            box-shadow: 0 12px 26px rgba(15, 118, 110, 0.22);
        }

        .exam-card-arrow {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.18);
            color: #ffffff;
            font-size: 1rem;
        }

        @media (max-width: 960px) {
            html,
            body {
                height: auto;
                overflow: auto;
            }

            .exam-gateway {
                height: auto;
                min-height: 100vh;
                overflow: visible;
            }

            .exam-card-grid {
                grid-template-columns: 1fr;
            }

            .exam-entry-card {
                min-height: 220px;
            }
        }

        @media (max-width: 640px) {
            .exam-gateway {
                padding: 5.6rem 1rem 2rem;
            }

            .exam-hero {
                text-align: left;
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
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>

                <li><a href="${pageContext.request.contextPath}/exam-room" class="active">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index.jsp#ai-roadmap">Hipzi AI</a></li>
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

    <main class="exam-gateway">
        <div class="exam-gateway-inner">
            <section class="exam-hero" aria-labelledby="exam-room-title">
                <div class="exam-kicker">Phòng thi HIPZI</div>
                <h1 id="exam-room-title">Chọn hạng mục thi phù hợp</h1>
                <p>Phòng thi được chia thành ba khu vực riêng để học viên luyện đề mở, làm bài kiểm tra trong lớp hoặc tham gia các kỳ thi chung do HIPZI tổ chức.</p>
            </section>

            <section class="exam-card-grid" aria-label="Các hạng mục thi trong HIPZI">
                <a class="exam-entry-card" href="${pageContext.request.contextPath}/mock-exams.jsp" aria-label="Mở hạng mục Thi thử">
                    <div>
                        <div class="exam-card-code">Luyện tập cá nhân</div>
                        <h2>Thi thử</h2>
                        <p>Luyện đề mở, kiểm tra năng lực và làm quen cấu trúc bài thi thật.</p>
                    </div>
                    <div class="exam-card-bottom">
                        <span>Khám phá thi thử</span>
                        <span class="exam-card-arrow" aria-hidden="true">›</span>
                    </div>
                </a>

                <a class="exam-entry-card" href="${pageContext.request.contextPath}/class-exam-room" data-tone="class" aria-label="Mở hạng mục Bài thi lớp học">
                    <div>
                        <div class="exam-card-code">Kiểm tra lớp học</div>
                        <h2>Bài thi lớp học</h2>
                        <p>Làm bài kiểm tra riêng theo lớp và theo dõi tiến độ học tập.</p>
                    </div>
                    <div class="exam-card-bottom">
                        <span>Vào bài thi lớp học</span>
                        <span class="exam-card-arrow" aria-hidden="true">›</span>
                    </div>
                </a>

                <a class="exam-entry-card" href="${pageContext.request.contextPath}/hipzi-exams.jsp" data-tone="contest" aria-label="Mở hạng mục Kỳ thi HIPZI">
                    <div>
                        <div class="exam-card-code">Sự kiện thi chung</div>
                        <h2>Kỳ thi HIPZI</h2>
                        <p>Tham gia kỳ thi chung, cạnh tranh bảng xếp hạng và nhận phần thưởng.</p>
                    </div>
                    <div class="exam-card-bottom">
                        <span>Xem kỳ thi HIPZI</span>
                        <span class="exam-card-arrow" aria-hidden="true">›</span>
                    </div>
                </a>
            </section>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
</body>
</html>
