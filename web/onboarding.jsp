<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
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
    User user = (User) request.getAttribute("user");
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn vai trò - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
    <style>
        body {
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background:
                linear-gradient(135deg, rgba(236, 253, 245, 0.94), rgba(240, 249, 255, 0.92)),
                repeating-linear-gradient(45deg, rgba(15, 23, 42, 0.025) 0 1px, transparent 1px 18px);
        }

        .onboarding-shell {
            width: min(1080px, 100%);
            position: relative;
            z-index: 1;
            animation: shellEnter 640ms cubic-bezier(0.2, 0.8, 0.2, 1) both;
        }

        .onboarding-panel {
            position: relative;
            overflow: hidden;
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 250, 252, 0.93)),
                linear-gradient(135deg, rgba(16, 185, 129, 0.12), rgba(14, 165, 233, 0.1));
            border: 1px solid rgba(255, 255, 255, 0.9);
            border-radius: 8px;
            box-shadow: 0 26px 70px rgba(15, 23, 42, 0.12), 0 1px 0 rgba(255, 255, 255, 0.9) inset;
            padding: 2.25rem;
        }

        .onboarding-panel::before {
            content: "";
            position: absolute;
            inset: 0;
            pointer-events: none;
            background:
                linear-gradient(90deg, rgba(5, 150, 105, 0.12), transparent 28%, rgba(14, 165, 233, 0.12)),
                radial-gradient(circle at 50% 0, rgba(255, 255, 255, 0.8), transparent 34%);
            opacity: 0.9;
        }

        .onboarding-panel > * {
            position: relative;
            z-index: 1;
        }

        .onboarding-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1.25rem;
            margin-bottom: 1.65rem;
        }

        .onboarding-title h1 {
            margin: 0 0 0.5rem;
            font-size: clamp(1.8rem, 3vw, 2.6rem);
            line-height: 1.15;
            color: #0f172a;
            letter-spacing: 0;
        }

        .onboarding-title p {
            margin: 0;
            max-width: 660px;
            color: #475569;
            font-size: 1rem;
            font-weight: 650;
            line-height: 1.6;
        }

        .role-choice-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 1rem;
            margin: 1.25rem 0 1.6rem;
        }

        .role-choice-card {
            --role-color: #059669;
            --role-soft: #dcfce7;
            --role-rgb: 5, 150, 105;
            position: relative;
            overflow: hidden;
            border: 1.5px solid #dbe4ee;
            background: rgba(255, 255, 255, 0.88);
            border-radius: 8px;
            padding: 1.2rem;
            cursor: pointer;
            min-height: 230px;
            display: flex;
            flex-direction: column;
            gap: 0.82rem;
            box-shadow: 0 14px 28px rgba(15, 23, 42, 0.055);
            transform: translateY(0) scale(1);
            transition:
                border-color 180ms ease,
                box-shadow 220ms ease,
                transform 220ms ease,
                background 220ms ease;
            animation: cardEnter 560ms cubic-bezier(0.2, 0.8, 0.2, 1) both;
        }

        .role-choice-card:nth-child(2) { animation-delay: 80ms; }
        .role-choice-card:nth-child(3) { animation-delay: 160ms; }

        .role-choice-card.parent-card {
            --role-color: #d97706;
            --role-soft: #fef3c7;
            --role-rgb: 217, 119, 6;
        }

        .role-choice-card.teacher-card {
            --role-color: #0284c7;
            --role-soft: #e0f2fe;
            --role-rgb: 2, 132, 199;
        }

        .role-choice-card::before {
            content: "";
            position: absolute;
            inset: 0;
            background:
                linear-gradient(135deg, rgba(var(--role-rgb), 0.14), transparent 38%),
                linear-gradient(180deg, rgba(255, 255, 255, 0.86), rgba(255, 255, 255, 0.58));
            opacity: 0;
            transition: opacity 220ms ease;
        }

        .role-choice-card::after {
            content: "";
            position: absolute;
            top: 0;
            left: -80%;
            width: 55%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.74), transparent);
            transform: skewX(-18deg);
            opacity: 0;
        }

        .role-choice-card:hover,
        .role-choice-card.active {
            border-color: var(--role-color);
            box-shadow: 0 22px 38px rgba(var(--role-rgb), 0.18), 0 10px 22px rgba(15, 23, 42, 0.08);
            transform: translateY(-7px) scale(1.015);
            background: rgba(255, 255, 255, 0.98);
        }

        .role-choice-card:hover::before,
        .role-choice-card.active::before {
            opacity: 1;
        }

        .role-choice-card.active::after {
            animation: cardSheen 760ms ease both;
        }

        .role-choice-card input {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .role-choice-card > * {
            position: relative;
            z-index: 1;
        }

        .role-card-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
        }

        .role-icon {
            width: 52px;
            height: 52px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.45rem;
            font-weight: 800;
            color: var(--role-color);
            background: var(--role-soft);
            box-shadow: 0 10px 22px rgba(var(--role-rgb), 0.14);
            transition: transform 220ms ease, box-shadow 220ms ease, background 220ms ease;
        }

        .role-choice-card:hover .role-icon,
        .role-choice-card.active .role-icon {
            transform: translateY(-2px) rotate(-3deg) scale(1.08);
            background: #ffffff;
            box-shadow: 0 16px 28px rgba(var(--role-rgb), 0.22);
        }

        .role-check {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1.5px solid #cbd5e1;
            color: transparent;
            background: rgba(255, 255, 255, 0.82);
            transform: scale(0.88);
            transition: background 180ms ease, border-color 180ms ease, color 180ms ease, transform 180ms ease;
        }

        .role-choice-card.active .role-check {
            background: var(--role-color);
            border-color: var(--role-color);
            color: #ffffff;
            transform: scale(1);
            animation: checkPop 320ms cubic-bezier(0.2, 0.9, 0.2, 1.25);
        }

        .role-choice-card h2 {
            margin: 0;
            color: #0f172a;
            font-size: 1.18rem;
            line-height: 1.25;
            letter-spacing: 0;
        }

        .role-choice-card p {
            margin: 0;
            color: #475569;
            line-height: 1.56;
            font-size: 0.95rem;
            font-weight: 520;
        }

        .role-mini-list {
            display: grid;
            gap: 0.45rem;
            margin-top: auto;
            padding-top: 0.35rem;
        }

        .role-mini-list span {
            display: flex;
            align-items: center;
            gap: 0.45rem;
            color: #334155;
            font-size: 0.86rem;
            font-weight: 650;
        }

        .role-mini-list span::before {
            content: "";
            width: 7px;
            height: 7px;
            flex: 0 0 7px;
            border-radius: 50%;
            background: var(--role-color);
            box-shadow: 0 0 0 4px rgba(var(--role-rgb), 0.13);
        }

        .onboarding-actions {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            padding-top: 0.25rem;
        }

        .onboarding-note {
            color: #64748b;
            font-size: 0.92rem;
            font-weight: 600;
        }

        .onboarding-actions .btn {
            width: auto;
            min-width: 220px;
            padding-left: 1.35rem;
            padding-right: 1.35rem;
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.22);
        }

        .onboarding-actions .btn.is-ready {
            animation: buttonReady 360ms cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        @keyframes shellEnter {
            from {
                opacity: 0;
                transform: translateY(18px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes cardEnter {
            from {
                opacity: 0;
                transform: translateY(18px) scale(0.97);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        @keyframes cardSheen {
            0% {
                opacity: 0;
                left: -80%;
            }
            30% {
                opacity: 0.85;
            }
            100% {
                opacity: 0;
                left: 125%;
            }
        }

        @keyframes checkPop {
            0% { transform: scale(0.72); }
            65% { transform: scale(1.12); }
            100% { transform: scale(1); }
        }

        @keyframes buttonReady {
            0% { transform: translateY(0) scale(1); }
            45% { transform: translateY(-2px) scale(1.025); }
            100% { transform: translateY(0) scale(1); }
        }

        @media (max-width: 900px) {
            .role-choice-grid {
                grid-template-columns: 1fr;
            }

            .role-choice-card {
                min-height: 190px;
            }
        }

        @media (max-width: 780px) {
            body {
                padding: 1rem;
                align-items: flex-start;
            }

            .onboarding-panel {
                padding: 1.25rem;
            }

            .onboarding-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .onboarding-actions {
                align-items: stretch;
                flex-direction: column;
            }

            .onboarding-actions,
            .onboarding-actions .btn {
                width: 100%;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                animation-duration: 1ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 1ms !important;
            }
        }
    </style>
</head>
<body>
    <a href="${pageContext.request.contextPath}/index.jsp" class="auth-home-btn" title="Về trang chủ">
        <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
    </a>

    <main class="onboarding-shell">
        <section class="onboarding-panel">
            <div class="onboarding-header">
                <div class="onboarding-title">
                    <h1>Chọn vai trò của bạn</h1>
                    <p>HIPZI sẽ mở đúng không gian học tập sau khi bạn xác nhận.</p>
                </div>
            </div>

            <% if (errorMsg != null) { %>
                <div class="alert alert-error">
                    <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    <span><%= h(errorMsg) %></span>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/onboarding" method="POST">
                <div class="role-choice-grid">
                    <label class="role-choice-card active student-card">
                        <input type="radio" name="role" value="student" checked>
                        <span class="role-card-top">
                            <span class="role-icon student">H</span>
                            <span class="role-check">&#10003;</span>
                        </span>
                        <h2>Học viên</h2>
                        <p>Luyện tập, tham gia lớp học, theo dõi tiến độ và nhận tài liệu phù hợp.</p>
                    </label>

                    <label class="role-choice-card parent-card">
                        <input type="radio" name="role" value="parent">
                        <span class="role-card-top">
                            <span class="role-icon parent">P</span>
                            <span class="role-check">&#10003;</span>
                        </span>
                        <h2>Phụ huynh</h2>
                        <p>Kết nối với học viên, theo dõi quá trình học tập và các hoạt động liên quan.</p>
                    </label>

                    <label class="role-choice-card teacher-card">
                        <input type="radio" name="role" value="teacher">
                        <span class="role-card-top">
                            <span class="role-icon teacher">G</span>
                            <span class="role-check">&#10003;</span>
                        </span>
                        <h2>Giảng viên</h2>
                        <p>Tạo lớp học, gửi hồ sơ giảng dạy và quản lý tài liệu sau khi được duyệt.</p>
                    </label>
                </div>

                <div class="onboarding-actions">
                    <span class="onboarding-note">Bạn có thể cập nhật hồ sơ chi tiết ở trang tiếp theo.</span>
                    <button type="submit" class="btn btn-primary">Tiếp tục</button>
                </div>
            </form>
        </section>
    </main>
    <script>
        const roleCards = document.querySelectorAll('.role-choice-card');
        const continueBtn = document.querySelector('.onboarding-actions .btn');
        roleCards.forEach(card => {
            const input = card.querySelector('input[name="role"]');
            card.addEventListener('click', () => {
                roleCards.forEach(item => item.classList.remove('active'));
                card.classList.add('active');
                continueBtn.classList.remove('is-ready');
                void continueBtn.offsetWidth;
                continueBtn.classList.add('is-ready');
            });
            input.addEventListener('change', () => {
                roleCards.forEach(item => item.classList.remove('active'));
                card.classList.add('active');
                continueBtn.classList.remove('is-ready');
                void continueBtn.offsetWidth;
                continueBtn.classList.add('is-ready');
            });
        });
    </script>
</body>
</html>
