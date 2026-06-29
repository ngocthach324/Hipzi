<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Role"%>
<%@page import="com.hipzi.model.Notification"%>
<%@page import="com.hipzi.model.SystemOverviewStats"%>
<%@page import="com.hipzi.model.AdminUserSummary"%>
<%@page import="com.hipzi.service.NotificationService"%>
<%@page import="com.hipzi.util.UserStatusWebSocket"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Locale"%>
<%
    User user = (User) request.getAttribute("user");
    if (user == null) {
        user = (User) session.getAttribute("loggedUser");
    }
    NotificationService notiService = new NotificationService();
    List<Notification> topNotifications = null;
    int unreadCount = 0;
    if (user != null) {
        topNotifications = notiService.getRecentNotifications(user.getId(), 5);
        unreadCount = notiService.getUnreadCount(user.getId());
    }
%>
<%!
    private String escAttr(String value) {
        if (value == null) return "";
        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều khiển Quản trị - HIPZI</title>
    <meta name="description" content="Trung tâm quản trị hệ thống, giám sát phân quyền, theo dõi hoạt động và nhật ký kiểm toán HIPZI.">
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <style>
        /* ===== OVERRIDE NỀN TẢNG & GIAO DIỆN PREMIUM TƯƠNG TỰ BẢN THIẾT KẾ ===== */
        body {
            background: linear-gradient(135deg, #e6fcf5 0%, #ebfbee 50%, #dcfce7 100%);
            background-repeat: no-repeat;
            background-attachment: fixed;
            min-height: 100vh;
        }

        /* ===== BỐ CỤC CHÍNH CỦA TRANG PROFILE ===== */
        .app-dashboard-container {
            max-width: 1320px;
            width: calc(100% - 3rem);
            height: calc(100vh - 12rem - 10px);
            min-height: 560px;
            margin: calc(1rem + 10px) auto 1.5rem auto;
            padding: 0;
            display: flex;
            flex-direction: column;
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 1.5rem;
            box-shadow: 0 16px 38px rgba(5, 150, 105, 0.08);
            overflow: hidden;
        }

        .dashboard-unified-header {
            background: linear-gradient(135deg, var(--primary) 0%, #047857 100%);
            padding: 0 1.75rem;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            position: relative;
            gap: 1rem;
            flex-shrink: 0;
            height: 64px;
            min-height: 64px;
            border-radius: 1.5rem 1.5rem 0 0;
        }

        .unified-header-tab-title {
            position: absolute;
            left: 50%;
            transform: translateX(-50%);
            font-size: 1.2rem;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: 0.3px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            transition: opacity 0.2s ease;
            pointer-events: none;
            max-width: calc(100% - 21rem);
        }

        .unified-header-right {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #ffffff;
            font-size: 0.85rem;
            font-weight: 600;
            background: rgba(255,255,255,0.15);
            padding: 0.4rem 0.85rem;
            border-radius: 1rem;
            flex-shrink: 0;
        }

        .dashboard-body {
            display: flex;
            flex-direction: row;
            flex: 1;
            min-height: 0;
            overflow: hidden;
        }

        /* ===== KHU VỰC SIDEBAR BÊN TRÁI (LEFT NAVIGATION PANE) ===== */
        .dashboard-sidebar {
            background: transparent;
            border-right: 1px solid rgba(226, 232, 240, 0.9);
            padding: 1rem 1rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            width: 270px;
            flex-shrink: 0;
            height: 100%;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            justify-content: space-between;
        }

        /* Nav menu items */
        .sidebar-menu {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar-menu li a {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.85rem 1rem;
            border-radius: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 0.95rem;
            text-decoration: none;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            cursor: pointer;
        }

        .sidebar-menu li a .menu-label-group {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .sidebar-menu li a svg {
            stroke-width: 2.2;
            transition: transform 0.2s ease;
            flex-shrink: 0;
        }

        .sidebar-menu li a:hover {
            color: var(--primary);
            background: var(--primary-light);
            transform: translateX(4px);
        }

        .sidebar-menu li a.active {
            color: var(--primary);
            background: var(--primary-light);
            font-weight: 700;
        }

        .sidebar-menu li a.active svg {
            stroke: var(--primary);
        }

        .menu-indicator {
            font-size: 1.1rem;
            color: var(--border-dark);
            transition: color 0.2s ease;
        }

        .sidebar-menu li a:hover .menu-indicator,
        .sidebar-menu li a.active .menu-indicator {
            color: var(--primary);
        }

        .menu-divider {
            height: 1px;
            background: var(--border-dark);
            margin: 0.75rem 0.5rem;
        }

        .sidebar-mascot-box {
            width: 100%;
            height: auto;
            margin-top: 26px;
            background: transparent;
            display: flex;
            align-items: center;
            justify-content: center;
            box-sizing: border-box;
            overflow: visible;
        }

        .sidebar-cute-mascot {
            width: 68px;
            height: 68px;
            object-fit: contain;
            filter: drop-shadow(0 8px 14px rgba(15, 23, 42, 0.12));
            animation: mascotFloat 3.2s ease-in-out infinite;
            transform-origin: bottom center;
            transition: transform 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275), filter 0.3s ease;
            cursor: pointer;
        }

        .sidebar-cute-mascot:hover {
            transform: scale(1.18) rotate(4deg) translateY(-6px);
            filter: drop-shadow(0 12px 20px rgba(16, 185, 129, 0.28));
        }

        @keyframes mascotFloat {
            0%, 100% { transform: translateY(0) rotate(-2deg); }
            50% { transform: translateY(-6px) rotate(2deg); }
        }

        /* Thẻ User tóm tắt ở dưới cùng sidebar (Lấy cảm hứng từ góc dưới bên trái của thiết kế) */
        .sidebar-user-card {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            border-radius: 1rem;
            padding: 0.85rem 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.25);
            text-decoration: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            flex-shrink: 0;
        }

        .sidebar-user-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(245, 158, 11, 0.35);
        }

        .sidebar-user-info {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            overflow: hidden;
        }

        .sidebar-user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: #ffffff;
            color: #d97706;
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            flex-shrink: 0;
            border: 2px solid rgba(255, 255, 255, 0.6);
            object-fit: cover;
        }

        .sidebar-user-details {
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .sidebar-user-name {
            font-weight: 700;
            font-size: 0.85rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .sidebar-user-email {
            font-size: 0.7rem;
            opacity: 0.9;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .sidebar-user-action {
            background: rgba(255, 255, 255, 0.2);
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: background 0.2s ease;
        }

        .sidebar-user-card:hover .sidebar-user-action {
            background: rgba(255, 255, 255, 0.3);
        }


        /* ===== NỘI DUNG CHÍNH (RIGHT CONTENT PANE) ===== */
        .dashboard-content-wrapper {
            display: flex;
            flex-direction: column;
            gap: 0;
            flex: 1;
            min-width: 0;
            padding: 0;
            min-height: 0;
            overflow-y: auto;
        }

        .dashboard-content-wrapper.is-switching-tab {
            overflow-anchor: none;
            transition: min-height 0.25s ease;
        }

        /* Dải tiêu đề trang trọng phía trên cùng */
        .dashboard-top-strip {
            background: linear-gradient(135deg, #047857 0%, #065f46 100%);
            border-radius: 1.25rem;
            padding: 1.15rem 1.75rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: #ffffff;
            box-shadow: 0 10px 25px rgba(4, 120, 87, 0.15);
        }

        .strip-right-controls {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .strip-date {
            font-size: 0.9rem;
            font-weight: 600;
            color: #ecfdf5;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .strip-actions-group {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .strip-btn {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.2);
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            cursor: pointer;
            position: relative;
            transition: all 0.2s ease;
        }

        .strip-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: scale(1.05);
        }

        .strip-pill-btn {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.2);
            height: 40px;
            padding: 0 1rem;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #ffffff;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 700;
            font-size: 0.85rem;
        }

        .strip-pill-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: scale(1.03);
        }

        .badge-counter {
            position: absolute;
            top: -2px;
            right: -2px;
            background: #ef4444;
            color: #ffffff;
            font-size: 0.65rem;
            font-weight: 800;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        /* ===== QUẢN LÝ TAB VIEW ===== */
        .tab-pane {
            display: none;
            opacity: 1;
            transform: none;
            flex-direction: column;
            flex: 1;
            min-height: 0;
            gap: 0;
        }

        .tab-pane.active-pane {
            display: flex;
            opacity: 1;
            transform: none;
            animation: none;
        }

        @media (prefers-reduced-motion: reduce) {
            .dashboard-content-wrapper.is-switching-tab,
            .tab-pane.active-pane {
                transition: none;
                animation: none;
            }

            .tab-pane.active-pane {
                opacity: 1;
                transform: none;
            }
        }


        /* ===== CARD 1: USER HIGHLIGHT CARD ===== */
        .profile-highlight-card {
            background: #ffffff;
            border-radius: 1.25rem;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.02);
            padding: 1.5rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1.5rem;
        }

        .highlight-left-group {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .highlight-avatar-container {
            position: relative;
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            padding: 3px;
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.15);
            flex-shrink: 0;
        }

        .highlight-avatar-container img,
        .highlight-avatar-placeholder {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #ffffff;
        }

        .highlight-avatar-placeholder {
            background: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            font-weight: 800;
            color: var(--secondary);
        }

        .highlight-user-info {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
        }

        .highlight-user-info h2 {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--text-main);
            margin: 0;
        }

        .highlight-user-roles {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .role-tag {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.2rem 0.75rem;
            border-radius: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .role-tag.student { background: #e0f2fe; color: #0284c7; }
        .role-tag.parent  { background: #fef3c7; color: #d97706; }
        .role-tag.teacher { background: #f3e8ff; color: #7c3aed; }
        .role-tag.staff   { background: #dbeafe; color: #2563eb; }
        .role-tag.admin   { background: #fee2e2; color: #dc2626; }

        .highlight-meta-info {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 500;
            margin-top: 0.15rem;
        }

        .highlight-right-badge {
            background: var(--primary-light);
            border: 1px solid rgba(5, 150, 105, 0.15);
            padding: 0.75rem 1.25rem;
            border-radius: 1rem;
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 0.15rem;
        }

        .badge-sub-label {
            font-size: 0.7rem;
            font-weight: 700;
            color: var(--primary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-main-text {
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--text-main);
        }


        /* ===== CARD 2: SECTION DATA CARD ===== */
        .section-data-card {
            background: #ffffff;
            border-radius: 1.25rem;
            border: 1px solid rgba(226, 232, 240, 0.8);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.02);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .card-header-layout {
            padding: 1.25rem 1.75rem;
            border-bottom: 1px solid var(--border-dark);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: rgba(248, 250, 252, 0.4);
        }

        .card-header-title {
            font-size: 1.1rem;
            font-weight: 800;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 0.65rem;
        }

        .card-header-title svg {
            color: var(--primary);
        }

        .btn-card-edit {
            background: var(--primary);
            color: #ffffff;
            font-weight: 700;
            font-size: 0.85rem;
            padding: 0.5rem 1.15rem;
            border-radius: 0.65rem;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            text-decoration: none;
            box-shadow: 0 4px 10px rgba(5, 150, 105, 0.2);
            transition: all 0.2s ease;
            cursor: pointer;
            border: none;
        }

        .btn-card-edit:hover {
            background: var(--primary-hover);
            box-shadow: 0 6px 14px rgba(5, 150, 105, 0.3);
            transform: translateY(-1px);
        }

        .btn-card-edit-light {
            background: #ffffff;
            color: var(--text-main);
            font-weight: 600;
            font-size: 0.85rem;
            padding: 0.5rem 1.15rem;
            border-radius: 0.65rem;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            text-decoration: none;
            border: 1px solid var(--border-dark);
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn-card-edit-light:hover {
            background: #f1f5f9;
            border-color: #cbd5e1;
        }

        /* Nội dung lưới thông tin */
        .card-body-grid {
            padding: 1.75rem;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.75rem;
        }

        .data-item-group {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
        }

        .data-item-label {
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--text-muted);
        }

        .data-item-value {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-main);
            word-break: break-word;
        }

        .data-item-value.muted {
            color: var(--text-muted);
            font-weight: 500;
        }

        /* Trạng thái tài khoản badge */
        .acc-status-tag {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            font-size: 0.8rem;
            font-weight: 700;
            padding: 0.15rem 0.65rem;
            border-radius: 0.4rem;
        }
        .acc-status-tag.active { background: #dcfce7; color: #15803d; }
        .acc-status-tag.suspended { background: #fef9c3; color: #a16207; }
        .acc-status-tag.disabled { background: #fee2e2; color: #b91c1c; }

        /* Provider badge */
        .provider-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.8rem;
            font-weight: 600;
            color: #1e293b;
            background: #f1f5f9;
            padding: 0.2rem 0.75rem;
            border-radius: 1rem;
            border: 1px solid var(--border-dark);
        }

        /* ===== FORM CẬP NHẬT TRONG TAB CHỈNH SỬA ===== */
        .form-edit-layout {
            padding: 1.75rem;
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
        }

        .form-group-edit {
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }

        .form-group-edit label {
            font-weight: 600;
            font-size: 0.85rem;
            color: var(--text-main);
        }

        .form-group-edit input,
        .form-group-edit textarea {
            width: 100%;
            padding: 0.75rem 1rem;
            border-radius: 0.75rem;
            border: 1px solid var(--border-dark);
            font-family: inherit;
            font-size: 0.95rem;
            color: var(--text-main);
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .form-group-edit input:focus,
        .form-group-edit textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        .form-actions-row {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 0.5rem;
        }


        /* ===== CÁC STYLES CHO NAVBAR KHI ĐÃ ĐĂNG NHẬP ===== */
        .navbar-user-controls {
            display: flex;
            align-items: center;
            gap: 1.25rem;
        }

        .nav-bell-trigger {
            position: relative;
            color: var(--text-muted);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: #f1f5f9;
            transition: all 0.2s ease;
        }

        .nav-bell-trigger:hover {
            color: var(--primary);
            background: #e2e8f0;
            transform: scale(1.05);
        }

        .nav-bell-trigger .badge-dot {
            position: absolute;
            top: 6px;
            right: 6px;
            width: 8px;
            height: 8px;
            background-color: #ef4444;
            border-radius: 50%;
            border: 2px solid #ffffff;
        }

        .nav-avatar-dropdown {
            position: relative;
            display: inline-block;
        }

        .nav-avatar-frame {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            border: 2px solid var(--primary);
            padding: 2px;
            background: #ffffff;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(5, 150, 105, 0.15);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .nav-avatar-frame:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(5, 150, 105, 0.25);
        }

        .nav-avatar-frame img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }

        .nav-avatar-initials {
            font-weight: 800;
            font-size: 1rem;
            color: var(--primary);
        }

        .dropdown-menu-popup {
            position: absolute;
            right: 0;
            top: calc(100% + 0.5rem);
            background: #ffffff;
            border-radius: 1rem;
            border: 1px solid var(--border-dark);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
            min-width: 180px;
            padding: 0.5rem 0;
            opacity: 0;
            visibility: hidden;
            transform: translateY(10px);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            z-index: 100;
        }

        /* Thêm cầu nối gap bridge để chuột di chuyển từ Avatar xuống menu không bị mất hover */
        .dropdown-menu-popup::before {
            content: '';
            position: absolute;
            top: -15px;
            left: 0;
            width: 100%;
            height: 15px;
        }

        .nav-avatar-dropdown:hover .dropdown-menu-popup {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .dropdown-menu-popup a {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.65rem 1.25rem;
            color: var(--text-main);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.85rem;
            transition: background 0.2s ease, color 0.2s ease;
        }

        .dropdown-menu-popup a:hover {
            background: var(--primary-light);
            color: var(--primary);
        }

        .dropdown-menu-popup a.danger-link {
            color: #ef4444;
        }

        .dropdown-menu-popup a.danger-link:hover {
            background: #fef2f2;
            color: #ef4444;
        }

        /* ===== DANH SÁCH THÔNG BÁO POPUP (LIGHT MODE ĐỒNG BỘ) ===== */
        .nav-bell-dropdown {
            position: relative;
            display: inline-block;
        }

        .notification-popup-menu {
            position: absolute;
            right: -10px;
            top: calc(100% + 25px);
            background: #ffffff;
            border: 1px solid var(--border-dark);
            border-radius: 1.25rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            width: 320px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(10px);
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            z-index: 200;
            overflow: hidden;
        }

        /* Thêm cầu nối gap bridge cho menu thông báo */
        .notification-popup-menu::before {
            content: '';
            position: absolute;
            top: -25px;
            left: 0;
            width: 100%;
            height: 25px;
        }

        .notification-popup-menu.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .noti-popup-header {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid #f1f5f9;
            text-align: left;
        }

        .noti-popup-header span {
            color: #0f172a;
            font-size: 1.15rem;
            font-weight: 800;
            letter-spacing: 0.3px;
        }

        .noti-popup-list {
            max-height: 280px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        .noti-popup-list::-webkit-scrollbar {
            width: 4px;
        }
        .noti-popup-list::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 2px;
        }

        .noti-popup-item {
            padding: 0.85rem 1.25rem;
            border-bottom: 1px solid #f8fafc;
            display: flex;
            gap: 0.85rem;
            align-items: flex-start;
            cursor: pointer;
            transition: background 0.2s ease;
            text-align: left;
        }

        .noti-popup-item:hover {
            background: #f1f5f9;
        }

        .noti-icon-round {
            width: 36px;
            height: 36px;
            border-radius: 0.75rem;
            background: #ecfdf5;
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            margin-top: 0.1rem;
        }

        .noti-info-col {
            display: flex;
            flex-direction: column;
            gap: 0.2rem;
            overflow: hidden;
            width: 100%;
        }

        .noti-title {
            color: #0f172a;
            font-weight: 700;
            font-size: 0.9rem;
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .noti-desc {
            color: #475569;
            font-size: 0.8rem;
            line-height: 1.3;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .noti-date {
            color: #94a3b8;
            font-size: 0.72rem;
            margin-top: 0.1rem;
        }

        .noti-popup-footer {
            padding: 0.85rem;
            text-align: center;
            border-top: 1px solid #f1f5f9;
            background: #f8fafc;
        }

        .noti-popup-footer a {
            color: var(--primary);
            font-size: 0.85rem;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: color 0.2s ease;
            display: block;
        }

        .noti-popup-footer a:hover {
            color: var(--primary-hover);
        }

        /* ===== NÚT CAMERA OVERLAY ĐỂ ĐỔI AVATAR TRÊN THẺ HIGHLIGHT ===== */
        .btn-avatar-camera {
            position: absolute;
            bottom: 0;
            right: 0;
            width: 28px;
            height: 28px;
            background: #ffffff;
            border: 2px solid #e2e8f0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-muted);
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            transition: all 0.2s ease;
        }

        .btn-avatar-camera:hover {
            color: var(--primary);
            border-color: var(--primary);
            transform: scale(1.1);
            box-shadow: 0 4px 8px rgba(5, 150, 105, 0.2);
        }

        /* Các tiện ích trống mock UI cho sinh viên */
        .empty-status-panel {
            padding: 3rem 2rem;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.75rem;
            color: var(--text-muted);
        }

        .empty-status-panel svg {
            color: var(--border-dark);
            margin-bottom: 0.5rem;
        }

        /* Responsive layout */
        @media (max-width: 1024px) {
            .app-dashboard-container {
                height: auto;
                min-height: 100vh;
            }
            .dashboard-body {
                flex-direction: column;
            }
            .dashboard-sidebar {
                width: 100%;
                height: auto;
                border-right: none;
                border-bottom: 1px solid rgba(226, 232, 240, 0.9);
            }
            .sidebar-bottom-group,
            .sidebar-mascot-box {
                display: none;
            }
            .card-body-grid {
                grid-template-columns: repeat(2, 1fr) !important;
            }
        }

        @media (max-width: 640px) {
            .app-dashboard-container {
                width: calc(100% - 1rem);
                margin-top: 0.75rem;
                border-radius: 1rem;
            }
            .dashboard-unified-header {
                height: auto;
                min-height: 64px;
                padding: 0.85rem 1rem;
                justify-content: center;
                flex-direction: column;
                border-radius: 1rem 1rem 0 0;
            }
            .unified-header-tab-title {
                position: static;
                transform: none;
                max-width: 100%;
            }
            .card-body-grid {
                grid-template-columns: 1fr !important;
                gap: 1.25rem;
            }
            .dashboard-top-strip {
                flex-direction: column;
                gap: 1rem;
                align-items: stretch;
            }
            .strip-right-controls {
                justify-content: space-between;
            }
            .profile-highlight-card {
                flex-direction: column;
                align-items: flex-start;
            }
            .highlight-right-badge {
                width: 100%;
                align-items: flex-start;
            }
        }

        /* ===== HỆ THỐNG THÔNG BÁO TOAST GÓC DƯỚI BÊN PHẢI ===== */
        .custom-toast-container {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            z-index: 9999;
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            pointer-events: none;
        }

        .custom-toast-msg {
            background: #10b981;
            color: #ffffff;
            padding: 0.85rem 1.25rem;
            border-radius: 0.75rem;
            font-weight: 700;
            font-size: 0.85rem;
            box-shadow: 0 10px 25px rgba(16, 185, 129, 0.35);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            pointer-events: auto;
            animation: slideInToast 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards, fadeOutToast 0.3s ease 2.7s forwards;
        }

        .custom-toast-msg.info {
            background: #0ea5e9;
            box-shadow: 0 10px 25px rgba(14, 165, 233, 0.35);
        }

        @keyframes slideInToast {
            from { transform: translateX(120%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        @keyframes fadeOutToast {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(120%); opacity: 0; }
        }

        @keyframes fadeInOverlay {
            from { opacity: 0; transform: scale(0.98); }
            to { opacity: 1; transform: scale(1); }
        }

        /* ===== HIPZI ANIMATED BRAND LOGO (BOTTOM SIDEBAR) ===== */
        .animated-brand-box {
            background: linear-gradient(135deg, rgba(248, 250, 252, 0.8) 0%, rgba(241, 245, 249, 0.9) 100%);
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 1rem;
            padding: 0.65rem 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.65rem;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
            position: relative;
            overflow: hidden;
        }

        .animated-brand-box::before {
            content: "";
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(16, 185, 129, 0.08) 0%, transparent 70%);
            animation: rotateGlow 8s linear infinite;
        }

        .animated-brand-box:hover {
            transform: translateY(-2px);
            border-color: rgba(16, 185, 129, 0.3);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.12);
        }

        .brand-logo-ring {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: #ffffff;
            padding: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
            flex-shrink: 0;
            animation: pulseRing 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
            position: relative;
            z-index: 1;
        }

        .brand-logo-ring img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            animation: gentleFloat 3s ease-in-out infinite alternate;
        }

        .brand-text-pulse {
            display: flex;
            flex-direction: column;
            align-items: center;
            z-index: 1;
        }

        .brand-title {
            font-size: 1.25rem;
            font-weight: 900;
            background: linear-gradient(135deg, #047857 0%, #10b981 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 0.5px;
        }

        @keyframes rotateGlow {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        @keyframes pulseRing {
            0%, 100% { box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2); }
            50% { box-shadow: 0 0 0 6px rgba(16, 185, 129, 0.4); }
        }

        @keyframes gentleFloat {
            from { transform: translateY(-1px) scale(0.98); }
            to { transform: translateY(1px) scale(1.02); }
        }
        /* ===== NEW: GROUPED TAB LAYOUT CLASSES ===== */
        .tab-grouped-container {
            border-radius: 0;
            overflow-y: auto;
            border: none;
            box-shadow: none;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            flex: 1;
            min-height: 0;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .tab-header-accent {
            background: transparent;
            padding: 0;
            display: none;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
            color: #ffffff;
        }

        .tab-header-title-text {
            font-size: 1.35rem;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .tab-header-date-pill {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.85rem;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.15);
            padding: 0.4rem 0.85rem;
            border-radius: 1rem;
        }

        .tab-body-content {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            padding: 2rem;
            display: flex;
            flex-direction: column;
            gap: 2rem;
            flex: 1;
            min-height: 0;
            overflow-y: auto;
        }

        #tab-profile,
        #tab-edit {
            gap: 2rem;
        }

        #tab-profile .tab-pane-header,
        #tab-edit .tab-pane-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 1rem;
            border-bottom: 1px solid var(--border-dark);
            padding-bottom: 1rem;
        }

        .tab-pane-header-left h1 {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-main);
            margin: 0 0 0.35rem 0;
        }

        .tab-pane-header-left p {
            font-size: 0.95rem;
            color: #475569;
            margin: 0;
            font-weight: 600;
        }

        .tab-pane-header-right {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .date-badge {
            background: #ffffff;
            border: 1px solid var(--border-dark);
            padding: 0.5rem 1rem;
            border-radius: 1rem;
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: var(--shadow);
        }

        .metrics-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.25rem;
        }

        @media (max-width: 1024px) {
            .metrics-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 640px) {
            .metrics-row {
                grid-template-columns: 1fr;
            }
        }

        .metric-card {
            border-radius: 1.5rem;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 140px;
            box-sizing: border-box;
            position: relative;
            overflow: hidden;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-top: 4px solid var(--primary);
            color: var(--text-main);
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
        }

        .metrics-row .metric-card:nth-child(1) { border-top-color: var(--primary); }
        .metrics-row .metric-card:nth-child(2) { border-top-color: #7c3aed; }
        .metrics-row .metric-card:nth-child(3) { border-top-color: #ea580c; }
        .metrics-row .metric-card:nth-child(4) { border-top-color: #2563eb; }

        .metric-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 34px rgba(15, 23, 42, 0.1);
        }

        .metric-card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 1rem;
        }

        .metric-card-title {
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
        }

        .metric-arrow-btn {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-dark);
            background: var(--border-light);
            color: var(--text-main);
            transition: all 0.2s ease;
            flex-shrink: 0;
        }

        .metric-card-value {
            font-size: 1.45rem;
            font-weight: 800;
            margin: 0.75rem 0 0.35rem 0;
            line-height: 1.15;
            position: relative;
            z-index: 1;
            word-break: break-word;
        }

        .metric-card-value.compact {
            font-size: 1rem;
        }

        .metric-card-sub {
            font-size: 0.78rem;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            padding: 0.24rem 0.62rem;
            border-radius: 0.5rem;
            width: fit-content;
            position: relative;
            z-index: 1;
            background: var(--primary-light);
            color: var(--primary);
        }

        .metric-ghost-icon {
            position: absolute;
            right: 1.15rem;
            bottom: 1rem;
            width: 64px;
            height: 64px;
            border-radius: 1.25rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            background: var(--primary-light);
            opacity: 0.28;
            transform: rotate(-6deg);
            pointer-events: none;
        }

        .metric-ghost-icon svg {
            width: 34px;
            height: 34px;
            stroke-width: 2.1;
        }

        .dashboard-grid-layout {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 1.5rem;
        }

        @media (max-width: 900px) {
            .dashboard-grid-layout {
                grid-template-columns: 1fr;
            }
        }

        .premium-card {
            background: #f8fafc;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            padding: 1.5rem;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
            box-sizing: border-box;
        }

        .premium-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-light);
            padding-bottom: 0.85rem;
            gap: 1rem;
        }

        .premium-card-title {
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .premium-card-title svg {
            color: var(--primary);
            width: 20px;
            height: 20px;
        }

        .account-header-actions,
        .account-edit-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .account-summary-panel {
            background: #ffffff;
            border: 1px solid var(--border-light);
            border-radius: 1.25rem;
            padding: 1.25rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .account-summary-main {
            display: flex;
            align-items: center;
            gap: 1rem;
            min-width: 0;
            flex: 1;
        }

        .account-avatar-wrap {
            position: relative;
            width: 76px;
            height: 76px;
            flex-shrink: 0;
        }

        .account-avatar-img,
        .account-avatar-placeholder {
            width: 76px;
            height: 76px;
            border-radius: 1.15rem;
            border: 1px solid rgba(4, 120, 87, 0.12);
            box-shadow: 0 10px 20px rgba(4, 120, 87, 0.08);
        }

        .account-avatar-img {
            object-fit: cover;
            display: block;
        }

        .account-avatar-placeholder {
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
            color: var(--primary);
            font-size: 1.8rem;
            font-weight: 900;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .avatar-camera-btn {
            position: absolute;
            right: -6px;
            bottom: -6px;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            border: 2px solid #ffffff;
            background: var(--primary);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 8px 16px rgba(4, 120, 87, 0.24);
            transition: all 0.2s ease;
        }

        .avatar-camera-btn:hover {
            background: var(--primary-hover);
            transform: translateY(-1px);
        }

        .account-identity {
            min-width: 0;
            flex: 1;
        }

        .account-name {
            margin: 0;
            color: var(--text-main);
            font-size: 1.25rem;
            font-weight: 850;
            line-height: 1.25;
        }

        .account-name-edit-form {
            width: min(100%, 360px);
            margin: 0;
        }

        .account-name-input {
            width: 100%;
            min-height: 2.7rem;
            border: 1px solid #cbd5e1;
            border-radius: 0.8rem;
            background: #ffffff;
            color: var(--text-main);
            font: inherit;
            font-size: 1rem;
            font-weight: 650;
            padding: 0.65rem 0.9rem;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .account-name-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(4, 120, 87, 0.12);
        }

        .account-email {
            display: block;
            margin-top: 0.25rem;
            color: #475569;
            font-size: 0.92rem;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .account-side-meta {
            display: flex;
            align-items: stretch;
            gap: 0.75rem;
            margin-left: auto;
            flex-shrink: 0;
        }

        .account-meta-pill {
            min-width: 150px;
            border: 1px solid var(--border-light);
            border-radius: 1rem;
            background: #f8fafc;
            padding: 0.75rem 0.9rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 0.22rem;
        }

        .account-meta-label {
            color: var(--text-muted);
            font-size: 0.68rem;
            font-weight: 850;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .account-meta-value {
            color: var(--text-main);
            font-size: 0.9rem;
            font-weight: 800;
            white-space: nowrap;
        }

        .btn-premium {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            min-height: 44px;
            padding-block: 0.68rem;
            padding-inline: 1.25rem;
            font-weight: 700;
            font-size: 0.85rem;
            line-height: 1.15;
            white-space: nowrap;
            border-radius: 0.85rem;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            font-family: inherit;
            text-decoration: none;
        }

        .btn-premium.primary,
        .btn-premium.profile-edit-btn,
        .account-save-btn {
            background: var(--primary);
            color: #ffffff;
            border: 1px solid var(--primary);
            box-shadow: 0 10px 20px rgba(4, 120, 87, 0.16);
        }

        .btn-premium.primary:hover,
        .btn-premium.profile-edit-btn:hover,
        .account-save-btn:hover {
            background: var(--primary-hover);
            border-color: var(--primary-hover);
            transform: translateY(-1px);
        }

        .btn-premium.secondary,
        .account-cancel-btn {
            background: #ffffff;
            color: var(--text-main);
            border: 1px solid var(--border-dark);
            box-shadow: var(--shadow);
        }

        .btn-premium.secondary:hover,
        .account-cancel-btn:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
        }

        .form-group-premium {
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }

        .form-group-premium label {
            font-weight: 700;
            font-size: 0.82rem;
            color: var(--text-main);
        }

        .form-group-premium input,
        .form-group-premium select,
        .form-group-premium textarea {
            width: 100%;
            padding: 0.75rem 1rem;
            border-radius: 0.75rem;
            border: 1px solid var(--border-dark);
            font-family: inherit;
            font-size: 0.92rem;
            color: var(--text-main);
            outline: none;
            background: #ffffff;
            transition: all 0.2s ease;
            box-sizing: border-box;
        }

        .form-group-premium input:focus,
        .form-group-premium select:focus,
        .form-group-premium textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        .form-actions-row-premium {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            flex-wrap: wrap;
        }

        @media (max-width: 640px) {
            .account-summary-panel {
                align-items: flex-start;
                flex-direction: column;
            }

            .account-summary-main,
            .account-side-meta {
                width: 100%;
            }

            .account-side-meta {
                margin-left: 0;
                flex-direction: column;
            }

            .account-meta-pill {
                min-width: 0;
            }
        }

        /* Profile Specific Styles */
        .profile-hero-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1.5rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px dashed #e2e8f0;
        }

        .hero-user-details {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .hero-role-display {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            text-align: right;
        }

        .role-display-label {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: block;
            margin-bottom: 0.35rem;
        }

        /* Enhanced Data Cards */
        .premium-data-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.25rem;
        }

        .info-card-premium {
            background: #ffffff;
            border-radius: 1.25rem;
            padding: 1.25rem 1.35rem;
            border: 1px solid transparent;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .info-card-premium:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
            border-color: var(--primary-light);
        }

        .info-card-icon-box {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-shrink: 0;
            transition: transform 0.3s ease;
        }

        .info-card-premium:hover .info-card-icon-box {
            transform: scale(1.1) rotate(5deg);
        }

        .info-card-text-group {
            min-width: 0;
            flex-grow: 1;
        }

        .info-card-label {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: block;
            margin-bottom: 0.15rem;
        }

        .info-card-value {
            font-size: 1.15rem;
            font-weight: 700;
            color: #0f172a;
            display: block;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .info-card-subtext {
            font-size: 0.75rem;
            color: #64748b;
            display: block;
            margin-top: 0.1rem;
        }

        /* Color Variations for Premium Cards */
        .card-green { border-color: #dcfce7; }
        .card-green .info-card-icon-box { background: #ecfdf5; color: #059669; }
        .card-green .info-card-label { color: #059669; }

        .card-blue { border-color: #e0e7ff; }
        .card-blue .info-card-icon-box { background: #e0e7ff; color: #4f46e5; }
        .card-blue .info-card-label { color: #4f46e5; }

        .card-amber { border-color: #fef3c7; }
        .card-amber .info-card-icon-box { background: #fffbeb; color: #d97706; }
        .card-amber .info-card-label { color: #d97706; }

        .card-red { border-color: #fee2e2; }
        .card-red .info-card-icon-box { background: #fef2f2; color: #ef4444; }
        .card-red .info-card-label { color: #ef4444; }

        .system-overview-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 1.25rem;
        }

        .system-metric-card {
            background: #ffffff;
            border: 1px solid #dcfce7;
            border-radius: 1.25rem;
            padding: 1.35rem;
            box-shadow: 0 6px 18px rgba(16, 185, 129, 0.04);
            display: flex;
            flex-direction: column;
            gap: 0.85rem;
            min-height: 150px;
        }

        .system-metric-icon {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            background: #ecfdf5;
            color: #059669;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .system-metric-label {
            color: #059669;
            font-size: 0.78rem;
            font-weight: 800;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .system-metric-value {
            color: #0f172a;
            font-size: 1.85rem;
            line-height: 1.1;
            font-weight: 850;
        }

        .system-metric-note {
            color: #64748b;
            font-size: 0.82rem;
            font-weight: 600;
            margin-top: auto;
        }

        .role-breakdown-panel {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1.25rem;
            padding: 1.5rem;
            box-shadow: 0 6px 18px rgba(15, 23, 42, 0.03);
        }

        .role-breakdown-title {
            margin: 0 0 1.25rem 0;
            font-size: 1.05rem;
            font-weight: 850;
            color: #0f172a;
        }

        .role-breakdown-list {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
        }

        .role-breakdown-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            padding: 1rem;
            border-radius: 1rem;
            background: #f8fafc;
            border: 1px solid #eef2f7;
        }

        .role-breakdown-name {
            color: #475569;
            font-size: 0.9rem;
            font-weight: 750;
            text-transform: capitalize;
        }

        .role-breakdown-count {
            color: #059669;
            font-size: 1.2rem;
            font-weight: 850;
        }

        .admin-user-table-wrap {
            overflow-x: auto;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1.25rem;
            box-shadow: 0 6px 18px rgba(15, 23, 42, 0.03);
        }

        .admin-user-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 820px;
        }

        .admin-user-table th {
            text-align: left;
            color: #64748b;
            background: #f8fafc;
            font-size: 0.76rem;
            font-weight: 850;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .admin-user-table td {
            padding: 1rem 1.15rem;
            border-bottom: 1px solid #f1f5f9;
            color: #0f172a;
            font-size: 0.9rem;
            vertical-align: middle;
        }

        .admin-user-table tr:last-child td { border-bottom: none; }

        .managed-user-name {
            display: flex;
            flex-direction: column;
            gap: 0.2rem;
            font-weight: 850;
        }

        .managed-user-email {
            color: #64748b;
            font-size: 0.78rem;
            font-weight: 600;
        }

        .managed-role-pill {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            background: #ecfdf5;
            color: #059669;
            padding: 0.28rem 0.75rem;
            font-size: 0.74rem;
            font-weight: 850;
            text-transform: capitalize;
        }

        .live-status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            border-radius: 999px;
            padding: 0.3rem 0.75rem;
            font-size: 0.74rem;
            font-weight: 850;
            text-transform: uppercase;
        }

        .live-status-badge::before {
            content: "";
            width: 7px;
            height: 7px;
            border-radius: 999px;
            background: currentColor;
        }

        .live-status-online { background: #dcfce7; color: #16a34a; }
        .live-status-offline { background: #f1f5f9; color: #64748b; }

        .account-status-pill {
            display: inline-flex;
            border-radius: 999px;
            padding: 0.25rem 0.65rem;
            font-size: 0.72rem;
            font-weight: 850;
            background: #dcfce7;
            color: #15803d;
            text-transform: uppercase;
        }

        .account-status-pill.disabled,
        .account-status-pill.suspended {
            background: #fee2e2;
            color: #b91c1c;
        }

        .admin-user-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .table-action-btn {
            border: none;
            border-radius: 999px;
            width: 36px;
            height: 36px;
            padding: 0;
            font-size: 0.76rem;
            font-weight: 850;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: transform 0.2s ease, box-shadow 0.2s ease, opacity 0.2s ease;
        }

        .table-action-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(15, 23, 42, 0.08);
        }

        .table-action-btn.detail { background: #ecfdf5; color: #059669; }
        .table-action-btn.ban { background: #fff1f2; color: #e11d48; }
        .table-action-btn:disabled { opacity: 0.5; cursor: not-allowed; }

        .admin-pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .admin-page-links {
            display: flex;
            gap: 0.4rem;
            flex-wrap: wrap;
        }

        .admin-page-link {
            min-width: 36px;
            height: 36px;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #ffffff;
            border: 1px solid #dbe4ea;
            color: #475569;
            text-decoration: none;
            font-weight: 850;
            font-size: 0.82rem;
        }

        .admin-page-link.active {
            background: #059669;
            border-color: #059669;
            color: #ffffff;
        }

        .admin-user-modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.38);
            backdrop-filter: blur(7px);
            display: none;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
            z-index: 2000;
        }

        .admin-user-modal-backdrop.active { display: flex; }

        .admin-user-modal {
            width: min(460px, 100%);
            background: #ffffff;
            border-radius: 1.25rem;
            border: 1px solid #e2e8f0;
            box-shadow: 0 24px 55px rgba(15, 23, 42, 0.22);
            padding: 1.5rem;
        }

        /* Form Layout Adjustments */
        .form-grouped-section {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .security-card-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        @media (max-width: 992px) {
            .app-dashboard-container {
                grid-template-columns: 1fr;
            }
            .premium-data-grid {
                grid-template-columns: 1fr;
            }
            .system-overview-grid,
            .role-breakdown-list {
                grid-template-columns: 1fr;
            }
        }

        /* Teacher profile shell for admin profile */
        body {
            font-family: var(--font-sans);
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }

        body::before,
        body::after {
            display: none !important;
        }

        .navbar,
        .dashboard-unified-header {
            display: none !important;
        }

        .app-dashboard-container {
            max-width: 1600px;
            width: calc(100% - 1.5rem);
            min-height: 0;
            height: auto;
            margin: 0.75rem auto 0 auto;
            padding: 0 0 0.75rem 0;
            background: transparent;
            border: none;
            border-radius: 0;
            box-shadow: none;
            overflow: visible;
            display: flex;
            flex-direction: row;
            gap: 1rem;
            align-items: flex-start;
        }

        .dashboard-body {
            display: contents;
        }

        .dashboard-sidebar {
            width: 270px;
            background: #ffffff;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            display: flex;
            flex-direction: column;
            padding: 1.5rem 1.25rem;
            box-sizing: border-box;
            flex-shrink: 0;
            position: sticky;
            top: 0.75rem;
            height: calc(100vh - 1.5rem);
            overflow-y: auto;
            box-shadow: var(--shadow);
            justify-content: flex-start;
        }

        .sidebar-brand-horizontal {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            width: 100%;
            text-decoration: none;
        }

        .brand-avatar-box {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            background: #ecfdf5;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            border: 1px solid rgba(4, 120, 87, 0.08);
            box-shadow: 0 2px 8px rgba(4, 120, 87, 0.04);
        }

        .brand-avatar-box img {
            width: 34px;
            height: 34px;
            object-fit: contain;
            transition: transform 0.25s ease;
        }

        .sidebar-brand-horizontal:hover .brand-avatar-box img {
            transform: scale(1.1) rotate(4deg);
        }

        .brand-text-col {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .brand-title {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--text-main);
            line-height: 1.2;
            white-space: nowrap;
        }

        .brand-subtitle {
            font-size: 0.65rem;
            font-weight: 800;
            color: var(--text-muted);
            letter-spacing: 0.8px;
            text-transform: uppercase;
            margin-top: 0.08rem;
            white-space: nowrap;
        }

        .sidebar-top-group {
            display: flex;
            flex-direction: column;
            min-height: 0;
        }

        .sidebar-menu {
            gap: 4.8px;
        }

        .sidebar-menu li a {
            justify-content: flex-start;
            gap: 0.75rem;
            padding: 0.8rem 0.85rem;
            border-radius: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 0.95rem;
            transform: none;
            position: relative;
        }

        .sidebar-menu li a:hover {
            transform: none;
        }

        .sidebar-menu li a.active::before {
            content: '';
            position: absolute;
            left: 0;
            top: 15%;
            height: 70%;
            width: 6px;
            background: var(--primary);
            border-radius: 0 6px 6px 0;
        }

        .menu-label-group {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-width: 0;
        }

        .menu-label-group span {
            white-space: normal;
            line-height: 1.25;
        }

        .menu-indicator {
            display: none;
        }

        .dashboard-main-section {
            display: flex;
            flex-direction: column;
            flex: 1;
            min-width: 0;
            background: transparent;
            gap: 1rem;
        }

        .dashboard-top-bar {
            height: 70px;
            min-height: 70px;
            background: #ffffff;
            border: 1px solid var(--border-dark);
            border-radius: 1.25rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2rem;
            box-sizing: border-box;
            z-index: 10;
            box-shadow: var(--shadow);
        }

        .top-bar-search-wrapper {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: #f1f5f9;
            padding: 0.5rem 1rem;
            border-radius: 1rem;
            width: 280px;
            border: 1px solid transparent;
            transition: all 0.2s ease;
        }

        .top-bar-search-wrapper:focus-within {
            background: #ffffff;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        .top-bar-search-wrapper svg {
            color: var(--text-muted);
            width: 18px;
            height: 18px;
            flex-shrink: 0;
        }

        .top-bar-search-wrapper input {
            border: none;
            background: transparent;
            outline: none;
            font-size: 0.85rem;
            color: var(--text-main);
            width: 100%;
            font-family: inherit;
        }

        .top-bar-right {
            display: flex;
            align-items: center;
            gap: 1rem;
            height: 42px;
        }

        .top-bar-user-card {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding-left: 0.75rem;
            border-left: 1px solid var(--border-dark);
            cursor: pointer;
            height: 42px;
            flex: 0 0 auto;
        }

        .top-bar-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--border-dark);
        }

        .top-bar-avatar-placeholder {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--primary-light);
            color: var(--primary);
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            border: 2px solid var(--primary);
        }

        .top-bar-user-info {
            display: flex;
            flex-direction: column;
            text-align: left;
            justify-content: center;
            min-width: 0;
        }

        .top-bar-user-name {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--text-main);
            line-height: 1.2;
            white-space: nowrap;
        }

        .top-bar-user-email {
            font-size: 0.7rem;
            color: var(--text-muted);
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 220px;
        }

        .dashboard-content-wrapper {
            flex: 1;
            padding: 2rem;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            gap: 2rem;
            background: #f9fafb;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            box-shadow: var(--shadow);
            min-height: calc(100vh - 6.75rem);
            overflow: visible;
        }

        .tab-pane {
            gap: 2rem;
            animation: fadeInTab 0.3s ease-out;
        }

        .tab-grouped-container {
            background: transparent;
            border: none;
            border-radius: 0;
            box-shadow: none;
            overflow: visible;
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .tab-header-accent {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 1rem;
            border-bottom: 1px solid var(--border-dark);
            padding: 0 0 1rem 0;
            color: var(--text-main);
        }

        .tab-header-title-text {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-main);
            margin: 0;
            letter-spacing: 0;
        }

        .tab-header-date-pill {
            background: #ffffff;
            border: 1px solid var(--border-dark);
            padding: 0.5rem 1rem;
            border-radius: 1rem;
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: var(--shadow);
        }

        .tab-body-content {
            background: transparent;
            padding: 0;
            overflow: visible;
            gap: 2rem;
        }

        .system-overview-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.25rem;
        }

        .system-metric-card {
            border-radius: 1.5rem;
            padding: 1.5rem;
            min-height: 140px;
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-top: 4px solid var(--primary);
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .system-metric-card:nth-child(2) { border-top-color: #7c3aed; }
        .system-metric-card:nth-child(3) { border-top-color: #ea580c; }
        .system-metric-card:nth-child(4) { border-top-color: #2563eb; }

        .system-metric-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 34px rgba(15, 23, 42, 0.1);
        }

        .system-metric-icon {
            width: 56px;
            height: 56px;
            border-radius: 1.25rem;
            background: var(--primary-light);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .system-metric-label {
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-muted);
            margin-top: 1rem;
        }

        .system-metric-value {
            font-size: 2.2rem;
            font-weight: 800;
            line-height: 1;
            color: var(--text-main);
            margin-top: 0.35rem;
        }

        .system-metric-note {
            color: #475569;
            font-size: 0.85rem;
            font-weight: 650;
            line-height: 1.35;
        }

        .role-breakdown-panel,
        .form-grouped-section,
        .admin-user-table-wrap {
            background: #ffffff;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            box-shadow: var(--shadow);
        }

        @media (max-width: 1024px) {
            .app-dashboard-container {
                width: calc(100% - 1rem);
                flex-direction: column;
            }

            .dashboard-sidebar {
                position: relative;
                top: auto;
                width: 100%;
                height: auto;
            }

            .system-overview-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 640px) {
            .dashboard-top-bar {
                padding: 1rem;
                height: auto;
                align-items: flex-start;
                flex-direction: column;
            }

            .top-bar-search-wrapper {
                width: 100%;
                box-sizing: border-box;
            }

            .system-overview-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
</head>
<body>

    <%
        // Logic đã được chuyển lên đầu trang để tránh trùng lặp
        List<com.hipzi.model.Role> roles = (user != null) ? user.getRoles() : null;

        // Xử lý format ngày tháng hiển thị thuần Việt
        String joinDate = "Chưa cập nhật";
        if (user != null && user.getCreatedAt() != null) {
            joinDate = new SimpleDateFormat("dd/MM/yyyy").format(user.getCreatedAt());
        }

        // Tạo chuỗi ngày hiện tại trang trọng cho Header Strip
        String currentDateDisplay = new SimpleDateFormat("'Hôm nay,' dd/MM/yyyy").format(new Date());

        // Lấy chữ cái đầu làm Avatar dự phòng
        String initials = "H";
        if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
            String[] parts = user.getDisplayName().trim().split("\\s+");
            initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
        }

        // Lấy danh sách thông báo hệ thống
        List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
        SystemOverviewStats systemOverview = (SystemOverviewStats) request.getAttribute("systemOverview");
        if (systemOverview == null) {
            systemOverview = new SystemOverviewStats();
        }
        Map<String, Integer> roleCounts = systemOverview.getRoleCounts();
        NumberFormat numberFmt = NumberFormat.getIntegerInstance(new Locale("vi", "VN"));
        NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        List<AdminUserSummary> adminUsers = (List<AdminUserSummary>) request.getAttribute("adminUsers");
        Integer adminUserPageObj = (Integer) request.getAttribute("adminUserPage");
        Integer adminUserTotalPagesObj = (Integer) request.getAttribute("adminUserTotalPages");
        Integer adminUserTotalCountObj = (Integer) request.getAttribute("adminUserTotalCount");
        int adminUserPage = adminUserPageObj != null ? adminUserPageObj : 1;
        int adminUserTotalPages = adminUserTotalPagesObj != null ? adminUserTotalPagesObj : 1;
        int adminUserTotalCount = adminUserTotalCountObj != null ? adminUserTotalCountObj : 0;
        String activeAdminTab = request.getParameter("tab");
        if (activeAdminTab == null || activeAdminTab.trim().isEmpty()) {
            activeAdminTab = "tab-dashboard";
        } else {
            activeAdminTab = activeAdminTab.trim();
            if (!activeAdminTab.startsWith("tab-")) {
                activeAdminTab = "tab-" + activeAdminTab;
            }
            if (!activeAdminTab.equals("tab-dashboard") &&
                !activeAdminTab.equals("tab-materials") &&
                !activeAdminTab.equals("tab-teacher-approval") &&
                !activeAdminTab.equals("tab-profile") &&
                !activeAdminTab.equals("tab-edit") &&
                !activeAdminTab.equals("tab-security") &&
                !activeAdminTab.equals("tab-notifications")) {
                activeAdminTab = "tab-dashboard";
            }
        }
    %>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <!-- ===== GLOBAL HEADER NAVBAR ===== -->
    <header class="navbar" id="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">

                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>


                <li><a href="${pageContext.request.contextPath}/mock-exams">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
            </ul>
            <div class="navbar-user-controls">
                <!-- Khung Dropdown Thông báo hệ thống cao cấp -->
                <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                <!-- Khung Avatar Người dùng kèm Dropdown Menu -->
                <div class="nav-avatar-dropdown">
                    <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                        <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                            <img src="<%= user.getAvatarUrl() %>" alt="Avatar">
                        <% } else { %>
                            <span class="nav-avatar-initials"><%= initials %></span>
                        <% } %>
                    </div>
                    
                    <div class="dropdown-menu-popup">
                        <a onclick="switchTab('tab-profile')">
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
        </div>
    </header>

    <!-- ===== DÀN TRANG CHÍNH THEO MẪU METROCERY TÙY BIẾN CHO HỌC VIÊN HIPZI ===== -->
    <div class="app-dashboard-container">

        <div class="dashboard-unified-header">
            <span class="unified-header-tab-title" id="unified-header-title">
                <%= "tab-materials".equals(activeAdminTab) ? "Quản lý người dùng" :
                    "tab-teacher-approval".equals(activeAdminTab) ? "Duyệt hồ sơ giảng viên" :
                    "tab-profile".equals(activeAdminTab) ? "Hồ sơ cá nhân" :
                    "tab-edit".equals(activeAdminTab) ? "Cập nhật thông tin" :
                    "tab-security".equals(activeAdminTab) ? "Bảo mật và mật khẩu" :
                    "tab-notifications".equals(activeAdminTab) ? "Thông báo hệ thống" :
                    "Tổng quan hệ thống" %>
            </span>
            <div class="unified-header-right">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span><%= currentDateDisplay %></span>
            </div>
        </div>

        <div class="dashboard-body">
            <!-- KÊNH SIDEBAR TRÁI (LEFT PANE) -->
            <aside class="dashboard-sidebar">
                <div class="sidebar-brand-horizontal">
                    <a href="${pageContext.request.contextPath}/index" class="brand-avatar-box" title="Trang chủ">
                        <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="Hipzi Logo">
                    </a>
                    <div class="brand-text-col">
                        <span class="brand-title">Hipzi</span>
                        <span class="brand-subtitle">Admin</span>
                    </div>
                </div>

                <div class="sidebar-top-group">
                    <ul class="sidebar-menu">
                        <li>
                            <a id="nav-tab-dashboard" class="<%= "tab-dashboard".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-dashboard')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/></svg>
                                <span>Tổng quan hệ thống</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-materials" class="<%= "tab-materials".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-materials')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-8 0v2"/><circle cx="12" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M2 21v-2a4 4 0 0 1 3-3.87"/></svg>
                                <span>Quản lý người dùng</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-teacher-approval" class="<%= "tab-teacher-approval".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-teacher-approval')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>
                                <span>Duyệt hồ sơ giảng viên</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-profile" class="<%= ("tab-profile".equals(activeAdminTab) || "tab-edit".equals(activeAdminTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                <span>Hồ sơ cá nhân</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-security" class="<%= "tab-security".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-security')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                <span>Bảo mật và mật khẩu</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-notifications" class="<%= "tab-notifications".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-notifications')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                <span>Thông báo hệ thống</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    </ul>
                    <div class="sidebar-mascot-box" aria-label="HIPZI mascot">
                        <img class="sidebar-cute-mascot"
                             src="${pageContext.request.contextPath}/assets/images/capybara-mascot-transparent.png"
                             alt="HIPZI mascot">
                    </div>
                </div>
            </aside>

            <div class="dashboard-main-section">
                <div class="dashboard-top-bar">
                    <div class="top-bar-search-wrapper">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Tìm kiếm tác vụ quản trị...">
                    </div>

                    <div class="top-bar-right">
                        <button type="button" class="nav-bell-trigger" title="Thông báo" onclick="switchTab('tab-notifications')">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                        </button>

                        <a href="${pageContext.request.contextPath}/logout" class="nav-bell-trigger" title="Đăng xuất" style="text-decoration:none;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        </a>

                        <div class="top-bar-user-card" onclick="switchTab('tab-profile')">
                            <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                <img src="<%= user.getAvatarUrl() %>" class="top-bar-avatar" alt="Avatar">
                            <% } else { %>
                                <div class="top-bar-avatar-placeholder"><%= initials %></div>
                            <% } %>
                            <div class="top-bar-user-info">
                                <span class="top-bar-user-name"><%= user != null ? user.getDisplayName() : "Quản trị viên HIPZI" %></span>
                                <span class="top-bar-user-email"><%= user != null ? user.getEmail() : "info@hipzi.vn" %></span>
                            </div>
                        </div>
                    </div>
                </div>

            <!-- KÊNH NỘI DUNG PHẢI (RIGHT CONTENT PANE) -->
            <main class="dashboard-content-wrapper">

            <!-- Banner dải màu trang trí phía trên cùng (Top Accent Strip) -->


            <!-- Thông báo nhắc nhở Onboarding (Nếu đăng ký qua Google mà chưa chọn role) -->
            <% if (user != null && !user.isOnboardingCompleted()) { %>
            <div class="onboarding-banner" style="margin-top: -0.5rem;">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#92400e" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <p>Hồ sơ của bạn đang chờ hoàn tất thiết lập vai trò học viên sử dụng nền tảng.</p>
                <a href="${pageContext.request.contextPath}/onboarding">Hoàn tất ngay</a>
            </div>
            <% } %>

            <!-- ========================================== -->
            <!-- TAB 1: HỒ SƠ CÁ NHÂN TỔNG QUAN             -->
            <!-- ========================================== -->
            <section id="tab-dashboard" class="tab-pane <%= "tab-dashboard".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Tổng quan hệ thống</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                    <div class="tab-body-content">
                        <div class="system-overview-grid">
                            <div class="system-metric-card">
                                <div class="system-metric-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-8 0v2"/><circle cx="12" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M2 21v-2a4 4 0 0 1 3-3.87"/></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng người dùng</div>
                                    <div class="system-metric-value"><%= numberFmt.format(systemOverview.getTotalUsers()) %></div>
                                </div>
                                <div class="system-metric-note"><%= numberFmt.format(systemOverview.getActiveUsers()) %> tài khoản đang hoạt động</div>
                            </div>
                            <div class="system-metric-card">
                                <div class="system-metric-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 12l2 2 4-4"/><path d="M21 12c.552 0 1-.448 1-1V8a2 2 0 0 0-2-2h-1.172a2 2 0 0 1-1.414-.586l-.828-.828A2 2 0 0 0 15.172 4H8.828a2 2 0 0 0-1.414.586l-.828.828A2 2 0 0 1 5.172 6H4a2 2 0 0 0-2 2v3c0 .552.448 1 1 1"/><path d="M3 12v6a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-6"/></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng tài liệu</div>
                                    <div class="system-metric-value"><%= numberFmt.format(systemOverview.getTotalMaterials()) %></div>
                                </div>
                                <div class="system-metric-note">Tài liệu học tập đang hiển thị</div>
                            </div>
                            <div class="system-metric-card">
                                <div class="system-metric-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 1v22"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7H14a3.5 3.5 0 0 1 0 7H6"/></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng doanh thu</div>
                                    <div class="system-metric-value" style="font-size:1.45rem;"><%= currencyFmt.format(systemOverview.getTotalRevenue()) %></div>
                                </div>
                                <div class="system-metric-note">Tính từ bảng thanh toán nếu đã cấu hình</div>
                            </div>
                            <div class="system-metric-card">
                                <div class="system-metric-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><path d="M12 8v4"/><path d="M12 16h.01"/></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng lớp học</div>
                                    <div class="system-metric-value"><%= numberFmt.format(systemOverview.getTotalClassrooms()) %></div>
                                </div>
                                <div class="system-metric-note">Lớp học đang mở hoặc sắp khai giảng</div>
                            </div>
                        </div>
                        <div class="role-breakdown-panel">
                            <h3 class="role-breakdown-title">Người dùng theo từng loại vai trò</h3>
                            <div class="role-breakdown-list">
                                <div class="role-breakdown-item"><span class="role-breakdown-name">Học sinh</span><span class="role-breakdown-count"><%= numberFmt.format(roleCounts.getOrDefault("student", 0)) %></span></div>
                                <div class="role-breakdown-item"><span class="role-breakdown-name">Phụ huynh</span><span class="role-breakdown-count"><%= numberFmt.format(roleCounts.getOrDefault("parent", 0)) %></span></div>
                                <div class="role-breakdown-item"><span class="role-breakdown-name">Giáo viên</span><span class="role-breakdown-count"><%= numberFmt.format(roleCounts.getOrDefault("teacher", 0)) %></span></div>
                                <div class="role-breakdown-item"><span class="role-breakdown-name">Nhân viên</span><span class="role-breakdown-count"><%= numberFmt.format(roleCounts.getOrDefault("staff", 0)) %></span></div>
                                <div class="role-breakdown-item"><span class="role-breakdown-name">Quản trị viên</span><span class="role-breakdown-count"><%= numberFmt.format(roleCounts.getOrDefault("admin", 0)) %></span></div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(activeAdminTab) ? "active-pane" : "" %>">
                <% String adminProfileStatus = (user != null) ? user.getAccountStatus() : "active";
                   String adminProfileStatusLabel = "active".equals(adminProfileStatus) ? "Đang hoạt động" : "suspended".equals(adminProfileStatus) ? "Tạm khóa" : "Vô hiệu hóa"; %>
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hồ sơ cá nhân</h1>
                        <p>Xem và quản lý thông tin tài khoản quản trị viên của bạn trên HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="metrics-row">
                    <div class="metric-card">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Họ và tên hiển thị</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= user != null ? user.getDisplayName() : "—" %></div>
                            <span class="metric-card-sub">Quản trị viên hệ thống</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </div>
                    </div>

                    <div class="metric-card">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Ngày tham gia</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= joinDate %></div>
                            <span class="metric-card-sub" style="background:#f5f3ff; color:#7c3aed;">Khởi tạo tài khoản</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true" style="color:#7c3aed; background:#f5f3ff;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        </div>
                    </div>

                    <div class="metric-card">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Địa chỉ Email</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value compact"><%= user != null ? user.getEmail() : "—" %></div>
                            <span class="metric-card-sub" style="background:#fff7ed; color:#ea580c;">Tài khoản định danh</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true" style="color:#ea580c; background:#fff7ed;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        </div>
                    </div>

                    <div class="metric-card">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Trạng thái tài khoản</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value" style="font-size:1rem;">
                                <span class="acc-status-tag <%= adminProfileStatus %>"><%= adminProfileStatusLabel %></span>
                            </div>
                            <span class="metric-card-sub" style="background:#eff6ff; color:#2563eb;">Chế độ bảo mật</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true" style="color:#2563eb; background:#eff6ff;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        </div>
                    </div>
                </div>

                <div class="dashboard-grid-layout">
                    <div class="premium-card" style="grid-column: 1 / -1;">
                        <div class="premium-card-header">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                Chi tiết tài khoản
                            </span>
                            <div class="account-header-actions">
                                <button type="button" id="accountEditTrigger" onclick="toggleAccountNameEdit(true)" class="btn-premium profile-edit-btn" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; min-height: 36px;">
                                    <span>Chỉnh sửa</span>
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                </button>
                                <div id="accountEditActions" class="account-edit-actions" style="display: none;">
                                    <button type="button" class="btn-premium account-cancel-btn" onclick="toggleAccountNameEdit(false)" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; min-height: 36px;">Hủy bỏ</button>
                                    <button type="submit" form="accountNameInlineForm" class="btn-premium account-save-btn" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; min-height: 36px;">Lưu</button>
                                </div>
                            </div>
                        </div>

                        <form id="adminAvatarUploadForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" style="display:none;">
                            <input type="hidden" name="action" value="updateAvatar">
                            <input type="file" id="adminAvatarFile" name="avatarFile" accept="image/*" onchange="if(this.files.length > 0) { showToast('Đang tải ảnh lên...', 'info'); document.getElementById('adminAvatarUploadForm').submit(); }">
                        </form>

                        <div class="account-summary-panel">
                            <div class="account-summary-main">
                                <div class="account-avatar-wrap">
                                    <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                        <img src="<%= user.getAvatarUrl() %>" class="account-avatar-img" alt="Avatar">
                                    <% } else { %>
                                        <div class="account-avatar-placeholder"><%= initials %></div>
                                    <% } %>
                                    <button type="button" class="avatar-camera-btn" title="Cập nhật ảnh đại diện" onclick="document.getElementById('adminAvatarFile').click();">
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                                    </button>
                                </div>
                                <div class="account-identity">
                                    <h3 class="account-name"><%= user != null ? user.getDisplayName() : "Quản trị viên HIPZI" %></h3>
                                    <form id="accountNameInlineForm" class="account-name-edit-form" action="${pageContext.request.contextPath}/profile" method="POST" style="display: none;">
                                        <input type="hidden" name="action" value="updateName">
                                        <input id="accountDisplayNameInput" class="account-name-input" type="text" name="displayName" required value="<%= user != null ? user.getDisplayName() : "" %>" placeholder="Nhập họ và tên của bạn...">
                                    </form>
                                    <span class="account-email" title="<%= user != null ? user.getEmail() : "" %>"><%= user != null ? user.getEmail() : "info@hipzi.vn" %></span>
                                </div>
                            </div>
                            <div class="account-side-meta">
                                <div class="account-meta-pill">
                                    <span class="account-meta-label">Ngày tham gia</span>
                                    <span class="account-meta-value"><%= joinDate %></span>
                                </div>
                                <div class="account-meta-pill">
                                    <span class="account-meta-label">Vai trò</span>
                                    <span class="account-meta-value">
                                        <% if (roles != null && !roles.isEmpty()) {
                                            for (Role r : roles) { %>
                                                <span class="role-tag <%= r.getName() %>">
                                                    <%= r.getName().equals("student")  ? "Học viên"    :
                                                        r.getName().equals("parent")   ? "Phụ huynh"   :
                                                        r.getName().equals("teacher")  ? "Giảng viên"  :
                                                        r.getName().equals("staff")    ? "Nhân viên"   :
                                                        r.getName().equals("admin")    ? "Quản trị"    : r.getName() %>
                                                </span>
                                        <% }} else { %>
                                            <span class="role-tag admin">Quản trị viên</span>
                                        <% } %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 2: CHỈNH SỬA HỒ SƠ                     -->
            <!-- ========================================== -->
            <section id="tab-edit" class="tab-pane <%= "tab-edit".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Cập nhật thông tin</h1>
                        <p>Thay đổi thông tin cá nhân hiển thị của quản trị viên trên hệ thống.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <button onclick="switchTab('tab-profile')" class="btn-premium secondary" style="padding: 0.5rem 1rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                            <span>Quay lại</span>
                        </button>
                    </div>
                </div>

                <div class="premium-card">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            Thông tin hiển thị
                        </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="form-edit-layout" style="padding: 0;">
                        <input type="hidden" name="action" value="updateName">
                        <div class="form-group-premium" style="margin-bottom: 1.5rem;">
                            <label>Họ và tên hiển thị</label>
                            <input type="text" name="displayName" required value="<%= user != null ? user.getDisplayName() : "" %>" placeholder="Nhập họ và tên của bạn...">
                        </div>

                        <div class="form-actions-row-premium">
                            <button type="button" class="btn-premium secondary" onclick="switchTab('tab-profile')">Hủy bỏ</button>
                            <button type="submit" class="btn-premium primary">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 3: BẢO MẬT VÀ MẬT KHẨU                 -->
            <!-- ========================================== -->
            <section id="tab-security" class="tab-pane <%= "tab-security".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Bảo mật tài khoản</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="form-grouped-section">
                            <!-- Password Change Block -->
                            <div style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 4px 12px rgba(0, 0, 0, 0.02); overflow:hidden;">
                                <div style="padding:1.75rem; display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:1.25rem;">
                                    <div>
                                        <span style="font-weight:800; font-size:1.15rem; color:#b45309; letter-spacing:0.5px; text-transform:uppercase; display:block;">Mật khẩu đăng nhập</span>
                                        <p style="font-size:0.85rem; color:var(--text-muted); margin:0.35rem 0 0 0;">Cập nhật mật khẩu định kỳ để bảo mật tốt hơn.</p>
                                    </div>
                                    <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='flex';" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease;">
                                        <span>Đổi mật khẩu</span>
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                    </button>
                                </div>

                                <div style="padding:1rem 1.75rem; border-top:1px solid var(--border-dark); background:rgba(248, 250, 252, 0.4); display:flex; align-items:center; gap:1.5rem; flex-wrap:wrap;">
                                    <div style="display:flex; align-items:center; gap:0.4rem; color:#10b981; font-weight:700; font-size:0.85rem;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                        <span>Mật khẩu mạnh</span>
                                    </div>
                                    <div style="display:flex; align-items:center; gap:0.4rem; color:<%= (user != null && user.isTwoFactorEnabled()) ? "#10b981" : "var(--text-muted)" %>; font-weight:700; font-size:0.85rem;">
                                        <% if (user != null && user.isTwoFactorEnabled()) { %>
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                            <span>Xác thực 2 lớp: Đang bật</span>
                                        <% } else { %>
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                                            <span>Xác thực 2 lớp: Tắt</span>
                                        <% } %>
                                    </div>
                                </div>
                            </div>

                            <div class="security-card-row">
                                <!-- 2FA Toggle -->
                                <div style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 4px 12px rgba(0, 0, 0, 0.02); padding:1.5rem; display:flex; flex-direction:column; justify-content:space-between; gap:1.5rem;">
                                    <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                        <span style="font-weight:800; font-size:0.9rem; color:var(--text-main); text-transform:uppercase; letter-spacing:0.5px;">Bảo mật 2 lớp (OTP)</span>
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                    </div>
                                    <div style="display:flex; justify-content:space-between; align-items:center;">
                                        <span style="font-weight:700; font-size:0.95rem; color:var(--text-main);">Mã OTP qua Email</span>
                                        <form id="toggle2faForm" action="${pageContext.request.contextPath}/profile" method="POST" style="display:none;">
                                            <input type="hidden" name="action" value="toggle2FA">
                                        </form>
                                        <% boolean is2fa = (user != null && user.isTwoFactorEnabled()); %>
                                        <div id="otp-toggle-btn" onclick="document.getElementById('toggle2faForm').submit();" style="width:44px; height:24px; background:<%= is2fa ? "#10b981" : "#cbd5e1" %>; border-radius:12px; padding:2px; cursor:pointer; transition:background 0.3s ease; display:flex; align-items:center;">
                                            <div class="toggle-circle" style="width:20px; height:20px; background:#ffffff; border-radius:50%; box-shadow:0 1px 3px rgba(0,0,0,0.2); transition:transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform:translateX(<%= is2fa ? "20px" : "0" %>);"></div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Current Device -->
                                <div style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 4px 12px rgba(0, 0, 0, 0.02); padding:1.5rem; display:flex; flex-direction:column; justify-content:space-between; gap:1.5rem;">
                                    <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                        <span style="font-weight:800; font-size:0.9rem; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px;">Thiết bị hiện tại</span>
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                                    </div>
                                    <div>
                                        <span style="font-weight:800; font-size:1.1rem; color:var(--text-main); display:block;">Windows - Chrome (Vietnam)</span>
                                        <span style="font-size:0.75rem; color:#10b981; font-weight:600; display:inline-block; margin-top:0.25rem; background:#ecfdf5; padding:0.15rem 0.5rem; border-radius:0.25rem;">Phiên truy cập an toàn</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 4: TÀI LIỆU ĐÃ LƯU                     -->
            <!-- ========================================== -->
            <section id="tab-materials" class="tab-pane <%= "tab-materials".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Quản lý người dùng</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="form-grouped-section">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    <span>Danh sách student, teacher, parent, staff</span>
                                </div>
                                <span style="font-size:0.82rem; font-weight:800; color:#059669; background:#ecfdf5; padding:0.4rem 1rem; border-radius:999px;"><%= numberFmt.format(adminUserTotalCount) %> người dùng</span>
                            </div>
                            <div class="admin-user-table-wrap">
                                <table class="admin-user-table">
                                    <thead>
                                        <tr>
                                            <th>Tên</th>
                                            <th>Vai trò</th>
                                            <th>Online/Offline</th>
                                            <th>Tài khoản</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (adminUsers != null && !adminUsers.isEmpty()) {
                                            for (AdminUserSummary managedUser : adminUsers) {
                                                boolean managedOnline = UserStatusWebSocket.isUserOnline(managedUser.getId());
                                                String managedStatus = managedUser.getAccountStatus() != null ? managedUser.getAccountStatus() : "active";
                                                String managedName = managedUser.getDisplayName() != null ? managedUser.getDisplayName() : "Người dùng HIPZI";
                                                String managedEmail = managedUser.getEmail() != null ? managedUser.getEmail() : "";
                                                String managedRoles = managedUser.getRoles() != null ? managedUser.getRoles() : "";
                                        %>
                                        <tr>
                                            <td>
                                                <div class="managed-user-name">
                                                    <span><%= managedName %></span>
                                                    <span class="managed-user-email"><%= managedEmail %></span>
                                                </div>
                                            </td>
                                            <td><span class="managed-role-pill"><%= managedRoles %></span></td>
                                            <td>
                                                <span id="admin-status-<%= managedUser.getId() %>" class="live-status-badge <%= managedOnline ? "live-status-online" : "live-status-offline" %>"><%= managedOnline ? "Online" : "Offline" %></span>
                                            </td>
                                            <td><span class="account-status-pill <%= managedStatus %>"><%= "active".equalsIgnoreCase(managedStatus) ? "Active" : "Đã khóa" %></span></td>
                                            <td>
                                                <div class="admin-user-actions">
                                                    <button type="button" class="table-action-btn detail"
                                                            data-name="<%= escAttr(managedName) %>"
                                                            data-email="<%= escAttr(managedEmail) %>"
                                                            data-roles="<%= escAttr(managedRoles) %>"
                                                            data-account="<%= escAttr(managedStatus) %>"
                                                            data-online="<%= managedOnline ? "Online" : "Offline" %>"
                                                            onclick="openAdminUserDetail(this)"
                                                            title="Xem chi tiết"
                                                            aria-label="Xem chi tiết người dùng">
                                                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></svg>
                                                    </button>
                                                    <form action="${pageContext.request.contextPath}/admin-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn khóa tài khoản này?');" style="margin:0;">
                                                        <input type="hidden" name="action" value="banUser">
                                                        <input type="hidden" name="targetUserId" value="<%= managedUser.getId() %>">
                                                        <input type="hidden" name="userPage" value="<%= adminUserPage %>">
                                                        <button type="submit"
                                                                class="table-action-btn ban"
                                                                title="Ban tài khoản"
                                                                aria-label="Ban tài khoản người dùng"
                                                                <%= "active".equalsIgnoreCase(managedStatus) ? "" : "disabled" %>>
                                                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } } else { %>
                                        <tr>
                                            <td colspan="5" style="text-align:center; padding:3rem; color:#64748b; font-weight:700;">Chưa có người dùng phù hợp để hiển thị.</td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <div class="admin-pagination">
                                <span style="color:#64748b; font-size:0.85rem; font-weight:700;">Trang <%= adminUserPage %>/<%= adminUserTotalPages %> · 10 người / trang</span>
                                <div class="admin-page-links">
                                    <% for (int p = 1; p <= adminUserTotalPages; p++) { %>
                                        <a class="admin-page-link <%= p == adminUserPage ? "active" : "" %>" href="${pageContext.request.contextPath}/admin-profile?tab=materials&userPage=<%= p %>"><%= p %></a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: DUYET HO SO GIANG VIEN                -->
            <!-- ========================================== -->
            <section id="tab-teacher-approval" class="tab-pane <%= "tab-teacher-approval".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Duyệt hồ sơ giảng viên</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="form-grouped-section">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>
                                    <span>Hàng chờ xét duyệt hồ sơ</span>
                                </div>
                                <span style="font-size:0.82rem; font-weight:800; color:#059669; background:#ecfdf5; padding:0.4rem 1rem; border-radius:999px;">Giao diện mẫu</span>
                            </div>

                            <div style="display:grid; grid-template-columns:repeat(3, minmax(0, 1fr)); gap:1rem;">
                                <div class="system-metric-card" style="min-height:auto;">
                                    <div class="system-metric-icon">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M16 21v-2a4 4 0 0 0-8 0v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    </div>
                                    <div>
                                        <div class="system-metric-label">Chờ duyệt</div>
                                        <div class="system-metric-value">0</div>
                                    </div>
                                    <div class="system-metric-note">Hồ sơ mới gửi lên</div>
                                </div>
                                <div class="system-metric-card" style="min-height:auto;">
                                    <div class="system-metric-icon">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20 6L9 17l-5-5"/></svg>
                                    </div>
                                    <div>
                                        <div class="system-metric-label">Đã duyệt</div>
                                        <div class="system-metric-value">0</div>
                                    </div>
                                    <div class="system-metric-note">Giảng viên hợp lệ</div>
                                </div>
                                <div class="system-metric-card" style="min-height:auto;">
                                    <div class="system-metric-icon">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                    </div>
                                    <div>
                                        <div class="system-metric-label">Từ chối</div>
                                        <div class="system-metric-value">0</div>
                                    </div>
                                    <div class="system-metric-note">Cần bổ sung thông tin</div>
                                </div>
                            </div>

                            <div class="admin-user-table-wrap">
                                <table class="admin-user-table">
                                    <thead>
                                        <tr>
                                            <th>Giảng viên</th>
                                            <th>Chuyên môn</th>
                                            <th>Trạng thái hồ sơ</th>
                                            <th>Ngày gửi</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td colspan="5" style="text-align:center; padding:3rem; color:#64748b; font-weight:700;">
                                                Chưa có hồ sơ giảng viên nào cần duyệt.
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div style="padding:1.25rem; border-radius:1rem; background:#f8fafc; border:1px dashed #cbd5e1; color:#64748b; font-weight:650; line-height:1.6;">
                                Khu vực này đã sẵn giao diện để sau này nối dữ liệu hồ sơ giảng viên, xem minh chứng chuyên môn, duyệt hoặc yêu cầu bổ sung thông tin.
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 6: THÔNG BÁO HỆ THỐNG                  -->
            <!-- ========================================== -->
            <section id="tab-notifications" class="tab-pane <%= "tab-notifications".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Thông báo hệ thống</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="form-grouped-section">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                    <span>Gửi thông báo hệ thống</span>
                                </div>
                                <span style="font-size:0.8rem; font-weight:700; color:#059669; background:#ecfdf5; padding:0.35rem 1rem; border-radius:2rem;">Admin Only</span>
                            </div>

                            <form action="${pageContext.request.contextPath}/admin/notification" method="POST" class="form-edit-layout" style="padding:0;">
                                <input type="hidden" name="action" value="broadcast">
                                
                                <div class="card-body-grid" style="grid-template-columns: 1fr 1fr; padding: 0; margin-bottom: 1.5rem; gap: 1.5rem;">
                                    <div class="form-group-edit">
                                        <label>Tiêu đề thông báo <span style="color:#ef4444;">*</span></label>
                                        <input type="text" name="title" required placeholder="Ví dụ: Bảo trì hệ thống định kỳ...">
                                    </div>
                                    <div class="form-group-edit">
                                        <label>Loại thông báo</label>
                                        <select name="type" style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid #e2e8f0; outline:none; background:white; font-family:inherit; font-size:0.95rem;">
                                            <option value="info">Thông tin (Xanh dương)</option>
                                            <option value="success">Thành công (Xanh lá)</option>
                                            <option value="warning">Cảnh báo (Vàng)</option>
                                            <option value="error">Nghiêm trọng (Đỏ)</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group-edit">
                                    <label>Nội dung chi tiết <span style="color:#ef4444;">*</span></label>
                                    <textarea name="message" rows="4" required placeholder="Nhập nội dung thông báo bạn muốn gửi đến tất cả người dùng..."></textarea>
                                </div>

                                <div style="display:flex; justify-content:flex-end; gap:1rem; margin-top:1.5rem;">
                                    <button type="reset" class="btn btn-ghost">Xóa nội dung</button>
                                    <button type="submit" class="btn btn-primary" style="padding:0.85rem 2rem; border-radius:9999px; display:inline-flex; align-items:center; gap:0.65rem;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                                        <span>Gửi thông báo ngay</span>
                                    </button>
                                </div>
                            </form>

                            <div style="margin-top: 1rem;">
                                <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                    <div class="card-header-title">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                        <span>Lịch sử gửi thông báo gần đây</span>
                                    </div>
                                </div>
                                <div style="padding-top:1.25rem; display:flex; flex-direction:column; gap:1rem;">
                                    <% if (notifications != null && !notifications.isEmpty()) { 
                                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                        for (com.hipzi.model.Notification n : notifications) {
                                            String typeColor = "var(--primary)";
                                            String bgColor = "#f0fdf4";
                                            String iconPath = "M22 11.08V12a10 10 0 1 1-5.93-9.14\";polyline points=\"22 4 12 14.01 9 11.01";
                                            
                                            if ("warning".equalsIgnoreCase(n.getType())) {
                                                typeColor = "#f59e0b";
                                                bgColor = "#fffbeb";
                                                iconPath = "M12 9v4\";line x1=\"12\" y1=\"17\" x2=\"12.01\" y2=\"17\";path d=\"M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z";
                                            } else if ("error".equalsIgnoreCase(n.getType())) {
                                                typeColor = "#ef4444";
                                                bgColor = "#fef2f2";
                                                iconPath = "M12 8v4\";line x1=\"12\" y1=\"16\" x2=\"12.01\" y2=\"16\";circle cx=\"12\" cy=\"12\" r=\"10";
                                            } else if ("info".equalsIgnoreCase(n.getType())) {
                                                typeColor = "#0ea5e9";
                                                bgColor = "#f0f9ff";
                                                iconPath = "M12 16v-4\";line x1=\"12\" y1=\"8\" x2=\"12.01\" y2=\"8\";circle cx=\"12\" cy=\"12\" r=\"10";
                                            }
                                    %>
                                        <div style="padding:1.25rem; border-radius:1rem; background:<%= bgColor %>; border:1px solid #e2e8f0; border-left:4px solid <%= typeColor %>; display:flex; gap:1rem; align-items:flex-start; box-shadow: 0 4px 12px rgba(0,0,0,0.02);">
                                            <div style="flex:1;">
                                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                                    <span style="font-weight:800; font-size:1.05rem; color:var(--text-main); letter-spacing: -0.2px;"><%= n.getTitle() %></span>
                                                    <span style="font-size:0.75rem; color:#94a3b8; font-weight:600;"><%= sdf.format(n.getCreatedAt()) %></span>
                                                </div>
                                                <p style="font-size:0.9rem; color:var(--text-muted); margin:0.35rem 0 0 0; line-height: 1.5;"><%= n.getMessage() %></p>
                                            </div>
                                        </div>
                                    <% } } else { %>
                                        <div class="empty-status-panel" style="padding: 2rem;">
                                            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                            <span style="font-weight:700; color:var(--text-main);">Chưa có thông báo nào được gửi</span>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 7: HỐ TRỢ HỌC TẬP                      -->
            <!-- ========================================== -->





            <!-- ========================================== -->
            <!-- MODAL OVERLAY: ĐỔI MẬT KHẨU HỆ THỐNG       -->
            <!-- ========================================== -->
            <div id="adminUserDetailModal" class="admin-user-modal-backdrop" aria-hidden="true">
                <div class="admin-user-modal" role="dialog" aria-modal="true" aria-labelledby="adminUserDetailTitle">
                    <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:1rem; margin-bottom:1.25rem;">
                        <div>
                            <div id="adminUserDetailTitle" style="font-size:1.25rem; font-weight:850; color:#0f172a;">Chi tiết người dùng</div>
                            <div id="adminUserDetailEmail" style="font-size:0.85rem; color:#64748b; font-weight:650; margin-top:0.25rem;">-</div>
                        </div>
                        <button type="button" onclick="closeAdminUserDetail()" style="border:none; background:#f1f5f9; color:#475569; width:34px; height:34px; border-radius:10px; font-size:1.2rem; cursor:pointer;">&times;</button>
                    </div>
                    <div style="display:grid; gap:0.85rem;">
                        <div class="role-breakdown-item"><span class="role-breakdown-name">Vai trò</span><span id="adminUserDetailRoles" class="role-breakdown-count" style="font-size:0.95rem;">-</span></div>
                        <div class="role-breakdown-item"><span class="role-breakdown-name">Trạng thái online</span><span id="adminUserDetailOnline" class="role-breakdown-count" style="font-size:0.95rem;">-</span></div>
                        <div class="role-breakdown-item"><span class="role-breakdown-name">Trạng thái tài khoản</span><span id="adminUserDetailAccount" class="role-breakdown-count" style="font-size:0.95rem;">-</span></div>
                    </div>
                </div>
            </div>

            <div id="pwd-modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15, 23, 42, 0.6); backdrop-filter:blur(4px); z-index:9999; display:none; justify-content:center; align-items:center; padding:1rem;">
                <div style="background:#ffffff; border-radius:1.5rem; width:100%; max-width:440px; padding:2rem; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1); border:1px solid #e2e8f0; animation:modalScaleUp 0.25s ease-out;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                        <div style="display:flex; align-items:center; gap:0.65rem;">
                            <div style="width:36px; height:36px; border-radius:50%; background:#fef3c7; color:#d97706; display:flex; justify-content:center; align-items:center;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            </div>
                            <span style="font-size:1.25rem; font-weight:800; color:var(--text-main);">Đổi mật khẩu</span>
                        </div>
                        <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='none';" style="background:none; border:none; font-size:1.25rem; color:var(--text-muted); cursor:pointer;">&times;</button>
                    </div>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" style="display:flex; flex-direction:column; gap:1.25rem;">
                        <input type="hidden" name="action" value="changePassword">
                        
                        <div style="display:flex; flex-direction:column; gap:0.4rem; text-align:left;">
                            <label style="font-size:0.85rem; font-weight:700; color:var(--text-main);">Mật khẩu hiện tại <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="currentPassword" required placeholder="••••••••" style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); font-size:0.95rem; outline:none; transition:border-color 0.2s ease;" onfocus="this.style.borderColor='var(--primary)';" onblur="this.style.borderColor='var(--border-dark)';">
                        </div>

                        <div style="display:flex; flex-direction:column; gap:0.4rem; text-align:left;">
                            <label style="font-size:0.85rem; font-weight:700; color:var(--text-main);">Mật khẩu mới <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="newPassword" required minlength="6" placeholder="Mật khẩu ít nhất 6 ký tự" style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); font-size:0.95rem; outline:none; transition:border-color 0.2s ease;" onfocus="this.style.borderColor='var(--primary)';" onblur="this.style.borderColor='var(--border-dark)';">
                        </div>

                        <div style="display:flex; flex-direction:column; gap:0.4rem; text-align:left;">
                            <label style="font-size:0.85rem; font-weight:700; color:var(--text-main);">Xác nhận mật khẩu mới <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="confirmPassword" required minlength="6" placeholder="Nhập lại mật khẩu mới" style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); font-size:0.95rem; outline:none; transition:border-color 0.2s ease;" onfocus="this.style.borderColor='var(--primary)';" onblur="this.style.borderColor='var(--border-dark)';">
                        </div>

                        <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:0.5rem;">
                            <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='none';" style="padding:0.65rem 1.25rem; border-radius:0.75rem; background:#f1f5f9; color:var(--text-muted); font-weight:700; border:none; cursor:pointer;">Hủy bỏ</button>
                            <button type="submit" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease;" onmouseover="this.style.background='#047857'; this.style.transform='translateY(-1px)';" onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                <span>Cập nhật ngay</span>
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            </main>
            </div>
        </div>
    </div>

    
    <!-- ===== JAVASCRIPT XỬ LÝ CHUYỂN TAB MƯỢT MÀ ===== -->
    <script>
        function showToast(message, type = 'success') {
            let container = document.getElementById('custom-toast-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'custom-toast-container';
                container.className = 'custom-toast-container';
                document.body.appendChild(container);
            }

            const toast = document.createElement('div');
            toast.className = 'custom-toast-msg ' + (type === 'info' ? 'info' : '');
            
            const iconSvg = type === 'info' 
                ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
                : '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>';
            
            toast.innerHTML = iconSvg + '<span>' + message + '</span>';
            container.appendChild(toast);

            setTimeout(() => {
                toast.remove();
            }, 3000);
        }

        function updateAdminUserStatus(userId, status) {
            const badge = document.getElementById('admin-status-' + userId);
            if (!badge) return;

            const isOnline = String(status).toLowerCase() === 'online';
            badge.textContent = isOnline ? 'Online' : 'Offline';
            badge.classList.toggle('live-status-online', isOnline);
            badge.classList.toggle('live-status-offline', !isOnline);

            const detailButton = badge.closest('tr')?.querySelector('.table-action-btn.detail');
            if (detailButton) {
                detailButton.dataset.online = isOnline ? 'Online' : 'Offline';
            }
        }

        function initAdminStatusWS() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const ws = new WebSocket(protocol + '//' + window.location.host + '${pageContext.request.contextPath}/status-ws');

            ws.onopen = () => {
                ws.send(JSON.stringify({ type: 'auth', userId: '<%= user != null ? user.getId() : "" %>' }));
            };

            ws.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    if (data.type === 'status' || data.type === 'status_update') {
                        updateAdminUserStatus(data.userId, data.status);
                    } else if (data.type === 'bulk_status' && data.statuses) {
                        Object.keys(data.statuses).forEach(userId => updateAdminUserStatus(userId, data.statuses[userId]));
                    }
                } catch (error) {
                    console.error('Admin status websocket error:', error);
                }
            };

            ws.onclose = () => {
                setTimeout(initAdminStatusWS, 5000);
            };
        }

        function openAdminUserDetail(button) {
            const modal = document.getElementById('adminUserDetailModal');
            if (!modal || !button) return;

            document.getElementById('adminUserDetailTitle').textContent = button.dataset.name || 'Người dùng HIPZI';
            document.getElementById('adminUserDetailEmail').textContent = button.dataset.email || '-';
            document.getElementById('adminUserDetailRoles').textContent = button.dataset.roles || '-';
            document.getElementById('adminUserDetailOnline').textContent = button.dataset.online || '-';
            document.getElementById('adminUserDetailAccount').textContent = button.dataset.account || '-';
            modal.classList.add('active');
            modal.setAttribute('aria-hidden', 'false');
        }

        function closeAdminUserDetail() {
            const modal = document.getElementById('adminUserDetailModal');
            if (!modal) return;
            modal.classList.remove('active');
            modal.setAttribute('aria-hidden', 'true');
        }

        const adminUserDetailModal = document.getElementById('adminUserDetailModal');
        if (adminUserDetailModal) {
            adminUserDetailModal.addEventListener('click', (event) => {
                if (event.target === adminUserDetailModal) closeAdminUserDetail();
            });
        }

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') closeAdminUserDetail();
        });

        let profileTabSwitchTimer;

        function getProfileTabSlug(tabId) {
            return tabId.replace(/^tab-/, '');
        }

        function normalizeProfileTabId(tabValue) {
            if (!tabValue) return '';
            return tabValue.startsWith('tab-') ? tabValue : 'tab-' + tabValue;
        }

        function updateProfileTabUrl(targetTabId, replace = false) {
            if (!window.history || !window.history.pushState) return;
            const url = new URL(window.location.href);
            url.searchParams.set('tab', getProfileTabSlug(targetTabId));
            const state = { profileTab: targetTabId };
            if (replace) {
                window.history.replaceState(state, '', url);
            } else {
                window.history.pushState(state, '', url);
            }
        }

        const TAB_TITLES = {
            'tab-dashboard': 'Tổng quan hệ thống',
            'tab-materials': 'Quản lý người dùng',
            'tab-teacher-approval': 'Duyệt hồ sơ giảng viên',
            'tab-profile': 'Hồ sơ cá nhân',
            'tab-edit': 'Cập nhật thông tin',
            'tab-security': 'Bảo mật và mật khẩu',
            'tab-notifications': 'Thông báo hệ thống',
        };

        function updateUnifiedHeaderTitle(tabId) {
            const el = document.getElementById('unified-header-title');
            const title = TAB_TITLES[tabId];
            if (!el || !title) return;
            el.style.opacity = '0';
            setTimeout(() => {
                el.textContent = title;
                el.style.opacity = '1';
            }, 160);
        }

        function steadyProfileTabHeight(previousPane, targetPane) {
            const contentWrapper = document.querySelector('.dashboard-content-wrapper');
            if (!contentWrapper || !targetPane) return;
            clearTimeout(profileTabSwitchTimer);
            const currentHeight = contentWrapper.offsetHeight;
            const previousHeight = previousPane ? previousPane.offsetHeight : 0;
            const nextHeight = targetPane.scrollHeight;
            contentWrapper.classList.add('is-switching-tab');
            contentWrapper.style.minHeight = Math.max(currentHeight, previousHeight, nextHeight) + 'px';
            profileTabSwitchTimer = window.setTimeout(() => {
                contentWrapper.classList.remove('is-switching-tab');
                contentWrapper.style.minHeight = '';
            }, 320);
        }

        function settleProfileTabScroll() {
            const dashboard = document.querySelector('.app-dashboard-container');
            if (!dashboard) return;
            const dashboardTop = dashboard.getBoundingClientRect().top + window.scrollY;
            const headerOffset = window.innerWidth < 1024 ? 72 : 96;
            const targetTop = Math.max(dashboardTop - headerOffset, 0);
            const viewportBottom = window.scrollY + window.innerHeight;
            const dashboardBottom = dashboardTop + dashboard.offsetHeight;
            const isDeepInsideOldTab = window.scrollY > targetTop + 120;
            const isBelowNewContent = viewportBottom > dashboardBottom + 80;
            if (isDeepInsideOldTab || isBelowNewContent) {
                const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
                window.scrollTo({ top: targetTop, behavior: prefersReducedMotion ? 'auto' : 'smooth' });
            }
        }

        function toggleAccountNameEdit(isEditing) {
            const nameView = document.querySelector('.account-identity .account-name');
            const form = document.getElementById('accountNameInlineForm');
            const editTrigger = document.getElementById('accountEditTrigger');
            const editActions = document.getElementById('accountEditActions');
            const input = document.getElementById('accountDisplayNameInput');

            if (!nameView || !form || !editTrigger || !editActions) {
                return;
            }

            nameView.style.display = isEditing ? 'none' : '';
            form.style.display = isEditing ? 'block' : 'none';
            editTrigger.style.display = isEditing ? 'none' : 'inline-flex';
            editActions.style.display = isEditing ? 'flex' : 'none';

            if (isEditing && input) {
                input.focus();
                input.select();
            } else if (input) {
                input.value = input.defaultValue;
            }
        }

        function switchTab(targetTabId, options = {}) {
            targetTabId = normalizeProfileTabId(targetTabId);
            const targetPane = document.getElementById(targetTabId);
            if (!targetPane || targetPane.classList.contains('active-pane')) {
                document.querySelectorAll('.sidebar-menu a').forEach(link => link.classList.remove('active'));
                let activeNav = document.getElementById('nav-' + targetTabId);
                if (!activeNav && targetTabId === 'tab-edit') {
                    activeNav = document.getElementById('nav-tab-profile');
                }
                if (activeNav) activeNav.classList.add('active');
                if (targetPane) updateUnifiedHeaderTitle(targetTabId);
                if (targetPane && options.updateUrl) updateProfileTabUrl(targetTabId, options.replaceUrl);
                return;
            }
            const previousPane = document.querySelector('.tab-pane.active-pane');
            steadyProfileTabHeight(previousPane, targetPane);
            document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active-pane'));
            document.querySelectorAll('.sidebar-menu a').forEach(link => link.classList.remove('active'));
            targetPane.classList.add('active-pane');
            const activeNav = document.getElementById('nav-' + targetTabId);
            if (activeNav) {
                activeNav.classList.add('active');
            } else if (targetTabId === 'tab-edit') {
                const profileNav = document.getElementById('nav-tab-profile');
                if (profileNav) profileNav.classList.add('active');
            }
            updateUnifiedHeaderTitle(targetTabId);
            if (options.updateUrl !== false) updateProfileTabUrl(targetTabId, options.replaceUrl);
            requestAnimationFrame(settleProfileTabScroll);
        }

        <% if (session.getAttribute("toastMsg") != null) { 
            String msg = (String) session.getAttribute("toastMsg");
            String type = (String) session.getAttribute("toastType");
            session.removeAttribute("toastMsg");
            session.removeAttribute("toastType");
        %>
        window.addEventListener('DOMContentLoaded', () => {
            showToast("<%= msg.replace("\"", "\\\"") %>", "<%= type != null ? type : "success" %>");
        });
        <% } %>
        window.addEventListener('DOMContentLoaded', () => {
            const urlParams = new URLSearchParams(window.location.search);
            const tabParam = urlParams.get('tab');
            if (tabParam) {
                switchTab(tabParam, { replaceUrl: true });
            } else {
                const activePane = document.querySelector('.tab-pane.active-pane');
                if (activePane) updateProfileTabUrl(activePane.id, true);
            }
            initAdminStatusWS();
        });

        window.addEventListener('popstate', (event) => {
            const stateTab = event.state && event.state.profileTab;
            const urlTab = new URLSearchParams(window.location.search).get('tab');
            switchTab(stateTab || urlTab || 'tab-dashboard', { updateUrl: false });
        });

        // Xử lý gửi form hỗ trợ qua Servlet
        const supportForm = document.getElementById('supportForm');
        if (supportForm) {
            supportForm.addEventListener('submit', function(e) {
                e.preventDefault();
                const formData = new FormData(this);
                const submitBtn = this.querySelector('button[type="submit"]');
                const originalBtnText = submitBtn.innerText;
                
                submitBtn.disabled = true;
                submitBtn.innerText = 'Đang gửi...';

                fetch('${pageContext.request.contextPath}/support', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                .then(async response => {
                    if (response.ok) {
                        showToast('Đã gửi thành công đến quản trị viên, phản hồi sẽ gửi đến email của bạn.');
                        this.reset();
                    } else {
                        const errorMsg = await response.text();
                        showToast(errorMsg || 'Có lỗi xảy ra khi gửi yêu cầu hỗ trợ.', 'error');
                    }
                })
                .catch(error => {
                    console.error('Support Error:', error);
                    showToast('Lỗi kết nối máy chủ. Vui lòng thử lại sau.', 'error');
                })
                .finally(() => {
                    submitBtn.disabled = false;
                    submitBtn.innerText = originalBtnText;
                });
            });
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>

