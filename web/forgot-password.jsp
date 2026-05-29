<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=block" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>
    <div class="auth-page-wrapper">
        <a href="${pageContext.request.contextPath}/index.jsp" class="auth-home-btn" title="Về trang chủ">
            <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
        </a>

        <div class="auth-banner">
            <div class="banner-image-container">
                <img src="${pageContext.request.contextPath}/assets/images/capybara_study.png" alt="Capybara Study" class="banner-image">
            </div>
            <div class="banner-content">
                <h2 class="banner-title">Khôi phục quyền truy cập HIPZI</h2>
            </div>
        </div>

        <div class="auth-content">
            <div class="auth-form-container">
                <div class="auth-header">
                    <h1>Quên mật khẩu?</h1>
                    <p>Nhập email tài khoản để nhận mật khẩu mới từ HIPZI</p>
                </div>

                <% String errorMsg = (String) request.getAttribute("errorMsg");
                   String successMsg = (String) request.getAttribute("successMsg");
                   if (successMsg != null) { %>
                    <div class="alert alert-success">
                        <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        <span><%= successMsg %></span>
                    </div>
                <% } %>
                <% if (errorMsg != null) { %>
                    <div class="alert alert-error">
                        <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        <span><%= errorMsg %></span>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/forgot-password" method="POST" autocomplete="off">
                    <div class="form-group">
                        <label for="email">Địa chỉ Email</label>
                        <input type="email" id="email" name="email" class="form-control"
                               value="${email != null ? email : ''}" required placeholder="hocsinh@gmail.com"
                               autocomplete="off">
                    </div>

                    <button type="submit" class="btn btn-primary">Gửi mật khẩu mới</button>
                </form>

                <div class="auth-footer">
                    Nhớ mật khẩu rồi? <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
                </div>
            </div>
        </div>
    </div>

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
</body>
</html>
