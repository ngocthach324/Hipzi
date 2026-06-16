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
        :root {
            --primary: #047857;
            --primary-hover: #065f46;
            --primary-light: #ecfdf5;
            --secondary: #10b981;
            --accent: #8b5cf6;
            --accent-light: #f5f3ff;
            --background: #f3f4f6;
            --surface: #ffffff;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --border-dark: #e2e8f0;
            --border-light: #f1f5f9;
            --shadow: 0 10px 30px rgba(0, 0, 0, 0.02);
            --shadow-lg: 0 20px 40px rgba(4, 120, 87, 0.04);
            --font-sans: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;
        }

        body {
            background-color: #e2e8f0;
            font-family: var(--font-sans);
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }

        .app-dashboard-container {
            max-width: 1600px;
            width: calc(100% - 1.5rem);
            min-height: calc(100vh - 1.5rem);
            margin: 0.75rem auto;
            background: transparent;
            display: flex;
            flex-direction: row;
            gap: 1rem;
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
        }

        .sidebar-brand-horizontal {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 27px;
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

        .sidebar-toggle-btn {
            background: #f8fafc;
            border: 1px solid var(--border-dark);
            border-radius: 10px;
            width: 34px;
            height: 34px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-muted);
            cursor: pointer;
            transition: all 0.2s ease;
            margin-left: auto;
            padding: 0;
        }

        .sidebar-toggle-btn:hover {
            color: var(--primary);
            background: var(--primary-light);
            border-color: rgba(4, 120, 87, 0.2);
            transform: scale(1.05);
        }

        .sidebar-section-label {
            font-size: 0.75rem;
            font-weight: 800;
            color: var(--text-muted);
            letter-spacing: 1px;
            text-transform: uppercase;
            margin: 1.05rem 0 0.3rem 0.35rem;
            white-space: nowrap;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 4.8px;
        }

        .sidebar-menu li a {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.8rem 0.85rem;
            border-radius: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 0.95rem;
            text-decoration: none;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            cursor: pointer;
            position: relative;
        }

        .sidebar-menu li a span {
            white-space: nowrap;
        }

        .sidebar-menu li a svg {
            width: 20px;
            height: 20px;
            stroke-width: 2.2;
            color: var(--text-muted);
            transition: all 0.2s ease;
        }

        .sidebar-menu li a:hover {
            color: var(--primary);
            background: var(--primary-light);
        }

        .sidebar-menu li a:hover svg {
            color: var(--primary);
        }

        .sidebar-menu li a.active {
            color: var(--primary);
            background: var(--primary-light);
            font-weight: 700;
        }

        .sidebar-menu li a.active svg {
            color: var(--primary);
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

        /* ===== CSS COLLAPSED SIDEBAR (THU GỌN THANH BÊN) ===== */
        .dashboard-sidebar {
            transition: width 0.3s cubic-bezier(0.16, 1, 0.3, 1), padding 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .brand-text-col,
        .sidebar-section-label,
        .sidebar-menu li a span {
            transition: opacity 0.2s ease, visibility 0.2s ease;
        }

        .app-dashboard-container.collapsed .dashboard-sidebar {
            width: 80px;
            padding: 1.5rem 0.5rem;
            align-items: center;
        }

        .app-dashboard-container.collapsed .sidebar-brand-horizontal {
            flex-direction: column;
            gap: 1rem;
            align-items: center;
        }

        .app-dashboard-container.collapsed .brand-text-col {
            display: none !important;
            opacity: 0;
            visibility: hidden;
        }

        .app-dashboard-container.collapsed .sidebar-toggle-btn {
            margin-left: 0;
            margin-right: 0;
        }

        .app-dashboard-container.collapsed .sidebar-toggle-btn .icon-collapse {
            display: none !important;
        }

        .app-dashboard-container.collapsed .sidebar-toggle-btn .icon-expand {
            display: block !important;
        }

        .app-dashboard-container.collapsed .sidebar-section-label {
            display: none !important;
            opacity: 0;
            visibility: hidden;
        }

        .app-dashboard-container.collapsed .sidebar-menu {
            width: 100%;
            align-items: center;
            margin-bottom: 1.25rem;
        }

        .app-dashboard-container.collapsed .sidebar-menu li {
            width: 100%;
            display: flex;
            justify-content: center;
        }

        .app-dashboard-container.collapsed .sidebar-menu li a {
            width: 44px;
            height: 44px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            margin: 0 auto;
        }

        .app-dashboard-container.collapsed .sidebar-menu li a span {
            display: none !important;
            opacity: 0;
            visibility: hidden;
        }

        .app-dashboard-container.collapsed .sidebar-menu li a.active::before {
            display: none !important;
        }

        .dashboard-main-section {
            display: flex;
            flex-direction: column;
            flex: 1;
            min-width: 0;
            background: transparent;
            gap: 1rem;
        }

        /* ===== TOP BAR ===== */
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
            gap: 1.25rem;
        }

        .top-bar-user-card {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding-left: 0.75rem;
            border-left: 1px solid var(--border-dark);
            cursor: pointer;
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
        }

        .top-bar-user-name {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--text-main);
            line-height: 1.2;
        }

        .top-bar-user-email {
            font-size: 0.7rem;
            color: var(--text-muted);
            line-height: 1.2;
        }

        .dashboard-content-wrapper {
            flex: 1;
            padding: 2rem;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            gap: 2rem;
            background: #f8fafc;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            box-shadow: var(--shadow);
        }

        /* Scrollbar custom */
        html::-webkit-scrollbar,
        .dashboard-sidebar::-webkit-scrollbar {
            width: 8px;
        }
        html::-webkit-scrollbar-thumb,
        .dashboard-sidebar::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }
        html::-webkit-scrollbar-track {
            background: #f1f5f9;
        }

        /* ===== TAB VIEW PANE ===== */
        .tab-pane {
            display: none;
            flex-direction: column;
            gap: 2rem;
            animation: fadeInTab 0.3s ease-out;
        }

        .tab-pane.active-pane {
            display: flex;
        }

        @keyframes fadeInTab {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ===== HEADER CỦA TAB ===== */
        .tab-pane-header {
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
            letter-spacing: -0.5px;
        }

        .tab-pane-header-left p {
            font-size: 0.95rem;
            color: var(--text-muted);
            margin: 0;
            font-weight: 500;
        }

        .tab-pane-header-right {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        /* Date badge */
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

        /* ===== THỀ METRICS (DONEZO STYLE) ===== */
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
        }

        .metric-card.primary {
            background: linear-gradient(135deg, #064e3b 0%, #047857 100%);
            color: #ffffff;
            box-shadow: 0 10px 25px rgba(4, 120, 87, 0.15);
        }

        .metric-card.secondary {
            background: #ffffff;
            border: 1px solid var(--border-dark);
            color: var(--text-main);
            box-shadow: var(--shadow);
        }

        .metric-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.06);
        }

        .metric-card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .metric-card-title {
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            opacity: 0.9;
        }

        .metric-card.secondary .metric-card-title {
            color: var(--text-muted);
        }

        .metric-arrow-btn {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid rgba(255,255,255,0.2);
            background: rgba(255,255,255,0.1);
            color: #ffffff;
            transition: all 0.2s ease;
        }

        .metric-card.secondary .metric-arrow-btn {
            border-color: var(--border-dark);
            background: var(--border-light);
            color: var(--text-main);
        }

        .metric-card-value {
            font-size: 2.2rem;
            font-weight: 800;
            margin: 0.75rem 0 0.35rem 0;
            line-height: 1;
        }

        .metric-card-sub {
            font-size: 0.72rem;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            padding: 0.2rem 0.5rem;
            border-radius: 0.5rem;
            width: fit-content;
        }

        .metric-card.primary .metric-card-sub {
            background: rgba(255, 255, 255, 0.15);
            color: #ecfdf5;
        }

        .metric-card.secondary .metric-card-sub {
            background: var(--primary-light);
            color: var(--primary);
        }

        /* ===== LAYOUT BÀN CỜ ĐA CỘT ===== */
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
            background: #ffffff;
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

        /* LƯỚI THÔNG TIN PROFILE */
        .profile-info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.25rem;
        }

        @media (max-width: 640px) {
            .profile-info-grid {
                grid-template-columns: 1fr;
            }
        }

        .profile-info-item {
            background: #ffffff;
            border-radius: 1.25rem;
            padding: 1.25rem;
            border: 1px solid var(--border-light);
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.2s ease;
        }

        .profile-info-item:hover {
            transform: translateY(-2px);
            border-color: var(--primary);
            box-shadow: 0 4px 12px rgba(4, 120, 87, 0.04);
        }

        .info-icon-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-shrink: 0;
        }

        .info-icon-circle.primary { background: var(--primary-light); color: var(--primary); }
        .info-icon-circle.accent { background: var(--accent-light); color: var(--accent); }
        .info-icon-circle.warning { background: #fff9db; color: #f59e0b; }
        .info-icon-circle.danger { background: #ffe3e3; color: #ef4444; }

        .info-content {
            display: flex;
            flex-direction: column;
            min-width: 0;
            flex-grow: 1;
        }

        .info-label {
            font-size: 0.72rem;
            font-weight: 800;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.15rem;
        }

        .info-value {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text-main);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* List Items */
        .dashboard-list {
            display: flex;
            flex-direction: column;
            gap: 0.85rem;
        }

        .dashboard-list-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.75rem 1rem;
            border-radius: 1rem;
            border: 1px solid var(--border-light);
            transition: all 0.2s ease;
            background: #ffffff;
            box-sizing: border-box;
        }

        .dashboard-list-item:hover {
            transform: translateY(-2px);
            border-color: var(--primary);
            box-shadow: 0 4px 12px rgba(4, 120, 87, 0.05);
        }

        .item-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-width: 0;
        }

        .item-icon-round {
            width: 36px;
            height: 36px;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .item-icon-round.primary {
            background: var(--primary-light);
            color: var(--primary);
        }

        .item-icon-round.accent {
            background: var(--accent-light);
            color: var(--accent);
        }

        .item-meta {
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .item-title {
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--text-main);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .item-subtitle {
            font-size: 0.75rem;
            color: var(--text-muted);
        }

        .status-badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.2rem 0.6rem;
            border-radius: 0.5rem;
        }

        .status-badge.open { background: #dcfce7; color: #15803d; }
        .status-badge.upcoming { background: #fef9c3; color: #a16207; }
        .status-badge.closed { background: #fee2e2; color: #b91c1c; }

        /* Buttons & Forms */
        .btn-premium {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            padding: 0.65rem 1.25rem;
            font-weight: 700;
            font-size: 0.85rem;
            border-radius: 0.85rem;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            font-family: inherit;
        }

        .btn-premium.primary {
            background: var(--primary);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(4, 120, 87, 0.2);
        }

        .btn-premium.primary:hover {
            background: var(--primary-hover);
            transform: translateY(-1px);
        }

        .btn-premium.secondary {
            background: #ffffff;
            color: var(--text-main);
            border: 1px solid var(--border-dark);
            box-shadow: var(--shadow);
        }

        .btn-premium.secondary:hover {
            background: var(--border-light);
        }

        .btn-premium.danger {
            background: #ef4444;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
        }

        .btn-premium.danger:hover {
            background: #dc2626;
            transform: translateY(-1px);
        }

        /* Form Controls */
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
            background: #ffffff;
        }

        .form-actions-row-premium {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        /* ===== THẺ PHÂN LOẠI GIẢNG VIÊN (PREMIUM SELECTION) ===== */
        .teacher-type-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
        }

        @media (max-width: 900px) {
            .teacher-type-grid {
                grid-template-columns: 1fr;
            }
        }

        .teacher-type-card {
            cursor: pointer;
            position: relative;
            display: block;
        }

        .teacher-type-card input {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .teacher-type-card-inner {
            border: 1px solid var(--border-dark);
            border-radius: 1.25rem;
            padding: 1.5rem;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            overflow: hidden;
            height: 100%;
            box-sizing: border-box;
        }

        .teacher-type-card-inner::after {
            content: '¹3';
            position: absolute;
            top: 1rem;
            right: 1rem;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: var(--primary);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 0.8rem;
            opacity: 0;
            transform: scale(0.7);
            transition: all 0.2s ease;
        }

        .teacher-type-card:hover .teacher-type-card-inner {
            border-color: var(--primary);
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(4, 120, 87, 0.05);
        }

        .teacher-type-card input:checked + .teacher-type-card-inner {
            border-color: var(--primary);
            background: linear-gradient(180deg, var(--primary-light) 0%, #ffffff 60%);
            box-shadow: 0 12px 24px rgba(4, 120, 87, 0.12);
            transform: translateY(-3px);
        }

        .teacher-type-card input:checked + .teacher-type-card-inner::after {
            opacity: 1;
            transform: scale(1);
        }

        .teacher-type-kicker {
            display: inline-flex;
            padding: 0.2rem 0.6rem;
            border-radius: 99px;
            background: var(--primary-light);
            color: var(--primary);
            font-size: 0.7rem;
            font-weight: 800;
            text-transform: uppercase;
            width: fit-content;
        }

        .teacher-type-title {
            margin: 0;
            color: var(--text-main);
            font-size: 1.1rem;
            font-weight: 800;
        }

        .teacher-type-description {
            margin: 0;
            color: var(--text-muted);
            font-size: 0.85rem;
            line-height: 1.5;
        }

        /* ===== TOAST NOTIFICATIONS ===== */
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
            background: #047857;
            color: #ffffff;
            padding: 0.85rem 1.25rem;
            border-radius: 0.75rem;
            font-weight: 700;
            font-size: 0.85rem;
            box-shadow: 0 10px 25px rgba(4, 120, 87, 0.3);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            pointer-events: auto;
            animation: slideInToast 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .custom-toast-msg.info {
            background: #0ea5e9;
            box-shadow: 0 10px 25px rgba(14, 165, 233, 0.3);
        }

        .custom-toast-msg.error {
            background: #ef4444;
            box-shadow: 0 10px 25px rgba(239, 68, 68, 0.3);
        }

        @keyframes slideInToast {
            from { transform: translateX(120%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        /* Account Status tags */
        .acc-status-tag {
            display: inline-flex;
            align-items: center;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.2rem 0.6rem;
            border-radius: 0.5rem;
        }
        .acc-status-tag.active { background: #dcfce7; color: #15803d; }
        .acc-status-tag.suspended { background: #fef9c3; color: #a16207; }

        /* General role-tag */
        .role-tag {
            font-size: 0.75rem;
            font-weight: 800;
            padding: 0.25rem 0.75rem;
            border-radius: 2rem;
            text-transform: uppercase;
        }
        .role-tag.teacher { background: #f3e8ff; color: #7c3aed; }
        .role-tag.student { background: #e0f2fe; color: #0284c7; }
        .role-tag.staff { background: #dbeafe; color: #2563eb; }
        .role-tag.admin { background: #fee2e2; color: #dc2626; }
        
        @keyframes modalScaleUp {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
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
                !initialTeacherTab.equals("tab-support") &&
                !initialTeacherTab.equals("tab-balance-stats") &&
                !initialTeacherTab.equals("tab-transaction-history")) {
                initialTeacherTab = "tab-teaching-registration";
            }
        }
    %>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>



    <!-- ===== DÀN TRANG CHÍNH THEO BỐ CỤC PREMIUM ĐỒNG BỘ DONEZO ===== -->
    <div class="app-dashboard-container">
        
        <!-- KÊNH SIDEBAR TRÁI (LEFT PANE) -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand-horizontal">
                <a href="${pageContext.request.contextPath}/index" class="brand-avatar-box" title="Trang chủ">
                    <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="Hipzi Logo">
                </a>
                <div class="brand-text-col">
                    <span class="brand-title">Hipzi</span>
                    <span class="brand-subtitle">Platform</span>
                </div>
                <button type="button" class="sidebar-toggle-btn" title="Thu gọn / Mở rộng" onclick="toggleSidebar()">
                    <svg class="icon-collapse" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M16 15l-3-3 3-3"/></svg>
                    <svg class="icon-expand" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="display: none;"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M13 9l3 3-3 3"/></svg>
                </button>
            </div>
            
            <div class="sidebar-section-label">Tổng quan</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-profile" class="<%= ("tab-profile".equals(initialTeacherTab) || "tab-edit".equals(initialTeacherTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')" title="Hồ sơ cá nhân">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/></svg>
                        <span>Hồ sơ cá nhân</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-security" class="<%= "tab-security".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-security')" title="Bảo mật">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <span>Bảo mật</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-support" class="<%= "tab-support".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-support')" title="Hỗ trợ giảng dạy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <span>Hỗ trợ giảng dạy</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">Quản lý giảng dạy</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-teaching-registration" class="<%= "tab-teaching-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-teaching-registration')" title="Đăng kí giảng dạy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                        <span>Đăng kí giảng dạy</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-class-registration" class="<%= "tab-class-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-class-registration')" title="Đăng kí lớp học">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                        <span>Đăng kí lớp học</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-course-registration" class="<%= "tab-course-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-course-registration')" title="Đăng khóa học">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                        <span>Đăng khóa học</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-upload-material" class="<%= "tab-upload-material".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-upload-material')" title="Đăng tải tài liệu">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        <span>Đăng tải tài liệu</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">Ví tiền</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-balance-stats" class="<%= "tab-balance-stats".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-balance-stats')" title="Thống kê số dư">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3a2 2 0 0 0 0-4z"/><circle cx="18" cy="12" r="1"/></svg>
                        <span>Thống kê số dư</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-transaction-history" class="<%= "tab-transaction-history".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-transaction-history')" title="Lịch sử giao dịch">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                        <span>Lịch sử giao dịch</span>
                    </a>
                </li>
            </ul>

        </aside>

        <!-- KÊNH PHẢI CHÍNH -->
        <div class="dashboard-main-section">
            
            <!-- TOP BAR ĐỒNG BỘ DONEZO -->
            <div class="dashboard-top-bar">
                <div class="top-bar-search-wrapper">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" placeholder="Tìm kiếm tác vụ...">

                </div>

                <div class="top-bar-right">
                    <!-- Toggle giao diện Sáng / Tối -->
                    <div class="nav-bell-trigger" title="Chuyển chế độ sáng/tối" onclick="alert('Chức năng chuyển đổi giao diện sáng/tối đang được phát triển.')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
                    </div>

                    <!-- Notification dropdown fragment -->
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                    <!-- Nút Đăng xuất -->
                    <a href="${pageContext.request.contextPath}/logout" class="nav-bell-trigger" title="Đăng xuất" style="text-decoration: none;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    </a>

                    <!-- User info card -->
                    <div class="top-bar-user-card" onclick="switchTab('tab-profile')">
                        <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                            <img src="<%= user.getAvatarUrl() %>" class="top-bar-avatar" alt="Avatar">
                        <% } else { %>
                            <div class="top-bar-avatar-placeholder"><%= initials %></div>
                        <% } %>
                        <div class="top-bar-user-info">
                            <span class="top-bar-user-name"><%= user != null ? user.getDisplayName() : "Giảng viên HIPZI" %></span>
                            <span class="top-bar-user-email"><%= user != null ? user.getEmail() : "info@hipzi.vn" %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- CHỨA WORKSPACE TAB PANES -->
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
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Đăng kí giảng dạy</h1>
                        <p>Hoàn thiện hồ sơ năng lực giảng dạy để được xét duyệt học liệu và giảng dạy.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="premium-card">
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
                                        <div class="form-group-premium">
                                            <label>Trường / đơn vị đang học hoặc công tác</label>
                                            <input type="text" name="institutionName" placeholder="Ví dụ: Đại học Sư phạm TP.HCM, THPT Chuyên Lê Hồng Phong" required>
                                        </div>
                                        <div class="form-group-premium">
                                            <label>Chuyên ngành / lĩnh vực chuyên môn</label>
                                            <input type="text" name="specialization" placeholder="Ví dụ: Sư phạm Toán, Ngôn ngữ Anh, Công nghệ thông tin" required>
                                        </div>
                                        <div class="form-group-premium">
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
                                        <div class="form-group-premium full-span">
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
                                        <div class="form-group-premium">
                                            <label>Kinh nghiệm giảng dạy</label>
                                            <input type="text" name="teachingExperience" placeholder="Ví dụ: 2 năm dạy kèm Toán THPT, trợ giảng trung tâm tiếng Anh">
                                        </div>
                                        <div class="form-group-premium">
                                            <label>Nơi từng/đang công tác</label>
                                            <input type="text" name="workplace" placeholder="Điền nếu có">
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>Thành tích, chứng chỉ hoặc bằng cấp liên quan</label>
                                            <textarea name="credentialsSummary" rows="3" placeholder="Ví dụ: IELTS 7.5, giải học sinh giỏi, chứng chỉ nghiệp vụ sư phạm, bằng cử nhân..."></textarea>
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>Hồ sơ cá nhân ngắn</label>
                                            <textarea name="teacherBio" rows="4" placeholder="Giới thiệu phương pháp dạy, nhóm học viên phù hợp và điểm mạnh chuyên môn của bạn." required></textarea>
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>Minh chứng xác minh</label>
                                            <div class="teacher-evidence-box">
                                                <input type="file" name="evidenceFiles" multiple accept=".pdf,.png,.jpg,.jpeg,.webp,.doc,.docx">
                                                <p style="font-size:0.8rem; color:var(--text-muted); margin:0.75rem 0 0 0;">Có thể đính kèm thẻ sinh viên, chứng chỉ, bằng cấp, bảng điểm hoặc giấy xác nhận công tác. Mỗi file tối đa 5MB.</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions-row-premium">
                                <button type="submit" class="btn-premium primary">
                                    <span>Gửi hồ sơ đăng kí</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4 20-7z"/></svg>
                                </button>
                            </div>
                        </form>
                    </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: ĐĂNG KÍ LỚP HỌC                       -->
            <!-- ========================================== -->
            <section id="tab-class-registration" class="tab-pane <%= "tab-class-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Đăng kí lớp học</h1>
                        <p>Quản lý danh sách lớp học và đăng ký mở lớp mới cho học viên.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <%
                    String[] registeredSubjects = new String[0];
                    if (teacherApplication != null && "approved".equals(teacherApplication.getStatus()) && teacherApplication.getTeachingSubjects() != null && !teacherApplication.getTeachingSubjects().isEmpty()) {
                        registeredSubjects = teacherApplication.getTeachingSubjects().split("\\s*,\\s*");
                    }
                %>

                <div class="premium-card">
                    <div class="premium-card-header">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M8 6h13"/><path d="M8 12h13"/><path d="M8 18h13"/><path d="M3 6h.01"/><path d="M3 12h.01"/><path d="M3 18h.01"/></svg>
                            Danh sách lớp học đã đăng kí
                        </span>
                    </div>

                    <% if (teacherClassrooms != null && !teacherClassrooms.isEmpty()) { %>
                        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr)); gap: 1.25rem;">
                            <% for (Classroom cls : teacherClassrooms) {
                                String startValue = cls.getStartTime() != null ? cls.getStartTime().toLocalTime().toString().substring(0, 5) : "";
                                String endValue = cls.getEndTime() != null ? cls.getEndTime().toLocalTime().toString().substring(0, 5) : "";
                            %>
                                <div class="classroom-card" style="border: 1px solid var(--border-dark); border-radius: 1rem; padding: 1.5rem; background: var(--surface); display: flex; flex-direction: column; justify-content: space-between; height: 100%; min-height: 250px; box-shadow: var(--shadow); transition: all 0.2s ease;">
                                    <div>
                                        <div style="display: flex; align-items: center; gap: 0.5rem; flex-wrap: wrap; margin-bottom: 0.75rem;">
                                            <span class="subject-badge" style="background: var(--primary-light); color: var(--primary); padding: 0.25rem 0.75rem; border-radius: 0.5rem; font-size: 0.75rem; font-weight: 700;"><%= cls.getSubject() %></span>
                                            <% if (cls.getGrade() != null && !cls.getGrade().isEmpty()) { %>
                                                <span style="font-size: 0.75rem; font-weight: 700; color: var(--text-muted);"><%= cls.getGrade() %></span>
                                            <% } %>
                                        </div>
                                        <h3 style="font-size: 1.1rem; font-weight: 800; color: var(--text-main); margin: 0 0 0.75rem 0; line-height: 1.4;"><%= cls.getTitle() %></h3>
                                        <% if (cls.getClassCode() != null && !cls.getClassCode().isEmpty()) { %>
                                            <div style="margin: 0 0 1.25rem 0;">
                                                <span style="font-size: 0.8rem; font-weight: 700; color: var(--primary); border: 1px solid var(--primary); background: var(--primary-light); padding: 0.25rem 0.5rem; border-radius: 0.4rem;">Mã lớp: <%= cls.getClassCode() %></span>
                                            </div>
                                        <% } %>
                                        
                                        <div style="display: flex; flex-direction: column; gap: 0.5rem; margin-bottom: 1.25rem;">
                                            <% if (cls.getScheduleDays() != null && !cls.getScheduleDays().isEmpty()) { %>
                                            <p style="display: flex; align-items: center; gap: 0.5rem; color: var(--text-main); font-weight: 600; margin: 0; font-size: 0.85rem;">
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                                <span><%= cls.getScheduleDays().replace(",", " -") %></span>
                                            </p>
                                            <% } %>
                                            <% if (!startValue.isEmpty() && !endValue.isEmpty()) { %>
                                            <p style="display: flex; align-items: center; gap: 0.5rem; color: var(--text-main); font-weight: 600; margin: 0; font-size: 0.85rem;">
                                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                                <span><%= startValue %> - <%= endValue %></span>
                                            </p>
                                            <% } %>
                                        </div>
                                    </div>

                                    <div style="display: flex; align-items: center; gap: 0.5rem; margin-top: auto;">
                                        <button type="button" class="btn-premium secondary" style="padding: 0.4rem 0.75rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;" onclick="document.getElementById('edit-class-<%= cls.getId() %>').style.display = 'flex'" title="Chỉnh sửa lớp học">
                                            <span>Chỉnh sửa</span>
                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
                                        </button>
                                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa lớp học này?');" style="margin: 0; display: inline;">
                                            <input type="hidden" name="action" value="deleteClass">
                                            <input type="hidden" name="classId" value="<%= cls.getId() %>">
                                            <button type="submit" class="btn-premium danger" style="padding: 0.4rem 0.75rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem; background: #fee2e2; border-color: #fca5a5; color: #dc2626;" title="Xóa lớp học">
                                                <span>Xóa</span>
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                            </button>
                                        </form>
                                    </div>
                                </div>

                                <!-- MODAL CHỈNH SỬA LỚP HỌC -->
                                <div id="edit-class-<%= cls.getId() %>" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.4); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
                                    <div style="background: var(--surface); width: 90%; max-width: 600px; border-radius: 1.5rem; padding: 2rem; box-shadow: var(--shadow-lg); position: relative; max-height: 90vh; overflow-y: auto;">
                                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" class="form-edit-layout" style="padding: 0;">
                                            <input type="hidden" name="action" value="updateClass">
                                            <input type="hidden" name="classId" value="<%= cls.getId() %>">
                                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; border-bottom: 1px solid var(--border-dark); padding-bottom: 0.75rem;">
                                                <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: var(--text-main);">Chỉnh sửa lớp học</h3>
                                                <div style="display: flex; gap: 0.5rem;">
                                                    <button type="button" onclick="document.getElementById('edit-class-<%= cls.getId() %>').style.display='none'" class="btn-premium secondary" style="padding: 0.5rem 1rem;">Hủy</button>
                                                    <button type="submit" class="btn-premium primary" style="padding: 0.5rem 1rem;">Lưu thay đổi</button>
                                                </div>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 1rem;">
                                                <div class="form-group-premium" style="margin: 0;">
                                                    <label>Tên lớp học</label>
                                                    <input type="text" name="className" value="<%= cls.getTitle() %>" required>
                                                </div>
                                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                                    <div class="form-group-premium" style="margin: 0;">
                                                        <label>Môn học</label>
                                                        <select name="classSubject" required>
                                                            <% for (String subject : registeredSubjects) { %>
                                                                <option value="<%= subject %>" <%= subject.equalsIgnoreCase(cls.getSubject()) ? "selected" : "" %>><%= subject %></option>
                                                            <% } %>
                                                        </select>
                                                    </div>
                                                    <div class="form-group-premium" style="margin: 0;">
                                                        <label>Khối lớp</label>
                                                        <select name="classGrade" required>
                                                            <option value="Lớp 10" <%= "Lớp 10".equals(cls.getGrade()) ? "selected" : "" %>>Lớp 10</option>
                                                            <option value="Lớp 11" <%= "Lớp 11".equals(cls.getGrade()) ? "selected" : "" %>>Lớp 11</option>
                                                            <option value="Lớp 12" <%= "Lớp 12".equals(cls.getGrade()) ? "selected" : "" %>>Lớp 12</option>
                                                            <option value="Ôn thi THPT" <%= "Ôn thi THPT".equals(cls.getGrade()) ? "selected" : "" %>>Ôn thi THPT</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                                    <div class="form-group-premium" style="margin: 0;">
                                                        <label>Trạng thái</label>
                                                        <select name="classStatus">
                                                            <option value="open" <%= "open".equals(cls.getStatus()) || "Đang mở".equals(cls.getStatus()) ? "selected" : "" %>>Đang mở</option>
                                                            <option value="upcoming" <%= "upcoming".equals(cls.getStatus()) || "Sắp khai giảng".equals(cls.getStatus()) ? "selected" : "" %>>Sắp khai giảng</option>
                                                            <option value="closed" <%= "closed".equals(cls.getStatus()) ? "selected" : "" %>>Đã đóng</option>
                                                        </select>
                                                    </div>
                                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem;">
                                                        <div class="form-group-premium" style="margin: 0;">
                                                            <label>Giờ bắt đầu</label>
                                                            <input type="text" name="startTime" class="class-time-input" value="<%= startValue %>" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                                        </div>
                                                        <div class="form-group-premium" style="margin: 0;">
                                                            <label>Giờ kết thúc</label>
                                                            <input type="text" name="endTime" class="class-time-input" value="<%= endValue %>" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group-premium" style="margin: 0;">
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
                                                <div class="form-group-premium" style="margin: 0;">
                                                    <label>Mô tả ngắn</label>
                                                    <textarea name="classDescription" rows="3"><%= cls.getDescription() != null ? cls.getDescription() : "" %></textarea>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div class="empty-status-panel" style="padding: 2.25rem 1.5rem; text-align: center; border: 1px dashed var(--border-dark); border-radius: 1rem; margin-top: 1rem;">
                            <p style="margin: 0; color: var(--text-muted); font-weight: 700;">Bạn chưa đăng kí lớp học nào.</p>
                        </div>
                    <% } %>
                </div>

                <div class="premium-card" style="margin-top: 1.5rem;">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                            Tạo lớp học mới
                        </span>
                    </div>
                    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">
                        Lưu ý: Bạn chỉ được phép mở lớp dạy cho các môn học đã được hệ thống phê duyệt trong hồ sơ năng lực của mình.
                    </p>

                    <% if (registeredSubjects.length > 0) { %>
                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" class="form-edit-layout" style="padding: 0;">
                            <input type="hidden" name="action" value="registerClass">
                            
                            <div class="form-group-premium" style="margin-bottom: 1.25rem;">
                                <label>Tên lớp học</label>
                                <input type="text" name="className" placeholder="Ví dụ: Lớp Toán 10A, Tiếng Anh giao tiếp..." required>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
                                <div class="form-group-premium" style="margin: 0;">
                                    <label>Chọn môn học</label>
                                    <select name="classSubject" required>
                                        <option value="" disabled selected>-- Chọn môn học --</option>
                                        <% for (String subject : registeredSubjects) { %>
                                            <option value="<%= subject %>"><%= subject %></option>
                                        <% } %>
                                    </select>
                                </div>

                                <div class="form-group-premium" style="margin: 0;">
                                    <label>Khối lớp</label>
                                    <select name="classGrade" required>
                                        <option value="" disabled selected>-- Chọn khối lớp --</option>
                                        <option value="Lớp 10">Lớp 10</option>
                                        <option value="Lớp 11">Lớp 11</option>
                                        <option value="Lớp 12">Lớp 12</option>
                                        <option value="Ôn thi THPT">Ôn thi THPT</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group-premium" style="margin-bottom: 1.25rem;">
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

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin: 0;">
                                    <div class="form-group-premium" style="margin: 0;">
                                        <label>Giờ bắt đầu</label>
                                        <input type="text" name="startTime" class="class-time-input" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                    </div>
                                    <div class="form-group-premium" style="margin: 0;">
                                        <label>Giờ kết thúc</label>
                                        <input type="text" name="endTime" class="class-time-input" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhập giờ dạng HH:mm, từ 00:00 đến 24:00" required>
                                    </div>
                                </div>

                                <div class="form-group-premium" style="margin: 0;">
                                    <label>Trạng thái</label>
                                    <select name="classStatus">
                                        <option value="open">Đang mở</option>
                                        <option value="upcoming">Sắp khai giảng</option>
                                        <option value="closed">Đã đóng</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="form-group-premium" style="margin-bottom: 1.25rem;">
                                <label>Mô tả ngắn</label>
                                <textarea name="classDescription" rows="3" placeholder="Nhập mô tả vắn tắt về lớp học này..."></textarea>
                            </div>

                            <div class="form-actions-row-premium">
                                <button type="submit" class="btn-premium primary" style="padding: 0.75rem 1.5rem;">Đăng kí lớp học</button>
                            </div>
                        </form>
                    <% } else { %>
                        <div class="empty-status-panel" style="padding: 2.25rem 1.5rem; text-align: center; border: 1px dashed var(--border-dark); border-radius: 1rem; margin-top: 1rem;">
                            <p style="margin: 0; color: var(--text-muted); font-weight: 700;">Bạn chưa có môn học nào được phê duyệt để mở lớp.</p>
                        </div>
                    <% } %>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 1: HỒ SƠ CÁ NHÂN TỔNG QUAN             -->
            <!-- ========================================== -->
            <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hồ sơ cá nhân</h1>
                        <p>Xem và quản lý thông tin tài khoản giảng viên của bạn trên HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <!-- METRICS ROW (Donezo style) -->
                <div class="metrics-row">
                    <!-- Metric 1: Active classrooms -->
                    <div class="metric-card primary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Lớp đang dạy</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= teacherClassrooms != null ? teacherClassrooms.size() : 0 %></div>
                            <span class="metric-card-sub">Lớp hoạt động</span>
                        </div>
                    </div>

                    <!-- Metric 2: Application status -->
                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Trạng thái hồ sơ</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value" style="font-size: 1.45rem; margin-top: 1.25rem;"><%= teachingRegistrationStatusLabel %></div>
                            <span class="metric-card-sub" style="background:#eff6ff; color:#2563eb;">Giảng viên</span>
                        </div>
                    </div>

                    <!-- Metric 3: Active courses -->
                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Khóa học của tôi</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value">1</div>
                            <span class="metric-card-sub" style="background:#f5f3ff; color:#7c3aed;">Đang phát hành</span>
                        </div>
                    </div>

                    <!-- Metric 4: System notifications -->
                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Thông báo</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= notifications != null ? notifications.size() : 0 %></div>
                            <span class="metric-card-sub" style="background:#fff7ed; color:#ea580c;">Tin nhắn mới</span>
                        </div>
                    </div>
                </div>

                <!-- MAIN GRID LAYOUT -->
                <div class="dashboard-grid-layout">
                    <!-- Cột Trái: Thông tin cá nhân -->
                    <div class="premium-card">
                        <div class="premium-card-header">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                Thông tin cá nhân
                            </span>
                            <button onclick="switchTab('tab-edit')" class="btn-premium secondary" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                                <span>Chỉnh sửa</span>
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </button>
                        </div>

                        <!-- Lưới chi tiết thông tin -->
                        <div class="profile-info-grid">
                            <div class="profile-info-item">
                                <div class="info-icon-circle primary">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                </div>
                                <div class="info-content">
                                    <span class="info-label">Họ và tên hiển thị</span>
                                    <span class="info-value"><%= user != null ? user.getDisplayName() : "—" %></span>
                                </div>
                            </div>

                            <div class="profile-info-item">
                                <div class="info-icon-circle accent">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                </div>
                                <div class="info-content">
                                    <span class="info-label">Ngày tham gia</span>
                                    <span class="info-value"><%= joinDate %></span>
                                </div>
                            </div>

                            <div class="profile-info-item">
                                <div class="info-icon-circle warning">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                </div>
                                <div class="info-content" style="min-width: 0;">
                                    <span class="info-label">Địa chỉ Email</span>
                                    <span class="info-value" style="font-size:0.95rem;" title="<%= user != null ? user.getEmail() : "" %>"><%= user != null ? user.getEmail() : "—" %></span>
                                </div>
                            </div>

                            <div class="profile-info-item">
                                <div class="info-icon-circle danger">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                </div>
                                <div class="info-content">
                                    <span class="info-label">Trạng thái tài khoản</span>
                                    <% String statusVal = (user != null) ? user.getAccountStatus() : "active"; %>
                                    <span class="acc-status-tag <%= statusVal %>">
                                        <%= "active".equals(statusVal) ? "Đang hoạt động" : "suspended".equals(statusVal) ? "Tạm khóa" : "Vô hiệu hóa" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Cột Phải: Danh sách lớp học -->
                    <div class="premium-card">
                        <div class="premium-card-header">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                Lớp học của tôi
                            </span>
                            <button onclick="switchTab('tab-class-registration')" class="btn-premium secondary" style="padding: 0.4rem 0.85rem; font-size: 0.8rem;">Xem tất cả</button>
                        </div>

                        <div class="dashboard-list">
                            <% if (teacherClassrooms != null && !teacherClassrooms.isEmpty()) { 
                                int count = 0;
                                for (Classroom cls : teacherClassrooms) { 
                                    if (count++ >= 3) break;
                            %>
                                <div class="dashboard-list-item">
                                    <div class="item-info">
                                        <div class="item-icon-round primary">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                        </div>
                                        <div class="item-meta">
                                            <span class="item-title" style="font-weight:700; color:var(--text-main); font-size:0.9rem;"><%= cls.getTitle() %></span>
                                            <span class="item-subtitle" style="font-size:0.75rem; color:var(--text-muted);"><%= cls.getSubject() %> - <%= cls.getGrade() %></span>
                                        </div>
                                    </div>
                                    <span class="status-badge <%= cls.getStatus() %>"><%= "open".equals(cls.getStatus()) ? "Đang mở" : "closed".equals(cls.getStatus()) ? "Đã đóng" : "Sắp mở" %></span>
                                </div>
                            <% } } else { %>
                                <div style="text-align: center; color: var(--text-muted); font-size: 0.9rem; padding: 1.5rem 0;">
                                    Chưa đăng kí lớp học nào.
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>
<!-- ========================================== -->
            <!-- TAB 2: CHỈNH SỬA HỒ SƠ                     -->
            <!-- ========================================== -->
            <section id="tab-edit" class="tab-pane <%= "tab-edit".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Cập nhật thông tin</h1>
                        <p>Thay đổi thông tin cá nhân hiển thị của giảng viên trên hệ thống.</p>
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
            <section id="tab-security" class="tab-pane <%= "tab-security".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Bảo mật tài khoản</h1>
                        <p>Quản lý mật khẩu đăng nhập, bảo mật hai lớp và phiên đăng nhập.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <!-- KHUNG CHÍNH TOP: MẬT KHẨU ĐĂNG NHẬP -->
                <div class="premium-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1.25rem;">
                        <div>
                            <span style="font-weight: 800; font-size: 1.15rem; color: #b45309; letter-spacing: 0.5px; text-transform: uppercase; display: block;">Mật khẩu đăng nhập</span>
                            <p style="font-size: 0.85rem; color: var(--text-muted); margin: 0.35rem 0 0 0;">Cập nhật mật khẩu định kỳ để bảo mật tốt hơn.</p>
                        </div>
                        <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='flex';" class="btn-premium primary" style="background: #059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">
                            <span>Đổi mật khẩu</span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                    </div>

                    <div style="padding: 1rem 0 0 0; border-top: 1px solid var(--border-light); display: flex; align-items: center; gap: 1.5rem; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: 0.4rem; color: #10b981; font-weight: 700; font-size: 0.85rem;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            <span>Mật khẩu mạnh</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 0.4rem; color: <%= (user != null && user.isTwoFactorEnabled()) ? "#10b981" : "var(--text-muted)" %>; font-weight: 700; font-size: 0.85rem;">
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
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-top: 1.5rem;">
                    
                    <!-- KHUNG TRÁI: BẢO MẬT 2 LỚP (OTP) -->
                    <div class="premium-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                            <span style="font-weight: 800; font-size: 0.9rem; color: var(--text-main); text-transform: uppercase; letter-spacing: 0.5px;">Bảo mật 2 lớp (OTP)</span>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-weight: 700; font-size: 0.95rem; color: var(--text-main);">Mã OTP qua Email</span>
                            
                            <!-- Form ngầm xử lý toggle 2FA -->
                            <form id="toggle2faForm" action="${pageContext.request.contextPath}/profile" method="POST" style="display: none;">
                                <input type="hidden" name="action" value="toggle2FA">
                            </form>

                            <!-- NÚT TOGGLE SWITCH THỰC TẾ -->
                            <% boolean is2fa = (user != null && user.isTwoFactorEnabled()); %>
                            <div id="otp-toggle-btn" onclick="document.getElementById('toggle2faForm').submit();" style="width: 44px; height: 24px; background: <%= is2fa ? "#10b981" : "#cbd5e1" %>; border-radius: 12px; padding: 2px; cursor: pointer; transition: background 0.3s ease; display: flex; align-items: center;">
                                <div class="toggle-circle" style="width: 20px; height: 20px; background: #ffffff; border-radius: 50%; box-shadow: 0 1px 3px rgba(0,0,0,0.2); transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform: translateX(<%= is2fa ? "20px" : "0" %>);"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KHUNG PHẢI: THIẾT BỊ HIỆN TẠI -->
                    <div class="premium-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                            <span style="font-weight: 800; font-size: 0.9rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px;">Thiết bị hiện tại</span>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                        </div>
                        <div>
                            <span style="font-weight: 800; font-size: 1.1rem; color: var(--text-main); display: block;">Windows - Chrome (Vietnam)</span>
                            <span style="font-size: 0.75rem; color: #10b981; font-weight: 600; display: inline-block; margin-top: 0.25rem; background: #ecfdf5; padding: 0.15rem 0.5rem; border-radius: 0.25rem;">Phiên truy cập an toàn</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: ĐĂNG KHÓA HỌC                         -->
            <!-- ========================================== -->
            <section id="tab-course-registration" class="tab-pane <%= "tab-course-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Đăng khóa học</h1>
                        <p>Tạo và liên kết nội dung bài giảng, khóa học từ Google Drive lên HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="premium-card">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                            Tạo khóa học mới
                        </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;" class="form-edit-layout">
                        <input type="hidden" name="action" value="registerCourse">

                        <div class="form-group-premium" style="grid-column: 1 / -1;">
                            <label>Tên khóa học <span style="color:#ef4444;">*</span></label>
                            <input type="text" name="courseTitle" placeholder="Ví dụ: Khóa học Tiếng Anh Giao Tiếp Cơ Bản..." required>
                        </div>

                        <div class="form-group-premium">
                            <label>Môn học <span style="color:#ef4444;">*</span></label>
                            <select name="courseSubject" required>
                                <option value="" disabled selected>-- Chọn môn học --</option>
                                <% for (String subject : registeredSubjects) { %>
                                    <option value="<%= subject %>"><%= subject %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group-premium">
                            <label>Khối lớp / Cấp độ <span style="color:#ef4444;">*</span></label>
                            <input type="text" name="courseGrade" placeholder="Ví dụ: Lớp 10, IELTS, TOEIC..." required>
                        </div>

                        <div class="form-group-premium">
                            <label>Giá tiền (VND) <span style="color:#ef4444;">*</span></label>
                            <input type="number" name="coursePriceAmount" placeholder="Ví dụ: 500000 (Nhập 0 nếu miễn phí)" value="0" min="0" step="1000" required>
                        </div>

                        <div class="form-group-premium">
                            <label>Số bài học <span style="color:#ef4444;">*</span></label>
                            <input type="number" name="courseLessonsCount" placeholder="Ví dụ: 12" value="1" min="1" required>
                        </div>

                        <div class="form-group-premium">
                            <label>Thời lượng dự kiến (Giờ)</label>
                            <input type="number" name="courseEstimatedHours" placeholder="Ví dụ: 20.5" value="0" min="0" step="0.5">
                        </div>

                        <div class="form-group-premium">
                            <label>Trình độ yêu cầu</label>
                            <input type="text" name="courseLevel" placeholder="Ví dụ: Cơ bản, Trung bình, Nâng cao...">
                        </div>

                        <div class="form-group-premium" style="grid-column: 1 / -1;">
                            <label>Ảnh bìa khóa học</label>
                            <input type="file" name="courseThumbnailFile" accept="image/*">
                        </div>

                        <div class="form-group-premium" style="grid-column: 1 / -1;">
                            <label>Mô tả ngắn khóa học <span style="color:#ef4444;">*</span></label>
                            <textarea name="courseDescription" rows="3" placeholder="Nhập mô tả về khóa học này..." required></textarea>
                        </div>

                        <!-- ===== GOOGLE PICKER SECTION ===== -->
                        <div class="form-group-premium" id="picker-section" style="grid-column: 1 / -1;">
                            <label>Nội dung khóa học trên Google Drive <span style="color:#ef4444;">*</span></label>
                            
                            <% Object teacherGoogleAccount = request.getAttribute("teacherGoogleAccount");
                               if (teacherGoogleAccount == null) { %>
                                <div style="background:#fff1f2; border:1px solid #fecdd3; border-radius:0.85rem; padding:1.25rem; display:flex; align-items:center; justify-content:space-between; gap:1rem; flex-wrap:wrap;">
                                    <div style="display:flex; align-items:center; gap:1rem;">
                                        <div style="width:40px; height:40px; border-radius:50%; background:#ffe4e6; color:#e11d48; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                        </div>
                                        <div>
                                            <strong style="display:block; color:#be123c; font-size:0.95rem; margin-bottom:0.2rem;">Chưa kết nối Google Drive</strong>
                                            <span style="color:#e11d48; font-size:0.85rem;">Bạn cần kết nối tài khoản Google Drive để có thể chọn file khóa học.</span>
                                        </div>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/teacher-drive/connect" class="btn-premium primary" style="background:#e11d48; box-shadow:none; text-decoration:none;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                                        <span>Kết nối Drive</span>
                                    </a>
                                </div>
                            <% } else { %>
                                <button type="button" id="btn-open-picker"
                                    onclick="openGoogleDrivePicker()"
                                    style="display:inline-flex; align-items:center; gap:0.6rem;
                                           padding:0.8rem 1.25rem; border-radius:0.85rem;
                                           border:1.5px solid #cbd5e1; background:#ffffff;
                                           color:#0f172a; font-weight:700; font-size:0.95rem;
                                           cursor:pointer; transition:all 0.2s ease;
                                           box-shadow:0 2px 8px rgba(0,0,0,0.05); width:100%;
                                           justify-content:center; font-family:inherit;">
                                    <svg width="20" height="20" viewBox="0 0 87.3 78" fill="none" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
                                        <path d="M6.6 66.85l3.85 6.65c.8 1.4 1.95 2.5 3.3 3.3l13.75-23.8H0a15.92 15.92 0 003.85 5.55z" fill="#0066da"/>
                                        <path d="M43.65 25L29.9 1.2c-1.35.8-2.5 1.9-3.3 3.3l-25.4 44a16.06 16.06 0 00-1.2 7.5h27.5z" fill="#00ac47"/>
                                        <path d="M73.55 76.8c1.35-.8 2.5-1.9 3.3-3.3l1.6-2.75 7.65-13.25a16.27 16.27 0 001.2-7.5H59.8l5.85 11.75z" fill="#ea4335"/>
                                        <path d="M43.65 25L57.4 1.2C56.05.4 54.5 0 52.9 0H34.4c-1.6 0-3.15.45-4.5 1.2z" fill="#00832d"/>
                                        <path d="M59.8 50H27.5L13.75 73.8c1.35.8 2.9 1.2 4.5 1.2h50.8c1.6 0 3.15-.45 4.5-1.2z" fill="#2684fc"/>
                                        <path d="M73.4 26l-12.7-22c-.8-1.4-1.95-2.5-3.3-3.3L43.65 25 59.8 50h27.45a15.92 15.92 0 00-1.55-8.25z" fill="#ffba00"/>
                                    </svg>
                                    <span id="picker-btn-label">Chọn file / thư mục từ Google Drive</span>
                                    <svg id="picker-loading-spin" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="display:none; animation:spin 1s linear infinite; flex-shrink:0;">
                                        <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
                                    </svg>
                                </button>
                            <% } %>

                            <div id="picker-selected-preview" style="display:none; margin-top:0.85rem; padding:0.9rem 1.1rem; border-radius:0.85rem; border:1px solid #bbf7d0; background:#f0fdf4; display:flex; align-items:center; gap:0.85rem; flex-wrap:wrap;">
                                <div id="picker-resource-icon" style="width:40px; height:40px; border-radius:0.65rem; background:#dcfce7; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="2.2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                </div>
                                <div style="flex:1; min-width:0;">
                                    <div id="picker-resource-name" style="font-weight:700; color:#0f172a; font-size:0.9rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">—</div>
                                    <div id="picker-resource-url" style="font-size:0.78rem; color:#047857; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">—</div>
                                </div>
                                <button type="button" onclick="clearPickerSelection()" title="Xóa lựa chọn"
                                    style="width:30px; height:30px; border-radius:50%; border:none; background:#fee2e2; color:#dc2626; font-size:1rem; cursor:pointer; display:flex; align-items:center; justify-content:center; flex-shrink:0;">&times;</button>
                            </div>

                            <button type="button" id="btn-show-manual-input"
                                onclick="document.getElementById('manual-drive-inputs').style.display='grid'; this.style.display='none';"
                                style="display:inline-flex; align-items:center; gap:0.4rem; background:none; border:none;
                                       color:#64748b; font-size:0.8rem; font-weight:600; cursor:pointer; margin-top:0.4rem;
                                       padding:0; text-decoration:underline; text-underline-offset:2px; font-family:inherit;">
                                Nhập thủ công URL hoặc ID nếu Picker không hoạt động
                            </button>

                            <div id="manual-drive-inputs" style="display:none; grid-template-columns:1fr 1fr; gap:0.75rem; margin-top:0.75rem;">
                                <div style="grid-column:1/-1; display:flex; flex-direction:column; gap:0.35rem;">
                                    <label style="font-size:0.8rem; font-weight:600; color:#64748b;">URL Google Drive</label>
                                    <input type="url" id="courseGoogleDriveUrlManual" name="courseGoogleDriveUrl" placeholder="https://drive.google.com/..."
                                        style="padding:0.7rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.9rem; outline:none; font-family:inherit;">
                                </div>
                                <div style="display:flex; flex-direction:column; gap:0.35rem;">
                                    <label style="font-size:0.8rem; font-weight:600; color:#64748b;">File ID (nếu là file đơn lẻ)</label>
                                    <input type="text" id="courseGoogleDriveFileIdManual" name="courseGoogleDriveFileId" placeholder="1aBcDeFgHiJkLm..."
                                        style="padding:0.7rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.9rem; outline:none; font-family:inherit;">
                                </div>
                                <div style="display:flex; flex-direction:column; gap:0.35rem;">
                                    <label style="font-size:0.8rem; font-weight:600; color:#64748b;">Folder ID (nếu là thư mục)</label>
                                    <input type="text" id="courseGoogleDriveFolderIdManual" name="courseGoogleDriveFolderId" placeholder="1aBcDeFgHiJkLm..."
                                        style="padding:0.7rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.9rem; outline:none; font-family:inherit;">
                                </div>
                            </div>

                            <input type="hidden" id="courseGoogleDriveUrlHidden" name="courseGoogleDriveUrl">
                            <input type="hidden" id="courseGoogleDriveFileIdHidden" name="courseGoogleDriveFileId">
                            <input type="hidden" id="courseGoogleDriveFolderIdHidden" name="courseGoogleDriveFolderId">
                        </div>
                        <!-- ===== END GOOGLE PICKER SECTION ===== -->

                        <div class="form-actions-row-premium full-span" style="grid-column: 1 / -1; margin-top: 1rem;">
                            <button type="submit" class="btn-premium primary" style="width: 100%;">Đăng khóa học</button>
                        </div>
                    </form>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 4: ĐĂNG TẢI TÀI LIỆU                   -->
            <!-- ========================================== -->
            <section id="tab-upload-material" class="tab-pane <%= "tab-upload-material".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Đăng tải tài liệu</h1>
                        <p>Đóng góp tài liệu học tập hữu ích vào kho tài nguyên giáo dục HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <a href="${pageContext.request.contextPath}/material-repository" class="btn-premium secondary" style="text-decoration: none; display: inline-flex; align-items: center; gap: 0.25rem;">
                            <span>Đến kho tài liệu</span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
                        </a>
                    </div>
                </div>

                <div class="premium-card">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            Đóng góp tài liệu
                        </span>
                    </div>

                    <div style="display: grid; grid-template-columns: 1.1fr 0.9fr; gap: 1.5rem;">
                        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 1rem; padding: 1.5rem; display: flex; flex-direction: column; gap: 1rem;">
                            <div style="width: 48px; height: 48px; border-radius: 0.75rem; background: var(--primary-light); color: var(--primary); display: flex; align-items: center; justify-content: center;">
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                            </div>
                            <div>
                                <h3 style="margin: 0 0 0.5rem 0; color: var(--text-main); font-size: 1.15rem; font-weight: 800;">Tài liệu của bạn sẽ xuất hiện trong kho tài liệu</h3>
                                <p style="margin: 0; color: var(--text-muted); line-height: 1.6; font-size: 0.88rem;">Khi giảng viên đăng tải bài giảng, đề luyện tập, giáo án hoặc bộ tài nguyên học tập chất lượng, tài liệu sẽ được đưa vào kho tài liệu để học viên dễ tìm kiếm, xem và đánh giá.</p>
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem; margin-top: 0.5rem;">
                                <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 0.75rem; text-align: center;">
                                    <strong style="display: block; color: var(--primary); font-size: 1.25rem;">01</strong>
                                    <span style="display: block; color: var(--text-muted); font-weight: 700; font-size: 0.72rem; margin-top: 0.25rem;">Đăng tài liệu</span>
                                </div>
                                <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 0.75rem; text-align: center;">
                                    <strong style="display: block; color: var(--primary); font-size: 1.25rem;">02</strong>
                                    <span style="display: block; color: var(--text-muted); font-weight: 700; font-size: 0.72rem; margin-top: 0.25rem;">Nhận tương tác</span>
                                </div>
                                <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 0.75rem; text-align: center;">
                                    <strong style="display: block; color: var(--primary); font-size: 1.25rem;">03</strong>
                                    <span style="display: block; color: var(--text-muted); font-weight: 700; font-size: 0.72rem; margin-top: 0.25rem;">Tăng uy tín</span>
                                </div>
                            </div>
                        </div>

                        <div style="background: linear-gradient(135deg, #064e3b 0%, #047857 100%); color: #ffffff; border-radius: 1rem; padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between; gap: 1.25rem; box-shadow: 0 14px 28px rgba(4, 120, 87, 0.12);">
                            <div>
                                <div style="display: inline-flex; align-items: center; gap: 0.45rem; background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.18); border-radius: 999px; padding: 0.25rem 0.75rem; font-size: 0.72rem; font-weight: 800;">ƯU TIÊN GỢI Ý</div>
                                <h3 style="margin: 0.75rem 0 0.5rem 0; font-size: 1.25rem; line-height: 1.3; font-weight: 800;">Giảng viên tích cực sẽ có lợi thế hiển thị</h3>
                                <p style="margin: 0; color: #d1fae5; line-height: 1.6; font-size: 0.85rem;">Những giảng viên thường xuyên chia sẻ tài liệu chất lượng, có nhiều lượt xem và nhận đánh giá tốt sẽ được hệ thống xem là tín hiệu uy tín để ưu tiên gợi ý trong các luồng tìm kiếm và đăng ký giảng dạy.</p>
                            </div>
                            <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='block'; document.getElementById('repository-upload-form-panel').scrollIntoView({ behavior: 'smooth', block: 'start' });" class="btn-premium secondary" style="width: 100%; border: none; background: #ffffff; color: var(--primary); font-weight: 800;">
                                <span>Bắt đầu đăng tải</span>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
                            </button>
                        </div>
                    </div>
                </div>

                <div id="repository-upload-form-panel" style="display: none; margin-top: 1.5rem; background: #ffffff; border: 1px solid var(--border-dark); border-radius: 1rem; padding: 1.5rem; box-shadow: var(--shadow);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-light); padding-bottom: 0.75rem;">
                            <div>
                                <h3 style="margin: 0; color: var(--text-main); font-size: 1.15rem; font-weight: 800;">Thông tin tài liệu đăng tải</h3>
                                <p style="margin: 0.25rem 0 0 0; color: var(--text-muted); font-size: 0.85rem;">File sẽ được lưu trên Supabase Storage và hiển thị công khai trong kho tài liệu sau khi đăng.</p>
                            </div>
                            <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='none';" style="width: 32px; height: 32px; border-radius: 50%; border: none; background: var(--border-light); color: var(--text-muted); font-size: 1.1rem; cursor: pointer; display: flex; align-items: center; justify-content: center;">&times;</button>
                        </div>

                        <form class="repository-upload-form form-edit-layout" action="${pageContext.request.contextPath}/material-repository" method="POST" enctype="multipart/form-data" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem; padding: 0;">
                            <input type="hidden" name="action" value="uploadRepositoryMaterial">

                            <div class="form-group-premium" style="grid-column: 1 / -1;">
                                <label>Tiêu đề tài liệu <span style="color:#ef4444;">*</span></label>
                                <input type="text" name="materialTitle" required maxlength="180" placeholder="Ví dụ: Chuyên đề hàm số lớp 12">
                            </div>

                            <div class="form-group-premium">
                                <label>Môn học <span style="color:#ef4444;">*</span></label>
                                <select name="materialSubject" required>
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

                            <div class="form-group-premium">
                                <label>Khối lớp <span style="color:#ef4444;">*</span></label>
                                <select name="materialGrade" required>
                                    <option value="">Chọn khối lớp</option>
                                    <option value="Lớp 10">Lớp 10</option>
                                    <option value="Lớp 11">Lớp 11</option>
                                    <option value="Lớp 12">Lớp 12</option>
                                </select>
                            </div>

                            <div class="form-group-premium">
                                <label>Loại tài liệu <span style="color:#ef4444;">*</span></label>
                                <select name="materialType" required>
                                    <option value="Lý thuyết">Lý thuyết</option>
                                    <option value="Đề ôn tập">Đề ôn tập</option>
                                </select>
                            </div>

                            <div class="form-group-premium">
                                <label>File tài liệu <span style="color:#ef4444;">*</span></label>
                                <input type="file" name="materialFile" required accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp" style="padding: 0.55rem;">
                                <span style="font-size: 0.72rem; color: var(--text-muted); margin-top: 0.15rem;">Hỗ trợ PDF, Word, PowerPoint, Excel và ảnh. Tối đa 50MB.</span>
                            </div>

                            <div class="form-group-premium" style="grid-column: 1 / -1;">
                                <label>Mô tả ngắn</label>
                                <textarea name="materialDescription" rows="3" maxlength="800" placeholder="Tóm tắt nội dung, mục tiêu học tập hoặc cách sử dụng tài liệu..."></textarea>
                            </div>

                            <div class="form-actions-row-premium full-span" style="grid-column: 1 / -1; margin-top: 1rem;">
                                <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='none';" class="btn-premium secondary">Hủy</button>
                                <button type="submit" class="btn-premium primary">Đăng tải lên kho</button>
                            </div>
                        </form>
                    </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 7: HỐ TRỢ HỌC TẬP                      -->
            <!-- ========================================== -->
            <section id="tab-support" class="tab-pane <%= "tab-support".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hỗ trợ giảng dạy</h1>
                        <p>Giải đáp thắc mắc và gửi yêu cầu trợ giúp kỹ thuật từ ban quản trị HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="dashboard-grid-layout" style="align-items: start;">
                    <!-- FAQ -->
                    <div class="premium-card">
                        <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                Câu hỏi thường gặp (FAQ)
                            </span>
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 1rem;">
                            <details style="background: #ffffff; padding: 1.25rem; border-radius: 1rem; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s ease; box-shadow: var(--shadow);">
                                <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                    <span>Làm thế nào để tải xuống bài giảng?</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                </summary>
                                <p style="font-size: 0.9rem; color: var(--text-muted); margin: 1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                    Học viên có thể tải xuống các file đính kèm miễn phí khi tài liệu đã được duyệt và chuyển sang chế độ hiển thị công khai.
                                </p>
                            </details>

                            <details style="background: #ffffff; padding: 1.25rem; border-radius: 1rem; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s ease; box-shadow: var(--shadow);">
                                <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                    <span>AI tạo câu hỏi ôn tập hoạt động ra sao?</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                </summary>
                                <p style="font-size: 0.9rem; color: var(--text-muted); margin: 1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                    Trợ lý AI phân tích văn bản từ tài liệu gốc do Giảng viên cung cấp để bóc tách thành các bộ Flashcard trực quan cho học viên luyện tập.
                                </p>
                            </details>
                        </div>
                    </div>

                    <!-- SUPPORT FORM -->
                    <div class="premium-card">
                        <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                Yêu cầu hỗ trợ
                            </span>
                        </div>
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.5rem;">Gửi yêu cầu trực tiếp đến đội ngũ kỹ thuật nếu bạn gặp sự cố nghiêm trọng.</p>
                        <form id="supportForm" style="display: flex; flex-direction: column; gap: 1.25rem;" class="form-edit-layout">
                            <div class="form-group-premium">
                                <label>Tiêu đề cần hỗ trợ</label>
                                <input type="text" name="title" required placeholder="Nhập tiêu đề vắn tắt...">
                            </div>
                            <div class="form-group-premium">
                                <label>Mô tả chi tiết</label>
                                <textarea name="content" rows="4" required placeholder="Mô tả khó khăn bạn đang gặp phải..."></textarea>
                            </div>
                            <button type="submit" class="btn-premium primary" style="width: 100%; text-transform: uppercase; letter-spacing: 1px; font-size: 0.85rem;">Gửi tin nhắn</button>
                        </form>
                    </div>
                </div>
            </section>
            <!-- ========================================== -->
            <!-- TAB: THỐNG KÊ SỐ DƯ (VÍ TIỀN)              -->
            <!-- ========================================== -->
            <section id="tab-balance-stats" class="tab-pane <%= "tab-balance-stats".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Thống kê số dư</h1>
                        <p>Quản lý nguồn thu nhập, số dư hiện có và yêu cầu thanh toán.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <%
                    String displayBalance = "0";
                    if (user != null) {
                        displayBalance = new java.text.DecimalFormat("#,##0").format(user.getWalletBalance());
                    }
                %>

                <div class="dashboard-grid-layout" style="display: grid; grid-template-columns: 1fr 2fr; gap: 1.5rem; margin-top: 1rem;">
                    <!-- Thẻ số dư ví chính -->
                    <div class="premium-card" style="background: linear-gradient(135deg, #047857 0%, #10b981 100%); color: #ffffff; padding: 2rem; border: none; display: flex; flex-direction: column; justify-content: space-between; min-height: 240px; box-shadow: 0 10px 25px -5px rgba(4, 120, 87, 0.3);">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                                <span style="font-size: 0.9rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; opacity: 0.9;">Ví tài khoản của tôi</span>
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3a2 2 0 0 0 0-4z"/><circle cx="18" cy="12" r="1"/></svg>
                            </div>
                            <span style="font-size: 0.85rem; opacity: 0.8; display: block; margin-bottom: 0.25rem;">Số dư khả dụng</span>
                            <div style="font-size: 2.25rem; font-weight: 800; letter-spacing: -0.5px;"><%= displayBalance %> <span style="font-size: 1.35rem; font-weight: 600;">VND</span></div>
                        </div>
                        <div style="margin-top: 1.5rem;">
                            <button type="button" class="btn-premium primary" style="background: #ffffff; color: #047857; width: 100%; border: none; font-weight: 700; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border-radius: 0.75rem; padding: 0.8rem 1.25rem;" onclick="alert('Chức năng yêu cầu rút tiền tạm thời chưa mở. Đội ngũ kỹ thuật đang kết nối cổng thanh toán ngân hàng.')">
                                Rút tiền về ngân hàng
                            </button>
                        </div>
                    </div>

                    <!-- Lưới thống kê thu nhập chi tiết -->
                    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.25rem;">
                        <!-- Card 1 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Doanh thu tháng này</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #ecfdf5; color: #059669; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">12.850.000 VND</div>
                            </div>
                            <span style="font-size: 0.75rem; color: #059669; font-weight: 700; display: inline-flex; align-items: center; gap: 0.25rem;">
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="18 15 12 9 6 15"/></svg>
                                +12.4% so với tháng trước
                            </span>
                        </div>
                        <!-- Card 2 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Thu nhập chờ duyệt</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #fffbeb; color: #d97706; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">1.500.000 VND</div>
                            </div>
                            <span style="font-size: 0.75rem; color: var(--text-muted); font-weight: 600;">Sẽ được đối soát vào ngày 25 hàng tháng</span>
                        </div>
                        <!-- Card 3 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Khóa học đã bán</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #f5f3ff; color: #7c3aed; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">48 <span style="font-size: 0.95rem; font-weight: 600; color: var(--text-muted);">lượt</span></div>
                            </div>
                            <span style="font-size: 0.75rem; color: #7c3aed; font-weight: 700;">Từ 3 khóa học trực tuyến đang mở</span>
                        </div>
                        <!-- Card 4 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Học viên đăng ký</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #eff6ff; color: #2563eb; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">152 <span style="font-size: 0.95rem; font-weight: 600; color: var(--text-muted);">học viên</span></div>
                            </div>
                            <span style="font-size: 0.75rem; color: #2563eb; font-weight: 700;">+24 học viên mới trong tuần này</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: LỊCH SỬ GIAO DỊCH (VÍ TIỀN)           -->
            <!-- ========================================== -->
            <section id="tab-transaction-history" class="tab-pane <%= "tab-transaction-history".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Lịch sử giao dịch</h1>
                        <p>Danh sách các giao dịch phát sinh từ việc bán khóa học, tài liệu và rút tiền.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="premium-card" style="padding: 0; overflow: hidden; margin-top: 1rem;">
                    <div style="overflow-x: auto;">
                        <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.92rem;">
                            <thead>
                                <tr style="background: #f8fafc; border-bottom: 1px solid var(--border-dark);">
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted);">Mã giao dịch</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted);">Ngày giao dịch</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted);">Nội dung</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted); text-align: right;">Số tiền</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted); text-align: center;">Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0892</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">15/06/2026 14:30</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Học viên mua khóa học: Lập trình Java Web MVC</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #059669;">+250.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Thành công</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0891</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">12/06/2026 09:15</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Yêu cầu rút tiền về Techcombank</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #ef4444;">-1.500.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Thành công</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0890</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">10/06/2026 18:45</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Học viên mua khóa học: Luyện thi THPT Toán học nâng cao</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #059669;">+300.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Thành công</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0889</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">08/06/2026 11:00</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Học viên tải tài liệu: Bộ đề ôn luyện tiếng Anh 2026</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #059669;">+50.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Thành công</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: none;">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0888</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">05/06/2026 16:20</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Yêu cầu rút tiền về Vietcombank</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #ef4444;">-500.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #fef2f2; color: #ef4444; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem; cursor: help;" title="Số tài khoản ngân hàng thụ hưởng không hợp lệ hoặc bị từ chối bởi ngân hàng liên kết.">Thất bại</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- MODAL OVERLAY: ĐỔI MẬT KHẨU HỆ THỐNG       -->
            <!-- ========================================== -->
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

                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="form-edit-layout" style="display:flex; flex-direction:column; gap:1.25rem; padding: 0;">
                        <input type="hidden" name="action" value="changePassword">
                        
                        <div class="form-group-premium">
                            <label>Mật khẩu hiện tại <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="currentPassword" required placeholder="••••••••">
                        </div>

                        <div class="form-group-premium">
                            <label>Mật khẩu mới <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="newPassword" required minlength="6" placeholder="Mật khẩu ít nhất 6 ký tự">
                        </div>

                        <div class="form-group-premium">
                            <label>Xác nhận mật khẩu mới <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="confirmPassword" required minlength="6" placeholder="Nhập lại mật khẩu mới">
                        </div>

                        <div class="form-actions-row-premium">
                            <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='none';" class="btn-premium secondary">Hủy bỏ</button>
                            <button type="submit" class="btn-premium primary" style="background:#059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">Cập nhật ngay</button>
                        </div>
                    </form>
                </div>
            </div>

            </main>
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
            'tab-security': 'Bảo mật',
            'tab-upload-material': 'Đăng tải tài liệu',
            'tab-support': 'Hỗ trợ giảng dạy',
            'tab-balance-stats': 'Thống kê số dư',
            'tab-transaction-history': 'Lịch sử giao dịch',
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

        function toggleSidebar() {
            const container = document.querySelector('.app-dashboard-container');
            if (container) {
                container.classList.toggle('collapsed');
                const isCollapsed = container.classList.contains('collapsed');
                localStorage.setItem('sidebarCollapsed', isCollapsed ? 'true' : 'false');
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
            const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
            if (isCollapsed) {
                const container = document.querySelector('.app-dashboard-container');
                if (container) {
                    container.classList.add('collapsed');
                }
            }
        });

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
    <!-- ===================================================== -->
    <!-- GOOGLE PICKER INTEGRATION                              -->
    <!-- ===================================================== -->
    <script src="https://apis.google.com/js/api.js" async defer></script>
    <style>
        @keyframes spin { to { transform: rotate(360deg); } }
        #btn-open-picker:hover {
            border-color: #059669 !important;
            background: #f0fdf4 !important;
            box-shadow: 0 4px 14px rgba(5,150,105,0.15) !important;
            transform: translateY(-1px);
        }
    </style>
    <script>
        var pickerApiLoaded = false;
        var pickerTokenPending = false;

        function onGapiLoad() {
            gapi.load('picker', function() { pickerApiLoaded = true; });
        }

        function openGoogleDrivePicker() {
            var btn = document.getElementById('btn-open-picker');
            var spin = document.getElementById('picker-loading-spin');
            var label = document.getElementById('picker-btn-label');
            if (pickerTokenPending) return;
            pickerTokenPending = true;
            label.textContent = 'Đang xác thực với Google...';
            spin.style.display = 'block';
            btn.disabled = true;

            fetch('${pageContext.request.contextPath}/teacher-drive/token', { credentials: 'same-origin' })
                .then(function(res) { return res.json(); })
                .then(function(data) {
                    if (data.error) { showToast(data.error, 'error'); resetPickerBtn(); return; }
                    if (!pickerApiLoaded) {
                        var att = 0, t = setInterval(function() {
                            att++;
                            if (pickerApiLoaded) { clearInterval(t); buildAndShowPicker(data.accessToken, data.clientId); }
                            else if (att > 30) { clearInterval(t); showToast('Google Picker chưa tải xong.', 'error'); resetPickerBtn(); }
                        }, 200);
                    } else { buildAndShowPicker(data.accessToken, data.clientId); }
                })
                .catch(function() { showToast('Không thể lấy token Drive.', 'error'); resetPickerBtn(); });
        }

        function buildAndShowPicker(accessToken, clientId) {
            try {
                var appId = clientId.split('-')[0];
                var docsView = new google.picker.DocsView().setIncludeFolders(true).setSelectFolderEnabled(true);
                var folderView = new google.picker.DocsView(google.picker.ViewId.FOLDERS).setSelectFolderEnabled(true);
                var picker = new google.picker.PickerBuilder()
                    .setAppId(appId)
                    .enableFeature(google.picker.Feature.NAV_HIDDEN)
                    .enableFeature(google.picker.Feature.MULTISELECT_DISABLED)
                    .setOAuthToken(accessToken)
                    .addView(docsView).addView(folderView)
                    .setTitle('Chọn nội dung khóa học từ Google Drive')
                    .setCallback(pickerCallback).build();
                picker.setVisible(true);
            } catch(e) { showToast('Không thể mở Google Picker: ' + e.message, 'error'); }
            resetPickerBtn();
        }

        function pickerCallback(data) {
            if (data.action !== google.picker.Action.PICKED) return;
            var doc = data.docs[0]; if (!doc) return;
            var id = doc.id || '', name = doc.name || id, url = doc.url || '', mime = doc.mimeType || '';
            var isFolder = (mime === 'application/vnd.google-apps.folder');
            if (!url) url = isFolder
                ? 'https://drive.google.com/drive/folders/' + id
                : 'https://drive.google.com/file/d/' + id + '/view?usp=sharing';

            document.getElementById('courseGoogleDriveUrlHidden').value = url;
            document.getElementById('courseGoogleDriveFileIdHidden').value = isFolder ? '' : id;
            document.getElementById('courseGoogleDriveFolderIdHidden').value = isFolder ? id : '';

            var vals = [url, isFolder ? '' : id, isFolder ? id : ''];
            ['courseGoogleDriveUrlManual','courseGoogleDriveFileIdManual','courseGoogleDriveFolderIdManual']
                .forEach(function(eid, i) { var el = document.getElementById(eid); if (el) el.value = vals[i]; });

            document.getElementById('picker-selected-preview').style.display = 'flex';
            document.getElementById('picker-resource-name').textContent = name;
            document.getElementById('picker-resource-url').textContent = url;
            var iconEl = document.getElementById('picker-resource-icon');
            if (isFolder) {
                iconEl.style.background = '#ede9fe';
                iconEl.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#7c3aed" stroke-width="2.2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>';
            } else {
                iconEl.style.background = '#dcfce7';
                iconEl.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="2.2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>';
            }
            document.getElementById('picker-btn-label').textContent = 'Thay đổi lựa chọn';
            showToast('Đã chọn: ' + name, 'success');
        }

        function clearPickerSelection() {
            ['courseGoogleDriveUrlHidden','courseGoogleDriveFileIdHidden','courseGoogleDriveFolderIdHidden',
             'courseGoogleDriveUrlManual','courseGoogleDriveFileIdManual','courseGoogleDriveFolderIdManual']
                .forEach(function(eid) { var el = document.getElementById(eid); if (el) el.value = ''; });
            document.getElementById('picker-selected-preview').style.display = 'none';
            document.getElementById('picker-btn-label').textContent = 'Chọn file / thư mục từ Google Drive';
        }

        function resetPickerBtn() {
            pickerTokenPending = false;
            var btn = document.getElementById('btn-open-picker');
            var spin = document.getElementById('picker-loading-spin');
            var lbl = document.getElementById('picker-btn-label');
            if (btn) btn.disabled = false;
            if (spin) spin.style.display = 'none';
            if (lbl && lbl.textContent.includes('xác thực')) lbl.textContent = 'Chọn file / thư mục từ Google Drive';
        }

        (function() {
            var ai = document.querySelector('input[name="action"][value="registerCourse"]');
            if (!ai) return;
            var form = ai.closest('form');
            if (!form) return;
            form.addEventListener('submit', function() {
                var md = document.getElementById('manual-drive-inputs');
                if (!md || md.style.display === 'none') return;
                [['courseGoogleDriveUrlManual','courseGoogleDriveUrlHidden'],
                 ['courseGoogleDriveFileIdManual','courseGoogleDriveFileIdHidden'],
                 ['courseGoogleDriveFolderIdManual','courseGoogleDriveFolderIdHidden']]
                    .forEach(function(pair) {
                        var s = document.getElementById(pair[0]);
                        var d = document.getElementById(pair[1]);
                        if (s && d && s.value) d.value = s.value;
                    });
            });
        })();

        window.addEventListener('load', function() {
            if (typeof gapi !== 'undefined') { onGapiLoad(); return; }
            var a = 0, t = setInterval(function() {
                a++;
                if (typeof gapi !== 'undefined') { clearInterval(t); onGapiLoad(); }
                else if (a > 50) clearInterval(t);
            }, 200);
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
