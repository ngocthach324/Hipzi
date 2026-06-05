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
    <title>Khóa học trực tuyến - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        body {
            background: #f8fafc;
        }
        .courses-container {
            max-width: 1200px;
            margin: 6rem auto 3rem;
            padding: 0 1.5rem;
        }
        .courses-header {
            margin-bottom: 2.5rem;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .courses-header-text h1 {
            font-size: 2.2rem;
            color: #0f172a;
            margin-bottom: 0.5rem;
        }
        .courses-header-text p {
            color: #64748b;
            font-size: 1.05rem;
        }
        .wallet-card {
            background: rgba(20, 184, 166, 0.1);
            border: 1px solid rgba(20, 184, 166, 0.3);
            border-radius: 12px;
            padding: 0.75rem 1.25rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .wallet-info span {
            display: block;
            font-size: 0.85rem;
            color: #0f766e;
            font-weight: 600;
        }
        .wallet-balance {
            font-size: 1.25rem;
            font-weight: 800;
            color: #0f172a;
        }
        .wallet-btn {
            background: #0f766e;
            color: #fff;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .wallet-btn:hover {
            background: #115e59;
        }

        .filters {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            overflow-x: auto;
            padding-bottom: 0.5rem;
        }
        .filter-btn {
            padding: 0.5rem 1.25rem;
            background: #fff;
            border: 1px solid #cbd5e1;
            border-radius: 99px;
            font-size: 0.95rem;
            color: #475569;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.2s;
        }
        .filter-btn:hover {
            border-color: #94a3b8;
            background: #f1f5f9;
        }
        .filter-btn.active {
            background: #0f172a;
            border-color: #0f172a;
            color: #fff;
        }

        .courses-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        /* Course Card */
        .course-card {
            background: #fff;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
        }
        .course-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 20px -5px rgba(0, 0, 0, 0.1);
        }
        .course-thumb {
            width: 100%;
            height: 160px;
            background: #cbd5e1;
            object-fit: cover;
        }
        .course-content {
            padding: 1.25rem;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        .course-title {
            font-size: 1.15rem;
            color: #0f172a;
            margin: 0 0 0.5rem;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .course-author {
            color: #64748b;
            font-size: 0.9rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .course-author img {
            width: 24px;
            height: 24px;
            border-radius: 50%;
        }
        .course-footer {
            margin-top: auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid #f1f5f9;
        }
        .course-price {
            font-weight: 800;
            color: #0f766e;
            font-size: 1.1rem;
        }
        .course-price.free {
            color: #16a34a;
        }
        .enroll-btn {
            padding: 0.4rem 1rem;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.9rem;
            background: #f1f5f9;
            color: #0f172a;
            text-decoration: none;
            transition: background 0.2s;
        }
        .enroll-btn:hover {
            background: #e2e8f0;
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
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>

                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
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

    <main class="courses-container">
        <div class="courses-header">
            <div class="courses-header-text">
                <h1>Khóa học chuyên sâu</h1>
                <p>Nâng cao kiến thức cùng các giảng viên hàng đầu trên HIPZI</p>
            </div>
            
            <% if (user != null) { %>
            <!-- Ví điện tử giả lập -->
            <div class="wallet-card">
                <div class="wallet-info">
                    <span>Số dư ví (HIPZI Coin)</span>
                    <div class="wallet-balance">500,000 đ</div>
                </div>
                <button class="wallet-btn">Nạp tiền</button>
            </div>
            <% } %>
        </div>

        <div class="filters">
            <button class="filter-btn active">Tất cả</button>
            <button class="filter-btn">Toán học</button>
            <button class="filter-btn">Vật lý</button>
            <button class="filter-btn">Tiếng Anh</button>
            <button class="filter-btn">Miễn phí</button>
            <button class="filter-btn">Có phí</button>
        </div>

        <div class="courses-grid">
            <!-- Course 1 -->
            <div class="course-card">
                <!-- Fallback thumbnail if none provided -->
                <div class="course-thumb" style="background: linear-gradient(45deg, #0f766e, #14b8a6);"></div>
                <div class="course-content">
                    <h3 class="course-title">Master IELTS Writing Task 2 từ con số 0</h3>
                    <div class="course-author">
                        <span style="display:inline-block; width:24px; height:24px; background:#e2e8f0; border-radius:50%; text-align:center; line-height:24px; font-size:12px;">GV</span>
                        Trần Anh Khoa
                    </div>
                    <div class="course-footer">
                        <div class="course-price">299,000 đ</div>
                        <a href="#" class="enroll-btn">Xem chi tiết</a>
                    </div>
                </div>
            </div>

            <!-- Course 2 -->
            <div class="course-card">
                <div class="course-thumb" style="background: linear-gradient(45deg, #3b82f6, #60a5fa);"></div>
                <div class="course-content">
                    <h3 class="course-title">Luyện thi ĐGNL ĐHQG TP.HCM - Môn Toán</h3>
                    <div class="course-author">
                        <span style="display:inline-block; width:24px; height:24px; background:#e2e8f0; border-radius:50%; text-align:center; line-height:24px; font-size:12px;">TS</span>
                        Nguyễn Văn A
                    </div>
                    <div class="course-footer">
                        <div class="course-price free">Miễn phí</div>
                        <a href="#" class="enroll-btn">Học ngay</a>
                    </div>
                </div>
            </div>

            <!-- Course 3 -->
            <div class="course-card">
                <div class="course-thumb" style="background: linear-gradient(45deg, #8b5cf6, #a78bfa);"></div>
                <div class="course-content">
                    <h3 class="course-title">Chinh phục Điểm 9+ Vật Lý 12 bằng Sơ đồ tư duy</h3>
                    <div class="course-author">
                        <span style="display:inline-block; width:24px; height:24px; background:#e2e8f0; border-radius:50%; text-align:center; line-height:24px; font-size:12px;">GV</span>
                        Lê Hương Giang
                    </div>
                    <div class="course-footer">
                        <div class="course-price">150,000 đ</div>
                        <a href="#" class="enroll-btn">Xem chi tiết</a>
                    </div>
                </div>
            </div>
            
             <!-- Course 4 -->
            <div class="course-card">
                <div class="course-thumb" style="background: linear-gradient(45deg, #f59e0b, #fbbf24);"></div>
                <div class="course-content">
                    <h3 class="course-title">Ngữ Pháp Tiếng Anh Căn Bản Cho Người Mất Gốc</h3>
                    <div class="course-author">
                        <span style="display:inline-block; width:24px; height:24px; background:#e2e8f0; border-radius:50%; text-align:center; line-height:24px; font-size:12px;">GV</span>
                        Phạm Minh Đức
                    </div>
                    <div class="course-footer">
                        <div class="course-price free">Miễn phí</div>
                        <a href="#" class="enroll-btn">Học ngay</a>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <%@ include file="/WEB-INF/fragments/site-footer.jspf" %>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
