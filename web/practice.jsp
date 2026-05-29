<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Quiz"%>
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
    String subjectTitle = request.getParameter("subject");
    boolean hasSubjectTitle = subjectTitle != null && !subjectTitle.trim().isEmpty() && !"Tất cả".equals(subjectTitle.trim());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Luyện tập - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="dns-prefetch" href="//fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/materials.css">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
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
                <li><a href="${pageContext.request.contextPath}/practice" class="active">Luyện tập</a></li>
                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
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

    <section class="repo-header">
        <div class="repo-container">
            <h1>Luyện tập Quizlet & Flashcard</h1>
            <p>Ôn tập nhanh bằng bộ câu hỏi ngắn và thẻ ghi nhớ, tìm theo chủ đề, môn học hoặc tên giảng viên.</p>

            <div class="search-bar">
                <form action="${pageContext.request.contextPath}/practice" method="GET">
                    <div class="search-input-wrapper">
                        <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                        <input type="text" name="q" placeholder="Tìm kiếm Quizlet, Flashcard, chủ đề, tên giảng viên..." class="search-input" value="${param.q}">
                        <input type="hidden" name="subject" value="${empty param.subject ? 'Tất cả' : param.subject}">
                        <input type="hidden" name="grade" value="${empty param.grade ? 'Tất cả' : param.grade}">
                        <input type="hidden" name="type" value="${empty param.type ? 'Tất cả' : param.type}">
                        <button type="submit" class="btn btn-primary search-btn" style="background: var(--color-secondary, #f0a928); border-color: var(--color-secondary, #f0a928);">Tìm kiếm</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <section id="content-area" class="repo-content <%= (request.getParameter("subject") == null && request.getParameter("q") == null) ? "animate-fade-up" : "" %>">
        <div class="repo-container layout-grid">
            <aside class="sidebar-filters" style="position: sticky; top: 6rem; height: max-content; align-self: start;">
                <div class="filter-card">
                    <h3>Môn học</h3>
                    <ul class="subject-list practice-sidebar">
                        <style>
                            .practice-sidebar a.active { background-color: var(--color-secondary, #f0a928) !important; color: #ffffff !important; font-weight: 600; border-radius: 8px; padding-left: 1rem !important; }
                            .practice-sidebar a.active::before { display: none; }
                        </style>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Tất cả&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${empty param.subject or param.subject eq 'Tất cả' ? 'active' : ''}">Tất cả môn học</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Toán&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Toán' ? 'active' : ''}">Toán học</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Văn&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Văn' ? 'active' : ''}">Ngữ Văn</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Anh&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Anh' ? 'active' : ''}">Tiếng Anh</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Lý&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Lý' ? 'active' : ''}">Vật Lý</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Hóa&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Hóa' ? 'active' : ''}">Hóa Học</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Sinh Học&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Sinh Học' ? 'active' : ''}">Sinh Học</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Lịch Sử&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Lịch Sử' ? 'active' : ''}">Lịch Sử</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Địa Lý&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Địa Lý' ? 'active' : ''}">Địa Lý</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=GDCD&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'GDCD' ? 'active' : ''}">Giáo dục Công dân</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=Tin Học&grade=${empty param.grade ? 'Tất cả' : param.grade}&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.subject eq 'Tin Học' ? 'active' : ''}">Tin Học</a></li>
                    </ul>
                </div>

                <div class="filter-card" style="margin-top: 1.5rem;">
                    <h3>Khối lớp</h3>
                    <ul class="subject-list practice-sidebar">
                        <li><a href="${pageContext.request.contextPath}/practice?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Tất cả&type=${empty param.type ? 'Tất cả' : param.type}" class="${empty param.grade or param.grade eq 'Tất cả' ? 'active' : ''}">Tất cả các lớp</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Lớp 12&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.grade eq 'Lớp 12' ? 'active' : ''}">Lớp 12</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Lớp 11&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.grade eq 'Lớp 11' ? 'active' : ''}">Lớp 11</a></li>
                        <li><a href="${pageContext.request.contextPath}/practice?subject=${empty param.subject ? 'Tất cả' : param.subject}&grade=Lớp 10&type=${empty param.type ? 'Tất cả' : param.type}" class="${param.grade eq 'Lớp 10' ? 'active' : ''}">Lớp 10</a></li>
                    </ul>
                </div>
            </aside>

            <main class="main-results" id="materials-results">
                <div class="results-header">
                    <h2>Học phần <%= hasSubjectTitle ? h(subjectTitle) : "mới nhất" %></h2>
                    <div class="sort-by" style="display: flex; gap: 0.75rem;">
                        <select id="type-select" class="sort-select" style="border-color: var(--color-secondary-soft, #fff4cc);">
                            <option value="Tất cả" ${empty param.type or param.type eq 'Tất cả' ? 'selected' : ''}>Tất cả hình thức</option>
                            <option value="Quizlet" ${param.type eq 'Quizlet' ? 'selected' : ''}>Quizlet</option>
                            <option value="Flashcard" ${param.type eq 'Flashcard' ? 'selected' : ''}>Flashcard</option>
                        </select>
                        <select class="sort-select">
                            <option>Mới nhất</option>
                            <option>Học nhiều nhất</option>
                            <option>Đánh giá cao</option>
                        </select>
                    </div>
                </div>

                <div class="material-grid">
                    <%
                        List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
                        if (quizzes == null || quizzes.isEmpty()) {
                    %>
                            <div class="empty-state">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
                                <h3>Chưa có học phần phù hợp</h3>
                                <p>Hãy thử đổi môn học, khối lớp, hình thức hoặc từ khóa tìm kiếm.</p>
                            </div>
                    <%
                        } else {
                            for (Quiz quiz : quizzes) {
                    %>
                                <div class="material-card">
                                    <div class="material-card-header">
                                        <span class="subject-badge" style="background: var(--color-secondary-soft, #fff4cc); color: var(--color-secondary, #f0a928);"><%= h(quiz.getSubject()) %></span>
                                        <span class="view-count">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                            <%= quiz.getAttemptCount() %> lượt học
                                        </span>
                                    </div>
                                    <div class="material-card-body">
                                        <div style="margin-bottom: 0.5rem;">
                                            <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 700; background-color:#fff4cc; color:#b27b00;"><%= h(quiz.getType()) %></span>
                                            <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 700; background-color:#ecfdf5; color:#047857; margin-left:0.35rem;"><%= h(quiz.getGrade()) %></span>
                                        </div>
                                        <h3 class="material-title"><%= h(quiz.getTitle()) %></h3>
                                        <p class="teacher-name">GV: <%= h(quiz.getTeacherName()) %></p>
                                        <p class="teacher-name">Độ khó: <%= h(quiz.getDifficulty()) %> • <%= quiz.getQuestionCount() %> thẻ/câu hỏi</p>
                                    </div>
                                    <div class="material-card-footer">
                                        <a href="<%= request.getContextPath() %>/login.jsp" class="btn btn-primary btn-full" style="background: var(--color-secondary, #f0a928); border-color: var(--color-secondary, #f0a928); color: #ffffff; font-weight: 600; border-radius: 9999px;">Bắt đầu học</a>
                                    </div>
                                </div>
                    <%
                            }
                        }
                    %>
                </div>
            </main>
        </div>
    </section>

    <footer class="footer">
        <div class="footer-card">
            <div class="footer-watermark">HIPZI</div>
            <div class="footer-top-grid">
                <div class="footer-brand-col">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="footer-logo">HIP<span>ZI</span></a>
                    <p class="footer-desc">Nền tảng giáo dục thông minh kết hợp tài liệu học tập, luyện tập tương tác và công nghệ AI nhằm tối ưu hóa hành trình tri thức của bạn.</p>
                </div>
                <div class="footer-links-wrapper">
                    <div class="footer-links-col">
                        <h4>Học viên</h4>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/material-repository">Tìm kiếm tài liệu</a></li>
                            <li><a href="${pageContext.request.contextPath}/practice">Luyện tập Quizlet</a></li>
                            <li><a href="${pageContext.request.contextPath}/practice?type=Flashcard">Bộ thẻ Flashcard</a></li>
                        </ul>
                    </div>
                    <div class="footer-links-col">
                        <h4>Giảng viên</h4>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/register.jsp">Đăng ký giảng dạy</a></li>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Công cụ AI</a></li>
                        </ul>
                    </div>
                    <div class="footer-links-col">
                        <h4>Về HIPZI</h4>
                        <ul>
                            <li><a href="#">Quy tắc bảo mật</a></li>
                            <li><a href="#">Điều khoản sử dụng</a></li>
                            <li><a href="#">Hỗ trợ & Liên hệ</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="footer-bottom-bar">
                <div class="footer-copyright">&copy; 2026 HIPZI Platform. Bản quyền được bảo hộ.</div>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
    <script>
    (function () {
        var resultsEl = document.getElementById('materials-results');
        var gridEl = resultsEl ? resultsEl.querySelector('.material-grid') : null;
        var sidebarEl = document.querySelector('.sidebar-filters');
        var abortCtrl = null;

        function setLoading(on) {
            if (!resultsEl) return;
            resultsEl.style.opacity = on ? '0.45' : '1';
            resultsEl.style.pointerEvents = on ? 'none' : '';
        }

        function applyTwoWayFilter(targetUrlStr, isPopState) {
            var targetUrl = new URL(targetUrlStr, location.href);
            var currentUrl = new URL(location.href);
            var newSubject = targetUrl.searchParams.get('subject') || currentUrl.searchParams.get('subject') || 'T\u1ea5t c\u1ea3';
            var newGrade   = targetUrl.searchParams.get('grade')   || currentUrl.searchParams.get('grade')   || 'T\u1ea5t c\u1ea3';
            var newType    = targetUrl.searchParams.get('type')    || currentUrl.searchParams.get('type')    || 'T\u1ea5t c\u1ea3';
            var q          = currentUrl.searchParams.get('q') || '';

            // C\u1eadp nh\u1eadt sidebar active ngay l\u1eadp t\u1ee9c
            updateSidebarActive(newSubject, newGrade, newType, q);

            var fetchUrl = new URL(location.pathname, location.href);
            fetchUrl.searchParams.set('subject', newSubject);
            fetchUrl.searchParams.set('grade', newGrade);
            fetchUrl.searchParams.set('type', newType);
            if (q) fetchUrl.searchParams.set('q', q);
            fetchUrl.searchParams.set('ajax', '1');

            if (!isPopState) {
                var pushUrl = new URL(fetchUrl.toString());
                pushUrl.searchParams.delete('ajax');
                history.pushState(null, '', pushUrl.toString());
            }

            if (abortCtrl) abortCtrl.abort();
            abortCtrl = new AbortController();
            setLoading(true);

            fetch(fetchUrl.toString(), { signal: abortCtrl.signal })
                .then(function (res) { return res.text(); })
                .then(function (html) {
                    if (gridEl) gridEl.innerHTML = html;
                    var typeSelect = document.getElementById('type-select');
                    if (typeSelect) { typeSelect.value = newType; attachTypeSelectEvent(); }
                    setLoading(false);
                    abortCtrl = null;
                })
                .catch(function (err) { if (err.name !== 'AbortError') setLoading(false); });
        }

        function updateSidebarActive(newSubject, newGrade, newType, q) {
            if (!sidebarEl) return;
            var cards = sidebarEl.querySelectorAll('.filter-card');
            if (cards[0]) {
                cards[0].querySelectorAll('a').forEach(function(a) {
                    var aUrl = new URL(a.href, location.href);
                    var thisSubject = aUrl.searchParams.get('subject') || 'T\u1ea5t c\u1ea3';
                    var updatedUrl = new URL(location.pathname, location.href);
                    updatedUrl.searchParams.set('subject', thisSubject);
                    updatedUrl.searchParams.set('grade', newGrade);
                    updatedUrl.searchParams.set('type', newType);
                    if (q) updatedUrl.searchParams.set('q', q);
                    a.href = updatedUrl.toString();
                    a.classList.toggle('active', thisSubject.toLowerCase() === newSubject.toLowerCase());
                });
            }
            if (cards[1]) {
                cards[1].querySelectorAll('a').forEach(function(a) {
                    var aUrl = new URL(a.href, location.href);
                    var thisGrade = aUrl.searchParams.get('grade') || 'T\u1ea5t c\u1ea3';
                    var updatedUrl = new URL(location.pathname, location.href);
                    updatedUrl.searchParams.set('subject', newSubject);
                    updatedUrl.searchParams.set('grade', thisGrade);
                    updatedUrl.searchParams.set('type', newType);
                    if (q) updatedUrl.searchParams.set('q', q);
                    a.href = updatedUrl.toString();
                    a.classList.toggle('active', thisGrade.toLowerCase() === newGrade.toLowerCase());
                });
            }
        }

        document.addEventListener('click', function (e) {
            var link = e.target.closest('.subject-list a');
            if (!link) return;
            e.preventDefault();
            applyTwoWayFilter(link.href, false);
        });

        function attachTypeSelectEvent() {
            var el = document.getElementById('type-select');
            if (el && !el.dataset.hasEvent) {
                el.dataset.hasEvent = 'true';
                el.addEventListener('change', function () {
                    var url = new URL(location.href);
                    url.searchParams.set('type', this.value);
                    applyTwoWayFilter(url.toString(), false);
                });
            }
        }

        attachTypeSelectEvent();
        window.addEventListener('popstate', function () { applyTwoWayFilter(location.href, true); });
    })();
    </script>
</body>
</html>
