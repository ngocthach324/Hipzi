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
    <meta name="description" content="Phòng thi HIPZI – luyện đề tự do hoặc tham gia kỳ thi chính thức với bảng xếp hạng toàn quốc.">
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400&display=block">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <style>
        /* ─── BASE ───────────────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; }

        /* Một background duy nhất cho toàn bộ trang — đồng nhất sau navbar và bên dưới */
        body {
        }

        /* ─── HERO SECTION ───────────────────────────────────────────── */
        .er-page { background: transparent; min-height: 100vh; overflow-x: hidden; }

        .er-hero {
            position: relative;
            padding: 7.5rem 1.5rem 5rem;
            text-align: center;
        }


        .er-hero-inner {
            position: relative;
            z-index: 1;
            max-width: 740px;
            margin: 0 auto;
        }

        /* Live-dot badge */
        .er-badge {
            display: inline-flex;
            align-items: center;
            gap: .5rem;
            padding: .38rem 1rem;
            background: rgba(20,184,166,.1);
            border: 1px solid rgba(20,184,166,.28);
            border-radius: 999px;
            font-size: .72rem;
            font-weight: 800;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: #0f766e;
            margin-bottom: 1.6rem;
        }
        .er-badge-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            background: #14b8a6;
            box-shadow: 0 0 0 3px rgba(20,184,166,.25);
            animation: er-dot-pulse 2s ease-in-out infinite;
        }
        @keyframes er-dot-pulse {
            0%,100% { box-shadow: 0 0 0 3px rgba(20,184,166,.25); }
            50%      { box-shadow: 0 0 0 7px rgba(20,184,166,.08); }
        }

        .er-hero-title {
            font-size: clamp(2.35rem, 5.5vw, 4rem);
            font-weight: 900;
            line-height: 1.09;
            letter-spacing: -.03em;
            color: #0f172a;
            margin-bottom: 1.1rem;
        }
        .er-hero-title .hl {
            position: relative;
            display: inline-block;
            background: linear-gradient(135deg, #058c63 0%, #0aaf7e 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            white-space: nowrap;
        }
        .er-hero-title .hl::after {
            content: attr(data-shine);
            position: absolute;
            inset: 0;
            color: transparent;
            background: linear-gradient(115deg, transparent 0%, transparent 45%, rgba(255, 255, 255, 0.8) 50%, transparent 55%, transparent 100%);
            background-size: 240% 100%;
            background-repeat: no-repeat;
            -webkit-background-clip: text;
            background-clip: text;
            pointer-events: none;
            animation: heroShine 2.5s linear infinite;
        }
        @keyframes heroShine {
            0% { background-position: 130% 0; opacity: 0; }
            8% { background-position: 130% 0; opacity: 0.95; }
            96% { background-position: -130% 0; opacity: 0.95; }
            100% { background-position: -130% 0; opacity: 0; }
        }

        .er-hero-sub {
            font-size: 1.05rem;
            line-height: 1.75;
            color: #475569;
            max-width: 600px;
            margin: 0 auto 2.4rem;
        }

        /* Stats row */
        .er-stats {
            display: inline-flex;
            align-items: center;
            gap: 2.2rem;
            flex-wrap: wrap;
            justify-content: center;
        }
        .er-stat { display: flex; flex-direction: column; align-items: center; gap: .15rem; }
        .er-stat-val {
            font-size: 1.65rem;
            font-weight: 900;
            color: #0f172a;
            letter-spacing: -.035em;
        }
        .er-stat-lbl {
            font-size: .7rem;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            color: #94a3b8;
        }
        .er-stat-sep { width: 1px; height: 34px; background: #e2e8f0; }

        /* ─── CARDS SECTION ──────────────────────────────────────────── */
        .er-cards-section { padding: 0 1.5rem 2.5rem; }
        .er-cards-inner   { max-width: 1080px; margin: 0 auto; }

        .er-cards-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.4rem;
            margin-bottom: 1.4rem;
        }

        /* ─── MAIN CARD ──────────────────────────────────────────────── */
        .er-card {
            position: relative;
            display: flex;
            flex-direction: column;
            text-decoration: none;
            border-radius: 22px;
            overflow: hidden;
            padding: 2.6rem 2.4rem;
            min-height: 400px;
            transition:
                transform .32s cubic-bezier(.34,1.56,.64,1),
                box-shadow .28s ease;
        }
        .er-card:hover { transform: translateY(-10px); }

        /* Floating orbs */
        .er-card::before,
        .er-card::after {
            content: "";
            position: absolute;
            border-radius: 50%;
            pointer-events: none;
        }
        .er-card::before {
            top: -80px; right: -70px;
            width: 260px; height: 260px;
            background: rgba(255,255,255,.1);
        }
        .er-card::after {
            bottom: -90px; left: -50px;
            width: 300px; height: 300px;
            background: rgba(255,255,255,.06);
        }

        /* Card A – practice (teal gradient) */
        .er-card--practice {
            background: linear-gradient(150deg, #0d9488 0%, #0f766e 45%, #0284c7 100%);
            box-shadow: 0 24px 60px rgba(13,148,136,.35);
        }
        .er-card--practice:hover { box-shadow: 0 40px 80px rgba(13,148,136,.42); }

        /* Card B – contest (indigo-purple) */
        .er-card--contest {
            background: linear-gradient(150deg, #6366f1 0%, #4f46e5 45%, #7c3aed 100%);
            box-shadow: 0 24px 60px rgba(99,102,241,.32);
        }
        .er-card--contest:hover { box-shadow: 0 40px 80px rgba(99,102,241,.42); }

        .er-card-body {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        /* Tag pill */
        .er-card-tag {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            padding: .32rem .85rem;
            background: rgba(255,255,255,.18);
            border: 1px solid rgba(255,255,255,.28);
            border-radius: 999px;
            font-size: .7rem;
            font-weight: 800;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: rgba(255,255,255,.92);
            width: fit-content;
            margin-bottom: 1.6rem;
            backdrop-filter: blur(8px);
        }
        .er-card-tag svg { width: 10px; height: 10px; stroke: rgba(255,255,255,.88); }

        /* Icon box */
        .er-card-iconbox {
            width: 58px; height: 58px;
            border-radius: 15px;
            background: rgba(255,255,255,.16);
            border: 1px solid rgba(255,255,255,.22);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 1.4rem;
            backdrop-filter: blur(8px);
        }
        .er-card-iconbox svg { width: 26px; height: 26px; stroke: rgba(255,255,255,.94); }

        .er-card-title {
            font-size: 2.1rem;
            font-weight: 900;
            color: #fff;
            letter-spacing: -.025em;
            line-height: 1.12;
            margin-bottom: .7rem;
        }

        .er-card-desc {
            font-size: .94rem;
            line-height: 1.72;
            color: rgba(255,255,255,.76);
            flex-grow: 1;
            margin-bottom: 1.6rem;
        }

        /* Feature list */
        .er-card-features {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: .52rem;
            margin-bottom: 2rem;
        }
        .er-card-features li {
            display: flex;
            align-items: center;
            gap: .55rem;
            font-size: .83rem;
            color: rgba(255,255,255,.82);
            font-weight: 500;
        }
        .er-feat-check {
            width: 17px; height: 17px;
            border-radius: 50%;
            flex-shrink: 0;
            background: rgba(255,255,255,.22);
            border: 1.5px solid rgba(255,255,255,.38);
            display: flex; align-items: center; justify-content: center;
        }
        .er-feat-check svg { width: 9px; height: 9px; stroke: #fff; stroke-width: 2.5; }

        /* CTA button */
        .er-card-cta {
            display: inline-flex;
            align-items: center;
            gap: .65rem;
            padding: .88rem 1.55rem;
            background: rgba(255,255,255,.96);
            border-radius: 999px;
            font-size: .88rem;
            font-weight: 800;
            letter-spacing: .01em;
            width: fit-content;
            transition: gap .22s ease, background .18s ease;
        }
        .er-card--practice .er-card-cta { color: #0f766e; }
        .er-card--contest  .er-card-cta { color: #4f46e5; }
        .er-card:hover .er-card-cta { gap: 1rem; background: #fff; }

        .er-cta-arrow {
            width: 22px; height: 22px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem;
            font-weight: 900;
            transition: transform .22s ease;
        }
        .er-card--practice .er-cta-arrow { background: rgba(15,118,110,.13); color: #0f766e; }
        .er-card--contest  .er-cta-arrow { background: rgba(79,70,229,.13); color: #4f46e5; }
        .er-card:hover .er-cta-arrow { transform: translateX(4px); }


        /* ─── RESPONSIVE ─────────────────────────────────────────────── */
        @media (max-width: 880px) {
            .er-cards-grid  { grid-template-columns: 1fr; }
            .er-card        { min-height: 330px; }
        }
        @media (max-width: 560px) {
            .er-hero        { padding: 6.5rem 1rem 3.5rem; }
            .er-hero-title  { font-size: 2.2rem; }
            .er-cards-section { padding: 0 1rem 2rem; }
            .er-card        { padding: 1.9rem 1.7rem; min-height: 280px; }
            .er-card-title  { font-size: 1.75rem; }
            .er-stats       { gap: 1.25rem; }
            .er-stat-sep    { display: none; }
        }
    </style>
</head>
<body>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <!-- ═══════════ NAVBAR (unchanged) ════════════════ -->
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

    <!-- ═══════════ PAGE CONTENT ══════════════════════ -->
    <div class="er-page">

        <!-- ── HERO ── -->
        <section class="er-hero" aria-labelledby="er-title">
            <div class="er-hero-inner">



                <h1 class="er-hero-title" id="er-title">
                    Sẵn sàng bứt phá<br><span class="hl" data-shine="thành tích?">thành tích?</span>
                </h1>

                <p class="er-hero-sub">
                    Chọn hình thức luyện tập phù hợp — từ thi thử tự do không giới hạn đến các kỳ thi HIPZI chính thức với bảng xếp hạng cạnh tranh toàn quốc.
                </p>

                <div class="er-stats" aria-label="Thống kê phòng thi">
                    <div class="er-stat">
                        <span class="er-stat-val">1,200+</span>
                        <span class="er-stat-lbl">Đề thi</span>
                    </div>
                    <span class="er-stat-sep" aria-hidden="true"></span>
                    <div class="er-stat">
                        <span class="er-stat-val">48k+</span>
                        <span class="er-stat-lbl">Lượt làm bài</span>
                    </div>
                    <span class="er-stat-sep" aria-hidden="true"></span>
                    <div class="er-stat">
                        <span class="er-stat-val">12</span>
                        <span class="er-stat-lbl">Môn học</span>
                    </div>
                    <span class="er-stat-sep" aria-hidden="true"></span>
                    <div class="er-stat">
                        <span class="er-stat-val">95%</span>
                        <span class="er-stat-lbl">Hài lòng</span>
                    </div>
                </div>

            </div>
        </section>

        <!-- ── CARDS ── -->
        <section class="er-cards-section" aria-label="Các hình thức thi trong HIPZI">
            <div class="er-cards-inner">

                <div class="er-cards-grid">

                    <!-- Card: Thi thử -->
                    <a class="er-card er-card--practice"
                       href="${pageContext.request.contextPath}/mock-exams"
                       aria-label="Vào khu vực Thi thử">
                        <div class="er-card-body">

                            <div class="er-card-tag">
                                <svg viewBox="0 0 24 24" fill="none" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>
                                </svg>
                                Luyện tập cá nhân
                            </div>

                            <div class="er-card-iconbox" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M9 11h6M9 15h3M7 3h10a2 2 0 0 1 2 2v14l-3-2-3 2-3-2-3 2V5a2 2 0 0 1 2-2z"/>
                                </svg>
                            </div>

                            <h2 class="er-card-title">Thi thử</h2>
                            <p class="er-card-desc">Luyện đề mở không giới hạn, kiểm tra năng lực tổng quát và làm quen với cấu trúc bài thi thật.</p>

                            <ul class="er-card-features" aria-label="Tính năng Thi thử">
                                <li>
                                    <span class="er-feat-check" aria-hidden="true">
                                        <svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </span>
                                    Kho đề đa dạng, cập nhật liên tục
                                </li>
                                <li>
                                    <span class="er-feat-check" aria-hidden="true">
                                        <svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </span>
                                    Kết quả chi tiết ngay sau khi nộp bài
                                </li>
                                <li>
                                    <span class="er-feat-check" aria-hidden="true">
                                        <svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </span>
                                    Tự chọn môn học, cấp độ và thời gian
                                </li>
                            </ul>

                            <div class="er-card-cta" aria-hidden="true">
                                <span>Khám phá thi thử</span>
                                <span class="er-cta-arrow">›</span>
                            </div>

                        </div>
                    </a>

                    <!-- Card: Kỳ thi HIPZI -->
                    <a class="er-card er-card--contest"
                       href="${pageContext.request.contextPath}/hipzi-exams"
                       aria-label="Vào khu vực Kỳ thi HIPZI">
                        <div class="er-card-body">

                            <div class="er-card-tag">
                                <svg viewBox="0 0 24 24" fill="none" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                                    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                                </svg>
                                Sự kiện thi chung
                            </div>

                            <div class="er-card-iconbox" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M8 21H5a2 2 0 0 1-2-2V5c0-1.1.9-2 2-2h14a2 2 0 0 1 2 2v5"/>
                                    <path d="m16 19 2 2 4-4"/>
                                    <path d="M9 7h6M9 11h4"/>
                                </svg>
                            </div>

                            <h2 class="er-card-title">Kỳ thi HIPZI</h2>
                            <p class="er-card-desc">Tham gia các kỳ thi chính thức do HIPZI tổ chức, cạnh tranh bảng xếp hạng và nhận phần thưởng hấp dẫn.</p>

                            <ul class="er-card-features" aria-label="Tính năng Kỳ thi HIPZI">
                                <li>
                                    <span class="er-feat-check" aria-hidden="true">
                                        <svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </span>
                                    Kỳ thi chính thức với đồng hồ đếm ngược
                                </li>
                                <li>
                                    <span class="er-feat-check" aria-hidden="true">
                                        <svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </span>
                                    Bảng xếp hạng công khai toàn quốc
                                </li>
                                <li>
                                    <span class="er-feat-check" aria-hidden="true">
                                        <svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    </span>
                                    Chứng nhận và phần thưởng cho người dẫn đầu
                                </li>
                            </ul>

                            <div class="er-card-cta" aria-hidden="true">
                                <span>Xem kỳ thi HIPZI</span>
                                <span class="er-cta-arrow">›</span>
                            </div>

                        </div>
                    </a>

                </div><!-- end .er-cards-grid -->



            </div>
        </section>

    </div><!-- end .er-page -->

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>

