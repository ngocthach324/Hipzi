<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hipzi.model.User" %>
<%@ page import="com.hipzi.model.Role" %>
<%@ page import="com.hipzi.model.ParentStudentLink" %>
<%@ page import="com.hipzi.model.Notification" %>
<%@ page import="com.hipzi.util.UserStatusWebSocket" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Role> roles = (List<Role>) session.getAttribute("roles");
    List<ParentStudentLink> trackedStudents = (List<ParentStudentLink>) request.getAttribute("trackedStudents");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String joinDate = (user.getCreatedAt() != null) ? sdf.format(user.getCreatedAt()) : "N/A";
    String currentDateDisplay = sdf.format(new Date());
    // Lấy danh sách thông báo hệ thống
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");

    String initials = "";
    if (user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().split(" ");
        if (parts.length > 0) {
            initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
        }
    }

    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.trim().isEmpty()) {
        activeTab = "tab-tracking";
    } else {
        activeTab = activeTab.trim();
        if (!activeTab.startsWith("tab-")) {
            activeTab = "tab-" + activeTab;
        }
        if (!activeTab.equals("tab-tracking") &&
            !activeTab.equals("tab-profile") &&
            !activeTab.equals("tab-security") &&
            !activeTab.equals("tab-notifications") &&
            !activeTab.equals("tab-support")) {
            activeTab = "tab-tracking";
        }
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
    <title>Hồ sơ Phụ huynh | HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&display=block" rel="stylesheet">
    <style>
        :root {
            --primary: #059669; /* Green-Eco Theme */
            --primary-light: #ecfdf5;
            --primary-dark: #047857;
            --accent: #f59e0b;
            --bg-body: #f8fafc;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --border-light: #f1f5f9;
            --border-dark: #e2e8f0;
            --white: #ffffff;
            --font-sans: 'Be Vietnam Pro', sans-serif;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.02);
            --shadow-md: 0 10px 15px -3px rgba(0,0,0,0.05);
            --shadow-lg: 0 20px 25px -5px rgba(0,0,0,0.05);
            --radius-xl: 1.5rem;
            --radius-lg: 1rem;
            --radius-md: 0.75rem;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            -webkit-font-smoothing: antialiased;
        }

        body {
            font-family: var(--font-sans);
            background: linear-gradient(135deg, #e6fcf5 0%, #ebfbee 50%, #dcfce7 100%);
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: var(--text-main);
            overflow-x: hidden;
            line-height: 1.6;
            min-height: 100vh;
        }

        button,
        input,
        textarea,
        select {
            font-family: var(--font-sans);
        }

        /* Updated Navbar Styles from index.jsp */
        .navbar {
            position: sticky;
            top: 0;
            width: 100%;
            height: 80px;
            background: transparent;
            border-bottom: 1px solid transparent;
            z-index: 1000;
            display: flex;
            justify-content: center;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .navbar.scrolled {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        }

        .nav-container {
            width: 100%;
            max-width: 1400px; /* Matched to dashboard container */
            padding: 0 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            text-decoration: none;
            font-weight: 800;
            font-size: 1.65rem;
            color: #0f172a;
            letter-spacing: -0.03em;
        }

        .logo img {
            height: 42px;
            width: auto;
            border-radius: 8px;
            object-fit: contain;
        }

        .logo span {
            background: linear-gradient(135deg, rgb(4, 120, 87) 0%, rgb(16, 185, 129) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            display: inline-block;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            list-style: none;
        }

        .nav-links a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: #1f2937;
            font-weight: 800;
            font-size: 0.95rem;
            padding: 0.68rem 1.15rem;
            border: 1px solid rgba(148, 163, 184, 0.28);
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.68);
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
            transition: color 0.2s ease, border-color 0.2s ease, background 0.2s ease, box-shadow 0.2s ease;
            white-space: nowrap;
        }

        .nav-links a:hover {
            color: var(--primary);
            border-color: rgba(5, 150, 105, 0.38);
            background: rgba(255, 255, 255, 0.92);
        }

        .nav-links a.active {
            color: var(--primary);
            border-color: rgba(5, 150, 105, 0.55);
            background: #ffffff;
            box-shadow: 0 14px 30px rgba(5, 150, 105, 0.16);
        }

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

        /* Notification Popup Styles from landing.css */
        .nav-bell-dropdown { position: relative; display: inline-block; }
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
            z-index: 2000;
            overflow: hidden;
        }
        .notification-popup-menu::before {
            content: ''; position: absolute; top: -25px; left: 0; width: 100%; height: 25px;
        }
        .notification-popup-menu.show { opacity: 1; visibility: visible; transform: translateY(0); }
        .noti-popup-header { padding: 1rem 1.25rem; border-bottom: 1px solid #f1f5f9; text-align: left; }
        .noti-popup-header span { color: #0f172a; font-size: 1.15rem; font-weight: 800; letter-spacing: 0.3px; }
        .noti-popup-list { max-height: 280px; overflow-y: auto; display: flex; flex-direction: column; }
        .noti-popup-item { padding: 0.85rem 1.25rem; border-bottom: 1px solid #f8fafc; display: flex; gap: 0.85rem; align-items: flex-start; cursor: pointer; transition: background 0.2s ease; text-align: left; }
        .noti-popup-item:hover { background: #f1f5f9; }
        .noti-icon-round { width: 36px; height: 36px; border-radius: 0.75rem; background: #ecfdf5; color: var(--primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 0.1rem; }
        .noti-info-col { display: flex; flex-direction: column; gap: 0.2rem; overflow: hidden; width: 100%; }
        .noti-title { color: #0f172a; font-weight: 700; font-size: 0.9rem; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .noti-desc { color: #475569; font-size: 0.8rem; line-height: 1.3; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .noti-date { color: #94a3b8; font-size: 0.72rem; margin-top: 0.1rem; }
        .noti-popup-footer { padding: 0.85rem; text-align: center; border-top: 1px solid #f1f5f9; background: #f8fafc; }
        .noti-popup-footer a { color: var(--primary); font-size: 0.85rem; font-weight: 700; text-decoration: none; cursor: pointer; transition: color 0.2s ease; display: block; }

        /* Dashboard Layout - synced with student-profile */
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

        /* Sidebar */
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

        .sidebar-top-group {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            min-height: 0;
        }

        .sidebar-menu {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar-menu li { margin-bottom: 0; }

        .sidebar-menu a {
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

        .sidebar-menu a:hover {
            color: var(--primary);
            background: var(--primary-light);
            transform: translateX(4px);
        }

        .sidebar-menu a.active {
            color: var(--primary);
            background: var(--primary-light);
            font-weight: 700;
            box-shadow: none;
        }

        .sidebar-menu a.active svg { stroke: var(--primary); }
        .menu-label-group { display: flex; align-items: center; gap: 0.75rem; min-width: 0; }
        .menu-label-group span { line-height: 1.25; }
        .menu-indicator {
            font-size: 1.1rem;
            color: var(--border-dark);
            transition: color 0.2s ease;
            flex-shrink: 0;
        }
        .sidebar-menu a:hover .menu-indicator,
        .sidebar-menu a.active .menu-indicator { color: var(--primary); }

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

        /* Main Content */
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
        .dashboard-content-wrapper.is-switching-tab { overflow-anchor: none; transition: min-height 0.25s ease; }
        .tab-pane {
            display: none;
            flex-direction: column;
            flex: 1;
            min-height: 0;
            opacity: 1;
            transform: none;
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
            .tab-pane.active-pane { transition: none; animation: none; }
            .tab-pane.active-pane { opacity: 1; transform: none; }
        }

        /* Cards */
        .premium-card {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-radius: 0;
            border: none;
            box-shadow: none;
            overflow-y: auto;
            margin-bottom: 0;
            flex: 1;
            min-height: 0;
        }
        .card-header-gradient {
            background: transparent;
            padding: 1.75rem 2rem 0.75rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--text-main);
            gap: 1rem;
            flex-wrap: wrap;
        }
        .card-header-gradient h2 { font-size: 1.35rem; font-weight: 800; letter-spacing: 0; }
        .card-header-gradient > span,
        .card-header-gradient > div {
            color: var(--primary);
            background: var(--primary-light) !important;
            border: 1px solid #bbf7d0;
            padding: 0.3rem 0.85rem !important;
            border-radius: 1rem !important;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .card-body-premium { padding: 2rem; }

        /* Connection Block */
        .connection-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 3rem;
            align-items: center;
        }
        .connection-intro h3 { font-size: 1.5rem; font-weight: 800; color: var(--text-main); margin-bottom: 1rem; }
        .connection-intro p { color: var(--text-muted); font-size: 1rem; margin-bottom: 1.5rem; }
        .feature-item { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.75rem; color: var(--primary); font-weight: 600; }

        .connection-form-box {
            background: var(--primary-light);
            padding: 2rem;
            border-radius: var(--radius-lg);
            border: 1px dashed var(--primary);
        }
        .form-group-custom { display: flex; flex-direction: column; gap: 0.75rem; }
        .form-group-custom label { font-weight: 700; color: var(--primary); text-transform: uppercase; font-size: 0.75rem; }
        .input-premium {
            padding: 1rem 1.25rem; border-radius: var(--radius-md); border: 1px solid var(--border-dark);
            font-size: 1.15rem; font-weight: 700; color: var(--primary); letter-spacing: 1px; outline: none;
            transition: all 0.2s ease;
        }
        .input-premium:focus { border-color: var(--primary); box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.1); }
        .btn-connect {
            background: var(--primary); color: white; border: none; padding: 1rem; 
            border-radius: var(--radius-md); font-weight: 800; cursor: pointer;
            transition: all 0.2s ease; box-shadow: 0 4px 12px rgba(5, 150, 105, 0.3);
        }
        .btn-connect:hover { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(5, 150, 105, 0.4); }

        /* Student Grid */
        .student-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 1.5rem;
            margin-top: 1rem;
        }
        .student-card-premium {
            background: var(--white); border-radius: var(--radius-lg); border: 1px solid var(--border-dark);
            padding: 1.5rem; padding-right: 3.5rem; transition: all 0.3s ease; display: flex; flex-direction: column; gap: 1rem;
        }
        .student-card-premium:hover { transform: translateY(-5px); box-shadow: var(--shadow-lg); border-color: var(--primary); }
        
        .student-card-header { display: flex; flex-direction: column; align-items: flex-start; gap: 0.35rem; min-width: 0; }
        .student-title-row { display: flex; align-items: center; gap: 0.65rem; flex-wrap: wrap; max-width: 100%; }
        .student-name { font-size: 1.25rem; font-weight: 800; color: var(--text-main); line-height: 1.25; }
        .status-badge {
            display: inline-flex; align-items: center; justify-content: center; min-height: 1.55rem;
            padding: 0.25rem 0.75rem; border-radius: 999px; font-size: 0.7rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: 0.3px; line-height: 1; white-space: nowrap;
        }
        .status-online { background: #dcfce7; color: #16a34a; }
        .status-offline { background: #f1f5f9; color: #64748b; }

        .report-btn {
            background: var(--primary); color: white; text-decoration: none; text-align: center;
            border: none; cursor: pointer;
            padding: 0.75rem; border-radius: var(--radius-md); font-weight: 700; font-size: 0.9rem;
            transition: all 0.2s ease;
        }
        .report-btn:hover { opacity: 0.9; }

        .report-modal-backdrop {
            position: fixed; inset: 0; z-index: 10000; display: none; align-items: center; justify-content: center;
            padding: 1.5rem; background: rgba(15, 23, 42, 0.45); backdrop-filter: blur(8px);
        }
        .report-modal-backdrop.active { display: flex; }
        .report-modal {
            width: min(560px, 100%); background: #ffffff; border-radius: 1rem; border: 1px solid rgba(226, 232, 240, 0.95);
            box-shadow: 0 24px 70px rgba(15, 23, 42, 0.24); overflow: hidden;
            animation: reportModalIn 0.22s ease-out;
        }
        .report-modal-header {
            padding: 1.25rem 1.5rem; background: linear-gradient(135deg, #059669 0%, #10b981 100%);
            color: #ffffff; display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem;
        }
        .report-modal-title { font-size: 1.25rem; font-weight: 800; line-height: 1.25; }
        .report-modal-subtitle { font-size: 0.82rem; opacity: 0.9; margin-top: 0.25rem; font-weight: 600; }
        .report-modal-close {
            width: 34px; height: 34px; border: none; border-radius: 0.75rem; cursor: pointer;
            background: rgba(255, 255, 255, 0.18); color: #ffffff; display: inline-flex; align-items: center; justify-content: center;
        }
        .report-modal-body { padding: 1.5rem; }
        .report-stats-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem; }
        .report-stat {
            border: 1px solid #e2e8f0; border-radius: 0.85rem; padding: 1rem; background: #f8fafc;
            display: flex; flex-direction: column; gap: 0.35rem; min-height: 104px;
        }
        .report-stat-label { color: #64748b; font-size: 0.76rem; font-weight: 800; text-transform: uppercase; }
        .report-stat-value { color: #0f172a; font-size: 1.65rem; line-height: 1.15; font-weight: 850; }
        .report-stat-note { color: #64748b; font-size: 0.78rem; font-weight: 600; }
        @keyframes reportModalIn {
            from { opacity: 0; transform: translateY(14px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        @media (max-width: 640px) {
            .report-stats-grid { grid-template-columns: 1fr; }
        }

        /* Toast Styles (Premium Look) */
        #toast-container { position: fixed; bottom: 1.5rem; right: 1.5rem; z-index: 10001; display: flex; flex-direction: column-reverse; gap: 1rem; }
        .toast {
            min-width: 350px; padding: 1.25rem 1.75rem; border-radius: 1rem;
            box-shadow: 0 15px 35px rgba(0,0,0,0.15); display: flex; align-items: center; gap: 1.25rem;
            animation: slideInPremium 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; color: white;
            transition: all 0.3s ease;
        }
        .toast.success { background: linear-gradient(135deg, #059669 0%, #10b981 100%); }
        .toast.error { background: linear-gradient(135deg, #ef4444 0%, #f87171 100%); }
        .toast svg { flex-shrink: 0; filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1)); }
        .toast span { font-weight: 700; font-size: 0.95rem; line-height: 1.4; }
        @keyframes slideInPremium { 
            from { transform: translateX(120%); opacity: 0; } 
            to { transform: translateX(0); opacity: 1; } 
        }

        /* Profile Info Styles */
        .info-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.25rem; }
        .info-item {
            background: #ffffff; border-radius: var(--radius-md); padding: 1.25rem; border: 1px solid var(--border-dark);
            display: flex; align-items: center; gap: 1rem;
        }
        .info-icon { width: 48px; height: 48px; border-radius: 50%; background: var(--primary-light); color: var(--primary); display: flex; justify-content: center; align-items: center; }
        .info-label { font-size: 0.75rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; display: block; }
        .info-value { font-size: 1.1rem; font-weight: 700; color: var(--text-main); }

        .acc-status-tag { padding: 0.25rem 0.75rem; border-radius: 1rem; font-size: 0.75rem; font-weight: 700; }
        .acc-status-tag.active { background: #dcfce7; color: #15803d; }

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

            .sidebar-mascot-box {
                display: none;
            }

            .connection-grid,
            .card-body-premium > div[style*="grid-template-columns: 1fr 1fr"] {
                grid-template-columns: 1fr !important;
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

            .sidebar-menu a {
                padding: 0.8rem 0.85rem;
            }

            .card-header-gradient,
            .card-body-premium {
                padding-left: 1rem;
                padding-right: 1rem;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .student-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <!-- ===== GLOBAL HEADER NAVBAR ===== -->
    <header class="navbar" id="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>

                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index.jsp#ai-roadmap">Hipzi AI</a></li>
            </ul>
            <div class="navbar-user-controls">
                <!-- Khung Dropdown Thông báo hệ thống cao cấp -->
                <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                <!-- Khung Avatar Người dùng kèm Dropdown Menu -->
                <div class="nav-avatar-dropdown">
                    <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                        <% if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
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

    <div class="app-dashboard-container">
        <div class="dashboard-unified-header">
            <span class="unified-header-tab-title" id="unified-header-title">
                <%= "tab-profile".equals(activeTab) ? "Hồ sơ cá nhân" :
                    "tab-security".equals(activeTab) ? "Bảo mật tài khoản" :
                    "tab-notifications".equals(activeTab) ? "Thông báo hệ thống" :
                    "tab-support".equals(activeTab) ? "Hỗ trợ hệ thống" :
                    "Theo dõi học sinh" %>
            </span>
            <div class="unified-header-right">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span>Hôm nay, <%= currentDateDisplay %></span>
            </div>
        </div>

        <div class="dashboard-body">
            <aside class="dashboard-sidebar">
                <div class="sidebar-top-group">
                    <ul class="sidebar-menu">
                        <li>
                            <a id="nav-tab-tracking" class="<%= "tab-tracking".equals(activeTab) ? "active" : "" %>" onclick="switchTab('tab-tracking')">
                                <div class="menu-label-group">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-3-3.87"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    <span>Theo dõi học sinh</span>
                                </div>
                                <span class="menu-indicator">&rarr;</span>
                            </a>
                        </li>
                        <li>
                            <a id="nav-tab-profile" class="<%= "tab-profile".equals(activeTab) ? "active" : "" %>" onclick="switchTab('tab-profile')">
                                <div class="menu-label-group">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    <span><%= profileMenuLabel %></span>
                                </div>
                                <span class="menu-indicator">&rarr;</span>
                            </a>
                        </li>
                        <li>
                            <a id="nav-tab-security" class="<%= "tab-security".equals(activeTab) ? "active" : "" %>" onclick="switchTab('tab-security')">
                                <div class="menu-label-group">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                    <span>Bảo mật tài khoản</span>
                                </div>
                                <span class="menu-indicator">&rarr;</span>
                            </a>
                        </li>
                        <li>
                            <a id="nav-tab-notifications" class="<%= "tab-notifications".equals(activeTab) ? "active" : "" %>" onclick="switchTab('tab-notifications')">
                                <div class="menu-label-group">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                    <span>Thông báo hệ thống</span>
                                </div>
                                <span class="menu-indicator">&rarr;</span>
                            </a>
                        </li>
                        <li>
                            <a id="nav-tab-support" class="<%= "tab-support".equals(activeTab) ? "active" : "" %>" onclick="switchTab('tab-support')">
                                <div class="menu-label-group">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                    <span>Hỗ trợ hệ thống</span>
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

            <main class="dashboard-content-wrapper">

            <!-- TAB: TRACKING (Theo dõi học sinh) -->
            <section id="tab-tracking" class="tab-pane <%= "tab-tracking".equals(activeTab) ? "active-pane" : "" %>">
                <div class="premium-card">
                    <div class="card-header-gradient">
                        <h2>Trung tâm Kết nối & Theo dõi</h2>
                        <div style="background: rgba(255,255,255,0.15); padding: 0.4rem 0.8rem; border-radius: 1rem; font-size: 0.85rem; font-weight: 600;">
                            <%= currentDateDisplay %>
                        </div>
                    </div>
                    <div class="card-body-premium">
                        <div class="connection-grid">
                            <div class="connection-intro">
                                <h3>Đồng hành cùng con</h3>
                                <p>Kết nối tài khoản học sinh để theo dõi tiến độ học tập, kết quả bài tập và nhận thông báo quan trọng từ HIPZI.</p>
                                <div class="feature-item">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Xem báo cáo chi tiết theo từng môn học</span>
                                </div>
                                <div class="feature-item">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Theo dõi trạng thái Online/Offline thời gian thực</span>
                                </div>
                                <div class="feature-item">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                                    <span>Nhận thông báo khi con hoàn thành Quiz</span>
                                </div>
                            </div>
                            <div class="connection-form-box">
                                <form id="linkStudentForm" action="${pageContext.request.contextPath}/parent/tracking" method="POST" class="form-group-custom">
                                    <input type="hidden" name="action" value="link">
                                    <label>Nhập mã học sinh</label>
                                    <input type="text" name="studentCode" class="input-premium" placeholder="Ví dụ: HZ-8A2K..." required>
                                    <button type="submit" class="btn-connect">KẾT NỐI NGAY</button>
                                </form>
                            </div>
                        </div>

                        <div style="margin-top: 3rem;">
                            <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem;">
                                <span style="width: 8px; height: 24px; background: var(--primary); border-radius: 4px;"></span>
                                Danh sách học sinh đang theo dõi
                            </h3>
                            
                            <div class="student-grid">
                                <% if (trackedStudents != null && !trackedStudents.isEmpty()) { 
                                    for (ParentStudentLink link : trackedStudents) {
                                        boolean studentOnline = UserStatusWebSocket.isUserOnline(link.getStudentId());
                                %>
                                    <div class="student-card-premium" style="position: relative;">
                                        <button onclick="unlinkStudent('<%= link.getStudentId() %>', '<%= link.getStudentName() %>')" style="position: absolute; top: 0.75rem; right: 0.75rem; background: #fff1f2; color: #f43f5e; border: none; width: 28px; height: 28px; border-radius: 8px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s ease; z-index: 10;" title="Hủy liên kết">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                        </button>
                                        <div class="student-card-header">
                                            <div class="student-title-row">
                                                <div class="student-name"><%= link.getStudentName() %></div>
                                                <div id="status-badge-<%= link.getStudentId() %>" class="status-badge <%= studentOnline ? "status-online" : "status-offline" %>"><%= studentOnline ? "Online" : "Offline" %></div>
                                            </div>
                                            <div style="font-size: 0.75rem; color: var(--text-muted); font-weight: 600;">Mã: <%= link.getStudentCode() %></div>
                                        </div>
                                        <div style="height: 1px; background: var(--border-light);"></div>
                                        <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                            <div style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                                <span style="color: var(--text-muted);">Email:</span>
                                                <span style="font-weight: 600;"><%= link.getStudentEmail() %></span>
                                            </div>
                                        </div>
                                        <button type="button"
                                                class="report-btn open-report-modal"
                                                data-name="<%= escAttr(link.getStudentName()) %>"
                                                data-code="<%= escAttr(link.getStudentCode()) %>"
                                                data-grade="<%= escAttr(link.getGradeLevel() != null && !link.getGradeLevel().trim().isEmpty() ? link.getGradeLevel() : "Chưa cập nhật") %>"
                                                data-level="<%= link.getCurrentLevel() %>"
                                                data-streak="<%= link.getCurrentStreak() %>"
                                                data-quizzes="<%= link.getCompletedQuizzesCount() %>">
                                            XEM BÁO CÁO CHI TIẾT
                                        </button>
                                    </div>
                                <% } } else { %>
                                    <div style="grid-column: 1 / -1; text-align: center; padding: 3rem; background: var(--bg-body); border-radius: var(--radius-lg); border: 1px dashed var(--border-dark);">
                                        <p style="color: var(--text-muted); font-weight: 600;">Chưa có học sinh nào được kết nối. Hãy nhập mã ở trên để bắt đầu!</p>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB: PROFILE (Hồ sơ phụ huynh) -->
            <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(activeTab) ? "active-pane" : "" %>">
                <div class="premium-card">
                    <div class="card-header-gradient">
                        <h2>Hồ sơ cá nhân</h2>
                        <span>Phụ huynh HIPZI</span>
                    </div>
                    <div class="card-body-premium">
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
                                <div>
                                    <span class="info-label">Họ và tên</span>
                                    <span class="info-value"><%= user.getDisplayName() %></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                                <div>
                                    <span class="info-label">Ngày tham gia</span>
                                    <span class="info-value"><%= joinDate %></span>
                                </div>
                            </div>
                            <div class="info-item" style="grid-column: 1 / -1;">
                                <div class="info-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></div>
                                <div>
                                    <span class="info-label">Email tài khoản</span>
                                    <span class="info-value"><%= user.getEmail() %></span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                                <div>
                                    <span class="info-label">Trạng thái</span>
                                    <span class="acc-status-tag active">Đang hoạt động</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB: SECURITY (Bảo mật) -->
            <section id="tab-security" class="tab-pane <%= "tab-security".equals(activeTab) ? "active-pane" : "" %>">
                <div class="premium-card">
                    <div class="card-header-gradient">
                        <h2>Bảo mật tài khoản</h2>
                        <span>Quản lý mật khẩu</span>
                    </div>
                    <div class="card-body-premium">
                        <div style="max-width: 500px;">
                            <form action="${pageContext.request.contextPath}/profile" method="POST" style="display: flex; flex-direction: column; gap: 1.5rem;">
                                <input type="hidden" name="action" value="changePassword">
                                <div class="form-group-custom">
                                    <label>Mật khẩu hiện tại</label>
                                    <input type="password" name="currentPassword" class="input-premium" style="font-size: 1rem; color: var(--text-main);" required>
                                </div>
                                <div class="form-group-custom">
                                    <label>Mật khẩu mới</label>
                                    <input type="password" name="newPassword" class="input-premium" style="font-size: 1rem; color: var(--text-main);" required>
                                </div>
                                <div class="form-group-custom">
                                    <label>Xác nhận mật khẩu mới</label>
                                    <input type="password" name="confirmPassword" class="input-premium" style="font-size: 1rem; color: var(--text-main);" required>
                                </div>
                                <button type="submit" class="btn-connect">CẬP NHẬT MẬT KHẨU</button>
                            </form>
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB: NOTIFICATIONS (Thông báo hệ thống) -->
            <section id="tab-notifications" class="tab-pane <%= "tab-notifications".equals(activeTab) ? "active-pane" : "" %>">
                <div class="premium-card">
                    <div class="card-header-gradient">
                        <h2>Thông báo hệ thống</h2>
                        <span>Cập nhật mới nhất từ HIPZI</span>
                    </div>
                    <div class="card-body-premium">
                        <div style="display: flex; flex-direction: column; gap: 1rem;">
                            <% if (notifications != null && !notifications.isEmpty()) { 
                                for (Notification n : notifications) {
                                    String typeColor = "#10b981"; // success
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
                                <div style="padding: 1.25rem; border-radius: var(--radius-md); background: <%= bgColor %>; border-left: 4px solid <%= typeColor %>; display: flex; gap: 1.25rem; align-items: flex-start;">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="<%= typeColor %>" stroke-width="2.5" style="flex-shrink:0; margin-top:0.2rem;"><path d="<%= iconPath %>"/></svg>
                                    <div>
                                        <span style="font-weight: 700; font-size: 1rem; color: var(--text-main); display: block; margin-bottom: 0.25rem;"><%= n.getTitle() %></span>
                                        <p style="font-size: 0.9rem; color: var(--text-muted); margin: 0;"><%= n.getMessage() %></p>
                                        <span style="font-size: 0.75rem; color: #94a3b8; display: block; margin-top: 0.5rem;"><%= sdf.format(n.getCreatedAt()) %></span>
                                    </div>
                                </div>
                            <% } } else { %>
                                <div style="padding: 4rem 2rem; text-align: center; color: var(--text-muted);">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 1rem; opacity: 0.5;"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                                    <p style="font-weight: 700; color: var(--text-main); margin-bottom: 0.5rem;">Không có thông báo nào</p>
                                    <p style="font-size: 0.9rem;">Thông báo hệ thống quan trọng dành cho phụ huynh sẽ xuất hiện tại đây.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB: SUPPORT (Hỗ trợ) -->
            <section id="tab-support" class="tab-pane <%= "tab-support".equals(activeTab) ? "active-pane" : "" %>">
                <div class="premium-card">
                    <div class="card-header-gradient">
                        <h2>Trung tâm Hỗ trợ</h2>
                        <span>Giải đáp thắc mắc và hỗ trợ kỹ thuật</span>
                    </div>
                    <div class="card-body-premium">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                            <div>
                                <h3 style="font-size: 1.1rem; font-weight: 800; margin-bottom: 1.25rem; color: var(--text-main);">Câu hỏi thường gặp (FAQs)</h3>
                                <div style="display: flex; flex-direction: column; gap: 1rem;">
                                    <details style="background: #f8fafc; padding: 1rem; border-radius: var(--radius-md); border: 1px solid var(--border-light); cursor: pointer;">
                                        <summary style="font-weight: 700; color: var(--text-main); font-size: 0.95rem;">Làm thế nào để kết nối với học sinh?</summary>
                                        <p style="font-size: 0.9rem; color: var(--text-muted); margin-top: 0.75rem; line-height: 1.5;">Phụ huynh cần lấy "Mã học viên" từ tài khoản của con mình, sau đó nhập vào ô "Kết nối học sinh" tại trang Tổng quan này.</p>
                                    </details>
                                    <details style="background: #f8fafc; padding: 1rem; border-radius: var(--radius-md); border: 1px solid var(--border-light); cursor: pointer;">
                                        <summary style="font-weight: 700; color: var(--text-main); font-size: 0.95rem;">Báo cáo học tập được cập nhật khi nào?</summary>
                                        <p style="font-size: 0.9rem; color: var(--text-muted); margin-top: 0.75rem; line-height: 1.5;">Dữ liệu được cập nhật theo thời gian thực ngay khi học sinh hoàn thành các bài luyện tập hoặc Quiz trên hệ thống.</p>
                                    </details>
                                    <details style="background: #f8fafc; padding: 1rem; border-radius: var(--radius-md); border: 1px solid var(--border-light); cursor: pointer;">
                                        <summary style="font-weight: 700; color: var(--text-main); font-size: 0.95rem;">Tôi có thể liên hệ trực tiếp với giảng viên không?</summary>
                                        <p style="font-size: 0.9rem; color: var(--text-muted); margin-top: 0.75rem; line-height: 1.5;">Hiện tại tính năng liên hệ trực tiếp đang được phát triển. Bạn có thể gửi yêu cầu hỗ trợ cho quản trị viên hệ thống ở khung bên cạnh.</p>
                                    </details>
                                </div>
                            </div>
                            <div style="background: #ffffff; padding: 1.5rem; border-radius: var(--radius-lg); border: 1px solid var(--border-dark); box-shadow: var(--shadow-sm);">
                                <h3 style="font-size: 1.1rem; font-weight: 800; margin-bottom: 1.25rem; color: var(--text-main);">Gửi yêu cầu hỗ trợ</h3>
                                <form action="${pageContext.request.contextPath}/profile" method="POST" style="display: flex; flex-direction: column; gap: 1.25rem;">
                                    <input type="hidden" name="action" value="submitSupport">
                                    <div class="form-group-custom">
                                        <label>Tiêu đề yêu cầu</label>
                                        <input type="text" name="title" required placeholder="Vấn đề bạn cần hỗ trợ..." class="input-premium">
                                    </div>
                                    <div class="form-group-custom">
                                        <label>Nội dung chi tiết</label>
                                        <textarea name="message" rows="4" required placeholder="Mô tả cụ thể vấn đề để chúng tôi hỗ trợ tốt nhất..." class="input-premium" style="resize: none;"></textarea>
                                    </div>
                                    <button type="submit" class="btn-connect" style="margin-top: 0.5rem;">GỬI YÊU CẦU NGAY</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            </main>
        </div>
    </div>

    <!-- BANNER CỘNG ĐỒNG HIPZI (CHÍNH GIỮA FULL-WIDTH TOÀN TRANG)  -->
    <!-- ========================================================== -->
    <div style="max-width:1400px; width:100%; margin:0 auto 5rem auto; padding:0 2rem;">
        <div class="community-engagement-banner" style="background:#ffffff; border-radius:1.5rem; border:1px solid #e2e8f0; box-shadow:0 10px 30px rgba(0, 0, 0, 0.03); padding:2.5rem; display:flex; flex-direction:column; gap:1.75rem; position:relative; overflow:hidden;">
            
            <!-- Dải lấp lánh trang trí góc phải -->
            <div style="position:absolute; top:0; right:0; width:350px; height:350px; background:radial-gradient(circle, rgba(5, 150, 105, 0.05) 0%, transparent 70%); pointer-events:none;"></div>

            <div style="display:flex; flex-direction:column; gap:1.25rem; z-index:1;">
                <!-- Badge Hỗ trợ / Cộng đồng -->
                <div>
                    <span style="display:inline-flex; align-items:center; gap:0.4rem; background:#ecfdf5; color:#059669; font-weight:800; font-size:0.75rem; padding:0.4rem 1rem; border-radius:2rem; letter-spacing:0.5px; text-transform:uppercase;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        Hỗ trợ Phụ huynh 24/7
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
                            Đừng ngần ngại kết nối với đội ngũ giảng viên và cộng đồng phụ huynh để cùng trao đổi, định hướng lộ trình học tập phù hợp và hiệu quả nhất cho con em mình.
                        </p>
                        
                        <!-- Hàng Nút Hành động CTA -->
                        <div style="display:flex; align-items:center; gap:0.85rem; margin-top:0.5rem; flex-wrap:wrap;">
                            <a href="https://zalo.me/g/hipzi2024" target="_blank" style="background:#059669; color:#ffffff; font-weight:700; font-size:0.85rem; padding:0.85rem 1.75rem; border-radius:0.75rem; text-decoration:none; display:inline-flex; align-items:center; gap:0.5rem; box-shadow:0 4px 12px rgba(5, 150, 105, 0.25); transition:all 0.2s ease; letter-spacing:0.5px;" onmouseover="this.style.background='#047857'; this.style.transform='translateY(-2px)';" onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                                THAM GIA CỘNG ĐỒNG ZALO
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
                                <span style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">GIẢNG VIÊN HỖ TRỢ</span>
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
                                <span style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">CỘNG ĐỒNG HIPZI</span>
                                <span style="font-size:1.05rem; font-weight:800; color:#0f172a;">2000+ Thành viên</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="studentReportModal" class="report-modal-backdrop" aria-hidden="true">
        <div class="report-modal" role="dialog" aria-modal="true" aria-labelledby="studentReportTitle">
            <div class="report-modal-header">
                <div>
                    <div id="studentReportTitle" class="report-modal-title">Báo cáo học viên</div>
                    <div id="studentReportSubtitle" class="report-modal-subtitle">Mã học viên</div>
                </div>
                <button type="button" class="report-modal-close" onclick="closeStudentReportModal()" aria-label="Đóng báo cáo">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
            </div>
            <div class="report-modal-body">
                <div class="report-stats-grid">
                    <div class="report-stat">
                        <span class="report-stat-label">Tên học viên</span>
                        <span id="reportStudentName" class="report-stat-value" style="font-size:1.25rem;">-</span>
                        <span class="report-stat-note">Thông tin tài khoản đã liên kết</span>
                    </div>
                    <div class="report-stat">
                        <span class="report-stat-label">Cấp độ</span>
                        <span id="reportStudentLevel" class="report-stat-value">0</span>
                        <span class="report-stat-note">Level hiện tại</span>
                    </div>
                    <div class="report-stat">
                        <span class="report-stat-label">Chuỗi ngày học</span>
                        <span id="reportStudentStreak" class="report-stat-value">0</span>
                        <span class="report-stat-note">Ngày học liên tiếp</span>
                    </div>
                    <div class="report-stat">
                        <span class="report-stat-label">Quiz hoàn thành</span>
                        <span id="reportStudentQuizzes" class="report-stat-value">0</span>
                        <span id="reportStudentGrade" class="report-stat-note">Cấp học: -</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="toast-container"></div>

    <script>
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
            'tab-tracking': 'Theo dõi học sinh',
            'tab-profile': 'Hồ sơ cá nhân',
            'tab-security': 'Bảo mật tài khoản',
            'tab-notifications': 'Thông báo hệ thống',
            'tab-support': 'Hỗ trợ hệ thống',
        };

        function updateUnifiedHeaderTitle(tabId) {
            const el = document.getElementById('unified-header-title');
            const title = TAB_TITLES[tabId];
            if (!el || !title) return;
            el.textContent = title;
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

        function switchTab(tabId, options = {}) {
            const targetTabId = normalizeProfileTabId(tabId);
            const targetPane = document.getElementById(targetTabId);
            if (!targetPane || targetPane.classList.contains('active-pane')) {
                document.querySelectorAll('.sidebar-menu a').forEach(el => el.classList.remove('active'));
                const activeNav = document.getElementById('nav-' + targetTabId);
                if (activeNav) activeNav.classList.add('active');
                if (targetPane) updateUnifiedHeaderTitle(targetTabId);
                if (targetPane && options.updateUrl) updateProfileTabUrl(targetTabId, options.replaceUrl);
                return;
            }
            const previousPane = document.querySelector('.tab-pane.active-pane');
            steadyProfileTabHeight(previousPane, targetPane);
            document.querySelectorAll('.tab-pane').forEach(el => el.classList.remove('active-pane'));
            document.querySelectorAll('.sidebar-menu a').forEach(el => el.classList.remove('active'));
            targetPane.classList.add('active-pane');
            const activeNav = document.getElementById('nav-' + targetTabId);
            if (activeNav) activeNav.classList.add('active');
            updateUnifiedHeaderTitle(targetTabId);
            if (options.updateUrl !== false) updateProfileTabUrl(targetTabId, options.replaceUrl);
            requestAnimationFrame(settleProfileTabScroll);
        }

        function showToast(message, type = 'success') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = 'toast ' + type;
            
            const icon = type === 'success' 
                ? '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3.5"><polyline points="20 6 9 17 4 12"/></svg>' 
                : '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';
            
            toast.innerHTML = icon + '<span>' + message + '</span>';
            
            container.appendChild(toast);
            setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(20px)';
                setTimeout(() => toast.remove(), 400);
            }, 5000);
        }

        async function getResponseMessage(response, fallback) {
            const text = await response.text();
            const contentType = response.headers.get('content-type') || '';

            if (!text || contentType.includes('text/html') || text.trim().startsWith('<!DOCTYPE') || text.trim().startsWith('<html')) {
                if (response.status === 401) return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
                if (response.status === 404) return 'Không tìm thấy học viên với mã này.';
                if (response.status === 409) return 'Tài khoản này không thể tự theo dõi chính mình.';
                return fallback;
            }

            return text;
        }

        // WebSocket Status Tracking
        let statusWS;
        function initStatusWS() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const host = window.location.host;
            const wsUrl = protocol + '//' + host + '${pageContext.request.contextPath}/status-ws';
            
            statusWS = new WebSocket(wsUrl);
            
            statusWS.onopen = () => {
                console.log('Status WebSocket connected');
                statusWS.send(JSON.stringify({ type: 'auth', userId: '<%= user.getId() %>' }));
            };

            statusWS.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    // Match the backend type 'status' from UserStatusWebSocket.java
                    if (data.type === 'status' || data.type === 'status_update') {
                        updateStudentStatusUI(data.userId, data.status);
                    } else if (data.type === 'bulk_status') {
                        Object.keys(data.statuses).forEach(uid => {
                            updateStudentStatusUI(uid, data.statuses[uid]);
                        });
                    }
                } catch (e) { console.error('WS Error:', e); }
            };

            statusWS.onclose = () => {
                console.log('Status WebSocket closed. Reconnecting...');
                setTimeout(initStatusWS, 5000);
            };
        }

        function updateStudentStatusUI(studentId, status) {
            const badge = document.getElementById('status-badge-' + studentId);
            if (badge) {
                if (status === 'online') {
                    badge.innerText = 'Online';
                    badge.classList.remove('status-offline');
                    badge.classList.add('status-online');
                } else {
                    badge.innerText = 'Offline';
                    badge.classList.remove('status-online');
                    badge.classList.add('status-offline');
                }
            }
        }

        async function unlinkStudent(studentId, studentName) {
            if (!confirm(`Bạn có chắc chắn muốn hủy liên kết với học sinh ${studentName}?`)) return;

            try {
                const response = await fetch(`${pageContext.request.contextPath}/parent/tracking`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    credentials: 'same-origin',
                    body: `action=unlink&studentId=${studentId}`
                });

                if (response.ok) {
                    showToast('Đã hủy liên kết thành công.', 'success');
                    setTimeout(() => window.location.reload(), 1000);
                } else {
                    const msg = await getResponseMessage(response, 'Lỗi khi hủy liên kết.');
                    showToast(msg || 'Lỗi khi hủy liên kết.', 'error');
                }
            } catch (error) {
                showToast('Lỗi kết nối máy chủ.', 'error');
            }
        }

        // Xử lý gửi form kết nối học sinh qua AJAX
        const linkStudentForm = document.getElementById('linkStudentForm');
        if (linkStudentForm) {
            linkStudentForm.addEventListener('submit', async function(e) {
                e.preventDefault();
                const formData = new FormData(this);
                const submitBtn = this.querySelector('button[type="submit"]');
                const originalText = submitBtn.innerText;
                
                submitBtn.disabled = true;
                submitBtn.innerText = 'Đang xử lý...';

                try {
                    const submitUrl = this.getAttribute('action') || '${pageContext.request.contextPath}/parent/tracking';
                    const response = await fetch(submitUrl, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                        credentials: 'same-origin',
                        body: new URLSearchParams(formData)
                    });

                    if (response.ok) {
                        showToast('Kết nối thành công!', 'success');
                        setTimeout(() => {
                            const currentUrl = new URL(window.location.href);
                            currentUrl.searchParams.set('tab', 'tracking');
                            window.location.href = currentUrl.toString();
                        }, 1500);
                    } else {
                        const msg = await getResponseMessage(response, 'Lỗi khi kết nối học sinh.');
                        showToast(msg || 'Lỗi khi kết nối học sinh.', 'error');
                    }
                } catch (error) {
                    showToast('Lỗi kết nối máy chủ.', 'error');
                } finally {
                    submitBtn.disabled = false;
                    submitBtn.innerText = originalText;
                }
            });
        }

        function openStudentReportModal(trigger) {
            const modal = document.getElementById('studentReportModal');
            if (!modal || !trigger) return;

            const name = trigger.dataset.name || '-';
            const code = trigger.dataset.code || '-';
            const grade = trigger.dataset.grade || '-';
            const level = trigger.dataset.level || '0';
            const streak = trigger.dataset.streak || '0';
            const quizzes = trigger.dataset.quizzes || '0';

            document.getElementById('studentReportTitle').textContent = 'B\u00e1o c\u00e1o c\u1ee7a ' + name;
            document.getElementById('studentReportSubtitle').textContent = 'M\u00e3 h\u1ecdc vi\u00ean: ' + code;
            document.getElementById('reportStudentName').textContent = name;
            document.getElementById('reportStudentLevel').textContent = 'C\u1ea5p ' + level;
            document.getElementById('reportStudentStreak').textContent = streak + ' ng\u00e0y';
            document.getElementById('reportStudentQuizzes').textContent = quizzes + ' b\u00e0i';
            document.getElementById('reportStudentGrade').textContent = 'C\u1ea5p h\u1ecdc: ' + grade;

            modal.classList.add('active');
            modal.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
        }

        function closeStudentReportModal() {
            const modal = document.getElementById('studentReportModal');
            if (!modal) return;

            modal.classList.remove('active');
            modal.setAttribute('aria-hidden', 'true');
            document.body.style.overflow = '';
        }

        document.querySelectorAll('.open-report-modal').forEach(button => {
            button.addEventListener('click', () => openStudentReportModal(button));
        });

        const studentReportModal = document.getElementById('studentReportModal');
        if (studentReportModal) {
            studentReportModal.addEventListener('click', (event) => {
                if (event.target === studentReportModal) {
                    closeStudentReportModal();
                }
            });
        }

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                closeStudentReportModal();
            }
        });

        window.onload = () => {
            const params = new URLSearchParams(window.location.search);
            const activeTab = params.get('tab');
            if (activeTab && document.getElementById(normalizeProfileTabId(activeTab))) {
                switchTab(activeTab, { replaceUrl: true });
            } else {
                const activePane = document.querySelector('.tab-pane.active-pane');
                if (activePane) updateProfileTabUrl(activePane.id, true);
            }
            initStatusWS();

            // Show success/error messages from session
            <%
                String tMsg = (String) session.getAttribute("toastMsg");
                String tType = (String) session.getAttribute("toastType");
                if (tMsg != null) {
                    session.removeAttribute("toastMsg");
                    session.removeAttribute("toastType");
            %>
                showToast("<%= tMsg %>", "<%= tType != null ? tType : "success" %>");
            <% } %>

            // Show success/error messages from redirect params (if any)
            const msg = params.get('msg');
            const error = params.get('error');
            if (msg) showToast(msg, 'success');
            if (error) showToast(error, 'error');
        };

        window.addEventListener('popstate', (event) => {
            const stateTab = event.state && event.state.profileTab;
            const urlTab = new URLSearchParams(window.location.search).get('tab');
            switchTab(stateTab || urlTab || 'tab-tracking', { updateUrl: false });
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>
