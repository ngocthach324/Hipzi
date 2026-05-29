<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=block" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>
    <div class="auth-page-wrapper register-auth-page">
        <!-- Nút Favicon Về Trang Chủ -->
        <a href="${pageContext.request.contextPath}/index.jsp" class="auth-home-btn" title="Về trang chủ">
            <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
        </a>

        <!-- Cột bên trái: Banner Capybara Cute & Animation -->
        <div class="auth-banner">
            <div class="banner-image-container">
                <img src="${pageContext.request.contextPath}/assets/images/capybara_study.png" alt="Capybara Study" class="banner-image">
            </div>
            <div class="banner-content">
                <h2 class="banner-title">Khám phá trải nghiệm học tập mới cùng HIPZI</h2>
            </div>
        </div>

        <!-- Cột bên phải: Form Đăng Ký -->
        <div class="auth-content">
            <div class="auth-form-container">
                <div class="auth-header">
                    <h1>Tạo tài khoản mới</h1>
                    <p>Bắt đầu hành trình học tập đầy hứng khởi cùng HIPZI</p>
                </div>

                <% String errorMsg = (String) request.getAttribute("errorMsg"); 
                   if (errorMsg != null) { %>
                    <div class="alert alert-error">
                        <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        <span><%= errorMsg %></span>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/register" method="POST">
                    <!-- BỘ CHỌN VAI TRÒ (ROLE SELECTOR) CỰC KỲ SANG TRỌNG -->
                    <div class="form-group">
                        <label style="font-weight: 600; margin-bottom: 0.5rem; display: block; color: var(--text-primary);">Bạn là ai?</label>
                        <div class="role-grid" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px;">
                            <!-- Thẻ Học viên -->
                            <label class="role-card active" style="border: 2px solid var(--primary, #059669); background: var(--surface, #ffffff); border-radius: 12px; padding: 12px; text-align: center; cursor: pointer; transition: all 0.2s ease; display: block;">
                                <input type="radio" name="role" value="student" checked style="display: none;" onchange="updateRoleUI(this)" />
                                <span style="font-weight: 600; font-size: 0.9rem; color: var(--primary, #059669); display: block;">Học viên</span>
                            </label>

                            <!-- Thẻ Phụ huynh -->
                            <label class="role-card" style="border: 2px solid var(--border, #e2e8f0); background: var(--surface, #ffffff); border-radius: 12px; padding: 12px; text-align: center; cursor: pointer; transition: all 0.2s ease; display: block; opacity: 0.7;">
                                <input type="radio" name="role" value="parent" style="display: none;" onchange="updateRoleUI(this)" />
                                <span style="font-weight: 500; font-size: 0.9rem; color: var(--text-secondary, #64748b); display: block;">Phụ huynh</span>
                            </label>

                            <!-- Thẻ Giảng viên -->
                            <label class="role-card" style="border: 2px solid var(--border, #e2e8f0); background: var(--surface, #ffffff); border-radius: 12px; padding: 12px; text-align: center; cursor: pointer; transition: all 0.2s ease; display: block; opacity: 0.7;">
                                <input type="radio" name="role" value="teacher" style="display: none;" onchange="updateRoleUI(this)" />
                                <span style="font-weight: 500; font-size: 0.9rem; color: var(--text-secondary, #64748b); display: block;">Giảng viên</span>
                            </label>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="displayName">Họ và tên</label>
                        <input type="text" id="displayName" name="displayName" class="form-control" 
                               value="${displayName != null ? displayName : ''}" required placeholder="Nguyễn Văn A">
                    </div>

                    <div class="form-group">
                        <label for="email">Địa chỉ Email</label>
                        <input type="email" id="email" name="email" class="form-control" 
                               value="${email != null ? email : ''}" required placeholder="hocsinh@gmail.com">
                    </div>

                    <div class="form-group">
                        <label for="password">Mật khẩu</label>
                        <div class="password-input-wrapper">
                            <input type="password" id="password" name="password" class="form-control" 
                                   required placeholder="••••••••" minlength="6">
                            <button type="button" class="password-toggle-btn" onclick="togglePassword('password', this)" title="Hiện/Ẩn mật khẩu">
                                <svg class="eye-icon eye-show" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                <svg class="eye-icon eye-hide" style="display:none;" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Xác nhận mật khẩu</label>
                        <div class="password-input-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                                   required placeholder="••••••••" minlength="6">
                            <button type="button" class="password-toggle-btn" onclick="togglePassword('confirmPassword', this)" title="Hiện/Ẩn mật khẩu">
                                <svg class="eye-icon eye-show" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                <svg class="eye-icon eye-hide" style="display:none;" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary">Đăng ký ngay</button>
                </form>

                <!-- Nút Đăng ký Google -->
                <div class="social-login-divider">
                    <span>hoặc</span>
                </div>
                <button type="button" class="btn btn-google" onclick="window.location.href='${pageContext.request.contextPath}/auth/google'">
                    <svg class="google-icon" viewBox="0 0 24 24" width="20" height="20">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                    </svg>
                    <span>Đăng ký với Google</span>
                </button>

                <div class="auth-footer">
                    Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Script xử lý nút ẩn/hiện mật khẩu và bộ chọn Role -->
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

        function togglePassword(inputId, btn) {
            const input = document.getElementById(inputId);
            const showIcon = btn.querySelector('.eye-show');
            const hideIcon = btn.querySelector('.eye-hide');
            if (input.type === 'password') {
                input.type = 'text';
                showIcon.style.display = 'none';
                hideIcon.style.display = 'block';
            } else {
                input.type = 'password';
                showIcon.style.display = 'block';
                hideIcon.style.display = 'none';
            }
        }

        function updateRoleUI(selectedRadio) {
            const allCards = document.querySelectorAll('.role-card');
            allCards.forEach(card => {
                card.style.border = '2px solid var(--border, #e2e8f0)';
                card.style.opacity = '0.7';
                const textSpan = card.querySelector('span');
                if (textSpan) {
                    textSpan.style.color = 'var(--text-secondary, #64748b)';
                    textSpan.style.fontWeight = '500';
                }
            });

            const parentCard = selectedRadio.closest('.role-card');
            if (parentCard) {
                parentCard.style.border = '2px solid var(--primary, #059669)';
                parentCard.style.opacity = '1';
                const textSpan = parentCard.querySelector('span');
                if (textSpan) {
                    textSpan.style.color = 'var(--primary, #059669)';
                    textSpan.style.fontWeight = '600';
                }
            }
        }

        document.addEventListener('DOMContentLoaded', animateBannerTitle);
    </script>
</body>
</html>
