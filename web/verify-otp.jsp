<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác minh bảo mật OTP - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
    <style>
        /* ===== BỔ SUNG CSS RIÊNG CHO LƯỚI NHẬP OTP ===== */
        .otp-input-grid {
            display: flex;
            gap: 0.65rem;
            justify-content: center;
            margin: 1.5rem 0 1.25rem 0;
        }

        .otp-digit {
            width: 50px;
            height: 58px;
            text-align: center;
            font-size: 1.5rem;
            font-weight: 800;
            font-family: 'Be Vietnam Pro', sans-serif;
            color: #0f172a;
            background: #f8fafc;
            border: 2px solid #cbd5e1;
            border-radius: 0.75rem;
            outline: none;
            transition: all 0.2s ease;
            caret-color: var(--primary);
        }

        .otp-digit:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12);
            background: #ffffff;
            transform: translateY(-2px);
        }

        .otp-digit.filled {
            border-color: var(--primary);
            background: #f0fdf4;
            color: var(--primary);
        }

        /* ===== ĐỒNG HỒ ĐẾM NGƯỢC ===== */
        .otp-timer {
            font-size: 0.85rem;
            color: #64748b;
            text-align: center;
            margin-bottom: 1.25rem;
            font-weight: 500;
        }

        .otp-timer strong {
            color: var(--primary);
            font-weight: 700;
            padding: 0.1rem 0.4rem;
            background: rgba(5, 150, 105, 0.1);
            border-radius: 0.25rem;
        }

        .otp-timer.expiring strong {
            color: var(--error);
            background: rgba(220, 38, 38, 0.1);
        }

        /* ===== BADGE PHÂN LOẠI MỤC ĐÍCH ===== */
        .purpose-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: #ecfdf5;
            color: var(--primary);
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.35rem 1rem;
            border-radius: 2rem;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin-bottom: 0.75rem;
        }

        .purpose-badge.login-badge {
            background: #eff6ff;
            color: #2563eb;
        }

        .purpose-badge.disable-badge {
            background: #fff7ed;
            color: #d97706;
        }

        /* ===== LINK GỬI LẠI OTP ===== */
        .resend-link {
            display: inline-block;
            font-size: 0.9rem;
            color: var(--primary);
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            background: none;
            border: none;
            padding: 0;
            margin-top: 0.25rem;
            transition: color 0.2s;
        }

        .resend-link:hover {
            color: var(--primary-hover);
            text-decoration: underline;
        }

        .resend-link:disabled {
            color: #94a3b8;
            text-decoration: none;
            cursor: not-allowed;
        }
    </style>
</head>
<body>

<div class="auth-page-wrapper">
    <!-- Nút Favicon Về Trang Chủ -->
    <a href="${pageContext.request.contextPath}/index.jsp" class="auth-home-btn" title="Về trang chủ">
        <img src="${pageContext.request.contextPath}/favicon.png" alt="HIPZI Logo">
    </a>

    <!-- Cột bên trái: Banner Capybara Cute & Animation (Premium Brand Sync) -->
    <div class="auth-banner">
        <div class="banner-image-container">
            <img src="${pageContext.request.contextPath}/assets/images/capybara_study.png" alt="Capybara Study" class="banner-image">
        </div>
        <div class="banner-content">
            <h2 class="banner-title">Bảo mật tuyệt đối cùng HIPZI</h2>
            <p class="banner-subtitle">Hệ thống áp dụng xác thực đa yếu tố bằng mã OTP nhằm bảo vệ vẹn toàn tài khoản và kho tài liệu bài giảng cá nhân của bạn.</p>
        </div>
    </div>

    <!-- Cột bên phải: Form Nhập OTP -->
    <div class="auth-content">
        <div class="auth-form-container">
            
            <%
                String purpose     = (String) request.getAttribute("purpose");
                String maskedEmail = (String) request.getAttribute("maskedEmail");
                if (purpose == null) purpose = "register";
                if (maskedEmail == null) maskedEmail = "***";
            %>

            <%-- Phần Tiêu đề Form --%>
            <div style="text-align: center; margin-bottom: 1.5rem;">
                <%-- Badge mục đích --%>
                <div>
                    <% if ("login".equals(purpose)) { %>
                        <span class="purpose-badge login-badge">🔐 Xác thực đăng nhập 2FA</span>
                    <% } else if ("disable_2fa".equals(purpose)) { %>
                        <span class="purpose-badge disable-badge">⚠️ Xác nhận tắt 2FA</span>
                    <% } else { %>
                        <span class="purpose-badge">🎓 Xác minh tài khoản mới</span>
                    <% } %>
                </div>

                <h1 style="font-size: 1.65rem; font-weight: 800; color: var(--text-main); margin: 0.25rem 0 0.5rem 0;">
                    <% if ("login".equals(purpose)) { %>
                        Nhập mã bảo mật OTP
                    <% } else if ("disable_2fa".equals(purpose)) { %>
                        Xác nhận quyền sở hữu
                    <% } else { %>
                        Xác minh địa chỉ email
                    <% } %>
                </h1>
                
                <p style="font-size: 0.95rem; color: var(--text-muted); margin: 0;">
                    Mã xác thực <strong>6 chữ số</strong> vừa được gửi đến<br>
                    <strong style="color: var(--primary); font-size: 1.05rem;"><%= maskedEmail %></strong>
                </p>
            </div>

            <%-- Hiển thị thông báo lỗi nếu nhập sai --%>
            <% String otpError = (String) request.getAttribute("otpError"); %>
            <% if (otpError != null && !otpError.isEmpty()) { %>
                <div class="alert alert-error" style="justify-content: center; text-align: center; border-radius: 0.75rem;">
                    <span><%= otpError %></span>
                </div>
            <% } %>

            <%-- Form nộp OTP --%>
            <form id="otpForm" action="${pageContext.request.contextPath}/verify-otp" method="POST">
                <input type="hidden" name="purpose" value="<%= purpose %>">
                <input type="hidden" id="otpHidden" name="otp" value="">

                <%-- Lưới 6 ô nhập liệu tự động chuyển focus --%>
                <div class="otp-input-grid">
                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="d0" autocomplete="one-time-code">
                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="d1">
                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="d2">
                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="d3">
                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="d4">
                    <input class="otp-digit" type="text" maxlength="1" inputmode="numeric" pattern="[0-9]" id="d5">
                </div>

                <%-- Đồng hồ đếm ngược thời gian hiệu lực --%>
                <div class="otp-timer" id="otpTimer">
                    Mã hết hạn sau: <strong id="timerDisplay">05:00</strong>
                </div>

                <%-- Submit Action --%>
                <button type="submit" id="submitBtn" class="btn btn-primary" disabled style="width: 100%; border-radius: 0.75rem;">
                    Xác nhận mã OTP
                </button>
            </form>

            <%-- Vùng Footer Form: Tùy chọn gửi lại mã --%>
            <div class="auth-footer" style="margin-top: 1.75rem; padding-top: 1.25rem;">
                <p style="margin: 0 0 0.35rem 0; font-size: 0.9rem; color: var(--text-muted);">Không nhận được email chứa mã?</p>
                <form action="${pageContext.request.contextPath}/send-register-otp" method="POST" style="display:inline;">
                    <button type="submit" id="resendBtn" class="resend-link">
                        Gửi lại mã OTP ngay
                    </button>
                </form>
            </div>

            <%-- Nút quay lại điều hướng linh hoạt --%>
            <div style="text-align: center; margin-top: 1.25rem;">
                <a href="${pageContext.request.contextPath}/<%= "login".equals(purpose) ? "login" : "register" %>"
                   style="color: #94a3b8; font-size: 0.85rem; text-decoration: none; font-weight: 600; transition: color 0.2s;">
                    ← Quay lại trang <% if ("login".equals(purpose)) { %>đăng nhập<% } else { %>đăng ký<% } %>
                </a>
            </div>

        </div>
    </div>
