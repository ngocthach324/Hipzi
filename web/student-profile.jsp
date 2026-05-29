<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="com.hipzi.model.StudentProfile" %>
        <%@page import="com.hipzi.model.User" %>
            <%@page import="com.hipzi.model.Role" %>
                <%@page import="java.util.List" %>
                    <%@page import="java.text.SimpleDateFormat" %>
                        <%@page import="java.util.Date" %>
                            <%@page import="com.hipzi.model.Notification" %>
                                <!DOCTYPE html>
                                <html lang="vi">

                                <head>
                                    <meta charset="UTF-8">
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                    <title>Hồ sơ học viên - HIPZI</title>
                                    <meta name="description"
                                        content="Quản lý thông tin tài khoản và tiến trình học tập của học viên trên nền tảng HIPZI.">
                                    <link rel="icon" type="image/png"
                                        href="${pageContext.request.contextPath}/assets/images/favicon.png">
                                    <link rel="stylesheet"
                                        href="${pageContext.request.contextPath}/assets/css/landing.css">
                                    <style>
                                        /* ===== OVERRIDE N?N T?NG & GIAO DI?N PREMIUM TUONG T? B?N THI?T K? ===== */
                                        body {
                                            background: linear-gradient(135deg, #e6fcf5 0%, #ebfbee 50%, #dcfce7 100%);
                                            background-repeat: no-repeat;
                                            background-attachment: fixed;
                                            min-height: 100vh;
                                        }

                                        body.student-profile-page {
                                            display: block;
                                            min-height: 100vh;
                                            overflow-x: hidden;
                                        }

                                        body.student-profile-page > .app-dashboard-container {
                                            display: flex !important;
                                            visibility: visible !important;
                                            opacity: 1 !important;
                                            background: #ffffff !important;
                                            position: relative !important;
                                            z-index: 1 !important;
                                            flex: none !important;
                                        }

                                        body.student-profile-page .dashboard-unified-header,
                                        body.student-profile-page .dashboard-body,
                                        body.student-profile-page .dashboard-sidebar,
                                        body.student-profile-page .dashboard-content-wrapper {
                                            visibility: visible !important;
                                            opacity: 1 !important;
                                        }

                                        body.student-profile-page .dashboard-body {
                                            display: flex !important;
                                        }

                                        /* ===== B? C?C CH�NH C?A TRANG PROFILE ===== */
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
                                            visibility: visible !important;
                                            opacity: 1 !important;
                                            position: relative;
                                            z-index: 1;
                                        }

                                        /* ===== HEADER THỐNG NHẤT FULL-WIDTH ===== */
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

                                        /* .unified-header-left and .unified-header-divider removed (logo removed) */

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

                                        /* ===== BODY: SIDEBAR + CONTENT ROW ===== */
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

                                        /* sidebar-section-header is now removed — header is unified */
                                        .sidebar-section-header {
                                            display: none;
                                        }

                                        .sidebar-section-header .animated-brand-box {
                                            width: 100%;
                                            height: 100%;
                                            min-height: 0;
                                            box-sizing: border-box;
                                            border-radius: 1.5rem 0 0 0;
                                            justify-content: flex-start;
                                            padding: 0.7rem 1.25rem;
                                            transition: none;
                                        }

                                        .sidebar-section-header .animated-brand-box:hover {
                                            transform: none;
                                        }

                                        .sidebar-section-header .animated-brand-box::before,
                                        .sidebar-section-header .brand-logo-ring,
                                        .sidebar-section-header .brand-logo-ring img {
                                            animation: none;
                                        }

                                        .sidebar-greeting-box {
                                            width: 100%;
                                            height: 100%;
                                            border-radius: 1.5rem 0 0 0;
                                            background: linear-gradient(135deg, rgba(255, 255, 255, 0.96) 0%, rgba(236, 253, 245, 0.92) 100%);
                                            display: flex;
                                            flex-direction: column;
                                            justify-content: center;
                                            padding: 0.65rem 1.25rem;
                                            box-sizing: border-box;
                                            overflow: hidden;
                                        }

                                        .sidebar-greeting-eyebrow {
                                            font-size: 0.78rem;
                                            font-weight: 700;
                                            color: #059669;
                                            letter-spacing: 0.04em;
                                            line-height: 1.1;
                                        }

                                        .sidebar-greeting-name {
                                            margin-top: 0.2rem;
                                            font-size: 1.08rem;
                                            font-weight: 900;
                                            color: #0f172a;
                                            line-height: 1.15;
                                            white-space: nowrap;
                                            overflow: hidden;
                                            text-overflow: ellipsis;
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
                                            0%, 100% {
                                                transform: translateY(0) rotate(-2deg);
                                            }

                                            50% {
                                                transform: translateY(-6px) rotate(2deg);
                                            }
                                        }

                                        /* sidebar-section-header rules removed — replaced by unified header */

                                        .sidebar-section-title {
                                            display: block;
                                            font-size: 1.1rem;
                                            font-weight: 800;
                                            line-height: 1.25;
                                            letter-spacing: 0.2px;
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

                                        /* Th? User t�m t?t ? du?i c�ng sidebar (L?y c?m h?ng t? g�c du?i b�n tr�i c?a thi?t k?) */
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

                                        /* D?i ti�u d? trang tr?ng ph�a tr�n c�ng */
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
                                            flex-direction: column;
                                            flex: 1;
                                            min-height: 0;
                                        }

                                        .tab-pane.active-pane {
                                            display: flex;
                                        }

                                        .profile-tab-panel {
                                            height: 100%;
                                            border-radius: 0;
                                            overflow: hidden;
                                            border: none;
                                            box-shadow: none;
                                            display: flex;
                                            flex-direction: column;
                                        }

                                        /* Obsolete: green headers removed from tabs, unified header used instead */

                                        .profile-tab-body {
                                            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
                                            padding: 2rem;
                                            display: flex;
                                            flex-direction: column;
                                            gap: 1.5rem;
                                            flex: 1;
                                            min-height: 0;
                                            overflow-y: auto;
                                        }

                                        .profile-tab-fill-card {
                                            flex: 1;
                                            min-height: 0;
                                            display: flex;
                                            flex-direction: column;
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

                                        .role-tag.student {
                                            background: #e0f2fe;
                                            color: #0284c7;
                                        }

                                        .role-tag.parent {
                                            background: #fef3c7;
                                            color: #d97706;
                                        }

                                        .role-tag.teacher {
                                            background: #f3e8ff;
                                            color: #7c3aed;
                                        }

                                        .role-tag.staff {
                                            background: #dbeafe;
                                            color: #2563eb;
                                        }

                                        .role-tag.admin {
                                            background: #fee2e2;
                                            color: #dc2626;
                                        }

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

                                        /* N?i dung lu?i th�ng tin */
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

                                        /* Tr?ng th�i t�i kho?n badge */
                                        .acc-status-tag {
                                            display: inline-flex;
                                            align-items: center;
                                            gap: 0.35rem;
                                            font-size: 0.8rem;
                                            font-weight: 700;
                                            padding: 0.15rem 0.65rem;
                                            border-radius: 0.4rem;
                                        }

                                        .acc-status-tag.active {
                                            background: #dcfce7;
                                            color: #15803d;
                                        }

                                        .acc-status-tag.suspended {
                                            background: #fef9c3;
                                            color: #a16207;
                                        }

                                        .acc-status-tag.disabled {
                                            background: #fee2e2;
                                            color: #b91c1c;
                                        }

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

                                        /* ===== FORM C?P NH?T TRONG TAB CH?NH S?A ===== */
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


                                        /* ===== C�C STYLES CHO NAVBAR KHI �� �ANG NH?P ===== */
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

                                        /* Th�m c?u n?i gap bridge d? chu?t di chuy?n t? Avatar xu?ng menu kh�ng b? m?t hover */
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

                                        /* ===== DANH S�CH TH�NG B�O POPUP (LIGHT MODE �?NG B?) ===== */
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

                                        /* Th�m c?u n?i gap bridge cho menu th�ng b�o */
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

                                        /* ===== N�T CAMERA OVERLAY �? �?I AVATAR TR�N TH? HIGHLIGHT ===== */
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
                                            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
                                            transition: all 0.2s ease;
                                        }

                                        .btn-avatar-camera:hover {
                                            color: var(--primary);
                                            border-color: var(--primary);
                                            transform: scale(1.1);
                                            box-shadow: 0 4px 8px rgba(5, 150, 105, 0.2);
                                        }

                                        /* C�c ti?n �ch tr?ng mock UI cho sinh vi�n */
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

                                            .dashboard-unified-header {
                                                border-radius: 1.5rem 1.5rem 0 0;
                                            }

                                            .profile-tab-panel {
                                                border-radius: 0;
                                            }

                                            .card-body-grid {
                                                grid-template-columns: repeat(2, 1fr);
                                            }
                                        }

                                        @media (max-width: 640px) {
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

                                        /* ===== H? TH?NG TH�NG B�O TOAST G�C DU?I B�N PH?I ===== */
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
                                            from {
                                                transform: translateX(120%);
                                                opacity: 0;
                                            }

                                            to {
                                                transform: translateX(0);
                                                opacity: 1;
                                            }
                                        }

                                        @keyframes fadeOutToast {
                                            from {
                                                transform: translateX(0);
                                                opacity: 1;
                                            }

                                            to {
                                                transform: translateX(120%);
                                                opacity: 0;
                                            }
                                        }

                                        @keyframes fadeInOverlay {
                                            from {
                                                opacity: 0;
                                                transform: scale(0.98);
                                            }

                                            to {
                                                opacity: 1;
                                                transform: scale(1);
                                            }
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
                                            from {
                                                transform: rotate(0deg);
                                            }

                                            to {
                                                transform: rotate(360deg);
                                            }
                                        }

                                        @keyframes pulseRing {

                                            0%,
                                            100% {
                                                box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
                                            }

                                            50% {
                                                box-shadow: 0 0 0 6px rgba(16, 185, 129, 0.4);
                                            }
                                        }

                                        @keyframes gentleFloat {
                                            from {
                                                transform: translateY(-1px) scale(0.98);
                                            }

                                            to {
                                                transform: translateY(1px) scale(1.02);
                                            }
                                        }
                                    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap">
                                </head>

                                <body class="student-profile-page">

                                    <% User user=(User) request.getAttribute("user"); if (user==null) { user=(User)
                                        session.getAttribute("loggedUser"); } List<Role> roles = (user != null) ?
                                        user.getRoles() : null;

                                        StudentProfile studentProfile = (StudentProfile)
                                        request.getAttribute("studentProfile");
                                        if (studentProfile == null) {
                                        studentProfile = new StudentProfile();
                                        }

                                        // X? l� format ng�y th�ng hi?n th? thu?n Vi?t
                                        String joinDate = "Chưa cập nhật";
                                        if (user != null && user.getCreatedAt() != null) {
                                        joinDate = new SimpleDateFormat("dd/MM/yyyy").format(user.getCreatedAt());
                                        }

                                        // T?o chu?i ng�y hi?n t?i trang tr?ng cho Header Strip
                                        String currentDateDisplay = new SimpleDateFormat("'Hôm nay,' dd/MM/yyyy").format(new Date());

                                        // Lấy chữ cái đầu làm Avatar dự phòng
                                        String initials = "H";
                                        if (user != null && user.getDisplayName() != null &&
                                        !user.getDisplayName().isEmpty()) {
                                        String[] parts = user.getDisplayName().trim().split("\\s+");
                                        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
                                        }
                                        
                                        // Lấy danh sách thông báo hệ thống
                                        List<Notification> notifications = (List<Notification>)
                                                request.getAttribute("notifications");

                                        // Xác định tab hoạt động hiện tại (Server-side rendering)
                                        String activeTab = request.getParameter("tab");
                                        if (activeTab == null || activeTab.trim().isEmpty()) {
                                            activeTab = "tab-dashboard";
                                        } else {
                                            activeTab = activeTab.trim();
                                            if (activeTab.equals("practice")) {
                                                activeTab = "tab-dashboard";
                                            } else if (!activeTab.startsWith("tab-")) {
                                                activeTab = "tab-" + activeTab;
                                            }
                                            // Validate against allowed tab list
                                            if (!activeTab.equals("tab-dashboard") &&
                                                !activeTab.equals("tab-profile") &&
                                                !activeTab.equals("tab-edit") &&
                                                !activeTab.equals("tab-security") &&
                                                !activeTab.equals("tab-materials") &&
                                                !activeTab.equals("tab-notifications") &&
                                                !activeTab.equals("tab-support")) {
                                                activeTab = "tab-dashboard";
                                            }
                                        }
                                                %>

                                                <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

                                                    <!-- ===== GLOBAL HEADER NAVBAR ===== -->
                                                    <header class="navbar" id="navbar">
                                                        <div class="nav-container">
                                                            <a href="${pageContext.request.contextPath}/index.jsp"
                                                                class="logo">
                                                                <img src="${pageContext.request.contextPath}/assets/images/favicon.png"
                                                                    alt="HIPZI Logo">
                                                                <span>HIPZI</span>
                                                            </a>
                                                            <ul class="nav-links">
                                                                <li><a
                                                                        href="${pageContext.request.contextPath}/index.jsp">Trang
                                                                        chủ</a></li>
                                                                <li><a
                                                                        href="${pageContext.request.contextPath}/material-repository">Kho
                                                                        tài liệu</a></li>
                                                                <li><a
                                                                        href="${pageContext.request.contextPath}/classes">Lớp
                                                                        học</a></li>
                                                                <li><a
                                                                        href="${pageContext.request.contextPath}/practice">Luyện
                                                                        tập</a></li>
                                                                <li><a
                                                                        href="${pageContext.request.contextPath}/exam-room">Phòng
                                                                        thi</a></li>
                                                                <li><a
                                                                        href="${pageContext.request.contextPath}/index.jsp#ai-roadmap">Hipzi
                                                                        AI</a></li>
                                                            </ul>
                                                            <div class="navbar-user-controls">
                                                                <!-- Khung Dropdown Thông báo hệ thống cao cấp -->
                                                                <%@ include
                                                                    file="/WEB-INF/fragments/notification-bell.jspf" %>

                                                                    <!-- Khung Avatar Người dùng kèm Dropdown Menu -->
                                                                    <div class="nav-avatar-dropdown">
                                                                        <div class="nav-avatar-frame"
                                                                            title="<%= profileMenuLabel %>">
                                                                            <% if (user !=null && user.getAvatarUrl()
                                                                                !=null &&
                                                                                !user.getAvatarUrl().isEmpty()) { %>
                                                                                <img src="<%= user.getAvatarUrl() %>"
                                                                                    alt="Avatar">
                                                                                <% } else { %>
                                                                                    <span class="nav-avatar-initials">
                                                                                        <%= initials %>
                                                                                    </span>
                                                                                    <% } %>
                                                                        </div>

                                                                        <div class="dropdown-menu-popup">
                                                                            <a onclick="switchTab('tab-profile')">
                                                                                <svg width="16" height="16"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor"
                                                                                    stroke-width="2.2">
                                                                                    <circle cx="12" cy="8" r="4" />
                                                                                    <path
                                                                                        d="M4 20c0-4 3.6-7 8-7s8 3 8 7" />
                                                                                </svg>
                                                                                <span>
                                                                                    <%= profileMenuLabel %>
                                                                                </span>
                                                                            </a>
                                                                            <div
                                                                                style="height:1px; background:var(--border-dark); margin:0.35rem 0;">
                                                                            </div>
                                                                            <a href="${pageContext.request.contextPath}/logout"
                                                                                class="danger-link">
                                                                                <svg width="16" height="16"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor"
                                                                                    stroke-width="2.2">
                                                                                    <path
                                                                                        d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                                                                                    <polyline
                                                                                        points="16 17 21 12 16 7" />
                                                                                    <line x1="21" y1="12" x2="9"
                                                                                        y2="12" />
                                                                                </svg>
                                                                                <span>Đăng xuất</span>
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                            </div>
                                                        </div>
                                                    </header>

                                                    <!-- ===== DASHBOARD CHÍNH HIPZI: HEADER THỐNG NHẤT + BODY 2 CỘT ===== -->
                                                    <div class="app-dashboard-container <%= "tab-notifications".equals(activeTab) ? "is-notifications-tab" : "" %>">

                                                        <!-- HEADER THỐNG NHẤT FULL-WIDTH -->
                                                        <div class="dashboard-unified-header">
                                                            <!-- Title căn giữa tuyệt đối -->
                                                            <span class="unified-header-tab-title" id="unified-header-title">
                                                                <%= "tab-profile".equals(activeTab) ? "Hồ sơ cá nhân" :
                                                                    "tab-security".equals(activeTab) ? "Bảo mật và mật khẩu" :
                                                                    "tab-materials".equals(activeTab) ? "Tài liệu đã lưu" :
                                                                    "tab-notifications".equals(activeTab) ? "Thông báo hệ thống" :
                                                                    "tab-support".equals(activeTab) ? "Hỗ trợ học tập" :
                                                                    "tab-edit".equals(activeTab) ? "Cập nhật thông tin học viên" :
                                                                    "Tổng quan học tập" %>
                                                            </span>
                                                            <!-- Date pill phải -->
                                                            <div class="unified-header-right">
                                                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                                                <span><%= currentDateDisplay %></span>
                                                            </div>
                                                        </div>

                                                        <!-- BODY: SIDEBAR TRÁI + NỘI DUNG PHẢI -->
                                                        <div class="dashboard-body">

                                                        <!-- KÊNH SIDEBAR TRÁI (LEFT PANE) -->
                                                        <aside class="dashboard-sidebar">
                                                            <div class="sidebar-top-group">
                                                                <ul class="sidebar-menu">
                                                                    <li>
                                                                        <a id="nav-tab-dashboard" class="<%= "tab-dashboard".equals(activeTab) ? "active" : "" %>"
                                                                            onclick="switchTab('tab-dashboard')">
                                                                            <div class="menu-label-group">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor">
                                                                                    <rect x="3" y="3" width="7"
                                                                                        height="7" rx="1" />
                                                                                    <rect x="14" y="3" width="7"
                                                                                        height="7" rx="1" />
                                                                                    <rect x="14" y="14" width="7"
                                                                                        height="7" rx="1" />
                                                                                    <rect x="3" y="14" width="7"
                                                                                        height="7" rx="1" />
                                                                                </svg>
                                                                                <span>Tổng quan học tập</span>
                                                                            </div>
                                                                            <span class="menu-indicator">&rarr;</span>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a id="nav-tab-profile" class="<%= ("tab-profile".equals(activeTab) || "tab-edit".equals(activeTab)) ? "active" : "" %>"
                                                                            onclick="switchTab('tab-profile')">
                                                                            <div class="menu-label-group">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor">
                                                                                    <path
                                                                                        d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                                                    <circle cx="12" cy="7" r="4" />
                                                                                </svg>
                                                                                <span>Hồ sơ cá nhân</span>
                                                                            </div>
                                                                            <span class="menu-indicator">&rarr;</span>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a id="nav-tab-security" class="<%= "tab-security".equals(activeTab) ? "active" : "" %>"
                                                                            onclick="switchTab('tab-security')">
                                                                            <div class="menu-label-group">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor">
                                                                                    <rect x="3" y="11" width="18"
                                                                                        height="11" rx="2" />
                                                                                    <path
                                                                                        d="M7 11V7a5 5 0 0 1 10 0v4" />
                                                                                </svg>
                                                                                <span>Bảo mật và mật khẩu</span>
                                                                            </div>
                                                                            <span class="menu-indicator">&rarr;</span>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a id="nav-tab-materials" class="<%= "tab-materials".equals(activeTab) ? "active" : "" %>"
                                                                            onclick="switchTab('tab-materials')">
                                                                            <div class="menu-label-group">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor">
                                                                                    <path
                                                                                        d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
                                                                                </svg>
                                                                                <span>Tài liệu đã lưu</span>
                                                                            </div>
                                                                            <span class="menu-indicator">&rarr;</span>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a id="nav-tab-notifications" class="<%= "tab-notifications".equals(activeTab) ? "active" : "" %>"
                                                                            onclick="switchTab('tab-notifications')">
                                                                            <div class="menu-label-group">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor">
                                                                                    <path
                                                                                        d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
                                                                                    <path
                                                                                        d="M13.73 21a2 2 0 0 1-3.46 0" />
                                                                                </svg>
                                                                                <span>Thông báo hệ thống</span>
                                                                            </div>
                                                                            <span class="menu-indicator">&rarr;</span>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a id="nav-tab-support" class="<%= "tab-support".equals(activeTab) ? "active" : "" %>"
                                                                            onclick="switchTab('tab-support')">
                                                                            <div class="menu-label-group">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor">
                                                                                    <circle cx="12" cy="12" r="10" />
                                                                                    <path
                                                                                        d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                                                                                    <line x1="12" y1="17" x2="12.01"
                                                                                        y2="17" />
                                                                                </svg>
                                                                                <span>Hỗ trợ học tập</span>
                                                                            </div>
                                                                            <span class="menu-indicator">&rarr;</span>
                                                                        </a>
                                                                    </li>
                                                                </ul>
                                                                    <div class="sidebar-mascot-box"
                                                                        aria-label="HIPZI mascot">
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
                                                            <% if (user !=null && !user.isOnboardingCompleted()) { %>
                                                                <div class="onboarding-banner"
                                                                    style="margin-bottom: 1.25rem;">
                                                                    <svg width="22" height="22" viewBox="0 0 24 24"
                                                                        fill="none" stroke="#92400e" stroke-width="2">
                                                                        <circle cx="12" cy="12" r="10" />
                                                                        <line x1="12" y1="8" x2="12" y2="12" />
                                                                        <line x1="12" y1="16" x2="12.01" y2="16" />
                                                                    </svg>
                                                                    <p>Hồ sơ của bạn đang chờ hoàn tất thiết lập vai trò
                                                                        học viên sử dụng nền tảng.</p>
                                                                    <a
                                                                        href="${pageContext.request.contextPath}/onboarding">Hoàn
                                                                        tất ngay</a>
                                                                </div>
                                                                <% } %>

                                                                    <!-- ========================================== -->
                                                                    <!-- TAB: TỔNG QUAN HỌC TẬP (DASHBOARD)         -->
                                                                    <!-- ========================================== -->
                                                                    <section id="tab-dashboard"
                                                                        class="tab-pane <%= "tab-dashboard".equals(activeTab) ? "active-pane" : "" %>">

                                                                        <!-- Bảng nội dung Tổng quan học tập -->
                                                                        <div
                                                                            style="flex:1; min-height:0; overflow:hidden; display:flex; flex-direction:column;">

                                                                            <!-- Nửa dưới: Nền trắng tích hợp Lời chào & Lưới 4 Thẻ -->
                                                                            <div
                                                                                style="background:linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); padding:2rem; display:flex; flex-direction:column; gap:1.5rem; flex:1; min-height:0; overflow-y:auto;">

                                                                                <!-- Hàng Tiêu đề Lời chào -->
                                                                                <div
                                                                                    style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
                                                                                    <div>
                                                                                        <h2
                                                                                            style="font-size:1.65rem; font-weight:800; color:var(--text-main); margin:0.25rem 0 0 0;">
                                                                                            Chào mừng trở lại, <%= user
                                                                                                !=null ?
                                                                                                user.getDisplayName()
                                                                                                : "Học viên HIPZI" %>!
                                                                                        </h2>
                                                                                    </div>
                                                                                    <div
                                                                                        style="display:flex; align-items:center; gap:0.75rem;">
                                                                                        <div style="display:flex; align-items:center; gap:0.5rem; background:#f0fdf4; border:1px solid #bbf7d0; padding:0.35rem 0.85rem; border-radius:1rem;">
                                                                                            <svg width="14" height="14"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="#16a34a"
                                                                                                stroke-width="2.5"
                                                                                                stroke-linecap="round"
                                                                                                stroke-linejoin="round"
                                                                                                style="cursor:help;"
                                                                                                onclick="event.stopPropagation(); showToast('Mã này dùng để gửi cho Phụ huynh giúp họ có thể theo dõi tiến độ học tập của bạn trên HipZi.', 'info')"
                                                                                                title="Nhấn để xem giải thích">
                                                                                                <circle cx="12" cy="12"
                                                                                                    r="10" />
                                                                                                <path
                                                                                                    d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                                                                                                <line x1="12" y1="17"
                                                                                                    x2="12.01"
                                                                                                    y2="17" />
                                                                                            </svg>
                                                                                            <span
                                                                                                style="font-size:0.75rem; font-weight:700; color:#15803d; text-transform:uppercase;">Mã
                                                                                                học viên:</span>
                                                                                            <span
                                                                                                onclick="event.stopPropagation(); copyStudentCode(this.textContent.trim());"
                                                                                                title="Nhấn để sao chép mã học viên"
                                                                                                style="font-size:0.85rem; font-weight:800; color:#16a34a; letter-spacing:0.5px; cursor:pointer;">
                                                                                                <%= (user !=null &&
                                                                                                    user.getStudentCode()
                                                                                                    !=null) ?
                                                                                                    user.getStudentCode()
                                                                                                    : "HZ-PENDING" %>
                                                                                            </span>
                                                                                        </div>
                                                                                    </div>
                                                                                </div>

                                                                                <!-- Lưới 4 Thẻ bên trong (2 thẻ trên, 2 thẻ dưới) -->
                                                                                <div
                                                                                    style="display:grid; grid-template-columns:repeat(2, 1fr); grid-auto-rows:1fr; gap:1.5rem; flex:1; min-height:0;">

                                                                                    <!-- Thẻ 1 (Trên trái): Cấp độ học viên -->
                                                                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.5rem; border:1px solid #dcfce7; box-shadow:0 4px 12px rgba(16, 185, 129, 0.03); display:flex; flex-direction:column; justify-content:center; gap:1rem; transition:transform 0.2s ease;"
                                                                                        onmouseover="this.style.transform='translateY(-2px)';"
                                                                                        onmouseout="this.style.transform='translateY(0)';">
                                                                                        <div
                                                                                            style="display:flex; align-items:center; gap:1rem;">
                                                                                            <div
                                                                                                style="width:56px; height:56px; border-radius:50%; background:#ecfdf5; display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                                                                <span
                                                                                                    style="font-size:1.55rem;">&#11088;</span>
                                                                                            </div>
                                                                                            <div>
                                                                                                <span
                                                                                                    style="font-size:0.75rem; font-weight:700; color:#059669; text-transform:uppercase; letter-spacing:0.5px; display:block;">Cấp
                                                                                                    độ học viên</span>
                                                                                                <span
                                                                                                    style="font-size:1.55rem; font-weight:800; color:var(--text-main); display:block; line-height:1.2;">Cấp
                                                                                                    <%= studentProfile.getCurrentLevel()
                                                                                                        %></span>
                                                                                            </div>
                                                                                        </div>
                                                                                        <!-- Mini Progress bar -->
                                                                                        <div>
                                                                                            <% int
                                                                                                currentXp=studentProfile.getCurrentXp();
                                                                                                int
                                                                                                targetXp=studentProfile.getCurrentLevel()
                                                                                                * 1000; int
                                                                                                xpPercent=(int)
                                                                                                Math.min(100, ((double)
                                                                                                currentXp / (targetXp> 0
                                                                                                ? targetXp : 1000)) *
                                                                                                100);
                                                                                                %>
                                                                                                <div
                                                                                                    style="display:flex; justify-content:space-between; font-size:0.75rem; font-weight:600; color:var(--text-muted); margin-bottom:0.3rem;">
                                                                                                    <span>Tiến
                                                                                                        trình</span>
                                                                                                    <span>
                                                                                                        <%= currentXp %>
                                                                                                            /<%= targetXp
                                                                                                                %> XP
                                                                                                    </span>
                                                                                                </div>
                                                                                                <div
                                                                                                    style="width:100%; height:6px; background:#e2e8f0; border-radius:3px; overflow:hidden;">
                                                                                                    <div
                                                                                                        style="width:<%= xpPercent %>%; height:100%; background:linear-gradient(90deg, #34d399 0%, #059669 100%); border-radius:3px;">
                                                                                                    </div>
                                                                                                </div>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Thẻ 2 (Trên phải): Chuỗi ngày (Streak) -->
                                                                                    <div style="background:#ffffff; border-radius:1.25rem; padding:2.45rem 1.5rem 1.5rem 1.5rem; border:1px solid #dcfce7; box-shadow:0 4px 12px rgba(16, 185, 129, 0.03); display:flex; align-items:flex-start; gap:1.15rem; transition:transform 0.2s ease;"
                                                                                        onmouseover="this.style.transform='translateY(-2px)';"
                                                                                        onmouseout="this.style.transform='translateY(0)';">
                                                                                        <div
                                                                                            style="width:56px; height:56px; border-radius:50%; background:#ecfdf5; display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                                                            <span
                                                                                                style="font-size:1.55rem;">&#128293;</span>
                                                                                        </div>
                                                                                        <div>
                                                                                            <span
                                                                                                style="font-size:0.75rem; font-weight:700; color:#059669; text-transform:uppercase; letter-spacing:0.5px; display:block;">Chuỗi
                                                                                                ngày học</span>
                                                                                            <span
                                                                                                style="font-size:1.55rem; font-weight:800; color:var(--text-main); display:block; line-height:1.2;">
                                                                                                <%= studentProfile.getCurrentStreak()
                                                                                                    %> Ngày
                                                                                            </span>
                                                                                            <span
                                                                                                style="font-size:0.75rem; color:var(--text-muted); display:block;">Liên
                                                                                                tiếp duy trì</span>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Thẻ 3 (Dưới trái): Tổng số Quiz -->
                                                                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.5rem; border:1px solid #dcfce7; box-shadow:0 4px 12px rgba(16, 185, 129, 0.03); display:flex; align-items:center; gap:1.15rem; transition:transform 0.2s ease;"
                                                                                        onmouseover="this.style.transform='translateY(-2px)';"
                                                                                        onmouseout="this.style.transform='translateY(0)';">
                                                                                        <div
                                                                                            style="width:56px; height:56px; border-radius:50%; background:#ecfdf5; display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                                                            <span
                                                                                                style="font-size:1.55rem;">&#9201;</span>
                                                                                        </div>
                                                                                        <div>
                                                                                            <span
                                                                                                style="font-size:0.75rem; font-weight:700; color:#059669; text-transform:uppercase; letter-spacing:0.5px; display:block;">Quiz
                                                                                                hoàn thành</span>
                                                                                            <span
                                                                                                style="font-size:1.55rem; font-weight:800; color:var(--text-main); display:block; line-height:1.2;">
                                                                                                <%= studentProfile.getCompletedQuizzesCount()
                                                                                                    %> Bài
                                                                                            </span>
                                                                                            <span
                                                                                                style="font-size:0.75rem; color:#10b981; font-weight:600;">&uarr;
                                                                                                <%= String.format("%.0f",
                                                                                                    studentProfile.getAverageAccuracy())
                                                                                                    %>% Tỷ lệ
                                                                                                    đúng</span>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Thẻ 4 (Dưới phải): Số lớp học -->
                                                                                    <div style="background:#ffffff; border-radius:1.25rem; padding:1.5rem; border:1px solid #dcfce7; box-shadow:0 4px 12px rgba(16, 185, 129, 0.03); display:flex; align-items:center; gap:1.15rem; transition:transform 0.2s ease;"
                                                                                        onmouseover="this.style.transform='translateY(-2px)';"
                                                                                        onmouseout="this.style.transform='translateY(0)';">
                                                                                        <div
                                                                                            style="width:56px; height:56px; border-radius:50%; background:#ecfdf5; display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                                                            <span
                                                                                                style="font-size:1.55rem;">&#128101;</span>
                                                                                        </div>
                                                                                        <div>
                                                                                            <span
                                                                                                style="font-size:0.75rem; font-weight:700; color:#059669; text-transform:uppercase; letter-spacing:0.5px; display:block;">Lớp
                                                                                                học tham gia</span>
                                                                                            <span
                                                                                                style="font-size:1.55rem; font-weight:800; color:var(--text-main); display:block; line-height:1.2;">
                                                                                                <%= studentProfile.getActiveClassesCount()
                                                                                                    %> Lớp học
                                                                                            </span>
                                                                                            <span
                                                                                                style="font-size:0.75rem; color:var(--text-muted);">Đang
                                                                                                hoạt động</span>
                                                                                        </div>
                                                                                    </div>

                                                                                </div>
                                                                            </div>

                                                                        </div>

                                                                    </section>

                                                                    <!-- ========================================== -->
                                                                    <!-- TAB 1: HỒ SƠ CÁ NHÂN TỔNG QUAN             -->
                                                                    <!-- ========================================== -->
                                                                    <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(activeTab) ? "active-pane" : "" %>">
                                                                        <!-- Bảng nội dung Hồ sơ cá nhân -->
                                                                        <div class="profile-tab-panel">
                                                                            <div
                                                                                style="background:linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); padding:1.75rem; display:flex; flex-direction:column; gap:2rem; flex:1; min-height:0; overflow-y:auto;">

                                                                                <!-- Bố cục hàng trên: Trái (Logo, Tên, Thành viên) - Phải (Vai trò chính) -->
                                                                                <div
                                                                                    style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1.5rem; padding-bottom:1.5rem; border-bottom:1px solid #f1f5f9;">

                                                                                    <!-- Nhóm Trái -->
                                                                                    <div class="highlight-left-group"
                                                                                        style="margin:0;">
                                                                                        <div
                                                                                            class="highlight-avatar-container">
                                                                                            <% if (user !=null &&
                                                                                                user.getAvatarUrl()
                                                                                                !=null &&
                                                                                                !user.getAvatarUrl().isEmpty())
                                                                                                { %>
                                                                                                <img src="<%= user.getAvatarUrl() %>"
                                                                                                    alt="Avatar">
                                                                                                <% } else { %>
                                                                                                    <div
                                                                                                        class="highlight-avatar-placeholder">
                                                                                                        <%= initials %>
                                                                                                    </div>
                                                                                                    <% } %>
                                                                                                        <label
                                                                                                            class="btn-avatar-camera"
                                                                                                            title="Thay đổi ảnh đại diện"
                                                                                                            onclick="document.getElementById('avatarFileInput').click();">
                                                                                                            <svg width="14"
                                                                                                                height="14"
                                                                                                                viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="currentColor"
                                                                                                                stroke-width="2.5">
                                                                                                                <path
                                                                                                                    d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
                                                                                                                <circle
                                                                                                                    cx="12"
                                                                                                                    cy="13"
                                                                                                                    r="4" />
                                                                                                            </svg>
                                                                                                        </label>

                                                                                                        <!-- Form ngầm upload ảnh đại diện -->
                                                                                                        <form
                                                                                                            id="avatarUploadForm"
                                                                                                            action="${pageContext.request.contextPath}/profile"
                                                                                                            method="POST"
                                                                                                            enctype="multipart/form-data"
                                                                                                            style="display:none;">
                                                                                                            <input
                                                                                                                type="hidden"
                                                                                                                name="action"
                                                                                                                value="updateAvatar">
                                                                                                            <input
                                                                                                                type="file"
                                                                                                                id="avatarFileInput"
                                                                                                                name="avatarFile"
                                                                                                                accept="image/*"
                                                                                                                onchange="if(this.files.length > 0) { showToast('Đang tải ảnh lên...', 'info'); document.getElementById('avatarUploadForm').submit(); }">
                                                                                                        </form>
                                                                                        </div>
                                                                                        <div
                                                                                            class="highlight-user-info">
                                                                                            <h2>
                                                                                                <%= user !=null ?
                                                                                                    user.getDisplayName()
                                                                                                    : "Học viên HIPZI"
                                                                                                    %>
                                                                                            </h2>
                                                                                            <div class="highlight-meta-info"
                                                                                                style="margin-top:0.35rem;">
                                                                                                <svg width="14"
                                                                                                    height="14"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    stroke-width="2">
                                                                                                    <path
                                                                                                        d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                                                                                                    <circle cx="12"
                                                                                                        cy="10" r="3" />
                                                                                                </svg>
                                                                                                <span>Thành viên tích
                                                                                                    cực</span>
                                                                                            </div>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Nhóm Phải: Vai trò chính đưa lên ngang hàng -->
                                                                                    <div
                                                                                        style="display:flex; flex-direction:column; align-items:flex-end; text-align:right;">
                                                                                        <span
                                                                                            style="font-size:0.75rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.35rem;">Vai
                                                                                            trò chính</span>
                                                                                        <div class="highlight-user-roles"
                                                                                            style="margin:0;">
                                                                                            <% if (roles !=null &&
                                                                                                !roles.isEmpty()) { for
                                                                                                (Role r : roles) { %>
                                                                                                <span
                                                                                                    class="role-tag <%= r.getName() %>"
                                                                                                    style="font-size:0.85rem; padding:0.4rem 1.15rem; border-radius:2rem;">
                                                                                                    <%= r.getName().equals("student")
                                                                                                        ? "Học viên" :
                                                                                                        r.getName().equals("parent")
                                                                                                        ? "Phụ huynh" :
                                                                                                        r.getName().equals("teacher")
                                                                                                        ? "Giảng viên" :
                                                                                                        r.getName().equals("staff")
                                                                                                        ? "Nhân viên" :
                                                                                                        r.getName().equals("admin")
                                                                                                        ? "Quản trị" :
                                                                                                        r.getName() %>
                                                                                                </span>
                                                                                                <% }} else { %>
                                                                                                    <span
                                                                                                        class="role-tag student"
                                                                                                        style="font-size:0.85rem; padding:0.4rem 1.15rem; border-radius:2rem;">Học
                                                                                                        viên</span>
                                                                                                    <% } %>
                                                                                        </div>
                                                                                    </div>

                                                                                </div>

                                                                                <!-- Nhóm Thông tin cá nhân bên dưới trong cùng 1 khối -->
                                                                                <div>
                                                                                    <div class="card-header-layout"
                                                                                        style="padding:0 0 1.25rem 0; margin:0; border-bottom:none;">
                                                                                        <div class="card-header-title">
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path
                                                                                                    d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                                                                <circle cx="12" cy="7"
                                                                                                    r="4" />
                                                                                            </svg>
                                                                                            <span>Thông tin cá
                                                                                                nhân</span>
                                                                                        </div>
                                                                                        <button
                                                                                            onclick="switchTab('tab-edit')"
                                                                                            class="btn-card-edit"
                                                                                            title="Chuyển sang tab cập nhật">
                                                                                            <span>Chỉnh sửa</span>
                                                                                            <svg width="14" height="14"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path d="M12 20h9" />
                                                                                                <path
                                                                                                    d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                                            </svg>
                                                                                        </button>
                                                                                    </div>

                                                                                    <div class="card-body-grid"
                                                                                        style="padding:0; display:grid; grid-template-columns:repeat(2, 1fr); gap:1.25rem;">

                                                                                        <!-- Thẻ 1: Họ và tên hiển thị -->
                                                                                        <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #dcfce7; box-shadow:0 4px 12px rgba(16, 185, 129, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;"
                                                                                            onmouseover="this.style.transform='translateY(-2px)';"
                                                                                            onmouseout="this.style.transform='translateY(0)';">
                                                                                            <div
                                                                                                style="width:48px; height:48px; border-radius:50%; background:#ecfdf5; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#059669;">
                                                                                                <svg width="22"
                                                                                                    height="22"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    stroke-width="2.2">
                                                                                                    <path
                                                                                                        d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                                                                    <circle cx="12"
                                                                                                        cy="7" r="4" />
                                                                                                </svg>
                                                                                            </div>
                                                                                            <div
                                                                                                style="min-width:0; flex-grow:1;">
                                                                                                <span
                                                                                                    style="font-size:0.75rem; font-weight:700; color:#059669; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Họ
                                                                                                    và tên hiển
                                                                                                    thị</span>
                                                                                                <span
                                                                                                    style="font-size:1.15rem; font-weight:700; color:#0f172a; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                                                                                                    <%= user !=null ?
                                                                                                        user.getDisplayName()
                                                                                                        : "—" %>
                                                                                                </span>
                                                                                                <span
                                                                                                    style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.1rem;">Thành
                                                                                                    viên hệ thống</span>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- Thẻ 2: Ngày tham gia -->
                                                                                        <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #e0e7ff; box-shadow:0 4px 12px rgba(99, 102, 241, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;"
                                                                                            onmouseover="this.style.transform='translateY(-2px)';"
                                                                                            onmouseout="this.style.transform='translateY(0)';">
                                                                                            <div
                                                                                                style="width:48px; height:48px; border-radius:50%; background:#e0e7ff; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#4f46e5;">
                                                                                                <svg width="22"
                                                                                                    height="22"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    stroke-width="2.2">
                                                                                                    <rect x="3" y="4"
                                                                                                        width="18"
                                                                                                        height="18"
                                                                                                        rx="2" ry="2" />
                                                                                                    <line x1="16" y1="2"
                                                                                                        x2="16"
                                                                                                        y2="6" />
                                                                                                    <line x1="8" y1="2"
                                                                                                        x2="8" y2="6" />
                                                                                                    <line x1="3" y1="10"
                                                                                                        x2="21"
                                                                                                        y2="10" />
                                                                                                </svg>
                                                                                            </div>
                                                                                            <div
                                                                                                style="min-width:0; flex-grow:1;">
                                                                                                <span
                                                                                                    style="font-size:0.75rem; font-weight:700; color:#4f46e5; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Ngày
                                                                                                    tham gia</span>
                                                                                                <span
                                                                                                    style="font-size:1.15rem; font-weight:700; color:#0f172a; display:block;">
                                                                                                    <%= joinDate %>
                                                                                                </span>
                                                                                                <span
                                                                                                    style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.1rem;">Thời
                                                                                                    gian kích
                                                                                                    hoạt</span>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- Thẻ 3: Địa chỉ Email -->
                                                                                        <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #fef3c7; box-shadow:0 4px 12px rgba(245, 158, 11, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;"
                                                                                            onmouseover="this.style.transform='translateY(-2px)';"
                                                                                            onmouseout="this.style.transform='translateY(0)';">
                                                                                            <div
                                                                                                style="width:48px; height:48px; border-radius:50%; background:#fffbeb; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#d97706;">
                                                                                                <svg width="22"
                                                                                                    height="22"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    stroke-width="2.2">
                                                                                                    <path
                                                                                                        d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                                                                                                    <polyline
                                                                                                        points="22,6 12,13 2,6" />
                                                                                                </svg>
                                                                                            </div>
                                                                                            <div
                                                                                                style="min-width:0; flex-grow:1;">
                                                                                                <span
                                                                                                    style="font-size:0.75rem; font-weight:700; color:#d97706; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Địa
                                                                                                    chỉ Email</span>
                                                                                                <span
                                                                                                    style="font-size:1.05rem; font-weight:700; color:#0f172a; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"
                                                                                                    title="<%= user != null ? user.getEmail() : "" %>">
                                                                                                    <%= user !=null ?
                                                                                                        user.getEmail()
                                                                                                        : "—" %>
                                                                                                </span>
                                                                                                <span
                                                                                                    style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.1rem;">Tài
                                                                                                    khoản liên
                                                                                                    kết</span>
                                                                                            </div>
                                                                                        </div>

                                                                                        <!-- Thẻ 4: Trạng thái tài khoản -->
                                                                                        <div style="background:#ffffff; border-radius:1.25rem; padding:1.25rem 1.35rem; border:1px solid #fee2e2; box-shadow:0 4px 12px rgba(239, 68, 68, 0.03); display:flex; align-items:center; gap:1rem; transition:transform 0.2s ease;"
                                                                                            onmouseover="this.style.transform='translateY(-2px)';"
                                                                                            onmouseout="this.style.transform='translateY(0)';">
                                                                                            <div
                                                                                                style="width:48px; height:48px; border-radius:50%; background:#fef2f2; display:flex; justify-content:center; align-items:center; flex-shrink:0; color:#ef4444;">
                                                                                                <svg width="22"
                                                                                                    height="22"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    stroke-width="2.2">
                                                                                                    <path
                                                                                                        d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                                                </svg>
                                                                                            </div>
                                                                                            <div
                                                                                                style="min-width:0; flex-grow:1;">
                                                                                                <span
                                                                                                    style="font-size:0.75rem; font-weight:700; color:#ef4444; text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.15rem;">Trạng
                                                                                                    thái tài
                                                                                                    khoản</span>
                                                                                                <div>
                                                                                                    <% String
                                                                                                        status=(user
                                                                                                        !=null) ?
                                                                                                        user.getAccountStatus()
                                                                                                        : "active" ; %>
                                                                                                        <span
                                                                                                            class="acc-status-tag <%= status %>"
                                                                                                            style="display:inline-block; font-size:0.8rem; padding:0.25rem 0.75rem; margin-top:0.1rem;">
                                                                                                            <%= "active"
                                                                                                                .equals(status)
                                                                                                                ? "Đang hoạt động"
                                                                                                                : "suspended"
                                                                                                                .equals(status)
                                                                                                                ? "Tạm khóa"
                                                                                                                : "Vô hiệu hóa"
                                                                                                                %>
                                                                                                        </span>
                                                                                                </div>
                                                                                                <span
                                                                                                    style="font-size:0.75rem; color:#64748b; display:block; margin-top:0.2rem;">Bảo
                                                                                                    mật hệ thống</span>
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
                                                                    <section id="tab-edit" class="tab-pane <%= "tab-edit".equals(activeTab) ? "active-pane" : "" %>">
                                                                        <!-- Bảng Header Tích hợp liền khối cho Cập nhật thông tin -->
                                                                        <div class="profile-tab-panel">
                                                                            <div class="profile-tab-body">
                                                                                <div class="section-data-card profile-tab-fill-card"
                                                                                    style="box-shadow:none; border:none; padding:0; margin:0;">
                                                                                    <div class="card-header-layout">
                                                                                        <div class="card-header-title">
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path d="M12 20h9" />
                                                                                                <path
                                                                                                    d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                                            </svg>
                                                                                            <span>Cập nhật thông tin học
                                                                                                viên</span>
                                                                                        </div>
                                                                                        <button
                                                                                            onclick="switchTab('tab-profile')"
                                                                                            class="btn-card-edit-light">
                                                                                            <span>Quay lại</span>
                                                                                        </button>
                                                                                    </div>

                                                                                    <form
                                                                                        action="${pageContext.request.contextPath}/profile"
                                                                                        method="POST"
                                                                                        class="form-edit-layout">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="updateName">
                                                                                        <div class="form-group-edit">
                                                                                            <label>Họ và tên hiển
                                                                                                thị</label>
                                                                                            <input type="text"
                                                                                                name="displayName"
                                                                                                required
                                                                                                value="<%= user != null ? user.getDisplayName() : "" %>"
                                                                                                placeholder="Nhập họ và tên của bạn...">
                                                                                        </div>

                                                                                        <div class="form-actions-row">
                                                                                            <button type="button"
                                                                                                class="btn btn-ghost"
                                                                                                onclick="switchTab('tab-profile')">Hủy
                                                                                                bỏ</button>
                                                                                            <button type="submit"
                                                                                                class="btn btn-primary"
                                                                                                style="border-radius:0.75rem;">Lưu
                                                                                                thay đổi</button>
                                                                                        </div>
                                                                                    </form>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </section>

                                                                    <!-- ========================================== -->
                                                                    <!-- TAB 3: BẢO MẬT VÀ MẬT KHẨU                 -->
                                                                    <!-- ========================================== -->
                                                                    <section id="tab-security" class="tab-pane <%= "tab-security".equals(activeTab) ? "active-pane" : "" %>">
                                                                        <!-- Bảng Header Tích hợp liền khối cho Bảo mật và mật khẩu -->
                                                                        <div class="profile-tab-panel">
                                                                            <div class="profile-tab-body">
                                                                                <!-- KHUNG CHÍNH TOP: MẬT KHẨU ĐĂNG NHẬP -->
                                                                                <div
                                                                                    style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 4px 12px rgba(0, 0, 0, 0.02); overflow:hidden;">
                                                                                    <div
                                                                                        style="padding:2rem; display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:1.25rem;">
                                                                                        <div>
                                                                                            <span
                                                                                                style="font-weight:800; font-size:1.15rem; color:#b45309; letter-spacing:0.5px; text-transform:uppercase; display:block;">Mật
                                                                                                khẩu đăng nhập</span>
                                                                                            <p
                                                                                                style="font-size:0.85rem; color:var(--text-muted); margin:0.35rem 0 0 0;">
                                                                                                Cập nhật mật khẩu định
                                                                                                kỳ để bảo mật tốt hơn.
                                                                                            </p>
                                                                                        </div>
                                                                                        <button type="button"
                                                                                            onclick="document.getElementById('pwd-modal-overlay').style.display='flex';"
                                                                                            style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease;"
                                                                                            onmouseover="this.style.background='#047857'; this.style.transform='translateY(-1px)';"
                                                                                            onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                                                                            <span>Đổi mật khẩu</span>
                                                                                            <svg width="15" height="15"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path d="M12 20h9" />
                                                                                                <path
                                                                                                    d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                                            </svg>
                                                                                        </button>
                                                                                    </div>

                                                                                    <div
                                                                                        style="padding:1rem 1.75rem; border-top:1px solid var(--border-dark); background:rgba(248, 250, 252, 0.4); display:flex; align-items:center; gap:1.5rem; flex-wrap:wrap;">
                                                                                        <div
                                                                                            style="display:flex; align-items:center; gap:0.4rem; color:#10b981; font-weight:700; font-size:0.85rem;">
                                                                                            <svg width="16" height="16"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path
                                                                                                    d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                                            </svg>
                                                                                            <span>Mật khẩu mạnh</span>
                                                                                        </div>
                                                                                        <div style="display:flex; align-items:center; gap:0.4rem; color:<%= (user != null && user.isTwoFactorEnabled()) ? "#10b981" : "var(--text-muted)" %>; font-weight:700; font-size:0.85rem;">
                                                                                            <% if (user !=null &&
                                                                                                user.isTwoFactorEnabled())
                                                                                                { %>
                                                                                                <svg width="16"
                                                                                                    height="16"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    stroke-width="2.5">
                                                                                                    <path
                                                                                                        d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                                                                                                    <polyline
                                                                                                        points="22 4 12 14.01 9 11.01" />
                                                                                                </svg>
                                                                                                <span>Xác thực 2 lớp:
                                                                                                    Đang bật</span>
                                                                                                <% } else { %>
                                                                                                    <svg width="16"
                                                                                                        height="16"
                                                                                                        viewBox="0 0 24 24"
                                                                                                        fill="none"
                                                                                                        stroke="currentColor"
                                                                                                        stroke-width="2">
                                                                                                        <circle cx="12"
                                                                                                            cy="12"
                                                                                                            r="10" />
                                                                                                        <line x1="8"
                                                                                                            y1="12"
                                                                                                            x2="16"
                                                                                                            y2="12" />
                                                                                                    </svg>
                                                                                                    <span>Xác thực 2
                                                                                                        lớp: Tắt</span>
                                                                                                    <% } %>
                                                                                        </div>
                                                                                    </div>
                                                                                </div>

                                                                                <!-- LƯỚI HAI KHUNG CON BÊN DƯỚI -->
                                                                                <div
                                                                                    style="display:grid; grid-template-columns:repeat(auto-fit, minmax(280px, 1fr)); gap:1.5rem; flex:1; min-height:0;">

                                                                                    <!-- KHUNG TRÁI: BẢO MẬT 2 LỚP (OTP) -->
                                                                                    <div
                                                                                        style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 4px 12px rgba(0, 0, 0, 0.02); padding:1.75rem; display:flex; flex-direction:column; justify-content:center; gap:1.5rem;">
                                                                                        <div
                                                                                            style="display:flex; justify-content:space-between; align-items:flex-start;">
                                                                                            <span
                                                                                                style="font-weight:800; font-size:0.9rem; color:var(--text-main); text-transform:uppercase; letter-spacing:0.5px;">Bảo
                                                                                                mật 2 lớp (OTP)</span>
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="#d97706"
                                                                                                stroke-width="2">
                                                                                                <path
                                                                                                    d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                                            </svg>
                                                                                        </div>
                                                                                        <div
                                                                                            style="display:flex; justify-content:space-between; align-items:center;">
                                                                                            <span
                                                                                                style="font-weight:700; font-size:0.95rem; color:var(--text-main);">Mã
                                                                                                OTP qua Email</span>

                                                                                            <!-- Form ngầm xử lý toggle 2FA -->
                                                                                            <form id="toggle2faForm"
                                                                                                action="${pageContext.request.contextPath}/profile"
                                                                                                method="POST"
                                                                                                style="display:none;">
                                                                                                <input type="hidden"
                                                                                                    name="action"
                                                                                                    value="toggle2FA">
                                                                                            </form>

                                                                                            <!-- NÚT TOGGLE SWITCH THỰC TẾ -->
                                                                                            <% boolean is2fa=(user
                                                                                                !=null &&
                                                                                                user.isTwoFactorEnabled());
                                                                                                %>
                                                                                                <div id="otp-toggle-btn"
                                                                                                    onclick="document.getElementById('toggle2faForm').submit();"
                                                                                                    style="width:44px; height:24px; background:<%= is2fa ? "#10b981" : "#cbd5e1" %>; border-radius:12px; padding:2px; cursor:pointer; transition:background 0.3s ease; display:flex; align-items:center;">
                                                                                                   <div class="toggle-circle"
                                                                                                        style="width:20px; height:20px; background:#ffffff; border-radius:50%; box-shadow:0 1px 3px rgba(0,0,0,0.2); transition:transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform:translateX(<%= is2fa ? "20px" : "0" %>);"></div>
                                                                                                </div>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- KHUNG PHẢI: THIẾT BỊ HIỆN TẠI -->
                                                                                    <div
                                                                                        style="background:#ffffff; border-radius:1.25rem; border:1px solid rgba(226, 232, 240, 0.9); box-shadow:0 4px 12px rgba(0, 0, 0, 0.02); padding:1.75rem; display:flex; flex-direction:column; justify-content:center; gap:1.5rem;">
                                                                                        <div
                                                                                            style="display:flex; justify-content:space-between; align-items:flex-start;">
                                                                                            <span
                                                                                                style="font-weight:800; font-size:0.9rem; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px;">Thiết
                                                                                                bị hiện tại</span>
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="#d97706"
                                                                                                stroke-width="2">
                                                                                                <rect x="2" y="3"
                                                                                                    width="20"
                                                                                                    height="14" rx="2"
                                                                                                    ry="2" />
                                                                                                <line x1="8" y1="21"
                                                                                                    x2="16" y2="21" />
                                                                                                <line x1="12" y1="17"
                                                                                                    x2="12" y2="21" />
                                                                                            </svg>
                                                                                        </div>
                                                                                        <div>
                                                                                            <span
                                                                                                style="font-weight:800; font-size:1.1rem; color:var(--text-main); display:block;">Windows
                                                                                                - Chrome
                                                                                                (Vietnam)</span>
                                                                                            <span
                                                                                                style="font-size:0.75rem; color:#10b981; font-weight:600; display:inline-block; margin-top:0.25rem; background:#ecfdf5; padding:0.15rem 0.5rem; border-radius:0.25rem;">Phiên
                                                                                                truy cập an toàn</span>
                                                                                        </div>
                                                                                    </div>

                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </section>

                                                                    <!-- ========================================== -->
                                                                    <!-- TAB 4: TÀI LIỆU ĐÃ LƯU                     -->
                                                                    <!-- ========================================== -->
                                                                    <section id="tab-materials" class="tab-pane <%= "tab-materials".equals(activeTab) ? "active-pane" : "" %>">
                                                                        <!-- Bảng Header Tích hợp liền khối cho Tài liệu đã lưu -->
                                                                        <div class="profile-tab-panel">
                                                                            <div class="profile-tab-body">
                                                                                <div class="section-data-card profile-tab-fill-card"
                                                                                    style="box-shadow:none; border:none; padding:0; margin:0;">
                                                                                    <div class="card-header-layout">
                                                                                        <div class="card-header-title">
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path
                                                                                                    d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
                                                                                            </svg>
                                                                                            <span>Kho tài liệu yêu thích
                                                                                                của học viên</span>
                                                                                        </div>
                                                                                        <a href="${pageContext.request.contextPath}/material-repository"
                                                                                            style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease; text-decoration:none;"
                                                                                            onmouseover="this.style.background='#047857'; this.style.transform='translateY(-1px)';"
                                                                                            onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                                                                            <span>Khám phá thêm</span>
                                                                                            <svg width="15" height="15"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path d="M12 20h9" />
                                                                                                <path
                                                                                                    d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                                            </svg>
                                                                                        </a>
                                                                                    </div>
                                                                                    <div class="empty-status-panel"
                                                                                        style="flex:1; justify-content:center;">
                                                                                        <svg width="64" height="64"
                                                                                            viewBox="0 0 24 24"
                                                                                            fill="none"
                                                                                            stroke="currentColor"
                                                                                            stroke-width="1.5">
                                                                                            <path
                                                                                                d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                                                                            <path
                                                                                                d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
                                                                                        </svg>
                                                                                        <span
                                                                                            style="font-weight:700; color:var(--text-main);">Chưa
                                                                                            có tài liệu nào được
                                                                                            lưu</span>
                                                                                        <p
                                                                                            style="font-size:0.85rem; max-width:400px; margin:0;">
                                                                                            Hãy nhấp vào biểu tượng lưu
                                                                                            trữ trên các tài liệu bài
                                                                                            giảng chất lượng để dễ dàng
                                                                                            ôn tập lại tại đây.</p>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </section>

                                                                    <!-- ========================================== -->
                                                                    <!-- TAB 6: THÔNG BÁO HỆ THỐNG                  -->
                                                                    <!-- ========================================== -->
                                                                    <section id="tab-notifications" class="tab-pane <%= "tab-notifications".equals(activeTab) ? "active-pane" : "" %>">
                                                                        <!-- Bảng nội dung Thông báo hệ thống -->
                                                                        <div
                                                                            style="height:100%; overflow:hidden; display:flex; flex-direction:column;">
                                                                            <div
                                                                                style="background:linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); padding:1.75rem; flex:1; min-height:0; overflow-y:auto;">
                                                                                <div class="section-data-card"
                                                                                    style="box-shadow:none; border:none; padding:0; margin:0;">
                                                                                    <div class="card-header-layout">
                                                                                        <div class="card-header-title">
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <path
                                                                                                    d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
                                                                                                <path
                                                                                                    d="M13.73 21a2 2 0 0 1-3.46 0" />
                                                                                            </svg>
                                                                                            <span>Thông báo hệ thống
                                                                                                dành cho học viên</span>
                                                                                        </div>
                                                                                        <span
                                                                                            style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">Mới
                                                                                            nhất</span>
                                                                                    </div>

                                                                                    <div
                                                                                        style="padding:1.5rem; display:flex; flex-direction:column; gap:1rem;">
                                                                                        <% if (notifications !=null &&
                                                                                            !notifications.isEmpty()) {
                                                                                            SimpleDateFormat sdf=new
                                                                                            SimpleDateFormat("dd/MM/yyyy");
                                                                                            for (Notification n :
                                                                                            notifications) { String
                                                                                            typeColor="var(--primary)" ;
                                                                                            String bgColor="#f0fdf4" ;
                                                                                            String iconPath="M20 6 9 17l-5-5";
                                                                                            if ("warning".equalsIgnoreCase(n.getType())) {
                                                                                                typeColor="#f59e0b";
                                                                                                bgColor="#fffbeb";
                                                                                                iconPath="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z";
                                                                                            } else if ("error".equalsIgnoreCase(n.getType())) {
                                                                                                typeColor="#ef4444";
                                                                                                bgColor="#fef2f2";
                                                                                                iconPath="M12 8v4m0 4h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z";
                                                                                            } else if ("info".equalsIgnoreCase(n.getType())) {
                                                                                                typeColor="#0ea5e9";
                                                                                                bgColor="#f0f9ff";
                                                                                                iconPath="M12 16v-4m0-4h.01M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z";
                                                                                            } %>
                                                                                            <div
                                                                                                style="padding:1rem 1.25rem; border-radius:0.75rem; background:<%= bgColor %>; border-left:4px solid <%= typeColor %>; display:flex; gap:1rem; align-items:flex-start;">
                                                                                                <svg width="20"
                                                                                                    height="20"
                                                                                                    viewBox="0 0 24 24"
                                                                                                    fill="none"
                                                                                                    stroke="<%= typeColor %>"
                                                                                                    stroke-width="2.5"
                                                                                                    style="flex-shrink:0; margin-top:0.15rem;">
                                                                                                    <path
                                                                                                        d="<%= iconPath %>" />
                                                                                                </svg>
                                                                                                <div>
                                                                                                    <span
                                                                                                        style="font-weight:700; font-size:0.95rem; color:var(--text-main); display:block;">
                                                                                                        <%= n.getTitle()
                                                                                                            %>
                                                                                                    </span>
                                                                                                    <p
                                                                                                        style="font-size:0.85rem; color:var(--text-muted); margin:0.25rem 0 0 0;">
                                                                                                        <%= n.getMessage()
                                                                                                            %>
                                                                                                    </p>
                                                                                                    <span
                                                                                                        style="font-size:0.75rem; color:#94a3b8; display:block; margin-top:0.35rem;">
                                                                                                        <%= sdf.format(n.getCreatedAt())
                                                                                                            %>
                                                                                                    </span>
                                                                                                </div>
                                                                                            </div>
                                                                                            <% } } else { %>
                                                                                                <div
                                                                                                    class="empty-status-panel">
                                                                                                    <svg width="48"
                                                                                                        height="48"
                                                                                                        viewBox="0 0 24 24"
                                                                                                        fill="none"
                                                                                                        stroke="currentColor"
                                                                                                        stroke-width="1.5">
                                                                                                        <path
                                                                                                            d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
                                                                                                        <path
                                                                                                            d="M13.73 21a2 2 0 0 1-3.46 0" />
                                                                                                    </svg>
                                                                                                    <span
                                                                                                        style="font-weight:700; color:var(--text-main);">Không
                                                                                                        có thông báo
                                                                                                        nào</span>
                                                                                                    <p
                                                                                                        style="font-size:0.85rem; max-width:400px; margin:0;">
                                                                                                        Bạn sẽ nhận được
                                                                                                        thông báo về các
                                                                                                        cập nhật hệ
                                                                                                        thống, kết quả
                                                                                                        luyện tập và tin
                                                                                                        nhắn từ ban quản
                                                                                                        trị tại đây.</p>
                                                                                                </div>
                                                                                                <% } %>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </section>

                                                                    <!-- ========================================== -->
                                                                    <!-- TAB 7: HỖ TRỢ HỌC TẬP                      -->
                                                                    <!-- ========================================== -->
                                                                    <section id="tab-support" class="tab-pane <%= "tab-support".equals(activeTab) ? "active-pane" : "" %>">
                                                                        <!-- Bảng Header Tích hợp liền khối cho Hỗ trợ học tập -->
                                                                        <div class="profile-tab-panel">
                                                                            <div class="profile-tab-body">
                                                                                <div class="section-data-card profile-tab-fill-card"
                                                                                    style="box-shadow:none; border:none; padding:0; margin:0;">
                                                                                    <div class="card-header-layout">
                                                                                        <div class="card-header-title">
                                                                                            <svg width="20" height="20"
                                                                                                viewBox="0 0 24 24"
                                                                                                fill="none"
                                                                                                stroke="currentColor"
                                                                                                stroke-width="2.5">
                                                                                                <circle cx="12" cy="12"
                                                                                                    r="10" />
                                                                                                <path
                                                                                                    d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                                                                                                <line x1="12" y1="17"
                                                                                                    x2="12.01"
                                                                                                    y2="17" />
                                                                                            </svg>
                                                                                            <span>Trung tâm Hỗ trợ &
                                                                                                Giải đáp thắc mắc</span>
                                                                                        </div>
                                                                                    </div>

                                                                                    <div
                                                                                        style="padding:1.75rem; display:grid; grid-template-columns:1fr 1fr; gap:1.75rem; flex:1; min-height:0;">
                                                                                        <div
                                                                                            style="display:flex; flex-direction:column; justify-content:flex-start;">
                                                                                            <span
                                                                                                style="font-weight:800; font-size:1.15rem; color:var(--text-main); display:block; margin-bottom:1rem;">Câu
                                                                                                hỏi thường gặp</span>
                                                                                            <div
                                                                                                style="display:flex; flex-direction:column; gap:1rem;">
                                                                                                <details
                                                                                                    style="background:#f1f5f9; padding:1rem 1.1rem; border-radius:0.8rem; cursor:pointer;">
                                                                                                    <summary
                                                                                                        style="font-weight:700; font-size:0.85rem; color:var(--text-main);">
                                                                                                        Làm thế nào để
                                                                                                        tải xuống bài
                                                                                                        giảng?</summary>
                                                                                                    <p
                                                                                                        style="font-size:0.8rem; color:var(--text-muted); margin:0.5rem 0 0 0;">
                                                                                                        Học viên có thể
                                                                                                        tải xuống các
                                                                                                        file đính kèm
                                                                                                        miễn phí khi tài
                                                                                                        liệu đã được
                                                                                                        duyệt và chuyển
                                                                                                        sang chế độ hiển
                                                                                                        thị công khai.
                                                                                                    </p>
                                                                                                </details>

                                                                                                <details
                                                                                                    style="background:#f1f5f9; padding:1rem 1.1rem; border-radius:0.8rem; cursor:pointer;">
                                                                                                    <summary
                                                                                                        style="font-weight:700; font-size:0.85rem; color:var(--text-main);">
                                                                                                        AI tạo câu hỏi
                                                                                                        ôn tập hoạt động
                                                                                                        ra sao?
                                                                                                    </summary>
                                                                                                    <p
                                                                                                        style="font-size:0.8rem; color:var(--text-muted); margin:0.5rem 0 0 0;">
                                                                                                        Trợ lý AI phân
                                                                                                        tích văn bản từ
                                                                                                        tài liệu gốc do
                                                                                                        Giảng viên cung
                                                                                                        cấp để bóc tách
                                                                                                        thành các bộ
                                                                                                        Flashcard trực
                                                                                                        quan cho học
                                                                                                        viên luyện tập.
                                                                                                    </p>
                                                                                                </details>

                                                                                            </div>
                                                                                        </div>

                                                                                        <div
                                                                                            style="padding:1.5rem; border-radius:1.1rem; border:1px solid #e2e8f0; background:#ffffff; display:flex; flex-direction:column; justify-content:center;">
                                                                                            <span
                                                                                                style="font-weight:800; font-size:1.05rem; color:var(--text-main); display:block; margin-bottom:0.75rem;">Gửi
                                                                                                yêu cầu hỗ trợ trực
                                                                                                tiếp</span>
                                                                                            <form id="supportForm"
                                                                                                style="display:flex; flex-direction:column; gap:1rem;">
                                                                                                <input type="text"
                                                                                                    name="title"
                                                                                                    required
                                                                                                    placeholder="Tiêu đề cần hỗ trợ..."
                                                                                                    style="padding:0.8rem 1rem; border-radius:0.7rem; border:1px solid var(--border-dark); font-size:0.9rem; outline:none;">
                                                                                                <textarea name="content"
                                                                                                    rows="5" required
                                                                                                    placeholder="Mô tả chi tiết khó khăn bạn đang gặp phải..."
                                                                                                    style="padding:0.8rem 1rem; border-radius:0.7rem; border:1px solid var(--border-dark); font-size:0.9rem; outline:none; resize:none;"></textarea>
                                                                                                <button type="submit"
                                                                                                    class="btn btn-primary"
                                                                                                    style="padding:0.75rem; border-radius:0.7rem; font-size:0.9rem;">Gửi
                                                                                                    tin nhắn</button>
                                                                                            </form>
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </section>

                                                        </main>

                                                        </div><!-- /dashboard-body -->

                                                    </div><!-- /app-dashboard-container -->

                                                    <!-- ========================================================== -->
                                                    <!-- BANNER CỘNG ĐỒNG HIPZI (CHÍNH GIỮA FULL-WIDTH TOÀN TRANG)  -->
                                                    <!-- ========================================================== -->
                                                    <div
                                                        style="max-width:1320px; width:100%; margin:3rem auto 5rem auto; padding:0 1.5rem;">
                                                        <div class="community-engagement-banner"
                                                            style="background:#ffffff; border-radius:1.5rem; border:1px solid #e2e8f0; box-shadow:0 10px 30px rgba(0, 0, 0, 0.03); padding:2.5rem; display:flex; flex-direction:column; gap:1.75rem; position:relative; overflow:hidden;">

                                                            <!-- Dải lấp lánh trang trí góc phải -->
                                                            <div
                                                                style="position:absolute; top:0; right:0; width:350px; height:350px; background:radial-gradient(circle, rgba(5, 150, 105, 0.05) 0%, transparent 70%); pointer-events:none;">
                                                            </div>

                                                            <div
                                                                style="display:flex; flex-direction:column; gap:1.25rem; z-index:1;">
                                                                <!-- Badge Hỗ trợ / Cộng đồng -->
                                                                <div>
                                                                    <span
                                                                        style="display:inline-flex; align-items:center; gap:0.4rem; background:#ecfdf5; color:#059669; font-weight:800; font-size:0.75rem; padding:0.4rem 1rem; border-radius:2rem; letter-spacing:0.5px; text-transform:uppercase;">
                                                                        <svg width="14" height="14" viewBox="0 0 24 24"
                                                                            fill="none" stroke="currentColor"
                                                                            stroke-width="2.5">
                                                                            <path
                                                                                d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                        </svg>
                                                                        Hỗ trợ học tập 24/7
                                                                    </span>
                                                                </div>

                                                                <!-- Hàng Flex chính chia 2 cột -->
                                                                <div
                                                                    style="display:flex; flex-direction:row; justify-content:space-between; align-items:center; gap:2.5rem; flex-wrap:wrap;">

                                                                    <!-- Cột Trái: Tiêu đề & Lời kêu gọi -->
                                                                    <div
                                                                        style="flex:1; min-width:320px; display:flex; flex-direction:column; gap:1rem; text-align:left;">
                                                                        <h3
                                                                            style="font-weight:800; font-size:2.15rem; color:#0f172a; line-height:1.25; margin:0; letter-spacing:-0.5px;">
                                                                            Tham Gia <span
                                                                                style="background:linear-gradient(135deg, rgb(4, 120, 87) 0%, rgb(16, 185, 129) 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; font-style:italic;">Cộng
                                                                                Đồng HIPZI?</span>
                                                                        </h3>
                                                                        <p
                                                                            style="font-size:0.95rem; color:#475569; line-height:1.55; margin:0; max-width:550px;">
                                                                            Đừng ngần ngại kết nối với đội ngũ giảng
                                                                            viên và cộng đồng học viên để cùng trao đổi
                                                                            kiến thức, định hướng lộ trình học tập phù
                                                                            hợp và hiệu quả nhất với bản thân.
                                                                        </p>

                                                                        <!-- Hàng Nút Hành động CTA -->
                                                                        <div
                                                                            style="display:flex; align-items:center; gap:0.85rem; margin-top:0.5rem; flex-wrap:wrap;">
                                                                            <a href="https://zalo.me/g/hipzi2024"
                                                                                target="_blank"
                                                                                style="background:#059669; color:#ffffff; font-weight:700; font-size:0.85rem; padding:0.85rem 1.75rem; border-radius:0.75rem; text-decoration:none; display:inline-flex; align-items:center; gap:0.5rem; box-shadow:0 4px 12px rgba(5, 150, 105, 0.25); transition:all 0.2s ease; letter-spacing:0.5px;"
                                                                                onmouseover="this.style.background='#047857'; this.style.transform='translateY(-2px)';"
                                                                                onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                                                                <svg width="16" height="16"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor"
                                                                                    stroke-width="2.5">
                                                                                    <polygon
                                                                                        points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
                                                                                </svg>
                                                                                THAM GIA CỘNG ĐỒNG
                                                                            </a>
                                                                        </div>
                                                                    </div>

                                                                    <!-- Cột Phải: Khung Highlight Thông số bo tròn màu xám nhạt -->
                                                                    <div
                                                                        style="background:#f8fafc; border-radius:1.25rem; padding:1.5rem; border:1px solid #f1f5f9; display:flex; flex-direction:column; gap:1.25rem; min-width:260px;">

                                                                        <!-- Thông số 1 -->
                                                                        <div
                                                                            style="display:flex; align-items:center; gap:1rem;">
                                                                            <div
                                                                                style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#2563eb; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor"
                                                                                    stroke-width="2.2">
                                                                                    <path
                                                                                        d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                                                                                    <circle cx="9" cy="7" r="4" />
                                                                                    <path
                                                                                        d="M23 21v-2a4 4 0 0 0-3-3.87" />
                                                                                    <path
                                                                                        d="M16 3.13a4 4 0 0 1 0 7.75" />
                                                                                </svg>
                                                                            </div>
                                                                            <div
                                                                                style="display:flex; flex-direction:column; text-align:left;">
                                                                                <span
                                                                                    style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">GIẢNG
                                                                                    VIÊN ONLINE</span>
                                                                                <span
                                                                                    style="font-size:1.05rem; font-weight:800; color:#0f172a;">Hơn
                                                                                    50+ Mentor</span>
                                                                            </div>
                                                                        </div>

                                                                        <div style="height:1px; background:#f1f5f9;">
                                                                        </div>

                                                                        <!-- Thông số 2 -->
                                                                        <div
                                                                            style="display:flex; align-items:center; gap:1rem;">
                                                                            <div
                                                                                style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#10b981; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                                                <svg width="20" height="20"
                                                                                    viewBox="0 0 24 24" fill="none"
                                                                                    stroke="currentColor"
                                                                                    stroke-width="2.2">
                                                                                    <circle cx="12" cy="12" r="10" />
                                                                                    <line x1="2" y1="12" x2="22"
                                                                                        y2="12" />
                                                                                    <path
                                                                                        d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
                                                                                </svg>
                                                                            </div>
                                                                            <div
                                                                                style="display:flex; flex-direction:column; text-align:left;">
                                                                                <span
                                                                                    style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">CỘNG
                                                                                    ĐỒNG HỌC VIÊN</span>
                                                                                <span
                                                                                    style="font-size:1.05rem; font-weight:800; color:#0f172a;">2000+
                                                                                    Thành viên</span>
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

                                                        function copyStudentCode(code) {
                                                            code = (code || '').trim();
                                                            if (!code) return;

                                                            const notifyCopied = () => showToast('Đã sao chép mã học viên: ' + code, 'success');
                                                            if (navigator.clipboard && window.isSecureContext) {
                                                                navigator.clipboard.writeText(code).then(notifyCopied).catch(() => fallbackCopyStudentCode(code, notifyCopied));
                                                                return;
                                                            }
                                                            fallbackCopyStudentCode(code, notifyCopied);
                                                        }

                                                        function fallbackCopyStudentCode(code, onDone) {
                                                            const input = document.createElement('textarea');
                                                            input.value = code;
                                                            input.setAttribute('readonly', '');
                                                            input.style.position = 'fixed';
                                                            input.style.opacity = '0';
                                                            document.body.appendChild(input);
                                                            input.select();
                                                            document.execCommand('copy');
                                                            input.remove();
                                                            onDone();
                                                        }

                                                        function getProfileTabSlug(tabId) {
                                                            return tabId.replace(/^tab-/, '');
                                                        }

                                                        function normalizeProfileTabId(tabValue) {
                                                            if (!tabValue) return '';
                                                            const normalized = tabValue.startsWith('tab-') ? tabValue : 'tab-' + tabValue;
                                                            return normalized === 'tab-practice' ? 'tab-dashboard' : normalized;
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

                                                        // Map tab IDs → Vietnamese titles for the unified header
                                                        const TAB_TITLES = {
                                                            'tab-dashboard':     'Tổng quan học tập',
                                                            'tab-profile':       'Hồ sơ cá nhân',
                                                            'tab-edit':          'Cập nhật thông tin học viên',
                                                            'tab-security':      'Bảo mật và mật khẩu',
                                                            'tab-materials':     'Tài liệu đã lưu',
                                                            'tab-notifications': 'Thông báo hệ thống',
                                                            'tab-support':       'Hỗ trợ học tập',
                                                        };

                                                        function updateUnifiedHeaderTitle(tabId) {
                                                            const el = document.getElementById('unified-header-title');
                                                            if (!el) return;
                                                            const title = TAB_TITLES[tabId] || '';
                                                            if (!title) return;
                                                            // Smooth fade swap
                                                            el.style.opacity = '0';
                                                            setTimeout(() => {
                                                                el.textContent = title;
                                                                el.style.opacity = '1';
                                                            }, 160);
                                                        }

                                                        function switchTab(targetTabId, options = {}) {
                                                            targetTabId = normalizeProfileTabId(targetTabId);
                                                            const targetPane = document.getElementById(targetTabId);
                                                            if (!targetPane || targetPane.classList.contains('active-pane')) {
                                                                let activeNav = document.getElementById('nav-' + targetTabId);
                                                                if (!activeNav && targetTabId === 'tab-edit') {
                                                                    activeNav = document.getElementById('nav-tab-profile');
                                                                }
                                                                if (activeNav) activeNav.classList.add('active');
                                                                const dashboard = document.querySelector('.app-dashboard-container');
                                                                if (dashboard) dashboard.classList.toggle('is-notifications-tab', targetTabId === 'tab-notifications');
                                                                if (targetPane && options.updateUrl) updateProfileTabUrl(targetTabId, options.replaceUrl);
                                                                return;
                                                            }
                                                            document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active-pane'));
                                                            document.querySelectorAll('.sidebar-menu a').forEach(link => link.classList.remove('active'));
                                                            targetPane.classList.add('active-pane');
                                                            const dashboard = document.querySelector('.app-dashboard-container');
                                                            if (dashboard) dashboard.classList.toggle('is-notifications-tab', targetTabId === 'tab-notifications');
                                                            const activeNav = document.getElementById('nav-' + targetTabId);
                                                            if (activeNav) activeNav.classList.add('active');
                                                            // Update unified header title
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
                                                                    showToast("<%= msg.replace("\"", "\\\"") %> ", " <%= type != null ? type : "success" %> ");
                                                                });
        <% } %>

                                                            window.addEventListener('DOMContentLoaded', () => {
                                                                const dashboardRoot = document.querySelector('.app-dashboard-container');
                                                                if (dashboardRoot) {
                                                                    dashboardRoot.style.display = 'flex';
                                                                    dashboardRoot.style.visibility = 'visible';
                                                                    dashboardRoot.style.opacity = '1';
                                                                    dashboardRoot.style.position = 'relative';
                                                                    dashboardRoot.style.zIndex = '1';
                                                                }
                                                                const params = new URLSearchParams(window.location.search);
                                                                const tabParam = params.get('tab');
                                                                if (tabParam) {
                                                                    switchTab(tabParam, { replaceUrl: true });
                                                                } else {
                                                                    const activePane = document.querySelector('.tab-pane.active-pane');
                                                                    if (activePane) updateProfileTabUrl(activePane.id, true);
                                                                }
                                                            });

                                                        window.addEventListener('popstate', (event) => {
                                                            const stateTab = event.state && event.state.profileTab;
                                                            const urlTab = new URLSearchParams(window.location.search).get('tab');
                                                            switchTab(stateTab || urlTab || 'tab-dashboard', { updateUrl: false });
                                                        });

                                                    </script>

                                                    <!-- ===== MODAL �?I M?T KH?U (PASSWORD UPDATE MODAL) ===== -->
                                                    <div id="pwd-modal-overlay"
                                                        style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15, 23, 42, 0.6); backdrop-filter:blur(4px); z-index:9999; display:none; justify-content:center; align-items:center; padding:1rem;">
                                                        <div
                                                            style="background:#ffffff; border-radius:1.5rem; width:100%; max-width:440px; padding:2rem; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1); border:1px solid #e2e8f0; animation:modalScaleUp 0.25s ease-out;">
                                                            <div
                                                                style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                                                                <div
                                                                    style="display:flex; align-items:center; gap:0.65rem;">
                                                                    <div
                                                                        style="width:36px; height:36px; border-radius:50%; background:#fef3c7; color:#d97706; display:flex; justify-content:center; align-items:center;">
                                                                        <svg width="18" height="18" viewBox="0 0 24 24"
                                                                            fill="none" stroke="currentColor"
                                                                            stroke-width="2.5">
                                                                            <rect x="3" y="11" width="18" height="11"
                                                                                rx="2" />
                                                                            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                                                                        </svg>
                                                                    </div>
                                                                    <span
                                                                        style="font-size:1.25rem; font-weight:800; color:var(--text-main);">Đổi
                                                                        mật khẩu</span>
                                                                </div>
                                                                <button type="button"
                                                                    onclick="document.getElementById('pwd-modal-overlay').style.display='none';"
                                                                    style="background:none; border:none; font-size:1.25rem; color:var(--text-muted); cursor:pointer;">&times;</button>
                                                            </div>

                                                            <form action="${pageContext.request.contextPath}/profile"
                                                                method="POST"
                                                                style="display:flex; flex-direction:column; gap:1.25rem;">
                                                                <input type="hidden" name="action"
                                                                    value="changePassword">

                                                                <div
                                                                    style="display:flex; flex-direction:column; gap:0.4rem;">
                                                                    <label
                                                                        style="font-size:0.85rem; font-weight:700; color:var(--text-main);">Mật
                                                                        khẩu hiện tại <span
                                                                            style="color:#ef4444;">*</span></label>
                                                                    <input type="password" name="currentPassword"
                                                                        required placeholder="••••••••"
                                                                        style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); font-size:0.95rem; outline:none; transition:border-color 0.2s ease;"
                                                                        onfocus="this.style.borderColor='var(--primary)';"
                                                                        onblur="this.style.borderColor='var(--border-dark)';">
                                                                </div>

                                                                <div
                                                                    style="display:flex; flex-direction:column; gap:0.4rem;">
                                                                    <label
                                                                        style="font-size:0.85rem; font-weight:700; color:var(--text-main);">Mật
                                                                        khẩu mới <span
                                                                            style="color:#ef4444;">*</span></label>
                                                                    <input type="password" name="newPassword" required
                                                                        minlength="6"
                                                                        placeholder="Mật khẩu ít nhất 6 ký tự"
                                                                        style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); font-size:0.95rem; outline:none; transition:border-color 0.2s ease;"
                                                                        onfocus="this.style.borderColor='var(--primary)';"
                                                                        onblur="this.style.borderColor='var(--border-dark)';">
                                                                </div>

                                                                <div
                                                                    style="display:flex; flex-direction:column; gap:0.4rem;">
                                                                    <label
                                                                        style="font-size:0.85rem; font-weight:700; color:var(--text-main);">Xác
                                                                        nhận mật khẩu mới <span
                                                                            style="color:#ef4444;">*</span></label>
                                                                    <input type="password" name="confirmPassword"
                                                                        required minlength="6"
                                                                        placeholder="Nhập lại mật khẩu mới"
                                                                        style="padding:0.75rem 1rem; border-radius:0.75rem; border:1px solid var(--border-dark); font-size:0.95rem; outline:none; transition:border-color 0.2s ease;"
                                                                        onfocus="this.style.borderColor='var(--primary)';"
                                                                        onblur="this.style.borderColor='var(--border-dark)';">
                                                                </div>

                                                                <div
                                                                    style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:0.5rem;">
                                                                    <button type="button"
                                                                        onclick="document.getElementById('pwd-modal-overlay').style.display='none';"
                                                                        style="padding:0.65rem 1.25rem; border-radius:0.75rem; background:#f1f5f9; color:var(--text-muted); font-weight:700; border:none; cursor:pointer;">Hủy
                                                                        bỏ</button>
                                                                    <button type="submit"
                                                                        style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease;"
                                                                        onmouseover="this.style.background='#047857'; this.style.transform='translateY(-1px)';"
                                                                        onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                                                        <span>Cập nhật ngay</span>
                                                                        <svg width="15" height="15" viewBox="0 0 24 24"
                                                                            fill="none" stroke="currentColor"
                                                                            stroke-width="2.5">
                                                                            <path d="M12 20h9" />
                                                                            <path
                                                                                d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                        </svg>
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>

                                                    <style>
                                                        @keyframes modalScaleUp {
                                                            from {
                                                                opacity: 0;
                                                                transform: scale(0.95);
                                                            }

                                                            to {
                                                                opacity: 1;
                                                                transform: scale(1);
                                                            }
                                                        }
                                                    </style>

                                                    <script>

                                                        // X? l� g?i form h? tr? h?c t?p qua Servlet
                                                        const supportForm = document.getElementById('supportForm');
                                                        if (supportForm) {
                                                            supportForm.addEventListener('submit', function (e) {
                                                                e.preventDefault();
                                                                const formData = new FormData(this);
                                                                const submitBtn = this.querySelector('button[type="submit"]');
                                                                const originalBtnText = submitBtn.innerText;

                                                                // Tr?ng th�i dang x? l�
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
                                                                        // Tr? l?i tr?ng th�i n�t
                                                                        submitBtn.disabled = false;
                                                                        submitBtn.innerText = originalBtnText;
                                                                    });
                                                            });
                                                        }
                                                        // --- WebSocket Tr?ng th�i Tr?c tuy?n ---
                                                        const initStatusWS = () => {
                                                            const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
                                                            const wsUrl = wsProtocol + '//' + window.location.host + '${pageContext.request.contextPath}/status-ws';
                                                            const statusWs = new WebSocket(wsUrl);

                                                            statusWs.onopen = () => {
                                                                console.log('Status WS Connected');
                <% if (user != null) { %>
                                                                    statusWs.send(JSON.stringify({ type: 'auth', userId: '<%= user.getId() %>' }));
                <% } %>
            };

                                                            statusWs.onclose = () => {
                                                                console.log('Status WS Disconnected. Retrying in 5s...');
                                                                setTimeout(initStatusWS, 5000);
                                                            };
                                                        };

                                                        window.addEventListener('load', initStatusWS);
                                                    </script>
                                                    <script
                                                        src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
                                </body>

                                </html>
