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
    <title>Hß╗ô s╞í giß║úng vi├¬n - HIPZI</title>
    <meta name="description" content="Quß║ún l├╜ th├┤ng tin t├ái khoß║ún, kho t├ái liß╗çu giß║úng dß║íy v├á hß╗ìc liß╗çu AI cß╗ºa giß║úng vi├¬n tr├¬n nß╗ün tß║úng HIPZI.">
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

        /* ===== CSS COLLAPSED SIDEBAR (THU Gß╗îN THANH B├èN) ===== */
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

        /* ===== HEADER Cß╗ªA TAB ===== */
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

        /* ===== THß╗Ç METRICS (DONEZO STYLE) ===== */
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

        /* ===== LAYOUT B├ÇN Cß╗£ ─ÉA Cß╗ÿT ===== */
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

        /* L╞»ß╗ÜI TH├öNG TIN PROFILE */
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

        /* ===== THß║║ PH├éN LOß║áI GIß║óNG VI├èN (PREMIUM SELECTION) ===== */
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
            content: '┬╣3';
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

        // Xß╗¡ l├╜ format ng├áy th├íng hiß╗ân thß╗ï thuß║ºn Viß╗çt
        String joinDate = "Ch╞░a cß║¡p nhß║¡t";
        if (user != null && user.getCreatedAt() != null) {
            joinDate = new SimpleDateFormat("dd/MM/yyyy").format(user.getCreatedAt());
        }

        // Tß║ío chuß╗ùi ng├áy hiß╗çn tß║íi trang trß╗ìng cho Header Strip
        String currentDateDisplay = new SimpleDateFormat("'H├┤m nay,' dd/MM/yyyy").format(new Date());

        // Lß║Ñy chß╗» c├íi ─æß║ºu l├ám Avatar dß╗▒ ph├▓ng
        String initials = "H";
        if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
            String[] parts = user.getDisplayName().trim().split("\\s+");
            initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
        }

        // Lß║Ñy danh s├ích th├┤ng b├ío hß╗ç thß╗æng
        List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");

        TeacherApplication teacherApplication = (TeacherApplication) request.getAttribute("teacherApplication");
        List<Classroom> teacherClassrooms = (List<Classroom>) request.getAttribute("teacherClassrooms");
        boolean teachingRegistrationSubmitted = teacherApplication != null || Boolean.TRUE.equals(session.getAttribute("teacherRegistrationSubmitted"));
        String teachingRegistrationStatus = teacherApplication != null ? teacherApplication.getStatus() : null;
        String teachingRegistrationStatusLabel = "─Éang chß╗¥ duyß╗çt";
        if ("approved".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "─É├ú duyß╗çt";
        } else if ("rejected".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Kh├┤ng ─æ╞░ß╗úc duyß╗çt";
        } else if ("needs_more_info".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Cß║ºn bß╗ò sung th├┤ng tin";
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



    <!-- ===== D├ÇN TRANG CH├ìNH THEO Bß╗É Cß╗ñC PREMIUM ─Éß╗ÆNG Bß╗ÿ DONEZO ===== -->
    <div class="app-dashboard-container">
        
        <!-- K├èNH SIDEBAR TR├üI (LEFT PANE) -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand-horizontal">
                <a href="${pageContext.request.contextPath}/index" class="brand-avatar-box" title="Trang chß╗º">
                    <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="Hipzi Logo">
                </a>
                <div class="brand-text-col">
                    <span class="brand-title">Hipzi</span>
                    <span class="brand-subtitle">Platform</span>
                </div>
                <button type="button" class="sidebar-toggle-btn" title="Thu gß╗ìn / Mß╗ƒ rß╗Öng" onclick="toggleSidebar()">
                    <svg class="icon-collapse" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M16 15l-3-3 3-3"/></svg>
                    <svg class="icon-expand" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="display: none;"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M13 9l3 3-3 3"/></svg>
                </button>
            </div>
            
            <div class="sidebar-section-label">Tß╗òng quan</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-profile" class="<%= ("tab-profile".equals(initialTeacherTab) || "tab-edit".equals(initialTeacherTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')" title="Hß╗ô s╞í c├í nh├ón">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/></svg>
                        <span>Hß╗ô s╞í c├í nh├ón</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-security" class="<%= "tab-security".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-security')" title="Bß║úo mß║¡t">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <span>Bß║úo mß║¡t</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-support" class="<%= "tab-support".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-support')" title="Hß╗ù trß╗ú giß║úng dß║íy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <span>Hß╗ù trß╗ú giß║úng dß║íy</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">Quß║ún l├╜ giß║úng dß║íy</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-teaching-registration" class="<%= "tab-teaching-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-teaching-registration')" title="─É─âng k├¡ giß║úng dß║íy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                        <span>─É─âng k├¡ giß║úng dß║íy</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-class-registration" class="<%= "tab-class-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-class-registration')" title="─É─âng k├¡ lß╗¢p hß╗ìc">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                        <span>─É─âng k├¡ lß╗¢p hß╗ìc</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-course-registration" class="<%= "tab-course-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-course-registration')" title="─É─âng kh├│a hß╗ìc">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                        <span>─É─âng kh├│a hß╗ìc</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-upload-material" class="<%= "tab-upload-material".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-upload-material')" title="─É─âng tß║úi t├ái liß╗çu">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        <span>─É─âng tß║úi t├ái liß╗çu</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">V├¡ tiß╗ün</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-balance-stats" class="<%= "tab-balance-stats".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-balance-stats')" title="Thß╗æng k├¬ sß╗æ d╞░">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3a2 2 0 0 0 0-4z"/><circle cx="18" cy="12" r="1"/></svg>
                        <span>Thß╗æng k├¬ sß╗æ d╞░</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-transaction-history" class="<%= "tab-transaction-history".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-transaction-history')" title="Lß╗ïch sß╗¡ giao dß╗ïch">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                        <span>Lß╗ïch sß╗¡ giao dß╗ïch</span>
                    </a>
                </li>
            </ul>

        </aside>

        <!-- K├èNH PHß║óI CH├ìNH -->
        <div class="dashboard-main-section">
            
            <!-- TOP BAR ─Éß╗ÆNG Bß╗ÿ DONEZO -->
            <div class="dashboard-top-bar">
                <div class="top-bar-search-wrapper">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" placeholder="T├¼m kiß║┐m t├íc vß╗Ñ...">

                </div>

                <div class="top-bar-right">
                    <!-- Toggle giao diß╗çn S├íng / Tß╗æi -->
                    <div class="nav-bell-trigger" title="Chuyß╗ân chß║┐ ─æß╗Ö s├íng/tß╗æi" onclick="alert('Chß╗⌐c n─âng chuyß╗ân ─æß╗òi giao diß╗çn s├íng/tß╗æi ─æang ─æ╞░ß╗úc ph├ít triß╗ân.')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
                    </div>

                    <!-- Notification dropdown fragment -->
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                    <!-- N├║t ─É─âng xuß║Ñt -->
                    <a href="${pageContext.request.contextPath}/logout" class="nav-bell-trigger" title="─É─âng xuß║Ñt" style="text-decoration: none;">
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
                            <span class="top-bar-user-name"><%= user != null ? user.getDisplayName() : "Giß║úng vi├¬n HIPZI" %></span>
                            <span class="top-bar-user-email"><%= user != null ? user.getEmail() : "info@hipzi.vn" %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- CHß╗¿A WORKSPACE TAB PANES -->
            <main class="dashboard-content-wrapper">

            <!-- Banner dß║úi m├áu trang tr├¡ ph├¡a tr├¬n c├╣ng (Top Accent Strip) -->


            <!-- Th├┤ng b├ío nhß║»c nhß╗ƒ Onboarding (Nß║┐u ─æ─âng k├╜ qua Google m├á ch╞░a chß╗ìn role) -->
            <% if (user != null && !user.isOnboardingCompleted()) { %>
            <div class="onboarding-banner" style="margin-top: -0.5rem;">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#92400e" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <p>Hß╗ô s╞í cß╗ºa bß║ín ─æang chß╗¥ ho├án tß║Ñt thiß║┐t lß║¡p vai tr├▓ hß╗ìc vi├¬n sß╗¡ dß╗Ñng nß╗ün tß║úng.</p>
                <a href="${pageContext.request.contextPath}/onboarding">Ho├án tß║Ñt ngay</a>
            </div>
            <% } %>

            <!-- ========================================== -->
            <!-- TAB 1: Hß╗Æ S╞á C├ü NH├éN Tß╗öNG QUAN             -->
            <!-- ========================================== -->
            <section id="tab-teaching-registration" class="tab-pane <%= "tab-teaching-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>─É─âng k├¡ giß║úng dß║íy</h1>
                        <p>Ho├án thiß╗çn hß╗ô s╞í n─âng lß╗▒c giß║úng dß║íy ─æß╗â ─æ╞░ß╗úc x├⌐t duyß╗çt hß╗ìc liß╗çu v├á giß║úng dß║íy.</p>
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
                                    <div style="font-weight:800; margin-bottom:0.25rem;">Hß╗ô s╞í ─æ─âng k├¡ giß║úng dß║íy ─æ├ú ─æ╞░ß╗úc gß╗¡i.</div>
                                    <div style="font-size:0.82rem; font-weight:800; margin-bottom:0.35rem; text-transform:uppercase; letter-spacing:0.4px;">Trß║íng th├íi: <%= teachingRegistrationStatusLabel %></div>
                                    <div style="font-size:0.9rem; line-height:1.55;">
                                        <% if (teacherApplication != null && teacherApplication.getReviewNote() != null && !teacherApplication.getReviewNote().trim().isEmpty()) { %>
                                            <%= teacherApplication.getReviewNote() %>
                                        <% } else { %>
                                            ─Éß╗Öi ng┼⌐ quß║ún trß╗ï sß║╜ kiß╗âm tra minh chß╗⌐ng v├á phß║ún hß╗ôi qua email. Bß║ín vß║½n c├│ thß╗â gß╗¡i lß║íi nß║┐u cß║ºn cß║¡p nhß║¡t th├┤ng tin.
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
                                        <span>Ph├ón loß║íi giß║úng vi├¬n</span>
                                    </div>
                                    <span style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">Bß║»t buß╗Öc</span>
                                </div>

                                <div style="padding:1.5rem;">
                                    <p class="teacher-type-helper-text">Vui l├▓ng chß╗ìn nh├│m giß║úng vi├¬n hiß╗çn tß║íi cß╗ºa bß║ín tr╞░ß╗¢c khi ─æiß╗ün th├┤ng tin.</p>
                                    <div class="teacher-type-grid">
                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="student_tutor" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nh├│m 1</span>
                                                <h3 class="teacher-type-title">Gia s╞░ sinh vi├¬n</h3>
                                                <p class="teacher-type-description">Ph├╣ hß╗úp vß╗¢i hß╗ìc vi├¬n cß║ºn ng╞░ß╗¥i h╞░ß╗¢ng dß║½n gß║ºn g┼⌐i, hß╗ù trß╗ú b├ái tß║¡p, ├┤n tß║¡p kiß║┐n thß╗⌐c nß╗ün tß║úng hoß║╖c hß╗ìc theo nh├│m nhß╗Å.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Sinh vi├¬n S╞░ phß║ím To├ín</li>
                                                    <li>Sinh vi├¬n C├┤ng nghß╗ç th├┤ng tin dß║íy lß║¡p tr├¼nh c╞í bß║ún</li>
                                                    <li>Sinh vi├¬n IELTS 7.5 dß║íy tiß║┐ng Anh</li>
                                                    <li>Sinh vi├¬n n─âm 3, n─âm 4 c├│ th├ánh t├¡ch hß╗ìc tß║¡p tß╗æt</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Tr╞░ß╗¥ng ─æang hß╗ìc, chuy├¬n ng├ánh, n─âm hß╗ìc hiß╗çn tß║íi</li>
                                                    <li>M├┤n c├│ thß╗â dß║íy</li>
                                                    <li>Thß║╗ sinh vi├¬n hoß║╖c minh chß╗⌐ng ─æang hß╗ìc</li>
                                                    <li>Th├ánh t├¡ch hoß║╖c chß╗⌐ng chß╗ë nß║┐u c├│</li>
                                                </ul>
                                            </div>
                                        </label>

                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="certified_pedagogy" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nh├│m 2</span>
                                                <h3 class="teacher-type-title">Giß║úng vi├¬n c├│ chß╗⌐ng chß╗ë s╞░ phß║ím</h3>
                                                <p class="teacher-type-description">Ph├╣ hß╗úp vß╗¢i hß╗ìc vi├¬n cß║ºn ng╞░ß╗¥i dß║íy c├│ nß╗ün tß║úng giß║úng dß║íy, ph╞░╞íng ph├íp truyß╗ün ─æß║ít r├╡ r├áng v├á tß║¡p trung v├áo mß╗Öt sß╗æ m├┤n cß╗Ñ thß╗â.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë nghiß╗çp vß╗Ñ s╞░ phß║ím</li>
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë dß║íy tiß║┐ng Anh</li>
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë ─æ├áo tß║ío kß╗╣ n─âng</li>
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë dß║íy tin hß╗ìc hoß║╖c lß║¡p tr├¼nh</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Chß╗⌐ng chß╗ë s╞░ phß║ím hoß║╖c chß╗⌐ng chß╗ë giß║úng dß║íy</li>
                                                    <li>M├┤n c├│ thß╗â dß║íy</li>
                                                    <li>Kinh nghiß╗çm dß║íy hß╗ìc nß║┐u c├│</li>
                                                    <li>Hß╗ô s╞í c├í nh├ón v├á minh chß╗⌐ng chuy├¬n m├┤n li├¬n quan</li>
                                                </ul>
                                            </div>
                                        </label>

                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="degree_specialist" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nh├│m 3</span>
                                                <h3 class="teacher-type-title">Giß║úng vi├¬n chuy├¬n m├┤n</h3>
                                                <p class="teacher-type-description">D├ánh cho giß║úng vi├¬n, gi├ío vi├¬n ─æ├ú tß╗æt nghiß╗çp, c├│ bß║▒ng cß║Ñp chuy├¬n m├┤n r├╡ r├áng hoß║╖c ─æang/─æ├ú l├ám viß╗çc trong l─⌐nh vß╗▒c giß║úng dß║íy.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Cß╗¡ nh├ón S╞░ phß║ím To├ín</li>
                                                    <li>Cß╗¡ nh├ón Ng├┤n ngß╗» Anh</li>
                                                    <li>Thß║íc s─⌐ ng├ánh Gi├ío dß╗Ñc</li>
                                                    <li>Gi├ío vi├¬n THCS/THPT, giß║úng vi├¬n ─æß║íi hß╗ìc hoß║╖c chuy├¬n gia ph├╣ hß╗úp</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Bß║▒ng ─æß║íi hß╗ìc, cao hß╗ìc hoß║╖c bß║▒ng chuy├¬n m├┤n</li>
                                                    <li>Chuy├¬n ng├ánh ─æ├áo tß║ío</li>
                                                    <li>Kinh nghiß╗çm giß║úng dß║íy</li>
                                                    <li>M├┤n phß╗Ñ tr├ích, n╞íi tß╗½ng/─æang c├┤ng t├íc nß║┐u c├│</li>
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
                                        <span>Th├┤ng tin x├íc minh</span>
                                    </div>
                                </div>

                                <div style="padding:1.5rem;">
                                    <div class="teacher-registration-form-grid">
                                        <div class="form-group-premium">
                                            <label>Tr╞░ß╗¥ng / ─æ╞ín vß╗ï ─æang hß╗ìc hoß║╖c c├┤ng t├íc</label>
                                            <input type="text" name="institutionName" placeholder="V├¡ dß╗Ñ: ─Éß║íi hß╗ìc S╞░ phß║ím TP.HCM, THPT Chuy├¬n L├¬ Hß╗ông Phong" required>
                                        </div>
                                        <div class="form-group-premium">
                                            <label>Chuy├¬n ng├ánh / l─⌐nh vß╗▒c chuy├¬n m├┤n</label>
                                            <input type="text" name="specialization" placeholder="V├¡ dß╗Ñ: S╞░ phß║ím To├ín, Ng├┤n ngß╗» Anh, C├┤ng nghß╗ç th├┤ng tin" required>
                                        </div>
                                        <div class="form-group-premium">
                                            <label>N─âm hß╗ìc hiß╗çn tß║íi</label>
                                            <select name="currentStudyYear">
                                                <option value="">Kh├┤ng ├íp dß╗Ñng</option>
                                                <option value="year_1">N─âm 1</option>
                                                <option value="year_2">N─âm 2</option>
                                                <option value="year_3">N─âm 3</option>
                                                <option value="year_4">N─âm 4</option>
                                                <option value="year_5_plus">N─âm 5 trß╗ƒ l├¬n</option>
                                                <option value="graduated">─É├ú tß╗æt nghiß╗çp</option>
                                            </select>
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>M├┤n c├│ thß╗â dß║íy (C├│ thß╗â chß╗ìn nhiß╗üu m├┤n)</label>
                                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 1rem; margin-top: 0.5rem; background: #f8fafc; padding: 1rem; border-radius: 0.75rem; border: 1px solid var(--border-dark);">
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="To├ín" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> To├ín hß╗ìc
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="V─ân" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Ngß╗» V─ân
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Anh" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Tiß║┐ng Anh
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="L├╜" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Vß║¡t L├╜
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="H├│a" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> H├│a Hß╗ìc
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Sinh Hß╗ìc" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Sinh Hß╗ìc
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Lß╗ïch Sß╗¡" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Lß╗ïch Sß╗¡
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="─Éß╗ïa L├╜" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> ─Éß╗ïa L├╜
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="C├┤ng Nghß╗ç" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> C├┤ng Nghß╗ç
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Tin Hß╗ìc" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Tin Hß╗ìc
                                                </label>
                                            </div>
                                        </div>
                                        <div class="form-group-premium">
                                            <label>Kinh nghiß╗çm giß║úng dß║íy</label>
                                            <input type="text" name="teachingExperience" placeholder="V├¡ dß╗Ñ: 2 n─âm dß║íy k├¿m To├ín THPT, trß╗ú giß║úng trung t├óm tiß║┐ng Anh">
                                        </div>
                                        <div class="form-group-premium">
                                            <label>N╞íi tß╗½ng/─æang c├┤ng t├íc</label>
                                            <input type="text" name="workplace" placeholder="─Éiß╗ün nß║┐u c├│">
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>Th├ánh t├¡ch, chß╗⌐ng chß╗ë hoß║╖c bß║▒ng cß║Ñp li├¬n quan</label>
                                            <textarea name="credentialsSummary" rows="3" placeholder="V├¡ dß╗Ñ: IELTS 7.5, giß║úi hß╗ìc sinh giß╗Åi, chß╗⌐ng chß╗ë nghiß╗çp vß╗Ñ s╞░ phß║ím, bß║▒ng cß╗¡ nh├ón..."></textarea>
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>Hß╗ô s╞í c├í nh├ón ngß║»n</label>
                                            <textarea name="teacherBio" rows="4" placeholder="Giß╗¢i thiß╗çu ph╞░╞íng ph├íp dß║íy, nh├│m hß╗ìc vi├¬n ph├╣ hß╗úp v├á ─æiß╗âm mß║ính chuy├¬n m├┤n cß╗ºa bß║ín." required></textarea>
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>Minh chß╗⌐ng x├íc minh</label>
                                            <div class="teacher-evidence-box">
                                                <input type="file" name="evidenceFiles" multiple accept=".pdf,.png,.jpg,.jpeg,.webp,.doc,.docx">
                                                <p style="font-size:0.8rem; color:var(--text-muted); margin:0.75rem 0 0 0;">C├│ thß╗â ─æ├¡nh k├¿m thß║╗ sinh vi├¬n, chß╗⌐ng chß╗ë, bß║▒ng cß║Ñp, bß║úng ─æiß╗âm hoß║╖c giß║Ñy x├íc nhß║¡n c├┤ng t├íc. Mß╗ùi file tß╗æi ─æa 5MB.</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions-row-premium">
                                <button type="submit" class="btn-premium primary">
                                    <span>Gß╗¡i hß╗ô s╞í ─æ─âng k├¡</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4 20-7z"/></svg>
                                </button>
                            </div>
                        </form>
                    </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: ─É─éNG K├ì Lß╗ÜP Hß╗îC                       -->
            <!-- ========================================== -->
            <section id="tab-class-registration" class="tab-pane <%= "tab-class-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>─É─âng k├¡ lß╗¢p hß╗ìc</h1>
                        <p>Quß║ún l├╜ danh s├ích lß╗¢p hß╗ìc v├á ─æ─âng k├╜ mß╗ƒ lß╗¢p mß╗¢i cho hß╗ìc vi├¬n.</p>
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
                            Danh s├ích lß╗¢p hß╗ìc ─æ├ú ─æ─âng k├¡
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
                                                <span style="font-size: 0.8rem; font-weight: 700; color: var(--primary); border: 1px solid var(--primary); background: var(--primary-light); padding: 0.25rem 0.5rem; border-radius: 0.4rem;">M├ú lß╗¢p: <%= cls.getClassCode() %></span>
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
                                        <button type="button" class="btn-premium secondary" style="padding: 0.4rem 0.75rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;" onclick="document.getElementById('edit-class-<%= cls.getId() %>').style.display = 'flex'" title="Chß╗ënh sß╗¡a lß╗¢p hß╗ìc">
                                            <span>Chß╗ënh sß╗¡a</span>
                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
                                        </button>
                                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" onsubmit="return confirm('Bß║ín chß║»c chß║»n muß╗æn x├│a lß╗¢p hß╗ìc n├áy?');" style="margin: 0; display: inline;">
                                            <input type="hidden" name="action" value="deleteClass">
                                            <input type="hidden" name="classId" value="<%= cls.getId() %>">
                                            <button type="submit" class="btn-premium danger" style="padding: 0.4rem 0.75rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem; background: #fee2e2; border-color: #fca5a5; color: #dc2626;" title="X├│a lß╗¢p hß╗ìc">
                                                <span>X├│a</span>
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                            </button>
                                        </form>
                                    </div>
                                </div>

                                <!-- MODAL CHß╗êNH Sß╗¼A Lß╗ÜP Hß╗îC -->
                                <div id="edit-class-<%= cls.getId() %>" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.4); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
                                    <div style="background: var(--surface); width: 90%; max-width: 600px; border-radius: 1.5rem; padding: 2rem; box-shadow: var(--shadow-lg); position: relative; max-height: 90vh; overflow-y: auto;">
                                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" class="form-edit-layout" style="padding: 0;">
                                            <input type="hidden" name="action" value="updateClass">
                                            <input type="hidden" name="classId" value="<%= cls.getId() %>">
                                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; border-bottom: 1px solid var(--border-dark); padding-bottom: 0.75rem;">
                                                <h3 style="margin: 0; font-size: 1.25rem; font-weight: 800; color: var(--text-main);">Chß╗ënh sß╗¡a lß╗¢p hß╗ìc</h3>
                                                <div style="display: flex; gap: 0.5rem;">
                                                    <button type="button" onclick="document.getElementById('edit-class-<%= cls.getId() %>').style.display='none'" class="btn-premium secondary" style="padding: 0.5rem 1rem;">Hß╗ºy</button>
                                                    <button type="submit" class="btn-premium primary" style="padding: 0.5rem 1rem;">L╞░u thay ─æß╗òi</button>
                                                </div>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 1rem;">
                                                <div class="form-group-premium" style="margin: 0;">
                                                    <label>T├¬n lß╗¢p hß╗ìc</label>
                                                    <input type="text" name="className" value="<%= cls.getTitle() %>" required>
                                                </div>
                                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                                    <div class="form-group-premium" style="margin: 0;">
                                                        <label>M├┤n hß╗ìc</label>
                                                        <select name="classSubject" required>
                                                            <% for (String subject : registeredSubjects) { %>
                                                                <option value="<%= subject %>" <%= subject.equalsIgnoreCase(cls.getSubject()) ? "selected" : "" %>><%= subject %></option>
                                                            <% } %>
                                                        </select>
                                                    </div>
                                                    <div class="form-group-premium" style="margin: 0;">
                                                        <label>Khß╗æi lß╗¢p</label>
                                                        <select name="classGrade" required>
                                                            <option value="Lß╗¢p 10" <%= "Lß╗¢p 10".equals(cls.getGrade()) ? "selected" : "" %>>Lß╗¢p 10</option>
                                                            <option value="Lß╗¢p 11" <%= "Lß╗¢p 11".equals(cls.getGrade()) ? "selected" : "" %>>Lß╗¢p 11</option>
                                                            <option value="Lß╗¢p 12" <%= "Lß╗¢p 12".equals(cls.getGrade()) ? "selected" : "" %>>Lß╗¢p 12</option>
                                                            <option value="├ön thi THPT" <%= "├ön thi THPT".equals(cls.getGrade()) ? "selected" : "" %>>├ön thi THPT</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                                                    <div class="form-group-premium" style="margin: 0;">
                                                        <label>Trß║íng th├íi</label>
                                                        <select name="classStatus">
                                                            <option value="open" <%= "open".equals(cls.getStatus()) || "─Éang mß╗ƒ".equals(cls.getStatus()) ? "selected" : "" %>>─Éang mß╗ƒ</option>
                                                            <option value="upcoming" <%= "upcoming".equals(cls.getStatus()) || "Sß║»p khai giß║úng".equals(cls.getStatus()) ? "selected" : "" %>>Sß║»p khai giß║úng</option>
                                                            <option value="closed" <%= "closed".equals(cls.getStatus()) ? "selected" : "" %>>─É├ú ─æ├│ng</option>
                                                        </select>
                                                    </div>
                                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem;">
                                                        <div class="form-group-premium" style="margin: 0;">
                                                            <label>Giß╗¥ bß║»t ─æß║ºu</label>
                                                            <input type="text" name="startTime" class="class-time-input" value="<%= startValue %>" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhß║¡p giß╗¥ dß║íng HH:mm, tß╗½ 00:00 ─æß║┐n 24:00" required>
                                                        </div>
                                                        <div class="form-group-premium" style="margin: 0;">
                                                            <label>Giß╗¥ kß║┐t th├║c</label>
                                                            <input type="text" name="endTime" class="class-time-input" value="<%= endValue %>" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhß║¡p giß╗¥ dß║íng HH:mm, tß╗½ 00:00 ─æß║┐n 24:00" required>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group-premium" style="margin: 0;">
                                                    <label>Thß╗⌐ hß╗ìc</label>
                                                    <div class="class-day-options">
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 2" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thß╗⌐ 2") ? "checked" : "" %>> Thß╗⌐ 2</label>
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 3" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thß╗⌐ 3") ? "checked" : "" %>> Thß╗⌐ 3</label>
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 4" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thß╗⌐ 4") ? "checked" : "" %>> Thß╗⌐ 4</label>
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 5" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thß╗⌐ 5") ? "checked" : "" %>> Thß╗⌐ 5</label>
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 6" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thß╗⌐ 6") ? "checked" : "" %>> Thß╗⌐ 6</label>
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 7" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Thß╗⌐ 7") ? "checked" : "" %>> Thß╗⌐ 7</label>
                                                        <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Chß╗º nhß║¡t" <%= cls.getScheduleDays() != null && cls.getScheduleDays().contains("Chß╗º nhß║¡t") ? "checked" : "" %>> Chß╗º nhß║¡t</label>
                                                    </div>
                                                </div>
                                                <div class="form-group-premium" style="margin: 0;">
                                                    <label>M├┤ tß║ú ngß║»n</label>
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
                            <p style="margin: 0; color: var(--text-muted); font-weight: 700;">Bß║ín ch╞░a ─æ─âng k├¡ lß╗¢p hß╗ìc n├áo.</p>
                        </div>
                    <% } %>
                </div>

                <div class="premium-card" style="margin-top: 1.5rem;">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                            Tß║ío lß╗¢p hß╗ìc mß╗¢i
                        </span>
                    </div>
                    <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1.5rem;">
                        L╞░u ├╜: Bß║ín chß╗ë ─æ╞░ß╗úc ph├⌐p mß╗ƒ lß╗¢p dß║íy cho c├íc m├┤n hß╗ìc ─æ├ú ─æ╞░ß╗úc hß╗ç thß╗æng ph├¬ duyß╗çt trong hß╗ô s╞í n─âng lß╗▒c cß╗ºa m├¼nh.
                    </p>

                    <% if (registeredSubjects.length > 0) { %>
                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" class="form-edit-layout" style="padding: 0;">
                            <input type="hidden" name="action" value="registerClass">
                            
                            <div class="form-group-premium" style="margin-bottom: 1.25rem;">
                                <label>T├¬n lß╗¢p hß╗ìc</label>
                                <input type="text" name="className" placeholder="V├¡ dß╗Ñ: Lß╗¢p To├ín 10A, Tiß║┐ng Anh giao tiß║┐p..." required>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
                                <div class="form-group-premium" style="margin: 0;">
                                    <label>Chß╗ìn m├┤n hß╗ìc</label>
                                    <select name="classSubject" required>
                                        <option value="" disabled selected>-- Chß╗ìn m├┤n hß╗ìc --</option>
                                        <% for (String subject : registeredSubjects) { %>
                                            <option value="<%= subject %>"><%= subject %></option>
                                        <% } %>
                                    </select>
                                </div>

                                <div class="form-group-premium" style="margin: 0;">
                                    <label>Khß╗æi lß╗¢p</label>
                                    <select name="classGrade" required>
                                        <option value="" disabled selected>-- Chß╗ìn khß╗æi lß╗¢p --</option>
                                        <option value="Lß╗¢p 10">Lß╗¢p 10</option>
                                        <option value="Lß╗¢p 11">Lß╗¢p 11</option>
                                        <option value="Lß╗¢p 12">Lß╗¢p 12</option>
                                        <option value="├ön thi THPT">├ön thi THPT</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group-premium" style="margin-bottom: 1.25rem;">
                                <label>Thß╗⌐ hß╗ìc</label>
                                <div class="class-day-options">
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 2"> Thß╗⌐ 2</label>
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 3"> Thß╗⌐ 3</label>
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 4"> Thß╗⌐ 4</label>
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 5"> Thß╗⌐ 5</label>
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 6"> Thß╗⌐ 6</label>
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Thß╗⌐ 7"> Thß╗⌐ 7</label>
                                    <label class="class-day-option"><input type="checkbox" name="scheduleDays" value="Chß╗º nhß║¡t"> Chß╗º nhß║¡t</label>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.25rem;">
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin: 0;">
                                    <div class="form-group-premium" style="margin: 0;">
                                        <label>Giß╗¥ bß║»t ─æß║ºu</label>
                                        <input type="text" name="startTime" class="class-time-input" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhß║¡p giß╗¥ dß║íng HH:mm, tß╗½ 00:00 ─æß║┐n 24:00" required>
                                    </div>
                                    <div class="form-group-premium" style="margin: 0;">
                                        <label>Giß╗¥ kß║┐t th├║c</label>
                                        <input type="text" name="endTime" class="class-time-input" placeholder="HH:mm" inputmode="numeric" maxlength="5" pattern="^(([01][0-9]|2[0-3]):[0-5][0-9]|24:00)$" title="Nhß║¡p giß╗¥ dß║íng HH:mm, tß╗½ 00:00 ─æß║┐n 24:00" required>
                                    </div>
                                </div>

                                <div class="form-group-premium" style="margin: 0;">
                                    <label>Trß║íng th├íi</label>
                                    <select name="classStatus">
                                        <option value="open">─Éang mß╗ƒ</option>
                                        <option value="upcoming">Sß║»p khai giß║úng</option>
                                        <option value="closed">─É├ú ─æ├│ng</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="form-group-premium" style="margin-bottom: 1.25rem;">
                                <label>M├┤ tß║ú ngß║»n</label>
                                <textarea name="classDescription" rows="3" placeholder="Nhß║¡p m├┤ tß║ú vß║»n tß║»t vß╗ü lß╗¢p hß╗ìc n├áy..."></textarea>
                            </div>

                            <div class="form-actions-row-premium">
                                <button type="submit" class="btn-premium primary" style="padding: 0.75rem 1.5rem;">─É─âng k├¡ lß╗¢p hß╗ìc</button>
                            </div>
                        </form>
                    <% } else { %>
                        <div class="empty-status-panel" style="padding: 2.25rem 1.5rem; text-align: center; border: 1px dashed var(--border-dark); border-radius: 1rem; margin-top: 1rem;">
                            <p style="margin: 0; color: var(--text-muted); font-weight: 700;">Bß║ín ch╞░a c├│ m├┤n hß╗ìc n├áo ─æ╞░ß╗úc ph├¬ duyß╗çt ─æß╗â mß╗ƒ lß╗¢p.</p>
                        </div>
                    <% } %>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 1: Hß╗Æ S╞á C├ü NH├éN Tß╗öNG QUAN             -->
            <!-- ========================================== -->
            <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hß╗ô s╞í c├í nh├ón</h1>
                        <p>Xem v├á quß║ún l├╜ th├┤ng tin t├ái khoß║ún giß║úng vi├¬n cß╗ºa bß║ín tr├¬n HIPZI.</p>
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
                            <span class="metric-card-title">Lß╗¢p ─æang dß║íy</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= teacherClassrooms != null ? teacherClassrooms.size() : 0 %></div>
                            <span class="metric-card-sub">Lß╗¢p hoß║ít ─æß╗Öng</span>
                        </div>
                    </div>

                    <!-- Metric 2: Application status -->
                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Trß║íng th├íi hß╗ô s╞í</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value" style="font-size: 1.45rem; margin-top: 1.25rem;"><%= teachingRegistrationStatusLabel %></div>
                            <span class="metric-card-sub" style="background:#eff6ff; color:#2563eb;">Giß║úng vi├¬n</span>
                        </div>
                    </div>

                    <!-- Metric 3: Active courses -->
                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Kh├│a hß╗ìc cß╗ºa t├┤i</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value">1</div>
                            <span class="metric-card-sub" style="background:#f5f3ff; color:#7c3aed;">─Éang ph├ít h├ánh</span>
                        </div>
                    </div>

                    <!-- Metric 4: System notifications -->
                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Th├┤ng b├ío</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= notifications != null ? notifications.size() : 0 %></div>
                            <span class="metric-card-sub" style="background:#fff7ed; color:#ea580c;">Tin nhß║»n mß╗¢i</span>
                        </div>
                    </div>
                </div>

                <!-- MAIN GRID LAYOUT -->
                <div class="dashboard-grid-layout">
                    <!-- Cß╗Öt Tr├íi: Th├┤ng tin c├í nh├ón -->
                    <div class="premium-card">
                        <div class="premium-card-header">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                Th├┤ng tin c├í nh├ón
                            </span>
                            <button onclick="switchTab('tab-edit')" class="btn-premium secondary" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                                <span>Chß╗ënh sß╗¡a</span>
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </button>
                        </div>

                        <!-- L╞░ß╗¢i chi tiß║┐t th├┤ng tin -->
                        <div class="profile-info-grid">
                            <div class="profile-info-item">
                                <div class="info-icon-circle primary">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                </div>
                                <div class="info-content">
                                    <span class="info-label">Hß╗ì v├á t├¬n hiß╗ân thß╗ï</span>
                                    <span class="info-value"><%= user != null ? user.getDisplayName() : "ΓÇö" %></span>
                                </div>
                            </div>

                            <div class="profile-info-item">
                                <div class="info-icon-circle accent">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                </div>
                                <div class="info-content">
                                    <span class="info-label">Ng├áy tham gia</span>
                                    <span class="info-value"><%= joinDate %></span>
                                </div>
                            </div>

                            <div class="profile-info-item">
                                <div class="info-icon-circle warning">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                </div>
                                <div class="info-content" style="min-width: 0;">
                                    <span class="info-label">─Éß╗ïa chß╗ë Email</span>
                                    <span class="info-value" style="font-size:0.95rem;" title="<%= user != null ? user.getEmail() : "" %>"><%= user != null ? user.getEmail() : "ΓÇö" %></span>
                                </div>
                            </div>

                            <div class="profile-info-item">
                                <div class="info-icon-circle danger">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                </div>
                                <div class="info-content">
                                    <span class="info-label">Trß║íng th├íi t├ái khoß║ún</span>
                                    <% String statusVal = (user != null) ? user.getAccountStatus() : "active"; %>
                                    <span class="acc-status-tag <%= statusVal %>">
                                        <%= "active".equals(statusVal) ? "─Éang hoß║ít ─æß╗Öng" : "suspended".equals(statusVal) ? "Tß║ím kh├│a" : "V├┤ hiß╗çu h├│a" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Cß╗Öt Phß║úi: Danh s├ích lß╗¢p hß╗ìc -->
                    <div class="premium-card">
                        <div class="premium-card-header">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                Lß╗¢p hß╗ìc cß╗ºa t├┤i
                            </span>
                            <button onclick="switchTab('tab-class-registration')" class="btn-premium secondary" style="padding: 0.4rem 0.85rem; font-size: 0.8rem;">Xem tß║Ñt cß║ú</button>
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
                                    <span class="status-badge <%= cls.getStatus() %>"><%= "open".equals(cls.getStatus()) ? "─Éang mß╗ƒ" : "closed".equals(cls.getStatus()) ? "─É├ú ─æ├│ng" : "Sß║»p mß╗ƒ" %></span>
                                </div>
                            <% } } else { %>
                                <div style="text-align: center; color: var(--text-muted); font-size: 0.9rem; padding: 1.5rem 0;">
                                    Ch╞░a ─æ─âng k├¡ lß╗¢p hß╗ìc n├áo.
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>
<!-- ========================================== -->
            <!-- TAB 2: CHß╗êNH Sß╗¼A Hß╗Æ S╞á                     -->
            <!-- ========================================== -->
            <section id="tab-edit" class="tab-pane <%= "tab-edit".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Cß║¡p nhß║¡t th├┤ng tin</h1>
                        <p>Thay ─æß╗òi th├┤ng tin c├í nh├ón hiß╗ân thß╗ï cß╗ºa giß║úng vi├¬n tr├¬n hß╗ç thß╗æng.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <button onclick="switchTab('tab-profile')" class="btn-premium secondary" style="padding: 0.5rem 1rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                            <span>Quay lß║íi</span>
                        </button>
                    </div>
                </div>

                <div class="premium-card">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            Th├┤ng tin hiß╗ân thß╗ï
                        </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="form-edit-layout" style="padding: 0;">
                        <input type="hidden" name="action" value="updateName">
                        <div class="form-group-premium" style="margin-bottom: 1.5rem;">
                            <label>Hß╗ì v├á t├¬n hiß╗ân thß╗ï</label>
                            <input type="text" name="displayName" required value="<%= user != null ? user.getDisplayName() : "" %>" placeholder="Nhß║¡p hß╗ì v├á t├¬n cß╗ºa bß║ín...">
                        </div>

                        <div class="form-actions-row-premium">
                            <button type="button" class="btn-premium secondary" onclick="switchTab('tab-profile')">Hß╗ºy bß╗Å</button>
                            <button type="submit" class="btn-premium primary">L╞░u thay ─æß╗òi</button>
                        </div>
                    </form>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 3: Bß║óO Mß║¼T V├Ç Mß║¼T KHß║¿U                 -->
            <!-- ========================================== -->
            <section id="tab-security" class="tab-pane <%= "tab-security".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Bß║úo mß║¡t t├ái khoß║ún</h1>
                        <p>Quß║ún l├╜ mß║¡t khß║⌐u ─æ─âng nhß║¡p, bß║úo mß║¡t hai lß╗¢p v├á phi├¬n ─æ─âng nhß║¡p.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <!-- KHUNG CH├ìNH TOP: Mß║¼T KHß║¿U ─É─éNG NHß║¼P -->
                <div class="premium-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1.25rem;">
                        <div>
                            <span style="font-weight: 800; font-size: 1.15rem; color: #b45309; letter-spacing: 0.5px; text-transform: uppercase; display: block;">Mß║¡t khß║⌐u ─æ─âng nhß║¡p</span>
                            <p style="font-size: 0.85rem; color: var(--text-muted); margin: 0.35rem 0 0 0;">Cß║¡p nhß║¡t mß║¡t khß║⌐u ─æß╗ïnh kß╗│ ─æß╗â bß║úo mß║¡t tß╗æt h╞ín.</p>
                        </div>
                        <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='flex';" class="btn-premium primary" style="background: #059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">
                            <span>─Éß╗òi mß║¡t khß║⌐u</span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                    </div>

                    <div style="padding: 1rem 0 0 0; border-top: 1px solid var(--border-light); display: flex; align-items: center; gap: 1.5rem; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: 0.4rem; color: #10b981; font-weight: 700; font-size: 0.85rem;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            <span>Mß║¡t khß║⌐u mß║ính</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 0.4rem; color: <%= (user != null && user.isTwoFactorEnabled()) ? "#10b981" : "var(--text-muted)" %>; font-weight: 700; font-size: 0.85rem;">
                            <% if (user != null && user.isTwoFactorEnabled()) { %>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                <span>X├íc thß╗▒c 2 lß╗¢p: ─Éang bß║¡t</span>
                            <% } else { %>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                                <span>X├íc thß╗▒c 2 lß╗¢p: Tß║»t</span>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- L╞»ß╗ÜI HAI KHUNG CON B├èN D╞»ß╗ÜI -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-top: 1.5rem;">
                    
                    <!-- KHUNG TR├üI: Bß║óO Mß║¼T 2 Lß╗ÜP (OTP) -->
                    <div class="premium-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                            <span style="font-weight: 800; font-size: 0.9rem; color: var(--text-main); text-transform: uppercase; letter-spacing: 0.5px;">Bß║úo mß║¡t 2 lß╗¢p (OTP)</span>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-weight: 700; font-size: 0.95rem; color: var(--text-main);">M├ú OTP qua Email</span>
                            
                            <!-- Form ngß║ºm xß╗¡ l├╜ toggle 2FA -->
                            <form id="toggle2faForm" action="${pageContext.request.contextPath}/profile" method="POST" style="display: none;">
                                <input type="hidden" name="action" value="toggle2FA">
                            </form>

                            <!-- N├ÜT TOGGLE SWITCH THß╗░C Tß║╛ -->
                            <% boolean is2fa = (user != null && user.isTwoFactorEnabled()); %>
                            <div id="otp-toggle-btn" onclick="document.getElementById('toggle2faForm').submit();" style="width: 44px; height: 24px; background: <%= is2fa ? "#10b981" : "#cbd5e1" %>; border-radius: 12px; padding: 2px; cursor: pointer; transition: background 0.3s ease; display: flex; align-items: center;">
                                <div class="toggle-circle" style="width: 20px; height: 20px; background: #ffffff; border-radius: 50%; box-shadow: 0 1px 3px rgba(0,0,0,0.2); transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform: translateX(<%= is2fa ? "20px" : "0" %>);"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KHUNG PHß║óI: THIß║╛T Bß╗è HIß╗åN Tß║áI -->
                    <div class="premium-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                            <span style="font-weight: 800; font-size: 0.9rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px;">Thiß║┐t bß╗ï hiß╗çn tß║íi</span>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                        </div>
                        <div>
                            <span style="font-weight: 800; font-size: 1.1rem; color: var(--text-main); display: block;">Windows - Chrome (Vietnam)</span>
                            <span style="font-size: 0.75rem; color: #10b981; font-weight: 600; display: inline-block; margin-top: 0.25rem; background: #ecfdf5; padding: 0.15rem 0.5rem; border-radius: 0.25rem;">Phi├¬n truy cß║¡p an to├án</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: ─É─éNG KH├ôA Hß╗îC                         -->
            <!-- ========================================== -->
            <section id="tab-course-registration" class="tab-pane <%= "tab-course-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>─É─âng kh├│a hß╗ìc</h1>
                        <p>Tß║ío v├á li├¬n kß║┐t nß╗Öi dung b├ái giß║úng, kh├│a hß╗ìc tß╗½ Google Drive l├¬n HIPZI.</p>
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
                            Tß║ío kh├│a hß╗ìc mß╗¢i
                        </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;" class="form-edit-layout">
                        <input type="hidden" name="action" value="registerCourse">

                        <div class="form-group-premium" style="grid-column: 1 / -1;">
                            <label>T├¬n kh├│a hß╗ìc <span style="color:#ef4444;">*</span></label>
                            <input type="text" name="courseTitle" placeholder="V├¡ dß╗Ñ: Kh├│a hß╗ìc Tiß║┐ng Anh Giao Tiß║┐p C╞í Bß║ún..." required>
                        </div>

                        <div class="form-group-premium">
                            <label>M├┤n hß╗ìc <span style="color:#ef4444;">*</span></label>
                            <select name="courseSubject" required>
                                <option value="" disabled selected>-- Chß╗ìn m├┤n hß╗ìc --</option>
                                <% for (String subject : registeredSubjects) { %>
                                    <option value="<%= subject %>"><%= subject %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group-premium">
                            <label>Khß╗æi lß╗¢p / Cß║Ñp ─æß╗Ö <span style="color:#ef4444;">*</span></label>
                            <input type="text" name="courseGrade" placeholder="V├¡ dß╗Ñ: Lß╗¢p 10, IELTS, TOEIC..." required>
                        </div>

                        <div class="form-group-premium">
                            <label>Gi├í tiß╗ün (VND) <span style="color:#ef4444;">*</span></label>
                            <input type="number" name="coursePriceAmount" placeholder="V├¡ dß╗Ñ: 500000 (Nhß║¡p 0 nß║┐u miß╗àn ph├¡)" value="0" min="0" step="1000" required>
                        </div>

                        <div class="form-group-premium">
                            <label>Sß╗æ b├ái hß╗ìc <span style="color:#ef4444;">*</span></label>
                            <input type="number" name="courseLessonsCount" placeholder="V├¡ dß╗Ñ: 12" value="1" min="1" required>
                        </div>

                        <div class="form-group-premium">
                            <label>Thß╗¥i l╞░ß╗úng dß╗▒ kiß║┐n (Giß╗¥)</label>
                            <input type="number" name="courseEstimatedHours" placeholder="V├¡ dß╗Ñ: 20.5" value="0" min="0" step="0.5">
                        </div>

                        <div class="form-group-premium">
                            <label>Tr├¼nh ─æß╗Ö y├¬u cß║ºu</label>
                            <input type="text" name="courseLevel" placeholder="V├¡ dß╗Ñ: C╞í bß║ún, Trung b├¼nh, N├óng cao...">
                        </div>

                        <div class="form-group-premium" style="grid-column: 1 / -1;">
                            <label>ß║ónh b├¼a kh├│a hß╗ìc</label>
                            <input type="file" name="courseThumbnailFile" accept="image/*">
                        </div>

                        <div class="form-group-premium" style="grid-column: 1 / -1;">
                            <label>M├┤ tß║ú ngß║»n kh├│a hß╗ìc <span style="color:#ef4444;">*</span></label>
                            <textarea name="courseDescription" rows="3" placeholder="Nhß║¡p m├┤ tß║ú vß╗ü kh├│a hß╗ìc n├áy..." required></textarea>
                        </div>

                        <!-- ===== GOOGLE PICKER SECTION ===== -->
                        <div class="form-group-premium" id="picker-section" style="grid-column: 1 / -1;">
                            <label>Nß╗Öi dung kh├│a hß╗ìc tr├¬n Google Drive <span style="color:#ef4444;">*</span></label>
                            
                            <% Object teacherGoogleAccount = request.getAttribute("teacherGoogleAccount");
                               if (teacherGoogleAccount == null) { %>
                                <div style="background:#fff1f2; border:1px solid #fecdd3; border-radius:0.85rem; padding:1.25rem; display:flex; align-items:center; justify-content:space-between; gap:1rem; flex-wrap:wrap;">
                                    <div style="display:flex; align-items:center; gap:1rem;">
                                        <div style="width:40px; height:40px; border-radius:50%; background:#ffe4e6; color:#e11d48; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                        </div>
                                        <div>
                                            <strong style="display:block; color:#be123c; font-size:0.95rem; margin-bottom:0.2rem;">Ch╞░a kß║┐t nß╗æi Google Drive</strong>
                                            <span style="color:#e11d48; font-size:0.85rem;">Bß║ín cß║ºn kß║┐t nß╗æi t├ái khoß║ún Google Drive ─æß╗â c├│ thß╗â chß╗ìn file kh├│a hß╗ìc.</span>
                                        </div>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/teacher-drive/connect" class="btn-premium primary" style="background:#e11d48; box-shadow:none; text-decoration:none;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                                        <span>Kß║┐t nß╗æi Drive</span>
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
                                    <span id="picker-btn-label">Chß╗ìn file / th╞░ mß╗Ñc tß╗½ Google Drive</span>
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
                                    <div id="picker-resource-name" style="font-weight:700; color:#0f172a; font-size:0.9rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">ΓÇö</div>
                                    <div id="picker-resource-url" style="font-size:0.78rem; color:#047857; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">ΓÇö</div>
                                </div>
                                <button type="button" onclick="clearPickerSelection()" title="X├│a lß╗▒a chß╗ìn"
                                    style="width:30px; height:30px; border-radius:50%; border:none; background:#fee2e2; color:#dc2626; font-size:1rem; cursor:pointer; display:flex; align-items:center; justify-content:center; flex-shrink:0;">&times;</button>
                            </div>

                            <button type="button" id="btn-show-manual-input"
                                onclick="document.getElementById('manual-drive-inputs').style.display='grid'; this.style.display='none';"
                                style="display:inline-flex; align-items:center; gap:0.4rem; background:none; border:none;
                                       color:#64748b; font-size:0.8rem; font-weight:600; cursor:pointer; margin-top:0.4rem;
                                       padding:0; text-decoration:underline; text-underline-offset:2px; font-family:inherit;">
                                Nhß║¡p thß╗º c├┤ng URL hoß║╖c ID nß║┐u Picker kh├┤ng hoß║ít ─æß╗Öng
                            </button>

                            <div id="manual-drive-inputs" style="display:none; grid-template-columns:1fr 1fr; gap:0.75rem; margin-top:0.75rem;">
                                <div style="grid-column:1/-1; display:flex; flex-direction:column; gap:0.35rem;">
                                    <label style="font-size:0.8rem; font-weight:600; color:#64748b;">URL Google Drive</label>
                                    <input type="url" id="courseGoogleDriveUrlManual" name="courseGoogleDriveUrl" placeholder="https://drive.google.com/..."
                                        style="padding:0.7rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.9rem; outline:none; font-family:inherit;">
                                </div>
                                <div style="display:flex; flex-direction:column; gap:0.35rem;">
                                    <label style="font-size:0.8rem; font-weight:600; color:#64748b;">File ID (nß║┐u l├á file ─æ╞ín lß║╗)</label>
                                    <input type="text" id="courseGoogleDriveFileIdManual" name="courseGoogleDriveFileId" placeholder="1aBcDeFgHiJkLm..."
                                        style="padding:0.7rem 1rem; border-radius:0.75rem; border:1px solid #cbd5e1; font-size:0.9rem; outline:none; font-family:inherit;">
                                </div>
                                <div style="display:flex; flex-direction:column; gap:0.35rem;">
                                    <label style="font-size:0.8rem; font-weight:600; color:#64748b;">Folder ID (nß║┐u l├á th╞░ mß╗Ñc)</label>
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
                            <button type="submit" class="btn-premium primary" style="width: 100%;">─É─âng kh├│a hß╗ìc</button>
                        </div>
                    </form>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 4: ─É─éNG Tß║óI T├ÇI LIß╗åU                   -->
            <!-- ========================================== -->
            <section id="tab-upload-material" class="tab-pane <%= "tab-upload-material".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>─É─âng tß║úi t├ái liß╗çu</h1>
                        <p>─É├│ng g├│p t├ái liß╗çu hß╗ìc tß║¡p hß╗»u ├¡ch v├áo kho t├ái nguy├¬n gi├ío dß╗Ñc HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <a href="${pageContext.request.contextPath}/material-repository" class="btn-premium secondary" style="text-decoration: none; display: inline-flex; align-items: center; gap: 0.25rem;">
                            <span>─Éß║┐n kho t├ái liß╗çu</span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
                        </a>
                    </div>
                </div>

                <div class="premium-card">
                    <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            ─É├│ng g├│p t├ái liß╗çu
                        </span>
                    </div>

                    <div style="display: grid; grid-template-columns: 1.1fr 0.9fr; gap: 1.5rem;">
                        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 1rem; padding: 1.5rem; display: flex; flex-direction: column; gap: 1rem;">
                            <div style="width: 48px; height: 48px; border-radius: 0.75rem; background: var(--primary-light); color: var(--primary); display: flex; align-items: center; justify-content: center;">
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                            </div>
                            <div>
                                <h3 style="margin: 0 0 0.5rem 0; color: var(--text-main); font-size: 1.15rem; font-weight: 800;">T├ái liß╗çu cß╗ºa bß║ín sß║╜ xuß║Ñt hiß╗çn trong kho t├ái liß╗çu</h3>
                                <p style="margin: 0; color: var(--text-muted); line-height: 1.6; font-size: 0.88rem;">Khi giß║úng vi├¬n ─æ─âng tß║úi b├ái giß║úng, ─æß╗ü luyß╗çn tß║¡p, gi├ío ├ín hoß║╖c bß╗Ö t├ái nguy├¬n hß╗ìc tß║¡p chß║Ñt l╞░ß╗úng, t├ái liß╗çu sß║╜ ─æ╞░ß╗úc ─æ╞░a v├áo kho t├ái liß╗çu ─æß╗â hß╗ìc vi├¬n dß╗à t├¼m kiß║┐m, xem v├á ─æ├ính gi├í.</p>
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem; margin-top: 0.5rem;">
                                <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 0.75rem; text-align: center;">
                                    <strong style="display: block; color: var(--primary); font-size: 1.25rem;">01</strong>
                                    <span style="display: block; color: var(--text-muted); font-weight: 700; font-size: 0.72rem; margin-top: 0.25rem;">─É─âng t├ái liß╗çu</span>
                                </div>
                                <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 0.75rem; text-align: center;">
                                    <strong style="display: block; color: var(--primary); font-size: 1.25rem;">02</strong>
                                    <span style="display: block; color: var(--text-muted); font-weight: 700; font-size: 0.72rem; margin-top: 0.25rem;">Nhß║¡n t╞░╞íng t├íc</span>
                                </div>
                                <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 0.75rem; padding: 0.75rem; text-align: center;">
                                    <strong style="display: block; color: var(--primary); font-size: 1.25rem;">03</strong>
                                    <span style="display: block; color: var(--text-muted); font-weight: 700; font-size: 0.72rem; margin-top: 0.25rem;">T─âng uy t├¡n</span>
                                </div>
                            </div>
                        </div>

                        <div style="background: linear-gradient(135deg, #064e3b 0%, #047857 100%); color: #ffffff; border-radius: 1rem; padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between; gap: 1.25rem; box-shadow: 0 14px 28px rgba(4, 120, 87, 0.12);">
                            <div>
                                <div style="display: inline-flex; align-items: center; gap: 0.45rem; background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.18); border-radius: 999px; padding: 0.25rem 0.75rem; font-size: 0.72rem; font-weight: 800;">╞»U TI├èN Gß╗óI ├¥</div>
                                <h3 style="margin: 0.75rem 0 0.5rem 0; font-size: 1.25rem; line-height: 1.3; font-weight: 800;">Giß║úng vi├¬n t├¡ch cß╗▒c sß║╜ c├│ lß╗úi thß║┐ hiß╗ân thß╗ï</h3>
                                <p style="margin: 0; color: #d1fae5; line-height: 1.6; font-size: 0.85rem;">Nhß╗»ng giß║úng vi├¬n th╞░ß╗¥ng xuy├¬n chia sß║╗ t├ái liß╗çu chß║Ñt l╞░ß╗úng, c├│ nhiß╗üu l╞░ß╗út xem v├á nhß║¡n ─æ├ính gi├í tß╗æt sß║╜ ─æ╞░ß╗úc hß╗ç thß╗æng xem l├á t├¡n hiß╗çu uy t├¡n ─æß╗â ╞░u ti├¬n gß╗úi ├╜ trong c├íc luß╗ông t├¼m kiß║┐m v├á ─æ─âng k├╜ giß║úng dß║íy.</p>
                            </div>
                            <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='block'; document.getElementById('repository-upload-form-panel').scrollIntoView({ behavior: 'smooth', block: 'start' });" class="btn-premium secondary" style="width: 100%; border: none; background: #ffffff; color: var(--primary); font-weight: 800;">
                                <span>Bß║»t ─æß║ºu ─æ─âng tß║úi</span>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg>
                            </button>
                        </div>
                    </div>
                </div>

                <div id="repository-upload-form-panel" style="display: none; margin-top: 1.5rem; background: #ffffff; border: 1px solid var(--border-dark); border-radius: 1rem; padding: 1.5rem; box-shadow: var(--shadow);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-light); padding-bottom: 0.75rem;">
                            <div>
                                <h3 style="margin: 0; color: var(--text-main); font-size: 1.15rem; font-weight: 800;">Th├┤ng tin t├ái liß╗çu ─æ─âng tß║úi</h3>
                                <p style="margin: 0.25rem 0 0 0; color: var(--text-muted); font-size: 0.85rem;">File sß║╜ ─æ╞░ß╗úc l╞░u tr├¬n Supabase Storage v├á hiß╗ân thß╗ï c├┤ng khai trong kho t├ái liß╗çu sau khi ─æ─âng.</p>
                            </div>
                            <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='none';" style="width: 32px; height: 32px; border-radius: 50%; border: none; background: var(--border-light); color: var(--text-muted); font-size: 1.1rem; cursor: pointer; display: flex; align-items: center; justify-content: center;">&times;</button>
                        </div>

                        <form class="repository-upload-form form-edit-layout" action="${pageContext.request.contextPath}/material-repository" method="POST" enctype="multipart/form-data" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem; padding: 0;">
                            <input type="hidden" name="action" value="uploadRepositoryMaterial">

                            <div class="form-group-premium" style="grid-column: 1 / -1;">
                                <label>Ti├¬u ─æß╗ü t├ái liß╗çu <span style="color:#ef4444;">*</span></label>
                                <input type="text" name="materialTitle" required maxlength="180" placeholder="V├¡ dß╗Ñ: Chuy├¬n ─æß╗ü h├ám sß╗æ lß╗¢p 12">
                            </div>

                            <div class="form-group-premium">
                                <label>M├┤n hß╗ìc <span style="color:#ef4444;">*</span></label>
                                <select name="materialSubject" required>
                                    <option value="">Chß╗ìn m├┤n hß╗ìc</option>
                                    <option value="To├ín">To├ín hß╗ìc</option>
                                    <option value="V─ân">Ngß╗» V─ân</option>
                                    <option value="Anh">Tiß║┐ng Anh</option>
                                    <option value="L├╜">Vß║¡t L├╜</option>
                                    <option value="H├│a">H├│a Hß╗ìc</option>
                                    <option value="Sinh Hß╗ìc">Sinh Hß╗ìc</option>
                                    <option value="Lß╗ïch Sß╗¡">Lß╗ïch Sß╗¡</option>
                                    <option value="─Éß╗ïa L├╜">─Éß╗ïa L├╜</option>
                                    <option value="C├┤ng Nghß╗ç">C├┤ng Nghß╗ç</option>
                                    <option value="Tin Hß╗ìc">Tin Hß╗ìc</option>
                                </select>
                            </div>

                            <div class="form-group-premium">
                                <label>Khß╗æi lß╗¢p <span style="color:#ef4444;">*</span></label>
                                <select name="materialGrade" required>
                                    <option value="">Chß╗ìn khß╗æi lß╗¢p</option>
                                    <option value="Lß╗¢p 10">Lß╗¢p 10</option>
                                    <option value="Lß╗¢p 11">Lß╗¢p 11</option>
                                    <option value="Lß╗¢p 12">Lß╗¢p 12</option>
                                </select>
                            </div>

                            <div class="form-group-premium">
                                <label>Loß║íi t├ái liß╗çu <span style="color:#ef4444;">*</span></label>
                                <select name="materialType" required>
                                    <option value="L├╜ thuyß║┐t">L├╜ thuyß║┐t</option>
                                    <option value="─Éß╗ü ├┤n tß║¡p">─Éß╗ü ├┤n tß║¡p</option>
                                </select>
                            </div>

                            <div class="form-group-premium">
                                <label>File t├ái liß╗çu <span style="color:#ef4444;">*</span></label>
                                <input type="file" name="materialFile" required accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.webp" style="padding: 0.55rem;">
                                <span style="font-size: 0.72rem; color: var(--text-muted); margin-top: 0.15rem;">Hß╗ù trß╗ú PDF, Word, PowerPoint, Excel v├á ß║únh. Tß╗æi ─æa 50MB.</span>
                            </div>

                            <div class="form-group-premium" style="grid-column: 1 / -1;">
                                <label>M├┤ tß║ú ngß║»n</label>
                                <textarea name="materialDescription" rows="3" maxlength="800" placeholder="T├│m tß║»t nß╗Öi dung, mß╗Ñc ti├¬u hß╗ìc tß║¡p hoß║╖c c├ích sß╗¡ dß╗Ñng t├ái liß╗çu..."></textarea>
                            </div>

                            <div class="form-actions-row-premium full-span" style="grid-column: 1 / -1; margin-top: 1rem;">
                                <button type="button" onclick="document.getElementById('repository-upload-form-panel').style.display='none';" class="btn-premium secondary">Hß╗ºy</button>
                                <button type="submit" class="btn-premium primary">─É─âng tß║úi l├¬n kho</button>
                            </div>
                        </form>
                    </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 7: Hß╗É TRß╗ó Hß╗îC Tß║¼P                      -->
            <!-- ========================================== -->
            <section id="tab-support" class="tab-pane <%= "tab-support".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hß╗ù trß╗ú giß║úng dß║íy</h1>
                        <p>Giß║úi ─æ├íp thß║»c mß║»c v├á gß╗¡i y├¬u cß║ºu trß╗ú gi├║p kß╗╣ thuß║¡t tß╗½ ban quß║ún trß╗ï HIPZI.</p>
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
                                C├óu hß╗Åi th╞░ß╗¥ng gß║╖p (FAQ)
                            </span>
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 1rem;">
                            <details style="background: #ffffff; padding: 1.25rem; border-radius: 1rem; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s ease; box-shadow: var(--shadow);">
                                <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                    <span>L├ám thß║┐ n├áo ─æß╗â tß║úi xuß╗æng b├ái giß║úng?</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                </summary>
                                <p style="font-size: 0.9rem; color: var(--text-muted); margin: 1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                    Hß╗ìc vi├¬n c├│ thß╗â tß║úi xuß╗æng c├íc file ─æ├¡nh k├¿m miß╗àn ph├¡ khi t├ái liß╗çu ─æ├ú ─æ╞░ß╗úc duyß╗çt v├á chuyß╗ân sang chß║┐ ─æß╗Ö hiß╗ân thß╗ï c├┤ng khai.
                                </p>
                            </details>

                            <details style="background: #ffffff; padding: 1.25rem; border-radius: 1rem; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s ease; box-shadow: var(--shadow);">
                                <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                    <span>AI tß║ío c├óu hß╗Åi ├┤n tß║¡p hoß║ít ─æß╗Öng ra sao?</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                </summary>
                                <p style="font-size: 0.9rem; color: var(--text-muted); margin: 1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                    Trß╗ú l├╜ AI ph├ón t├¡ch v─ân bß║ún tß╗½ t├ái liß╗çu gß╗æc do Giß║úng vi├¬n cung cß║Ñp ─æß╗â b├│c t├ích th├ánh c├íc bß╗Ö Flashcard trß╗▒c quan cho hß╗ìc vi├¬n luyß╗çn tß║¡p.
                                </p>
                            </details>
                        </div>
                    </div>

                    <!-- SUPPORT FORM -->
                    <div class="premium-card">
                        <div class="premium-card-header" style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                Y├¬u cß║ºu hß╗ù trß╗ú
                            </span>
                        </div>
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.5rem;">Gß╗¡i y├¬u cß║ºu trß╗▒c tiß║┐p ─æß║┐n ─æß╗Öi ng┼⌐ kß╗╣ thuß║¡t nß║┐u bß║ín gß║╖p sß╗▒ cß╗æ nghi├¬m trß╗ìng.</p>
                        <form id="supportForm" style="display: flex; flex-direction: column; gap: 1.25rem;" class="form-edit-layout">
                            <div class="form-group-premium">
                                <label>Ti├¬u ─æß╗ü cß║ºn hß╗ù trß╗ú</label>
                                <input type="text" name="title" required placeholder="Nhß║¡p ti├¬u ─æß╗ü vß║»n tß║»t...">
                            </div>
                            <div class="form-group-premium">
                                <label>M├┤ tß║ú chi tiß║┐t</label>
                                <textarea name="content" rows="4" required placeholder="M├┤ tß║ú kh├│ kh─ân bß║ín ─æang gß║╖p phß║úi..."></textarea>
                            </div>
                            <button type="submit" class="btn-premium primary" style="width: 100%; text-transform: uppercase; letter-spacing: 1px; font-size: 0.85rem;">Gß╗¡i tin nhß║»n</button>
                        </form>
                    </div>
                </div>
            </section>
            <!-- ========================================== -->
            <!-- TAB: THß╗ÉNG K├è Sß╗É D╞» (V├ì TIß╗ÇN)              -->
            <!-- ========================================== -->
            <section id="tab-balance-stats" class="tab-pane <%= "tab-balance-stats".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Thß╗æng k├¬ sß╗æ d╞░</h1>
                        <p>Quß║ún l├╜ nguß╗ôn thu nhß║¡p, sß╗æ d╞░ hiß╗çn c├│ v├á y├¬u cß║ºu thanh to├ín.</p>
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
                    <!-- Thß║╗ sß╗æ d╞░ v├¡ ch├¡nh -->
                    <div class="premium-card" style="background: linear-gradient(135deg, #047857 0%, #10b981 100%); color: #ffffff; padding: 2rem; border: none; display: flex; flex-direction: column; justify-content: space-between; min-height: 240px; box-shadow: 0 10px 25px -5px rgba(4, 120, 87, 0.3);">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                                <span style="font-size: 0.9rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; opacity: 0.9;">V├¡ t├ái khoß║ún cß╗ºa t├┤i</span>
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3a2 2 0 0 0 0-4z"/><circle cx="18" cy="12" r="1"/></svg>
                            </div>
                            <span style="font-size: 0.85rem; opacity: 0.8; display: block; margin-bottom: 0.25rem;">Sß╗æ d╞░ khß║ú dß╗Ñng</span>
                            <div style="font-size: 2.25rem; font-weight: 800; letter-spacing: -0.5px;"><%= displayBalance %> <span style="font-size: 1.35rem; font-weight: 600;">VND</span></div>
                        </div>
                        <div style="margin-top: 1.5rem;">
                            <button type="button" class="btn-premium primary" style="background: #ffffff; color: #047857; width: 100%; border: none; font-weight: 700; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border-radius: 0.75rem; padding: 0.8rem 1.25rem;" onclick="alert('Chß╗⌐c n─âng y├¬u cß║ºu r├║t tiß╗ün tß║ím thß╗¥i ch╞░a mß╗ƒ. ─Éß╗Öi ng┼⌐ kß╗╣ thuß║¡t ─æang kß║┐t nß╗æi cß╗òng thanh to├ín ng├ón h├áng.')">
                                R├║t tiß╗ün vß╗ü ng├ón h├áng
                            </button>
                        </div>
                    </div>

                    <!-- L╞░ß╗¢i thß╗æng k├¬ thu nhß║¡p chi tiß║┐t -->
                    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.25rem;">
                        <!-- Card 1 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Doanh thu th├íng n├áy</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #ecfdf5; color: #059669; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">12.850.000 VND</div>
                            </div>
                            <span style="font-size: 0.75rem; color: #059669; font-weight: 700; display: inline-flex; align-items: center; gap: 0.25rem;">
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="18 15 12 9 6 15"/></svg>
                                +12.4% so vß╗¢i th├íng tr╞░ß╗¢c
                            </span>
                        </div>
                        <!-- Card 2 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Thu nhß║¡p chß╗¥ duyß╗çt</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #fffbeb; color: #d97706; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">1.500.000 VND</div>
                            </div>
                            <span style="font-size: 0.75rem; color: var(--text-muted); font-weight: 600;">Sß║╜ ─æ╞░ß╗úc ─æß╗æi so├ít v├áo ng├áy 25 h├áng th├íng</span>
                        </div>
                        <!-- Card 3 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Kh├│a hß╗ìc ─æ├ú b├ín</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #f5f3ff; color: #7c3aed; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">48 <span style="font-size: 0.95rem; font-weight: 600; color: var(--text-muted);">l╞░ß╗út</span></div>
                            </div>
                            <span style="font-size: 0.75rem; color: #7c3aed; font-weight: 700;">Tß╗½ 3 kh├│a hß╗ìc trß╗▒c tuyß║┐n ─æang mß╗ƒ</span>
                        </div>
                        <!-- Card 4 -->
                        <div class="premium-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                                    <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">Hß╗ìc vi├¬n ─æ─âng k├╜</span>
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: #eff6ff; color: #2563eb; display: flex; justify-content: center; align-items: center;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    </div>
                                </div>
                                <div style="font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 0.25rem;">152 <span style="font-size: 0.95rem; font-weight: 600; color: var(--text-muted);">hß╗ìc vi├¬n</span></div>
                            </div>
                            <span style="font-size: 0.75rem; color: #2563eb; font-weight: 700;">+24 hß╗ìc vi├¬n mß╗¢i trong tuß║ºn n├áy</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: Lß╗èCH Sß╗¼ GIAO Dß╗èCH (V├ì TIß╗ÇN)           -->
            <!-- ========================================== -->
            <section id="tab-transaction-history" class="tab-pane <%= "tab-transaction-history".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Lß╗ïch sß╗¡ giao dß╗ïch</h1>
                        <p>Danh s├ích c├íc giao dß╗ïch ph├ít sinh tß╗½ viß╗çc b├ín kh├│a hß╗ìc, t├ái liß╗çu v├á r├║t tiß╗ün.</p>
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
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted);">M├ú giao dß╗ïch</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted);">Ng├áy giao dß╗ïch</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted);">Nß╗Öi dung</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted); text-align: right;">Sß╗æ tiß╗ün</th>
                                    <th style="padding: 1rem 1.5rem; font-weight: 800; color: var(--text-muted); text-align: center;">Trß║íng th├íi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0892</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">15/06/2026 14:30</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Hß╗ìc vi├¬n mua kh├│a hß╗ìc: Lß║¡p tr├¼nh Java Web MVC</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #059669;">+250.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Th├ánh c├┤ng</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0891</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">12/06/2026 09:15</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Y├¬u cß║ºu r├║t tiß╗ün vß╗ü Techcombank</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #ef4444;">-1.500.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Th├ánh c├┤ng</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0890</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">10/06/2026 18:45</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Hß╗ìc vi├¬n mua kh├│a hß╗ìc: Luyß╗çn thi THPT To├ín hß╗ìc n├óng cao</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #059669;">+300.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Th├ánh c├┤ng</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid var(--border-light);">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0889</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">08/06/2026 11:00</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Hß╗ìc vi├¬n tß║úi t├ái liß╗çu: Bß╗Ö ─æß╗ü ├┤n luyß╗çn tiß║┐ng Anh 2026</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #059669;">+50.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #ecfdf5; color: #059669; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem;">Th├ánh c├┤ng</span>
                                    </td>
                                </tr>
                                <tr style="border-bottom: none;">
                                    <td style="padding: 1.15rem 1.5rem; font-weight: 700; color: var(--text-main);">TXN0888</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-muted);">05/06/2026 16:20</td>
                                    <td style="padding: 1.15rem 1.5rem; color: var(--text-main); font-weight: 500;">Y├¬u cß║ºu r├║t tiß╗ün vß╗ü Vietcombank</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: right; font-weight: 800; color: #ef4444;">-500.000 VND</td>
                                    <td style="padding: 1.15rem 1.5rem; text-align: center;">
                                        <span style="display: inline-block; background: #fef2f2; color: #ef4444; font-weight: 700; font-size: 0.75rem; padding: 0.25rem 0.75rem; border-radius: 1rem; cursor: help;" title="Sß╗æ t├ái khoß║ún ng├ón h├áng thß╗Ñ h╞░ß╗ƒng kh├┤ng hß╗úp lß╗ç hoß║╖c bß╗ï tß╗½ chß╗æi bß╗ƒi ng├ón h├áng li├¬n kß║┐t.">Thß║Ñt bß║íi</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- MODAL OVERLAY: ─Éß╗öI Mß║¼T KHß║¿U Hß╗å THß╗ÉNG       -->
            <!-- ========================================== -->
            <!-- ========================================== -->
            <div id="pwd-modal-overlay" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15, 23, 42, 0.6); backdrop-filter:blur(4px); z-index:9999; display:none; justify-content:center; align-items:center; padding:1rem;">
                <div style="background:#ffffff; border-radius:1.5rem; width:100%; max-width:440px; padding:2rem; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1); border:1px solid #e2e8f0; animation:modalScaleUp 0.25s ease-out;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                        <div style="display:flex; align-items:center; gap:0.65rem;">
                            <div style="width:36px; height:36px; border-radius:50%; background:#fef3c7; color:#d97706; display:flex; justify-content:center; align-items:center;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            </div>
                            <span style="font-size:1.25rem; font-weight:800; color:var(--text-main);">─Éß╗òi mß║¡t khß║⌐u</span>
                        </div>
                        <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='none';" style="background:none; border:none; font-size:1.25rem; color:var(--text-muted); cursor:pointer;">&times;</button>
                    </div>

                    <form action="${pageContext.request.contextPath}/profile" method="POST" class="form-edit-layout" style="display:flex; flex-direction:column; gap:1.25rem; padding: 0;">
                        <input type="hidden" name="action" value="changePassword">
                        
                        <div class="form-group-premium">
                            <label>Mß║¡t khß║⌐u hiß╗çn tß║íi <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="currentPassword" required placeholder="ΓÇóΓÇóΓÇóΓÇóΓÇóΓÇóΓÇóΓÇó">
                        </div>

                        <div class="form-group-premium">
                            <label>Mß║¡t khß║⌐u mß╗¢i <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="newPassword" required minlength="6" placeholder="Mß║¡t khß║⌐u ├¡t nhß║Ñt 6 k├╜ tß╗▒">
                        </div>

                        <div class="form-group-premium">
                            <label>X├íc nhß║¡n mß║¡t khß║⌐u mß╗¢i <span style="color:#ef4444;">*</span></label>
                            <input type="password" name="confirmPassword" required minlength="6" placeholder="Nhß║¡p lß║íi mß║¡t khß║⌐u mß╗¢i">
                        </div>

                        <div class="form-actions-row-premium">
                            <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='none';" class="btn-premium secondary">Hß╗ºy bß╗Å</button>
                            <button type="submit" class="btn-premium primary" style="background:#059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">Cß║¡p nhß║¡t ngay</button>
                        </div>
                    </form>
                </div>
            </div>

            </main>
        </div>
    </div>

    
    <!-- ===== JAVASCRIPT Xß╗¼ L├¥ CHUYß╗éN TAB M╞»ß╗óT M├Ç ===== -->
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
            'tab-teaching-registration': '─É─âng k├¡ giß║úng dß║íy',
            'tab-class-registration': '─É─âng k├¡ lß╗¢p hß╗ìc',
            'tab-profile': 'Hß╗ô s╞í c├í nh├ón',
            'tab-edit': 'Cß║¡p nhß║¡t th├┤ng tin',
            'tab-security': 'Bß║úo mß║¡t',
            'tab-upload-material': '─É─âng tß║úi t├ái liß╗çu',
            'tab-support': 'Hß╗ù trß╗ú giß║úng dß║íy',
            'tab-balance-stats': 'Thß╗æng k├¬ sß╗æ d╞░',
            'tab-transaction-history': 'Lß╗ïch sß╗¡ giao dß╗ïch',
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

        // Xß╗¡ l├╜ gß╗¡i form hß╗ù trß╗ú qua Servlet
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
                submitBtn.innerText = '─Éang gß╗¡i...';

                fetch('${pageContext.request.contextPath}/support', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                .then(async response => {
                    if (response.ok) {
                        showToast('─É├ú gß╗¡i th├ánh c├┤ng ─æß║┐n quß║ún trß╗ï vi├¬n, phß║ún hß╗ôi sß║╜ gß╗¡i ─æß║┐n email cß╗ºa bß║ín.');
                        this.reset();
                    } else {
                        const errorMsg = await response.text();
                        showToast(errorMsg || 'C├│ lß╗ùi xß║úy ra khi gß╗¡i y├¬u cß║ºu hß╗ù trß╗ú.', 'error');
                    }
                })
                .catch(error => {
                    console.error('Support Error:', error);
                    showToast('Lß╗ùi kß║┐t nß╗æi m├íy chß╗º. Vui l├▓ng thß╗¡ lß║íi sau.', 'error');
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
                showToast('Vui l├▓ng chß╗ìn ├¡t nhß║Ñt mß╗Öt m├┤n c├│ thß╗â dß║íy.', 'error');
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
            label.textContent = '─Éang x├íc thß╗▒c vß╗¢i Google...';
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
                            else if (att > 30) { clearInterval(t); showToast('Google Picker ch╞░a tß║úi xong.', 'error'); resetPickerBtn(); }
                        }, 200);
                    } else { buildAndShowPicker(data.accessToken, data.clientId); }
                })
                .catch(function() { showToast('Kh├┤ng thß╗â lß║Ñy token Drive.', 'error'); resetPickerBtn(); });
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
                    .setTitle('Chß╗ìn nß╗Öi dung kh├│a hß╗ìc tß╗½ Google Drive')
                    .setCallback(pickerCallback).build();
                picker.setVisible(true);
            } catch(e) { showToast('Kh├┤ng thß╗â mß╗ƒ Google Picker: ' + e.message, 'error'); }
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
            document.getElementById('picker-btn-label').textContent = 'Thay ─æß╗òi lß╗▒a chß╗ìn';
            showToast('─É├ú chß╗ìn: ' + name, 'success');
        }

        function clearPickerSelection() {
            ['courseGoogleDriveUrlHidden','courseGoogleDriveFileIdHidden','courseGoogleDriveFolderIdHidden',
             'courseGoogleDriveUrlManual','courseGoogleDriveFileIdManual','courseGoogleDriveFolderIdManual']
                .forEach(function(eid) { var el = document.getElementById(eid); if (el) el.value = ''; });
            document.getElementById('picker-selected-preview').style.display = 'none';
            document.getElementById('picker-btn-label').textContent = 'Chß╗ìn file / th╞░ mß╗Ñc tß╗½ Google Drive';
        }

        function resetPickerBtn() {
            pickerTokenPending = false;
            var btn = document.getElementById('btn-open-picker');
            var spin = document.getElementById('picker-loading-spin');
            var lbl = document.getElementById('picker-btn-label');
            if (btn) btn.disabled = false;
            if (spin) spin.style.display = 'none';
            if (lbl && lbl.textContent.includes('x├íc thß╗▒c')) lbl.textContent = 'Chß╗ìn file / th╞░ mß╗Ñc tß╗½ Google Drive';
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
