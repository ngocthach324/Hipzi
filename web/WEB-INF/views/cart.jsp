<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.CartItem"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    User user = (User) session.getAttribute("loggedUser");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal cartTotal = (BigDecimal) request.getAttribute("cartTotal");
    
    NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
    String totalFormatted = (cartTotal != null) ? format.format(cartTotal) + " đ" : "0 đ";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng của bạn - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=11">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        body { font-family: "Inter", "Be Vietnam Pro", sans-serif; background: #f9f9f9; margin: 0; color: #111; }
        

        .checkout-container { max-width: 1380px; width: 96%; margin: 100px auto 50px; padding: 0 1rem; }
        
        /* Progress Bar */
        .progress-wrapper {
            max-width: 800px; margin: 0 auto 3rem auto;
            display: flex; justify-content: space-between; align-items: center; position: relative;
        }
        .progress-line {
            position: absolute; top: 12px; left: 0; right: 0; height: 2px; background: #e5e5e5; z-index: 1;
        }
        .progress-line-fill {
            position: absolute; top: 12px; left: 0; width: 0%; height: 2px; background: #00b167; z-index: 2;
        }
        .progress-step {
            position: relative; z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;
        }
        .step-circle {
            width: 24px; height: 24px; border-radius: 50%; background: #e5e5e5;
            display: flex; justify-content: center; align-items: center;
        }
        .step-circle.active { background: #00b167; }
        .step-circle.current { background: #fff; border: 4px solid #00b167; }
        .step-label { font-size: 0.9rem; font-weight: 600; color: #111; }

        /* Main Layout */
        .cart-grid { display: grid; grid-template-columns: 1fr 320px; gap: 2rem; align-items: start; }
        @media (max-width: 900px) { .cart-grid { grid-template-columns: 1fr; } }
        
        .panel { background: #fff; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .panel-title { font-size: 1.25rem; font-weight: 700; margin-bottom: 1.25rem; }
        .cart-header-title { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; }
        .cart-header-title .panel-title { margin-bottom: 0; }
        .selected-count-tag { background: #eaf8f1; color: #00b167; padding: 0.35rem 0.85rem; border-radius: 99px; font-size: 0.85rem; font-weight: 600; }

        /* Left Column - Product List */
        .cart-table-header { display: grid; grid-template-columns: 40px minmax(50%, 3fr) 1fr 1fr 40px; padding: 1rem 1rem 0.5rem 1rem; border-top: 1px solid #eee; margin-bottom: 0.5rem; color: #555; font-size: 0.9rem; font-weight: 500; align-items: center; }
        .col-qty, .col-price { text-align: center; }

        .product-item { display: grid; grid-template-columns: 40px minmax(50%, 3fr) 1fr 1fr 40px; align-items: center; padding: 1rem; border: 1px solid #eee; border-radius: 12px; margin-bottom: 1rem; }
        
        .item-checkbox { cursor: pointer; transform: scale(1.2); accent-color: #00b167; }

        .prod-info-group { display: flex; align-items: center; gap: 1rem; }
        .prod-img { width: 60px; height: 60px; object-fit: contain; background: #f8f8f8; border-radius: 8px; padding: 0.25rem; }
        .prod-details { display: flex; flex-direction: column; }
        .prod-name { font-weight: 600; font-size: 0.95rem; margin-bottom: 0.25rem; color: #000; line-height: 1.3; }
        .prod-variant { font-size: 0.8rem; color: #888; }

        .qty-controls { display: flex; align-items: center; justify-content: center; gap: 1rem; background: #f9f9f9; padding: 0.35rem 0.75rem; border-radius: 99px; width: fit-content; margin: 0 auto; }
        .qty-btn { background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #555; }
        .qty-val { font-weight: 600; font-size: 0.95rem; }

        .prod-price { font-weight: 700; font-size: 1.1rem; color: #000; text-align: center; }
        
        .btn-trash { background: none; border: none; color: #aaa; cursor: pointer; transition: color 0.2s; text-align: right; }
        .btn-trash:hover { color: #ef4444; }

        .cart-footer-actions { display: flex; justify-content: flex-end; align-items: center; margin-top: 2rem; padding-bottom: 2rem; }

        /* Right Column - Sidebars */
        .coupon-input { width: 100%; background: #f5f5f5; border: none; padding: 0.85rem 1rem; border-radius: 8px; margin-bottom: 1rem; font-family: inherit; font-size: 0.9rem; }
        .btn-outline-green { width: 100%; display: inline-flex; justify-content: center; align-items: center; background: #ffffff; border: 1px solid #00b167; color: #00b167; padding: 0.85rem; border-radius: 8px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.2s; text-decoration: none; }
        .btn-outline-green:hover { background: #eaf8f1; }
        .btn-outline-green:active { transform: scale(0.97); }

        .summary-row { display: flex; justify-content: space-between; margin-bottom: 0.75rem; font-size: 0.9rem; color: #888; font-weight: 500; }
        .summary-row.total { margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #eee; font-size: 1.25rem; font-weight: 700; color: #000; margin-bottom: 1.5rem; }
        
        .btn-checkout { width: 100%; display: inline-flex; justify-content: center; align-items: center; transition: all 0.2s; background: #00b167; color: #fff; border: none; padding: 1rem; border-radius: 8px; font-weight: 600; font-size: 1rem; cursor: pointer; box-shadow: 0 4px 12px rgba(0,177,103,0.2); }
        .btn-checkout:hover { background: #009858; }
        .btn-checkout:active { transform: scale(0.97); }

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
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
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

    <div class="checkout-container">
        <%
            String errorMsg = (String) session.getAttribute("errorMsg");
            if (errorMsg != null) {
                session.removeAttribute("errorMsg");
        %>
        <div style="margin-bottom:1rem; padding:1rem 1.25rem; border-radius:12px; background:#fef2f2; border:1px solid #fecaca; color:#b91c1c; font-weight:700;">
            <%= h(errorMsg) %>
        </div>
        <% } %>

        <form id="checkoutForm" action="${pageContext.request.contextPath}/checkout" method="POST" onsubmit="return checkoutSelected()">
        <div class="cart-grid">
            <!-- Left Column: Product List -->
            <div class="panel">
                <div class="cart-header-title">
                    <h2 class="panel-title">Giỏ hàng</h2>
                    <span class="selected-count-tag" id="selectedCount">Đã chọn: 0 khóa học</span>
                </div>
                
                <div class="cart-table-header">
                    <div><input type="checkbox" class="item-checkbox" id="selectAll" <%= (cartItems == null || cartItems.isEmpty()) ? "disabled" : "checked" %>></div>
                    <div>Khóa học</div>
                    <div class="col-qty">Số lượng</div>
                    <div class="col-price">Giá tiền</div>
                    <div></div>
                </div>

                <% if (cartItems != null && !cartItems.isEmpty()) {
                       for (CartItem item : cartItems) {
                           String thumbUrl = item.getThumbnailUrl();
                           String thumbStyle = (thumbUrl != null && !thumbUrl.trim().isEmpty())
                               ? "background-image:url('" + h(thumbUrl) + "'); background-size:cover; background-position:center;"
                               : "background:" + h(item.getThumbnailGradientOrDefault()) + "; display:flex; align-items:center; justify-content:center;";
                %>
                <div class="product-item" id="cart-item-<%= h(item.getCourseId()) %>">
                    <div><input type="checkbox" class="item-checkbox" name="courseId" value="<%= h(item.getCourseId()) %>" data-id="<%= h(item.getCourseId()) %>" data-price="<%= item.getPriceAmount() %>" checked></div>
                    <div class="prod-info-group">
                        <% if (thumbUrl != null && !thumbUrl.trim().isEmpty()) { %>
                            <img src="<%= h(thumbUrl) %>" alt="Product" class="prod-img" style="object-fit: cover;">
                        <% } else { %>
                            <div class="prod-img" style="<%= thumbStyle %>">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.58)" stroke-width="1.25"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z"/><path d="M8 7h8M8 11h6"/></svg>
                            </div>
                        <% } %>
                        <div class="prod-details">
                            <span class="prod-name"><a href="${pageContext.request.contextPath}/course-detail?id=<%= h(item.getCourseId()) %>" style="text-decoration:none; color:inherit;"><%= h(item.getCourseTitle()) %></a></span>
                            <span class="prod-variant">Giảng viên: <%= h(item.getTeacherName()) %></span>
                        </div>
                    </div>
                    <div class="qty-controls">
                        <span class="qty-val">1</span>
                    </div>
                    <div class="prod-price"><%= h(item.getPriceLabel()) %></div>
                    <button class="btn-trash" onclick="removeCartItem('<%= h(item.getCourseId()) %>')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    </button>
                </div>
                <%     }
                   } else { %>
                   <div class="product-item" style="display: flex; justify-content: center; align-items: center; border: 1px dashed #e5e7eb; background: #fafafa; padding: 2rem 1rem;">
                       <span style="color: #888; font-weight: 500;">Hiện tại không có khóa học nào trong giỏ hàng</span>
                   </div>
                <% } %>

                <div class="cart-footer-actions">
                    <a href="${pageContext.request.contextPath}/courses" class="btn-outline-green" style="width: auto;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px;"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                        Khám phá thêm khóa học
                    </a>
                </div>
            </div>

            <!-- Right Column: Sidebar -->
            <div>
                <!-- Coupon Panel -->
                <div class="panel">
                    <h2 class="panel-title">Mã giảm giá</h2>
                    <input type="text" class="coupon-input" placeholder="Nhập mã giảm giá của bạn">
                    <button class="btn-outline-green">Áp dụng mã</button>
                </div>

                <!-- Order Summary Panel -->
                <div class="panel">
                    <h2 class="panel-title">Tóm tắt đơn hàng</h2>
                    <div class="summary-row">
                        <span>Tổng tiền</span>
                        <span id="summaryTotal">0 đ</span>
                    </div>
                    <div class="summary-row">
                        <span>Giảm giá</span>
                        <span id="summaryDiscount">0 đ</span>
                    </div>

                    <div class="summary-row total">
                        <span>Thành tiền</span>
                        <span id="summaryFinal">0 đ</span>
                    </div>
                    
                    <button type="submit" class="btn-checkout">Thanh toán ngay</button>
                </div>
            </div>
        </div>
        </form>
    </div>
    
    <%@ include file="/WEB-INF/fragments/site-footer.jspf" %>
    
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
    <script>
        // Format number to currency
        function formatCurrency(num) {
            return new Intl.NumberFormat('vi-VN').format(num) + ' đ';
        }

        async function removeCartItem(courseId) {
            if (!confirm('Bạn có chắc muốn bỏ khóa học này khỏi giỏ hàng?')) return;
            try {
                const formData = new URLSearchParams();
                formData.append('action', 'remove');
                formData.append('courseId', courseId);
                
                const response = await fetch('${pageContext.request.contextPath}/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                });
                
                const data = await response.json();
                if (data.success) {
                    // Update header cart count
                    if (window.updateCartCountUI) {
                        window.updateCartCountUI(data.count);
                    } else {
                        const cartBadge = document.querySelector('.navbar-cart .cart-badge');
                        if (cartBadge) {
                            cartBadge.innerText = data.count;
                            cartBadge.style.display = data.count > 0 ? 'flex' : 'none';
                        }
                    }
                    
                    // Remove from DOM
                    const itemEl = document.getElementById('cart-item-' + courseId);
                    if (itemEl) itemEl.remove();
                    
                    // Trigger recalcs
                    window.recalcCartTotals();
                    
                    // If no items left, reload to show empty state
                    if (document.querySelectorAll('.product-item').length === 0) {
                        window.location.reload();
                    }
                } else {
                    alert(data.message || 'Không thể xóa khóa học khỏi giỏ hàng.');
                }
            } catch (err) {
                console.error(err);
                alert('Lỗi kết nối. Vui lòng thử lại.');
            }
        }

        function checkoutSelected() {
            const selected = Array.from(document.querySelectorAll('.product-item .item-checkbox'))
                                .filter(cb => cb.checked)
                                .map(cb => cb.getAttribute('data-id'));
            
            if (selected.length === 0) {
                alert('Vui lòng chọn ít nhất 1 khóa học để thanh toán.');
                return false;
            }
            
            return true;
        }

        document.addEventListener('DOMContentLoaded', function() {
            const selectAllCheckbox = document.getElementById('selectAll');
            
            window.recalcCartTotals = function() {
                const itemCheckboxes = document.querySelectorAll('.product-item .item-checkbox');
                const selectedCountEl = document.getElementById('selectedCount');
                
                let count = 0;
                let total = 0;
                let discount = 0; // Discount logic can be added later

                itemCheckboxes.forEach(cb => {
                    if (cb.checked) {
                        count++;
                        total += parseFloat(cb.getAttribute('data-price')) || 0;
                    }
                });

                if (selectedCountEl) {
                    selectedCountEl.textContent = 'Đã chọn: ' + count + ' khóa học';
                }

                // Update summary
                document.getElementById('summaryTotal').textContent = formatCurrency(total);
                document.getElementById('summaryDiscount').textContent = discount > 0 ? '- ' + formatCurrency(discount) : '0 đ';
                document.getElementById('summaryFinal').textContent = formatCurrency(total - discount);
            };

            const itemCheckboxes = document.querySelectorAll('.product-item .item-checkbox');

            if (itemCheckboxes.length > 0) {
                window.recalcCartTotals();

                // When selectAll is clicked
                if (selectAllCheckbox) {
                    selectAllCheckbox.addEventListener('change', function() {
                        const isChecked = this.checked;
                        document.querySelectorAll('.product-item .item-checkbox').forEach(function(checkbox) {
                            checkbox.checked = isChecked;
                        });
                        window.recalcCartTotals();
                    });
                }

                // When an individual item checkbox is clicked
                document.querySelectorAll('.product-item').forEach(function(itemEl) {
                    const cb = itemEl.querySelector('.item-checkbox');
                    if (cb) {
                        cb.addEventListener('change', function() {
                            // Check if all items are checked
                            const allCb = document.querySelectorAll('.product-item .item-checkbox');
                            const allChecked = Array.from(allCb).every(c => c.checked);
                            if (selectAllCheckbox) selectAllCheckbox.checked = allChecked;
                            window.recalcCartTotals();
                        });
                    }
                });
            } else {
                if (selectAllCheckbox) selectAllCheckbox.disabled = true;
            }
        });
    </script>
</body>
</html>
