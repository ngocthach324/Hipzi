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
    <title>Bài thi lớp học - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        html,
        body {
            height: 100%;
            overflow: hidden;
        }

        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #e8f3f6 0%, #f6fbfc 52%, #ffffff 100%);
            color: #0f172a;
        }

        .class-exam-page {
            position: relative;
            box-sizing: border-box;
            min-height: calc(100vh - 80px);
            height: calc(100vh - 80px);
            padding: 1.15rem 1.5rem 0.9rem;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            gap: 0.95rem;
            overflow: hidden;
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
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap">
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
                <li><a href="${pageContext.request.contextPath}/practice">Luyện tập</a></li>
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

    <main class="class-exam-page">
        <div class="class-exam-topbar">
            <a class="class-exam-back" href="${pageContext.request.contextPath}/exam-room">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M19 12H5"/>
                    <path d="m12 19-7-7 7-7"/>
                </svg>
                <span>Quay trở lại</span>
            </a>
        </div>

        <section class="class-exam-intro">
            <h1>Nhập mã đề thi lớp học</h1>
            <p>Mỗi bài thi lớp học chỉ mở cho học viên hợp lệ trong lớp. Hãy nhập đúng mã đề thi do giảng viên cung cấp để xem thông tin bài, thời lượng và trạng thái làm bài.</p>
        </section>

        <div class="class-exam-shell">
            <section class="class-exam-hero">
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
                    <form class="exam-code-form" id="classExamCodeForm">
                        <input class="exam-code-input" id="classExamCode" type="text" autocomplete="off" placeholder="VD: HIPZI-TOAN10-01" aria-label="Mã đề thi">
                        <button class="exam-code-submit" id="classExamCodeSubmit" type="submit" disabled>Hiển thị bài thi <span aria-hidden="true">›</span></button>
                        <div class="exam-code-error" id="classExamCodeError">Vui lòng nhập mã đề thi trước khi tiếp tục.</div>
                        <div class="exam-code-help">Mã đề được giáo viên cung cấp trong lớp học. Vui lòng nhập đúng chữ hoa, số và dấu gạch ngang nếu có.</div>
                    </form>
                </section>

                <section class="exam-result-panel" id="classExamResult" aria-live="polite">
                    <div class="exam-found-label">Đã tìm thấy bài thi</div>
                    <h2 id="examResultTitle">Bài kiểm tra lớp học</h2>
                    <div class="exam-meta-list">
                        <div class="exam-meta-item">
                            <span>Mã đề</span>
                            <strong id="examResultCode">HIPZI-CLASS</strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Thời lượng</span>
                            <strong>45 phút</strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Trạng thái</span>
                            <strong>Đang mở</strong>
                        </div>
                        <div class="exam-meta-item">
                            <span>Quyền truy cập</span>
                            <strong>Học viên trong lớp</strong>
                        </div>
                    </div>
                    <a href="#" class="exam-enter-btn">Vào phòng làm bài</a>
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

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
    <script>
    (function () {
        var form = document.getElementById('classExamCodeForm');
        var input = document.getElementById('classExamCode');
        var error = document.getElementById('classExamCodeError');
        var result = document.getElementById('classExamResult');
        var resultCode = document.getElementById('examResultCode');
        var resultTitle = document.getElementById('examResultTitle');
        var submit = document.getElementById('classExamCodeSubmit');

        if (!form || !input || !result) return;

        function syncSubmitState() {
            if (submit) submit.disabled = input.value.trim().length === 0;
        }

        input.addEventListener('input', function () {
            syncSubmitState();
            if (input.value.trim()) {
                error.classList.remove('active');
            }
        });

        syncSubmitState();

        form.addEventListener('submit', function (event) {
            event.preventDefault();
            var code = input.value.trim();
            if (!code) {
                error.classList.add('active');
                result.classList.remove('active');
                input.focus();
                return;
            }

            error.classList.remove('active');
            resultCode.textContent = code.toUpperCase();
            resultTitle.textContent = 'Bài thi lớp học - ' + code.toUpperCase();
            result.classList.add('active');
        });
    })();
    </script>
</body>
</html>
