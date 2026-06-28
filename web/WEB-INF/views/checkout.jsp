<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.CourseOrder"%>
<%@page import="com.hipzi.model.CourseOrderItem"%>
<%@page import="com.hipzi.model.CourseAccessSummary"%>
<%@page import="java.text.SimpleDateFormat"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    String initials = "H";
    if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().trim().split("\\s+");
        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
    }
    CourseOrder order = (CourseOrder) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/cart");
        return;
    }
    String vietQrUrl = (String) request.getAttribute("vietQrUrl");
    String bankLabel = (String) request.getAttribute("bankLabel");
    String bankAccountName = (String) request.getAttribute("bankAccountName");
    String bankAccountNo = (String) request.getAttribute("bankAccountNo");
    CourseAccessSummary accessSummary = (CourseAccessSummary) request.getAttribute("accessSummary");
    SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm dd/MM/yyyy");
    String expiresLabel = order.getExpiresAt() != null ? dateFormat.format(order.getExpiresAt()) : "";
    String accessNoticeClass = "pending";
    String accessNoticeMessage = "Sau khi chuyển khoản đúng số tiền và nội dung, SePay sẽ gửi webhook về HIPZI để kích hoạt khóa học.";
    if (order.isPaid()) {
        if (accessSummary != null && accessSummary.isAllGranted()) {
            accessNoticeClass = "success";
            String email = accessSummary.getStudentEmail() != null && !accessSummary.getStudentEmail().isEmpty()
                    ? accessSummary.getStudentEmail()
                    : "của bạn";
            accessNoticeMessage = "Khóa học đã được gửi qua email " + email + ". Vui lòng kiểm tra Google Drive hoặc hộp thư của bạn.";
        } else if (accessSummary != null && accessSummary.hasFailure()) {
            accessNoticeClass = "failed";
            accessNoticeMessage = "Thanh toán đã được ghi nhận, nhưng HIPZI chưa thể tự động cấp quyền Google Drive. Bộ phận hỗ trợ hoặc giáo viên sẽ xử lý lại cho bạn.";
        } else {
            accessNoticeClass = "success";
            accessNoticeMessage = "Thanh toán thành công. HIPZI đang cấp quyền truy cập khóa học qua email của bạn, vui lòng kiểm tra lại sau ít phút.";
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán đơn <%= h(order.getOrderCode()) %> - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=12">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        body {
            font-family: "Be Vietnam Pro", "Inter", Arial, sans-serif;
            background: #f5fbf8;
            color: #0f172a;
            margin: 0;
        }
        body::before,
        body::after { display: none !important; }
        .checkout-shell {
            width: min(1180px, calc(100vw - 32px));
            margin: 104px auto 56px;
        }
        .checkout-heading {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .checkout-heading h1 {
            margin: 0 0 .35rem;
            font-size: clamp(1.6rem, 3vw, 2.25rem);
            line-height: 1.2;
            font-weight: 900;
        }
        .checkout-heading p {
            margin: 0;
            color: #64748b;
            font-weight: 600;
        }
        .status-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 36px;
            padding: 0 .9rem;
            border-radius: 999px;
            background: #fff7ed;
            color: #c2410c;
            border: 1px solid #fed7aa;
            font-weight: 800;
            white-space: nowrap;
        }
        .status-pill.paid {
            background: #ecfdf5;
            border-color: #a7f3d0;
            color: #047857;
        }
        .checkout-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 380px;
            gap: 1.25rem;
            align-items: start;
        }
        .panel {
            background: rgba(255,255,255,.92);
            border: 1px solid #dbe7e3;
            border-radius: 12px;
            box-shadow: 0 18px 42px rgba(15,23,42,.06);
            overflow: hidden;
        }
        .panel-header {
            padding: 1.1rem 1.25rem;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            align-items: center;
        }
        .panel-title {
            font-size: 1.05rem;
            font-weight: 900;
        }
        .panel-body { padding: 1.25rem; }
        .pay-box {
            display: grid;
            grid-template-columns: 220px minmax(0, 1fr);
            gap: 1.25rem;
            align-items: center;
        }
        .qr-box {
            aspect-ratio: 1;
            border-radius: 12px;
            border: 1px dashed #94a3b8;
            background:
                linear-gradient(90deg, rgba(15,23,42,.08) 1px, transparent 1px),
                linear-gradient(0deg, rgba(15,23,42,.08) 1px, transparent 1px),
                #ffffff;
            background-size: 18px 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #0f766e;
            font-weight: 900;
            padding: 1rem;
        }
        .qr-box.has-qr {
            background: #fff;
            border-style: solid;
            padding: .65rem;
        }
        .qr-box img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: block;
            border-radius: 8px;
        }
        .pay-lines {
            display: grid;
            gap: .8rem;
        }
        .pay-line {
            display: grid;
            grid-template-columns: 160px minmax(0, 1fr);
            gap: 1rem;
            align-items: center;
        }
        .pay-label {
            color: #64748b;
            font-size: .88rem;
            font-weight: 700;
        }
        .pay-value {
            min-width: 0;
            color: #0f172a;
            font-weight: 900;
            overflow-wrap: anywhere;
        }
        .pay-value.amount {
            color: #059669;
            font-size: 1.35rem;
        }
        .copy-row {
            display: flex;
            gap: .5rem;
            align-items: center;
        }
        .copy-row .pay-value { flex: 1; }
        .icon-btn {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            background: #fff;
            color: #0f766e;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: background .2s, border-color .2s, transform .2s;
        }
        .icon-btn:hover {
            background: #ecfdf5;
            border-color: #0d9488;
            transform: translateY(-1px);
        }
        .order-item {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            padding: 1rem 0;
            border-bottom: 1px solid #e2e8f0;
        }
        .order-item:last-child { border-bottom: 0; }
        .order-item-title {
            color: #0f172a;
            font-weight: 800;
            line-height: 1.4;
        }
        .order-item-price {
            color: #0f766e;
            font-weight: 900;
            white-space: nowrap;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: .9rem;
            color: #475569;
            font-weight: 700;
        }
        .summary-row.total {
            border-top: 1px solid #e2e8f0;
            padding-top: 1rem;
            margin-top: 1rem;
            color: #0f172a;
            font-size: 1.2rem;
            font-weight: 900;
        }
        .helper-note {
            margin-top: 1rem;
            padding: .9rem 1rem;
            border-radius: 10px;
            background: #f0fdfa;
            border: 1px solid #99f6e4;
            color: #115e59;
            font-size: .9rem;
            font-weight: 650;
            line-height: 1.55;
        }
        .access-note.success {
            background: #ecfdf5;
            border-color: #6ee7b7;
            color: #065f46;
        }
        .access-note.failed {
            background: #fef2f2;
            border-color: #fecaca;
            color: #991b1b;
        }
        .access-note.pending {
            background: #fff7ed;
            border-color: #fed7aa;
            color: #9a3412;
        }
        .actions {
            display: grid;
            gap: .75rem;
            margin-top: 1rem;
        }
        .btn-main,
        .btn-soft {
            min-height: 46px;
            border-radius: 10px;
            border: 0;
            font: inherit;
            font-weight: 900;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .btn-main {
            background: linear-gradient(135deg, #059669, #10b981);
            color: #fff;
            box-shadow: 0 12px 24px rgba(16,185,129,.18);
        }
        .btn-soft {
            background: #f8fafc;
            color: #0f172a;
            border: 1px solid #e2e8f0;
        }
        @media (max-width: 900px) {
            .checkout-heading { align-items: flex-start; flex-direction: column; }
            .checkout-grid,
            .pay-box { grid-template-columns: 1fr; }
            .qr-box { max-width: 260px; width: 100%; margin: 0 auto; }
            .pay-line { grid-template-columns: 1fr; gap: .25rem; }
        }
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
                <li><a href="${pageContext.request.contextPath}/mock-exams">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/courses" class="active">Khóa học</a></li>
            </ul>
            <div class="navbar-user-controls">
                <%@ include file="/WEB-INF/fragments/cart-icon.jspf" %>
                <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                <%@ include file="/WEB-INF/fragments/avatar-dropdown.jspf" %>
            </div>
        </div>
    </header>

    <main class="checkout-shell">
        <div class="checkout-heading">
            <div>
                <h1>Thanh toán đơn hàng</h1>
                <p>Mã đơn <strong><%= h(order.getOrderCode()) %></strong>. Nội dung chuyển khoản phải khớp để SePay đối soát.</p>
            </div>
            <span class="status-pill <%= order.isPaid() ? "paid" : "" %>" id="orderStatus">
                <%= order.isPaid() ? "Đã thanh toán" : "Chờ thanh toán" %>
            </span>
        </div>

        <div class="checkout-grid">
            <section class="panel">
                <div class="panel-header">
                    <div class="panel-title">Thông tin chuyển khoản SePay</div>
                    <span style="color:#64748b; font-weight:700; font-size:.9rem;">Hết hạn: <%= h(expiresLabel) %></span>
                </div>
                <div class="panel-body">
                    <div class="pay-box">
                        <div class="qr-box <%= (vietQrUrl != null && !vietQrUrl.isEmpty()) ? "has-qr" : "" %>">
                            <% if (vietQrUrl != null && !vietQrUrl.isEmpty()) { %>
                            <img src="<%= h(vietQrUrl) %>" alt="Ma QR thanh toan <%= h(order.getOrderCode()) %>">
                            <% } else { %>
                            QR SePay<br>
                            đang chờ cấu hình tài khoản nhận tiền
                            <% } %>
                        </div>
                        <div class="pay-lines">
                            <div class="pay-line">
                                <div class="pay-label">Số tiền</div>
                                <div class="pay-value amount" id="payAmount"><%= h(order.getTotalLabel()) %></div>
                            </div>
                            <div class="pay-line">
                                <div class="pay-label">Nội dung</div>
                                <div class="copy-row">
                                    <div class="pay-value" id="paymentContent"><%= h(order.getPaymentContent()) %></div>
                                    <button type="button" class="icon-btn" onclick="copyText('paymentContent')" title="Sao chép nội dung" aria-label="Sao chép nội dung">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                                    </button>
                                </div>
                            </div>
                            <div class="pay-line">
                                <div class="pay-label">Nhà cung cấp</div>
                                <div class="pay-value">SePay VietQR/Webhook</div>
                            </div>
                            <div class="pay-line">
                                <div class="pay-label">Tài khoản nhận</div>
                                <div class="pay-value"><%= h(bankLabel) %> - <%= h(bankAccountName) %></div>
                            </div>
                            <div class="helper-note access-note <%= h(accessNoticeClass) %>" id="accessNotice">
                                <%= h(accessNoticeMessage) %>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <aside class="panel">
                <div class="panel-header">
                    <div class="panel-title">Tóm tắt đơn</div>
                </div>
                <div class="panel-body">
                    <% for (CourseOrderItem item : order.getItems()) { %>
                    <div class="order-item">
                        <div class="order-item-title"><%= h(item.getCourseTitle()) %></div>
                        <div class="order-item-price"><%= h(item.getPriceLabel()) %></div>
                    </div>
                    <% } %>
                    <div class="summary-row total">
                        <span>Tổng cộng</span>
                        <span id="summaryTotal"><%= h(order.getTotalLabel()) %></span>
                    </div>
                    <div class="actions">
                        <button type="button" class="btn-main" onclick="checkPaymentStatus()">Kiểm tra thanh toán</button>
                        <a href="${pageContext.request.contextPath}/cart" class="btn-soft">Quay lại giỏ hàng</a>
                    </div>
                </div>
            </aside>
        </div>
    </main>

    <%@ include file="/WEB-INF/fragments/site-footer.jspf" %>

    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=3"></script>
    <script>
        function copyText(elementId) {
            const el = document.getElementById(elementId);
            if (!el) return;
            navigator.clipboard.writeText(el.textContent.trim()).then(() => {
                showCheckoutToast('Đã sao chép');
            }).catch(() => {
                showCheckoutToast('Không thể sao chép', true);
            });
        }

        function showCheckoutToast(message, error) {
            const oldToast = document.getElementById('checkoutToast');
            if (oldToast) oldToast.remove();
            const toast = document.createElement('div');
            toast.id = 'checkoutToast';
            toast.style.cssText = 'position:fixed;right:24px;bottom:24px;z-index:9999;background:' + (error ? '#dc2626' : '#059669') + ';color:white;padding:13px 18px;border-radius:10px;font-weight:800;box-shadow:0 12px 26px rgba(15,23,42,.18);';
            toast.textContent = message;
            document.body.appendChild(toast);
            setTimeout(() => toast.remove(), 2400);
        }

        async function checkPaymentStatus() {
            try {
                const response = await fetch('${pageContext.request.contextPath}/checkout?action=status&id=<%= h(order.getId()) %>');
                const data = await response.json();
                if (!data.success) {
                    showCheckoutToast(data.message || 'Không lấy được trạng thái', true);
                    return;
                }
                const status = document.getElementById('orderStatus');
                if (data.paid) {
                    status.textContent = 'Đã thanh toán';
                    status.classList.add('paid');
                    updateAccessNotice(data.accessStatus, data.accessMessage);
                    showCheckoutToast('Thanh toán đã được ghi nhận');
                } else {
                    status.textContent = 'Chờ thanh toán';
                    status.classList.remove('paid');
                    updateAccessNotice('waiting_payment', data.accessMessage);
                    showCheckoutToast('Đơn hàng vẫn đang chờ thanh toán');
                }
            } catch (err) {
                console.error(err);
                showCheckoutToast('Lỗi kiểm tra trạng thái', true);
            }
        }

        function updateAccessNotice(accessStatus, message) {
            const notice = document.getElementById('accessNotice');
            if (!notice) return;
            notice.classList.remove('success', 'failed', 'pending');
            if (accessStatus === 'granted' || accessStatus === 'pending_access') {
                notice.classList.add('success');
            } else if (accessStatus === 'failed') {
                notice.classList.add('failed');
            } else {
                notice.classList.add('pending');
            }
            if (message) {
                notice.textContent = message;
            }
        }

        setInterval(checkPaymentStatus, 5000);
    </script>
</body>
</html>

