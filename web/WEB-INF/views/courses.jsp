<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Course"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
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
    List<Course> featuredCourses = (List<Course>) request.getAttribute("featuredCourses");
    List<Course> subjects = (List<Course>) request.getAttribute("subjects");
    Set<String> cartCourseIds = (Set<String>) request.getAttribute("cartCourseIds");
    if (cartCourseIds == null) cartCourseIds = new HashSet<>();

    boolean hasDynamicCourses = courses != null && !courses.isEmpty();
    boolean hasFeaturedCourses = featuredCourses != null && !featuredCourses.isEmpty();
    boolean showSampleCourses = false;
    boolean showFeaturedSamples = !hasFeaturedCourses;
    int initialCourseCount = hasDynamicCourses ? courses.size() : 0;
    String currentSearch = (String) request.getAttribute("currentSearch");
    if (currentSearch == null) currentSearch = "";
    
    String currentSubject = (String) request.getAttribute("currentSubject");
    if (currentSubject == null) currentSubject = "all";
    
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
            min-height: 28vh;
            padding: 3.25rem 1.5rem .5rem;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
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
            max-width: 760px;
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
            width: min(1720px, calc(100vw - 3rem));
            max-width: none;
            margin: 0 auto;
            padding: 0 0 5rem;
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
            background: rgba(255,255,255,.92);
            border: 1.5px solid rgba(226,232,240,.95);
            border-radius: 18px;
            box-shadow: var(--c-card-sh);
            display: flex;
            flex-direction: column;
            max-width: 420px;
            padding: .9rem;
            cursor: default;
            transition: box-shadow var(--transition), transform var(--transition);
            text-decoration: none;
            color: inherit;
        }
        .course-card:hover {
            box-shadow: var(--c-card-sh);
        }

        /* Thumbnail */
        .card-thumb {
            width: 100%;
            aspect-ratio: 1.45 / 1;
            border-radius: 14px;
            overflow: hidden;
            position: relative;
            margin-bottom: 1rem;
        }
        .card-thumb::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(115deg, transparent 0%, transparent 42%, rgba(255,255,255,.58) 50%, transparent 58%, transparent 100%);
            transform: translateX(-130%);
            pointer-events: none;
            opacity: 0;
            z-index: 1;
        }
        .course-card:hover .card-thumb::after {
            animation: weeklyCoverShine .8s ease-out 1;
        }
        .card-thumb-bg {
            width: 100%;
            height: 100%;
            transition: transform .55s cubic-bezier(.16,1,.3,1);
        }
        .course-card:hover .card-thumb-bg { transform: scale(1.055); }
        .card-rating-badge {
            position: absolute;
            top: .65rem;
            left: .65rem;
            display: inline-flex;
            align-items: center;
            gap: .25rem;
            padding: .24rem .62rem;
            border-radius: var(--r-pill);
            background: rgba(15,23,42,.78);
            color: #fff;
            font-size: .72rem;
            font-weight: 800;
            backdrop-filter: blur(8px);
            z-index: 2;
        }
        .card-rating-badge svg {
            width: 12px;
            height: 12px;
            fill: #f59e0b;
            stroke: #f59e0b;
        }
        
        /* Card Body */
        .card-body {
            min-width: 0;
            display: flex;
            flex-direction: column;
            flex: 1;
            padding: 0 .1rem .1rem;
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
            color: var(--c-navy);
            font-size: 1.05rem;
            font-weight: 800;
            line-height: 1.38;
            margin-bottom: .65rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .card-teacher-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            margin-bottom: 1rem;
        }
        .card-teacher {
            min-width: 0;
            color: var(--c-muted);
            font-size: .84rem;
            font-weight: 700;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .card-students {
            display: flex;
            align-items: center;
            gap: .28rem;
            color: var(--c-muted);
            font-size: .8rem;
            font-weight: 700;
            white-space: nowrap;
        }
        .card-students svg {
            width: 14px;
            height: 14px;
            stroke-width: 2.2;
        }


        .card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            margin-top: auto;
            padding-top: .35rem;
        }
        .card-price {
            color: var(--c-navy);
            font-size: .98rem;
            font-weight: 800;
            white-space: nowrap;
        }
        .card-price.free { color: #16a34a; }

        .card-cart-btn {
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
            color: var(--c-navy);
            box-shadow: 0 8px 18px rgba(15,23,42,.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            transition: transform var(--transition), background var(--transition), color var(--transition), box-shadow var(--transition);
            z-index: 2;
            cursor: pointer;
        }
        .course-card:hover .card-cart-btn {
            color: var(--c-primary-d);
            background: rgba(255,255,255,.96);
            box-shadow: 0 10px 22px rgba(15,23,42,.16);
            transform: translateY(-1px);
        }
        .card-cart-btn svg {
            width: 17px;
            height: 17px;
            stroke-width: 2.2;
        }
        .card-cart-btn.added {
            color: #16a34a;
            background: rgba(236,253,245,.96);
        }

        .card-cta {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 36px;
            padding: .48rem .9rem;
            border-radius: var(--r-pill);
            background: linear-gradient(135deg, #0d9488, #10b981);
            color: #fff;
            font-size: .82rem;
            font-weight: 800;
            white-space: nowrap;
            border: 0;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(13,148,136,.18);
            transition: background var(--transition), box-shadow var(--transition), transform var(--transition);
        }
        .card-cta:hover {
            box-shadow: 0 10px 22px rgba(13,148,136,.28);
            transform: translateY(-1px);
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

        /* ── WEEKLY FEATURED COURSES ─────────────── */
        .weekly-featured {
            position: relative;
            margin-bottom: 2.75rem;
        }
        .weekly-featured-callout {
            position: absolute;
            top: calc(-7.6rem + 20px);
            left: max(.25rem, calc(clamp(.75rem, 2vw, 2.25rem) + 5px));
            width: 300px;
            height: 120px;
            pointer-events: none;
            z-index: 4;
            filter: drop-shadow(0 12px 18px rgba(15,23,42,.12));
            animation: featuredCalloutFloat 4.8s ease-in-out infinite;
        }
        .weekly-featured-stats {
            position: absolute;
            top: calc(-8.7rem + 18px);
            right: calc(clamp(2rem, 7vw, 8rem) - 30px);
            width: 250px;
            min-height: 96px;
            pointer-events: none;
            z-index: 4;
            animation: featuredStatsFloat 5.4s ease-in-out infinite;
        }
        .weekly-featured-stats::after {
            content: '';
            position: absolute;
            border-radius: 999px;
            pointer-events: none;
        }
        .weekly-featured-stats::after {
            width: 7px;
            height: 7px;
            right: 2.6rem;
            top: 0rem;
            background: #f59e0b;
            box-shadow:
                0rem 3.4rem 0 rgba(13,148,136,.55),
                -7.4rem 5.8rem 0 rgba(124,58,237,.42);
            animation: featuredStatsDots 3.8s ease-in-out infinite;
        }
        .weekly-stat-card {
            position: absolute;
            display: flex;
            align-items: center;
            gap: .7rem;
            padding: .62rem .78rem;
            border-radius: 16px;
            background: rgba(255,255,255,.72);
            border: 1px solid rgba(255,255,255,.85);
            box-shadow: 0 16px 36px rgba(15,23,42,.08), inset 0 1px 0 rgba(255,255,255,.8);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
        }
        .weekly-stat-card:nth-child(1) {
            top: .2rem;
            right: 2.6rem;
            transform: rotate(2deg);
        }
        .weekly-stat-card:nth-child(2) {
            top: 3.35rem;
            right: .2rem;
            transform: rotate(-3deg);
        }
        .weekly-stat-icon {
            width: 30px;
            height: 30px;
            flex: 0 0 30px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            color: #0f766e;
            background: rgba(13,148,136,.12);
            box-shadow: inset 0 0 0 1px rgba(13,148,136,.12);
        }
        .weekly-stat-icon svg {
            width: 16px;
            height: 16px;
            stroke-width: 2.2;
        }
        .weekly-stat-copy {
            display: grid;
            gap: .05rem;
            white-space: nowrap;
        }
        .weekly-stat-value {
            color: var(--c-navy);
            font-size: .92rem;
            font-weight: 900;
            line-height: 1.1;
        }
        .weekly-stat-label {
            color: var(--c-muted);
            font-size: .68rem;
            font-weight: 700;
            line-height: 1.2;
        }
        .featured-callout-text {
            position: absolute;
            top: .25rem;
            left: .2rem;
            color: #0f172a;
            font-size: 1.38rem;
            font-weight: 900;
            letter-spacing: .01em;
            text-shadow:
                0 2px 0 rgba(255,255,255,.95),
                0 8px 18px rgba(13,148,136,.18);
            transform: rotate(-7deg);
            animation: featuredTextWiggle 3.6s ease-in-out infinite;
        }
        .featured-callout-text span {
            display: inline-block;
            color: #0d9488;
            transform: translateY(.18rem) rotate(4deg);
        }
        .featured-callout-arrow {
            position: absolute;
            inset: 2.55rem 0 0 4.1rem;
            width: 90px;
            height: 41px;
            overflow: visible;
            transform: rotate(10deg);
            transform-origin: 18% 24%;
        }
        .featured-callout-arrow .arrow-main,
        .featured-callout-arrow .arrow-shadow {
            fill: none;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        .featured-callout-arrow .arrow-shadow {
            stroke: rgba(15,23,42,.12);
            stroke-width: 6;
            transform: translate(2px, 4px);
        }
        .featured-callout-arrow .arrow-main {
            stroke: #0f172a;
            stroke-width: 4.5;
            stroke-dasharray: 430;
            stroke-dashoffset: 430;
            animation: featuredArrowDraw 1.2s .25s cubic-bezier(.16,1,.3,1) forwards;
        }
        .featured-callout-arrow .arrow-highlight {
            fill: none;
            stroke: rgba(13,148,136,.62);
            stroke-width: 2.2;
            stroke-linecap: round;
            stroke-dasharray: 7 12;
            animation: featuredArrowDashes 2.8s linear infinite;
        }
        @keyframes featuredArrowDraw {
            to { stroke-dashoffset: 0; }
        }
        @keyframes featuredArrowDashes {
            to { stroke-dashoffset: -42; }
        }
        @keyframes featuredCalloutFloat {
            0%, 100% { transform: translateY(0) rotate(-1deg); }
            50% { transform: translateY(-8px) rotate(1deg); }
        }
        @keyframes featuredTextWiggle {
            0%, 100% { transform: rotate(-7deg) translateY(0); }
            50% { transform: rotate(-4deg) translateY(-3px); }
        }
        @keyframes featuredStatsFloat {
            0%, 100% { transform: translateY(0) rotate(.5deg); }
            50% { transform: translateY(-7px) rotate(-.8deg); }
        }
        @keyframes featuredStatsDots {
            0%, 100% { opacity: .65; transform: translateY(0) scale(1); }
            50% { opacity: 1; transform: translateY(-5px) scale(1.08); }
        }
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
            animation: scrollMarquee 40s linear infinite;
        }
        .weekly-featured-grid:hover {
            animation-play-state: paused;
        }
        @keyframes scrollMarquee {
            0% { transform: translateX(0); }
            100% { transform: translateX(calc(-50% - 0.625rem)); }
        }
        .weekly-course-card {
            display: flex;
            flex-direction: column;
            width: 320px;
            max-width: 420px;
            min-height: 100%;
            padding: .9rem;
            background: rgba(255,255,255,.92);
            border: 1.5px solid rgba(226,232,240,.95);
            border-radius: 18px;
            box-shadow: var(--c-card-sh);
            color: inherit;
            text-decoration: none;
            transition: box-shadow var(--transition);
            cursor: default;
        }
        .weekly-course-card:hover {
            box-shadow: var(--c-card-sh);
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
            border-radius: var(--r-pill);
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
            color: var(--c-navy);
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
            color: var(--c-muted);
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
            color: var(--c-muted);
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
            color: var(--c-navy);
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
            color: var(--c-navy);
            box-shadow: 0 8px 18px rgba(15,23,42,.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            transition: transform var(--transition), background var(--transition), color var(--transition), box-shadow var(--transition);
            z-index: 2;
            cursor: pointer;
        }
        .weekly-course-card:hover .weekly-cart-btn {
            color: var(--c-primary-d);
            background: rgba(255,255,255,.96);
            box-shadow: 0 10px 22px rgba(15,23,42,.16);
            transform: translateY(-1px);
        }
        .weekly-cart-btn svg {
            width: 17px;
            height: 17px;
            stroke-width: 2.2;
        }
        .weekly-cart-btn.added {
            color: #16a34a;
            background: rgba(236,253,245,.96);
        }
        .weekly-cta {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 36px;
            padding: .48rem .9rem;
            border-radius: var(--r-pill);
            background: linear-gradient(135deg, #0d9488, #10b981);
            color: #fff;
            font-size: .82rem;
            font-weight: 800;
            white-space: nowrap;
            border: 0;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(13,148,136,.18);
            transition: background var(--transition), box-shadow var(--transition), transform var(--transition);
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
        /* Filter workspace inspired by compact CRM filter panels */
        .course-browser-layout {
            display: grid;
            grid-template-columns: 292px minmax(0, 1fr);
            gap: 1.5rem;
            align-items: start;
            margin-top: 2.5rem;
        }
        .course-filter-panel {
            position: sticky;
            top: 96px;
            background: rgba(255,255,255,.78);
            border: 1px solid rgba(226,232,240,.9);
            border-radius: 18px;
            box-shadow: 0 18px 42px rgba(15,23,42,.07);
            overflow: hidden;
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
        }
        .filter-panel-header {
            padding: 1.1rem 1rem .95rem;
            border-bottom: 1px solid rgba(226,232,240,.75);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
        }
        .filter-panel-title {
            display: flex;
            align-items: center;
            gap: .58rem;
            color: var(--c-navy);
            font-size: 1.16rem;
            font-weight: 900;
        }
        .filter-panel-title svg,
        .filter-section-label svg {
            color: var(--c-primary);
            stroke-width: 2.3;
        }
        .filter-panel-title svg { width: 20px; height: 20px; }
        .filter-reset-btn {
            border: 0;
            background: transparent;
            color: var(--c-primary-d);
            font: inherit;
            font-size: .78rem;
            font-weight: 800;
            cursor: pointer;
            padding: .28rem .4rem;
            border-radius: 8px;
            transition: background var(--transition), color var(--transition);
        }
        .filter-reset-btn:hover {
            background: rgba(13,148,136,.08);
            color: var(--c-primary);
        }
        .filter-search-box {
            margin: .95rem 1rem 1rem;
            min-height: 44px;
            display: flex;
            align-items: center;
            gap: .65rem;
            padding: 0 .85rem;
            border: 1.5px solid rgba(203,213,225,.95);
            border-radius: 12px;
            background: rgba(255,255,255,.9);
            box-shadow: inset 0 1px 0 rgba(255,255,255,.86);
            transition: border-color var(--transition), box-shadow var(--transition);
        }
        .filter-search-box:focus-within {
            border-color: var(--c-primary-l);
            box-shadow: 0 0 0 4px rgba(13,148,136,.08);
        }
        .filter-search-box svg {
            width: 18px;
            height: 18px;
            color: #64748b;
            flex: 0 0 auto;
        }
        .filter-search-box input {
            width: 100%;
            border: 0;
            outline: 0;
            background: transparent;
            color: var(--c-text);
            font-size: .9rem;
            font-weight: 600;
        }
        .filter-search-box input::placeholder { color: #94a3b8; }
        .filter-section {
            border-top: 1px solid rgba(226,232,240,.72);
            padding: 1rem;
        }
        .filter-section-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: .75rem;
            margin-bottom: .8rem;
        }
        .filter-section-label {
            display: inline-flex;
            align-items: center;
            gap: .55rem;
            color: var(--c-navy);
            font-size: .9rem;
            font-weight: 900;
        }
        .filter-section-label svg { width: 17px; height: 17px; }
        .filter-section-count {
            color: #94a3b8;
            font-size: .75rem;
            font-weight: 800;
        }
        .course-filter-panel .category-scroll {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: .6rem;
            margin: 0;
            padding: 0;
            overflow: visible;
        }
        .course-filter-panel .filter-chips {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: .4rem;
            margin: 0;
            padding: 0;
        }
        .course-filter-panel .cat-pill,
        .course-filter-panel .chip {
            min-height: 34px;
            width: 100%;
            padding: .42rem .72rem;
            border-radius: 10px;
            font-size: .82rem;
            background: rgba(255,255,255,.86);
            box-shadow: 0 6px 14px rgba(15,23,42,.035);
        }
        .course-filter-panel .cat-pill { justify-content: flex-start; }
        .course-filter-panel .chip { justify-content: center; }
        .course-filter-panel .cat-pill.active,
        .course-filter-panel .chip.active {
            background: linear-gradient(135deg, #0d9488, #10b981);
            border-color: transparent;
            color: #fff;
            box-shadow: 0 10px 22px rgba(13,148,136,.2);
        }
        .filter-sort-control { position: relative; }
        .filter-sort-control::after {
            content: '';
            position: absolute;
            right: .9rem;
            top: 50%;
            width: 8px;
            height: 8px;
            border-right: 2px solid var(--c-primary);
            border-bottom: 2px solid var(--c-primary);
            transform: translateY(-65%) rotate(45deg);
            pointer-events: none;
        }
        .filter-sort-control .sort-select {
            width: 100%;
            min-height: 42px;
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            border-radius: 12px;
            padding: .55rem 2.4rem .55rem .8rem;
            background: rgba(255,255,255,.92);
            border-color: rgba(203,213,225,.95);
            box-shadow: 0 8px 18px rgba(15,23,42,.04);
        }
        .course-results-panel { min-width: 0; }
        .course-results-toolbar {
            position: relative;
            z-index: 50;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.25rem;
            padding: .85rem 1rem;
            border: 1px solid rgba(226,232,240,.8);
            border-radius: 16px;
            background: rgba(255,255,255,.62);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            box-shadow: 0 14px 32px rgba(15,23,42,.045);
        }
        .course-results-title {
            color: var(--c-navy);
            font-size: 1.3rem;
            font-weight: 900;
        }
        .course-results-panel .result-count { margin: 0; }

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
            .courses-hero { min-height: auto; padding: 2.75rem 1rem .75rem; }
            .hero-title, .hero-subtitle { max-width: 100%; }
            .weekly-featured-callout,
            .weekly-featured-stats { display: none; }
            .course-browser-layout { grid-template-columns: 1fr; margin-top: 1.5rem; }
            .course-filter-panel { position: relative; top: auto; }
            .course-results-toolbar { align-items: flex-start; flex-direction: column; }
            .weekly-featured-viewport {
                width: calc(100vw - 2rem);
                margin-left: 50%;
                transform: translateX(-50%);
                -webkit-mask-image: linear-gradient(90deg, transparent 0, #000 10%, #000 90%, transparent 100%);
                mask-image: linear-gradient(90deg, transparent 0, #000 10%, #000 90%, transparent 100%);
            }
            .weekly-course-card { width: 300px; }
            .stats-bar { gap: 1.5rem; flex-wrap: wrap; }
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
            <li><a href="${pageContext.request.contextPath}/mock-exams">Phòng thi</a></li>
            <li><a href="${pageContext.request.contextPath}/courses" class="active">Khóa học</a></li>
        </ul>

        <% if (user != null) { %>
            <div class="navbar-user-controls">
                <%@ include file="/WEB-INF/fragments/cart-icon.jspf" %>
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

<!-- HERO SECTION -->
<section class="courses-hero">
</section>

<!-- MAIN CONTENT -->
<div class="courses-body">

    <% if (hasDynamicCourses || showFeaturedSamples) { %>
    <!-- WEEKLY FEATURED COURSES -->
    <section class="weekly-featured">
        <div class="weekly-featured-callout" aria-hidden="true">
            <div class="featured-callout-text">Khóa học <span>nổi bật</span></div>
            <svg class="featured-callout-arrow" viewBox="0 0 180 82" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path class="arrow-shadow" d="M14 14 C16 35 42 40 50 22 C57 8 31 8 34 30 C38 61 102 63 145 58" />
                <path class="arrow-main" d="M12 12 C15 35 41 40 48 22 C55 8 31 8 34 30 C38 61 101 63 145 58" />
                <path class="arrow-main" d="M145 58 L125 46" />
                <path class="arrow-main" d="M145 58 L127 73" />
                <path class="arrow-highlight" d="M37 41 C54 60 103 61 135 58" />
            </svg>
        </div>
        <div class="weekly-featured-stats" aria-hidden="true">
            <div class="weekly-stat-card">
                <span class="weekly-stat-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 2l2.8 6 6.2.8-4.6 4.4 1.2 6.2L12 16.2 6.4 19.4l1.2-6.2L3 8.8 9.2 8 12 2z"/></svg>
                </span>
                <span class="weekly-stat-copy">
                    <span class="weekly-stat-value">4.8/5</span>
                    <span class="weekly-stat-label">đánh giá trung bình</span>
                </span>
            </div>
            <div class="weekly-stat-card">
                <span class="weekly-stat-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                </span>
                <span class="weekly-stat-copy">
                    <span class="weekly-stat-value">3.2k+</span>
                    <span class="weekly-stat-label">học viên đang học</span>
                </span>
            </div>
        </div>
        <div class="weekly-featured-viewport">
        <div class="weekly-featured-grid" id="weeklyFeaturedTrack">
            <% if (hasFeaturedCourses) { %>
            <%
                int weeklyLimit = Math.min(10, featuredCourses.size());
                for (int loop = 0; loop < 2; loop++) {
                for (int i = 0; i < weeklyLimit; i++) {
                    Course featuredCourse = featuredCourses.get(i);
                    String featuredThumbUrl = featuredCourse.getThumbnailUrl();
                    String featuredThumbStyle = (featuredThumbUrl != null && !featuredThumbUrl.trim().isEmpty())
                            ? "background-image:url('" + h(featuredThumbUrl) + "'); background-size:cover; background-position:center;"
                            : "background:" + h(featuredCourse.getThumbnailGradientOrDefault()) + "; display:flex; align-items:center; justify-content:center;";
            %>
            <article class="weekly-course-card">
                <div class="weekly-thumb">
                    <div class="weekly-thumb-bg" style="<%= featuredThumbStyle %>">
                        <% if (featuredThumbUrl == null || featuredThumbUrl.trim().isEmpty()) { %>
                            <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.55)" stroke-width="1.25"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        <% } %>
                    </div>
                    <span class="weekly-rating-badge" aria-label="Đánh giá <%= h(featuredCourse.getDisplayRating()) %> sao">
                        <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        <%= h(featuredCourse.getDisplayRating()) %>
                    </span>
                    <button type="button" class="weekly-cart-btn" onclick="handleWeeklyCart(event, this, '<%= h(featuredCourse.getId()) %>')" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                    </button>
                </div>
                <div class="weekly-info">
                    <h3 class="weekly-title"><%= h(featuredCourse.getTitle()) %></h3>
                    <div class="weekly-teacher-row">
                        <div class="weekly-teacher"><%= h(featuredCourse.getTeacherName()) %></div>
                        <span class="weekly-students" aria-label="<%= featuredCourse.getStudentsCount() %> học viên">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            <%= featuredCourse.getStudentsCount() %>
                        </span>
                    </div>
                    <div class="weekly-footer">
                        <span class="weekly-price <%= featuredCourse.isFree() ? "free" : "" %>"><%= h(featuredCourse.getPriceLabel()) %></span>
                        <a href="#" class="weekly-cta" onclick="event.preventDefault(); event.stopPropagation();">Xem chi tiết</a>
                    </div>
                </div>
            </article>
            <% } } %>
            <% } else if (showFeaturedSamples) { %>
            <article class="weekly-course-card">
                <div class="weekly-thumb">
                    <div class="weekly-thumb-bg" style="background:linear-gradient(135deg,#0f766e 0%,#14b8a6 48%,#7c3aed 100%); display:flex; align-items:center; justify-content:center;">
                        <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.58)" stroke-width="1.25"><path d="M3 5h18M3 10h12M3 15h9M3 20h6"/><circle cx="19" cy="17" r="3"/><path d="M22 20l-1.5-1.5"/></svg>
                    </div>
                    <span class="weekly-rating-badge" aria-label="Đánh giá 4.9 sao">
                        <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        4.9
                    </span>
                    <button type="button" class="weekly-cart-btn" onclick="handleWeeklyCart(event, this, '')" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                    </button>
                </div>
                <div class="weekly-info">
                    <h3 class="weekly-title">Master IELTS Writing Task 2 từ con số 0 đến Band 7.5</h3>
                    <div class="weekly-teacher-row">
                        <div class="weekly-teacher">Trần Anh Khoa</div>
                        <span class="weekly-students" aria-label="950 học viên">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            950
                        </span>
                    </div>
                    <div class="weekly-footer">
                        <span class="weekly-price free">Miễn phí</span>
                        <a href="#" class="weekly-cta" onclick="event.preventDefault(); event.stopPropagation();">Xem chi tiết</a>
                    </div>
                </div>
            </article>
            <article class="weekly-course-card">
                <div class="weekly-thumb">
                    <div class="weekly-thumb-bg" style="background:linear-gradient(135deg,#2563eb 0%,#6366f1 100%); display:flex; align-items:center; justify-content:center;">
                        <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.58)" stroke-width="1.25"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/><path d="M8 7h8M8 11h6"/></svg>
                    </div>
                    <span class="weekly-rating-badge" aria-label="Đánh giá 4.8 sao">
                        <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        4.8
                    </span>
                    <button type="button" class="weekly-cart-btn" onclick="handleWeeklyCart(event, this, '')" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                    </button>
                </div>
                <div class="weekly-info">
                    <h3 class="weekly-title">Luyện thi ĐGNL ĐHQG TP.HCM - Toán tổng ôn siêu tốc</h3>
                    <div class="weekly-teacher-row">
                        <div class="weekly-teacher">Nguyễn Văn An</div>
                        <span class="weekly-students" aria-label="820 học viên">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            820
                        </span>
                    </div>
                    <div class="weekly-footer">
                        <span class="weekly-price free">Miễn phí</span>
                        <a href="#" class="weekly-cta" onclick="event.preventDefault(); event.stopPropagation();">Xem chi tiết</a>
                    </div>
                </div>
            </article>
            <article class="weekly-course-card">
                <div class="weekly-thumb">
                    <div class="weekly-thumb-bg" style="background:linear-gradient(135deg,#7c3aed 0%,#a78bfa 100%); display:flex; align-items:center; justify-content:center;">
                        <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.58)" stroke-width="1.25"><circle cx="12" cy="12" r="4"/><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
                    </div>
                    <span class="weekly-rating-badge" aria-label="Đánh giá 4.7 sao">
                        <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                        4.7
                    </span>
                    <button type="button" class="weekly-cart-btn" onclick="handleWeeklyCart(event, this, '')" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                    </button>
                </div>
                <div class="weekly-info">
                    <h3 class="weekly-title">Chinh phục điểm 9+ Vật Lý 12 bằng sơ đồ tư duy</h3>
                    <div class="weekly-teacher-row">
                        <div class="weekly-teacher">Lê Hương Giang</div>
                        <span class="weekly-students" aria-label="610 học viên">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            610
                        </span>
                    </div>
                    <div class="weekly-footer">
                        <span class="weekly-price">150.000 đ</span>
                        <a href="#" class="weekly-cta" onclick="event.preventDefault(); event.stopPropagation();">Xem chi tiết</a>
                    </div>
                </div>
            </article>
            <% } %>
        </div>
        </div>
    </section>
    <% } %>

    <div class="course-browser-layout">
        <aside class="course-filter-panel" aria-label="Bộ lọc khóa học">
            <div class="filter-panel-header">
                <div class="filter-panel-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M22 3H2l8 9.46V19l4 2v-8.54L22 3z"/></svg>
                    <span>Bộ lọc</span>
                </div>
                <button type="button" class="filter-reset-btn" onclick="resetCourseFilters()">Đặt lại</button>
            </div>

            <div class="filter-search-box">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
                <input type="text" id="courseSearch" placeholder="Tìm khóa học, giáo viên..." value="<%= h(currentSearch) %>" autocomplete="off">
            </div>

            <section class="filter-section">
                <div class="filter-section-title">
                    <span class="filter-section-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/></svg>
                        Danh mục
                    </span>
                    <span class="filter-section-count"><%= subjects != null ? subjects.size() : 11 %> môn</span>
                </div>
                <div class="category-scroll" id="categoryScroll">
                    <button class="cat-pill active" data-cat="all" onclick="filterByCategory(this, 'all')"><span class="cat-pill-icon">🎯</span> Tất cả</button>
                    <% if (subjects != null) { 
                           for (Course s : subjects) { 
                               String code = s.getSubjectCode();
                               String name = s.getSubjectName();
                               String icon = "📚"; // default icon
                               if ("math".equals(code)) icon = "📐";
                               else if ("literature".equals(code)) icon = "📖";
                               else if ("english".equals(code)) icon = "🌍";
                               else if ("physics".equals(code)) icon = "⚛";
                               else if ("chemistry".equals(code)) icon = "🧪";
                               else if ("biology".equals(code)) icon = "🧬";
                               else if ("history".equals(code)) icon = "🏛";
                               else if ("geography".equals(code)) icon = "🗺";
                               else if ("civics".equals(code)) icon = "⚖";
                               else if ("it".equals(code)) icon = "💻";
                               else if ("technology".equals(code)) icon = "⚙";
                               String activeCls = code.equals(currentSubject) ? " active" : "";
                    %>
                    <button class="cat-pill<%= activeCls %>" data-cat="<%= h(code) %>" onclick="filterByCategory(this, '<%= h(code) %>')"><span class="cat-pill-icon"><%= icon %></span> <%= h(name) %></button>
                    <% } } %>
                </div>
            </section>

            <section class="filter-section">
                <div class="filter-section-title">
                    <span class="filter-section-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 7h-9"/><path d="M14 17H5"/><circle cx="17" cy="17" r="3"/><circle cx="7" cy="7" r="3"/></svg>
                        Trạng thái
                    </span>
                    <span class="filter-section-count">3 lựa chọn</span>
                </div>
                <div class="filter-chips">
                    <button class="chip active" data-filter="all" id="filter-all" onclick="applyFilter(this, 'all')">Tất cả</button>
                    <button class="chip" data-filter="free" id="filter-free" onclick="applyFilter(this, 'free')">Miễn phí</button>
                    <button class="chip" data-filter="paid" id="filter-paid" onclick="applyFilter(this, 'paid')">Có phí</button>
                </div>
            </section>

        </aside>

        <main class="course-results-panel">
            <div class="course-results-toolbar">
                <div class="course-results-title">
                    <p class="result-count" id="resultCount" style="margin: 0;">Hiển thị <strong id="visibleCount"><%= initialCourseCount %></strong> khóa học</p>
                </div>
                <div style="display: flex; align-items: center; gap: 1.25rem;">
                    <div class="filter-sort-control" style="display: flex; align-items: center; gap: 0.6rem;">
                        <select class="sort-select" id="enrollmentSelect" onchange="applySorting()">
                            <option value="all">Tất cả</option>
                            <option value="enrolled">Đã mua</option>
                            <option value="not_enrolled">Chưa mua</option>
                        </select>
                    </div>
                    <div class="filter-sort-control" style="display: flex; align-items: center; gap: 0.6rem;">
                        <select class="sort-select" id="sortSelect" onchange="applySorting()">
                            <option value="popular">Phổ biến nhất</option>
                            <option value="newest">Mới nhất</option>
                            <option value="rating">Đánh giá cao</option>
                            <option value="price-asc">Giá tăng dần</option>
                            <option value="price-desc">Giá giảm dần</option>
                        </select>
                    </div>
                </div>
            </div>

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
        <article class="course-card" data-cat="<%= h(course.getSubjectCode()) %>" data-price-type="<%= h(course.getPriceType()) %>" data-price="<%= h(priceValue) %>" data-rating="<%= h(ratingValue) %>" data-popular="<%= course.getStudentsCount() %>" data-new="<%= course.isNew() ? "1" : "0" %>" data-enrolled="<%= course.isViewerEnrolled() ? "true" : "false" %>">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="<%= thumbStyle %>">
                    <% if (thumbUrl == null || thumbUrl.trim().isEmpty()) { %>
                        <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.55)" stroke-width="1.25"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    <% } %>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá <%= h(course.getDisplayRating()) %> sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    <%= h(course.getDisplayRating()) %>
                </span>
                <% if (profileHasStudent && !course.isViewerEnrolled()) { 
                       boolean inCart = cartCourseIds.contains(course.getId());
                %>
                <button type="button" class="card-cart-btn<%= inCart ? " added" : "" %>" onclick="addToCart(event, this, '<%= h(course.getId()) %>')" title="<%= inCart ? "Đã thêm vào giỏ" : "Thêm vào giỏ" %>" aria-label="Thêm vào giỏ">
                    <% if (inCart) { %>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    <% } else { %>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                    <% } %>
                </button>
                <% } %>
            </div>
            <div class="card-body">
                <div class="card-subject"><span class="card-subject-dot"></span> <%= h(course.getSubjectName()) %></div>
                <h3 class="card-title"><%= h(course.getTitle()) %></h3>
                <div class="card-teacher-row">
                    <div class="card-teacher"><%= h(course.getTeacherName()) %></div>
                    <span class="card-students" aria-label="<%= course.getStudentsCount() %> học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        <%= course.getStudentsCount() %>
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price <%= course.isFree() ? "free" : "" %>"><%= h(course.getPriceLabel()) %></span>
                    <a href="${pageContext.request.contextPath}/course-detail?id=<%= h(course.getId()) %>" class="card-cta" style="text-decoration: none;">Xem chi tiết</a>
                </div>
            </div>
        </article>
        <%  }
           } else if (showSampleCourses) { %>

        <!-- Card 1 -->
        <article class="course-card" data-cat="english" data-price-type="free" data-price="0" data-rating="4.9" data-popular="950" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#0f766e 0%,#14b8a6 50%,#7c3aed 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M3 5h18M3 10h12M3 15h9M3 20h6"/><circle cx="19" cy="17" r="3"/><path d="M22 20l-1.5-1.5"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.9 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.9
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject"><span class="card-subject-dot"></span> Tiếng Anh</div>
                <h3 class="card-title">Master IELTS Writing Task 2 từ con số 0 đến Band 7.5</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Trần Anh Khoa</div>
                    <span class="card-students" aria-label="950 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        950
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price free">Miễn phí</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 2 -->
        <article class="course-card" data-cat="math" data-price-type="free" data-price="0" data-rating="4.8" data-popular="820" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#3b82f6 0%,#6366f1 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.8 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.8
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#3b82f6"><span class="card-subject-dot"></span> Toán học</div>
                <h3 class="card-title">Luyện thi ĐGNL ĐHQG TP.HCM — Toán tổng ôn siêu tốc</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Nguyễn Văn An</div>
                    <span class="card-students" aria-label="820 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        820
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price free">Miễn phí</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 3 -->
        <article class="course-card" data-cat="physics" data-price-type="paid" data-price="150000" data-rating="4.7" data-popular="610" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#8b5cf6 0%,#a78bfa 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><circle cx="12" cy="12" r="4"/><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.7 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.7
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#8b5cf6"><span class="card-subject-dot" style="background:#8b5cf6"></span> Vật lý</div>
                <h3 class="card-title">Chinh phục Điểm 9+ Vật Lý 12 bằng Sơ đồ tư duy</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Lê Hương Giang</div>
                    <span class="card-students" aria-label="610 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        610
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price">150.000 đ <span class="price-original">299.000 đ</span></span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 4 -->
        <article class="course-card" data-cat="english" data-price-type="free" data-price="0" data-rating="4.6" data-popular="740" data-new="1">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#f59e0b 0%,#f97316 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.6 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.6
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#f59e0b"><span class="card-subject-dot" style="background:#f59e0b"></span> Tiếng Anh</div>
                <h3 class="card-title">Ngữ Pháp Tiếng Anh Căn Bản — Từ Mất Gốc đến Tự Tin</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Phạm Minh Đức</div>
                    <span class="card-students" aria-label="740 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        740
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price free">Miễn phí</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 5 -->
        <article class="course-card" data-cat="chemistry" data-price-type="paid" data-price="299000" data-rating="4.9" data-popular="480" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#059669 0%,#10b981 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M9 3h6l3 7-6 2-6-2 3-7z"/><path d="M9 3v4M15 3v4"/><path d="M6 10l-2 9h16l-2-9"/><circle cx="12" cy="16" r="2"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.9 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.9
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#059669"><span class="card-subject-dot" style="background:#059669"></span> Hóa học</div>
                <h3 class="card-title">Hóa Hữu Cơ Nâng Cao — Bộ đề luyện THPTQG cực chất</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Vũ Khánh Hà</div>
                    <span class="card-students" aria-label="480 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        480
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price">299.000 đ</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 6 -->
        <article class="course-card" data-cat="it" data-price-type="free" data-price="0" data-rating="4.8" data-popular="560" data-new="1">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#1e293b 0%,#334155 50%,#0f766e 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/><path d="M7 7l3 3-3 3M13 13h4"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.8 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.8
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#0f766e"><span class="card-subject-dot"></span> Tin học</div>
                <h3 class="card-title">Lập trình Python từ Zero — Xây dự án thực tế trong 30 ngày</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Đặng Bảo Trung</div>
                    <span class="card-students" aria-label="560 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        560
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price free">Miễn phí</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 7 -->
        <article class="course-card" data-cat="literature" data-price-type="paid" data-price="120000" data-rating="4.5" data-popular="320" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#e11d48 0%,#f43f5e 50%,#fb7185 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/><path d="M8 7h8M8 11h6"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.5 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.5
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#e11d48"><span class="card-subject-dot" style="background:#e11d48"></span> Ngữ văn</div>
                <h3 class="card-title">Nghị luận văn học nâng cao — Bứt phá điểm 8+ kỳ thi THPT</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Bùi Thu Phương</div>
                    <span class="card-students" aria-label="320 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        320
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price">120.000 đ <span class="price-original">199.000 đ</span></span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 8 -->
        <article class="course-card" data-cat="biology" data-price-type="free" data-price="0" data-rating="4.7" data-popular="290" data-new="0">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#16a34a 0%,#22c55e 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2z"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.7 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.7
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#16a34a"><span class="card-subject-dot" style="background:#16a34a"></span> Sinh học</div>
                <h3 class="card-title">Di Truyền học — Chinh phục chuyên đề khó nhất Sinh 12</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Trần Ngọc Quỳnh</div>
                    <span class="card-students" aria-label="290 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        290
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price free">Miễn phí</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <!-- Card 9 -->
        <article class="course-card" data-cat="history" data-price-type="paid" data-price="199000" data-rating="4.6" data-popular="210" data-new="1">
            <div class="card-thumb">
                <div class="card-thumb-bg" style="background:linear-gradient(135deg,#78350f 0%,#b45309 50%,#d97706 100%); display:flex; align-items:center; justify-content:center;">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" stroke-width="1.2"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 3.9 2.4-7.4L2 9.4h7.6L12 2z"/></svg>
                </div>
                <span class="card-rating-badge" aria-label="Đánh giá 4.6 sao">
                    <svg viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                    4.6
                </span>
                <button type="button" class="card-cart-btn" title="Thêm vào giỏ" aria-label="Thêm vào giỏ">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                </button>
            </div>
            <div class="card-body">
                <div class="card-subject" style="color:#b45309"><span class="card-subject-dot" style="background:#b45309"></span> Lịch sử</div>
                <h3 class="card-title">Lịch Sử Việt Nam 1945–1975 — Timeline & Phân tích chuyên sâu</h3>
                <div class="card-teacher-row">
                    <div class="card-teacher">Ngô Duy Long</div>
                    <span class="card-students" aria-label="210 học viên">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        210
                    </span>
                </div>
                <div class="card-footer">
                    <span class="card-price">199.000 đ</span>
                    <span class="card-cta">Xem chi tiết</span>
                </div>
            </div>
        </article>

        <% } %>
    </div><!-- /courses-grid -->

    <!-- EMPTY STATE -->
    <div class="empty-state <%= initialCourseCount > 0 ? "" : "visible" %>" id="emptyState">
        <div class="empty-icon">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--c-primary)" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/><path d="M8 11h6M11 8v6"/></svg>
        </div>
        <h3>Không tìm thấy khóa học</h3>
        <p>Thử thay đổi từ khóa hoặc bộ lọc để tìm khóa học phù hợp.</p>
    </div>

    <!-- LOAD MORE -->
    <div class="load-more-wrap" id="loadMoreWrap" style="<%= initialCourseCount > 0 ? "" : "display:none;" %>">
        <button class="load-more-btn" id="loadMoreBtn" onclick="loadMore()">
            <span class="spinner" id="loadSpinner"></span>
            <span id="loadMoreText">Xem thêm khóa học</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" id="loadMoreIcon"><path d="M12 5v14M5 12l7 7 7-7"/></svg>
        </button>
    </div>
        </main>
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

const weeklyFeaturedTrack = document.getElementById('weeklyFeaturedTrack');
if (weeklyFeaturedTrack && !weeklyFeaturedTrack.dataset.marqueeReady) {
    const originalCards = Array.from(weeklyFeaturedTrack.children);
    const viewport = weeklyFeaturedTrack.closest('.weekly-featured-viewport');
    weeklyFeaturedTrack.dataset.marqueeReady = 'true';

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (!prefersReducedMotion && viewport && originalCards.length > 0) {
        let offset = 0;
        let lastTime = null;
        let currentSpeed = 46;
        let targetSpeed = 46;
        let loopWidth = 0;

        viewport.addEventListener('mouseenter', () => { targetSpeed = 16; });
        viewport.addEventListener('mouseleave', () => { targetSpeed = 46; });

        function cloneOriginalSet() {
            originalCards.forEach(card => {
                const clone = card.cloneNode(true);
                clone.setAttribute('aria-hidden', 'true');
                clone.tabIndex = -1;
                clone.querySelectorAll('a, button').forEach(control => {
                    control.tabIndex = -1;
                });
                weeklyFeaturedTrack.appendChild(clone);
            });
        }

        function measureLoop() {
            const styles = window.getComputedStyle(weeklyFeaturedTrack);
            const gap = parseFloat(styles.columnGap || styles.gap || '0') || 0;
            const cardsWidth = originalCards.reduce((sum, card) => sum + card.getBoundingClientRect().width, 0);
            loopWidth = cardsWidth + gap * originalCards.length;

            while (weeklyFeaturedTrack.scrollWidth < viewport.clientWidth + loopWidth + gap) {
                cloneOriginalSet();
            }
        }

        measureLoop();
        window.addEventListener('resize', debounce(measureLoop, 150));

        function tick(time) {
            if (lastTime === null) lastTime = time;
            const delta = Math.min((time - lastTime) / 1000, 0.05);
            lastTime = time;

            currentSpeed += (targetSpeed - currentSpeed) * Math.min(delta * 6, 1);
            if (loopWidth > 0) {
                offset = (offset + currentSpeed * delta) % loopWidth;
                weeklyFeaturedTrack.style.transform = 'translateX(-' + offset + 'px)';
            }

            requestAnimationFrame(tick);
        }

        requestAnimationFrame(tick);
    }
}

function handleWeeklyCart(e, btn, courseId) {
    if (e) {
        e.preventDefault();
        e.stopPropagation();
    }
    if (courseId && typeof window.addToCart === 'function') {
        window.addToCart(e, btn, courseId);
        return;
    }
    btn.classList.add('added');
    window.setTimeout(() => btn.classList.remove('added'), 900);
}

// ─── SEARCH ───────────────────────────────────────────
const searchInput = document.getElementById('courseSearch');
if (searchInput) {
    searchInput.addEventListener('input', debounce(() => {
        searchQuery = searchInput.value.trim().toLowerCase();
        applyAll();
    }, 250));
}

function applySearch() {
    if (!searchInput) return;
    searchQuery = searchInput.value.trim().toLowerCase();
    applyAll();
}

function resetCourseFilters() {
    const allCategory = document.querySelector('.cat-pill[data-cat="all"]');
    const allFilter = document.getElementById('filter-all');
    const sortSelect = document.getElementById('sortSelect');
    const enrollSelect = document.getElementById('enrollmentSelect');
    if (searchInput) searchInput.value = '';
    searchQuery = '';
    if (allCategory) filterByCategory(allCategory, 'all');
    if (allFilter) applyFilter(allFilter, 'all');
    if (sortSelect) sortSelect.value = 'popular';
    if (enrollSelect) enrollSelect.value = 'all';
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
    const enrollVal = document.getElementById('enrollmentSelect')?.value || 'all';
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
        const enrollMatch = enrollVal === 'all'
            || (enrollVal === 'enrolled'     && card.dataset.enrolled === 'true')
            || (enrollVal === 'not_enrolled' && card.dataset.enrolled !== 'true');
        const title   = card.querySelector('.card-title')?.textContent?.toLowerCase() || '';
        const author  = card.querySelector('.author-name')?.textContent?.toLowerCase() || '';
        const subject = card.querySelector('.card-subject')?.textContent?.toLowerCase() || '';
        const srchMatch = !searchQuery || title.includes(searchQuery) || author.includes(searchQuery) || subject.includes(searchQuery);

        const show = catMatch && filterMatch && srchMatch && enrollMatch;
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

// ─── ADD TO CART ──────────────────────────────────────
const cartBagIconSvg = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>';
const cartCheckIconSvg = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';

function getCourseCartButtons(courseId) {
    if (!courseId) return [];
    return Array.from(document.querySelectorAll('.card-cart-btn[onclick*="' + courseId + '"], .weekly-cart-btn[onclick*="' + courseId + '"]'));
}

function setCourseCartState(courseId, added) {
    getCourseCartButtons(courseId).forEach(btn => {
        btn.classList.toggle('added', added);
        btn.disabled = false;
        btn.setAttribute('title', added ? 'Đã thêm vào giỏ' : 'Thêm vào giỏ');
        btn.setAttribute('aria-label', added ? 'Đã thêm vào giỏ' : 'Thêm vào giỏ');
        btn.innerHTML = added ? cartCheckIconSvg : cartBagIconSvg;
        btn.style.transform = '';
        btn.style.opacity = '';
    });
}

window.addToCart = function(e, btn, courseId) {
    if (e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    if (btn.disabled) return;
    btn.disabled = true;

    const isAdded = btn.classList.contains('added');
    const action = isAdded ? 'remove' : 'add';

    const formData = new URLSearchParams();
    formData.append('action', action);
    formData.append('courseId', courseId);

    fetch('${pageContext.request.contextPath}/cart', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formData.toString()
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            btn.style.transform = 'scale(0.7)';
            btn.style.opacity = '0.5';
            
            setTimeout(() => {
                const added = action === 'add';
                setCourseCartState(courseId, added);
                showToast(added ? 'Đã thêm vào giỏ hàng' : 'Đã xóa khỏi giỏ hàng', 'success');
                if (!added) {
                    window.dispatchEvent(new CustomEvent('cartItemRemoved', { detail: courseId }));
                }
            }, 150);

            if (data.count !== undefined) {
                const badge = document.getElementById('cart-item-count');
                if (badge) {
                    if (data.count > 0) {
                        badge.textContent = data.count > 9 ? '9+' : String(data.count);
                        badge.style.display = 'flex';
                    } else {
                        badge.style.display = 'none';
                    }
                }
                const countLabel = document.getElementById('cart-count-label');
                if (countLabel) countLabel.textContent = data.count;
            }
        } else {
            if (data.message === 'Vui lòng đăng nhập để sử dụng giỏ hàng.') {
                window.location.href = '${pageContext.request.contextPath}/login';
            } else {
                showToast(data.message || 'Đã có lỗi xảy ra.', 'error');
            }
        }
    })
    .catch(error => {
        console.error('Error modifying cart:', error);
        showToast('Không thể kết nối đến máy chủ.', 'error');
    })
    .finally(() => {
        setTimeout(() => btn.disabled = false, 300);
    });
};

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
    if (!document.getElementById('slideInUpFrames')) {
        const style = document.createElement('style');
        style.id = 'slideInUpFrames';
        style.innerHTML = `@keyframes slideInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }`;
        document.head.appendChild(style);
    }
}

// ─── UTILITY ──────────────────────────────────────────
function debounce(fn, ms) {
    let t;
    return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
}

window.addEventListener('cartItemRemoved', function(e) {
    const courseId = e.detail;
    if (!courseId) return;
    setCourseCartState(courseId, false);
});
</script>

</body>
</html>

