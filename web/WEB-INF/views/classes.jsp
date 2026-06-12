<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.User"%>
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
    <title>Lớp học trực tuyến - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/materials.css">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        :root {
            --font: "Be Vietnam Pro", "Inter", Arial, sans-serif;
            --c-primary:   #0d9488;
            --c-primary-l: #14b8a6;
            --c-primary-d: #0f766e;
            --c-accent:    #7c3aed;
            --c-navy:      #0f172a;
            --c-text:      #1e293b;
            --c-muted:     #64748b;
            --c-border:    #e2e8f0;
            --c-surface:   #ffffff;
            --r-pill:      999px;
            --transition:  .25s cubic-bezier(.4,0,.2,1);
        }
        .navbar:not(.scrolled) {
            background: transparent !important;
            border-bottom: none !important;
            box-shadow: none !important;
        }
        @keyframes fadeSlideDown {
            from { opacity: 0; transform: translateY(-16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .page-hero {
            background: transparent;
            min-height: 60vh;
            padding: 2rem 1.5rem 3rem;
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
        .hero-title {
            font-size: clamp(1.8rem, 4.5vw, 3rem);
            font-weight: 800;
            color: var(--c-navy);
            line-height: 1.2;
            max-width: 720px;
            margin-bottom: 1rem;
            animation: fadeSlideDown .65s .08s ease both;
        }
        .hero-title span {
            background: linear-gradient(135deg, #058c63 0%, #0aaf7e 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .hero-subtitle {
            color: #334155;
            font-weight: 500;
            font-size: 1.1rem;
            max-width: 580px;
            margin-bottom: 2rem;
            line-height: 1.7;
            animation: fadeSlideDown .7s .14s ease both;
        }
        .hero-search-wrap {
            width: 100%;
            max-width: 640px;
            animation: fadeSlideDown .75s .2s ease both;
        }
        .hero-search-bar {
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
        .hero-search-bar:focus-within {
            border-color: var(--c-primary-l);
            box-shadow: 0 8px 32px rgba(13,148,136,.15), 0 0 0 4px rgba(13,148,136,.08);
        }
        .hero-search-icon { color: var(--c-muted); flex-shrink: 0; }
        .hero-search-input {
            flex: 1;
            border: none;
            outline: none;
            font-family: var(--font);
            font-size: 1rem;
            color: var(--c-text);
            background: transparent;
        }
        .hero-search-input::placeholder { color: #94a3b8; }
        .hero-search-btn {
            background: linear-gradient(135deg, #058c63 0%, #0aaf7e 100%);
            color: #fff;
            border: none;
            padding: .7rem 1.5rem;
            border-radius: var(--r-pill);
            font-family: var(--font);
            font-size: .95rem;
            font-weight: 700;
            cursor: pointer;
            white-space: nowrap;
            transition: opacity var(--transition), transform var(--transition);
            box-shadow: 0 4px 14px rgba(5,140,99,.35);
        }
        .hero-search-btn:hover { opacity: .9; transform: translateY(-1px); }
        .hero-search-btn:active { transform: translateY(0); }
    </style>
</head>
<body>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <!-- BỘ ĐIỀU HƯỚNG / NAVBAR -->
    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
               <span>HIPZI</span>
            </a>
            <ul class="nav-links">

                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes" class="active">Lớp học</a></li>


                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
            </ul>
            
            <% if (user != null) { %>
                <div class="navbar-user-controls">
                    <!-- Khung Dropdown Thông báo hệ thống cao cấp -->
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                    <!-- Khung Avatar Người dùng kèm Dropdown Menu -->
                    <div class="nav-avatar-dropdown">
                        <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                            <% if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                <img src="<%= user.getAvatarUrl() %>" alt="Avatar">
                            <% } else { %>
                                <span class="nav-avatar-initials"><%= initials %></span>
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

    <!-- HERO LỚP HỌC -->
    <section class="page-hero">
        <div class="hero-kicker">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Hệ thống lớp học trực tuyến HIPZI
        </div>
        <h1 class="hero-title">
            Lớp học trực tuyến <span>tương tác &amp; hiệu quả</span>
        </h1>
        <p class="hero-subtitle">
            Hệ thống các lớp học chất lượng cao do giảng viên hàng đầu dẫn dắt, bám sát lộ trình và mục tiêu điểm số của bạn.
        </p>
        <div class="hero-search-wrap">
            <form action="${pageContext.request.contextPath}/classes" method="GET">
                <div class="hero-search-bar">
                    <svg class="hero-search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
                    <input type="text" name="q" class="hero-search-input" placeholder="Tìm kiếm lớp học, chủ đề, tên giảng viên..." value="${param.q}" autocomplete="off">
                    <input type="hidden" name="subject" value="${empty param.subject ? 'Tất cả' : param.subject}">
                    <input type="hidden" name="grade" value="${empty param.grade ? 'Tất cả' : param.grade}">
                    <button type="submit" class="hero-search-btn">Tìm kiếm</button>
                </div>
            </form>
        </div>
    </section>

    <!-- KHU VỰC NỘI DUNG CHÍNH (CONTENT AREA) -->
    <section id="content-area" class="repo-content <%= (request.getParameter("subject") == null && request.getParameter("q") == null) ? "animate-fade-up" : "" %>">
        <div class="repo-container layout-grid">
            
            <!-- SIDEBAR: BỘ LỌC CHÉO 2 CHIỀU CÓ STICKY HOÀN HẢO -->
            <aside class="sidebar-filters" style="position: sticky; top: 6rem; height: max-content; align-self: start;">
                <div class="filter-card">
                    <h3>Môn học</h3>
                    <ul class="subject-list classes-sidebar">
                        <style>
                            .classes-sidebar a.active { background-color: #059669 !important; color: #ffffff !important; font-weight: 600; border-radius: 8px; padding-left: 1rem !important; }
                            .classes-sidebar a.active::before { display: none; }
                            .search-btn { transition: all 0.2s ease !important; }
                            .search-btn:hover { background-color: #047857 !important; border-color: #047857 !important; box-shadow: 0 6px 16px rgba(5, 150, 105, 0.3) !important; }
                            .btn-full { transition: all 0.2s ease !important; }
                            .btn-full:hover { background-color: #047857 !important; border-color: #047857 !important; box-shadow: 0 6px 16px rgba(5, 150, 105, 0.3) !important; }
                        </style>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Tất cả&grade=${empty param.grade ? 'Tất cả' : param.grade}" 
                               class="${empty param.subject or param.subject eq 'Tất cả' ? 'active' : ''}">Tất cả môn học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Toán&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Toán' ? 'active' : ''}">Toán học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Văn&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Văn' ? 'active' : ''}">Ngữ Văn</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Anh&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Anh' ? 'active' : ''}">Tiếng Anh</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Lý&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Lý' ? 'active' : ''}">Vật Lý</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Hóa&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Hóa' ? 'active' : ''}">Hóa Học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Sinh Học&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Sinh Học' ? 'active' : ''}">Sinh Học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Lịch Sử&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Lịch Sử' ? 'active' : ''}">Lịch Sử</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Địa Lý&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Địa Lý' ? 'active' : ''}">Địa Lý</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Công Nghệ&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Công Nghệ' ? 'active' : ''}">Công Nghệ</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=Tin Học&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'Tin Học' ? 'active' : ''}">Tin Học</a>
                        </li>
                    </ul>
                </div>

                <div class="filter-card" style="margin-top: 1.5rem;">
                    <h3>Khối lớp</h3>
                    <ul class="subject-list classes-sidebar">
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Tất cả" 
                               class="${empty param.grade or param.grade eq 'Tất cả' ? 'active' : ''}">Tất cả các lớp</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Lớp 12"
                               class="${param.grade eq 'Lớp 12' ? 'active' : ''}">Lớp 12</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Lớp 11"
                               class="${param.grade eq 'Lớp 11' ? 'active' : ''}">Lớp 11</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Lớp 10"
                               class="${param.grade eq 'Lớp 10' ? 'active' : ''}">Lớp 10</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/classes?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Ôn thi THPT"
                               class="${param.grade eq 'Ôn thi THPT' ? 'active' : ''}">Ôn thi THPT</a>
                        </li>
                    </ul>
                </div>
            </aside>

            <!-- MAIN RESULTS -->
            <main class="main-results" id="materials-results">
                <div class="results-header">
                    <div class="sort-by" style="margin-left: auto;">
                        <select class="sort-select" aria-label="Lọc trạng thái lớp học">
                            <option>Tất cả</option>
                            <option>Đang mở</option>
                            <option>Sắp khai giảng</option>
                        </select>
                        <select class="sort-select" aria-label="Sắp xếp lớp học">
                            <option>Mới nhất</option>
                            <option>Đông học viên</option>
                        </select>
                    </div>
                </div>

                <div class="material-grid-wrapper">
                    <div class="material-grid">
                        <jsp:include page="/WEB-INF/fragments/classes-results.jsp" />
                    </div>
                </div>
            </main>
        </div>
    </section>

    <%@ include file="/WEB-INF/fragments/site-footer.jspf" %>

    <!-- KỊCH BẢN JAVASCRIPT HỖ TRỢ LỌC CHÉO AJAX HAI CHIỀU (TỐI ƯU) -->
    <script>
    (function () {
        var sidebarEl = document.querySelector('.sidebar-filters');
        var resultsEl = document.getElementById('materials-results');
        var gridEl = resultsEl ? resultsEl.querySelector('.material-grid') : null;
        var abortCtrl = null;

        function setLoading(isLoading) {
            if (!resultsEl) return;
            resultsEl.style.opacity = isLoading ? '0.45' : '1';
            resultsEl.style.pointerEvents = isLoading ? 'none' : 'auto';
        }

        function scrollToResultsHeader() {
            if (!resultsEl) return;
            var navbar = document.querySelector('.navbar');
            var navbarHeight = navbar ? navbar.getBoundingClientRect().height : 0;
            var top = resultsEl.getBoundingClientRect().top + window.pageYOffset - navbarHeight - 14;
            window.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
        }

        function applyTwoWayFilter(targetHref, isPopState, shouldScroll) {
            var targetUrl = new URL(targetHref, location.href);
            var currentUrl = new URL(location.href);

            var newSubject = targetUrl.searchParams.get('subject') || currentUrl.searchParams.get('subject') || 'Tất cả';
            var newGrade   = targetUrl.searchParams.get('grade')   || currentUrl.searchParams.get('grade')   || 'Tất cả';
            var q          = currentUrl.searchParams.get('q') || '';

            // Cập nhật trạng thái active sidebar ngay lập tức (không cần chờ server)
            updateSidebarActive(newSubject, newGrade, q);

            var fetchUrl = new URL(location.pathname, location.href);
            fetchUrl.searchParams.set('subject', newSubject);
            fetchUrl.searchParams.set('grade', newGrade);
            if (q) fetchUrl.searchParams.set('q', q);
            fetchUrl.searchParams.set('ajax', '1'); // Chỉ lấy fragment kết quả, không tải cả trang

            if (!isPopState) {
                var pushUrl = new URL(fetchUrl.toString());
                pushUrl.searchParams.delete('ajax');
                history.pushState(null, '', pushUrl.toString());
            }

            // Hủy request cũ nếu đang chạy
            if (abortCtrl) abortCtrl.abort();
            abortCtrl = new AbortController();

            setLoading(true);

            fetch(fetchUrl.toString(), { signal: abortCtrl.signal })
                .then(function (res) { return res.text(); })
                .then(function (html) {
                    if (gridEl) gridEl.innerHTML = html; // Gán trực tiếp, không cần DOMParser
                    setLoading(false);
                    if (shouldScroll) {
                        requestAnimationFrame(scrollToResultsHeader);
                    }
                    abortCtrl = null;
                })
                .catch(function (err) {
                    if (err.name !== 'AbortError') setLoading(false);
                });
        }

        function updateSidebarActive(newSubject, newGrade, q) {
            if (!sidebarEl) return;
            var subjectCard = sidebarEl.querySelectorAll('.filter-card')[0];
            if (subjectCard) {
                subjectCard.querySelectorAll('a').forEach(function(a) {
                    var aUrl = new URL(a.href, location.href);
                    var thisSubject = aUrl.searchParams.get('subject') || 'Tất cả';
                    var updatedUrl = new URL(location.pathname, location.href);
                    updatedUrl.searchParams.set('subject', thisSubject);
                    updatedUrl.searchParams.set('grade', newGrade);
                    if (q) updatedUrl.searchParams.set('q', q);
                    a.href = updatedUrl.toString();
                    a.classList.toggle('active', thisSubject.toLowerCase() === newSubject.toLowerCase());
                });
            }
            var gradeCard = sidebarEl.querySelectorAll('.filter-card')[1];
            if (gradeCard) {
                gradeCard.querySelectorAll('a').forEach(function(a) {
                    var aUrl = new URL(a.href, location.href);
                    var thisGrade = aUrl.searchParams.get('grade') || 'Tất cả';
                    var updatedUrl = new URL(location.pathname, location.href);
                    updatedUrl.searchParams.set('subject', newSubject);
                    updatedUrl.searchParams.set('grade', thisGrade);
                    if (q) updatedUrl.searchParams.set('q', q);
                    a.href = updatedUrl.toString();
                    a.classList.toggle('active', thisGrade.toLowerCase() === newGrade.toLowerCase());
                });
            }
        }

        document.addEventListener('click', function (e) {
            var link = e.target.closest('.classes-sidebar a');
            if (!link) return;
            e.preventDefault();
            applyTwoWayFilter(link.href, false, true);
        });

        window.addEventListener('popstate', function () {
            applyTwoWayFilter(location.href, true, true);
        });
    })();
    </script>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
