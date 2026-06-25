<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Course"%>
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
    Boolean profileHasStudentObj = (Boolean) request.getAttribute("profileHasStudent");
    boolean profileHasStudent = profileHasStudentObj != null ? profileHasStudentObj : false;
    
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
        
        .detail-container { max-width: 1200px; margin: 100px auto 50px; padding: 0 1.5rem; display: grid; grid-template-columns: 1fr 380px; gap: 2rem; align-items: start; }
        @media (max-width: 900px) {
            .detail-container { grid-template-columns: 1fr; }
        }

        .main-content { background: #fff; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 20px rgba(0,0,0,0.04); }
        .breadcrumb { font-size: 0.9rem; color: #666; margin-bottom: 1.5rem; }
        .breadcrumb a { color: #00b167; text-decoration: none; font-weight: 500; }
        
        .course-title { font-size: 2rem; font-weight: 800; color: #111; margin-bottom: 1rem; line-height: 1.3; }
        .course-meta { display: flex; align-items: center; gap: 1.5rem; color: #666; font-size: 0.95rem; margin-bottom: 2rem; flex-wrap: wrap; }
        .meta-item { display: flex; align-items: center; gap: 0.5rem; }
        .meta-item svg { width: 18px; height: 18px; color: #00b167; }
        
        .teacher-info { display: flex; align-items: center; gap: 1rem; padding: 1.5rem; background: #f0fdf4; border-radius: 12px; margin-bottom: 2rem; }
        .teacher-avatar { width: 48px; height: 48px; border-radius: 50%; object-fit: cover; background: #c6f6d5; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #00b167; }
        .teacher-details { display: flex; flex-direction: column; }
        .teacher-name { font-weight: 600; color: #111; }
        .teacher-school { font-size: 0.85rem; color: #555; }

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
                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
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
        <% if (successMsg != null) { %>
            <div style="grid-column: 1 / -1; padding: 1rem; background: #dcfce7; color: #16a34a; border-radius: 8px; margin-bottom: -1rem; font-weight: 500;">
                <%= h(successMsg) %>
            </div>
        <% } %>
        <div class="main-content" style="margin-top: 2rem;">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/courses">Khóa học</a> &nbsp;>&nbsp; <%= h(course.getSubjectName()) %>
            </div>
            
            <h1 class="course-title"><%= h(course.getTitle()) %></h1>
            
            <div class="course-meta">
                <div class="meta-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                    <%= h(course.getDisplayRating()) %> sao (<%= course.getRatingCount() %> đánh giá)
                </div>
                <div class="meta-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    <%= course.getStudentsCount() %> học viên
                </div>
                <div class="meta-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="14 2 18 6 7 17 3 17 3 13 14 2"></polygon><line x1="3" y1="22" x2="21" y2="22"></line></svg>
                    Cấp độ: <%= h(course.getLevelName()) %>
                </div>
            </div>
            
            <div class="teacher-info">
                <% if (course.getTeacherAvatarUrl() != null && !course.getTeacherAvatarUrl().isEmpty()) { %>
                    <img src="<%= h(course.getTeacherAvatarUrl()) %>" class="teacher-avatar" alt="Giáo viên">
                <% } else { 
                    String tInits = "GV";
                    if (course.getTeacherName() != null && !course.getTeacherName().isEmpty()) {
                        String[] parts = course.getTeacherName().trim().split("\\s+");
                        tInits = parts[parts.length - 1].substring(0, 1).toUpperCase();
                    }
                %>
                    <div class="teacher-avatar"><%= h(tInits) %></div>
                <% } %>
                <div class="teacher-details">
                    <div class="teacher-name">Giảng viên: <%= h(course.getTeacherName()) %></div>
                    <div class="teacher-school"><%= h(course.getTeacherSchool()) %></div>
                </div>
            </div>
            
            <h2 class="section-title">Giới thiệu khóa học</h2>
            <div class="course-desc">
                <%= course.getShortDescription() != null ? h(course.getShortDescription()) : "Chưa có mô tả chi tiết." %>
            </div>
            
            <% if (course.isViewerEnrolled()) { %>
            <h2 class="section-title">Hướng dẫn truy cập</h2>
            <div class="course-desc" style="background:#e0e7ff; padding: 1.5rem; border-radius:12px; color:#3730a3;">
                <% if (course.getAccessInstructions() != null && !course.getAccessInstructions().isEmpty()) { %>
                    <%= h(course.getAccessInstructions()) %>
                <% } else { %>
                    Bạn đã đăng ký khóa học này. Hãy làm theo hướng dẫn hoặc liên hệ giáo viên để được cấp quyền truy cập tài nguyên.
                <% } %>
            </div>
            <% } %>
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
                    <a href="#" class="btn btn-primary" onclick="alert('Tính năng truy cập trực tiếp sẽ ra mắt trong Phase tiếp theo!')">Truy cập khóa học</a>
                    <p style="text-align:center; font-size:0.85rem; color:#666; margin-top:0.5rem;">Bạn đã đăng ký khóa học này</p>
                <% } else if (course.isFree()) { %>
                    <% if (profileHasStudent) { %>
                        <form action="${pageContext.request.contextPath}/enroll" method="POST" style="margin:0;">
                            <input type="hidden" name="courseId" value="<%= h(course.getId()) %>">
                            <button type="submit" class="btn btn-primary">Đăng ký học ngay</button>
                        </form>
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
    </script>
</body>
</html>
