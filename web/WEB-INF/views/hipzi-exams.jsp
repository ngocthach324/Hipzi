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
    <title>Kỳ thi HIPZI - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        body {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .hipzi-exam-container {
            flex: 1;
            padding: 6rem 1.5rem 3rem;
            max-width: 1180px;
            margin: 0 auto;
            width: 100%;
            box-sizing: border-box;
        }

        .hipzi-exam-hero {
            text-align: center;
            margin-bottom: 3.5rem;
        }

        .hipzi-exam-hero h1 {
            font-size: clamp(2rem, 4vw, 3rem);
            color: #0f172a;
            font-weight: 900;
            margin-bottom: 1rem;
            line-height: 1.2;
        }

        .hipzi-exam-hero p {
            font-size: 1.1rem;
            color: #475569;
            max-width: 700px;
            margin: 0 auto;
            line-height: 1.6;
        }
        
        .xp-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: rgba(245, 158, 11, 0.15);
            color: #d97706;
            padding: 0.35rem 0.8rem;
            border-radius: 999px;
            font-weight: 800;
            font-size: 0.85rem;
            margin-top: 1rem;
        }

        .section-title {
            font-size: 1.5rem;
            color: #1e293b;
            font-weight: 800;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .exam-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }

        .exam-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.03);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;
        }

        .exam-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(15, 23, 42, 0.08);
        }

        .exam-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: #14b8a6;
        }
        
        .exam-card.special::before {
            background: linear-gradient(90deg, #3b82f6, #8b5cf6);
        }

        .exam-card h3 {
            font-size: 1.25rem;
            color: #0f172a;
            font-weight: 800;
            margin: 0.5rem 0 1rem;
            line-height: 1.4;
        }

        .exam-meta {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            flex: 1;
        }

        .exam-meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #64748b;
            font-size: 0.9rem;
        }

        .btn-join {
            display: inline-block;
            text-align: center;
            padding: 0.75rem 1rem;
            background: #0f766e;
            color: white;
            font-weight: 700;
            border-radius: 8px;
            text-decoration: none;
            transition: background 0.2s;
        }

        .btn-join:hover {
            background: #115e59;
        }

        .btn-leaderboard {
            display: inline-block;
            text-align: center;
            padding: 0.75rem 1rem;
            background: #f1f5f9;
            color: #334155;
            font-weight: 700;
            border-radius: 8px;
            text-decoration: none;
            border: 1px solid #cbd5e1;
            transition: all 0.2s;
        }

        .btn-leaderboard:hover {
            background: #e2e8f0;
            color: #0f172a;
        }

        .tag {
            display: inline-block;
            padding: 0.25rem 0.6rem;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
        }

        .tag.upcoming {
            background: #dcfce7;
            color: #166534;
        }

        .tag.past {
            background: #f1f5f9;
            color: #475569;
        }

        .tag.proctored {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            background: white;
            border-radius: 12px;
            border: 1px dashed #cbd5e1;
            color: #64748b;
        }

        @media (max-width: 768px) {
            .hipzi-exam-container {
                padding: 5rem 1rem 2rem;
            }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800;900&display=block">
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

                <li><a href="${pageContext.request.contextPath}/mock-exams" class="active">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
            </ul>

            <% if (user != null) { %>
                <div class="navbar-user-controls">
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                                        <%@ include file="/WEB-INF/fragments/avatar-dropdown.jspf" %>
                </div>
            <% } else { %>
                <div class="nav-actions">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Bắt đầu</a>
                </div>
            <% } %>
        </div>
    </header>

    <main class="hipzi-exam-container">
        <div class="hipzi-exam-hero">
            <h1>Kỳ thi HIPZI Toàn Hệ Thống</h1>
            <p>Tham gia các kỳ thi chung quan trọng hàng tuần, hàng tháng do Ban quản trị HIPZI tổ chức với hệ thống giám sát chặt chẽ. Cạnh tranh trên bảng xếp hạng và nhận phần thưởng XP hấp dẫn.</p>
            <div class="xp-badge">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                Hoàn thành xuất sắc để nhận điểm thưởng XP
            </div>
        </div>

        <h2 class="section-title">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0f766e" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            Kỳ thi sắp diễn ra
        </h2>
        
        <div class="exam-grid">
            <!-- Dummy Data cho UI -->
            <div class="exam-card special">
                <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                    <span class="tag upcoming">Sắp diễn ra</span>
                    <span class="tag proctored">Giám sát AI</span>
                </div>
                <h3>Kỳ Thi Đánh Giá Năng Lực Toán Học Khối 12 - Tháng 6</h3>
                <div class="exam-meta">
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        15/06/2026 - 19:30
                    </div>
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Thời gian: 90 phút
                    </div>
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"></path></svg>
                        Phần thưởng: 500 XP
                    </div>
                </div>
                <a href="#" class="btn-join">Đăng ký tham gia</a>
            </div>

            <div class="exam-card">
                <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                    <span class="tag upcoming">Sắp diễn ra</span>
                </div>
                <h3>Thi thử THPT Quốc Gia - Môn Tiếng Anh Lần 1</h3>
                <div class="exam-meta">
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        20/06/2026 - 20:00
                    </div>
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Thời gian: 60 phút
                    </div>
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"></path></svg>
                        Phần thưởng: 300 XP
                    </div>
                </div>
                <a href="#" class="btn-join">Đăng ký tham gia</a>
            </div>
        </div>

        <h2 class="section-title" style="margin-top: 2rem;">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2.5"><path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            Kỳ thi đã qua
        </h2>

        <div class="exam-grid">
            <div class="exam-card">
                <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                    <span class="tag past">Đã kết thúc</span>
                </div>
                <h3>Đánh Giá Năng Lực Toán Học Khối 12 - Tháng 5</h3>
                <div class="exam-meta">
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        15/05/2026
                    </div>
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        1,245 người tham gia
                    </div>
                </div>
                <a href="#" class="btn-leaderboard">Xem Bảng xếp hạng</a>
            </div>
            
            <div class="exam-card">
                <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                    <span class="tag past">Đã kết thúc</span>
                </div>
                <h3>Thi thử Vật Lý Căn Bản - Chương 1</h3>
                <div class="exam-meta">
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        02/05/2026
                    </div>
                    <div class="exam-meta-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        890 người tham gia
                    </div>
                </div>
                <a href="#" class="btn-leaderboard">Xem Bảng xếp hạng</a>
            </div>
        </div>
        
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