</div>

<script>
    // =========================================================================
    // Xử lý Navigation & dán mã tự động trên lưới OTP
    // =========================================================================
    const digits    = Array.from(document.querySelectorAll('.otp-digit'));
    const hidden    = document.getElementById('otpHidden');
    const submitBtn = document.getElementById('submitBtn');

    digits.forEach((input, idx) => {
        input.addEventListener('input', (e) => {
            const val = e.target.value.replace(/\D/g, '');
            e.target.value = val;
            if (val) {
                e.target.classList.add('filled');
                if (idx < digits.length - 1) {
                    digits[idx + 1].focus();
                }
            } else {
                e.target.classList.remove('filled');
            }
            syncHiddenAndButton();
        });

        input.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && !e.target.value && idx > 0) {
                digits[idx - 1].focus();
                digits[idx - 1].value = '';
                digits[idx - 1].classList.remove('filled');
                syncHiddenAndButton();
            }
        });

        // Xử lý dán (Paste) trọn vẹn 6 số cùng lúc
        input.addEventListener('paste', (e) => {
            e.preventDefault();
            const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
            pasted.split('').forEach((ch, i) => {
                if (digits[i]) {
                    digits[i].value = ch;
                    digits[i].classList.add('filled');
                }
            });
            if (pasted.length < 6) {
                digits[pasted.length]?.focus();
            } else {
                digits[5].focus();
            }
            syncHiddenAndButton();
        });
    });

    function syncHiddenAndButton() {
        const code = digits.map(d => d.value).join('');
        hidden.value = code;
        submitBtn.disabled = (code.length !== 6);
    }

    // =========================================================================
    // Quản lý đếm ngược 5 phút
    // =========================================================================
    let totalSeconds = 5 * 60;
    const timerEl        = document.getElementById('timerDisplay');
    const timerContainer = document.getElementById('otpTimer');

    const countdown = setInterval(() => {
        totalSeconds--;
        if (totalSeconds <= 0) {
            clearInterval(countdown);
            timerEl.textContent = 'Hết hạn';
            timerContainer.classList.add('expiring');
            submitBtn.disabled = true;
            submitBtn.textContent = 'Mã OTP đã hết hạn – Vui lòng gửi lại';
            return;
        }
        const m = String(Math.floor(totalSeconds / 60)).padStart(2, '0');
        const s = String(totalSeconds % 60).padStart(2, '0');
        timerEl.textContent = m + ':' + s;
        if (totalSeconds <= 60) {
            timerContainer.classList.add('expiring');
        }
    }, 1000);

    // Tự động trỏ chuột vào ô nhập đầu tiên khi trang vừa tải xong
    window.addEventListener('DOMContentLoaded', () => {
        if (digits.length > 0) {
            digits[0].focus();
        }
    });
</script>

</body>
</html>
