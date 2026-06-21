<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Course"%>
<%@page import="java.util.List"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String initialsFrom(String value) {
        if (value == null || value.trim().isEmpty()) return "HZ";
        StringBuilder initials = new StringBuilder();
        for (String part : value.trim().split("\\s+")) {
            if (!part.isEmpty()) {
                initials.append(part.substring(0, 1).toUpperCase());
            }
            if (initials.length() >= 2) break;
        }
        return initials.length() > 0 ? initials.toString() : "HZ";
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    boolean hasDynamicCourses = courses != null && !courses.isEmpty();
    boolean showSampleCourses = false;
    String currentSearch = (String) request.getAttribute("currentSearch");
    if (currentSearch == null) currentSearch = "";
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
    <meta name="description" content="Khám phá hàng trăm khóa học chất lượng cao từ giảng viên uy tín trên HIPZI. Học mọi lúc, mọi nơi, theo lộ trình cá nhân hóa.">
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=9">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&display=block">

    <style>
        /* =============================================
           COURSES PAGE — HIPZI DESIGN SYSTEM
           ============================================= */
        :root {
            --c-bg:        #f0fdf9;
            --c-surface:   #ffffff;
            --c-primary:   #0d9488;
            --c-primary-l: #14b8a6;
            --c-primary-d: #0f766e;
            --c-accent:    #7c3aed;
            --c-accent-l:  #ede9fe;
            --c-yellow:    #f59e0b;
            --c-yellow-l:  #fef3c7;
            --c-navy:      #0f172a;
            --c-text:      #1e293b;
            --c-muted:     #64748b;
            --c-border:    #e2e8f0;
            --c-card-sh:   0 4px 24px rgba(13,148,136,.08), 0 1px 4px rgba(0,0,0,.04);
            --c-card-sh-h: 0 16px 40px rgba(13,148,136,.15), 0 4px 12px rgba(0,0,0,.07);
            --font:        "Be Vietnam Pro", "Inter", Arial, sans-serif;
            --r-card:      18px;
            --r-pill:      999px;
            --transition:  .25s cubic-bezier(.4,0,.2,1);
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: var(--font);
            color: var(--c-text);
            -webkit-font-smoothing: antialiased;
        }

        /* Override landing.css body blobs so they don't interfere */
        body::before, body::after { display: none !important; }

        /* Ensure Navbar is transparent when at the top */
        .navbar:not(.scrolled) {
            background: transparent !important;
            border-bottom-color: transparent !important;
            box-shadow: none !important;
        }

        /* ── HERO ──────────────────────────────────── */
        .courses-hero {
            background: transparent;
            min-height: calc(100vh - 200px);
            padding: 2rem 1.5rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .hero-kicker {
            display: inline-flex;
            align-items: center;
            gap: .45rem;
            background: rgba(13,148,136,.12);
            border: 1px solid rgba(13,148,136,.25);
            color: var(--c-primary-d);
            font-size: .82rem;
            font-weight: 700;
            letter-spacing: .06em;
            text-transform: uppercase;
            padding: .35rem .9rem;
            border-radius: var(--r-pill);
            margin-bottom: 1.4rem;
            animation: fadeSlideDown .6s ease both;
        }
        .hero-kicker svg { flex-shrink: 0; }
        .hero-title {
            font-size: clamp(2rem, 5vw, 3.2rem);
            font-weight: 800;
            color: var(--c-navy);
            line-height: 1.2;
            max-width: 760px;
            margin-bottom: 1.1rem;
            animation: fadeSlideDown .65s .08s ease both;
        }
        .hero-title span {
            position: relative;
            display: inline-block;
            white-space: nowrap;
            background: linear-gradient(135deg, #058c63 0%, #0aaf7e 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .hero-title span::after {
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
        .hero-subtitle {
            color: #334155;
            font-weight: 500;
            font-size: 1.15rem;
            max-width: 580px;
            margin-bottom: 2.5rem;
            line-height: 1.7;
            animation: fadeSlideDown .7s .14s ease both;
        }

        /* ── SEARCH BAR ───────────────────────────── */
        .search-wrap {
            width: 100%;
            max-width: 680px;
            position: relative;
            animation: fadeSlideDown .75s .2s ease both;
        }
        .search-bar {
            display: flex;
            align-items: center;
            background: var(--c-surface);
            border: 2px solid var(--c-border);
            border-radius: var(--r-pill);
            padding: .5rem .5rem .5rem 1.4rem;
            box-shadow: 0 8px 32px rgba(0,0,0,.08);
            transition: border-color var(--transition), box-shadow var(--transition);
            gap: .75rem;
        }
        .search-bar:focus-within {
            border-color: var(--c-primary-l);
            box-shadow: 0 8px 32px rgba(13,148,136,.15), 0 0 0 4px rgba(13,148,136,.08);
        }
        .search-icon {
            color: var(--c-muted);
            flex-shrink: 0;
            transition: color var(--transition);
        }
        .search-bar:focus-within .search-icon { color: var(--c-primary); }
        .search-input {
            flex: 1;
            border: none;
            outline: none;
            font-family: var(--font);
            font-size: 1rem;
            color: var(--c-text);
            background: transparent;
        }
        .search-input::placeholder { color: #94a3b8; }
        .search-btn {
            background: linear-gradient(135deg, #058c63 0%, #0aaf7e 100%);
            color: #fff;
            border: none;
            padding: .7rem 1.6rem;
            border-radius: var(--r-pill);
            font-family: var(--font);
            font-size: .95rem;
            font-weight: 700;
            cursor: pointer;
            white-space: nowrap;
            transition: opacity var(--transition), transform var(--transition), box-shadow var(--transition);
            box-shadow: 0 4px 14px rgba(5,140,99,.35);
        }
        .search-btn:hover {
            opacity: .9;
            transform: translateY(-1px);
            box-shadow: 0 8px 20px rgba(5,140,99,.45);
        }
        .search-btn:active { transform: translateY(0); }

        /* ── MAIN LAYOUT ──────────────────────────── */
        .courses-body {
            max-width: 1280px;
            margin: 0 auto;
            padding: 3rem 1.5rem 5rem;
        }

        /* ── FILTER ROW ───────────────────────────── */
        .filter-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 2rem;
        }
        .filter-label {
            font-size: .9rem;
            font-weight: 600;
            color: var(--c-muted);
            white-space: nowrap;
        }
        .filter-chips {
            display: flex;
            gap: .5rem;
            flex-wrap: wrap;
        }
        .chip {
            padding: .42rem 1.05rem;
            border-radius: var(--r-pill);
            font-family: var(--font);
            font-size: .88rem;
            font-weight: 600;
            cursor: pointer;
            border: 1.5px solid var(--c-border);
            background: var(--c-surface);
            color: var(--c-muted);
            transition: all var(--transition);
            white-space: nowrap;
            user-select: none;
        }
        .chip:hover {
            border-color: var(--c-primary-l);
            color: var(--c-primary);
            background: rgba(13,148,136,.06);
        }
        .chip.active {
            background: var(--c-primary);
            border-color: var(--c-primary);
            color: #fff;
            box-shadow: 0 4px 12px rgba(13,148,136,.3);
        }

        /* Sort dropdown */
        .sort-wrap {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: .5rem;
        }
        .sort-label { font-size: .88rem; color: var(--c-muted); font-weight: 500; }
        .sort-select {
            font-family: var(--font);
            font-size: .88rem;
            font-weight: 600;
            color: var(--c-text);
            background: var(--c-surface);
            border: 1.5px solid var(--c-border);
            border-radius: 8px;
            padding: .38rem .75rem;
            outline: none;
            cursor: pointer;
            transition: border-color var(--transition);
        }
        .sort-select:focus { border-color: var(--c-primary-l); }

        /* Result count */
        .result-count {
            font-size: .9rem;
            color: var(--c-muted);
            margin-bottom: 1.5rem;
        }
        .result-count strong { color: var(--c-text); }

        /* ── COURSES GRID ─────────────────────────── */
        .courses-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.75rem;
        }

        /* ── COURSE CARD ──────────────────────────── */
        .course-card {
            background: var(--c-surface);
            border-radius: var(--r-card);
            border: 1.5px solid var(--c-border);
            box-shadow: var(--c-card-sh);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            cursor: pointer;
            transition: transform var(--transition), box-shadow var(--transition), border-color var(--transition);
            opacity: 0;
            transform: translateY(28px) scale(.97);
            text-decoration: none;
            color: inherit;
        }
        .course-card.visible {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
        .course-card:hover {
            transform: translateY(-6px) scale(1.01);
            box-shadow: var(--c-card-sh-h);
            border-color: var(--c-primary-l);
        }

        /* Thumbnail */
        .card-thumb {
            position: relative;
            height: 188px;
            overflow: hidden;
        }
        .card-thumb-bg {
            width: 100%;
            height: 100%;
            transition: transform .5s ease;
        }
        .course-card:hover .card-thumb-bg { transform: scale(1.06); }

        /* Badges on thumb */
        .thumb-badges {
            position: absolute;
            top: .85rem;
            left: .85rem;
            display: flex;
            gap: .4rem;
        }
        .badge {
            display: inline-flex;
            align-items: center;
            gap: .28rem;
            padding: .25rem .65rem;
            border-radius: var(--r-pill);
            font-size: .75rem;
            font-weight: 700;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }
        .badge-free {
            background: rgba(22,163,74,.9);
            color: #fff;
        }
        .badge-paid {
            background: rgba(15,23,42,.82);
            color: #fff;
        }
        .badge-hot {
            background: rgba(239,68,68,.9);
            color: #fff;
        }
        .badge-new {
            background: rgba(124,58,237,.9);
            color: #fff;
        }

        /* Wishlist btn */
        .wishlist-btn {
            position: absolute;
            top: .85rem;
            right: .85rem;
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: rgba(255,255,255,.88);
            backdrop-filter: blur(6px);
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--c-muted);
            transition: all var(--transition);
            box-shadow: 0 2px 8px rgba(0,0,0,.1);
        }
        .wishlist-btn:hover { background: #fff; color: #ef4444; transform: scale(1.1); }
        .wishlist-btn.active { color: #ef4444; }

        /* Card Body */
        .card-body {
            padding: 1.25rem 1.25rem 1rem;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .card-subject {
            display: inline-flex;
            align-items: center;
            gap: .3rem;
            font-size: .78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: var(--c-primary);
            margin-bottom: .6rem;
        }
        .card-subject-dot {
            width: 6px; height: 6px;
            border-radius: 50%;
            background: currentColor;
            display: inline-block;
        }

        .card-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--c-navy);
            line-height: 1.45;
            margin-bottom: .6rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .card-author {
            display: flex;
            align-items: center;
            gap: .5rem;
            margin-bottom: 1rem;
        }
        .author-avatar {
            width: 26px;
            height: 26px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: .7rem;
            font-weight: 800;
            color: #fff;
            flex-shrink: 0;
        }
        .author-name {
            font-size: .86rem;
            color: var(--c-muted);
            font-weight: 500;
        }

        /* Meta row: ratings + students */
        .card-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
            font-size: .82rem;
            color: var(--c-muted);
        }
        .meta-rating {
            display: flex;
            align-items: center;
            gap: .28rem;
        }
        .meta-stars { color: #f59e0b; font-size: .85rem; }
        .meta-rating-val { font-weight: 700; color: var(--c-text); }
        .meta-dot { width: 3px; height: 3px; border-radius: 50%; background: var(--c-border); }

        /* Progress bar (for enrolled) */
        .card-progress {
            margin-bottom: .9rem;
        }
        .progress-label {
            display: flex;
            justify-content: space-between;
            font-size: .78rem;
            color: var(--c-muted);
            margin-bottom: .3rem;
        }
        .progress-label strong { color: var(--c-primary-d); }
        .progress-track {
            height: 5px;
            background: #e2e8f0;
            border-radius: var(--r-pill);
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--c-primary-l), var(--c-primary));
            border-radius: var(--r-pill);
            transition: width 1s ease;
            width: 0;
        }
        .course-card.visible .progress-fill {
            width: var(--progress, 0%);
        }

        /* Card Footer */
        .card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: .9rem;
            border-top: 1px solid var(--c-border);
            margin-top: auto;
        }
        .card-price-free {
            font-size: 1.05rem;
            font-weight: 800;
            color: #16a34a;
        }
        .card-price-paid {
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--c-navy);
        }
        .card-price-paid .price-original {
            font-size: .82rem;
            font-weight: 400;
            color: #94a3b8;
            text-decoration: line-through;
            margin-left: .35rem;
        }
        .card-cta {
            padding: .45rem 1.1rem;
            border-radius: var(--r-pill);
            font-family: var(--font);
            font-size: .85rem;
            font-weight: 700;
            text-decoration: none;
            transition: all var(--transition);
            border: 1.5px solid var(--c-primary);
            color: var(--c-primary);
            background: transparent;
        }
        .card-cta:hover {
            background: var(--c-primary);
            color: #fff;
            box-shadow: 0 4px 12px rgba(13,148,136,.28);
        }
        .card-cta.enrolled {
            background: linear-gradient(135deg, var(--c-primary-l), var(--c-primary));
            color: #fff;
            border-color: transparent;
        }
        .card-cta.enrolled:hover { opacity: .88; }

        /* Lesson count chip */
        .lessons-chip {
            display: inline-flex;
            align-items: center;
            gap: .28rem;
            font-size: .8rem;
            color: var(--c-muted);
        }

        /* ── FEATURED BANNER ──────────────────────── */
        .featured-banner {
            background: linear-gradient(135deg, #0f766e 0%, #7c3aed 100%);
            border-radius: 20px;
            padding: 2.5rem 2.5rem 2.5rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 2rem;
            margin-bottom: 3rem;
            position: relative;
            overflow: hidden;
            opacity: 0;
            transform: translateY(20px);
            transition: opacity .6s ease, transform .6s ease;
        }
        .featured-banner.visible { opacity: 1; transform: none; }
        .featured-banner::before {
            content: '';
            position: absolute;
            inset: 0;
            background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.04'%3E%3Ccircle cx='30' cy='30' r='20'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
            pointer-events: none;
        }
        .banner-content { position: relative; }
        .banner-tag {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            background: rgba(255,255,255,.18);
            border: 1px solid rgba(255,255,255,.25);
            color: #fff;
            font-size: .78rem;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            padding: .28rem .8rem;
            border-radius: var(--r-pill);
            margin-bottom: .9rem;
        }
        .banner-title {
            font-size: 1.65rem;
            font-weight: 800;
            color: #fff;
            line-height: 1.25;
            margin-bottom: .65rem;
        }
        .banner-desc {
            color: rgba(255,255,255,.8);
            font-size: .95rem;
            max-width: 480px;
            line-height: 1.6;
        }
        .banner-cta {
            background: #fff;
            color: var(--c-primary-d);
            font-family: var(--font);
            font-size: .95rem;
            font-weight: 700;
            padding: .75rem 1.8rem;
            border-radius: var(--r-pill);
            text-decoration: none;
            white-space: nowrap;
            transition: all var(--transition);
            box-shadow: 0 6px 20px rgba(0,0,0,.15);
            position: relative;
            flex-shrink: 0;
        }
        .banner-cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 28px rgba(0,0,0,.2);
        }

        /* ── SECTION HEADING ─────────────────────── */
        .section-heading {
            display: flex;
            align-items: baseline;
            gap: 1rem;
            margin-bottom: 1.75rem;
        }
        .section-heading h2 {
            font-size: 1.55rem;
            font-weight: 800;
            color: var(--c-navy);
        }
        .section-heading .see-all {
            font-size: .88rem;
            font-weight: 600;
            color: var(--c-primary);
            text-decoration: none;
            margin-left: auto;
            transition: opacity var(--transition);
        }
        .section-heading .see-all:hover { opacity: .75; }

        /* ── CATEGORY PILLS SCROLL ───────────────── */
        .category-scroll {
            display: flex;
            gap: .6rem;
            overflow-x: auto;
            padding-bottom: .4rem;
            margin-bottom: 2.5rem;
            scrollbar-width: none;
        }
        .category-scroll::-webkit-scrollbar { display: none; }
        .cat-pill {
            display: inline-flex;
            align-items: center;
            gap: .5rem;
            padding: .6rem 1.2rem;
            border-radius: var(--r-pill);
            background: var(--c-surface);
            border: 1.5px solid var(--c-border);
            font-family: var(--font);
            font-size: .9rem;
            font-weight: 600;
            color: var(--c-text);
            cursor: pointer;
            white-space: nowrap;
            transition: all var(--transition);
            text-decoration: none;
        }
        .cat-pill:hover {
            border-color: var(--c-primary-l);
            color: var(--c-primary);
            background: rgba(13,148,136,.05);
            transform: translateY(-2px);
        }
        .cat-pill.active {
            background: var(--c-primary);
            border-color: var(--c-primary);
            color: #fff;
            box-shadow: 0 4px 14px rgba(13,148,136,.3);
        }
        .cat-pill-icon { font-size: 1.1rem; line-height: 1; }

        /* ── TEACHER SPOTLIGHT ───────────────────── */
        .teachers-row {
            display: flex;
            gap: 1.25rem;
            margin-bottom: 3.5rem;
            overflow-x: auto;
            padding-bottom: .5rem;
            scrollbar-width: none;
        }
        .teachers-row::-webkit-scrollbar { display: none; }
        .teacher-mini-card {
            background: var(--c-surface);
            border: 1.5px solid var(--c-border);
            border-radius: 14px;
            padding: 1.2rem 1rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            min-width: 150px;
            gap: .5rem;
            text-align: center;
            text-decoration: none;
            color: inherit;
            flex-shrink: 0;
            transition: all var(--transition);
        }
        .teacher-mini-card:hover {
            border-color: var(--c-primary-l);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(13,148,136,.12);
        }
        .teacher-avatar {
            width: 58px;
            height: 58px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            font-weight: 800;
            color: #fff;
            margin-bottom: .2rem;
        }
        .teacher-name-mini {
            font-size: .88rem;
            font-weight: 700;
            color: var(--c-navy);
            line-height: 1.3;
        }
        .teacher-subject-mini {
            font-size: .78rem;
            color: var(--c-muted);
        }
        .teacher-courses-count {
            font-size: .78rem;
            font-weight: 600;
            color: var(--c-primary);
            background: rgba(13,148,136,.1);
            padding: .18rem .6rem;
            border-radius: var(--r-pill);
        }

        /* ── EMPTY STATE ──────────────────────────── */
        .empty-state {
            text-align: center;
            padding: 5rem 1.5rem;
            display: none;
        }
        .empty-state.visible { display: block; }
        .empty-icon {
            width: 72px; height: 72px;
            background: rgba(13,148,136,.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.2rem;
        }
        .empty-state h3 { font-size: 1.2rem; font-weight: 700; margin-bottom: .5rem; color: var(--c-navy); }
        .empty-state p { color: var(--c-muted); font-size: .95rem; }

        /* ── ANIMATIONS ───────────────────────────── */
        @keyframes fadeSlideDown {
            from { opacity: 0; transform: translateY(-20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Card stagger delay */
        .course-card:nth-child(1)  { transition-delay: .02s; }
        .course-card:nth-child(2)  { transition-delay: .07s; }
        .course-card:nth-child(3)  { transition-delay: .12s; }
        .course-card:nth-child(4)  { transition-delay: .02s; }
        .course-card:nth-child(5)  { transition-delay: .07s; }
        .course-card:nth-child(6)  { transition-delay: .12s; }
        .course-card:nth-child(7)  { transition-delay: .02s; }
        .course-card:nth-child(8)  { transition-delay: .07s; }
        .course-card:nth-child(9)  { transition-delay: .12s; }

        /* All cards transition */
        .course-card {
            transition: opacity .5s ease, transform .5s ease, box-shadow var(--transition), border-color var(--transition);
        }

        /* ── RESPONSIVE ───────────────────────────── */
        @media (max-width: 768px) {
            .courses-hero { padding: 100px 1rem 60px; }
            .stats-bar { gap: 1.5rem; flex-wrap: wrap; }
            .featured-banner { flex-direction: column; padding: 1.75rem 1.25rem; }
            .sort-wrap { margin-left: 0; }
        }
        @media (max-width: 480px) {
            .courses-grid { grid-template-columns: 1fr; }
            .search-bar { padding: .4rem .4rem .4rem 1rem; }
            .search-btn { padding: .6rem 1rem; font-size: .85rem; }
        }

        /* ── LOAD MORE BUTTON ─────────────────────── */
        .load-more-wrap {
            display: flex;
            justify-content: center;
            margin-top: 3rem;
        }
        .load-more-btn {
            background: transparent;
            border: 2px solid var(--c-primary);
            color: var(--c-primary);
            font-family: var(--font);
            font-size: .95rem;
            font-weight: 700;
            padding: .75rem 2.5rem;
            border-radius: var(--r-pill);
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: .6rem;
            transition: all var(--transition);
        }
        .load-more-btn:hover {
            background: var(--c-primary);
            color: #fff;
            box-shadow: 0 6px 20px rgba(13,148,136,.3);
        }
        .spinner {
            width: 16px; height: 16px;
            border: 2px solid currentColor;
            border-top-color: transparent;
            border-radius: 50%;
            animation: spin .7s linear infinite;
            display: none;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

<!-- NAVBAR -->
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
            <li><a href="${pageContext.request.contextPath}/courses" class="active">Khóa học</a></li>
            <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
        </ul>

        <% if (user != null) { %>
            <div class="navbar-user-controls">
                <%@ include file="/WEB-INF/fragments/cart-icon.jspf" %>
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
                        <a href="<%= profileMenuHref %>">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
                            <span class="avatar-menu-copy">
                                <span class="avatar-menu-title"><%= profileMenuLabel %></span>
                                <span class="avatar-menu-subtitle">Vai trò: <%= profileRoleLabel %></span>
                            </span>
                        </a>
                        <% if (profileHasTeacher && !profileHasStaff && !profileHasAdmin) { %>
                        <a href="${pageContext.request.contextPath}/teacher-profile?tab=wallet" class="avatar-menu-wallet">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20 7H5a2 2 0 0 0 0 4h15v8H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h16v4z"/><path d="M16 14h.01"/></svg>
                            <span class="avatar-menu-copy">
                                <span class="avatar-menu-title">Ví giảng viên</span>
                                <span class="avatar-menu-subtitle">Số dư: 1.250.000đ</span>
                            </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/teacher-profile?tab=management">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                            <span class="avatar-menu-copy">
                                <span class="avatar-menu-title">Quản lý giảng dạy</span>
                                <span class="avatar-menu-subtitle">Lớp học, khóa học và tài liệu</span>
                            </span>
                        </a>
                        <% } else if (profileHasStaff && !profileHasAdmin) { %>
                        <a href="${pageContext.request.contextPath}/staff-profile?tab=teacher-approval">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/></svg>
                            <span class="avatar-menu-copy">
                                <span class="avatar-menu-title">Bảng điều phối</span>
                                <span class="avatar-menu-subtitle">Kiểm duyệt hệ thống</span>
                            </span>
                        </a>
                        <% } else if (profileHasAdmin) { %>
                        <a href="${pageContext.request.contextPath}/admin-profile">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M8 12h8"/><path d="M12 8v8"/></svg>
                            <span class="avatar-menu-copy">
                                <span class="avatar-menu-title">Quản trị hệ thống</span>
                                <span class="avatar-menu-subtitle">Người dùng, vai trò và kiểm duyệt</span>
                            </span>
                        </a>
                        <% } %>
                        <div class="avatar-menu-divider"></div>
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

<!-- HERO SECTION -->
<section class="courses-hero">

    <h1 class="hero-title">
        Nâng cao kiến thức cùng <span data-shine="giảng viên uy tín">giảng viên uy tín</span>
    </h1>
    <p class="hero-subtitle">
        Hàng trăm khóa học chất lượng cao, từ cơ bản đến nâng cao, học theo tốc độ của riêng bạn.
    </p>

    <!-- SEARCH BAR -->
    <div class="search-wrap">
        <div class="search-bar">
            <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
            <input
                type="text"
                id="courseSearch"
                class="search-input"
                placeholder="Tìm kiếm khóa học, giảng viên, chủ đề..."
                value="<%= h(currentSearch) %>"
                autocomplete="off"
            >
            <button class="search-btn" onclick="applySearch()" id="searchBtn">
                Tìm kiếm
            </button>
        </div>
    </div>
</section>

<!-- MAIN CONTENT -->
<div class="courses-body">

    <!-- FEATURED BANNER -->
    <div class="featured-banner" id="featuredBanner">
        <div class="banner-content">
            <div class="banner-tag">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M14 2c.2 4.4 2.6 6.8 7 7-4.4.2-6.8 2.6-7 7-.2-4.4-2.6-6.8-7-7 4.4-.2 6.8-2.6 7-7z"/></svg>
                Nổi bật tuần này
            </div>
            <h2 class="banner-title">Lộ trình chinh phục IELTS 7.0+<br>cùng AI luyện tập thông minh</h2>
            <p class="banner-desc">Kết hợp phương pháp học có hệ thống với sức mạnh của HIPZI AI để đạt band điểm mục tiêu trong thời gian ngắn nhất.</p>
        </div>
        <a href="${pageContext.request.contextPath}/login" class="banner-cta">
            Đăng ký miễn phí →
        </a>
    </div>

    <!-- CATEGORY PILLS -->
    <div class="section-heading">
        <h2>Danh mục khóa học</h2>
    </div>
    <div class="category-scroll" id="categoryScroll">
        <button class="cat-pill active" data-cat="all" onclick="filterByCategory(this, 'all')">
            <span class="cat-pill-icon">🎯</span> Tất cả
        </button>
        <button class="cat-pill" data-cat="math" onclick="filterByCategory(this, 'math')">
            <span class="cat-pill-icon">📐</span> Toán học
        </button>
        <button class="cat-pill" data-cat="english" onclick="filterByCategory(this, 'english')">
            <span class="cat-pill-icon">🌍</span> Tiếng Anh
        </button>
        <button class="cat-pill" data-cat="physics" onclick="filterByCategory(this, 'physics')">
            <span class="cat-pill-icon">⚛️</span> Vật lý
        </button>
        <button class="cat-pill" data-cat="chemistry" onclick="filterByCategory(this, 'chemistry')">
            <span class="cat-pill-icon">🧪</span> Hóa học
        </button>
        <button class="cat-pill" data-cat="literature" onclick="filterByCategory(this, 'literature')">
            <span class="cat-pill-icon">📖</span> Ngữ văn
        </button>
        <button class="cat-pill" data-cat="biology" onclick="filterByCategory(this, 'biology')">
            <span class="cat-pill-icon">🧬</span> Sinh học
        </button>
        <button class="cat-pill" data-cat="history" onclick="filterByCategory(this, 'history')">
            <span class="cat-pill-icon">🏛️</span> Lịch sử
        </button>
        <button class="cat-pill" data-cat="it" onclick="filterByCategory(this, 'it')">
            <span class="cat-pill-icon">💻</span> Tin học
        </button>
    </div>

    <!-- FILTER ROW -->
    <div class="filter-row">
        <span class="filter-label">Lọc theo:</span>
        <div class="filter-chips">
            <button class="chip active" data-filter="all" id="filter-all" onclick="applyFilter(this, 'all')">Tất cả</button>
            <button class="chip" data-filter="free" id="filter-free" onclick="applyFilter(this, 'free')">Miễn phí</button>
            <button class="chip" data-filter="paid" id="filter-paid" onclick="applyFilter(this, 'paid')">Có phí</button>
            <button class="chip" data-filter="enrolled" id="filter-enrolled" onclick="applyFilter(this, 'enrolled')">Đang học</button>
        </div>

        <div class="sort-wrap">
            <label class="sort-label" for="sortSelect">Sắp xếp:</label>
            <select class="sort-select" id="sortSelect" onchange="applySorting()">
                <option value="popular">Phổ biến nhất</option>
                <option value="newest">Mới nhất</option>
                <option value="rating">Đánh giá cao</option>
                <option value="price-asc">Giá tăng dần</option>
                <option value="price-desc">Giá giảm dần</option>
            </select>
        </div>
    </div>

    <!-- RESULT COUNT -->
    <p class="result-count" id="resultCount">Hiển thị <strong id="visibleCount"><%= hasDynamicCourses ? courses.size() : 0 %></strong> khóa học</p>

    <!-- COURSES GRID -->
    <div class="courses-grid" id="coursesGrid">

        <% if (hasDynamicCourses) {
            for (Course course : courses) {
                String priceValue = course.getPriceAmount() != null ? course.getPriceAmount().toPlainString() : "0";
                String ratingValue = course.getRatingAverage() != null ? course.getRatingAverage().toPlainString() : "0";
                String thumbUrl = course.getThumbnailUrl();
                String thumbStyle = (thumbUrl != null && !thumbUrl.trim().isEmpty())
                        ? "background-image:url('" + h(thumbUrl) + "'); background-size:cover; background-position:center;"
                        : "background:" + h(course.getThumbnailGradientOrDefault()) + "; display:flex; align-items:center; justify-content:center;";
                int progress = Math.max(0, Math.min(100, course.getViewerProgressPercent()));
        %>
        <a href="#" class="course-card" data-cat="<%= h(course.getSubjectCode()) %>" data-price-type="<%= h(course.getPriceType()) %>" data-price="<%= h(priceValue) %>" data-rating="<%= h(ratingValue) %>" data-popular="<%= course.getStudentsCount() %>" data-new="<%= course.isNew() ? "1" : "0" %>">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="<%= thumbStyle %>">
                    <% if (thumbUrl == null || thumbUrl.trim().isEmpty()) { %>
                        <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    <% } %>
                </div>
                <div class="thumb-badges">
                    <% if (course.isFree()) { %>
                        <span class="badge badge-free">Miễn phí</span>
                    <% } else { %>
                        <span class="badge badge-paid">Có phí</span>
                    <% } %>
                    <% if (course.getBadgeText() != null && !course.getBadgeText().trim().isEmpty()) { %>
                        <span class="badge badge-hot"><%= h(course.getBadgeText()) %></span>
                    <% } else if (course.isFeatured()) { %>
                        <span class="badge badge-hot">Hot</span>
                    <% } %>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject"><span class="card-subject-dot"></span> <%= h(course.getSubjectName()) %></div>
                <h3 class="card-title"><%= h(course.getTitle()) %></h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#0f766e"><%= h(initialsFrom(course.getTeacherName())) %></div>
                    <span class="author-name"><%= h(course.getTeacherName()) %></span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val"><%= h(course.getDisplayRating()) %></span>
                    </div>
                    <span class="meta-dot"></span>
                    <span><%= course.getStudentsCount() %> học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        <%= course.getLessonsCount() %> bài học
                    </span>
                </div>
                <% if (course.isViewerEnrolled()) { %>
                    <div class="card-progress">
                        <div class="progress-label">
                            <span>Tiến độ</span>
                            <strong><%= progress %>%</strong>
                        </div>
                        <div class="progress-track">
                            <div class="progress-fill" style="--progress:<%= progress %>%"></div>
                        </div>
                    </div>
                <% } %>
                <div class="card-footer">
                    <span class="<%= course.isFree() ? "card-price-free" : "card-price-paid" %>"><%= h(course.getPriceLabel()) %></span>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <% if (profileHasStudent && !course.isViewerEnrolled() && !course.isFree()) { %>
                            <button class="card-add-to-cart-btn" onclick="addToCart(event, this, '<%= h(course.getId()) %>')" title="Thêm vào giỏ">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                            </button>
                        <% } %>
                        <span class="card-cta <%= course.isViewerEnrolled() ? "enrolled" : "" %>"><%= course.isViewerEnrolled() ? "Tiếp tục học" : (course.isFree() ? "Học ngay" : "Xem chi tiết") %></span>
                    </div>
                </div>
            </div>
        </a>
        <%  }
           } else if (showSampleCourses) { %>

        <!-- Card 1 -->
        <a href="#" class="course-card" data-cat="english" data-price-type="free" data-price="0" data-rating="4.9" data-popular="950" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#0f766e 0%,#14b8a6 50%,#7c3aed 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M3 5h18M3 10h12M3 15h9M3 20h6"/><circle cx="19" cy="17" r="3"/><path d="M22 20l-1.5-1.5"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-free">Miễn phí</span>
                    <span class="badge badge-hot">🔥 Hot</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject"><span class="card-subject-dot"></span> Tiếng Anh</div>
                <h3 class="card-title">Master IELTS Writing Task 2 từ con số 0 đến Band 7.5</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#0f766e">TA</div>
                    <span class="author-name">Trần Anh Khoa</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val">4.9</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>950 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        32 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-free">Miễn phí</span>
                    <span class="card-cta">Học ngay</span>
                </div>
            </div>
        </a>

        <!-- Card 2 -->
        <a href="#" class="course-card" data-cat="math" data-price-type="free" data-price="0" data-rating="4.8" data-popular="820" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#3b82f6 0%,#6366f1 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-free">Miễn phí</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#3b82f6"><span class="card-subject-dot"></span> Toán học</div>
                <h3 class="card-title">Luyện thi ĐGNL ĐHQG TP.HCM — Toán tổng ôn siêu tốc</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#3b82f6">VA</div>
                    <span class="author-name">Nguyễn Văn An</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val">4.8</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>820 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        28 bài học
                    </span>
                </div>
                <div class="card-progress">
                    <div class="progress-label">
                        <span>Tiến độ</span>
                        <strong>65%</strong>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" style="--progress:65%"></div>
                    </div>
                </div>
                <div class="card-footer">
                    <span class="card-price-free">Miễn phí</span>
                    <span class="card-cta enrolled">Tiếp tục học</span>
                </div>
            </div>
        </a>

        <!-- Card 3 -->
        <a href="#" class="course-card" data-cat="physics" data-price-type="paid" data-price="150000" data-rating="4.7" data-popular="610" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#8b5cf6 0%,#a78bfa 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><circle cx="12" cy="12" r="4"/><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-paid">150.000 đ</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#8b5cf6"><span class="card-subject-dot" style="background:#8b5cf6"></span> Vật lý</div>
                <h3 class="card-title">Chinh phục Điểm 9+ Vật Lý 12 bằng Sơ đồ tư duy</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#8b5cf6">HG</div>
                    <span class="author-name">Lê Hương Giang</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val">4.7</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>610 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        45 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-paid">150.000 đ <span class="price-original">299.000 đ</span></span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </a>

        <!-- Card 4 -->
        <a href="#" class="course-card" data-cat="english" data-price-type="free" data-price="0" data-rating="4.6" data-popular="740" data-new="1">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#f59e0b 0%,#f97316 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-free">Miễn phí</span>
                    <span class="badge badge-new">✨ Mới</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#f59e0b"><span class="card-subject-dot" style="background:#f59e0b"></span> Tiếng Anh</div>
                <h3 class="card-title">Ngữ Pháp Tiếng Anh Căn Bản — Từ Mất Gốc đến Tự Tin</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#f59e0b">MD</div>
                    <span class="author-name">Phạm Minh Đức</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★☆</span>
                        <span class="meta-rating-val">4.6</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>740 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        22 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-free">Miễn phí</span>
                    <span class="card-cta">Học ngay</span>
                </div>
            </div>
        </a>

        <!-- Card 5 -->
        <a href="#" class="course-card" data-cat="chemistry" data-price-type="paid" data-price="299000" data-rating="4.9" data-popular="480" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#059669 0%,#10b981 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M9 3h6l3 7-6 2-6-2 3-7z"/><path d="M9 3v4M15 3v4"/><path d="M6 10l-2 9h16l-2-9"/><circle cx="12" cy="16" r="2"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-paid">299.000 đ</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#059669"><span class="card-subject-dot" style="background:#059669"></span> Hóa học</div>
                <h3 class="card-title">Hóa Hữu Cơ Nâng Cao — Bộ đề luyện THPTQG cực chất</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#059669">KH</div>
                    <span class="author-name">Vũ Khánh Hà</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val">4.9</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>480 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        60 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-paid">299.000 đ</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </a>

        <!-- Card 6 -->
        <a href="#" class="course-card" data-cat="it" data-price-type="free" data-price="0" data-rating="4.8" data-popular="560" data-new="1">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#1e293b 0%,#334155 50%,#0f766e 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/><path d="M7 7l3 3-3 3M13 13h4"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-free">Miễn phí</span>
                    <span class="badge badge-new">✨ Mới</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#0f766e"><span class="card-subject-dot"></span> Tin học</div>
                <h3 class="card-title">Lập trình Python từ Zero — Xây dự án thực tế trong 30 ngày</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#0f766e">BT</div>
                    <span class="author-name">Đặng Bảo Trung</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val">4.8</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>560 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        55 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-free">Miễn phí</span>
                    <span class="card-cta">Học ngay</span>
                </div>
            </div>
        </a>

        <!-- Card 7 -->
        <a href="#" class="course-card" data-cat="literature" data-price-type="paid" data-price="120000" data-rating="4.5" data-popular="320" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#e11d48 0%,#f43f5e 50%,#fb7185 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/><path d="M8 7h8M8 11h6"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-paid">120.000 đ</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#e11d48"><span class="card-subject-dot" style="background:#e11d48"></span> Ngữ văn</div>
                <h3 class="card-title">Nghị luận văn học nâng cao — Bứt phá điểm 8+ kỳ thi THPT</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#e11d48">TP</div>
                    <span class="author-name">Bùi Thu Phương</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★☆</span>
                        <span class="meta-rating-val">4.5</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>320 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        18 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-paid">120.000 đ <span class="price-original">199.000 đ</span></span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </a>

        <!-- Card 8 -->
        <a href="#" class="course-card" data-cat="biology" data-price-type="free" data-price="0" data-rating="4.7" data-popular="290" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#16a34a 0%,#22c55e 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2z"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-free">Miễn phí</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#16a34a"><span class="card-subject-dot" style="background:#16a34a"></span> Sinh học</div>
                <h3 class="card-title">Di Truyền học — Chinh phục chuyên đề khó nhất Sinh 12</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#16a34a">NQ</div>
                    <span class="author-name">Trần Ngọc Quỳnh</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★★</span>
                        <span class="meta-rating-val">4.7</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>290 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        40 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-free">Miễn phí</span>
                    <span class="card-cta">Học ngay</span>
                </div>
            </div>
        </a>

        <!-- Card 9 -->
        <a href="#" class="course-card" data-cat="history" data-price-type="paid" data-price="199000" data-rating="4.6" data-popular="210" data-new="1">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#78350f 0%,#b45309 50%,#d97706 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 3.9 2.4-7.4L2 9.4h7.6L12 2z"/></svg>
                </div>
                <div class="thumb-badges">
                    <span class="badge badge-paid">199.000 đ</span>
                    <span class="badge badge-new">✨ Mới</span>
                </div>
                <button class="wishlist-btn" onclick="toggleWishlist(event, this)" aria-label="Yêu thích">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#b45309"><span class="card-subject-dot" style="background:#b45309"></span> Lịch sử</div>
                <h3 class="card-title">Lịch Sử Việt Nam 1945–1975 — Timeline & Phân tích chuyên sâu</h3>
                <div class="card-author">
                    <div class="author-avatar" style="background:#b45309">DL</div>
                    <span class="author-name">Ngô Duy Long</span>
                </div>
                <div class="card-meta">
                    <div class="meta-rating">
                        <span class="meta-stars">★★★★☆</span>
                        <span class="meta-rating-val">4.6</span>
                    </div>
                    <span class="meta-dot"></span>
                    <span>210 học viên</span>
                    <span class="meta-dot"></span>
                    <span class="lessons-chip">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        25 bài học
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price-paid">199.000 đ</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </a>

        <% } %>
    </div><!-- /courses-grid -->

    <!-- EMPTY STATE -->
    <div class="empty-state <%= hasDynamicCourses ? "" : "visible" %>" id="emptyState">
        <div class="empty-icon">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--c-primary)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/><path d="M8 11h6M11 8v6"/></svg>
        </div>
        <h3>Không tìm thấy khóa học</h3>
        <p>Thử thay đổi từ khóa hoặc bộ lọc để tìm khóa học phù hợp.</p>
    </div>

    <!-- LOAD MORE -->
    <div class="load-more-wrap" id="loadMoreWrap" style="<%= hasDynamicCourses ? "" : "display:none;" %>">
        <button class="load-more-btn" id="loadMoreBtn" onclick="loadMore()">
            <span class="spinner" id="loadSpinner"></span>
            <span id="loadMoreText">Xem thêm khóa học</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" id="loadMoreIcon"><path d="M12 5v14M5 12l7 7 7-7"/></svg>
        </button>
    </div>

</div><!-- /courses-body -->

<%@ include file="/WEB-INF/fragments/site-footer.jspf" %>

<script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=3"></script>
<script>
// ─── DATA ────────────────────────────────────────────
const allCards = Array.from(document.querySelectorAll('.course-card'));
let activeCategory = 'all';
let activeFilter   = 'all';
let searchQuery    = '';

// ─── INTERSECTION OBSERVER — CARD REVEAL ─────────────
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(e => {
        if (e.isIntersecting) {
            e.target.classList.add('visible');
            revealObserver.unobserve(e.target);
        }
    });
}, { threshold: 0.08 });

allCards.forEach(c => revealObserver.observe(c));

// Featured banner
const bannerObs = new IntersectionObserver((entries) => {
    entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); bannerObs.unobserve(e.target); } });
}, { threshold: 0.2 });
const banner = document.getElementById('featuredBanner');
if (banner) bannerObs.observe(banner);

// ─── SEARCH ───────────────────────────────────────────
const searchInput = document.getElementById('courseSearch');
searchInput.addEventListener('input', debounce(() => {
    searchQuery = searchInput.value.trim().toLowerCase();
    applyAll();
}, 250));

function applySearch() {
    searchQuery = searchInput.value.trim().toLowerCase();
    applyAll();
}

// ─── CATEGORY FILTER ──────────────────────────────────
function filterByCategory(btn, cat) {
    document.querySelectorAll('.cat-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    activeCategory = cat;
    applyAll();
}

// ─── PRICE FILTER ─────────────────────────────────────
function applyFilter(btn, type) {
    document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
    btn.classList.add('active');
    activeFilter = type;
    applyAll();
}

// ─── SORT ─────────────────────────────────────────────
function applySorting() { applyAll(); }

// ─── APPLY ALL FILTERS ────────────────────────────────
function applyAll() {
    const sortVal = document.getElementById('sortSelect').value;
    const grid    = document.getElementById('coursesGrid');
    let   visible = 0;

    // Detach cards from DOM for reorder
    const ordered = [...allCards].sort((a, b) => {
        if (sortVal === 'rating')     return +b.dataset.rating   - +a.dataset.rating;
        if (sortVal === 'newest')     return +b.dataset.new      - +a.dataset.new;
        if (sortVal === 'popular')    return +b.dataset.popular  - +a.dataset.popular;
        if (sortVal === 'price-asc')  return +a.dataset.price    - +b.dataset.price;
        if (sortVal === 'price-desc') return +b.dataset.price    - +a.dataset.price;
        return 0;
    });

    ordered.forEach((card, i) => {
        const catMatch    = activeCategory === 'all' || card.dataset.cat === activeCategory;
        const filterMatch = activeFilter   === 'all'
            || (activeFilter === 'free'     && card.dataset.priceType === 'free')
            || (activeFilter === 'paid'     && card.dataset.priceType === 'paid')
            || (activeFilter === 'enrolled' && card.querySelector('.card-cta.enrolled'));
        const title   = card.querySelector('.card-title')?.textContent?.toLowerCase() || '';
        const author  = card.querySelector('.author-name')?.textContent?.toLowerCase() || '';
        const subject = card.querySelector('.card-subject')?.textContent?.toLowerCase() || '';
        const srchMatch = !searchQuery || title.includes(searchQuery) || author.includes(searchQuery) || subject.includes(searchQuery);

        const show = catMatch && filterMatch && srchMatch;
        card.style.display = show ? '' : 'none';
        if (show) {
            visible++;
            card.style.transitionDelay = (visible * 0.05) + 's';
            setTimeout(() => {
                if (!card.classList.contains('visible')) card.classList.add('visible');
            }, 50);
        }
        grid.appendChild(card);
    });

    document.getElementById('visibleCount').textContent = visible;
    document.getElementById('emptyState').classList.toggle('visible', visible === 0);
    document.getElementById('loadMoreWrap').style.display = visible > 0 ? '' : 'none';
}

// ─── WISHLIST TOGGLE ──────────────────────────────────
function toggleWishlist(e, btn) {
    e.preventDefault();
    e.stopPropagation();
    btn.classList.toggle('active');
    const svg  = btn.querySelector('svg');
    const isOn = btn.classList.contains('active');
    svg.setAttribute('fill', isOn ? '#ef4444' : 'none');
    btn.style.transform = 'scale(1.25)';
    setTimeout(() => btn.style.transform = '', 250);
}

// ─── LOAD MORE (mock) ─────────────────────────────────
function loadMore() {
    const btn     = document.getElementById('loadMoreBtn');
    const spinner = document.getElementById('loadSpinner');
    const text    = document.getElementById('loadMoreText');
    const icon    = document.getElementById('loadMoreIcon');
    btn.disabled  = true;
    spinner.style.display = 'block';
    text.textContent = 'Đang tải...';
    icon.style.display = 'none';
    setTimeout(() => {
        spinner.style.display = 'none';
        text.textContent = 'Đã hiển thị tất cả khóa học';
        icon.style.display = 'none';
        btn.disabled = true;
        btn.style.opacity = '.5';
        btn.style.cursor = 'default';
    }, 1200);
}

// ─── UTILITY ──────────────────────────────────────────
function debounce(fn, ms) {
    let t;
    return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
}
</script>

</body>
</html>
