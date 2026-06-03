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
    <title>Thi thử - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        body {
            background: #f8fafc;
        }
        .mock-exam-container {
            max-width: 1200px;
            margin: 6rem auto 3rem;
            padding: 0 1.5rem;
        }
        .mock-exam-header {
            margin-bottom: 2rem;
            text-align: center;
        }
        .mock-exam-header h1 {
            font-size: 2.2rem;
            color: #0f172a;
            margin-bottom: 0.5rem;
        }
        .mock-exam-header p {
            color: #64748b;
            font-size: 1.05rem;
        }

        /* Tabs styling */
        .mock-tabs {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 3rem;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 0.5rem;
        }
        .mock-tab {
            padding: 0.75rem 1.5rem;
            font-weight: 600;
            color: #64748b;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1.05rem;
            position: relative;
            transition: color 0.2s;
            font-family: inherit;
        }
        .mock-tab:hover {
            color: #0f766e;
        }
        .mock-tab.active {
            color: #0f766e;
        }
        .mock-tab.active::after {
            content: '';
            position: absolute;
            bottom: -0.65rem;
            left: 0;
            right: 0;
            height: 3px;
            background: #0f766e;
            border-radius: 3px 3px 0 0;
        }

        /* Content grids */
        .mock-tab-content {
            display: none;
        }
        .mock-tab-content.active {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1.5rem;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Exam Card */
        .exam-card {
            background: #fff;
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .exam-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        .exam-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 99px;
            font-size: 0.75rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-mcq { background: #e0f2fe; color: #0284c7; }
        .badge-flashcard { background: #fef3c7; color: #d97706; }
        .badge-essay { background: #f3e8ff; color: #7e22ce; }
        
        .exam-card h3 {
            font-size: 1.25rem;
            color: #0f172a;
            margin: 0 0 0.5rem;
            line-height: 1.4;
        }
        .exam-meta {
            color: #64748b;
            font-size: 0.9rem;
            margin-bottom: 1.5rem;
            display: flex;
            gap: 1rem;
        }
        .exam-card .btn-start {
            margin-top: auto;
            display: inline-block;
            text-align: center;
            padding: 0.75rem;
            background: #f1f5f9;
            color: #0f172a;
            font-weight: 600;
            border-radius: 8px;
            text-decoration: none;
            transition: background 0.2s;
        }
        .exam-card .btn-start:hover {
            background: #0f766e;
            color: #fff;
        }
        
        /* Empty state */
        .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 3rem;
            background: #fff;
            border-radius: 12px;
            border: 1px dashed #cbd5e1;
            color: #64748b;
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
                <li><a href="${pageContext.request.contextPath}/index">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
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

    <main class="mock-exam-container">
        <div class="mock-exam-header">
            <h1>Luyện đề Thi thử</h1>
            <p>Khám phá các đề thi do HIPZI tuyển chọn để đánh giá năng lực của bạn</p>
        </div>

        <div class="mock-tabs">
            <button class="mock-tab active" onclick="switchTab('mcq')">Trắc nghiệm</button>
            <button class="mock-tab" onclick="switchTab('flashcard')">Flashcard</button>
            <button class="mock-tab" onclick="switchTab('essay')">Tự luận</button>
        </div>

        <!-- Trắc nghiệm -->
        <div id="tab-mcq" class="mock-tab-content active">
            <!-- UI Placeholder cho demo -->
            <div class="exam-card">
                <div><span class="exam-badge badge-mcq">Trắc nghiệm</span></div>
                <h3>Đề thi thử THPT Quốc Gia - Môn Toán (Mã đề 101)</h3>
                <div class="exam-meta">
                    <span>📚 Toán học</span>
                    <span>⏱ 90 phút</span>
                </div>
                <a href="#" class="btn-start">Vào thi ngay</a>
            </div>
            
            <div class="exam-card">
                <div><span class="exam-badge badge-mcq">Trắc nghiệm</span></div>
                <h3>Kiểm tra 15 phút - Môn Tiếng Anh Lớp 10</h3>
                <div class="exam-meta">
                    <span>📚 Tiếng Anh</span>
                    <span>⏱ 15 phút</span>
                </div>
                <a href="#" class="btn-start">Vào thi ngay</a>
            </div>
            
            <div class="exam-card">
                <div><span class="exam-badge badge-mcq">Trắc nghiệm</span></div>
                <h3>Ôn tập Sinh học kỳ 1 (Nâng cao)</h3>
                <div class="exam-meta">
                    <span>📚 Sinh học</span>
                    <span>⏱ 45 phút</span>
                </div>
                <a href="#" class="btn-start">Vào thi ngay</a>
            </div>
        </div>

        <!-- Flashcard -->
        <div id="tab-flashcard" class="mock-tab-content">
            <div class="exam-card">
                <div><span class="exam-badge badge-flashcard">Flashcard</span></div>
                <h3>3000 Từ vựng Tiếng Anh giao tiếp cơ bản</h3>
                <div class="exam-meta">
                    <span>📚 Tiếng Anh</span>
                    <span>🗂 300 thẻ</span>
                </div>
                <a href="#" class="btn-start">Ôn tập thẻ</a>
            </div>
            
            <div class="exam-card">
                <div><span class="exam-badge badge-flashcard">Flashcard</span></div>
                <h3>Công thức Vật lý 12 - Chương 1 & 2</h3>
                <div class="exam-meta">
                    <span>📚 Vật lý</span>
                    <span>🗂 50 thẻ</span>
                </div>
                <a href="#" class="btn-start">Ôn tập thẻ</a>
            </div>
        </div>

        <!-- Tự luận -->
        <div id="tab-essay" class="mock-tab-content">
            <div class="empty-state">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 1rem; color: #94a3b8;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                <h3>Chưa có bài thi tự luận nào</h3>
                <p>Các đề thi tự luận sẽ sớm được Admin cập nhật.</p>
            </div>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
    <script>
        function switchTab(tabId) {
            // Update tabs
            document.querySelectorAll('.mock-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            event.target.classList.add('active');

            // Update content
            document.querySelectorAll('.mock-tab-content').forEach(content => {
                content.classList.remove('active');
            });
            document.getElementById('tab-' + tabId).classList.add('active');
        }
    </script>
</body>
</html>