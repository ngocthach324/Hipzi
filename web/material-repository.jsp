<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Material"%>
<%@page import="com.hipzi.model.User"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String formatFileSize(long size) {
        if (size <= 0) return "";
        double kb = size / 1024.0;
        if (kb < 1024) return String.format(java.util.Locale.US, "%.0f KB", kb);
        return String.format(java.util.Locale.US, "%.1f MB", kb / 1024.0);
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    String currentSort = (String) request.getAttribute("currentSort");
    if (currentSort == null || currentSort.isEmpty()) currentSort = "newest";
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
    <title>Kho tài liệu - HIPZI</title>
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

    <!-- BỘ ĐIỀU HƯỚNG / NAVBAR -->
    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
               <span>HIPZI</span>
            </a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository" class="active">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/practice">Luyện tập</a></li>
                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index.jsp#ai-roadmap">Hipzi AI</a></li>
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

    <!-- HEADER KHO TÀI LIỆU -->
    <section class="repo-header">
        <div class="repo-container">
            <h1>Khám phá Kho Tài Liệu HIPZI</h1>
            <p>Hàng ngàn tài liệu chất lượng cao từ các giảng viên uy tín, được phân loại theo môn học để bạn dễ dàng tra cứu.</p>
            
            <div class="search-bar">
                <form action="${pageContext.request.contextPath}/material-repository" method="GET">
                    <div class="search-input-wrapper">
                        <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                        <input type="text" name="q" placeholder="Tìm kiếm tài liệu, chủ đề, tên giảng viên..." class="search-input" value="${param.q}">
                        <input type="hidden" name="subject" value="${currentSubject}">
                        <input type="hidden" name="grade" value="${currentGrade}">
                        <input type="hidden" name="type" value="${currentType}">
                        <input type="hidden" name="sort" value="${currentSort}">
                        <button type="submit" class="btn btn-primary search-btn">Tìm kiếm</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <!-- CONTENT KHO TÀI LIỆU -->
    <section id="content-area" class="repo-content <%= (request.getParameter("subject") == null && request.getParameter("q") == null) ? "animate-fade-up" : "" %>">
        <div class="repo-container layout-grid">
            
            <!-- SIDEBAR: BỘ LỌC -->
            <aside class="sidebar-filters" style="position: sticky; top: 6rem; height: max-content; align-self: start;">
                <div class="filter-card">
                    <h3>Môn học</h3>
                    <ul class="subject-list">
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Tất cả&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area" 
                               class="${currentSubject eq 'Tất cả' ? 'active' : ''}">Tất cả môn học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Toán&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Toán' ? 'active' : ''}">Toán học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Văn&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Văn' ? 'active' : ''}">Ngữ Văn</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Anh&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Anh' ? 'active' : ''}">Tiếng Anh</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Lý&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Lý' ? 'active' : ''}">Vật Lý</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Hóa&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Hóa' ? 'active' : ''}">Hóa Học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Sinh Học&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Sinh Học' ? 'active' : ''}">Sinh Học</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Lịch Sử&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Lịch Sử' ? 'active' : ''}">Lịch Sử</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Địa Lý&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Địa Lý' ? 'active' : ''}">Địa Lý</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=GDCD&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'GDCD' ? 'active' : ''}">Giáo dục Công dân</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Tin Học&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Tin Học' ? 'active' : ''}">Tin Học</a>
                        </li>
                    </ul>
                </div>

                <div class="filter-card" style="margin-top: 1.5rem;">
                    <h3>Khối lớp</h3>
                    <ul class="subject-list">
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=${empty currentSubject ? 'Tất cả' : currentSubject}&grade=Tất cả&type=${empty currentType ? 'Tất cả' : currentType}#content-area" 
                               class="${currentGrade eq 'Tất cả' ? 'active' : ''}">Tất cả các lớp</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=${empty currentSubject ? 'Tất cả' : currentSubject}&grade=Lớp 12&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentGrade eq 'Lớp 12' ? 'active' : ''}">Lớp 12</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=${empty currentSubject ? 'Tất cả' : currentSubject}&grade=Lớp 11&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentGrade eq 'Lớp 11' ? 'active' : ''}">Lớp 11</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=${empty currentSubject ? 'Tất cả' : currentSubject}&grade=Lớp 10&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentGrade eq 'Lớp 10' ? 'active' : ''}">Lớp 10</a>
                        </li>
                    </ul>
                </div>
            </aside>

            <!-- MAIN RESULTS -->
            <main class="main-results" id="materials-results">
                <div class="results-header">
                    <h2>Tài liệu ${currentSubject ne 'Tất cả' ? currentSubject : 'mới nhất'}</h2>
                    <div class="sort-by" style="display: flex; gap: 0.75rem;">
                        <select id="type-select" class="sort-select">
                            <option value="Tất cả" ${currentType eq 'Tất cả' ? 'selected' : ''}>Tất cả loại</option>
                            <option value="Lý thuyết" ${currentType eq 'Lý thuyết' ? 'selected' : ''}>Lý thuyết</option>
                            <option value="Đề ôn tập" ${currentType eq 'Đề ôn tập' ? 'selected' : ''}>Đề ôn tập</option>
                        </select>
                        <select id="sort-select" class="sort-select">
                            <option value="newest" <%= "newest".equals(currentSort) ? "selected" : "" %>>Mới nhất</option>
                            <option value="views" <%= "views".equals(currentSort) ? "selected" : "" %>>Xem nhiều nhất</option>
                            <option value="rating" <%= "rating".equals(currentSort) ? "selected" : "" %>>Đánh giá cao</option>
                        </select>
                    </div>
                </div>

                <div class="material-grid">
                    <% 
                        List<Material> materials = (List<Material>) request.getAttribute("materials");
                        if (materials == null || materials.isEmpty()) { 
                    %>
                            <div class="empty-state">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
                                <h3>Không tìm thấy tài liệu</h3>
                                <p>Chưa có tài liệu nào cho môn học này. Hãy thử tìm kiếm với từ khóa khác.</p>
                            </div>
                    <% 
                        } else { 
                            for (Material material : materials) {
                    %>
                                <div class="material-card">
                                    <div class="material-card-header">
                                        <span class="subject-badge"><%= h(material.getSubject()) %></span>
                                        <span class="view-count">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                            <%= material.getViewCount() %>
                                        </span>
                                    </div>
                                    <div class="material-card-body">
                                        <div style="margin-bottom: 0.5rem;">
                                            <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 500; background-color: <%= "Đề ôn tập".equalsIgnoreCase(material.getType()) ? "#fff4cc" : "#e8f2ff" %>; color: <%= "Đề ôn tập".equalsIgnoreCase(material.getType()) ? "#b27b00" : "#0052cc" %>;">
                                                <%= h(material.getType() != null ? material.getType() : "Lý thuyết") %>
                                            </span>
                                            <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 500; background-color:#ecfdf5; color:#047857; margin-left:0.35rem;"><%= h(material.getGrade()) %></span>
                                        </div>
                                        <h3 class="material-title"><%= h(material.getTitle()) %></h3>
                                        <% if (material.getDescription() != null && !material.getDescription().isEmpty()) { %>
                                            <p style="color:#64748b; font-size:0.85rem; line-height:1.55; margin:0.45rem 0 0 0;"><%= h(material.getDescription()) %></p>
                                        <% } %>
                                        <p class="teacher-name">GV: <%= h(material.getTeacherName() != null && !material.getTeacherName().isEmpty() ? material.getTeacherName() : "HIPZI Teacher") %></p>
                                        <p style="color:#94a3b8; font-size:0.78rem; margin:0.35rem 0 0 0;">
                                            <%= h(material.getOriginalFileName()) %>
                                            <% if (material.getFileSize() > 0) { %>
                                                · <%= formatFileSize(material.getFileSize()) %>
                                            <% } %>
                                        </p>
                                        <% if (material.getRatingCount() > 0) { %>
                                            <p style="color:#d97706; font-size:0.8rem; font-weight:700; margin:0.35rem 0 0 0;">★ <%= String.format(java.util.Locale.US, "%.1f", material.getRatingAverage()) %> (<%= material.getRatingCount() %> đánh giá)</p>
                                        <% } %>
                                    </div>
                                    <div class="material-card-footer">
                                        <a href="<%= request.getContextPath() %>/repository-material-preview?id=<%= h(material.getId()) %>" target="_blank" rel="noopener" class="btn btn-primary btn-full" style="border-radius: 9999px; font-weight: 600;">Xem tài liệu</a>
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

    <!-- CHÂN TRANG / FOOTER (Similar to index) -->
    <footer class="footer">
        <div class="footer-card">
            <!-- Giant Watermark Background Text -->
            <div class="footer-watermark">HIPZI</div>

            <!-- Top Content Grid -->
            <div class="footer-top-grid">
                <!-- Brand Info & Socials -->
                <div class="footer-brand-col">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="footer-logo">
                        HIP<span>ZI</span>
                    </a>
                    <p class="footer-desc">Nền tảng giáo dục thông minh kết hợp tài liệu học tập, luyện tập tương tác và công nghệ AI nhằm tối ưu hóa hành trình tri thức của bạn.</p>
                    
                    <!-- Social Link Circles -->
                    <div class="footer-socials">
                        <a href="#" class="social-btn" title="X / Twitter">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="4" y1="4" x2="20" y2="20"></line>
                                <line x1="20" y1="4" x2="4" y2="20"></line>
                            </svg>
                        </a>
                        <a href="#" class="social-btn" title="Facebook">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"></path>
                            </svg>
                        </a>
                        <a href="#" class="social-btn" title="Instagram">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect>
                                <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path>
                                <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line>
                            </svg>
                        </a>
                        <a href="#" class="social-btn" title="LinkedIn">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"></path>
                                <rect x="2" y="9" width="4" height="12"></rect>
                                <circle cx="4" cy="4" r="2"></circle>
                            </svg>
                        </a>
                    </div>
                </div>

                <!-- Navigation Columns Wrapper -->
                <div class="footer-links-wrapper">
                    <!-- Column 1 -->
                    <div class="footer-links-col">
                        <h4>Học viên</h4>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/material-repository">Tìm kiếm tài liệu</a></li>
                            <li><a href="${pageContext.request.contextPath}/practice">Luyện tập Trắc nghiệm</a></li>
                            <li><a href="${pageContext.request.contextPath}/practice">Bộ thẻ Flashcard</a></li>
                        </ul>
                    </div>

                    <!-- Column 2 -->
                    <div class="footer-links-col">
                        <h4>Giảng viên</h4>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/register.jsp">Đăng ký giảng dạy</a></li>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Quy định tải lên</a></li>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Công cụ AI</a></li>
                        </ul>
                    </div>

                    <!-- Column 3 -->
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

            <!-- Bottom Legal Inline Bar -->
            <div class="footer-bottom-bar">
                <div class="footer-copyright">
                    &copy; 2026 HIPZI Platform. Bản quyền được bảo hộ.
                </div>
                <div class="footer-legal-links">
                    <a href="#">Chính Sách Bảo Mật</a>
                    <a href="#">Điều Khoản Dịch Vụ</a>
                    <a href="#">Cài Đặt Cookie</a>
                    </div>
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
            var newSort    = targetUrl.searchParams.get('sort')    || currentUrl.searchParams.get('sort')    || 'newest';
            var q          = currentUrl.searchParams.get('q') || '';

            // Cập nhật sidebar active ngay lập tức
            updateSidebarActive(newSubject, newGrade, newType, newSort, q);

            var fetchUrl = new URL(location.pathname, location.href);
            fetchUrl.searchParams.set('subject', newSubject);
            fetchUrl.searchParams.set('grade', newGrade);
            fetchUrl.searchParams.set('type', newType);
            fetchUrl.searchParams.set('sort', newSort);
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
                    // Đồng bộ select sau khi render
                    var typeSelect = document.getElementById('type-select');
                    if (typeSelect) { typeSelect.value = newType; attachTypeSelectEvent(); }
                    var sortSelect = document.getElementById('sort-select');
                    if (sortSelect) { sortSelect.value = newSort; attachSortSelectEvent(); }
                    setLoading(false);
                    abortCtrl = null;
                })
                .catch(function (err) { if (err.name !== 'AbortError') setLoading(false); });
        }

        function updateSidebarActive(newSubject, newGrade, newType, newSort, q) {
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
                    updatedUrl.searchParams.set('sort', newSort);
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
                    updatedUrl.searchParams.set('sort', newSort);
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
        function attachSortSelectEvent() {
            var el = document.getElementById('sort-select');
            if (el && !el.dataset.hasEvent) {
                el.dataset.hasEvent = 'true';
                el.addEventListener('change', function () {
                    var url = new URL(location.href);
                    url.searchParams.set('sort', this.value);
                    applyTwoWayFilter(url.toString(), false);
                });
            }
        }

        attachTypeSelectEvent();
        attachSortSelectEvent();
        window.addEventListener('popstate', function () { applyTwoWayFilter(location.href, true); });
    })();
    </script>
</body>
</html>
