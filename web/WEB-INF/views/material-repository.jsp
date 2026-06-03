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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/materials.css">
    <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
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
                <li><a href="${pageContext.request.contextPath}/index">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository" class="active">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>

                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
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
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Công Nghệ&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Công Nghệ' ? 'active' : ''}">Công Nghệ</a>
                        </li>
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=Tin Học&grade=${empty currentGrade ? 'Tất cả' : currentGrade}&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentSubject eq 'Tin Học' ? 'active' : ''}">Tin Học</a>
                        </li>
                    </ul>
                </div>

                <div class="filter-card" style="margin-top: 1rem;">
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
                        <li>
                            <a href="${pageContext.request.contextPath}/material-repository?subject=${empty currentSubject ? 'Tất cả' : currentSubject}&grade=Ôn thi THPT&type=${empty currentType ? 'Tất cả' : currentType}#content-area"
                               class="${currentGrade eq 'Ôn thi THPT' ? 'active' : ''}">Ôn thi THPT</a>
                        </li>
                    </ul>
                </div>
            </aside>

            <!-- MAIN RESULTS -->
            <main class="main-results" id="materials-results">
                <div class="results-header">
                    <div class="sort-by" style="margin-left: auto;">
                        <select id="type-select" class="sort-select" aria-label="Lọc theo loại tài liệu">
                            <option value="Tất cả" ${currentType eq 'Tất cả' ? 'selected' : ''}>Tất cả loại</option>
                            <option value="Lý thuyết" ${currentType eq 'Lý thuyết' ? 'selected' : ''}>Lý thuyết</option>
                            <option value="Đề ôn tập" ${currentType eq 'Đề ôn tập' ? 'selected' : ''}>Đề ôn tập</option>
                        </select>
                        <select id="sort-select" class="sort-select" aria-label="Sắp xếp tài liệu">
                            <option value="newest" <%= "newest".equals(currentSort) ? "selected" : "" %>>Mới nhất</option>
                            <option value="views" <%= "views".equals(currentSort) ? "selected" : "" %>>Xem nhiều nhất</option>
                            <option value="rating" <%= "rating".equals(currentSort) ? "selected" : "" %>>Đánh giá cao</option>
                        </select>
                    </div>
                </div>

                <div class="material-grid-wrapper">
                    <div class="material-grid">
                        <jsp:include page="/WEB-INF/fragments/material-repository-results.jsp" />
                    </div>
                </div>
            </main>
        </div>
    </section>

    <!-- CHÂN TRANG / FOOTER -->
    <footer class="footer">
        <div class="footer-card">
            <!-- Top Content Grid -->
            <div class="footer-top-grid">
                <!-- Brand Info & Socials -->
                <div class="footer-brand-col">
                    <a href="${pageContext.request.contextPath}/index" class="footer-logo">
                        <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
                        <span>HIPZI</span>
                    </a>
                    <p class="footer-desc">Nền tảng giáo dục thông minh kết hợp tài liệu học tập, luyện tập tương tác và công nghệ AI nhằm tối ưu hóa hành trình tri thức.</p>
                    
                    <!-- Social Links -->
                    <div class="footer-socials">
                        <a href="#" class="social-btn" title="Facebook">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                                <path d="M14 8.7V6.9c0-.86.2-1.3 1.38-1.3H17V2.17C16.21 2.06 15.44 2 14.67 2 11.9 2 10 3.69 10 6.79V8.7H7v3.82h3V22h4v-9.48h3.22l.5-3.82H14Z"></path>
                            </svg>
                        </a>
                        <a href="#" class="social-btn" title="TikTok">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                                <path d="M16.36 2c.28 2.39 1.62 3.82 3.86 3.97v3.33a7.23 7.23 0 0 1-3.8-1.14v6.8c0 4.37-3.32 6.89-6.58 6.89-3.61 0-6.06-2.73-6.06-5.96 0-3.78 2.96-6.1 6.78-5.94v3.48c-1.72-.25-3.17.74-3.17 2.43 0 1.38 1.08 2.38 2.45 2.38 1.53 0 2.68-.91 2.68-3.06V2h3.84Z"></path>
                            </svg>
                        </a>
                        <a href="#" class="social-btn" title="YouTube">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                                <path d="M21.58 7.18a3.02 3.02 0 0 0-2.12-2.12C17.58 4.56 12 4.56 12 4.56s-5.58 0-7.46.5a3.02 3.02 0 0 0-2.12 2.12A31.5 31.5 0 0 0 1.92 12c0 1.66.16 3.24.5 4.82a3.02 3.02 0 0 0 2.12 2.12c1.88.5 7.46.5 7.46.5s5.58 0 7.46-.5a3.02 3.02 0 0 0 2.12-2.12c.34-1.58.5-3.16.5-4.82s-.16-3.24-.5-4.82ZM10.02 15.55v-7.1L16.2 12l-6.18 3.55Z"></path>
                            </svg>
                        </a>
                    </div>
                </div>

                <!-- Navigation Columns Wrapper -->
                <div class="footer-links-wrapper">
                    <!-- Column 1 -->
                    <div class="footer-links-col footer-student-col">
                        <h4>Học viên</h4>
                        <ul>
                            <li>
                                <a href="${pageContext.request.contextPath}/material-repository">
                                    <span class="footer-student-icon" aria-hidden="true">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M4 19.5V5a2 2 0 0 1 2-2h11a3 3 0 0 1 3 3v13a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2Z"></path>
                                            <path d="M8 7h7"></path>
                                            <path d="M8 11h5"></path>
                                        </svg>
                                    </span>
                                    <span>Tìm kiếm tài liệu</span>
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/practice">
                                    <span class="footer-student-icon" aria-hidden="true">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M9 11h6"></path>
                                            <path d="M9 15h3"></path>
                                            <path d="M8 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2"></path>
                                            <rect x="8" y="2" width="8" height="4" rx="1"></rect>
                                        </svg>
                                    </span>
                                    <span>Luyện tập Trắc nghiệm</span>
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/practice">
                                    <span class="footer-student-icon" aria-hidden="true">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                                            <rect x="3" y="6" width="18" height="12" rx="2"></rect>
                                            <path d="M7 10h5"></path>
                                            <path d="M7 14h3"></path>
                                            <path d="M15.5 12h2"></path>
                                        </svg>
                                    </span>
                                    <span>Bộ thẻ Flashcard</span>
                                </a>
                            </li>
                        </ul>
                    </div>

                    <!-- Column 2 -->
                    <div class="footer-links-col footer-service-col footer-teacher-col">
                        <h4>Giảng viên</h4>
                        <ul>
                            <li>
                                <a href="${pageContext.request.contextPath}/register">
                                    <span class="footer-service-icon" aria-hidden="true">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                                            <circle cx="9" cy="7" r="4"></circle>
                                            <path d="M19 8v6"></path>
                                            <path d="M22 11h-6"></path>
                                        </svg>
                                    </span>
                                    <span>Đăng ký giảng dạy</span>
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/login">
                                    <span class="footer-service-icon" aria-hidden="true">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"></path>
                                            <path d="M14 2v6h6"></path>
                                            <path d="M9 15h6"></path>
                                            <path d="M9 18h4"></path>
                                        </svg>
                                    </span>
                                    <span>Quy định tải lên</span>
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/login">
                                    <span class="footer-service-icon" aria-hidden="true">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M12 3l1.6 4.7L18 9l-4.4 1.3L12 15l-1.6-4.7L6 9l4.4-1.3Z"></path>
                                            <path d="M19 14l.8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8Z"></path>
                                            <path d="M5 14l.8 2.2L8 17l-2.2.8L5 20l-.8-2.2L2 17l2.2-.8Z"></path>
                                        </svg>
                                    </span>
                                    <span>Công cụ AI</span>
                                </a>
                            </li>
                        </ul>
                    </div>

                    <!-- Column 3 -->
                    <div class="footer-links-col footer-dev-col">
                        <h4>Đội ngũ phát triển</h4>
                        <ul>
                            <li>
                                <div>
                                    <span class="footer-dev-role">Admin</span>
                                    <strong>Nguyễn Ngọc Thạch</strong>
                                    <a class="footer-dev-email" href="mailto:nguyenngocthach531@gmail.com">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                            <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                                            <path d="m3 7 9 6 9-6"></path>
                                        </svg>
                                        <span>nguyenngocthach531@gmail.com</span>
                                    </a>
                                </div>
                            </li>
                            <li>
                                <div>
                                    <span class="footer-dev-role">Admin</span>
                                    <strong>Văn Viết Nhật</strong>
                                    <a class="footer-dev-email" href="mailto:vnhat2644@gmail.com">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                            <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                                            <path d="m3 7 9 6 9-6"></path>
                                        </svg>
                                        <span>vnhat2644@gmail.com</span>
                                    </a>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Footer Contact & Map -->
            <div class="footer-contact-map" id="footer-contact">
                <div class="footer-map-panel">
                    <iframe
                        title="Bản đồ HIPZI"
                        src="https://maps.google.com/maps?hl=vi&ll=15.966996,108.252610&z=15&output=embed"
                        loading="lazy"
                        referrerpolicy="no-referrer-when-downgrade">
                    </iframe>
                </div>

                <div class="footer-contact-info">
                    <h3>Thông tin liên hệ HIPZI</h3>
                    <ul class="footer-contact-list">
                        <li>
                            <span class="footer-contact-icon" aria-hidden="true">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0Z"></path>
                                    <circle cx="12" cy="10" r="3"></circle>
                                </svg>
                            </span>
                            <div>
                                <strong>Địa chỉ</strong>
                                <span>Khu đô thị FPT, Đà Nẵng</span>
                            </div>
                        </li>
                        <li>
                            <span class="footer-contact-icon" aria-hidden="true">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                                    <path d="m3 7 9 6 9-6"></path>
                                </svg>
                            </span>
                            <div>
                                <strong>Email</strong>
                                <a href="mailto:support@hipzi.vn">support@hipzi.vn</a>
                            </div>
                        </li>
                        <li>
                            <span class="footer-contact-icon" aria-hidden="true">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.35 1.9.65 2.8a2 2 0 0 1-.45 2.11L8.03 9.91a16 16 0 0 0 6.06 6.06l1.28-1.28a2 2 0 0 1 2.11-.45c.9.3 1.84.52 2.8.65A2 2 0 0 1 22 16.92Z"></path>
                                </svg>
                            </span>
                            <div>
                                <strong>Hotline</strong>
                                <a href="tel:0911256346">0911 256 346</a>
                            </div>
                        </li>
                        <li>
                            <span class="footer-contact-icon" aria-hidden="true">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="9"></circle>
                                    <path d="M12 7v5l3 2"></path>
                                </svg>
                            </span>
                            <div>
                                <strong>Thời gian hỗ trợ</strong>
                                <span>08:00 - 22:00</span>
                            </div>
                        </li>
                    </ul>
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

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
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

        function scrollToResultsHeader() {
            if (!resultsEl) return;
            var navbar = document.querySelector('.navbar');
            var navbarHeight = navbar ? navbar.getBoundingClientRect().height : 0;
            var top = resultsEl.getBoundingClientRect().top + window.pageYOffset - navbarHeight - 14;
            window.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
        }

        function applyTwoWayFilter(targetUrlStr, isPopState, shouldScroll) {
            var targetUrl = new URL(targetUrlStr, location.href);
            var currentUrl = new URL(location.href);

            var newSubject = targetUrl.searchParams.get('subject') || currentUrl.searchParams.get('subject') || 'T\u1ea5t c\u1ea3';
            var newGrade   = targetUrl.searchParams.get('grade')   || currentUrl.searchParams.get('grade')   || 'T\u1ea5t c\u1ea3';
            var newType    = targetUrl.searchParams.get('type')    || currentUrl.searchParams.get('type')    || 'T\u1ea5t c\u1ea3';
            var newSort    = targetUrl.searchParams.get('sort')    || currentUrl.searchParams.get('sort')    || 'newest';
            var q          = currentUrl.searchParams.get('q') || '';
            var page       = targetUrl.searchParams.has('page') ? targetUrl.searchParams.get('page') : (isPopState ? currentUrl.searchParams.get('page') || '1' : '1');

            // Cập nhật sidebar active ngay lập tức
            updateSidebarActive(newSubject, newGrade, newType, newSort, q);

            var fetchUrl = new URL(location.pathname, location.href);
            fetchUrl.searchParams.set('subject', newSubject);
            fetchUrl.searchParams.set('grade', newGrade);
            fetchUrl.searchParams.set('type', newType);
            fetchUrl.searchParams.set('sort', newSort);
            fetchUrl.searchParams.set('page', page);
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
                    if (typeSelect) { typeSelect.value = newType; attachTypeSelectEvent(); if (window.HipziSelect) window.HipziSelect.refresh(typeSelect); }
                    var sortSelect = document.getElementById('sort-select');
                    if (sortSelect) { sortSelect.value = newSort; attachSortSelectEvent(); if (window.HipziSelect) window.HipziSelect.refresh(sortSelect); }
                    setLoading(false);
                    if (shouldScroll) {
                        requestAnimationFrame(scrollToResultsHeader);
                    }
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
            var pageBtn = e.target.closest('.page-btn');
            if (pageBtn) {
                e.preventDefault();
                if (pageBtn.disabled || pageBtn.classList.contains('active')) return;
                var page = pageBtn.getAttribute('data-page');
                var url = new URL(location.href);
                url.searchParams.set('page', page);
                applyTwoWayFilter(url.toString(), false, true);
                return;
            }

            var link = e.target.closest('.subject-list a');
            if (!link) return;
            e.preventDefault();
            // When filtering, remove page parameter so it defaults to 1
            var url = new URL(link.href);
            url.searchParams.delete('page');
            applyTwoWayFilter(url.toString(), false, true);
        });

        function attachTypeSelectEvent() {
            var el = document.getElementById('type-select');
            if (el && !el.dataset.hasEvent) {
                el.dataset.hasEvent = 'true';
                el.addEventListener('change', function () {
                    var url = new URL(location.href);
                    url.searchParams.set('type', this.value);
                    url.searchParams.delete('page');
                    applyTwoWayFilter(url.toString(), false, false);
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
                    url.searchParams.delete('page');
                    applyTwoWayFilter(url.toString(), false, false);
                });
            }
        }

        attachTypeSelectEvent();
        attachSortSelectEvent();
        window.addEventListener('popstate', function () { applyTwoWayFilter(location.href, true, true); });
    })();
    </script>
</body>
</html>
