<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Role"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.TeacherApplication"%>
<%@page import="com.hipzi.model.Notification"%>
<%@page import="com.hipzi.service.NotificationService"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ giảng viên - HIPZI</title>
    <meta name="description" content="Quản lý thông tin tài khoản, kho tài liệu giảng dạy và học liệu AI của giảng viên trên nền tảng HIPZI.">
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

        /* ===== TAB GROUPED AESTHETIC (NEW) ===== */
        .tab-grouped-container {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-radius: 0;
            border: none;
            box-shadow: none;
            overflow-y: auto;
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
            color: #ffffff;
        }

        .tab-header-title-text {
            font-size: 1.15rem;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .tab-header-date-pill {
            background: rgba(255, 255, 255, 0.15);
            padding: 0.4rem 1rem;
            border-radius: 2rem;
            font-size: 0.8rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .tab-body-content {
            padding: 2rem;
            display: flex;
            flex-direction: column;
            gap: 2rem;
            flex: 1;
            min-height: 0;
            overflow-y: auto;
        }

        #tab-class-registration, #tab-upload-material {
            overflow-y: auto;
            overflow-x: hidden;
        }

        #tab-class-registration .tab-grouped-container, #tab-upload-material .tab-grouped-container {
            overflow-y: auto;
            overflow-x: hidden;
        }

        #tab-class-registration .tab-body-content, #tab-upload-material .tab-body-content {
            flex: 0 0 auto;
            min-height: auto;
            overflow: visible;
            padding-bottom: 3rem;
        }

        .card-main-premium {
            padding: 0.25rem 0.5rem 1.5rem 0.5rem;
            flex: 1;
            min-height: 0;
            overflow-y: auto;
        }

        /* Override for section-data-card when inside tab-body-content */
        .tab-body-content .section-data-card {
            border: none;
            padding: 0;
            box-shadow: none;
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

        .upload-material-info-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.15fr) minmax(260px, 0.85fr);
            gap: 1.25rem;
            align-items: stretch;
            margin-top: 1.5rem;
        }

        .upload-material-steps {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.75rem;
            margin-top: 0.25rem;
        }

        @media (max-width: 900px) {
            .upload-material-info-grid,
            .upload-material-steps,
            .repository-upload-form {
                grid-template-columns: 1fr !important;
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
        .form-group-edit select,
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
        .form-group-edit select:focus,
        .form-group-edit textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        .class-day-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 0.65rem;
        }

        .class-day-option {
            display: flex;
            align-items: center;
            gap: 0.55rem;
            padding: 0.7rem 0.85rem;
            border: 1px solid var(--border-dark);
            border-radius: 0.75rem;
            background: #ffffff;
            color: var(--text-main);
            font-size: 0.9rem;
            font-weight: 700;
            cursor: pointer;
            transition: border-color 0.2s ease, background 0.2s ease, color 0.2s ease;
        }

        .class-day-option:hover {
            border-color: var(--primary);
            background: var(--primary-light);
        }

        .class-day-option input {
            width: 1rem;
            height: 1rem;
            padding: 0;
            margin: 0;
            flex-shrink: 0;
            accent-color: var(--primary);
        }

        .class-time-input {
            min-height: 3rem;
            background:
                linear-gradient(135deg, #ffffff 0%, #f8fafc 100%),
                #ffffff;
            background-image:
                url("data:image/svg+xml,%3Csvg width='18' height='18' viewBox='0 0 24 24' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Ccircle cx='12' cy='12' r='9' stroke='%23059669' stroke-width='2'/%3E%3Cpath d='M12 7v5l3 2' stroke='%23059669' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E"),
                linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            background-repeat: no-repeat, no-repeat;
            background-position: right 1rem center, left top;
            background-size: 18px 18px, 100% 100%;
            padding-right: 3rem !important;
            font-weight: 700;
        }

        .class-time-input::placeholder {
            color: #94a3b8;
            font-weight: 600;
        }

        .class-time-input:invalid:not(:placeholder-shown) {
            border-color: #fca5a5;
            box-shadow: 0 0 0 3px #fee2e2;
        }

        .form-actions-row {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .teacher-application-status {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            padding: 1rem 1.25rem;
            border-radius: 1rem;
            background: #ecfdf5;
            border: 1px solid #bbf7d0;
            color: #065f46;
        }

        .teacher-application-status svg {
            flex-shrink: 0;
            margin-top: 0.15rem;
        }

        .teacher-type-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 1rem;
        }

        .teacher-type-card {
            cursor: pointer;
            min-height: 100%;
            position: relative;
            display: block;
        }

        .teacher-type-card input {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .teacher-type-card-inner {
            min-height: 100%;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.2rem;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            gap: 0.9rem;
            transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .teacher-type-card-inner::after {
            content: '\2713';
            position: absolute;
            top: 0.85rem;
            right: 0.85rem;
            width: 28px;
            height: 28px;
            border-radius: 999px;
            background: var(--primary);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 0.9rem;
            box-shadow: 0 8px 18px rgba(5, 150, 105, 0.24);
            opacity: 0;
            transform: scale(0.72);
            transition: opacity 0.18s ease, transform 0.18s ease;
        }

        .teacher-type-card:hover .teacher-type-card-inner {
            border-color: var(--primary);
            box-shadow: 0 10px 24px rgba(5, 150, 105, 0.12);
            transform: translateY(-2px);
        }

        .teacher-type-card input:checked + .teacher-type-card-inner {
            border-color: var(--primary);
            background: linear-gradient(180deg, #ecfdf5 0%, #ffffff 58%);
            box-shadow:
                0 0 0 3px rgba(5, 150, 105, 0.18),
                0 18px 36px rgba(5, 150, 105, 0.2);
            transform: translateY(-3px);
        }

        .teacher-type-card input:checked + .teacher-type-card-inner::after {
            opacity: 1;
            transform: scale(1);
        }

        .teacher-type-card input:checked + .teacher-type-card-inner .teacher-type-kicker {
            background: #059669;
            color: #ffffff;
        }

        .teacher-type-card input:checked + .teacher-type-card-inner .teacher-type-title {
            color: #047857;
        }

        .teacher-type-helper-text {
            margin: 0 0 1rem 0;
            color: var(--text-muted);
            font-size: 0.92rem;
            font-weight: 700;
            line-height: 1.55;
        }

        .teacher-type-kicker {
            display: inline-flex;
            align-items: center;
            width: fit-content;
            padding: 0.22rem 0.65rem;
            border-radius: 999px;
            background: var(--primary-light);
            color: var(--primary);
            font-size: 0.72rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .teacher-type-title {
            margin: 0;
            color: var(--text-main);
            font-size: 1rem;
            font-weight: 800;
            line-height: 1.35;
        }

        .teacher-type-description {
            margin: 0;
            color: var(--text-muted);
            font-size: 0.85rem;
            line-height: 1.55;
        }

        .teacher-type-examples,
        .teacher-type-requirements {
            display: flex;
            flex-direction: column;
            gap: 0.45rem;
            margin: 0;
            padding: 0;
            list-style: none;
        }

        .teacher-type-examples li,
        .teacher-type-requirements li {
            display: flex;
            align-items: flex-start;
            gap: 0.45rem;
            color: var(--text-muted);
            font-size: 0.8rem;
            line-height: 1.45;
        }

        .teacher-type-examples li::before,
        .teacher-type-requirements li::before {
            content: '';
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--primary);
            flex-shrink: 0;
            margin-top: 0.45rem;
        }

        .teacher-registration-form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.25rem;
        }

        .teacher-registration-form-grid .full-span {
            grid-column: 1 / -1;
        }

        .teacher-evidence-box {
            border: 1px dashed #94a3b8;
            border-radius: 1rem;
            padding: 1rem;
            background: #f8fafc;
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
                grid-template-columns: repeat(2, 1fr);
            }
            .teacher-type-grid,
            .teacher-registration-form-grid {
                grid-template-columns: 1fr;
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
                grid-template-columns: 1fr;
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
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
</head>
<body>

    <%
        User user = (User) request.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("loggedUser");
        }
        List<Role> roles = (user != null) ? user.getRoles() : null;

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

        TeacherApplication teacherApplication = (TeacherApplication) request.getAttribute("teacherApplication");
        List<Classroom> teacherClassrooms = (List<Classroom>) request.getAttribute("teacherClassrooms");
        boolean teachingRegistrationSubmitted = teacherApplication != null || Boolean.TRUE.equals(session.getAttribute("teacherRegistrationSubmitted"));
        String teachingRegistrationStatus = teacherApplication != null ? teacherApplication.getStatus() : null;
        String teachingRegistrationStatusLabel = "Đang chờ duyệt";
        if ("approved".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Đã duyệt";
        } else if ("rejected".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Không được duyệt";
        } else if ("needs_more_info".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Cần bổ sung thông tin";
        }
        boolean registrationNeedsAttention = !teachingRegistrationSubmitted
                || "rejected".equals(teachingRegistrationStatus)
                || "needs_more_info".equals(teachingRegistrationStatus);
        String initialTeacherTab = request.getParameter("tab");
        if (initialTeacherTab == null || initialTeacherTab.trim().isEmpty()) {
            initialTeacherTab = "tab-teaching-registration";
        } else {
            initialTeacherTab = initialTeacherTab.trim();
            if (initialTeacherTab.equals("materials") || initialTeacherTab.equals("practice") ||
                initialTeacherTab.equals("tab-materials") || initialTeacherTab.equals("tab-practice")) {
                initialTeacherTab = "tab-upload-material";
            } else if (!initialTeacherTab.startsWith("tab-")) {
                initialTeacherTab = "tab-" + initialTeacherTab;
            }
            if (!initialTeacherTab.equals("tab-teaching-registration") &&
                !initialTeacherTab.equals("tab-class-registration") &&
                !initialTeacherTab.equals("tab-profile") &&
                !initialTeacherTab.equals("tab-edit") &&
                !initialTeacherTab.equals("tab-security") &&
                !initialTeacherTab.equals("tab-upload-material") &&
                !initialTeacherTab.equals("tab-notifications") &&
                !initialTeacherTab.equals("tab-support")) {
                initialTeacherTab = "tab-teaching-registration";
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


                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
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
                <%= "tab-class-registration".equals(initialTeacherTab) ? "Đăng kí lớp học" :
                    "tab-profile".equals(initialTeacherTab) ? "Hồ sơ cá nhân" :
                    "tab-edit".equals(initialTeacherTab) ? "Cập nhật thông tin" :
                    "tab-security".equals(initialTeacherTab) ? "Bảo mật và mật khẩu" :
                    "tab-upload-material".equals(initialTeacherTab) ? "Đăng tải tài liệu" :
                    "tab-notifications".equals(initialTeacherTab) ? "Thông báo hệ thống" :
                    "tab-support".equals(initialTeacherTab) ? "Hỗ trợ giảng dạy" :
                    "Đăng kí giảng dạy" %>
            </span>
            <div class="unified-header-right">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span><%= currentDateDisplay %></span>
            </div>
        </div>

        <div class="dashboard-body">
            <!-- KÊNH SIDEBAR TRÁI (LEFT PANE) -->
            <aside class="dashboard-sidebar">
                <div class="sidebar-top-group">
                    <ul class="sidebar-menu">
                        <li>
                            <a id="nav-tab-teaching-registration" class="<%= "tab-teaching-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-teaching-registration')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                                <span>Đăng kí giảng dạy</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-class-registration" class="<%= "tab-class-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-class-registration')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                <span>Đăng kí lớp học</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-profile" class="<%= ("tab-profile".equals(initialTeacherTab) || "tab-edit".equals(initialTeacherTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                <span>Hồ sơ cá nhân</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-security" class="<%= "tab-security".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-security')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                <span>Bảo mật và mật khẩu</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-upload-material" class="<%= "tab-upload-material".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-upload-material')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                <span>Đăng tải tài liệu</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-notifications" class="<%= "tab-notifications".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-notifications')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                <span>Thông báo hệ thống</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-support" class="<%= "tab-support".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-support')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                <span>Hỗ trợ giảng dạy</span>
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
            <section id="tab-teaching-registration" class="tab-pane <%= "tab-teaching-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Đăng kí giảng dạy</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <% if (teachingRegistrationSubmitted) { %>
                            <div class="teacher-application-status">
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                <div>
                                    <div style="font-weight:800; margin-bottom:0.25rem;">Hồ sơ đăng kí giảng dạy đã được gửi.</div>
                                    <div style="font-size:0.82rem; font-weight:800; margin-bottom:0.35rem; text-transform:uppercase; letter-spacing:0.4px;">Trạng thái: <%= teachingRegistrationStatusLabel %></div>
                                    <div style="font-size:0.9rem; line-height:1.55;">
                                        <% if (teacherApplication != null && teacherApplication.getReviewNote() != null && !teacherApplication.getReviewNote().trim().isEmpty()) { %>
                                            <%= teacherApplication.getReviewNote() %>
                                        <% } else { %>
                                            Đội ngũ quản trị sẽ kiểm tra minh chứng và phản hồi qua email. Bạn vẫn có thể gửi lại nếu cần cập nhật thông tin.
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        <% } %>

                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" enctype="multipart/form-data" class="form-edit-layout" style="padding:0;" onsubmit="return validateTeachingSubjects()">
                            <input type="hidden" name="action" value="submitTeachingRegistration">

                            <div class="section-data-card">
                                <div class="card-header-layout">
                                    <div class="card-header-title">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                                        <span>Phân loại giảng viên</span>
                                    </div>
                                    <span style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">Bắt buộc</span>
                                </div>

                                <div style="padding:1.5rem;">
                                    <p class="teacher-type-helper-text">Vui lòng chọn nhóm giảng viên hiện tại của bạn trước khi điền thông tin.</p>
                                    <div class="teacher-type-grid">
                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="student_tutor" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nhóm 1</span>
                                                <h3 class="teacher-type-title">Gia sư sinh viên</h3>
                                                <p class="teacher-type-description">Phù hợp với học viên cần người hướng dẫn gần gũi, hỗ trợ bài tập, ôn tập kiến thức nền tảng hoặc học theo nhóm nhỏ.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Sinh viên Sư phạm Toán</li>
                                                    <li>Sinh viên Công nghệ thông tin dạy lập trình cơ bản</li>
                                                    <li>Sinh viên IELTS 7.5 dạy tiếng Anh</li>
                                                    <li>Sinh viên năm 3, năm 4 có thành tích học tập tốt</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Trường đang học, chuyên ngành, năm học hiện tại</li>
                                                    <li>Môn có thể dạy</li>
                                                    <li>Thẻ sinh viên hoặc minh chứng đang học</li>
                                                    <li>Thành tích hoặc chứng chỉ nếu có</li>
                                                </ul>
                                            </div>
                                        </label>

                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="certified_pedagogy" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nhóm 2</span>
                                                <h3 class="teacher-type-title">Giảng viên có chứng chỉ sư phạm</h3>
                                                <p class="teacher-type-description">Phù hợp với học viên cần người dạy có nền tảng giảng dạy, phương pháp truyền đạt rõ ràng và tập trung vào một số môn cụ thể.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Người có chứng chỉ nghiệp vụ sư phạm</li>
                                                    <li>Người có chứng chỉ dạy tiếng Anh</li>
                                                    <li>Người có chứng chỉ đào tạo kỹ năng</li>
                                                    <li>Người có chứng chỉ dạy tin học hoặc lập trình</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Chứng chỉ sư phạm hoặc chứng chỉ giảng dạy</li>
                                                    <li>Môn có thể dạy</li>
                                                    <li>Kinh nghiệm dạy học nếu có</li>
                                                    <li>Hồ sơ cá nhân và minh chứng chuyên môn liên quan</li>
                                                </ul>
                                            </div>
                                        </label>

                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="degree_specialist" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nhóm 3</span>
                                                <h3 class="teacher-type-title">Giảng viên chuyên môn</h3>
                                                <p class="teacher-type-description">Dành cho giảng viên, giáo viên đã tốt nghiệp, có bằng cấp chuyên môn rõ ràng hoặc đang/đã làm việc trong lĩnh vực giảng dạy.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Cử nhân Sư phạm Toán</li>
                                                    <li>Cử nhân Ngôn ngữ Anh</li>
                                                    <li>Thạc sĩ ngành Giáo dục</li>
                                                    <li>Giáo viên THCS/THPT, giảng viên đại học hoặc chuyên gia phù hợp</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Bằng đại học, cao học hoặc bằng chuyên môn</li>
                                                    <li>Chuyên ngành đào tạo</li>
                                                    <li>Kinh nghiệm giảng dạy</li>
                                                    <li>Môn phụ trách, nơi từng/đang công tác nếu có</li>
                                                </ul>
                                            </div>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="section-data-card">
                                <div class="card-header-layout">
                                    <div class="card-header-title">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                        <span>Thông tin xác minh</span>
                                    </div>
                                </div>

                                <div style="padding:1.5rem;">
                                    <div class="teacher-registration-form-grid">
                                        <div class="form-group-edit">
                                            <label>Trường / đơn vị đang học hoặc công tác</label>
                                            <input type="text" name="institutionName" placeholder="Ví dụ: Đại học Sư phạm TP.HCM, THPT Chuyên Lê Hồng Phong" required>
                                        </div>
                                        <div class="form-group-edit">
                                            <label>Chuyên ngành / lĩnh vực chuyên môn</label>
                                            <input type="text" name="specialization" placeholder="Ví dụ: Sư phạm Toán, Ngôn ngữ Anh, Công nghệ thông tin" required>
                                        </div>
                                        <div class="form-group-edit">
                                            <label>Năm học hiện tại</label>
                                            <select name="currentStudyYear">
                                                <option value="">Không áp dụng</option>
                                                <option value="year_1">Năm 1</option>
                                                <option value="year_2">Năm 2</option>
                                                <option value="year_3">Năm 3</option>
                                                <option value="year_4">Năm 4</option>
                                                <option value="year_5_plus">Năm 5 trở lên</option>
                                                <option value="graduated">Đã tốt nghiệp</option>
                                            </select>
                                        </div>
                                        <div class="form-group-edit full-span">
                                            <label>Môn có thể dạy (Có thể chọn nhiều môn)</label>
                                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 1rem; margin-top: 0.5rem; background: #f8fafc; padding: 1rem; border-radius: 0.75rem; border: 1px solid var(--border-dark);">
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Toán" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Toán học
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Văn" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Ngữ Văn
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Anh" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Tiếng Anh
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Lý" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Vật Lý
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Hóa" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Hóa Học
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Sinh Học" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Sinh Học
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Lịch Sử" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Lịch Sử
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Địa Lý" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Địa Lý
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Công Nghệ" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Công Nghệ
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Tin Học" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Tin Học
                                                </label>
                                            </div>
                                        </div>
                                        <div class="form-group-edit">
                                            <label>Kinh nghiệm giảng dạy</label>
                                            <input type="text" name="teachingExperience" placeholder="Ví dụ: 2 năm dạy kèm Toán THPT, trợ giảng trung tâm tiếng Anh">
                                        </div>
                                        <div class="form-group-edit">
                                            <label>Nơi từng/đang công tác</label>
                                            <input type="text" name="workplace" placeholder="Điền nếu có">
                                        </div>
                                        <div class="form-group-edit full-span">
                                            <label>Thành tích, chứng chỉ hoặc bằng cấp liên quan</label>
                                            <textarea name="credentialsSummary" rows="3" placeholder="Ví dụ: IELTS 7.5, giải học sinh giỏi, chứng chỉ nghiệp vụ sư phạm, bằng cử nhân..."></textarea>
                                        </div>
                                        <div class="form-group-edit full-span">
                                            <label>Hồ sơ cá nhân ngắn</label>
                                            <textarea name="teacherBio" rows="4" placeholder="Giới thiệu phương pháp dạy, nhóm học viên phù hợp và điểm mạnh chuyên môn của bạn." required></textarea>
                                        </div>
                                        <div class="form-group-edit full-span">
                                            <label>Minh chứng xác minh</label>
                                            <div class="teacher-evidence-box">
                                                <input type="file" name="evidenceFiles" multiple accept=".pdf,.png,.jpg,.jpeg,.webp,.doc,.docx">
                                                <p style="font-size:0.8rem; color:var(--text-muted); margin:0.75rem 0 0 0;">Có thể đính kèm thẻ sinh viên, chứng chỉ, bằng cấp, bảng điểm hoặc giấy xác nhận công tác. Mỗi file tối đa 5MB.</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions-row">
                                <button type="submit" class="btn-card-edit">
                                    <span>Gửi hồ sơ đăng kí</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4 20-7z"/></svg>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: ĐĂNG KÍ LỚP HỌC                       -->
            <!-- ========================================== -->
            <section id="tab-class-registration" class="tab-pane <%= "tab-class-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Đăng kí lớp học</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                    <div class="tab-body-content">
                        <%
                            String[] registeredSubjects = new String[0];
                            if (teacherApplication != null && "approved".equals(teacherApplication.getStatus()) && teacherApplication.getTeachingSubjects() != null && !teacherApplication.getTeachingSubjects().isEmpty()) {
                                registeredSubjects = teacherApplication.getTeachingSubjects().split("\\s*,\\s*");
                            }
                        %>

                        <div class="section-data-card" style="margin-bottom:1.25rem;">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M8 6h13"/><path d="M8 12h13"/><path d="M8 18h13"/><path d="M3 6h.01"/><path d="M3 12h.01"/><path d="M3 18h.01"/></svg>
                                    <span>Lớp học đã đăng kí</span>
                                </div>
                            </div>

                            <% if (teacherClassrooms != null && !teacherClassrooms.isEmpty()) { %>
                                <div style="display:flex; flex-direction:column; gap:1rem; padding-top:1.25rem;">
                                    <% for (Classroom cls : teacherClassrooms) {
                                        String startValue = cls.getStartTime() != null ? cls.getStartTime().toLocalTime().toString().substring(0, 5) : "";
                                        String endValue = cls.getEndTime() != null ? cls.getEndTime().toLocalTime().toString().substring(0, 5) : "";
                                    %>
                                        <div style="border:1px solid #e2e8f0; border-radius:0.9rem; padding:1.1rem; background:#ffffff;">
                                            <div style="display:flex; justify-content:space-between; gap:1rem; align-items:flex-start; flex-wrap:wrap;">
                                                <div style="min-width:240px; flex:1;">
                                                    <div style="display:flex; align-items:center; gap:0.55rem; flex-wrap:wrap; margin-bottom:0.55rem;">
                                                        <span class="subject-badge" style="background:#ecfdf5; color:#047857;"><%= cls.getSubject() %></span>
                                                        <span style="font-size:0.75rem; font-weight:800; padding:0.2rem 0.65rem; border-radius:999px; background:#f8fafc; color:#475569;"><%= cls.getStatusLabel() %></span>
                                                        <% if (cls.getGrade() != null && !cls.getGrade().isEmpty()) { %>
                                                            <span style="font-size:0.75rem; font-weight:800; color:#64748b;"><%= cls.getGrade() %></span>
                                                        <% } %>
                                                    </div>
                                                    <h3 style="font-size:1.05rem; font-weight:800; color:var(--text-main); margin:0 0 0.45rem 0;"><%= cls.getTitle() %></h3>
                                                    <p style="display:flex; align-items:center; gap:0.45rem; color:#047857; font-weight:700; margin:0 0 0.5rem 0; font-size:0.9rem;">
                                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                                        <span><%= cls.getSchedule() %></span>
                                                    </p>
                                                    <% if (cls.getDescription() != null && !cls.getDescription().isEmpty()) { %>
                                                        <p style="color:var(--text-muted); font-size:0.9rem; line-height:1.55; margin:0;"><%= cls.getDescription() %></p>
                                                    <% } %>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa lớp học này?');">
                                                    <input type="hidden" name="action" value="deleteClass">
                                                    <input type="hidden" name="classId" value="<%= cls.getId() %>">
                                                    <button type="submit" class="btn-card-edit-light" style="color:#dc2626; border-color:#fecaca;" title="Xóa lớp học">
                                                        <span>Xóa</span>
                                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                                    </button>
                                                </form>
                                            </div>

                                            <details style="margin-top:1rem;">
                                                <summary style="cursor:pointer; font-weight:800; color:var(--primary); font-size:0.9rem;">Chỉnh sửa lớp học</summary>
                                                <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" class="form-edit-layout" style="padding:1rem 0 0 0;">
                                                    <input type="hidden" name="action" value="updateClass">
                                                    <input type="hidden" name="classId" value="<%= cls.getId() %>">
                                                    <div class="form-grid-2">
                                                        <div class="form-group-edit">
                                                            <label>Tên lớp học</label>
                                                            <input type="text" name="className" value="<%= cls.getTitle() %>" required>
                                                        </div>
                                                        <div class="form-group-edit">
                                                            <label>Môn học</label>
                                                            <select name="classSubject" style="width:100%; padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); outline:none;" required>
                                                                <% for (String subject : registeredSubjects) { %>
                                                                    <option value="<%= subject %>" <%= subject.equalsIgnoreCase(cls.getSubject()) ? "selected" : "" %>><%= subject %></option>
                                                                <% } %>
                                                            </select>
                                                        </div>
                                                        <div class="form-group-edit">
                                                            <label>Khối lớp</label>
                                                            <select name="classGrade" required>
                                                                <option value="Lớp 10" <%= "Lớp 10".equals(cls.getGrade()) ? "selected" : "" %>>Lớp 10</option>
                                                                <option value="Lớp 11" <%= "Lớp 11".equals(cls.getGrade()) ? "selected" : "" %>>Lớp 11</option>
                                                                <option value="Lớp 12" <%= "Lớp 12".equals(cls.getGrade()) ? "selected" : "" %>>Lớp 12</option>
                                                                <option value="Ôn thi THPT" <%= "Ôn thi THPT".equals(cls.getGrade()) ? "selected" : "" %>>Ôn thi THPT</option>
                                                            </select>
                                                        </div>
                                                        <div class="form-group-edit">
                                                            <label>Trạng thái</label>
                                                            <select name="classStatus" style="width:100%; padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); outline:none;">
                                                                <option value="open" <%= "open".equals(cls.getStatus()) || "Đang mở".equals(cls.getStatus()) ? "selected" : "" %>>Đang mở</option>
                                                                <option value="upcoming" <%= "upcoming".equals(cls.getStatus()) || "Sắp khai giảng".equals(cls.getStatus()) ? "selected" : "" %>>Sắp khai giảng</option>
                                                                <option value="closed" <%= "closed".equals(cls.getStatus()) ? "selected" : "" %>>Đã đóng</option>
                                                            </select>
                                                        </div>
                                                        <div class="form-group-edit">
                                                            <label>Thứ học</label>
                                                            <div class="class-day-options">
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 2" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thứ 2") ? "checked" : "" %>> Thứ 2</label>
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 3" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thứ 3") ? "checked" : "" %>> Thứ 3</label>
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 4" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thứ 4") ? "checked" : "" %>> Thứ 4</label>
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 5" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thứ 5") ? "checked" : "" %>> Thứ 5</label>
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 6" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thứ 6") ? "checked" : "" %>> Thứ 6</label>
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 7" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thứ 7") ? "checked" : "" %>> Thứ 7</label>
                                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Chủ nhật" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Chủ nhật") ? "checked" : "" %>> Chủ nhật</label>
                                                            </div>
                                                        </div>
                                                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:0.75rem;">
                                                            <div class="form-group-edit">
                                                                <label>Giờ bắt đầu</label>
                                                                <input type="text" name="startTime" class="class-time-input" value="<%= startValue %>" placeholder="__:__" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                                            </div>
                                                            <div class="form-group-edit">
                                                                <label>Giờ kết thúc</label>
                                                                <input type="text" name="endTime" class="class-time-input" value="<%= endValue %>" placeholder="__:__" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                                            </div>
                                                        </div>
                                                        <div class="form-group-edit full-span">
                                                            <label>Mô tả ngắn</label>
                                                            <textarea name="classDescription" rows="3"><%= cls.getDescription() != null ? cls.getDescription() : "" %></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="form-actions-row">
                                                        <button type="submit" class="btn-card-edit" style="padding:0.75rem 1.5rem;">Lưu thay đổi</button>
                                                    </div>
                                                </form>
                                            </details>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="empty-status-panel" style="padding:2.25rem 1.5rem; margin-top:1rem;">
                                    <p style="margin:0; color:var(--text-muted); font-weight:700;">Bạn chưa đăng kí lớp học nào.</p>
                                </div>
                            <% } %>
                        </div>

                        <div class="section-data-card">
                            <div class="form-edit-layout">
                                <div class="card-header-title" style="margin-bottom: 1rem;">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                    <span>Tạo lớp học mới</span>
                                </div>
                                <p style="color:var(--text-muted); font-size:0.9rem; margin-bottom:1.5rem;">
                                    Lưu ý: Bạn chỉ được phép mở lớp dạy cho các môn học đã được hệ thống phê duyệt trong hồ sơ năng lực của mình.
                                </p>

                                <% if (registeredSubjects.length > 0) { %>
                                    <form action="${pageContext.request.contextPath}/teacher-profile" method="POST">
                                        <input type="hidden" name="action" value="registerClass">
                                        
                                        <div class="form-group-edit" style="margin-bottom: 1.25rem;">
                                            <label>Tên lớp học</label>
                                            <input type="text" name="className" placeholder="Ví dụ: Lớp Toán 10A, Tiếng Anh giao tiếp..." required>
                                        </div>

                                        <div class="form-group-edit" style="margin-bottom: 1.25rem;">
                                            <label>Chọn môn học</label>
                                            <select name="classSubject" style="width: 100%; padding: 0.75rem 1rem; border-radius: 0.75rem; border: 1px solid var(--border-dark); outline: none;" required>
                                                <option value="" disabled selected>-- Chọn môn học --</option>
                                                <% for (String subject : registeredSubjects) { %>
                                                    <option value="<%= subject %>"><%= subject %></option>
                                                <% } %>
                                            </select>
                                        </div>

                                        <div class="form-group-edit" style="margin-bottom: 1.25rem;">
                                            <label>Khối lớp</label>
                                            <select name="classGrade" required>
                                                <option value="" disabled selected>-- Chọn khối lớp --</option>
                                                <option value="Lớp 10">Lớp 10</option>
                                                <option value="Lớp 11">Lớp 11</option>
                                                <option value="Lớp 12">Lớp 12</option>
                                                <option value="Ôn thi THPT">Ôn thi THPT</option>
                                            </select>
                                        </div>

                                        <div class="form-group-edit" style="margin-bottom: 1.25rem;">
                                            <label>Thứ học</label>
                                            <div class="class-day-options">
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 2"> Thứ 2</label>
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 3"> Thứ 3</label>
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 4"> Thứ 4</label>
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 5"> Thứ 5</label>
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 6"> Thứ 6</label>
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thứ 7"> Thứ 7</label>
                                                <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Chủ nhật"> Chủ nhật</label>
                                            </div>
                                        </div>

                                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:0.75rem; margin-bottom:1.25rem;">
                                            <div class="form-group-edit">
                                                <label>Giờ bắt đầu</label>
                                                <input type="text" name="startTime" class="class-time-input" placeholder="__:__" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                            </div>
                                            <div class="form-group-edit">
                                                <label>Giờ kết thúc</label>
                                                <input type="text" name="endTime" class="class-time-input" placeholder="__:__" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                            </div>
                                        </div>

                                        <div class="form-group-edit" style="margin-bottom: 1.25rem;">
                                            <label>Trạng thái</label>
                                            <select name="classStatus" style="width: 100%; padding: 0.75rem 1rem; border-radius: 0.75rem; border: 1px solid var(--border-dark); outline: none;">
                                                <option value="open">Đang mở</option>
                                                <option value="upcoming">Sắp khai giảng</option>
                                                <option value="closed">Đã đóng</option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group-edit" style="margin-bottom: 1.25rem;">
                                            <label>Mô tả ngắn</label>
                                            <textarea name="classDescription" rows="3" placeholder="Nhập mô tả về lớp học này..."></textarea>
                                        </div>

                                        <div class="form-actions-row">
                                            <button type="submit" class="btn-card-edit" style="padding: 0.75rem 1.5rem;">Đăng kí lớp học</button>
                                        </div>
                                    </form>
                                <% } else if (teacherApplication != null && !"approved".equals(teacherApplication.getStatus())) { %>
                                    <div style="background: #fffbeb; border: 1px solid #fde68a; color: #b45309; padding: 1rem 1.25rem; border-radius: 0.75rem; font-weight: 600; font-size: 0.9rem;">
                                        Hồ sơ giảng viên của bạn chưa được duyệt. Vui lòng chờ quản trị viên phê duyệt hồ sơ trước khi đăng kí lớp học.
                                    </div>
                                <% } else { %>
                                    <div style="background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; padding: 1rem 1.25rem; border-radius: 0.75rem; font-weight: 600; font-size: 0.9rem;">
                                        Bạn chưa gửi hồ sơ đăng kí giảng dạy hoặc chưa chọn môn học. Vui lòng hoàn thiện hồ sơ.
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Hồ sơ cá nhân</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div style="background:linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); display:flex; flex-direction:column; gap:2rem; flex:1; min-height:0;">
                            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1.5rem; padding-bottom:1.5rem; border-bottom:1px solid #f1f5f9;">
                                <div class="highlight-left-group" style="margin:0;">
                                <div class="highlight-avatar-container">
                                    <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                        <img src="<%= user.getAvatarUrl() %>" alt="Avatar">
                                    <% } else { %>
                                        <div class="highlight-avatar-placeholder"><%= initials %></div>
                                    <% } %>
                                    <label class="btn-avatar-camera" title="Thay đổi ảnh đại diện" onclick="document.getElementById('avatarFileInput').click();">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                                    </label>

                                    <!-- Form ngầm upload ảnh đại diện -->
                                    <form id="avatarUploadForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" style="display:none;">
                                        <input type="hidden" name="action" value="updateAvatar">
                                        <input type="file" id="avatarFileInput" name="avatarFile" accept="image/*" onchange="if(this.files.length > 0) { showToast('Đang tải ảnh lên...', 'info'); document.getElementById('avatarUploadForm').submit(); }">
                                    </form>
                                </div>
                                <div class="highlight-user-info">
                                    <h2><%= user != null ? user.getDisplayName() : "Giảng viên HIPZI" %></h2>
                                    <div class="highlight-meta-info" style="margin-top:0.35rem;">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                                        <span>Thành viên tích cực</span>
                                    </div>
                                </div>
                            </div>

                                <div style="display:flex; flex-direction:column; align-items:flex-end; text-align:right;">
                                    <span style="font-size:0.75rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.35rem;">Vai trò chính</span>
                                    <div class="highlight-user-roles" style="margin:0;">
                                        <% if (roles != null && !roles.isEmpty()) {
                                            for (Role r : roles) { %>
                                                <span class="role-tag <%= r.getName() %>" style="font-size:0.85rem; padding:0.4rem 1.15rem; border-radius:2rem;">
                                                    <%= r.getName().equals("student")  ? "Học viên"    :
                                                        r.getName().equals("parent")   ? "Phụ huynh"   :
                                                        r.getName().equals("teacher")  ? "Giảng viên"  :
                                                        r.getName().equals("staff")    ? "Nhân viên"   :
                                                        r.getName().equals("admin")    ? "Quản trị"    : r.getName() %>
                                                </span>
                                        <% }} else { %>
                                            <span class="role-tag teacher" style="font-size:0.85rem; padding:0.4rem 1.15rem; border-radius:2rem;">Giảng viên</span>
                                        <% } %>
                                    </div>
                                </div>
                        </div>

                            <div>
                                <div class="card-header-layout" style="padding:0 0 1.25rem 0; margin:0; border-bottom:none; background:transparent;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    <span>Thông tin cá nhân</span>
                                </div>
                                <button onclick="switchTab('tab-edit')" class="btn-card-edit" title="Chuyển sang tab cập nhật">
                                    <span>Chỉnh sửa</span>
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                </button>
                            </div>

                                <div class="card-body-grid" style="padding:0; display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:1.25rem;">
                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #dcfce7; box-shadow:0 4px 12px rgba(16, 185, 129, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;" onmouseover="this.style.transform='translateY(-2px)';" onmouseout="this.style.transform='translateY(0)';">
                                        <div style="width:48px; height:48px; border-radius:50%; background:#ecfdf5; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#059669;">
                                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                        </div>
                                        <div style="min-width:0; flex-grow:1;">
                                            <span style="font-size:0.75rem; font-weight:700; color:#059669; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Họ và tên hiển thị</span>
                                            <span style="font-size:1.15rem; font-weight:700; color:#0f172a; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><%= user != null ? user.getDisplayName() : "—" %></span>
                                            <span style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.1rem;">Thành viên hệ thống</span>
                                        </div>
                                </div>

                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #e0e7ff; box-shadow:0 4px 12px rgba(99, 102, 241, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;" onmouseover="this.style.transform='translateY(-2px)';" onmouseout="this.style.transform='translateY(0)';">
                                        <div style="width:48px; height:48px; border-radius:50%; background:#e0e7ff; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#4f46e5;">
                                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                        </div>
                                        <div style="min-width:0; flex-grow:1;">
                                            <span style="font-size:0.75rem; font-weight:700; color:#4f46e5; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Ngày tham gia</span>
                                            <span style="font-size:1.15rem; font-weight:700; color:#0f172a; display:block;"><%= joinDate %></span>
                                            <span style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.1rem;">Thời gian kích hoạt</span>
                                        </div>
                                </div>

                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #fef3c7; box-shadow:0 4px 12px rgba(245, 158, 11, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;" onmouseover="this.style.transform='translateY(-2px)';" onmouseout="this.style.transform='translateY(0)';">
                                        <div style="width:48px; height:48px; border-radius:50%; background:#fffbeb; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#d97706;">
                                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                        </div>
                                        <div style="min-width:0; flex-grow:1;">
                                            <span style="font-size:0.75rem; font-weight:700; color:#d97706; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Địa chỉ Email</span>
                                            <span style="font-size:1.05rem; font-weight:700; color:#0f172a; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;" title="<%= user != null ? user.getEmail() : "" %>"><%= user != null ? user.getEmail() : "—" %></span>
                                            <span style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.1rem;">Tài khoản liên kết</span>
                                        </div>
                                </div>

                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #fee2e2; box-shadow:0 4px 12px rgba(239, 68, 68, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;" onmouseover="this.style.transform='translateY(-2px)';" onmouseout="this.style.transform='translateY(0)';">
                                        <div style="width:48px; height:48px; border-radius:50%; background:#fef2f2; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#ef4444;">
                                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                        </div>
                                        <div style="min-width:0; flex-grow:1;">
                                            <span style="font-size:0.75rem; font-weight:700; color:#ef4444; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Trạng thái tài khoản</span>
                                        <% String status = (user != null) ? user.getAccountStatus() : "active"; %>
                                            <span class="acc-status-tag <%= status %>" style="display:inline-block; font-size:0.8rem; padding:0.25rem 0.75rem; margin-top:0.1rem;">
                                            <%= "active".equals(status) ? "Đang hoạt động" : "suspended".equals(status) ? "Tạm khóa" : "Vô hiệu hóa" %>
                                        </span>
                                            <span style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.2rem;">Bảo mật hệ thống</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 2: CHỈNH SỬA HỒ SƠ                     -->
            <!-- ========================================== -->
            <section id="tab-edit" class="tab-pane <%= "tab-edit".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Cập nhật thông tin</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                    <span>Cập nhật thông tin học viên</span>
                                </div>
                                <button onclick="switchTab('tab-profile')" class="btn-card-edit-light">
                                    <span>Quay lại</span>
                                </button>
                            </div>

                            <form action="${pageContext.request.contextPath}/profile" method="POST" class="form-edit-layout" style="padding:1.5rem 0 0 0;">
                                <input type="hidden" name="action" value="updateName">
                                <div class="form-group-edit">
                                    <label>Họ và tên hiển thị</label>
                                    <input type="text" name="displayName" required value="<%= user != null ? user.getDisplayName() : "" %>" placeholder="Nhập họ và tên của bạn...">
                                </div>

                                <div class="form-actions-row">
                                    <button type="button" class="btn btn-ghost" onclick="switchTab('tab-profile')">Hủy bỏ</button>
                                    <button type="submit" class="btn btn-primary" style="border-radius:0.75rem;">Lưu thay đổi</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 3: BẢO MẬT VÀ MẬT KHẨU                 -->
            <!-- ========================================== -->
            <section id="tab-security" class="tab-pane <%= "tab-security".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Bảo mật tài khoản</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <!-- KHUNG CHÍNH TOP: MẬT KHẨU ĐĂNG NHẬP -->
                        <div style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 8px 24px rgba(0, 0, 0, 0.02); overflow:hidden;">
                            <div style="padding:1.75rem; display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:1.25rem;">
                                <div>
                                    <span style="font-weight:800; font-size:1.15rem; color:#b45309; letter-spacing:0.5px; text-transform:uppercase; display:block;">Mật khẩu đăng nhập</span>
                                    <p style="font-size:0.85rem; color:var(--text-muted); margin:0.35rem 0 0 0;">Cập nhật mật khẩu định kỳ để bảo mật tốt hơn.</p>
                                </div>
                                <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='flex';" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease;" onmouseover="this.style.background='#047857'; this.style.transform='translateY(-1px)';" onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
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

                        <!-- LƯỚI HAI KHUNG CON BÊN DƯỚI -->
                        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(280px, 1fr)); gap:1.5rem;">
                            
                            <!-- KHUNG TRÁI: BẢO MẬT 2 LỚP (OTP) -->
                            <div style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 8px 24px rgba(0, 0, 0, 0.02); padding:1.5rem; display:flex; flex-direction:column; justify-content:space-between; gap:1.5rem;">
                                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                    <span style="font-weight:800; font-size:0.9rem; color:var(--text-main); text-transform:uppercase; letter-spacing:0.5px;">Bảo mật 2 lớp (OTP)</span>
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                </div>
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <span style="font-weight:700; font-size:0.95rem; color:var(--text-main);">Mã OTP qua Email</span>
                                    
                                    <!-- Form ngầm xử lý toggle 2FA -->
                                    <form id="toggle2faForm" action="${pageContext.request.contextPath}/profile" method="POST" style="display:none;">
                                        <input type="hidden" name="action" value="toggle2FA">
                                    </form>

                                    <!-- NÚT TOGGLE SWITCH THỰC TẾ -->
                                    <% boolean is2fa = (user != null && user.isTwoFactorEnabled()); %>
                                    <div id="otp-toggle-btn" onclick="document.getElementById('toggle2faForm').submit();" style="width:44px; height:24px; background:<%= is2fa ? "#10b981" : "#cbd5e1" %>; border-radius:12px; padding:2px; cursor:pointer; transition:background 0.3s ease; display:flex; align-items:center;">
                                        <div class="toggle-circle" style="width:20px; height:20px; background:#ffffff; border-radius:50%; box-shadow:0 1px 3px rgba(0,0,0,0.2); transition:transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform:translateX(<%= is2fa ? "20px" : "0" %>);"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- KHUNG PHẢI: THIẾT BỊ HIỆN TẠI -->
                            <div style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 8px 24px rgba(0, 0, 0, 0.02); padding:1.5rem; display:flex; flex-direction:column; justify-content:space-between; gap:1.5rem;">
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
            </section>

            <!-- ========================================== -->
            <!-- TAB 4: ĐĂNG TẢI TÀI LIỆU                   -->
            <!-- ========================================== -->
            <section id="tab-upload-material" class="tab-pane <%= "tab-upload-material".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Đăng tải tài liệu</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                    <span>Đóng góp tài liệu vào kho học tập HIPZI</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/material-repository" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease; text-decoration:none;">
                                    <span>Đến kho tài liệu</span>
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
                                </a>
                            </div>

                            <div class="upload-material-info-grid">
                                <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:1rem; padding:1.5rem; display:flex; flex-direction:column; gap:1rem;">
                                    <div style="width:52px; height:52px; border-radius:1rem; background:#ecfdf5; color:#059669; display:flex; align-items:center; justify-content:center;">
                                        <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                    </div>
                                    <div>
                                        <h3 style="margin:0 0 0.5rem 0; color:#0f172a; font-size:1.25rem;">Tài liệu của bạn sẽ xuất hiện trong kho tài liệu</h3>
                                        <p style="margin:0; color:#64748b; line-height:1.7; font-size:0.95rem;">Khi giảng viên đăng tải bài giảng, đề luyện tập, giáo án hoặc bộ tài nguyên học tập chất lượng, tài liệu sẽ được đưa vào kho tài liệu để học viên dễ tìm kiếm, xem và đánh giá.</p>
                                    </div>
                                    <div class="upload-material-steps">
                                        <div style="background:#ffffff; border:1px solid #e2e8f0; border-radius:0.85rem; padding:1rem;">
                                            <strong style="display:block; color:#059669; font-size:1.35rem;">01</strong>
                                            <span style="display:block; color:#475569; font-weight:700; font-size:0.82rem; margin-top:0.25rem;">Đăng tài liệu hữu ích</span>
                                        </div>
                                        <div style="background:#ffffff; border:1px solid #e2e8f0; border-radius:0.85rem; padding:1rem;">
                                            <strong style="display:block; color:#059669; font-size:1.35rem;">02</strong>
                                            <span style="display:block; color:#475569; font-weight:700; font-size:0.82rem; margin-top:0.25rem;">Nhận lượt xem và đánh giá</span>
                                        </div>
                                        <div style="background:#ffffff; border:1px solid #e2e8f0; border-radius:0.85rem; padding:1rem;">
                                            <strong style="display:block; color:#059669; font-size:1.35rem;">03</strong>
                                            <span style="display:block; color:#475569; font-weight:700; font-size:0.82rem; margin-top:0.25rem;">Tăng uy tín giảng dạy</span>
                                        </div>
                                    </div>
                                </div>

                                <div style="background:linear-gradient(135deg, #064e3b 0%, #047857 100%); color:#ffffff; border-radius:1rem; padding:1.5rem; display:flex; flex-direction:column; justify-content:space-between; gap:1.25rem; box-shadow:0 14px 28px rgba(4, 120, 87, 0.18);">
                                    <div>
                                        <div style="display:inline-flex; align-items:center; gap:0.45rem; background:rgba(255,255,255,0.14); border:1px solid rgba(255,255,255,0.18); border-radius:999px; padding:0.35rem 0.75rem; font-size:0.78rem; font-weight:800;">Ưu tiên gợi ý</div>
                                        <h3 style="margin:1rem 0 0.65rem 0; font-size:1.35rem; line-height:1.25;">Giảng viên tích cực sẽ có lợi thế hiển thị</h3>
                                        <p style="margin:0; color:#d1fae5; line-height:1.7; font-size:0.92rem;">Những giảng viên thường xuyên chia sẻ tài liệu chất lượng, có nhiều lượt xem và nhận đánh giá tốt sẽ được hệ thống xem là tín hiệu uy tín để ưu tiên gợi ý trong các luồng tìm kiếm và đăng ký giảng dạy.</p>
                                    </div>
                                    <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='block'; document.getElementById('repository-upload-form-panel').scrollIntoView({ behavior: 'smooth', block: 'start' });" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; width:100%; background:#ffffff; color:#047857; font-weight:900; font-size:0.9rem; padding:0.8rem 1rem; border-radius:0.85rem; text-decoration:none; border:none; cursor:pointer;">
                                        <span>Bắt đầu đăng tải</span>
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
                                    </button>
                                </div>
                            </div>

                            <div id="repository-upload-form-panel" style="display:none; margin-top:1.5rem; background:#ffffff; border:1px solid #dbeafe; border-radius:1rem; padding:1.5rem; box-shadow:0 12px 30px rgba(15, 23, 42, 0.06);">
                                <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:1rem; margin-bottom:1.25rem;">
                                    <div>
                                        <h3 style="margin:0; color:#0f172a; font-size:1.2rem;">Thông tin tài liệu đăng tải</h3>
                                        <p style="margin:0.35rem 0 0 0; color:#64748b; line-height:1.6; font-size:0.9rem;">File sẽ được lưu trên Supabase Storage và hiển thị công khai trong kho tài liệu sau khi đăng.</p>
                                    </div>
                                    <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='none';" style="width:36px; height:36px; border-radius:50%; border:none; background:#f1f5f9; color:#64748b; font-size:1.1rem; cursor:pointer;">&times;</button>
                                </div>

                                <form class="repository-upload-form" action="${pageContext.request.contextPath}/material-repository" method="POST" enctype="multipart/form-data" style="display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:1rem;">
                                    <input type="hidden" name="action" value="uploadRepositoryMaterial">

                                    <div style="grid-column:1 / -1; display:flex; flex-direction:column; gap:0.4rem;">
                                        <label style="font-size:0.85rem; font-weight:800; color:#0f172a;">Tiêu đề tài liệu <span style="color:#ef4444;">*</span></label>
                                        <input type="text" name="materialTitle" required maxlength="180" placeholder="Ví dụ: Chuyên đề hàm số lớp 12" style="padding:0.8rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.95rem; outline:none;">
                                    </div>

                                    <div style="display:flex; flex-direction:column; gap:0.4rem;">
                                        <label style="font-size:0.85rem; font-weight:800; color:#0f172a;">Môn học <span style="color:#ef4444;">*</span></label>
                                        <select name="materialSubject" required style="padding:0.8rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.95rem; background:#ffffff;">
                                            <option value="">Chọn môn học</option>
                                            <option value="Toán">Toán học</option>
                                            <option value="Văn">Ngữ Văn</option>
                                            <option value="Anh">Tiếng Anh</option>
                                            <option value="Lý">Vật Lý</option>
                                            <option value="Hóa">Hóa Học</option>
                                            <option value="Sinh Học">Sinh Học</option>
                                            <option value="Lịch Sử">Lịch Sử</option>
                                            <option value="Địa Lý">Địa Lý</option>
                                            <option value="Công Nghệ">Công Nghệ</option>
                                            <option value="Tin Học">Tin Học</option>
                                        </select>
                                    </div>

                                    <div style="display:flex; flex-direction:column; gap:0.4rem;">
                                        <label style="font-size:0.85rem; font-weight:800; color:#0f172a;">Khối lớp <span style="color:#ef4444;">*</span></label>
                                        <select name="materialGrade" required style="padding:0.8rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.95rem; background:#ffffff;">
                                            <option value="">Chọn khối lớp</option>
                                            <option value="Lớp 10">Lớp 10</option>
                                            <option value="Lớp 11">Lớp 11</option>
                                            <option value="Lớp 12">Lớp 12</option>
                                        </select>
                                    </div>

                                    <div style="display:flex; flex-direction:column; gap:0.4rem;">
                                        <label style="font-size:0.85rem; font-weight:800; color:#0f172a;">Loại tài liệu <span style="color:#ef4444;">*</span></label>
                                        <select name="materialType" required style="padding:0.8rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.95rem; background:#ffffff;">
                                            <option value="Lý thuyết">Lý thuyết</option>
                                            <option value="Đề ôn tập">Đề ôn tập</option>
                                        </select>
                                    </div>

                                    <div style="display:flex; flex-direction:column; gap:0.4rem;">
                                        <label style="font-size:0.85rem; font-weight:800; color:#0f172a;">File tài liệu <span style="color:#ef4444;">*</span></label>
                                        <input type="file" name="materialFile" required accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp" style="padding:0.7rem; border-radius:0.75rem; border:1px dashed #94a3b8; background:#f8fafc; font-size:0.9rem;">
                                        <span style="font-size:0.75rem; color:#64748b;">Hỗ trợ PDF, Word, PowerPoint, Excel và ảnh. Tối đa 50MB.</span>
                                    </div>

                                    <div style="grid-column:1 / -1; display:flex; flex-direction:column; gap:0.4rem;">
                                        <label style="font-size:0.85rem; font-weight:800; color:#0f172a;">Mô tả ngắn</label>
                                        <textarea name="materialDescription" rows="4" maxlength="800" placeholder="Tóm tắt nội dung, mục tiêu học tập hoặc cách sử dụng tài liệu..." style="padding:0.8rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.95rem; resize:vertical; outline:none;"></textarea>
                                    </div>

                                    <div style="grid-column:1 / -1; display:flex; justify-content:flex-end; gap:0.75rem; flex-wrap:wrap;">
                                        <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='none';" style="padding:0.75rem 1.2rem; border-radius:0.75rem; border:none; background:#f1f5f9; color:#475569; font-weight:800; cursor:pointer;">Hủy</button>
                                        <button type="submit" style="padding:0.75rem 1.35rem; border-radius:0.75rem; border:none; background:#059669; color:#ffffff; font-weight:900; cursor:pointer; box-shadow:0 8px 18px rgba(5, 150, 105, 0.22);">Đăng tải lên kho</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 6: THÔNG BÁO HỆ THỐNG                  -->
            <!-- ========================================== -->
            <section id="tab-notifications-static" style="display:none;">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Thông báo hệ thống</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                    <span>Thông báo kiểm duyệt & hệ thống</span>
                                </div>
                                <span style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">Mới nhất</span>
                            </div>

                            <div style="padding-top:1.5rem; display:flex; flex-direction:column; gap:1rem;">
                                <div style="padding:1rem 1.25rem; border-radius:0.75rem; background:#f0fdf4; border-left:4px solid var(--primary); display:flex; gap:1rem; align-items:flex-start; box-shadow:0 4px 12px rgba(0,0,0,0.02);">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2.5" style="flex-shrink:0; margin-top:0.15rem;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                    <div>
                                        <span style="font-weight:700; font-size:0.95rem; color:var(--text-main); display:block;">Xác thực tài khoản Giảng viên / Chuyên gia thành công!</span>
                                        <p style="font-size:0.85rem; color:var(--text-muted); margin:0.25rem 0 0 0;">Bạn đã được cấp quyền tải lên học liệu và sử dụng toàn bộ bộ công cụ Trí tuệ nhân tạo hỗ trợ giảng dạy của HIPZI.</p>
                                        <span style="font-size:0.75rem; color:#94a3b8; display:block; margin-top:0.35rem;"><%= currentDateDisplay %></span>
                                    </div>
                                </div>

                                <div style="padding:1rem 1.25rem; border-radius:0.75rem; background:#f8fafc; border:1px solid var(--border-dark); display:flex; gap:1rem; align-items:flex-start; box-shadow:0 4px 12px rgba(0,0,0,0.02);">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" style="flex-shrink:0; margin-top:0.15rem;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                    <div>
                                        <span style="font-weight:600; font-size:0.95rem; color:var(--text-main); display:block;">Cập nhật kho học liệu Trí tuệ nhân tạo</span>
                                        <p style="font-size:0.85rem; color:var(--text-muted); margin:0.25rem 0 0 0;">Hàng trăm bộ Flashcard và câu hỏi luyện tập tự động đã được đội ngũ Giảng viên phê duyệt sẵn sàng trên thư viện chung.</p>
                                        <span style="font-size:0.75rem; color:#94a3b8; display:block; margin-top:0.35rem;">Hôm qua</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 7: HỐ TRỢ HỌC TẬP                      -->
            <!-- ========================================== -->
            <section id="tab-support" class="tab-pane <%= "tab-support".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Hỗ trợ giảng dạy</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                    <span>Trung tâm Hỗ trợ & Giải đáp thắc mắc</span>
                                </div>
                            </div>

                            <div style="padding-top:1.75rem; display:grid; grid-template-columns:1.2fr 1fr; gap:2rem; align-items: start;">
                                <div>
                                    <span style="font-weight:800; font-size:1.15rem; color:var(--text-main); display:block; margin-bottom:1.25rem; letter-spacing: -0.2px;">Câu hỏi thường gặp (FAQ)</span>
                                    <div style="display:flex; flex-direction:column; gap:1rem;">
                                        <details style="background:#ffffff; padding:1.25rem; border-radius:1rem; border: 1px solid #e2e8f0; cursor:pointer; transition: all 0.2s ease; box-shadow: 0 4px 12px rgba(0,0,0,0.02);">
                                            <summary style="font-weight:700; font-size:0.95rem; color:var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                                <span>Làm thế nào để tải xuống bài giảng?</span>
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                            </summary>
                                            <p style="font-size:0.9rem; color:var(--text-muted); margin:1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                                Học viên có thể tải xuống các file đính kèm miễn phí khi tài liệu đã được duyệt và chuyển sang chế độ hiển thị công khai.
                                            </p>
                                        </details>

                                        <details style="background:#ffffff; padding:1.25rem; border-radius:1rem; border: 1px solid #e2e8f0; cursor:pointer; transition: all 0.2s ease; box-shadow: 0 4px 12px rgba(0,0,0,0.02);">
                                            <summary style="font-weight:700; font-size:0.95rem; color:var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                                <span>AI tạo câu hỏi ôn tập hoạt động ra sao?</span>
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                            </summary>
                                            <p style="font-size:0.9rem; color:var(--text-muted); margin:1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                                Trợ lý AI phân tích văn bản từ tài liệu gốc do Giảng viên cung cấp để bóc tách thành các bộ Flashcard trực quan cho học viên luyện tập.
                                            </p>
                                        </details>
                                    </div>
                                </div>

                                <div style="padding:1.75rem; border-radius:1.5rem; border:1px solid #e2e8f0; background:linear-gradient(135deg, #ffffff 0%, #f1f5f9 100%); box-shadow: 0 10px 25px rgba(0,0,0,0.02);">
                                    <span style="font-weight:800; font-size:1.05rem; color:var(--text-main); display:block; margin-bottom:1rem; text-transform: uppercase; letter-spacing: 0.5px;">Yêu cầu hỗ trợ</span>
                                    <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.5rem;">Gửi yêu cầu trực tiếp đến đội ngũ kỹ thuật nếu bạn gặp sự cố nghiêm trọng.</p>
                                    <form id="supportForm" style="display:flex; flex-direction:column; gap:1.25rem;">
                                        <div class="form-group-edit">
                                            <label style="font-size: 0.8rem;">Tiêu đề cần hỗ trợ</label>
                                            <input type="text" name="title" required placeholder="Nhập tiêu đề vắn tắt..." style="background: white;">
                                        </div>
                                        <div class="form-group-edit">
                                            <label style="font-size: 0.8rem;">Mô tả chi tiết</label>
                                            <textarea name="content" rows="4" required placeholder="Mô tả khó khăn bạn đang gặp phải..." style="background: white;"></textarea>
                                        </div>
                                        <button type="submit" class="btn btn-primary" style="padding:0.75rem; border-radius:0.75rem; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; font-size: 0.85rem; margin-top: 0.5rem;">Gửi tin nhắn</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: THÔNG BÁO HỆ THỐNG                     -->
            <!-- ========================================== -->
            <section id="tab-notifications" class="tab-pane <%= "tab-notifications".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Thông báo hệ thống</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="card-main-premium">
                        <div style="padding:1.5rem; display:flex; flex-direction:column; gap:1rem;">
                            <% if (notifications != null && !notifications.isEmpty()) { 
                                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                for (Notification n : notifications) {
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
                                <div style="padding:1rem 1.25rem; border-radius:0.75rem; background:<%= bgColor %>; border-left:4px solid <%= typeColor %>; display:flex; gap:1rem; align-items:flex-start;">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="<%= typeColor %>" stroke-width="2.5" style="flex-shrink:0; margin-top:0.15rem;"><path d="<%= iconPath %>"/></svg>
                                    <div>
                                        <span style="font-weight:700; font-size:0.95rem; color:var(--text-main); display:block;"><%= n.getTitle() %></span>
                                        <p style="font-size:0.85rem; color:var(--text-muted); margin:0.25rem 0 0 0;"><%= n.getMessage() %></p>
                                        <span style="font-size:0.75rem; color:#94a3b8; display:block; margin-top:0.35rem;"><%= sdf.format(n.getCreatedAt()) %></span>
                                    </div>
                                </div>
                            <% } } else { %>
                                <div class="empty-status-panel">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                    <span style="font-weight:700; color:var(--text-main);">Không có thông báo nào</span>
                                    <p style="font-size:0.85rem; max-width:400px; margin:0;">Bạn sẽ nhận được thông báo về các cập nhật hệ thống, phê duyệt học liệu và tin nhắn quản trị tại đây.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>




            <!-- ========================================== -->
            <!-- MODAL OVERLAY: ĐỔI MẬT KHẨU HỆ THỐNG       -->
            <!-- ========================================== -->
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

    <!-- ========================================================== -->
    <!-- BANNER CỘNG ĐỒNG HIPZI (CHÍNH GIỮA FULL-WIDTH TOÀN TRANG)  -->
    <!-- ========================================================== -->
    <div style="max-width:1320px; width:100%; margin:2.5rem auto 5rem auto; padding:0 1.5rem;">
        <div class="community-engagement-banner" style="background:#ffffff; border-radius:1.5rem; border:1px solid #e2e8f0; box-shadow:0 10px 30px rgba(0, 0, 0, 0.03); padding:2.5rem; display:flex; flex-direction:column; gap:1.75rem; position:relative; overflow:hidden;">
            
            <!-- Dải lấp lánh trang trí góc phải -->
            <div style="position:absolute; top:0; right:0; width:350px; height:350px; background:radial-gradient(circle, rgba(5, 150, 105, 0.05) 0%, transparent 70%); pointer-events:none;"></div>

            <div style="display:flex; flex-direction:column; gap:1.25rem; z-index:1;">
                <!-- Badge Hỗ trợ / Cộng đồng -->
                <div>
                    <span style="display:inline-flex; align-items:center; gap:0.4rem; background:#ecfdf5; color:#059669; font-weight:800; font-size:0.75rem; padding:0.4rem 1rem; border-radius:2rem; letter-spacing:0.5px; text-transform:uppercase;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        Hỗ trợ học tập 24/7
                    </span>
                </div>

                <!-- Hàng Flex chính chia 2 cột -->
                <div style="display:flex; flex-direction:row; justify-content:space-between; align-items:center; gap:2.5rem; flex-wrap:wrap;">
                    
                    <!-- Cột Trái: Tiêu đề & Lời kêu gọi -->
                    <div style="flex:1; min-width:320px; display:flex; flex-direction:column; gap:1rem; text-align:left;">
                        <h3 style="font-weight:800; font-size:2.15rem; color:#0f172a; line-height:1.25; margin:0; letter-spacing:-0.5px;">
                            Tham Gia <span style="background:linear-gradient(135deg, rgb(4, 120, 87) 0%, rgb(16, 185, 129) 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; font-style:italic;">Cộng Đồng HIPZI?</span>
                        </h3>
                        <p style="font-size:0.95rem; color:#475569; line-height:1.55; margin:0; max-width:550px;">
                            Đừng ngần ngại kết nối với đội ngũ giảng viên và cộng đồng học viên để cùng trao đổi kiến thức, định hướng lộ trình học tập phù hợp và hiệu quả nhất với bản thân.
                        </p>
                        
                        <!-- Hàng Nút Hành động CTA -->
                        <div style="display:flex; align-items:center; gap:0.85rem; margin-top:0.5rem; flex-wrap:wrap;">
                            <a href="https://zalo.me/g/hipzi2024" target="_blank" style="background:#059669; color:#ffffff; font-weight:700; font-size:0.85rem; padding:0.85rem 1.75rem; border-radius:0.75rem; text-decoration:none; display:inline-flex; align-items:center; gap:0.5rem; box-shadow:0 4px 12px rgba(5, 150, 105, 0.25); transition:all 0.2s ease; letter-spacing:0.5px;" onmouseover="this.style.background='#047857'; this.style.transform='translateY(-2px)';" onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                                THAM GIA CỘNG ĐỒNG
                            </a>
                        </div>
                    </div>

                    <!-- Cột Phải: Khung Highlight Thông số bo tròn màu xám nhạt -->
                    <div style="background:#f8fafc; border-radius:1.25rem; padding:1.5rem; border:1px solid #f1f5f9; display:flex; flex-direction:column; gap:1.25rem; min-width:260px;">
                        
                        <!-- Thông số 1 -->
                        <div style="display:flex; align-items:center; gap:1rem;">
                            <div style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#2563eb; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                            <div style="display:flex; flex-direction:column; text-align:left;">
                                <span style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">GIẢNG VIÊN ONLINE</span>
                                <span style="font-size:1.05rem; font-weight:800; color:#0f172a;">Hơn 50+ Mentor</span>
                            </div>
                        </div>

                        <div style="height:1px; background:#f1f5f9;"></div>

                        <!-- Thông số 2 -->
                        <div style="display:flex; align-items:center; gap:1rem;">
                            <div style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#10b981; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                            </div>
                            <div style="display:flex; flex-direction:column; text-align:left;">
                                <span style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">CỘNG ĐỒNG HỌC VIÊN</span>
                                <span style="font-size:1.05rem; font-weight:800; color:#0f172a;">2000+ Thành viên</span>
                            </div>
                        </div>

                    </div>

                </div>
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

        let teacherTabSwitchTimer;

        function getTeacherTabSlug(tabId) {
            return tabId.replace(/^tab-/, '');
        }

        function normalizeTeacherTabId(tabValue) {
            if (!tabValue) {
                return '';
            }
            if (tabValue === 'materials' || tabValue === 'practice' || tabValue === 'tab-materials' || tabValue === 'tab-practice') {
                return 'tab-upload-material';
            }
            return tabValue.startsWith('tab-') ? tabValue : 'tab-' + tabValue;
        }

        function updateTeacherTabUrl(targetTabId, replace = false) {
            if (!window.history || !window.history.pushState) {
                return;
            }

            const url = new URL(window.location.href);
            url.searchParams.set('tab', getTeacherTabSlug(targetTabId));
            const state = { teacherTab: targetTabId };
            if (replace) {
                window.history.replaceState(state, '', url);
            } else {
                window.history.pushState(state, '', url);
            }
        }

        const TAB_TITLES = {
            'tab-teaching-registration': 'Đăng kí giảng dạy',
            'tab-class-registration': 'Đăng kí lớp học',
            'tab-profile': 'Hồ sơ cá nhân',
            'tab-edit': 'Cập nhật thông tin',
            'tab-security': 'Bảo mật và mật khẩu',
            'tab-upload-material': 'Đăng tải tài liệu',
            'tab-notifications': 'Thông báo hệ thống',
            'tab-support': 'Hỗ trợ giảng dạy',
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

        function steadyTeacherTabHeight(previousPane, targetPane) {
            const contentWrapper = document.querySelector('.dashboard-content-wrapper');
            if (!contentWrapper || !targetPane) {
                return;
            }

            clearTimeout(teacherTabSwitchTimer);
            const currentHeight = contentWrapper.offsetHeight;
            const previousHeight = previousPane ? previousPane.offsetHeight : 0;
            const nextHeight = targetPane.scrollHeight;
            contentWrapper.classList.add('is-switching-tab');
            contentWrapper.style.minHeight = Math.max(currentHeight, previousHeight, nextHeight) + 'px';

            teacherTabSwitchTimer = window.setTimeout(() => {
                contentWrapper.classList.remove('is-switching-tab');
                contentWrapper.style.minHeight = '';
            }, 320);
        }

        function settleTeacherTabScroll() {
            const dashboard = document.querySelector('.app-dashboard-container');
            if (!dashboard) {
                return;
            }

            const dashboardTop = dashboard.getBoundingClientRect().top + window.scrollY;
            const headerOffset = window.innerWidth < 1024 ? 72 : 96;
            const targetTop = Math.max(dashboardTop - headerOffset, 0);
            const viewportBottom = window.scrollY + window.innerHeight;
            const dashboardBottom = dashboardTop + dashboard.offsetHeight;
            const isDeepInsideOldTab = window.scrollY > targetTop + 120;
            const isBelowNewContent = viewportBottom > dashboardBottom + 80;

            if (isDeepInsideOldTab || isBelowNewContent) {
                const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
                window.scrollTo({
                    top: targetTop,
                    behavior: prefersReducedMotion ? 'auto' : 'smooth'
                });
            }
        }

        function switchTab(targetTabId, options = {}) {
            targetTabId = normalizeTeacherTabId(targetTabId);
            const panes = document.querySelectorAll('.tab-pane');
            const targetPane = document.getElementById(targetTabId);
            if (!targetPane || targetPane.classList.contains('active-pane')) {
                const navLinks = document.querySelectorAll('.sidebar-menu a');
                navLinks.forEach(link => {
                    link.classList.remove('active');
                });
                let activeNav = document.getElementById('nav-' + targetTabId);
                if (!activeNav && targetTabId === 'tab-edit') {
                    activeNav = document.getElementById('nav-tab-profile');
                }
                if (activeNav) {
                    activeNav.classList.add('active');
                }
                if (targetPane) {
                    updateUnifiedHeaderTitle(targetTabId);
                }
                if (options.updateUrl) {
                    updateTeacherTabUrl(targetTabId, options.replaceUrl);
                }
                return;
            }

            const previousPane = document.querySelector('.tab-pane.active-pane');
            steadyTeacherTabHeight(previousPane, targetPane);

            panes.forEach(pane => {
                pane.classList.remove('active-pane');
            });

            const navLinks = document.querySelectorAll('.sidebar-menu a');
            navLinks.forEach(link => {
                link.classList.remove('active');
            });

            targetPane.classList.add('active-pane');

            const activeNav = document.getElementById('nav-' + targetTabId);
            if (activeNav) {
                activeNav.classList.add('active');
            } else if (targetTabId === 'tab-edit') {
                const profileNav = document.getElementById('nav-tab-profile');
                if (profileNav) {
                    profileNav.classList.add('active');
                }
            }

            updateUnifiedHeaderTitle(targetTabId);

            if (options.updateUrl !== false) {
                updateTeacherTabUrl(targetTabId, options.replaceUrl);
            }

            requestAnimationFrame(settleTeacherTabScroll);
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
                switchTab(normalizeTeacherTabId(tabParam), { replaceUrl: true });
            } else {
                const activePane = document.querySelector('.tab-pane.active-pane');
                if (activePane) {
                    updateTeacherTabUrl(activePane.id, true);
                }
            }
        });

        window.addEventListener('popstate', (event) => {
            const stateTab = event.state && event.state.teacherTab;
            const urlTab = new URLSearchParams(window.location.search).get('tab');
            const targetTabId = stateTab || (urlTab ? normalizeTeacherTabId(urlTab) : 'tab-teaching-registration');
            switchTab(targetTabId, { updateUrl: false });
        });

        // Xử lý gửi form hỗ trợ qua Servlet
        function connectTeacherStatusSocket() {
            <% if (user != null && user.getId() != null) { %>
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + '${pageContext.request.contextPath}/status-ws';
            const statusWs = new WebSocket(wsUrl);
            statusWs.onopen = () => {
                statusWs.send(JSON.stringify({ type: 'auth', userId: '<%= user.getId() %>' }));
            };
            <% } %>
        }

        window.addEventListener('DOMContentLoaded', connectTeacherStatusSocket);

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

        function validateTeachingSubjects() {
            const checkboxes = document.querySelectorAll('input[name="teachingSubjects"]:checked');
            if (checkboxes.length === 0) {
                showToast('Vui lòng chọn ít nhất một môn có thể dạy.', 'error');
                return false;
            }
            return true;
        }

        function formatClassTimeValue(rawValue) {
            const digits = rawValue.replace(/\D/g, '').slice(0, 4);
            if (digits.length <= 2) {
                return digits;
            }
            var hour = digits.slice(0, 2);
            var minute = digits.slice(2);

            if (hour.length === 2 && Number(hour) > 24) {
                hour = '24';
            }
            if (minute.length === 2 && Number(minute) > 59) {
                minute = '59';
            }
            if (hour === '24' && minute.length > 0) {
                minute = minute.length === 1 ? '0' : '00';
            }

            return hour + ':' + minute;
        }

        document.querySelectorAll('.class-time-input').forEach(input => {
            input.addEventListener('input', () => {
                input.value = formatClassTimeValue(input.value);
            });

            input.addEventListener('blur', () => {
                if (input.value.length === 4 && input.value.indexOf(':') === -1) {
                    input.value = formatClassTimeValue(input.value);
                }
            });
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
