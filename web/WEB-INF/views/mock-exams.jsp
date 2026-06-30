<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.MockExam"%>
<%@page import="java.util.List"%>
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
    List<MockExam> publishedMockMcqExams = (List<MockExam>) request.getAttribute("publishedMockMcqExams");
    List<MockExam> publishedMockEssayExams = (List<MockExam>) request.getAttribute("publishedMockEssayExams");
    boolean hasPublishedMcq = publishedMockMcqExams != null && !publishedMockMcqExams.isEmpty();
    boolean hasPublishedEssay = publishedMockEssayExams != null && !publishedMockEssayExams.isEmpty();
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
        *, *::before, *::after {
            box-sizing: border-box;
        }

        :root {
            --mock-ink: #0f172a;
            --mock-muted: #64748b;
            --mock-soft: #f8fafc;
            --mock-line: #dbe7ef;
            --mock-primary: #047857;
            --mock-primary-strong: #065f46;
            --mock-blue: #2563eb;
            --mock-amber: #b45309;
            --mock-rose: #be123c;
            --mock-shadow: 0 18px 50px rgba(15, 23, 42, 0.09);
        }
        body {
            background: #f6fbf9;
            color: var(--mock-ink);
        }

        body::before,
        body::after {
            display: none;
        }

        /* Transparent navbar on scroll top */
        .navbar:not(.scrolled) {
            background: transparent !important;
            border-bottom-color: transparent !important;
            box-shadow: none !important;
        }

        @keyframes fadeSlideDown {
            from { opacity: 0; transform: translateY(-18px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── EXAM HERO ──────────────────────────────── */
        .page-hero-exam {
            text-align: center;
            padding: 2.5rem 1.5rem 1rem;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .hero-kicker-exam {
            display: inline-flex;
            align-items: center;
            gap: .55rem;
            background: #d1fae5;
            color: #065f46;
            font-weight: 800;
            font-size: .85rem;
            letter-spacing: .05em;
            text-transform: uppercase;
            padding: .4rem 1rem;
            border-radius: 999px;
            margin-bottom: 1.5rem;
            animation: fadeSlideDown .6s ease both;
        }
        .hero-title-exam {
            font-size: clamp(1.9rem, 4.5vw, 3rem);
            font-weight: 900;
            line-height: 1.18;
            color: #071627;
            max-width: 780px;
            margin-bottom: 1rem;
            animation: fadeSlideDown .65s .08s ease both;
        }
        .hero-title-accent {
            color: var(--mock-primary);
        }
        .hero-sub-exam {
            color: #475569;
            font-size: 1.05rem;
            font-weight: 500;
            line-height: 1.75;
            max-width: 680px;
            margin-bottom: 2.2rem;
            animation: fadeSlideDown .7s .14s ease both;
        }
        .hero-exam-search-wrap {
            width: 100%;
            max-width: 640px;
            animation: fadeSlideDown .75s .2s ease both;
        }
        .hero-exam-search-bar {
            display: flex;
            align-items: center;
            background: #ffffff;
            border: 2px solid #e2e8f0;
            border-radius: 999px;
            padding: .5rem .5rem .5rem 1.4rem;
            box-shadow: 0 8px 32px rgba(0,0,0,.08);
            transition: border-color .25s, box-shadow .25s;
            gap: .75rem;
        }
        .hero-exam-search-bar:focus-within {
            border-color: rgba(4,120,87,.4);
            box-shadow: 0 8px 32px rgba(4,120,87,.12), 0 0 0 4px rgba(4,120,87,.08);
        }
        .hero-exam-search-input {
            flex: 1;
            border: none;
            outline: none;
            font: 600 1rem inherit;
            color: #0f172a;
            background: transparent;
        }
        .hero-exam-search-input::placeholder { color: #94a3b8; font-weight: 400; }
        .hero-exam-search-btn {
            background: linear-gradient(135deg, #058c63 0%, #0aaf7e 100%);
            color: #fff;
            border: none;
            padding: .7rem 1.6rem;
            border-radius: 999px;
            font: 700 .95rem inherit;
            cursor: pointer;
            white-space: nowrap;
            box-shadow: 0 4px 14px rgba(5,140,99,.35);
            transition: opacity .2s, transform .2s;
        }
        .hero-exam-search-btn:hover { opacity: .9; transform: translateY(-1px); }
        .hero-exam-search-btn:active { transform: translateY(0); }

        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        .mock-page {
            position: relative;
            min-height: 100vh;
            padding: 7.25rem 1.5rem 4rem;
            overflow: hidden;
            background:
                linear-gradient(180deg, rgba(236, 253, 245, 0.88) 0%, rgba(248, 250, 252, 0.98) 43%, rgba(255, 247, 237, 0.58) 100%),
                linear-gradient(135deg, #f8fafc 0%, #ecfeff 44%, #fff7ed 100%);
        }

        .mock-page::before {
            content: "";
            position: absolute;
            inset: 0;
            pointer-events: none;
            background-image:
                linear-gradient(rgba(15, 23, 42, 0.045) 1px, transparent 1px),
                linear-gradient(90deg, rgba(15, 23, 42, 0.04) 1px, transparent 1px);
            background-size: 44px 44px;
            -webkit-mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.46), transparent 72%);
            mask-image: linear-gradient(180deg, rgba(0, 0, 0, 0.46), transparent 72%);
        }

        .mock-shell {
            position: relative;
            z-index: 1;
            width: 98%; max-width: none;
            margin: 0 auto;
        }

        .mock-hero {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 390px;
            gap: 2rem;
            align-items: center;
            margin-bottom: 1.7rem;
        }

        .mock-kicker {
            display: inline-flex;
            align-items: center;
            gap: 0.55rem;
            color: var(--mock-primary-strong);
            font-weight: 800;
            font-size: 0.86rem;
            margin-bottom: 1rem;
        }

        .mock-kicker-icon {
            width: 34px;
            height: 34px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #d1fae5;
            color: var(--mock-primary);
            flex: 0 0 auto;
        }

        .mock-kicker-icon svg,
        .mock-tab-icon svg,
        .exam-type svg,
        .exam-meta-item svg,
        .btn-start svg,
        .icon-action svg,
        .mock-search svg {
            width: 18px;
            height: 18px;
            stroke: currentColor;
        }

        .mock-hero h1 {
            max-width: 760px;
            margin: 0;
            font-size: 3.15rem;
            line-height: 1.13;
            font-weight: 900;
            letter-spacing: 0;
            color: #071627;
        }

        .mock-hero h1 span {
            color: var(--mock-primary);
        }

        .mock-hero p {
            max-width: 690px;
            margin: 1rem 0 0;
            color: #475569;
            font-size: 1.05rem;
            line-height: 1.75;
            font-weight: 500;
        }

        .mock-hero-card {
            border: 1px solid rgba(148, 163, 184, 0.24);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.86);
            box-shadow: var(--mock-shadow);
            overflow: hidden;
        }

        .mock-hero-card-top {
            display: grid;
            grid-template-columns: 108px minmax(0, 1fr);
            gap: 1rem;
            padding: 1.15rem;
            align-items: center;
            background: linear-gradient(135deg, rgba(236, 253, 245, 0.86), rgba(239, 246, 255, 0.88));
            border-bottom: 1px solid rgba(148, 163, 184, 0.18);
        }

        .mock-hero-card img {
            width: 108px;
            height: 108px;
            object-fit: contain;
            filter: drop-shadow(0 14px 18px rgba(15, 23, 42, 0.12));
        }

        .mock-hero-card h2 {
            margin: 0 0 0.4rem;
            font-size: 1.08rem;
            line-height: 1.35;
            color: #0f172a;
        }

        .mock-hero-card p {
            margin: 0;
            font-size: 0.86rem;
            line-height: 1.6;
            color: #475569;
        }

        .mock-focus-list {
            display: grid;
            gap: 0;
            margin: 0;
            padding: 0;
            list-style: none;
        }

        .mock-focus-list li {
            display: grid;
            grid-template-columns: 36px minmax(0, 1fr) auto;
            gap: 0.7rem;
            align-items: center;
            padding: 0.95rem 1.15rem;
            border-top: 1px solid rgba(226, 232, 240, 0.72);
        }

        .focus-step {
            width: 36px;
            height: 36px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            background: #ecfeff;
            color: #0369a1;
            font-weight: 900;
        }

        .mock-focus-list strong {
            display: block;
            color: #0f172a;
            font-size: 0.91rem;
            overflow-wrap: anywhere;
        }

        .mock-focus-list small {
            display: block;
            margin-top: 0.18rem;
            color: var(--mock-muted);
            font-weight: 600;
        }

        .focus-score {
            color: var(--mock-primary);
            font-weight: 900;
            white-space: nowrap;
        }

        .mock-board {
            border: 1px solid rgba(148, 163, 184, 0.25);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.88);
            box-shadow: var(--mock-shadow);
            overflow: hidden;
        }

        .mock-tabs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.6rem;
            padding: 0.85rem;
            background: rgba(248, 250, 252, 0.82);
            border-bottom: 1px solid rgba(226, 232, 240, 0.9);
        }

        .mock-tab {
            width: 100%;
            min-height: 74px;
            border: 1px solid transparent;
            border-radius: 8px;
            background: transparent;
            color: #475569;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.72rem;
            padding: 0.75rem;
            text-align: left;
            font-family: inherit;
            transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease, transform 0.2s ease;
        }

        .mock-tab:hover {
            background: #ffffff;
            border-color: rgba(148, 163, 184, 0.34);
            color: #0f172a;
        }

        .mock-tab.active {
            background: #ffffff;
            border-color: rgba(4, 120, 87, 0.28);
            color: var(--mock-primary-strong);
            box-shadow: 0 10px 24px rgba(4, 120, 87, 0.08);
        }

        .mock-tab-icon {
            width: 44px;
            height: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex: 0 0 auto;
            border-radius: 8px;
            background: #eef2ff;
            color: var(--mock-blue);
        }

        .mock-tab[data-tab-target="flashcard"] .mock-tab-icon {
            background: #fffbeb;
            color: var(--mock-amber);
        }

        .mock-tab[data-tab-target="essay"] .mock-tab-icon {
            background: #fff1f2;
            color: var(--mock-rose);
        }

        .mock-tab strong {
            display: block;
            color: inherit;
            font-size: 0.98rem;
        }

        .mock-tab small {
            display: block;
            margin-top: 0.18rem;
            color: var(--mock-muted);
            font-weight: 700;
        }

        .mock-toolbox {
            display: grid;
            grid-template-columns: minmax(260px, 1fr) auto;
            gap: 1rem;
            align-items: center;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid rgba(226, 232, 240, 0.88);
        }

        .mock-search {
            position: relative;
            min-width: 0;
        }

        .mock-search svg {
            position: absolute;
            left: 0.9rem;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
            pointer-events: none;
        }

        .mock-search input {
            width: 100%;
            min-height: 48px;
            padding: 0.78rem 1rem 0.78rem 2.75rem;
            border: 1px solid var(--mock-line);
            border-radius: 8px;
            outline: none;
            background: #ffffff;
            color: #0f172a;
            font: inherit;
            font-weight: 600;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .mock-search input:focus {
            border-color: rgba(4, 120, 87, 0.48);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
        }

        .mock-filters {
            display: flex;
            gap: 0.5rem;
            justify-content: flex-end;
            flex-wrap: wrap;
        }

        .mock-filter-select {
            min-height: 40px;
            border: 1px solid var(--mock-line);
            border-radius: 8px;
            background: #ffffff;
            color: #475569;
            padding: 0.55rem 2.5rem 0.55rem 1rem;
            font-family: inherit;
            font-weight: 800;
            cursor: pointer;
            outline: none;
            appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg fill="none" viewBox="0 0 24 24" stroke="%23475569" stroke-width="2" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path></svg>');
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 1rem;
            transition: all 0.2s ease;
        }

        .mock-filter-select:focus,
        .mock-filter-select:hover {
            background-color: #ecfdf5;
            color: var(--mock-primary-strong);
            border-color: rgba(4, 120, 87, 0.3);
        }

        .mock-tab-content {
            display: none;
            padding: 1.25rem;
        }

        .mock-tab-content.active {
            display: block;
            animation: mockFade 0.22s ease;
        }

        @keyframes mockFade {
            from {
                opacity: 0;
                transform: translateY(8px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .mock-section-head {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            align-items: flex-end;
            margin-bottom: 1rem;
        }

        .mock-section-head h2 {
            margin: 0;
            font-size: 1.35rem;
            line-height: 1.35;
            color: #0f172a;
        }

        .mock-section-head p {
            margin: 0.28rem 0 0;
            color: var(--mock-muted);
            font-weight: 600;
            line-height: 1.6;
        }

        .result-count {
            flex: 0 0 auto;
            color: var(--mock-primary-strong);
            background: #ecfdf5;
            border: 1px solid rgba(4, 120, 87, 0.16);
            border-radius: 8px;
            padding: 0.48rem 0.68rem;
            font-weight: 900;
            font-size: 0.86rem;
        }

        .exam-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1rem;
        }

        .exam-card {
            min-width: 0;
            min-height: 348px;
            display: flex;
            flex-direction: column;
            padding: 1rem;
            border: 1px solid rgba(203, 213, 225, 0.88);
            border-radius: 8px;
            background: #ffffff;
            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
        }

        .exam-card:hover {
            transform: translateY(-4px);
            border-color: rgba(4, 120, 87, 0.32);
            box-shadow: 0 18px 34px rgba(15, 23, 42, 0.1);
        }

        .exam-card.is-hidden {
            display: none;
        }

        .exam-card-top,
        .exam-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
        }

        .exam-type {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            min-height: 34px;
            padding: 0.4rem 0.58rem;
            border-radius: 8px;
            font-weight: 900;
            font-size: 0.82rem;
            color: var(--mock-blue);
            background: #eff6ff;
            border: 1px solid #dbeafe;
        }

        .exam-type.flashcard {
            color: var(--mock-amber);
            background: #fffbeb;
            border-color: #fde68a;
        }

        .exam-type.essay {
            color: var(--mock-rose);
            background: #fff1f2;
            border-color: #ffe4e6;
        }

        .exam-match {
            color: var(--mock-primary-strong);
            font-weight: 900;
            font-size: 0.82rem;
            white-space: nowrap;
        }

        .exam-card h3 {
            margin: 1rem 0 0.55rem;
            color: #071627;
            font-size: 1.13rem;
            line-height: 1.42;
            overflow-wrap: anywhere;
        }

        .exam-desc {
            margin: 0;
            color: #64748b;
            font-size: 0.9rem;
            line-height: 1.6;
            font-weight: 600;
        }

        .exam-meta-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.55rem;
            margin: 1rem 0;
        }

        .exam-meta-item {
            display: flex;
            align-items: center;
            gap: 0.45rem;
            min-width: 0;
            min-height: 38px;
            padding: 0.5rem 0.55rem;
            border-radius: 8px;
            background: #f8fafc;
            color: #475569;
            font-size: 0.82rem;
            font-weight: 800;
        }

        .exam-meta-item svg {
            width: 16px;
            height: 16px;
            flex: 0 0 auto;
            color: #64748b;
        }

        .exam-progress {
            margin-top: auto;
            padding-top: 0.15rem;
        }

        .exam-progress-row {
            display: flex;
            justify-content: space-between;
            gap: 0.8rem;
            align-items: center;
            color: #64748b;
            font-size: 0.82rem;
            font-weight: 800;
        }

        .exam-progress-row strong {
            color: #0f172a;
        }

        .progress-track {
            display: block;
            width: 100%;
            height: 8px;
            margin-top: 0.55rem;
            border-radius: 8px;
            overflow: hidden;
            background: #e2e8f0;
        }

        .progress-track span {
            display: block;
            width: var(--value);
            height: 100%;
            border-radius: inherit;
            background: linear-gradient(90deg, #10b981, #2563eb);
        }

        .exam-footer {
            margin-top: 1rem;
        }

        .btn-start {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            min-height: 44px;
            padding: 0.72rem 0.9rem;
            border-radius: 8px;
            background: #0f172a;
            color: #ffffff;
            text-decoration: none;
            font-weight: 900;
            flex: 1 1 auto;
            transition: background 0.2s ease, transform 0.2s ease;
        }

        .btn-start:hover {
            background: var(--mock-primary-strong);
            transform: translateY(-1px);
        }

        .icon-action {
            width: 44px;
            height: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex: 0 0 44px;
            border-radius: 8px;
            border: 1px solid var(--mock-line);
            background: #ffffff;
            color: #475569;
            cursor: pointer;
            transition: color 0.2s ease, border-color 0.2s ease, background 0.2s ease;
        }

        .icon-action:hover {
            color: var(--mock-primary-strong);
            border-color: rgba(4, 120, 87, 0.34);
            background: #ecfdf5;
        }

        .empty-state {
            display: none;
            text-align: center;
            padding: 2.3rem 1.2rem;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            background: #f8fafc;
            color: var(--mock-muted);
        }

        .empty-state.show {
            display: block;
        }

        .empty-state svg {
            width: 44px;
            height: 44px;
            color: #94a3b8;
            margin-bottom: 0.8rem;
        }

        .empty-state h3 {
            margin: 0 0 0.35rem;
            color: #0f172a;
            font-size: 1.05rem;
        }

        .empty-state p {
            margin: 0;
            font-weight: 600;
            line-height: 1.6;
        }

        @media (max-width: 1080px) {
            .mock-hero {
                flex-direction: column;
            }

            .mock-hero-card {
                max-width: 620px;
            }

            .exam-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .mock-page {
                padding: 6.25rem 1rem 3rem;
            }

            .mock-hero h1 {
                font-size: 2.15rem;
                max-width: 100%;
                overflow-wrap: break-word;
            }

            .mock-hero p {
                font-size: 0.98rem;
                max-width: 100%;
                overflow-wrap: break-word;
            }

            .mock-hero-card-top {
                grid-template-columns: 82px minmax(0, 1fr);
            }

            .mock-hero-card img {
                width: 82px;
                height: 82px;
            }

            .mock-tabs {
                flex-direction: column;
            }

            .mock-toolbox {
                flex-direction: column;
            }

            .mock-filters {
                justify-content: flex-start;
            }

            .mock-section-head {
                align-items: stretch;
                flex-direction: column;
            }

            .result-count {
                width: fit-content;
            }

            .exam-grid {
                flex-direction: column;
            }
        }

        @media (max-width: 560px) {
            .mock-page {
                padding-inline: 0.75rem;
            }

            .mock-hero h1 {
                font-size: 1.9rem;
                line-height: 1.18;
            }

            .mock-focus-list li {
                grid-template-columns: 34px minmax(0, 1fr);
            }

            .focus-score {
                grid-column: 2;
            }

            .exam-meta-grid {
                flex-direction: column;
            }
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

                <li><a href="${pageContext.request.contextPath}/mock-exams" class="active">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
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

    <main class="mock-page">
        <div class="mock-shell">
            <!-- HERO PHÒNG THI -->
            <section class="page-hero-exam" aria-labelledby="mock-title">
                <div class="hero-kicker-exam">
                    <span class="mock-kicker-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 3v18M5 8h14M7 16h10"/>
                        </svg>
                    </span>
                    Phòng luyện thi thông minh
                </div>
                <h1 id="mock-title" class="hero-title-exam">
                    Chọn đúng dạng luyện tập, <span class="hero-title-accent">vào bài nhanh hơn.</span>
                </h1>
</section>

            <section class="mock-board" aria-label="Danh sách bài thi thử">
                <div class="mock-tabs" role="tablist" aria-label="Chọn dạng bài thi">
                    <button type="button" class="mock-tab active" id="mock-tab-mcq" data-tab-target="mcq" role="tab" aria-controls="tab-mcq" aria-selected="true">
                        <span class="mock-tab-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                            </svg>
                        </span>
                        <span><strong>Trắc nghiệm</strong><small>3 đề kiểm tra tốc độ</small></span>
                    </button>
                    <button type="button" class="mock-tab" id="mock-tab-essay" data-tab-target="essay" role="tab" aria-controls="tab-essay" aria-selected="false">
                        <span class="mock-tab-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/>
                            </svg>
                        </span>
                        <span><strong>Tự luận</strong><small>2 bài luyện lập luận</small></span>
                    </button>
                </div>

                <div class="mock-toolbox" aria-label="Công cụ tìm kiếm và lọc">
                    <label class="mock-search">
                        <span class="sr-only">Tìm bài luyện thi</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>
                        </svg>
                        <input id="mockSearch" type="search" placeholder="Tìm theo môn, kỹ năng, mục tiêu...">
                    </label>
                    <div class="mock-filters" aria-label="Bộ lọc nhanh">
                        <select class="mock-filter-select" aria-label="Chọn môn học hoặc kỹ năng">
                                                        <option value="all">Tất cả</option>
                            <option value="toan">Toán</option>
                            <option value="ngu-van">Ngữ văn</option>
                            <option value="vat-ly">Vật lý</option>
                            <option value="hoa-hoc">Hóa học</option>
                            <option value="sinh-hoc">Sinh học</option>
                            <option value="lich-su">Lịch sử</option>
                            <option value="dia-ly">Địa lý</option>
                            <option value="tieng-anh">Tiếng Anh</option>
                            <option value="giao-duc-cong-dan">Giáo dục công dân</option>
                            <option value="tin-hoc">Tin học</option>
                            <option value="cong-nghe">Công nghệ</option>
                            <option value="ngoai-ngu-khac">Ngoại ngữ khác</option>
                        </select>
                    </div>
                </div>

                <div id="tab-mcq" class="mock-tab-content active" role="tabpanel" aria-labelledby="mock-tab-mcq">
                    <div class="mock-section-head">
                        <div>
                            <h2>Trắc nghiệm nổi bật</h2>
                            <p>Chọn đề theo thời gian, độ khó và mức độ phù hợp với mục tiêu hiện tại.</p>
                        </div>
                        <span class="result-count" aria-live="polite">3 lựa chọn phù hợp</span>
                    </div>

                    <div class="exam-grid">
                        <% if (hasPublishedMcq) {
                            for (MockExam exam : publishedMockMcqExams) {
                                String desc = exam.getDescription() != null && !exam.getDescription().trim().isEmpty()
                                        ? exam.getDescription()
                                        : "Đề trắc nghiệm được staff HIPZI đăng tải từ dữ liệu thật.";
                        %>
                        <article class="exam-card" data-search="<%= h((exam.getTitle() + " " + exam.getSubject() + " " + exam.getGradeLevel()).toLowerCase()) %>" data-tags="<%= h((exam.getSubject() + " " + exam.getGradeLevel()).toLowerCase()) %>">
                            <div class="exam-card-top">
                                <span class="exam-type">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                                    Trắc nghiệm
                                </span>
                            </div>
                            <h3><%= h(exam.getTitle()) %></h3>
                            <p class="exam-desc"><%= h(desc) %></p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/></svg><%= h(exam.getSubject()) %></span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg><%= exam.getDurationMinutes() != null ? exam.getDurationMinutes() + " phút" : "45 phút" %></span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h.01M3 12h.01M3 18h.01"/></svg><%= exam.getItemCount() %> câu</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg><%= h(exam.getGradeLevel()) %></span>
                            </div>
                            <div class="exam-footer">
                                <a href="${pageContext.request.contextPath}/mock-exam-room?examId=<%= exam.getId() %>" class="btn-start">Vào thi <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                            </div>
                        </article>
                        <% }
                        } else { %>
                        <article class="exam-card" data-search="Đề thi thử THPT Quốc Gia Môn Toán Mã đề 101 trắc nghiệm toán học 90 phút nâng cao" data-tags="toan thpt nang-cao">
                            <div class="exam-card-top">
                                <span class="exam-type">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                                    Trắc nghiệm
                                </span>
                                <span class="exam-match">Gợi ý 92%</span>
                            </div>
                            <h3>Đề thi thử THPT Quốc Gia - Môn Toán (Mã đề 101)</h3>
                            <p class="exam-desc">Mô phỏng cấu trúc đề thật, cân bằng nhận biết, vận dụng và câu phân loại.</p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/></svg>Toán học</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>90 phút</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h.01M3 12h.01M3 18h.01"/></svg>50 câu</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg>Nâng cao</span>
                            </div>
                            <div class="exam-footer">
                                <a href="#" class="btn-start">Vào thi <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                                <button type="button" class="icon-action" aria-label="Lưu đề Toán" title="Lưu đề"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></button>
                            </div>
                        </article>

                        <article class="exam-card" data-search="Kiểm tra 15 phút Môn Tiếng Anh Lớp 10 trắc nghiệm tiếng anh cấp tốc" data-tags="tieng-anh lop-10 cap-toc">
                            <div class="exam-card-top">
                                <span class="exam-type">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                                    Trắc nghiệm
                                </span>
                                <span class="exam-match">Nhanh 15 phút</span>
                            </div>
                            <h3>Kiểm tra 15 phút - Môn Tiếng Anh Lớp 10</h3>
                            <p class="exam-desc">Bài luyện ngắn để rà từ vựng, ngữ pháp và phản xạ chọn đáp án.</p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 7h20"/><path d="M2 17h20"/><path d="M7 2v20"/><path d="M17 2v20"/></svg>Tiếng Anh</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>15 phút</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h.01M3 12h.01M3 18h.01"/></svg>20 câu</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M13 2 3 14h9l-1 8 10-12h-9z"/></svg>Cấp tốc</span>
                            </div>
                            <div class="exam-footer">
                                <a href="#" class="btn-start">Vào thi <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                                <button type="button" class="icon-action" aria-label="Lưu đề Tiếng Anh" title="Lưu đề"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></button>
                            </div>
                        </article>

                        <article class="exam-card" data-search="Ôn tập Sinh học kỳ 1 nâng cao trắc nghiệm sinh học" data-tags="sinh-hoc nang-cao">
                            <div class="exam-card-top">
                                <span class="exam-type">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                                    Trắc nghiệm
                                </span>
                                <span class="exam-match">Ôn kỳ 1</span>
                            </div>
                            <h3>Ôn tập Sinh học kỳ 1 (Nâng cao)</h3>
                            <p class="exam-desc">Tập trung cơ chế di truyền, tế bào và câu hỏi phân tích tình huống.</p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10 2v7.31"/><path d="M14 9.3V2"/><path d="M8.5 2h7"/><path d="M14 9.3a6.5 6.5 0 1 1-4 0"/></svg>Sinh học</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>45 phút</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h.01M3 12h.01M3 18h.01"/></svg>35 câu</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg>Nâng cao</span>
                            </div>
                            <div class="exam-footer">
                                <a href="#" class="btn-start">Vào thi <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                                <button type="button" class="icon-action" aria-label="Lưu đề Sinh học" title="Lưu đề"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></button>
                            </div>
                        </article>
                        <% } %>
                    </div>

                    <div class="empty-state" aria-live="polite">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                        <h3>Không tìm thấy đề phù hợp</h3>
                        <p>Thử xoá bớt từ khóa hoặc chọn bộ lọc khác.</p>
                    </div>
                </div>

                <div id="tab-essay" class="mock-tab-content" role="tabpanel" aria-labelledby="mock-tab-essay">
                    <div class="mock-section-head">
                        <div>
                            <h2>Tự luận luyện lập luận</h2>
                            <p>Rèn dàn ý, diễn đạt và khả năng triển khai câu trả lời có cấu trúc.</p>
                        </div>
                        <span class="result-count" aria-live="polite">2 lựa chọn phù hợp</span>
                    </div>

                    <div class="exam-grid">
                        <% if (hasPublishedEssay) {
                            for (MockExam exam : publishedMockEssayExams) {
                                String desc = exam.getDescription() != null && !exam.getDescription().trim().isEmpty()
                                        ? exam.getDescription()
                                        : "Đề tự luận được staff HIPZI đăng tải từ dữ liệu thật.";
                        %>
                        <article class="exam-card" data-search="<%= h((exam.getTitle() + " " + exam.getSubject() + " " + exam.getGradeLevel()).toLowerCase()) %>" data-tags="<%= h((exam.getSubject() + " " + exam.getGradeLevel()).toLowerCase()) %>">
                            <div class="exam-card-top">
                                <span class="exam-type essay">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                    Tự luận
                                </span>
                            </div>
                            <h3><%= h(exam.getTitle()) %></h3>
                            <p class="exam-desc"><%= h(desc) %></p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/></svg><%= h(exam.getSubject()) %></span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg><%= exam.getDurationMinutes() != null ? exam.getDurationMinutes() + " phút" : "45 phút" %></span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg><%= exam.getItemCount() %> đề</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg><%= h(exam.getGradeLevel()) %></span>
                            </div>
                            <div class="exam-footer">
                                <a href="${pageContext.request.contextPath}/mock-essay-room?examId=<%= exam.getId() %>" class="btn-start">Luyện viết <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                            </div>
                        </article>
                        <% }
                        } else { %>
                        <article class="exam-card" data-search="Tự luận Ngữ văn phân tích đoạn thơ Việt Bắc viết nâng cao" data-tags="ngu-van viet nang-cao">
                            <div class="exam-card-top">
                                <span class="exam-type essay">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                    Tự luận
                                </span>
                                <span class="exam-match">Rèn ý chính</span>
                            </div>
                            <h3>Phân tích đoạn thơ trong bài Việt Bắc</h3>
                            <p class="exam-desc">Gợi ý chấm theo luận điểm, dẫn chứng và cách liên kết đoạn văn.</p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/></svg>Ngữ văn</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>45 phút</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>Viết dàn ý</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg>Nâng cao</span>
                            </div>
                            <div class="exam-footer">
                                <a href="#" class="btn-start">Luyện viết <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                                <button type="button" class="icon-action" aria-label="Lưu bài tự luận Ngữ văn" title="Lưu bài"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></button>
                            </div>
                        </article>

                        <article class="exam-card" data-search="Tự luận Tiếng Anh IELTS Writing Task 2 education viết tiếng anh nâng cao" data-tags="tieng-anh viet nang-cao">
                            <div class="exam-card-top">
                                <span class="exam-type essay">
                                    <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                                    Tự luận
                                </span>
                                <span class="exam-match">Writing Task 2</span>
                            </div>
                            <h3>IELTS Writing Task 2 - Education Topic</h3>
                            <p class="exam-desc">Luyện bố cục mở bài, thân bài, ví dụ và kết luận cho chủ đề giáo dục.</p>
                            <div class="exam-meta-grid">
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 7h20"/><path d="M2 17h20"/><path d="M7 2v20"/><path d="M17 2v20"/></svg>Tiếng Anh</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>40 phút</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>250 từ</span>
                                <span class="exam-meta-item"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 17 6-6 4 4 8-8"/><path d="M14 7h7v7"/></svg>Nâng cao</span>
                            </div>
                            <div class="exam-footer">
                                <a href="#" class="btn-start">Luyện viết <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>
                                <button type="button" class="icon-action" aria-label="Lưu bài tự luận Tiếng Anh" title="Lưu bài"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></button>
                            </div>
                        </article>
                        <% } %>
                    </div>

                    <div class="empty-state" aria-live="polite">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                        <h3>Không tìm thấy bài tự luận phù hợp</h3>
                        <p>Thử xoá bớt từ khóa hoặc chọn bộ lọc khác.</p>
                    </div>
                </div>
            </section>
        </div>
    </main>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
    <script>
        (function () {
            const tabs = Array.from(document.querySelectorAll('.mock-tab'));
            const panels = Array.from(document.querySelectorAll('.mock-tab-content'));
            const filterSelect = document.querySelector('.mock-filter-select');
            const searchInput = document.getElementById('mockSearch');
            let activeTab = 'mcq';
            let activeFilter = 'all';

            function normalize(value) {
                return (value || '')
                    .toLocaleLowerCase('vi-VN')
                    .normalize('NFD')
                    .replace(/[\u0300-\u036f]/g, '')
                    .replace(/đ/g, 'd')
                    .replace(/[^a-z0-9\s-]/g, ' ')
                    .replace(/\s+/g, ' ')
                    .trim();
            }

            function setFilter(nextFilter) {
                activeFilter = nextFilter;
                if (filterSelect && filterSelect.value !== nextFilter) {
                    filterSelect.value = nextFilter;
                }
            }

            function applyFilters() {
                const panel = document.getElementById('tab-' + activeTab);
                if (!panel) return;

                const query = normalize(searchInput.value);
                const cards = Array.from(panel.querySelectorAll('.exam-card'));
                let visibleCount = 0;

                cards.forEach(card => {
                    const titleText = card.querySelector('h3') ? card.querySelector('h3').textContent : '';
                    const subjectText = card.querySelector('.exam-meta-item') ? card.querySelector('.exam-meta-item').textContent : '';
                    const queryHaystack = normalize(titleText + ' ' + subjectText);
                    
                    const fullHaystack = normalize([card.dataset.search, card.dataset.tags, card.textContent].join(' '));
                    const tags = normalize(card.dataset.tags || '').split(/\s+/);
                    
                    const matchesQuery = !query || queryHaystack.includes(query);
                    const matchesFilter = activeFilter === 'all' || tags.includes(activeFilter) || fullHaystack.includes(activeFilter);
                    const isVisible = matchesQuery && matchesFilter;
                    
                    card.classList.toggle('is-hidden', !isVisible);
                    if (isVisible) visibleCount += 1;
                });

                const emptyState = panel.querySelector('.empty-state');
                const resultCount = panel.querySelector('.result-count');
                if (emptyState) emptyState.classList.toggle('show', visibleCount === 0);
                if (resultCount) resultCount.textContent = visibleCount + ' lựa chọn phù hợp';
            }

            function switchTab(tabId) {
                activeTab = tabId;

                tabs.forEach(tab => {
                    const isActive = tab.dataset.tabTarget === tabId;
                    tab.classList.toggle('active', isActive);
                    tab.setAttribute('aria-selected', isActive ? 'true' : 'false');
                });

                panels.forEach(panel => {
                    const isActive = panel.id === 'tab-' + tabId;
                    panel.classList.toggle('active', isActive);
                    panel.hidden = !isActive;
                });

                setFilter('all');
                applyFilters();
            }

            tabs.forEach(tab => {
                tab.addEventListener('click', () => switchTab(tab.dataset.tabTarget));
            });

            if (filterSelect) {
                filterSelect.addEventListener('change', (e) => {
                    setFilter(e.target.value);
                    applyFilters();
                });
            }

            if (searchInput) {
                searchInput.addEventListener('input', applyFilters);
            }

            document.querySelectorAll('.icon-action').forEach(button => {
                button.addEventListener('click', () => {
                    const isSaved = button.getAttribute('aria-pressed') === 'true';
                    button.setAttribute('aria-pressed', isSaved ? 'false' : 'true');
                    button.title = isSaved ? 'Lưu lại' : 'Đã lưu';
                });
            });

            panels.forEach(panel => {
                panel.hidden = !panel.classList.contains('active');
            });
            applyFilters();
        })();
</script>
</body>
</html>













