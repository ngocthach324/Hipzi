<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=block" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css?v=3">
</head>
<body>
    <% 
        String errorMsg = (String) request.getAttribute("errorMsg"); 
        String successMsg = (String) request.getAttribute("successMsg");
        String toastMessageToDisplay = null;
        
        if (successMsg != null) {
            toastMessageToDisplay = successMsg;
        } else if (errorMsg != null) {
            toastMessageToDisplay = errorMsg;
        }
        
        String disableAnimStyle = (toastMessageToDisplay != null) ? "style=\"animation: none;\"" : "";
    %>
    <div class="auth-page-wrapper forgot-password-auth-page">
        <!-- Nút Favicon Về Trang Chủ -->
        <a href="${pageContext.request.contextPath}/index" class="auth-home-btn" title="Về trang chủ" <%= disableAnimStyle %>>
            <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
        </a>

        <!-- Cột bên trái: Poster Wall (3 cột cuộn) -->
        <div class="auth-banner" <%= disableAnimStyle %>>
            <img class="auth-side-illustration" src="${pageContext.request.contextPath}/assets/images/auth-capybara-classroom-no-math.png" alt="" aria-hidden="true">
            <div class="poster-grid">
                <% 
                    String[] myPosters = null;
                    try {
                        String path = application.getRealPath("/assets/images");
                        if (path != null) {
                            java.io.File folder = new java.io.File(path);
                            if (folder.exists() && folder.isDirectory()) {
                                myPosters = folder.list(new java.io.FilenameFilter() {
                                    @Override
                                    public boolean accept(java.io.File dir, String name) {
                                        String lower = name.toLowerCase();
                                        return lower.endsWith(".webp") || lower.endsWith(".jpg") 
                                            || lower.endsWith(".png") || lower.endsWith(".jpeg");
                                    }
                                });
                            }
                        }
                    } catch (Exception e) {
                        // Bỏ qua ngoại lệ nếu có lỗi
                    }
                    
                    if (myPosters == null || myPosters.length == 0) {
                        myPosters = new String[]{"placeholder.jpg"};
                    }
                    myPosters = new String[]{"auth-capybara-classroom-no-math.png"};
                    
                    // Vòng lặp 3 cột
                    for (int col = 0; col < 3; col++) { 
                %>
                <div class="poster-col">
                    <!-- Lặp poster lần 1 để hiệu ứng infinite scroll -->
                    <% for (int i = 0; i < 12; i++) { 
                        String posterFile = myPosters[(i + col * 4) % myPosters.length];
                    %>
                    <div class="poster-item" 
                         style="background-image: url('${pageContext.request.contextPath}/assets/images/<%= posterFile %>');"></div>
                    <% } %>
                    
                    <!-- Lặp lần 2 cho infinite effect -->
                    <% for (int i = 0; i < 12; i++) { 
                        String posterFile = myPosters[(i + col * 4) % myPosters.length];
                    %>
                    <div class="poster-item" 
                         style="background-image: url('${pageContext.request.contextPath}/assets/images/<%= posterFile %>');"></div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <div class="poster-overlay"></div>
            <div class="auth-banner-copy" hidden>
                <strong>Học mọi lúc, mọi nơi</strong>
                <span>Hàng nghìn bài học chờ bạn khám phá</span>
            </div>
        </div>

        <!-- Cột bên phải: Form Quên Mật Khẩu -->
        <div class="auth-content">
            <div class="auth-form-container">
                <div class="auth-form-inner" <%= disableAnimStyle %>>
                    <div class="auth-header">
                        <h1>Quên mật khẩu?</h1>
                        <p>Nhập email tài khoản để nhận mật khẩu mới từ HIPZI</p>
                    </div>

                    <form action="${pageContext.request.contextPath}/forgot-password" method="POST" autocomplete="off">
                        <div class="form-group">
                            <label for="email">Địa chỉ Email</label>
                            <input type="email" id="email" name="email" class="form-control"
                                   value="${email != null ? email : ''}" required placeholder="hocsinh@gmail.com"
                                   autocomplete="off">
                        </div>

                        <button type="submit" class="btn btn-primary">Gửi mật khẩu mới</button>
                    </form>

                    <div class="auth-footer" style="margin-top: 1.5rem;">
                        Nhớ mật khẩu rồi? <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Script xử lý UI -->
    <script>
        function animateBannerTitle() {
            const title = document.querySelector('.banner-title');
            if (!title || title.dataset.animated === 'true') return;

            const text = title.textContent;
            title.dataset.animated = 'true';
            title.setAttribute('aria-label', text);
            title.textContent = '';

            Array.from(text).forEach((char, index) => {
                const span = document.createElement('span');
                span.className = 'banner-title-char' + (char === ' ' ? ' space' : '');
                span.textContent = char === ' ' ? '\u00A0' : char;
                span.style.animationDelay = (index * 22) + 'ms';
                span.setAttribute('aria-hidden', 'true');
                title.appendChild(span);
            });
        }

        document.addEventListener('DOMContentLoaded', animateBannerTitle);
    </script>
    
    <% if (toastMessageToDisplay != null) { %>
    <div id="custom-toast-container" class="custom-toast-container">
        <div class="custom-toast-msg <%= (errorMsg != null) ? "error" : "" %>">
            <% if (successMsg != null) { %>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            <% } else { %>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            <% } %>
            <span><%= toastMessageToDisplay %></span>
        </div>
    </div>
    <% } %>
</body>
</html>