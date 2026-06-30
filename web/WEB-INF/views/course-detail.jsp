<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Course"%>
<%@page import="java.util.List"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    Course course = (Course) request.getAttribute("course");
    Boolean isInCartObj = (Boolean) request.getAttribute("isInCart");
    boolean isInCart = isInCartObj != null ? isInCartObj : false;
    List<Course> relatedCourses = (List<Course>) request.getAttribute("relatedCourses");
    

    if (course == null) {
        response.sendRedirect(request.getContextPath() + "/courses");
        return;
    }
    
    String thumbUrl = course.getThumbnailUrl();
    String thumbStyle = (thumbUrl != null && !thumbUrl.trim().isEmpty())
            ? "background-image:url('" + h(thumbUrl) + "'); background-size:cover; background-position:center;"
            : "background:" + h(course.getThumbnailGradientOrDefault()) + "; display:flex; align-items:center; justify-content:center;";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= h(course.getTitle()) %> - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=12">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        body { font-family: "Inter", "Be Vietnam Pro", sans-serif; background: #f9f9f9; margin: 0; color: #111; }
        
        .detail-container { max-width: 1600px; width: 96%; margin: 2rem auto 50px; padding: 0 1.5rem; display: grid; grid-template-columns: 1fr 380px; gap: 2rem; align-items: start; }
        @media (max-width: 900px) {
            .detail-container { grid-template-columns: 1fr; }
        }

        /* ── HERO HEADER ── */
        .course-hero {
            background: linear-gradient(135deg, #0a1628 0%, #0f2744 40%, #0d3d2e 100%);
            position: relative; overflow: hidden;
            padding: 80px 0 48px;
            margin-top: 72px; /* navbar height */
        }
        .course-hero::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(ellipse 60% 80% at 10% 50%, rgba(0,177,103,.18) 0%, transparent 70%),
                        radial-gradient(ellipse 40% 60% at 90% 20%, rgba(99,102,241,.15) 0%, transparent 60%);
        }
        .course-hero::after {
            content: '';
            position: absolute; bottom: -1px; left: 0; right: 0; height: 48px;
            background: #f9f9f9;
            clip-path: ellipse(55% 100% at 50% 100%);
        }
        .hero-inner {
            max-width: 1600px; width: 96%;
            margin: 0 auto; padding: 0 1.5rem;
            position: relative; z-index: 1;
        }
        .hero-breadcrumb {
            font-size: 0.85rem; color: rgba(255,255,255,.55); margin-bottom: 1.25rem;
            display: flex; align-items: center; gap: 0.5rem;
        }
        .hero-breadcrumb a { color: #4ade80; text-decoration: none; font-weight: 500; }
        .hero-breadcrumb a:hover { color: #86efac; }
        .hero-breadcrumb .sep { color: rgba(255,255,255,.3); }
        .hero-subject-badge {
            display: inline-flex; align-items: center; gap: 0.4rem;
            background: rgba(0,177,103,.18); border: 1px solid rgba(0,177,103,.35);
            color: #4ade80; font-size: 0.8rem; font-weight: 600;
            padding: 0.3rem 0.9rem; border-radius: 999px; margin-bottom: 1.25rem;
            letter-spacing: .5px; text-transform: uppercase;
        }
        .hero-title {
            font-size: clamp(1.75rem, 3.5vw, 2.75rem);
            font-weight: 900; color: #fff;
            line-height: 1.25; margin: 0 0 1.25rem;
            max-width: 100%;
            text-shadow: 0 2px 20px rgba(0,0,0,.4);
        }
        .hero-meta {
            display: flex; flex-wrap: wrap; gap: 1.25rem;
            margin-bottom: 2rem;
        }
        .hero-meta-item {
            display: flex; align-items: center; gap: 0.45rem;
            color: rgba(255,255,255,.75); font-size: 0.9rem;
        }
        .hero-meta-item svg { width: 16px; height: 16px; color: #4ade80; flex-shrink: 0; }
        .hero-meta-item strong { color: #fff; }
        .hero-teacher-card {
            display: inline-flex; flex-direction: column; align-items: center; text-align: center; gap: 1rem;
            margin-bottom: -0.8rem;
        }
        .hero-teacher-avatar-wrap {
            position: relative;
            display: inline-block;
            border-radius: 50%;
            animation: avatarFloat 4s ease-in-out infinite;
        }
        .hero-teacher-avatar-wrap::after {
            content: '';
            position: absolute;
            inset: -2px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4ade80 0%, #3b82f6 100%);
            z-index: -1;
            opacity: 0;
            transition: opacity 0.4s ease;
            filter: blur(8px);
        }
        .hero-teacher-card:hover .hero-teacher-avatar-wrap::after {
            opacity: 0.8;
            animation: pulseGlow 2s infinite;
        }
        .hero-teacher-avatar {
            width: 140px; height: 140px; border-radius: 50%;
            border: 4px solid rgba(255,255,255,.9);
            object-fit: cover;
            background: linear-gradient(135deg,#059669,#6366f1);
            display: flex; align-items: center; justify-content: center;
            font-weight: 800; color: #fff; font-size: 3rem; flex-shrink: 0;
            box-shadow: 0 8px 24px rgba(0,0,0,0.25);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            z-index: 1;
        }
        .hero-teacher-card:hover .hero-teacher-avatar {
            transform: scale(1.08) rotate(3deg);
            box-shadow: 0 15px 35px rgba(0,0,0,0.4);
            border-color: #fff;
        }

        /* ── REST ── */
        .main-content { background: #fff; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 20px rgba(0,0,0,0.04); }
        .teacher-avatar { width: 48px; height: 48px; border-radius: 50%; object-fit: cover; background: #c6f6d5; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #00b167; }

        .section-title { font-size: 1.25rem; font-weight: 700; margin-bottom: 1rem; color: #111; }
        .course-desc { color: #444; line-height: 1.7; margin-bottom: 2rem; white-space: pre-wrap; }

        .checkout-card { background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 8px 30px rgba(0,0,0,0.08); position: sticky; top: 100px; }
        .card-thumb { width: 100%; aspect-ratio: 16/9; position: relative; }
        .card-thumb-bg { width: 100%; height: 100%; }
        .card-thumb svg { width: 64px; height: 64px; }
        .card-body { padding: 1.5rem; }
        .price { font-size: 2rem; font-weight: 800; color: #111; margin-bottom: 1.5rem; }
        .price.free { color: #00b167; }
        
        .btn { width: 100%; padding: 1rem; border-radius: 8px; font-weight: 600; font-size: 1rem; cursor: pointer; border: none; text-align: center; text-decoration: none; display: inline-block; transition: all 0.2s; margin-bottom: 1rem; box-sizing: border-box; }
        .btn-primary { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: #fff; }
        .btn-primary:hover { background: linear-gradient(135deg, #059669 0%, #047857 100%); transform: translateY(-2px); box-shadow: 0 4px 12px rgba(16,185,129,0.3); }
        .btn-secondary { background: #f1f5f9; color: #334155; }
        .btn-secondary:hover { background: #e2e8f0; }
        
        .features-list { list-style: none; padding: 0; margin: 0; }
        .features-list li { display: flex; align-items: center; gap: 0.75rem; color: #555; font-size: 0.95rem; margin-bottom: 0.75rem; }
        .features-list svg { width: 18px; height: 18px; color: #00b167; flex-shrink: 0; }

        .btn-added { background: #e2e8f0; color: #475569; pointer-events: none; }

        /* ── HERO HEADER (inside card) ── */
        .course-hero {
            background: linear-gradient(135deg, #115e59, #059669);
            border-radius: 14px;
            position: relative; overflow: hidden;
            padding: 2rem 2.5rem 6rem;
            margin: -2rem -2rem 2rem -2rem; /* bleed to card edges */
            display: flex; justify-content: space-between; align-items: flex-end; gap: 2rem;
        }
        .course-hero::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(ellipse 70% 90% at 5% 50%, rgba(0,177,103,.2) 0%, transparent 65%),
                        radial-gradient(ellipse 50% 70% at 95% 10%, rgba(99,102,241,.18) 0%, transparent 60%);
            pointer-events: none;
        }
        .hero-breadcrumb {
            font-size: 0.82rem; color: rgba(255,255,255,.5); margin-bottom: 1rem;
            display: flex; align-items: center; gap: 0.5rem; position: relative; z-index: 1;
        }
        .hero-breadcrumb a { color: #4ade80; text-decoration: none; font-weight: 500; }
        .hero-breadcrumb a:hover { color: #86efac; }
        .hero-breadcrumb .sep { color: rgba(255,255,255,.25); }
        .hero-subject-badge {
            display: inline-flex; align-items: center; gap: 0.4rem;
            background: rgba(0,177,103,.18); border: 1px solid rgba(0,177,103,.4);
            color: #4ade80; font-size: 0.75rem; font-weight: 700;
            padding: 0.25rem 0.8rem; border-radius: 999px; margin-bottom: 1rem;
            letter-spacing: .6px; text-transform: uppercase;
            position: relative; z-index: 1;
        }
        .hero-title {
            font-size: clamp(1.4rem, 2.5vw, 2rem);
            font-weight: 900; color: #fff;
            line-height: 1.3; margin: 0 0 1.25rem;
            text-shadow: 0 2px 16px rgba(0,0,0,.4);
            position: relative; z-index: 1;
            max-width: 100%;
        }
        .hero-meta {
            display: flex; flex-wrap: wrap; gap: 1rem;
            margin-bottom: 0;
            position: relative; z-index: 1;
        }
        .hero-meta-item {
            display: flex; align-items: center; gap: 0.4rem;
            color: rgba(255,255,255,.75); font-size: 0.88rem;
        }
        .hero-meta-item svg { width: 15px; height: 15px; flex-shrink: 0; }
        .hero-meta-item strong { color: #fff; }
        
        .benefit-list { display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; margin-bottom: 3rem; }
        @media (max-width: 768px) { .benefit-list { grid-template-columns: 1fr; } }
        .benefit-item { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 1.5rem; display: flex; flex-direction: column; gap: 0.75rem; align-items: flex-start; transition: box-shadow 0.2s, border-color 0.2s; }
        .benefit-item:hover { box-shadow: 0 4px 12px rgba(13,148,136,0.08); border-color: #0d9488; }
        .benefit-icon { line-height: 1; padding: 0.75rem; background: #f0fdf4; border-radius: 10px; color: #10b981; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .benefit-text { color: #334155; line-height: 1.6; font-size: 0.95rem; }
        
        .curriculum-section { margin-bottom: 3rem; background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; }
        .curriculum-part { border-bottom: 1px solid #e2e8f0; }
        .curriculum-part:last-child { border-bottom: none; }
        .curriculum-part-title { font-weight: 700; color: #1e293b; font-size: 1rem; padding: 1.25rem 1.5rem; background: #f8fafc; cursor: pointer; display: flex; justify-content: space-between; align-items: center; transition: background 0.2s; }
        .curriculum-part-title:hover { background: #f1f5f9; }
        .curriculum-list { padding: 0.5rem 1.5rem 1.25rem; display: flex; flex-direction: column; gap: 0.5rem; }
        .curriculum-item { display: flex; gap: 0.75rem; align-items: flex-start; padding: 0.75rem; border-radius: 8px; transition: background 0.2s; cursor: pointer; }
        .curriculum-item:hover { background: #f8fafc; }
        .curriculum-icon { color: #0d9488; flex-shrink: 0; margin-top: 2px; }
        .curriculum-text { color: #475569; line-height: 1.5; font-size: 0.95rem; flex-grow: 1; }

        .reviews-section { margin-bottom: 3rem; }
        .review-overview { display: flex; gap: 2rem; align-items: center; margin-bottom: 2rem; background: #f8fafc; padding: 1.5rem; border-radius: 12px; }
        .review-score { text-align: center; }
        .review-score-num { font-size: 3rem; font-weight: 900; color: #1e293b; line-height: 1; }
        .review-score-stars { color: #f59e0b; margin: 0.5rem 0; font-size: 1.2rem; }
        .review-score-total { color: #64748b; font-size: 0.85rem; }
        .review-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.25rem; }
        .review-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 1.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .review-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 1rem; }
        .review-user-info { display: flex; align-items: center; gap: 0.75rem; }
        .review-avatar { width: 42px; height: 42px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; color: #fff; }
        .review-avatar.color-1 { background: #3b82f6; }
        .review-avatar.color-2 { background: #10b981; }
        .review-avatar.color-3 { background: #f59e0b; }
        .review-name { font-weight: 600; color: #1e293b; font-size: 0.95rem; }
        .review-date { color: #94a3b8; font-size: 0.8rem; margin-top: 2px; }
        .review-rating { color: #f59e0b; font-size: 0.85rem; }
        .review-text { color: #475569; font-size: 0.95rem; line-height: 1.6; }
        
        /* Interactive Star Rating Trick */
        .interactive-stars { display: flex; gap: 4px; color: #cbd5e1; cursor: pointer; }
        .interactive-stars svg { transition: color 0.2s, transform 0.2s; }
        .interactive-stars:hover svg { color: #facc15; }
        .interactive-stars svg:hover ~ svg { color: #cbd5e1; }
        .interactive-stars svg:hover { transform: scale(1.15); }

        .related-courses-section { border-top: 1px solid #e2e8f0; padding-top: 3rem; margin-top: 2rem; }
        
        /* Related Courses - Sync with Featured Courses */
        .weekly-featured-viewport {
            overflow: hidden;
            width: min(1500px, calc(100vw - 4rem));
            max-width: none;
            margin-left: 50%;
            transform: translateX(-50%);
            padding: .35rem 0 1rem;
            -webkit-mask-image: linear-gradient(90deg, transparent 0, #000 7%, #000 93%, transparent 100%);
            mask-image: linear-gradient(90deg, transparent 0, #000 7%, #000 93%, transparent 100%);
        }
        .weekly-featured-grid {
            display: flex;
            gap: 1.25rem;
            width: max-content;
            will-change: transform;
            transform: translateX(0);
        }
        .weekly-course-card {
            display: flex;
            flex-direction: column;
            width: 320px;
            min-height: 100%;
            padding: .9rem;
            background: rgba(255,255,255,.92);
            border: 1.5px solid rgba(226,232,240,.95);
            border-radius: 18px;
            box-shadow: 0 16px 36px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.8);
            color: inherit;
            text-decoration: none;
            transition: box-shadow .2s ease;
            cursor: default;
        }
        .weekly-course-card:hover {
            box-shadow: 0 16px 36px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.8);
        }
        .weekly-thumb {
            width: 100%;
            aspect-ratio: 1.45 / 1;
            border-radius: 14px;
            overflow: hidden;
            position: relative;
            margin-bottom: 1rem;
        }
        .weekly-thumb::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(115deg, transparent 0%, transparent 42%, rgba(255,255,255,.58) 50%, transparent 58%, transparent 100%);
            transform: translateX(-130%);
            pointer-events: none;
            opacity: 0;
            z-index: 1;
        }
        .weekly-course-card:hover .weekly-thumb::after {
            animation: weeklyCoverShine .8s ease-out 1;
        }
        .weekly-thumb-bg {
            width: 100%;
            height: 100%;
            transition: transform .55s cubic-bezier(.16,1,.3,1);
        }
        .weekly-course-card:hover .weekly-thumb-bg {
            transform: scale(1.055);
        }
        .weekly-rating-badge {
            position: absolute;
            top: .65rem;
            left: .65rem;
            display: inline-flex;
            align-items: center;
            gap: .25rem;
            padding: .24rem .62rem;
            border-radius: 9999px;
            background: rgba(15,23,42,.78);
            color: #fff;
            font-size: .72rem;
            font-weight: 800;
            backdrop-filter: blur(8px);
            z-index: 2;
        }
        .weekly-rating-badge svg {
            width: 12px;
            height: 12px;
            fill: #f59e0b;
            stroke: #f59e0b;
        }
        .weekly-info {
            min-width: 0;
            display: flex;
            flex-direction: column;
            flex: 1;
            padding: 0 .1rem .1rem;
        }
        .weekly-title {
            color: #0f172a;
            font-size: 1.05rem;
            font-weight: 800;
            line-height: 1.38;
            margin-bottom: .65rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .weekly-teacher-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            margin-bottom: 1rem;
        }
        .weekly-teacher {
            min-width: 0;
            color: #64748b;
            font-size: .84rem;
            font-weight: 700;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .weekly-students {
            display: flex;
            align-items: center;
            gap: .28rem;
            color: #64748b;
            font-size: .8rem;
            font-weight: 700;
            white-space: nowrap;
        }
        .weekly-students svg {
            width: 14px;
            height: 14px;
            stroke-width: 2.2;
        }
        .weekly-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            margin-top: auto;
            padding-top: .35rem;
        }
        .weekly-price {
            color: #0f172a;
            font-size: .98rem;
            font-weight: 800;
            white-space: nowrap;
        }
        .weekly-price.free { color: #16a34a; }
        .weekly-cart-btn {
            position: absolute;
            top: .65rem;
            right: .65rem;
            width: 34px;
            height: 34px;
            flex: 0 0 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: rgba(255,255,255,.86);
            border: 1px solid rgba(255,255,255,.85);
            color: #0f172a;
            box-shadow: 0 8px 18px rgba(15,23,42,.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            transition: transform .2s ease, background .2s ease, color .2s ease, box-shadow .2s ease;
            z-index: 2;
            cursor: pointer;
        }
        .weekly-course-card:hover .weekly-cart-btn {
            color: #0d9488;
            background: rgba(255,255,255,.96);
            box-shadow: 0 10px 22px rgba(15,23,42,.16);
            transform: translateY(-1px);
        }
        .weekly-cart-btn svg {
            width: 17px;
            height: 17px;
            stroke-width: 2.2;
        }
        .weekly-cta {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 36px;
            padding: .48rem .9rem;
            border-radius: 9999px;
            background: linear-gradient(135deg, #0d9488, #10b981);
            color: #fff;
            font-size: .82rem;
            font-weight: 800;
            white-space: nowrap;
            border: 0;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(13,148,136,.18);
            transition: background .2s ease, box-shadow .2s ease, transform .2s ease;
        }
        .weekly-cta:hover {
            box-shadow: 0 10px 22px rgba(13,148,136,.28);
            transform: translateY(-1px);
        }
        @keyframes weeklyCoverShine {
            0% { transform: translateX(-130%); opacity: 0; }
            12% { opacity: .95; }
            100% { transform: translateX(130%); opacity: 0; }
        }
        @keyframes avatarFloat {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }
        @keyframes pulseGlow {
            0%, 100% { filter: blur(8px); transform: scale(1); opacity: 0.7; }
            50% { filter: blur(12px); transform: scale(1.05); opacity: 1; }
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
                <li><a href="${pageContext.request.contextPath}/mock-exams">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/courses" class="active">Khóa học</a></li>
            </ul>
            <div class="navbar-user-controls">
                <%@ include file="/WEB-INF/fragments/cart-icon.jspf" %>
                <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                <div class="nav-avatar-dropdown">
                    <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                        <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                            <img src="<%= h(user.getAvatarUrl()) %>" alt="Avatar">
                        <% } else { 
                            String inits = "H";
                            if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
                                String[] parts = user.getDisplayName().trim().split("\\s+");
                                inits = parts[parts.length - 1].substring(0, 1).toUpperCase();
                            }
                        %>
                            <span class="nav-avatar-initials"><%= h(inits) %></span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <% 
        String errorMsg = (String) session.getAttribute("errorMsg");
        String successMsg = (String) session.getAttribute("successMsg");
        if (errorMsg != null) { session.removeAttribute("errorMsg"); }
        if (successMsg != null) { session.removeAttribute("successMsg"); }
    %>


    <div class="detail-container" style="margin-top: 100px;">
        <% if (errorMsg != null) { %>
            <div style="grid-column: 1 / -1; padding: 1rem; background: #fee2e2; color: #dc2626; border-radius: 8px; margin-bottom: -1rem; font-weight: 500;">
                <%= h(errorMsg) %>
            </div>
        <% } %>
        <div class="main-content">
            <!-- Hero header inside card -->
            <div class="course-hero">
                <div class="hero-left-content" style="flex: 1; max-width: 50%;">
                    <nav class="hero-breadcrumb">
                        <a href="${pageContext.request.contextPath}/courses">Khóa học</a>
                        <span class="sep">›</span>
                        <span class="hero-subject-badge" style="margin-bottom: 0;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="12" height="12"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                            <%= h(course.getSubjectName()) %>
                        </span>
                    </nav>
                    <h1 class="hero-title"><%= h(course.getTitle()) %></h1>
                    <div class="hero-meta">
                        <div class="hero-meta-item">
                            <svg viewBox="0 0 24 24" fill="#facc15" stroke="#facc15" stroke-width="1"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <strong><%= h(course.getDisplayRating()) %></strong>&nbsp;sao (<%= course.getRatingCount() %> đánh giá)
                        </div>
                        <div class="hero-meta-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            <strong><%= course.getStudentsCount() %></strong>&nbsp;học viên
                        </div>
                        <div class="hero-meta-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="14 2 18 6 7 17 3 17 3 13 14 2"/><line x1="3" y1="22" x2="21" y2="22"/></svg>
                            Cấp độ:&nbsp;<strong><%= h(course.getLevelName()) %></strong>
                        </div>
                    </div>
                </div>
                
                <div class="hero-right-content" style="flex-shrink: 0; margin-right: 2rem;">
                    <div class="hero-teacher-card">
                        <div class="hero-teacher-avatar-wrap" title="Giảng viên: <%= h(course.getTeacherName()) %>">
                            <% if (course.getTeacherAvatarUrl() != null && !course.getTeacherAvatarUrl().isEmpty()) { %>
                                <img src="<%= h(course.getTeacherAvatarUrl()) %>" class="hero-teacher-avatar" alt="Giáo viên">
                            <% } else {
                                String tInits = "GV";
                                if (course.getTeacherName() != null && !course.getTeacherName().isEmpty()) {
                                    String[] tParts = course.getTeacherName().trim().split("\\s+");
                                    tInits = tParts[tParts.length - 1].substring(0, 1).toUpperCase();
                                }
                            %>
                                <div class="hero-teacher-avatar"><%= h(tInits) %></div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <h2 class="section-title">Giới thiệu khóa học</h2>
            <div class="course-desc">
                <%= course.getShortDescription() != null ? h(course.getShortDescription()) : "Chưa có mô tả chi tiết." %>
            </div>
            
            <% if (course.isViewerEnrolled()) { %>
            <h2 class="section-title">Hướng dẫn truy cập</h2>
            <div class="course-desc" style="background:#e0e7ff; border-left-color:#6366f1; color:#3730a3;">
                <% if (course.getAccessInstructions() != null && !course.getAccessInstructions().isEmpty()) { %>
                    <%= h(course.getAccessInstructions()) %>
                <% } else { %>
                    Bạn đã đăng ký khóa học này. Hãy làm theo hướng dẫn hoặc liên hệ giáo viên để được cấp quyền truy cập tài nguyên.
                <% } %>
            </div>
            <% } %>

            <!-- 1. Sau khi học sẽ nhận được gì -->
            <h2 class="section-title">Mục tiêu khóa học</h2>
            <div class="benefit-list">
                <% java.util.List<String> objectives = course.getLearningObjectivesList();
                   if (objectives != null && !objectives.isEmpty()) {
                       for (String obj : objectives) { %>
                <div class="benefit-item">
                    <div class="benefit-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="24" height="24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="benefit-text"><%= h(obj) %></div>
                </div>
                <%     }
                   } else { %>
                <div style="color: var(--text-muted); font-style: italic;">Chưa có thông tin mục tiêu khóa học.</div>
                <% } %>
            </div>

            <!-- 2. Nội dung chính khóa học -->
            <h2 class="section-title">Nội dung chương trình</h2>
            <div class="curriculum-section">
                <% java.util.List<java.util.Map<String,String>> curriculums = course.getCurriculumList();
                   if (curriculums != null && !curriculums.isEmpty()) {
                       for (int i = 0; i < curriculums.size(); i++) {
                           java.util.Map<String,String> part = curriculums.get(i);
                %>
                <div class="curriculum-part">
                    <div class="curriculum-part-title">
                        <span><%= h(part.get("title")) %></span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" width="16" height="16"><polyline points="6 9 12 15 18 9"></polyline></svg>
                    </div>
                    <div class="curriculum-list">
                        <div class="curriculum-item">
                            <svg class="curriculum-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                            <div class="curriculum-text"><%= h(part.get("description")) %></div>
                        </div>
                    </div>
                </div>
                <%     }
                   } else { %>
                <div style="color: var(--text-muted); font-style: italic;">Chưa có thông tin nội dung chương trình.</div>
                <% } %>
            </div>

            <!-- 3. Đánh giá của học viên -->
            <h2 class="section-title" id="reviews-section">Đánh giá từ học viên</h2>
            <div class="reviews-section">
                <div class="review-overview">
                    <div class="review-score">
                        <div class="review-score-num"><%= String.format(java.util.Locale.US, "%.1f", course.getRatingAverage()) %></div>
                        <div class="review-score-stars">
                            <% int avgRating = Math.round(course.getRatingAverage().floatValue());
                               for(int s=1; s<=5; s++) { %>
                                <%= s <= avgRating ? "⭐" : "☆" %>
                            <% } %>
                        </div>
                        <div class="review-score-total"><%= course.getRatingCount() %> đánh giá</div>
                    </div>
                    
                    <% if (request.getSession(false) != null && request.getSession(false).getAttribute("loggedUser") != null) {
                        com.hipzi.model.CourseReview userReview = (com.hipzi.model.CourseReview) request.getAttribute("userReview");
                        if (userReview != null) {
                    %>
                    <div class="review-form-container" style="flex-grow: 1; border-left: 2px dashed #e2e8f0; padding-left: 2.5rem; margin-left: 0.5rem; display: flex; flex-direction: column; justify-content: center; align-items: center;">
                        <div style="background: #ecfdf5; border: 1px solid #a7f3d0; color: #059669; padding: 1.5rem 2rem; border-radius: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 0.75rem; text-align: left; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.05);">
                            <div style="background: #10b981; color: #fff; border-radius: 50%; padding: 8px; flex-shrink: 0;">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" width="18" height="18"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            </div>
                            <div>
                                <div style="font-size: 1.05rem; font-weight: 700;">Cảm ơn bạn đã đánh giá!</div>
                                <div style="font-size: 0.85rem; font-weight: 500; color: #047857; margin-top: 4px;">Đánh giá của bạn giúp khóa học ngày càng hoàn thiện hơn.</div>
                            </div>
                        </div>
                    </div>
                    <%  } else {
                            int myRating = 5;
                            String myText = "";
                    %>
                    <div class="review-form-container" style="flex-grow: 1; border-left: 2px dashed #e2e8f0; padding-left: 2.5rem; margin-left: 0.5rem;">
                        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.25rem;">
                            <h3 style="font-size: 1.1rem; font-weight: 800; color: #0f172a; margin: 0;">Gửi Đánh Giá Của Bạn</h3>
                            <div class="interactive-stars" id="starRatingContainer">
                                <% for(int i=1; i<=5; i++) { %>
                                <svg data-val="<%= i %>" class="star-icon" width="26" height="26" viewBox="0 0 24 24" fill="<%= i <= myRating ? "currentColor" : "none" %>" stroke="currentColor" stroke-width="1" stroke-linejoin="round" style="cursor:pointer; color: #fbbf24;"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                <% } %>
                            </div>
                        </div>
                        <form class="review-form" action="${pageContext.request.contextPath}/course/review" method="POST">
                            <input type="hidden" name="courseId" value="<%= course.getId() %>">
                            <input type="hidden" name="rating" id="reviewRatingInput" value="<%= myRating %>">
                            <div style="display: flex; gap: 1rem; align-items: flex-start;">
                                <div class="review-avatar" style="flex-shrink: 0; background: linear-gradient(135deg, #0ea5e9, #6366f1); font-size: 0.8rem;">Bạn</div>
                                <div style="flex-grow: 1; position: relative;">
                                    <textarea name="reviewText" placeholder="Khóa học này thế nào? Hãy chia sẻ trải nghiệm của bạn nhé..." style="width: 100%; padding: 1rem 1.25rem; background: #fff; border: 2px solid #e2e8f0; border-radius: 12px; resize: vertical; min-height: 100px; font-family: inherit; font-size: 0.95rem; color: #1e293b; outline: none; transition: all 0.3s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.02);" onfocus="this.style.borderColor='#0d9488'; this.style.boxShadow='0 0 0 4px rgba(13,148,136,0.1)';" onblur="this.style.borderColor='#e2e8f0'; this.style.boxShadow='0 2px 4px rgba(0,0,0,0.02)';"><%= h(myText) %></textarea>
                                    <div style="display: flex; justify-content: flex-end; margin-top: 0.75rem;">
                                        <button type="submit" style="display: inline-flex; align-items: center; gap: 0.5rem; background: linear-gradient(135deg, #0d9488, #10b981); color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 50px; font-weight: 700; font-size: 0.95rem; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(13,148,136,0.25);" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 16px rgba(13,148,136,0.35)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(13,148,136,0.25)';">
                                            <span>Gửi đánh giá</span>
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <% } 
                    } %>
                </div>
                
                <div class="review-grid">
                    <% java.util.List<com.hipzi.model.CourseReview> reviews = (java.util.List<com.hipzi.model.CourseReview>) request.getAttribute("reviews");
                       if (reviews != null && !reviews.isEmpty()) {
                           int colorIdx = 1;
                           for (com.hipzi.model.CourseReview r : reviews) { 
                               String firstChar = r.getStudentName() != null && r.getStudentName().length() > 0 ? r.getStudentName().substring(0, 1).toUpperCase() : "U";
                               String colorClass = "color-" + (colorIdx++ % 5 + 1); // Cycle through color-1 to color-5
                    %>
                    <div class="review-card">
                        <div class="review-header">
                            <div class="review-user-info">
                                <% if(r.getStudentAvatar() != null && !r.getStudentAvatar().isEmpty()) { %>
                                    <div class="review-avatar" style="background-image:url('<%= h(r.getStudentAvatar()) %>'); background-size:cover;"></div>
                                <% } else { %>
                                    <div class="review-avatar <%= colorClass %>"><%= h(firstChar) %></div>
                                <% } %>
                                <div>
                                    <div class="review-name"><%= h(r.getStudentName()) %></div>
                                    <div class="review-date"><%= r.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(r.getCreatedAt()) : "" %></div>
                                </div>
                            </div>
                            <div class="review-rating">
                                <% for(int i=0; i<r.getRating(); i++){ %>⭐<% } %>
                            </div>
                        </div>
                        <div class="review-text"><%= h(r.getReviewText()) %></div>
                    </div>
                    <%     }
                       } else { %>
                    <div style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 2rem;">Chưa có đánh giá nào cho khóa học này.</div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="checkout-card">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="<%= thumbStyle %>">
                    <% if (thumbUrl == null || thumbUrl.trim().isEmpty()) { %>
                        <svg viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.55)" stroke-width="1.25" style="width:64px; height:64px; margin:auto;"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    <% } %>
                </div>
            </div>
            <div class="card-body">
                <div class="price <%= course.isFree() ? "free" : "" %>"><%= h(course.getPriceLabel()) %></div>
                
                <% if (course.isViewerEnrolled()) { %>
                    <a href="javascript:void(0)" class="btn btn-primary" style="cursor: default; pointer-events: none; opacity: 0.9;">Hãy kiểm tra email của bạn</a>
                    <p style="text-align:center; font-size:0.85rem; color:#666; margin-top:0.5rem;">Bạn đã đăng ký khóa học này</p>
                <% } else if (course.isFree()) { %>
                    <% if (profileHasStudent) { %>
                        <div style="display:flex; flex-direction:column; gap:0.5rem;">
                            <form action="${pageContext.request.contextPath}/enroll" method="POST" style="margin:0;">
                                <input type="hidden" name="courseId" value="<%= h(course.getId()) %>">
                                <button type="submit" class="btn btn-primary" style="width:100%;">Đăng ký học ngay</button>
                            </form>
                            <button type="button" class="btn <%= isInCart ? "btn-added" : "btn-secondary" %>" id="btnAddToCartFree" onclick="addToCart('<%= h(course.getId()) %>')" style="width:100%;">
                                <%= isInCart ? "Đã có trong giỏ hàng" : "Thêm vào giỏ hàng" %>
                            </button>
                        </div>
                    <% } else if (user != null) { %>
                        <a href="javascript:void(0)" class="btn btn-primary" style="cursor: default; pointer-events: none; opacity: 0.8;">Dành cho tài khoản Học viên</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Đăng nhập để đăng ký</a>
                    <% } %>
                <% } else { %>
                    <% if (profileHasStudent) { %>
                        <button type="button" class="btn <%= isInCart ? "btn-added" : "btn-primary" %>" id="btnAddToCart" onclick="addToCart('<%= h(course.getId()) %>')">
                            <%= isInCart ? "Đã có trong giỏ hàng" : "Thêm vào giỏ hàng" %>
                        </button>
                        <% if (!isInCart) { %>
                            <button type="button" class="btn btn-secondary" onclick="buyNow('<%= h(course.getId()) %>')">Mua ngay</button>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/cart" class="btn btn-secondary">Đến giỏ hàng</a>
                        <% } %>
                    <% } else if (user != null) { %>
                        <a href="javascript:void(0)" class="btn btn-primary" style="cursor: default; pointer-events: none; opacity: 0.8;">Dành cho tài khoản Học viên</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Đăng nhập để mua</a>
                    <% } %>
                <% } %>
                
                <ul class="features-list" style="margin-top: 2rem;">
                    <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg> Quyền truy cập trọn đời</li>
                    <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg> Hỗ trợ từ giáo viên</li>
                    <li><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg> Cập nhật tài nguyên miễn phí</li>
                </ul>
            </div>
        </div>
    </div>

    <!-- 4. Khóa học liên quan -->
    <div style="max-width: 1600px; width: 96%; margin: 0 auto 50px; padding: 0 1.5rem;">
        <div class="related-courses-section">
            <h2 class="section-title">Các Khóa Học Liên Quan</h2>
            <div style="display: flex; gap: 1.25rem; flex-wrap: wrap; justify-content: center; padding: 1rem 0;">
                    <%
                        if (relatedCourses != null && !relatedCourses.isEmpty()) {
                            for (Course rc : relatedCourses) {
                                String rcThumbUrl = rc.getThumbnailUrl();
                                String rcThumbStyle = (rcThumbUrl != null && !rcThumbUrl.trim().isEmpty())
                                        ? "background-image:url('" + h(rcThumbUrl) + "'); background-size:cover; background-position:center;"
                                        : "background:" + h(rc.getThumbnailGradientOrDefault()) + "; display:flex; align-items:center; justify-content:center;";
                    %>
                    <article class="weekly-course-card">
                        <a href="${pageContext.request.contextPath}/course-detail?id=<%= h(rc.getId()) %>" style="display:block; text-decoration:none; color:inherit; height:100%;">
                            <div class="weekly-thumb">
                                <div class="weekly-thumb-bg" style="<%= rcThumbStyle %>">
                                    <% if (rcThumbUrl == null || rcThumbUrl.trim().isEmpty()) { %>
                                        <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.58)" stroke-width="1.25"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/><path d="M8 7h8M8 11h6"/></svg>
                                    <% } %>
                                </div>
                                <span class="weekly-rating-badge" aria-label="Đánh giá 5.0 sao">
                                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                                    5.0
                                </span>
                                <% if (profileHasStudent && !rc.isViewerEnrolled()) { %>
                                <button type="button" class="weekly-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ" onclick="event.preventDefault(); event.stopPropagation(); addToCart('<%= h(rc.getId()) %>');">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                                </button>
                                <% } %>
                            </div>
                            <div class="weekly-info">
                                <h3 class="weekly-title"><%= h(rc.getTitle()) %></h3>
                                <div class="weekly-teacher-row">
                                    <div class="weekly-teacher"><%= h(rc.getTeacherName()) %></div>
                                    <span class="weekly-students" aria-label="0 học viên">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                        0
                                    </span>
                                </div>
                                <div class="weekly-footer">
                                    <span class="weekly-price <%= rc.isFree() ? "free" : "" %>"><%= h(rc.getPriceLabel()) %></span>
                                    <span class="weekly-cta">Xem chi tiết</span>
                                </div>
                            </div>
                        </a>
                    </article>
                    <%
                            }
                        } else {
                    %>
                        <div style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); padding: 2rem; font-size: 0.95rem;">Không có khóa học nào liên quan.</div>
                    <%
                        }
                    %>
                </div>
        </div>
    </div>
    
    <script>
        function addToCart(courseId) {
            const btn = document.getElementById('btnAddToCart');
            if (btn.classList.contains('btn-added')) return;
            
            const formData = new URLSearchParams();
            formData.append('action', 'add');
            formData.append('courseId', courseId);

            fetch('${pageContext.request.contextPath}/cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    btn.classList.remove('btn-primary');
                    btn.classList.add('btn-added');
                    btn.textContent = 'Đã có trong giỏ hàng';
                    
                    const cartBadge = document.querySelector('.header-cart-badge');
                    if (cartBadge && data.count !== undefined) {
                        cartBadge.textContent = data.count;
                        cartBadge.style.display = 'flex';
                    }
                    
                    const secondaryBtn = document.querySelector('.checkout-card .btn-secondary');
                    if (secondaryBtn) {
                        const a = document.createElement('a');
                        a.href = '${pageContext.request.contextPath}/cart';
                        a.className = 'btn btn-secondary';
                        a.textContent = 'Đến giỏ hàng';
                        secondaryBtn.parentNode.replaceChild(a, secondaryBtn);
                    }
                } else {
                    alert(data.message || 'Đã có lỗi xảy ra.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Không thể kết nối đến máy chủ.');
            });
        }
        
        function buyNow(courseId) {
            const formData = new URLSearchParams();
            formData.append('action', 'add');
            formData.append('courseId', courseId);

            fetch('${pageContext.request.contextPath}/cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(response => response.json())
            .then(data => {
                if (data.success || data.message === 'Khóa học đã có trong giỏ hàng.') {
                    window.location.href = '${pageContext.request.contextPath}/cart';
                } else {
                    alert(data.message || 'Đã có lỗi xảy ra.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Không thể kết nối đến máy chủ.');
            });
        }
        


        // Interactive Review Stars
        const starContainer = document.getElementById('starRatingContainer');
        const ratingInput = document.getElementById('reviewRatingInput');
        if (starContainer && ratingInput) {
            const stars = starContainer.querySelectorAll('svg');
            let currentRating = parseInt(ratingInput.value) || 5;

            function renderStars(rating) {
                stars.forEach((s, idx) => {
                    if (idx < rating) {
                        s.setAttribute('fill', 'currentColor');
                    } else {
                        s.setAttribute('fill', 'none');
                    }
                });
            }

            stars.forEach((star, index) => {
                const val = index + 1;
                star.addEventListener('mouseenter', () => renderStars(val));
                star.addEventListener('mouseleave', () => renderStars(currentRating));
                star.addEventListener('click', () => {
                    currentRating = val;
                    ratingInput.value = val;
                    renderStars(currentRating);
                });
            });
        }

        function showToast(message, type = 'success') {
            const oldToast = document.getElementById('custom-toast-container-js');
            if (oldToast) oldToast.remove();
            
            const toast = document.createElement('div');
            toast.id = 'custom-toast-container-js';
            toast.style.cssText = 'position: fixed; bottom: 24px; right: 24px; z-index: 9999; animation: slideInUp 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;';
            
            const bg = type === 'success' ? '#059669' : '#dc2626';
            const icon = type === 'success' 
                ? '<polyline points="20 6 9 17 4 12"/>' 
                : '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>';
                
            toast.innerHTML = 
                '<div style="display: flex; align-items: center; gap: 12px; background: ' + bg + '; color: white; padding: 16px 24px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.15); font-weight: 600; font-family: \'Be Vietnam Pro\', sans-serif;">' +
                    '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">' + icon + '</svg>' +
                    '<span>' + message + '</span>' +
                '</div>';
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(20px)';
                setTimeout(() => toast.remove(), 400);
            }, 3500);
            
            // Add keyframes if not exists
            if (!document.getElementById('slideInUpFrames')) {
                const style = document.createElement('style');
                style.id = 'slideInUpFrames';
                style.innerHTML = `@keyframes slideInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }`;
                document.head.appendChild(style);
            }
        }

        async function addToCart(courseId) {
            try {
                const formData = new URLSearchParams();
                formData.append('action', 'add');
                formData.append('courseId', courseId);
                
                const response = await fetch('${pageContext.request.contextPath}/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                });
                
                const data = await response.json();
                if (data.success) {
                    showToast(data.message || 'Đã thêm khóa học vào giỏ hàng!');
                    // Update header cart count
                    if (window.refreshCartBadge) {
                        window.refreshCartBadge();
                    } else {
                        // Fallback
                        const badge = document.getElementById('cart-item-count');
                        if (badge) {
                            badge.textContent = data.count > 9 ? '9+' : String(data.count);
                            badge.style.display = data.count > 0 ? 'flex' : 'none';
                        }
                    }
                    
                    // Update buttons
                    const addBtns = document.querySelectorAll('#btnAddToCart, #btnAddToCartFree');
                    addBtns.forEach(btn => {
                        btn.className = 'btn btn-added';
                        btn.innerText = 'Đã có trong giỏ hàng';
                        // Keep onclick in case they click again it will say 'Already in cart' from server
                    });
                    
                    // Hide buyNow button
                    const buyNowBtn = document.querySelector('.btn-secondary[onclick^="buyNow"]');
                    if (buyNowBtn) {
                        buyNowBtn.outerHTML = `<a href="${pageContext.request.contextPath}/cart" class="btn btn-secondary">Đến giỏ hàng</a>`;
                    }

                } else {
                    showToast(data.message || 'Có lỗi xảy ra', 'error');
                }
            } catch (err) {
                console.error(err);
                showToast('Lỗi kết nối. Vui lòng thử lại.', 'error');
            }
        }

        async function buyNow(courseId) {
            try {
                const formData = new URLSearchParams();
                formData.append('action', 'add');
                formData.append('courseId', courseId);
                
                const response = await fetch('${pageContext.request.contextPath}/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                });
                
                const data = await response.json();
                if (data.success || data.message === 'Khóa học đã có trong giỏ hàng') {
                    window.location.href = '${pageContext.request.contextPath}/cart';
                } else {
                    showToast(data.message || 'Có lỗi xảy ra', 'error');
                }
            } catch (err) {
                console.error(err);
                showToast('Lỗi kết nối. Vui lòng thử lại.', 'error');
            }
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
    
    <% if (successMsg != null) { %>
    <div id="custom-toast-container" style="position: fixed; bottom: 24px; right: 24px; z-index: 9999; animation: slideInUp 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;">
        <div style="display: flex; align-items: center; gap: 12px; background: #059669; color: white; padding: 16px 24px; border-radius: 12px; box-shadow: 0 10px 25px rgba(5,150,105,0.35); font-weight: 600; font-family: 'Be Vietnam Pro', sans-serif;">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
            <span><%= h(successMsg) %></span>
        </div>
    </div>
    <script>
        setTimeout(() => {
            const toast = document.getElementById('custom-toast-container');
            if (toast) {
                toast.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(20px)';
                setTimeout(() => toast.remove(), 400);
            }
        }, 3500);
    </script>
    <style>
        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
    <% } %>
</body>
</html>

