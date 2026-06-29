<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>Đăng ký - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=block" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth-mobile.css?v=1">
</head>
<body>
    <% 
        String errorMsg = (String) request.getAttribute("errorMsg"); 
        String disableAnimStyle = (errorMsg != null) ? "style=\"animation: none;\"" : "";
    %>
    <div class="auth-page-wrapper register-auth-page">
        <!-- Nút Favicon Về Trang Chủ -->
        <a href="${pageContext.request.contextPath}/index" class="auth-home-btn" title="Về trang chủ"
           aria-label="Về trang chủ HIPZI" <%= disableAnimStyle %>>
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

        <!-- Cột bên phải: Form Đăng Ký -->
        <div class="auth-content">
            <div class="auth-form-container">
                <div class="auth-form-inner" <%= disableAnimStyle %>>
                    <div class="auth-header">
                        <h1>Tạo tài khoản mới</h1>
                        <p>Bắt đầu hành trình học tập đầy hứng khởi cùng HIPZI</p>
                    </div>                    <form action="${pageContext.request.contextPath}/register" method="POST">
                        <!-- BỘ CHỌN VAI TRÒ (ROLE SELECTOR) CỰC KỲ SANG TRỌNG -->
                        <div class="form-group">
                            <label>Bạn là ai?</label>
                            <div class="role-grid">
                                <!-- Thẻ Học viên -->
                                <label class="role-card active">
                                    <input type="radio" name="role" value="student" checked onchange="updateRoleUI(this)" />
                                    <span>Học viên</span>
                                </label>

                                <!-- Thẻ Phụ huynh -->
                                <label class="role-card">
                                    <input type="radio" name="role" value="parent" onchange="updateRoleUI(this)" />
                                    <span>Phụ huynh</span>
                                </label>

                                <!-- Thẻ Giảng viên -->
                                <label class="role-card">
                                    <input type="radio" name="role" value="teacher" onchange="updateRoleUI(this)" />
                                    <span>Giảng viên</span>
                                </label>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="displayName">Họ và tên</label>
                            <input type="text" id="displayName" name="displayName" class="form-control" 
                                   value="${displayName != null ? displayName : ''}" required placeholder="Nguyễn Văn A"
                                   autocomplete="name">
                        </div>

                        <div class="form-group">
                            <label for="email">Địa chỉ Email</label>
                            <input type="email" id="email" name="email" class="form-control" 
                                   value="${email != null ? email : ''}" required placeholder="hocsinh@gmail.com"
                                   autocomplete="email" inputmode="email" autocapitalize="none" spellcheck="false">
                        </div>

                        <div class="form-group">
                            <label for="password">Mật khẩu</label>
                            <div class="password-input-wrapper">
                                <input type="password" id="password" name="password" class="form-control" 
                                       required placeholder="••••••••" minlength="6" autocomplete="new-password">
                                <button type="button" class="password-toggle-btn" onclick="togglePassword('password', this)" title="Hiện/Ẩn mật khẩu">
                                    <svg class="eye-icon eye-show" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                    <svg class="eye-icon eye-hide" style="display:none;" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                                </button>
                            </div>
                        </div>



                        <button type="submit" class="btn btn-primary">Đăng ký ngay</button>
                    </form>



                    <div class="auth-footer">
                        Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                    </div>
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
                card.classList.remove('active');
            });

            const parentCard = selectedRadio.closest('.role-card');
            if (parentCard) {
                parentCard.classList.add('active');
            }
        }

        document.addEventListener('DOMContentLoaded', animateBannerTitle);
    </script>
    
    <% if (errorMsg != null) { %>
    <div id="custom-toast-container" class="custom-toast-container">
        <div class="custom-toast-msg error">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            <span><%= errorMsg %></span>
        </div>
    </div>
    <% } %>
</body>
</html>
