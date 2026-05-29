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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=3">
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
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes" class="active">Lớp học</a></li>
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

    <!-- HEADER LỚP HỌC (SẮC TÍM HOÀNG GIA RỰC RỠ) -->
    <section class="repo-header">
        <div class="repo-container">
            <h1>Lớp học trực tuyến & Tương tác</h1>
            <p>Hệ thống các lớp học chất lượng cao do Giảng viên hàng đầu dẫn dắt, bám sát lộ trình và mục tiêu điểm số.</p>
            
            <!-- THANH TÌM KIẾM TRUNG TÂM -->
            <div class="search-bar-wrapper" style="max-width: 650px; margin: 2rem auto 0 auto;">
                <form action="${pageContext.request.contextPath}/classes" method="GET" class="search-bar" style="background: #ffffff; padding: 0.5rem 0.5rem 0.5rem 1.5rem; border-radius: 100px; display: flex; align-items: center; box-shadow: 0 10px 25px rgba(109, 40, 217, 0.2);">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" name="q" class="search-input" placeholder="Tìm kiếm lớp học, chủ đề, tên giảng viên..." value="${param.q}" style="border: none; outline: none; width: 100%; margin-left: 0.75rem; font-size: 1rem;" />
                    <input type="hidden" name="subject" value="${empty param.subject ? 'Tất cả' : param.subject}" />
                    <input type="hidden" name="grade" value="${empty param.grade ? 'Tất cả' : param.grade}" />
                    <button type="submit" class="btn btn-primary search-btn" style="background: #8b5cf6; border-color: #8b5cf6; border-radius: 100px; font-weight: 600;">Tìm kiếm</button>
                </form>
            </div>
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
                            .classes-sidebar a.active { background-color: #8b5cf6 !important; color: #ffffff !important; font-weight: 600; border-radius: 8px; padding-left: 1rem !important; }
                            .classes-sidebar a.active::before { display: none; }
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
                            <a href="${pageContext.request.contextPath}/classes?subject=GDCD&grade=${empty param.grade ? 'Tất cả' : param.grade}"
                               class="${param.subject eq 'GDCD' ? 'active' : ''}">Giáo dục Công dân</a>
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
                    </ul>
                </div>
            </aside>

            <!-- MAIN RESULTS -->
            <main class="main-results" id="materials-results">
                <div class="results-header">
                    <h2>Lớp học ${not empty param.subject and param.subject ne 'Tất cả' ? param.subject : 'nổi bật'}</h2>
                    <div class="sort-by" style="display: flex; gap: 0.75rem;">
                        <select class="sort-select" style="border-color: #ede9fe;">
                            <option>Đang tuyển sinh</option>
                            <option>Khai giảng gần đây</option>
                            <option>Đông học viên</option>
                        </select>
                    </div>
                </div>

                <div class="material-grid">
                    <% 
                        List<Classroom> classrooms = (List<Classroom>) request.getAttribute("classrooms");
                        if (classrooms == null || classrooms.isEmpty()) { 
                    %>
                            <div class="empty-state">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                <h3>Không tìm thấy lớp học</h3>
                                <p>Hiện chưa có lớp học nào phù hợp với tiêu chí lọc. Hãy thử chọn môn học hoặc khối lớp khác.</p>
                            </div>
                    <% 
                        } else { 
                            for (Classroom cls : classrooms) {
                                String statusLabel = cls.getStatusLabel();
                    %>
                                <div class="material-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                                    <div>
                                        <div class="material-card-header" style="margin-bottom: 0.75rem;">
                                            <span class="subject-badge" style="background: #ede9fe; color: #8b5cf6;"><%= cls.getSubject() %></span>
                                            <span style="font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 12px; background-color: <%= "Đang mở".equalsIgnoreCase(statusLabel) ? "#dcfce7" : "#fef9c3" %>; color: <%= "Đang mở".equalsIgnoreCase(statusLabel) ? "#15803d" : "#a16207" %>;">
                                                <%= statusLabel %>
                                            </span>
                                        </div>
                                        <h3 class="material-title" style="font-size: 1.15rem; margin-bottom: 0.5rem;"><%= cls.getTitle() %></h3>
                                        <p class="teacher-name" style="font-weight: 600; color: #334155; margin-bottom: 0.25rem;"><%= cls.getTeacherName() %></p>
                                        <p style="font-size: 0.85rem; color: #64748b; margin-bottom: 1rem;"><%= cls.getTeacherSchool() %></p>
                                        
                                        <div style="background: #f8fafc; padding: 0.75rem; border-radius: 8px; margin-bottom: 1.25rem; font-size: 0.85rem; color: #475569;">
                                            <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.25rem;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                                <span>Lịch: <strong><%= cls.getSchedule() %></strong></span>
                                            </div>
                                            <div style="display: flex; align-items: center; gap: 0.5rem;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#8b5cf6" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                                                <span>Sĩ số: <strong><%= cls.getStudentCount() %> học viên</strong></span>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="material-card-footer" style="padding: 0; border: none;">
                                        <a href="<%= request.getContextPath() %>/class-detail?id=<%= cls.getId() %>" class="btn btn-primary btn-full" style="background: #8b5cf6; border-color: #8b5cf6; color: #ffffff; font-weight: 600; border-radius: 9999px;">Tham gia lớp</a>
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

    <!-- CHÂN TRANG / FOOTER -->
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
                            <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                            <li><a href="${pageContext.request.contextPath}/classes">Lớp học trực tuyến</a></li>
                            <li><a href="${pageContext.request.contextPath}/practice">Luyện tập</a></li>
                        </ul>
                    </div>
                    <div class="footer-links-col">
                        <h4>Giảng viên</h4>
                        <ul>
                            <li><a href="${pageContext.request.contextPath}/register.jsp">Đăng ký giảng dạy</a></li>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Quy định tải lên</a></li>
                        </ul>
                    </div>
                    <div class="footer-links-col">
                        <h4>Hỗ trợ</h4>
                        <ul>
                            <li><a href="#">Liên hệ</a></li>
                            <li><a href="#">Bảo mật</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="footer-bottom-bar">
                <div class="footer-copyright">&copy; 2026 HIPZI Platform. Bản quyền được bảo hộ.</div>
            </div>
        </div>
    </footer>

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

        function applyTwoWayFilter(targetHref, isPopState) {
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
            applyTwoWayFilter(link.href, false);
        });

        window.addEventListener('popstate', function () {
            applyTwoWayFilter(location.href, true);
        });
    })();
    </script>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
</body>
</html>
