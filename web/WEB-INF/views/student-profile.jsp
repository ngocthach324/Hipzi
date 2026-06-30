<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="com.hipzi.model.User" %>
        <%@page import="com.hipzi.model.Role" %>
            <%@page import="com.hipzi.model.Classroom" %>
            <%@page import="com.hipzi.model.Course" %>
            <%@page import="java.text.NumberFormat" %>
            <%@page import="java.util.Locale" %>
                <%@page import="com.hipzi.model.TuitionInvoice" %>
                <%@page import="com.hipzi.model.TeachingSchedule" %>
                <%@page import="com.hipzi.model.TeacherApplication" %>
                    <%@page import="com.hipzi.model.Notification" %>
                        <%@page import="com.hipzi.model.SupportMessage" %>
                            <%@page import="com.hipzi.model.SupportTicket" %>
                                <%@page import="com.hipzi.model.StudentStudyProgressStats" %>
                                <%@page import="com.hipzi.service.NotificationService" %>
                                    <%@page import="java.util.List" %>
                                        <%@page import="java.text.SimpleDateFormat" %>
                                            <%@page import="java.util.Date" %>
                                                <%! private String h(String value) { if (value==null) return "" ; return
                                                    value.replace("&", "&amp;" ) .replace("<", "&lt;" ) .replace(">",
                                                    "&gt;")
                                                    .replace("\"", "&quot;");
                                                    }
                                                    private String studyProgressJson(List<StudentStudyProgressStats.Point> points) {
                                                        StringBuilder json = new StringBuilder("[");
                                                        if (points != null) {
                                                            for (int i = 0; i < points.size(); i++) {
                                                                StudentStudyProgressStats.Point point = points.get(i);
                                                                if (i > 0) json.append(",");
                                                                json.append("{\"label\":\"")
                                                                        .append(jsEscape(point.getLabel()))
                                                                        .append("\",\"fullLabel\":\"")
                                                                        .append(jsEscape(point.getFullLabel()))
                                                                        .append("\",\"hours\":")
                                                                        .append(String.format(java.util.Locale.US, "%.2f", point.getHours()))
                                                                        .append(",\"hoursLabel\":\"")
                                                                        .append(jsEscape(point.getHoursLabel()))
                                                                        .append("\"}");
                                                            }
                                                        }
                                                        json.append("]");
                                                        return json.toString();
                                                    }
                                                    private String jsEscape(String value) {
                                                        if (value == null) return "";
                                                        return value.replace("\\", "\\\\")
                                                                .replace("\"", "\\\"")
                                                                .replace("\n", "\\n")
                                                                .replace("\r", "");
                                                    }
                                                    %>
                                                    <!DOCTYPE html>
                                                    <html lang="vi">

                                                    <head>
                                                        <meta charset="UTF-8">
                                                        <meta name="viewport"
                                                            content="width=device-width, initial-scale=1.0">
                                                        <title>Hồ sơ học viên - HIPZI</title>
                                                        <meta name="description"
                                                            content="Quản lý thông tin tài khoản, kho tài liệu giảng dạy và học liệu AI của giảng viên trên nền tảng HIPZI.">
                                                        <link rel="icon" type="image/png"
                                                            href="${pageContext.request.contextPath}/assets/images/favicon.png">
                                                        <script>
                                                            (function() {
                                                                if (localStorage.getItem('hipzi-student-theme') === 'dark') {
                                                                    document.documentElement.classList.add('dark-profile');
                                                                }
                                                            })();
                                                        </script>
                                                        <link rel="stylesheet"
                                                            href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
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
                                                                background:
                                                                    linear-gradient(135deg, #e6fcf5 0%, #ebfbee 50%, #dcfce7 100%) !important;
                                                                background-attachment: fixed !important;
                                                                font-family: var(--font-sans);
                                                                margin: 0;
                                                                padding: 0;
                                                                min-height: 0;
                                                                position: relative;
                                                            }

                                                            body::before {
                                                                display: none !important;
                                                            }

                                                            body::after {
                                                                display: none !important;
                                                            }

                                                            .app-dashboard-container {
                                                                max-width: 1600px;
                                                                width: calc(100% - 1.5rem);
                                                                min-height: 0;
                                                                height: var(--teacher-dashboard-frame-height, auto);
                                                                margin: 0.75rem auto 0 auto;
                                                                padding-bottom: 0.75rem;
                                                                background: transparent;
                                                                display: flex;
                                                                flex-direction: row;
                                                                gap: 1rem;
                                                                align-items: flex-start;
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
                                                            }

                                                            .top-bar-user-email {
                                                                font-size: 0.7rem;
                                                                color: var(--text-muted);
                                                                line-height: 1.2;
                                                            }

                                                            .nav-bell-dropdown {
                                                                position: relative;
                                                                width: 42px;
                                                                height: 42px;
                                                                flex: 0 0 42px;
                                                                display: flex;
                                                                align-items: center;
                                                                justify-content: center;
                                                            }

                                                            .nav-bell-trigger {
                                                                width: 42px;
                                                                height: 42px;
                                                                border-radius: 50%;
                                                                background: #f1f5f9;
                                                                color: var(--text-muted);
                                                                display: flex;
                                                                align-items: center;
                                                                justify-content: center;
                                                                cursor: pointer;
                                                                transition: all 0.2s ease;
                                                                position: relative;
                                                                border: none;
                                                                text-decoration: none;
                                                                padding: 0;
                                                                box-sizing: border-box;
                                                                flex: 0 0 42px;
                                                                line-height: 1;
                                                            }

                                                            .nav-bell-trigger svg {
                                                                display: block;
                                                                flex: 0 0 auto;
                                                            }

                                                            .nav-bell-trigger:hover {
                                                                background: var(--primary-light);
                                                                color: var(--primary);
                                                                transform: translateY(-1px);
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
                                                                from {
                                                                    opacity: 0;
                                                                    transform: translateY(8px);
                                                                }

                                                                to {
                                                                    opacity: 1;
                                                                    transform: translateY(0);
                                                                }
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
                                                                color: #475569;
                                                                margin: 0;
                                                                font-weight: 600;
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
                                                                grid-template-columns: repeat(3, 1fr);
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
                                                                cursor: pointer;
                                                            }

                                                            .metric-card.primary {
                                                                background: #ffffff;
                                                                color: var(--text-main);
                                                                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
                                                            }

                                                            .metric-card.secondary {
                                                                background: #ffffff;
                                                            }

                                                            .metrics-row .metric-card:nth-child(1) {
                                                                border-top-color: var(--primary);
                                                            }

                                                            .metrics-row .metric-card:nth-child(2) {
                                                                border-top-color: #7c3aed;
                                                            }

                                                            .metrics-row .metric-card:nth-child(3) {
                                                                border-top-color: #ea580c;
                                                            }

                                                            .metrics-row .metric-card:nth-child(4) {
                                                                border-top-color: #2563eb;
                                                            }

                                                            .metric-card:hover {
                                                                transform: translateY(-3px);
                                                                box-shadow: 0 16px 34px rgba(15, 23, 42, 0.1);
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

                                                            .metric-card.primary .metric-card-title {
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
                                                                color: var(--primary);
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
                                                                position: relative;
                                                                z-index: 1;
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
                                                            }

                                                            .metric-card.primary .metric-card-sub {
                                                                background: var(--primary-light);
                                                                color: var(--primary);
                                                            }

                                                            .metric-card.secondary .metric-card-sub {
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

                                                            .overview-analytics-grid {
                                                                display: grid;
                                                                grid-template-columns: 1fr;
                                                                gap: 1.25rem;
                                                                margin-top: 1.25rem;
                                                            }

                                                            @media (max-width: 1100px) {
                                                                .overview-analytics-grid {
                                                                    grid-template-columns: 1fr;
                                                                }
                                                            }

                                                            .overview-chart-card {
                                                                background: #ffffff;
                                                                border: 1px solid #e5e7eb;
                                                                border-radius: 1.5rem;
                                                                box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
                                                                padding: 1.25rem;
                                                                min-height: 300px;
                                                                box-sizing: border-box;
                                                                overflow: hidden;
                                                            }

                                                            .overview-chart-head {
                                                                display: flex;
                                                                align-items: flex-start;
                                                                justify-content: space-between;
                                                                gap: 1rem;
                                                                margin-bottom: 1rem;
                                                            }

                                                            .overview-chart-title-block {
                                                                display: flex;
                                                                flex-direction: column;
                                                                gap: 0.72rem;
                                                                min-width: 0;
                                                            }

                                                            .overview-chart-title {
                                                                margin: 0;
                                                                color: var(--text-main);
                                                                font-size: 1rem;
                                                                font-weight: 800;
                                                            }

                                                            .overview-chart-summary {
                                                                display: flex;
                                                                flex-wrap: wrap;
                                                                gap: 0.55rem;
                                                            }

                                                            .overview-summary-pill {
                                                                display: inline-flex;
                                                                align-items: center;
                                                                gap: 0.45rem;
                                                                border: 1px solid #e2e8f0;
                                                                border-radius: 999px;
                                                                background: #f8fafc;
                                                                color: #475569;
                                                                padding: 0.34rem 0.68rem;
                                                                font-size: 0.72rem;
                                                                font-weight: 850;
                                                                line-height: 1;
                                                                white-space: nowrap;
                                                            }

                                                            .overview-summary-pill strong {
                                                                color: var(--text-main);
                                                                font-size: 0.8rem;
                                                                font-weight: 900;
                                                            }

                                                            .overview-summary-pill.taught strong {
                                                                color: #059669;
                                                            }

                                                            .overview-summary-pill.scheduled strong {
                                                                color: #d97706;
                                                            }

                                                            .overview-summary-pill.trend {
                                                                background: #dcfce7;
                                                                border-color: #bbf7d0;
                                                                color: #166534;
                                                            }

                                                            .overview-summary-pill.trend strong {
                                                                color: #166534;
                                                                font-weight: 750;
                                                            }

                                                            .overview-chart-subtitle {
                                                                margin: 0.28rem 0 0;
                                                                color: var(--text-muted);
                                                                font-size: 0.78rem;
                                                                font-weight: 700;
                                                                line-height: 1.45;
                                                            }

                                                            .overview-chart-chip {
                                                                border: 1px solid #e2e8f0;
                                                                background: #f8fafc;
                                                                color: #475569;
                                                                border-radius: 999px;
                                                                padding: 0.36rem 0.72rem;
                                                                font-size: 0.74rem;
                                                                font-weight: 800;
                                                                white-space: nowrap;
                                                            }

                                                            .overview-period-switch {
                                                                position: relative;
                                                                display: grid;
                                                                grid-template-columns: 1fr 1fr;
                                                                width: 136px;
                                                                height: 36px;
                                                                border: 1px solid #dbe3ee;
                                                                border-radius: 999px;
                                                                background: #f8fafc;
                                                                padding: 2px;
                                                                box-sizing: border-box;
                                                                box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8), 0 8px 20px rgba(15, 23, 42, 0.06);
                                                            }

                                                            .overview-period-switch::before {
                                                                content: "";
                                                                position: absolute;
                                                                top: 3px;
                                                                left: 3px;
                                                                width: calc(50% - 10px);
                                                                height: calc(100% - 6px);
                                                                border-radius: 999px;
                                                                background: #ffffff;
                                                                border: 1px solid #cde8dd;
                                                                box-shadow: 0 8px 18px rgba(5, 150, 105, 0.16);
                                                                transform: translateX(0);
                                                                transition: transform 0.34s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.24s ease;
                                                            }

                                                            .overview-period-switch[data-active="month"]::before {
                                                                transform: translateX(calc(100% + 14px));
                                                            }

                                                            .overview-period-btn {
                                                                position: relative;
                                                                z-index: 1;
                                                                border: 0;
                                                                background: transparent;
                                                                color: #64748b;
                                                                border-radius: 999px;
                                                                font-size: 0.74rem;
                                                                font-weight: 900;
                                                                cursor: pointer;
                                                                transition: color 0.22s ease, transform 0.22s ease;
                                                            }

                                                            .overview-period-btn[data-period="month"] {
                                                                padding-left: 0.62rem;
                                                                padding-right: 0.08rem;
                                                            }

                                                            .overview-period-btn:hover {
                                                                color: var(--primary);
                                                            }

                                                            .overview-period-btn.is-active {
                                                                color: var(--primary);
                                                                transform: translateY(-1px);
                                                            }

                                                            .overview-period-btn:focus-visible {
                                                                outline: 2px solid rgba(5, 150, 105, 0.35);
                                                                outline-offset: 3px;
                                                            }

                                                            @media (max-width: 640px) {
                                                                .overview-chart-head {
                                                                    flex-direction: column;
                                                                    align-items: stretch;
                                                                }

                                                                .overview-period-switch {
                                                                    align-self: flex-start;
                                                                }
                                                            }

                                                            .overview-line-wrap {
                                                                position: relative;
                                                                min-height: 214px;
                                                            }

                                                            .overview-line-wrap.is-switching .overview-line-chart,
                                                            .overview-line-wrap.is-switching .overview-line-tooltip {
                                                                opacity: 0.38;
                                                            }

                                                            .overview-line-chart {
                                                                width: 100%;
                                                                height: 214px;
                                                                display: block;
                                                                transition: opacity 0.22s ease;
                                                            }

                                                            .overview-line-chart text {
                                                                fill: #94a3b8;
                                                                font-size: 12px;
                                                                font-weight: 700;
                                                            }

                                                            .overview-line-tooltip {
                                                                position: absolute;
                                                                top: 44px;
                                                                left: 46%;
                                                                transform: translateX(-50%);
                                                                background: #0f172a;
                                                                color: #ffffff;
                                                                border-radius: 0.75rem;
                                                                padding: 0.85rem 0.95rem;
                                                                box-shadow: 0 16px 34px rgba(15, 23, 42, 0.28);
                                                                min-width: 146px;
                                                                transition: opacity 0.22s ease;
                                                            }

                                                            .overview-line-tooltip strong {
                                                                display: block;
                                                                font-size: 0.78rem;
                                                                margin-bottom: 0.55rem;
                                                            }

                                                            .overview-tooltip-row {
                                                                display: flex;
                                                                align-items: center;
                                                                justify-content: space-between;
                                                                gap: 1rem;
                                                                color: #cbd5e1;
                                                                font-size: 0.76rem;
                                                                font-weight: 700;
                                                            }

                                                            .overview-tooltip-row+.overview-tooltip-row {
                                                                margin-top: 0.4rem;
                                                            }

                                                            .overview-tooltip-label {
                                                                display: inline-flex;
                                                                align-items: center;
                                                                gap: 0.42rem;
                                                            }

                                                            .overview-tooltip-dot {
                                                                width: 3px;
                                                                height: 18px;
                                                                border-radius: 999px;
                                                                display: inline-block;
                                                            }

                                                            .overview-chart-legend {
                                                                display: flex;
                                                                flex-wrap: wrap;
                                                                gap: 0.85rem;
                                                                margin-top: 0.85rem;
                                                                color: var(--text-muted);
                                                                font-size: 0.76rem;
                                                                font-weight: 800;
                                                            }

                                                            .overview-legend-item {
                                                                display: inline-flex;
                                                                align-items: center;
                                                                gap: 0.42rem;
                                                            }

                                                            .overview-legend-dot {
                                                                width: 9px;
                                                                height: 9px;
                                                                border-radius: 50%;
                                                                display: inline-block;
                                                            }

                                                            .overview-donut-chart-container {
                                                                display: flex;
                                                                flex-direction: column;
                                                                align-items: center;
                                                                justify-content: center;
                                                                height: 100%;
                                                                position: relative;
                                                                padding: 1rem;
                                                                gap: 1.5rem;
                                                                flex-grow: 1;
                                                                margin-top: -15px;
                                                            }

                                                            .overview-donut-chart {
                                                                width: 164px;
                                                                height: 164px;
                                                                border-radius: 50%;
                                                                background: conic-gradient(#059669 0deg 245deg,
                                                                        #f59e0b 245deg 324deg,
                                                                        #ef4444 324deg 360deg);
                                                                position: relative;
                                                                display: flex;
                                                                align-items: center;
                                                                justify-content: center;
                                                                flex-shrink: 0;
                                                                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04);
                                                                animation: donutScaleUp 0.7s cubic-bezier(0.16, 1, 0.3, 1) forwards;
                                                                transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s ease;
                                                            }

                                                            .overview-donut-chart:hover {
                                                                transform: scale(1.05) rotate(0deg);
                                                                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
                                                            }

                                                            .overview-donut-hole {
                                                                width: 122px;
                                                                height: 122px;
                                                                background: #ffffff;
                                                                border-radius: 50%;
                                                                display: flex;
                                                                flex-direction: column;
                                                                align-items: center;
                                                                justify-content: center;
                                                                box-shadow: inset 0 2px 10px rgba(0, 0, 0, 0.02);
                                                                transition: transform 0.3s ease;
                                                            }

                                                            .overview-donut-chart:hover .overview-donut-hole {
                                                                transform: scale(0.96);
                                                            }

                                                            .overview-donut-score {
                                                                display: flex;
                                                                align-items: center;
                                                                gap: 0.3rem;
                                                                color: var(--text-main);
                                                                font-size: 1.6rem;
                                                                font-weight: 900;
                                                                line-height: 1.1;
                                                            }

                                                            .overview-donut-total {
                                                                color: var(--text-muted);
                                                                font-size: 0.78rem;
                                                                font-weight: 700;
                                                                margin-top: 0.2rem;
                                                            }

                                                            @keyframes donutScaleUp {
                                                                from {
                                                                    transform: scale(0.8) rotate(-15deg);
                                                                    opacity: 0;
                                                                }

                                                                to {
                                                                    transform: scale(1) rotate(0);
                                                                    opacity: 1;
                                                                }
                                                            }

                                                            .overview-donut-legend {
                                                                display: flex;
                                                                flex-direction: column;
                                                                gap: 0.85rem;
                                                                width: 100%;
                                                                padding: 0 0.5rem;
                                                            }

                                                            .overview-donut-legend-item {
                                                                display: flex;
                                                                align-items: center;
                                                                gap: 0.75rem;
                                                                font-size: 0.88rem;
                                                                font-weight: 700;
                                                                color: var(--text-main);
                                                                transition: transform 0.2s ease;
                                                                width: 100%;
                                                            }

                                                            .overview-donut-legend-item:hover {
                                                                transform: translateX(4px);
                                                            }

                                                            .overview-donut-legend-color {
                                                                width: 12px;
                                                                height: 12px;
                                                                border-radius: 50%;
                                                                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                                                                flex-shrink: 0;
                                                            }

                                                            .overview-donut-legend-label {
                                                                flex-grow: 1;
                                                            }

                                                            .overview-donut-legend-value {
                                                                color: var(--text-muted);
                                                                font-weight: 800;
                                                                font-size: 0.9rem;
                                                                display: flex;
                                                                align-items: center;
                                                                gap: 0.75rem;
                                                            }

                                                            .overview-donut-progress-bg {
                                                                width: 48px;
                                                                height: 6px;
                                                                background: #e2e8f0;
                                                                border-radius: 99px;
                                                                overflow: hidden;
                                                                display: inline-block;
                                                            }

                                                            .overview-donut-progress-fill {
                                                                height: 100%;
                                                                display: block;
                                                                border-radius: 99px;
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

                                                            #tab-profile .premium-card,
                                                            #tab-support .premium-card,
                                                            #tab-history .premium-card,
                                                            #tab-course-registration .premium-card,
                                                            #tab-upload-material .premium-card,
                                                            #tab-my-classes .premium-card,
                                                            #tab-my-courses .premium-card,
                                                            #tab-my-schedule .premium-card,
                                                            #tab-wallet-history .premium-card {
                                                                background: #ffffff;
                                                            }

                                                            #tab-support #supportForm input,
                                                            #tab-support #supportForm textarea {
                                                                background: #f8fafc;
                                                            }

                                                            #tab-support .dashboard-grid-layout {
                                                                align-items: stretch !important;
                                                            }

                                                            #tab-support .dashboard-grid-layout>.premium-card {
                                                                height: 100%;
                                                            }

                                                            #tab-support #supportForm {
                                                                flex: 1;
                                                            }

                                                            #tab-support .support-submit-row {
                                                                margin-top: auto;
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

                                                            .info-icon-circle svg {
                                                                width: 20px;
                                                                height: 20px;
                                                                stroke-width: 2.15;
                                                            }

                                                            .info-icon-circle.primary {
                                                                background: var(--primary-light);
                                                                color: var(--primary);
                                                            }

                                                            .info-icon-circle.accent {
                                                                background: var(--accent-light);
                                                                color: var(--accent);
                                                            }

                                                            .info-icon-circle.warning {
                                                                background: #fff9db;
                                                                color: #f59e0b;
                                                            }

                                                            .info-icon-circle.danger {
                                                                background: #ffe3e3;
                                                                color: #ef4444;
                                                            }

                                                            .info-content {
                                                                display: flex;
                                                                flex-direction: column;
                                                                min-width: 0;
                                                                flex-grow: 1;
                                                                align-items: flex-start;
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

                                                            .account-name-view {
                                                                min-height: 2.35rem;
                                                                display: flex;
                                                                align-items: center;
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

                                                            .status-badge.open {
                                                                background: #dcfce7;
                                                                color: #15803d;
                                                            }

                                                            .status-badge.upcoming {
                                                                background: #fef9c3;
                                                                color: #a16207;
                                                            }

                                                            .status-badge.closed {
                                                                background: #fee2e2;
                                                                color: #b91c1c;
                                                            }

                                                            /* Buttons & Forms */
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
                                                                background: #f8fafc;
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

                                                            .field-required {
                                                                color: #ef4444;
                                                                font-weight: 900;
                                                                margin-left: 0.18rem;
                                                            }

                                                            .field-optional {
                                                                color: var(--text-muted);
                                                                font-weight: 600;
                                                                font-size: 0.76rem;
                                                                margin-left: 0.25rem;
                                                            }

                                                            .teacher-form-section {
                                                                display: flex;
                                                                flex-direction: column;
                                                                gap: 1.15rem;
                                                            }

                                                            .teacher-form-section .form-group-premium {
                                                                gap: 0.62rem;
                                                            }

                                                            .teacher-form-section .form-group-premium>label {
                                                                line-height: 1.45;
                                                                margin-bottom: 0.05rem;
                                                            }

                                                            .teacher-form-section+.teacher-form-section {
                                                                margin-top: 1.6rem;
                                                                padding-top: 1.4rem;
                                                                border-top: 1px solid var(--border-light);
                                                            }

                                                            .teacher-form-section-title {
                                                                display: flex;
                                                                align-items: center;
                                                                gap: 0.5rem;
                                                                color: var(--text-muted);
                                                                font-size: 0.78rem;
                                                                font-weight: 800;
                                                                letter-spacing: 0.03em;
                                                                text-transform: uppercase;
                                                            }

                                                            .teacher-form-section-title::before {
                                                                content: "";
                                                                width: 0.5rem;
                                                                height: 0.5rem;
                                                                border-radius: 999px;
                                                                background: var(--primary);
                                                                box-shadow: 0 0 0 4px var(--primary-light);
                                                            }

                                                            .teacher-registration-form-grid {
                                                                display: grid;
                                                                grid-template-columns: repeat(3, minmax(0, 1fr));
                                                                gap: 1.15rem 1rem;
                                                            }

                                                            .teacher-registration-form-grid .full-span {
                                                                grid-column: 1 / -1;
                                                            }

                                                            @media (max-width: 1000px) {
                                                                .teacher-registration-form-grid {
                                                                    grid-template-columns: 1fr;
                                                                }
                                                            }

                                                            .teacher-registration-select {
                                                                color: var(--text-main);
                                                                appearance: none;
                                                                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2.4' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
                                                                background-repeat: no-repeat;
                                                                background-position: right 0.95rem center;
                                                                background-size: 1rem;
                                                                padding-right: 2.6rem;
                                                            }

                                                            .teacher-registration-textarea {
                                                                min-height: 118px;
                                                                resize: vertical;
                                                            }

                                                            input[name="teachingSubjects"] {
                                                                appearance: none;
                                                                width: 1.25rem !important;
                                                                height: 1.25rem !important;
                                                                border: 1.5px solid #cbd5e1;
                                                                border-radius: 0.3rem !important;
                                                                background: #f8fafc;
                                                                display: inline-grid;
                                                                place-content: center;
                                                                cursor: pointer;
                                                                transition: background-color 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
                                                            }

                                                            input[name="teachingSubjects"]:hover {
                                                                border-color: var(--primary);
                                                                box-shadow: 0 0 0 4px rgba(4, 120, 87, 0.08);
                                                            }

                                                            input[name="teachingSubjects"]:checked {
                                                                border-color: var(--primary);
                                                                background-color: var(--primary) !important;
                                                                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23ffffff' stroke-width='3.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 6 9 17l-5-5'/%3E%3C/svg%3E");
                                                                background-repeat: no-repeat;
                                                                background-position: center;
                                                                background-size: 0.95rem;
                                                                box-shadow: 0 6px 14px rgba(4, 120, 87, 0.24), 0 0 0 4px rgba(4, 120, 87, 0.1);
                                                                transform: scale(1.04);
                                                            }

                                                            .teacher-registration-readonly input[name="teachingSubjects"]:checked,
                                                            .teacher-registration-readonly input[name="teachingSubjects"]:disabled:checked,
                                                            .teacher-registration-editing input[name="teachingSubjects"]:checked {
                                                                border-color: var(--primary) !important;
                                                                background-color: var(--primary) !important;
                                                                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23ffffff' stroke-width='3.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 6 9 17l-5-5'/%3E%3C/svg%3E") !important;
                                                                background-repeat: no-repeat !important;
                                                                background-position: center !important;
                                                                background-size: 0.95rem !important;
                                                            }

                                                            input[name="teachingSubjects"]:checked+span {
                                                                color: var(--primary);
                                                            }

                                                            .teacher-subject-selected {
                                                                color: var(--primary) !important;
                                                                font-weight: 800 !important;
                                                            }

                                                            .teacher-evidence-dropzone {
                                                                position: relative;
                                                                display: flex;
                                                                flex-direction: column;
                                                                align-items: center;
                                                                justify-content: center;
                                                                gap: 0.65rem;
                                                                min-height: 150px;
                                                                padding: 1.25rem;
                                                                border: 1.5px dashed #cbd5e1;
                                                                border-radius: 1rem;
                                                                background: #ffffff;
                                                                text-align: center;
                                                                cursor: pointer;
                                                                transition: all 0.2s ease;
                                                            }

                                                            .teacher-evidence-dropzone:hover,
                                                            .teacher-evidence-dropzone.drag-over {
                                                                border-color: var(--primary);
                                                                background: var(--primary-light);
                                                                box-shadow: 0 0 0 3px rgba(4, 120, 87, 0.08);
                                                            }

                                                            .teacher-evidence-dropzone input[type="file"] {
                                                                position: absolute;
                                                                inset: 0;
                                                                opacity: 0;
                                                                cursor: pointer;
                                                            }

                                                            .teacher-evidence-icon {
                                                                width: 44px;
                                                                height: 44px;
                                                                border-radius: 999px;
                                                                display: inline-flex;
                                                                align-items: center;
                                                                justify-content: center;
                                                                color: var(--primary);
                                                                background: #ffffff;
                                                                border: 1px solid var(--border-dark);
                                                                box-shadow: var(--shadow);
                                                            }

                                                            .teacher-evidence-title {
                                                                color: var(--text-main);
                                                                font-size: 0.95rem;
                                                                font-weight: 800;
                                                            }

                                                            .teacher-evidence-subtitle,
                                                            .teacher-evidence-filename {
                                                                color: var(--text-muted);
                                                                font-size: 0.8rem;
                                                                line-height: 1.5;
                                                            }

                                                            .teacher-evidence-filename {
                                                                color: var(--primary);
                                                                font-weight: 700;
                                                            }

                                                            .form-actions-row-premium {
                                                                display: flex;
                                                                justify-content: flex-end;
                                                                gap: 1rem;
                                                                margin-top: 0.5rem;
                                                            }

                                                            .form-actions-row-premium.is-hidden {
                                                                display: none !important;
                                                            }

                                                            .teacher-registration-readonly input:not([type="hidden"]),
                                                            .teacher-registration-readonly select,
                                                            .teacher-registration-readonly textarea {
                                                                background-color: #ffffff !important;
                                                                color: #64748b !important;
                                                                cursor: not-allowed !important;
                                                            }

                                                            .teacher-registration-readonly .teacher-type-card,
                                                            .teacher-registration-readonly .teacher-evidence-dropzone,
                                                            .teacher-registration-readonly .teacher-subject-option {
                                                                cursor: not-allowed !important;
                                                            }

                                                            .teacher-registration-editing input:not([type="hidden"]),
                                                            .teacher-registration-editing select,
                                                            .teacher-registration-editing textarea {
                                                                background-color: #ffffff;
                                                                color: var(--text-main);
                                                            }

                                                            .checkbox-grid-premium {
                                                                display: grid;
                                                                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                                                                gap: 1rem;
                                                                margin-top: 0.5rem;
                                                                background: #f8fafc;
                                                                padding: 1rem;
                                                                border-radius: 0.75rem;
                                                                border: 1px solid var(--border-dark);
                                                            }

                                                            .checkbox-premium-label {
                                                                display: flex;
                                                                align-items: center;
                                                                gap: 0.5rem;
                                                                font-weight: 500;
                                                                cursor: pointer;
                                                                color: var(--text-main);
                                                                font-size: 0.95rem;
                                                            }

                                                            .checkbox-premium-input {
                                                                width: 1.25rem;
                                                                height: 1.25rem;
                                                                margin: 0;
                                                                padding: 0;
                                                                flex-shrink: 0;
                                                                border-radius: 0.25rem;
                                                            }

                                                            .teacher-type-helper-text {
                                                                color: var(--text-muted);
                                                                font-size: 0.9rem;
                                                                margin: 0 0 1rem 0;
                                                                line-height: 1.5;
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
                                                                content: '\2714';
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

                                                            .teacher-type-card input:focus-visible+.teacher-type-card-inner {
                                                                outline: 2px solid var(--primary);
                                                                outline-offset: 2px;
                                                            }

                                                            .teacher-type-card input:checked+.teacher-type-card-inner {
                                                                border-color: var(--primary);
                                                                background: linear-gradient(180deg, var(--primary-light) 0%, #ffffff 60%);
                                                                box-shadow: 0 12px 24px rgba(4, 120, 87, 0.12);
                                                                transform: translateY(-3px);
                                                            }

                                                            .teacher-type-card input:checked+.teacher-type-card-inner::after {
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

                                                            .teacher-type-examples {
                                                                list-style: none;
                                                                padding-left: 0;
                                                            }

                                                            .teacher-type-examples li {
                                                                position: relative;
                                                                padding-left: 1.55rem;
                                                            }

                                                            .teacher-type-examples li::before {
                                                                content: '\2713';
                                                                position: absolute;
                                                                left: 0;
                                                                top: 0.05rem;
                                                                color: #10b981;
                                                                font-weight: 900;
                                                                font-size: 1rem;
                                                                line-height: 1;
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
                                                                background: #059669;
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
                                                                from {
                                                                    transform: translateX(120%);
                                                                    opacity: 0;
                                                                }

                                                                to {
                                                                    transform: translateX(0);
                                                                    opacity: 1;
                                                                }
                                                            }

                                                            /* Account Status tags */
                                                            .acc-status-tag {
                                                                display: inline-flex;
                                                                align-items: center;
                                                                font-size: 0.75rem;
                                                                font-weight: 700;
                                                                padding: 0.2rem 0.6rem;
                                                                border-radius: 0.5rem;
                                                                width: fit-content;
                                                                max-width: max-content;
                                                                align-self: flex-start;
                                                            }

                                                            .acc-status-tag.active {
                                                                background: #dcfce7;
                                                                color: #15803d;
                                                            }

                                                            .acc-status-tag.suspended {
                                                                background: #fef9c3;
                                                                color: #a16207;
                                                            }

                                                            /* General role-tag */
                                                            .role-tag {
                                                                font-size: 0.75rem;
                                                                font-weight: 800;
                                                                padding: 0.25rem 0.75rem;
                                                                border-radius: 2rem;
                                                                text-transform: uppercase;
                                                            }

                                                            .role-tag.teacher {
                                                                background: #f3e8ff;
                                                                color: #7c3aed;
                                                            }

                                                            .role-tag.student {
                                                                background: #e0f2fe;
                                                                color: #0284c7;
                                                            }

                                                            .role-tag.staff {
                                                                background: #dbeafe;
                                                                color: #2563eb;
                                                            }

                                                            .role-tag.admin {
                                                                background: #fee2e2;
                                                                color: #dc2626;
                                                            }

                                                            .account-header-actions,
                                                            .account-edit-actions {
                                                                display: flex;
                                                                align-items: center;
                                                                gap: 0.6rem;
                                                                flex-wrap: wrap;
                                                            }

                                                            .account-cancel-btn {
                                                                background: #ffffff;
                                                                color: var(--text-main);
                                                                border: 1px solid var(--border-dark);
                                                            }

                                                            .account-cancel-btn:hover {
                                                                background: #f8fafc;
                                                                border-color: #cbd5e1;
                                                            }

                                                            .btn-premium.profile-edit-btn,
                                                            .btn-premium.secondary.profile-edit-btn,
                                                            .account-save-btn {
                                                                background: var(--primary);
                                                                color: #ffffff;
                                                                border: 1px solid var(--primary);
                                                                box-shadow: 0 10px 20px rgba(4, 120, 87, 0.16);
                                                            }

                                                            .btn-premium.profile-edit-btn:hover,
                                                            .btn-premium.secondary.profile-edit-btn:hover,
                                                            .account-save-btn:hover {
                                                                background: var(--primary-hover);
                                                                border-color: var(--primary-hover);
                                                            }

                                                            .btn-premium.profile-edit-btn svg {
                                                                color: currentColor;
                                                            }

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

                                                            /* ===== Lịch sử học tập - Thứ học Checkboxes ===== */
                                                            .class-day-options {
                                                                display: flex;
                                                                flex-wrap: wrap;
                                                                gap: 0.75rem;
                                                                margin-top: 0.25rem;
                                                            }

                                                            .class-day-option {
                                                                display: flex !important;
                                                                align-items: center;
                                                                gap: 0.5rem;
                                                                font-weight: 600 !important;
                                                                cursor: pointer;
                                                                color: var(--text-main) !important;
                                                                font-size: 0.9rem !important;
                                                                padding: 0.5rem 0.85rem;
                                                                border-radius: 0.6rem;
                                                                border: 1px solid var(--border-dark);
                                                                background: #ffffff;
                                                                transition: all 0.2s ease;
                                                                margin: 0 !important;
                                                            }

                                                            .class-day-option:hover input[name="scheduleDays"] {
                                                                border-color: var(--primary);
                                                                box-shadow: 0 0 0 4px rgba(4, 120, 87, 0.08);
                                                            }

                                                            input[name="scheduleDays"] {
                                                                appearance: none;
                                                                width: 1.1rem !important;
                                                                height: 1.1rem !important;
                                                                min-width: 1.1rem !important;
                                                                min-height: 1.1rem !important;
                                                                border: 1px solid #cbd5e1;
                                                                border-radius: 0.15rem !important;
                                                                background: #f9fafb;
                                                                display: inline-grid;
                                                                place-content: center;
                                                                cursor: pointer;
                                                                transition: all 0.18s ease;
                                                                margin: 0 !important;
                                                                padding: 0 !important;
                                                                flex-shrink: 0;
                                                                box-sizing: border-box !important;
                                                            }

                                                            input[name="scheduleDays"]:checked {
                                                                border-color: var(--primary) !important;
                                                                background-color: var(--primary) !important;
                                                                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23ffffff' stroke-width='3.2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M20 6 9 17l-5-5'/%3E%3C/svg%3E") !important;
                                                                background-repeat: no-repeat !important;
                                                                background-position: center !important;
                                                                background-size: 0.8rem !important;
                                                                box-shadow: 0 4px 10px rgba(4, 120, 87, 0.2), 0 0 0 4px rgba(4, 120, 87, 0.1);
                                                                transform: scale(1.05);
                                                            }

                                                            /* ========================================== */
        .schedule-modal-backdrop {
            position: fixed;
            top: 0; left: 0; width: 100vw; height: 100vh;
            background: rgba(15, 23, 42, 0.45);
            backdrop-filter: blur(4px);
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .schedule-modal-backdrop.show {
            display: flex;
            opacity: 1;
        }

        .schedule-modal-box {
            background: #ffffff;
            width: 95vw;
            max-width: 1100px;
            height: 85vh;
            border-radius: 1.5rem;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            transform: scale(0.95) translateY(20px);
            transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .schedule-modal-backdrop.show .schedule-modal-box {
            transform: scale(1) translateY(0);
        }

        .schedule-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e2e8f0;
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
        }

        .schedule-header h2 {
            font-size: 1.5rem;
            font-weight: 800;
            margin: 0;
            color: var(--text-main);
        }

        .schedule-actions {
            display: flex;
            gap: 1rem;
            align-items: center;
            justify-content: flex-end;
        }

        .schedule-btn-group {
            display: flex;
            background: #f1f5f9;
            border-radius: 0.5rem;
            padding: 0.25rem;
            justify-self: center;
        }

        .schedule-btn-group button {
            border: none;
            background: transparent;
            padding: 0.5rem 1rem;
            border-radius: 0.35rem;
            font-weight: 600;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s;
        }

        .schedule-btn-group button.active {
            background: #ffffff;
            color: var(--text-main);
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .schedule-close-btn {
            background: #f1f5f9;
            border: none;
            width: 36px; height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center; justify-content: center;
            cursor: pointer;
            color: #64748b;
        }

        .schedule-close-btn:hover {
            background: #e2e8f0;
            color: #0f172a;
        }

        .schedule-body {
            flex: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            background: #f8fafc;
        }

        .schedule-body::-webkit-scrollbar {
            width: 8px;
        }
        .schedule-body::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }
        .schedule-body::-webkit-scrollbar-track {
            background: #f1f5f9;
        }

        .schedule-days-header {
            display: grid;
            grid-template-columns: 60px repeat(7, 1fr);
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .schedule-day-col {
            padding: 1rem 0;
            text-align: center;
            border-left: 1px solid #f1f5f9;
        }

        .schedule-day-name {
            font-size: 0.8rem;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
        }

        .schedule-day-num {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--text-main);
            margin-top: 0.25rem;
        }

        .schedule-day-col.active {
            background: var(--primary);
            border-radius: 0.5rem;
            margin: 0.5rem;
            padding: 0.5rem 0;
        }

        .schedule-day-col.active .schedule-day-name,
        .schedule-day-col.active .schedule-day-num {
            color: #ffffff;
        }

        .schedule-grid {
            display: grid;
            grid-template-columns: 60px repeat(7, 1fr);
            flex: 1;
            position: relative;
            padding-top: 1.25rem;
        }

        .schedule-time-col {
            display: flex;
            flex-direction: column;
        }

        .schedule-time-slot {
            height: 80px;
            text-align: right;
            padding-right: 0.75rem;
            font-size: 0.75rem;
            color: #94a3b8;
            font-weight: 600;
            position: relative;
            transform: translateY(-0.5rem);
        }

        .schedule-grid-cols {
            display: contents;
        }

        .schedule-grid-col {
            border-left: 1px solid #e2e8f0;
            background-image: linear-gradient(to bottom, #e2e8f0 1px, transparent 1px);
            background-size: 100% 80px;
            position: relative;
        }

        .schedule-event {
            position: absolute;
            left: 0.5rem; right: 0.5rem;
            border-radius: 0.75rem;
            padding: 0.75rem;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            transition: transform 0.2s;
            overflow: hidden;
        }

        .schedule-event:hover {
            transform: scale(1.02);
            z-index: 20;
        }

        .schedule-event-title {
            font-weight: 800;
            font-size: 0.85rem;
            color: #0f172a;
            margin-bottom: 0.25rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .schedule-event-time {
            font-size: 0.75rem;
            color: rgba(15, 23, 42, 0.7);
            font-weight: 600;
        }

        /* Colors for events */
        .event-blue { background: #bfdbfe; }
        .event-green { background: #bbf7d0; }
        .event-yellow { background: #fef08a; }
        .event-purple { background: #e9d5ff; }
        .event-pink { background: #fbcfe8; }
        html.dark-profile {
            --background: #0D1410;
            --surface: #152219;
            --text-main: #E2E8E4;
            --text-muted: #9AA89E;
            --border-dark: #24362A;
            --border-light: #1A261E;
            --primary: #5EC977;
            --primary-hover: #4EB465;
            --primary-light: rgba(94, 201, 119, 0.15);
            --secondary: #F0B429;
            --secondary-hover: #DCA01C;
            --secondary-light: rgba(240, 180, 41, 0.15);
            --danger: #EF4444;
            --danger-light: rgba(239, 68, 68, 0.15);
            --success: #10B981;
            --success-light: rgba(16, 185, 129, 0.15);
            --warning: #F59E0B;
            --warning-light: rgba(245, 158, 11, 0.15);
            --info: #3B82F6;
            --info-light: rgba(59, 130, 246, 0.15);
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.4);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.4), 0 2px 4px -1px rgba(0, 0, 0, 0.3);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -2px rgba(0, 0, 0, 0.3);
        }

        /* Toggle animation CSS */
        .dark-mode-toggle-btn {
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .dark-mode-toggle-btn svg {
            position: absolute;
            transition: opacity 0.3s ease, transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
            transform-origin: center;
        }
        .dark-mode-toggle-btn svg.icon-hidden {
            opacity: 0;
            transform: rotate(90deg) scale(0.5);
            pointer-events: none;
        }
        .dark-mode-toggle-btn svg.icon-visible {
            opacity: 1;
            transform: rotate(0deg) scale(1);
        }

        html.dark-profile body {
            background: var(--background) !important;
        }
        html.dark-profile .dashboard-sidebar { background: var(--surface); }
        html.dark-profile .dashboard-top-bar { background: var(--surface); }
        html.dark-profile .dashboard-content-wrapper { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .metric-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .metric-card.primary { background: var(--surface) !important; }
        html.dark-profile .metric-card.secondary { background: var(--surface) !important; }
        html.dark-profile .overview-chart-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .account-summary-panel { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .stat-card { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .overview-summary-pill { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-muted); }
        html.dark-profile .overview-chart-chip { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-muted); }
        html.dark-profile .overview-period-switch { background: var(--background) !important; border-color: var(--border-dark) !important; box-shadow: none; }
        html.dark-profile .overview-period-switch::before { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .top-bar-search-wrapper { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .top-bar-search-wrapper:focus-within { background: var(--surface) !important; }
        html.dark-profile .nav-bell-trigger { background: var(--background) !important; }
        html.dark-profile .nav-bell-trigger:hover { background: var(--primary-light) !important; }
        html.dark-profile .teacher-form-section-title { color: var(--text-main) !important; }
        html.dark-profile .sidebar-brand-horizontal { color: var(--text-main) !important; }
        html.dark-profile .date-badge { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .teacher-registration-select { background-color: var(--surface) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        html.dark-profile .sidebar-toggle-btn { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .modal-content { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .modal-header { border-color: var(--border-dark) !important; }
        html.dark-profile .modal-footer { border-color: var(--border-dark) !important; }
        html.dark-profile .table-wrapper { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile table th { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        html.dark-profile table td { border-color: var(--border-dark) !important; }
        html.dark-profile .empty-state-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .card-placeholder { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .course-item-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .file-upload-zone { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .activity-item { border-color: var(--border-dark) !important; }

        /* Phase 2 Overrides */
        html.dark-profile .premium-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .profile-info-item { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .account-name-edit-form { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .account-meta-pill { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .account-cancel-btn { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        
        html.dark-profile #tab-support #supportForm textarea,
        html.dark-profile .form-group-premium textarea,
        html.dark-profile .form-group-premium select,
        html.dark-profile .form-group-premium input { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        html.dark-profile .form-group-premium textarea:focus,
        html.dark-profile .form-group-premium select:focus,
        html.dark-profile .form-group-premium input:focus { background: var(--surface) !important; border-color: var(--primary) !important; }
        html.dark-profile .btn-premium.secondary { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        html.dark-profile .btn-premium.secondary:hover { background: var(--border-dark) !important; }
        
        html.dark-profile .teacher-type-card-inner { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .teacher-registration-readonly input,
        html.dark-profile .teacher-registration-readonly select,
        html.dark-profile .teacher-registration-readonly textarea { background-color: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-muted) !important; }
        html.dark-profile .teacher-registration-editing input,
        html.dark-profile .teacher-registration-editing select,
        html.dark-profile .teacher-registration-editing textarea { background-color: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        html.dark-profile .checkbox-grid-premium { background: var(--background) !important; border-color: var(--border-dark) !important; }
        
        html.dark-profile .overview-donut-hole { background: var(--background) !important; }
        html.dark-profile .schedule-modal-box { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .schedule-btn-group { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .schedule-btn-group button.active { background: var(--surface) !important; color: var(--text-main) !important; box-shadow: none !important; border-color: var(--border-dark) !important; }
        html.dark-profile .schedule-close-btn { background: var(--background) !important; border-color: var(--border-dark) !important; color: var(--text-main) !important; }
        html.dark-profile .schedule-days-header { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .class-day-option { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile input[name="scheduleDays"] { background: var(--background) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .teacher-evidence-dropzone { background: var(--background) !important; border-color: var(--border-dark) !important; }

        /* Override Inline Styles */
        html.dark-profile [style*="background: #ffffff"],
        html.dark-profile [style*="background:#ffffff"],
        html.dark-profile [style*="background: #fff;"],
        html.dark-profile [style*="background:#fff;"],
        html.dark-profile [style*="background-color: #ffffff"],
        html.dark-profile [style*="background-color:#ffffff"] {
            background: var(--surface) !important;
            border-color: var(--border-dark) !important;
            color: var(--text-main) !important;
        }

        html.dark-profile [style*="background: #f8fafc"],
        html.dark-profile [style*="background:#f8fafc"],
        html.dark-profile [style*="background: #f1f5f9"],
        html.dark-profile [style*="background:#f1f5f9"],
        html.dark-profile [style*="background: #f3f4f6"],
        html.dark-profile [style*="background:#f3f4f6"],
        html.dark-profile [style*="background: #f9fafb"],
        html.dark-profile [style*="background:#f9fafb"] {
            background: var(--background) !important;
            border-color: var(--border-dark) !important;
            color: var(--text-main) !important;
        }
        
        html.dark-profile [style*="background: #e0f2fe"], html.dark-profile [style*="background:#e0f2fe"] {
            background: rgba(2, 132, 199, 0.1) !important;
            border-color: rgba(2, 132, 199, 0.2) !important;
        }

        /* Success/Warning/Error Cards Inline Styles */
        html.dark-profile [style*="background: #f0fdf4"],
        html.dark-profile [style*="background:#f0fdf4"] {
            background: rgba(16, 185, 129, 0.1) !important;
            border-color: rgba(16, 185, 129, 0.2) !important;
        }
        html.dark-profile [style*="color: #064e3b"], html.dark-profile [style*="color:#064e3b"] { color: #34d399 !important; }
        html.dark-profile [style*="color: #047857"], html.dark-profile [style*="color:#047857"] { color: #10b981 !important; }
        
        html.dark-profile [style*="background: #fffbeb"], html.dark-profile [style*="background:#fffbeb"],
        html.dark-profile [style*="background: #fff7ed"], html.dark-profile [style*="background:#fff7ed"],
        html.dark-profile [style*="background: #fff9db"], html.dark-profile [style*="background:#fff9db"] {
            background: rgba(245, 158, 11, 0.1) !important;
            border-color: rgba(245, 158, 11, 0.2) !important;
        }
        
        html.dark-profile [style*="background: #fef2f2"], html.dark-profile [style*="background:#fef2f2"],
        html.dark-profile [style*="background: #fee2e2"], html.dark-profile [style*="background:#fee2e2"],
        html.dark-profile [style*="background: #ffe3e3"], html.dark-profile [style*="background:#ffe3e3"] {
            background: rgba(239, 68, 68, 0.1) !important;
            border-color: rgba(239, 68, 68, 0.2) !important;
        }

        /* Additional structural cards */
        html.dark-profile .section-data-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .classroom-card { background: var(--surface) !important; border-color: var(--border-dark) !important; }
        html.dark-profile .curriculum-row { background: var(--background) !important; border-color: var(--border-dark) !important; }

        html.dark-profile .toggle-circle[style] {
            background: var(--text-main) !important;
        }
        
        html.dark-profile [style*="border: 1px solid #e2e8f0"],
        html.dark-profile [style*="border: 1px dashed var(--border-dark)"] {
            border-color: var(--border-dark) !important;
        }
        
        html.dark-profile [style*="background:#fff1f2"] {
            background: rgba(225, 29, 72, 0.15) !important;
            border-color: rgba(225, 29, 72, 0.3) !important;
        }
        
                                                        </style>
                                                        <link rel="stylesheet"
                                                            href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
                                                    </head>

                                                    <body class="student-profile-page">

                                                        <% User user=(User) request.getAttribute("user"); if
                                                            (user==null) { user=(User)
                                                            session.getAttribute("loggedUser"); } List<Role> roles =
                                                            (user != null) ? user.getRoles() : null;

                                                            String joinDate = "Chưa cập nhật";
                                                            if (user != null && user.getCreatedAt() != null) {
                                                            joinDate = new
                                                            SimpleDateFormat("dd/MM/yyyy").format(user.getCreatedAt());
                                                            }

                                                            String currentDateDisplay = new SimpleDateFormat("'Hôm nay,' dd/MM/yyyy").format(new Date());

                                                            String initials = "H";
                                                            if (user != null && user.getDisplayName() != null &&
                                                            !user.getDisplayName().isEmpty()) {
                                                            String[] parts = user.getDisplayName().trim().split("\\s+");
                                                            initials = parts[parts.length - 1].substring(0,
                                                            1).toUpperCase();
                                                            }

                                                            List<Notification> notifications = (List<Notification>)
                                                                    request.getAttribute("notifications");
                                                                    List<SupportTicket> userSupportTickets = (List
                                                                        <SupportTicket>)
                                                                            request.getAttribute("userSupportTickets");
                                                                            SupportTicket selectedSupportTicket =
                                                                            (SupportTicket)
                                                                            request.getAttribute("selectedSupportTicket");
                                                                            List<SupportMessage> supportMessages = (List
                                                                                <SupportMessage>)
                                                                                    request.getAttribute("supportMessages");

                                                                                    String initialTab =
                                                                                    request.getParameter("tab");
                                                                                    if (initialTab == null ||
                                                                                    initialTab.trim().isEmpty()) {
                                                                                    initialTab = "tab-dashboard";
                                                                                    } else {
                                                                                    initialTab = initialTab.trim();
                                                                                    if (!initialTab.startsWith("tab-"))
                                                                                    {
                                                                                    initialTab = "tab-" + initialTab;
                                                                                    }
                                                                                    }
                                                                                    StudentStudyProgressStats studyProgressStats =
                                                                                            (StudentStudyProgressStats) request.getAttribute("studentStudyProgressStats");
                                                                                    if (studyProgressStats == null) {
                                                                                        studyProgressStats = new StudentStudyProgressStats();
                                                                                    }
                                                                                    String weeklyStudyJson = studyProgressJson(studyProgressStats.getWeeklyPoints());
                                                                                    String monthlyStudyJson = studyProgressJson(studyProgressStats.getMonthlyPoints());
                                                                                    %>

                                                                                    <%@ include
                                                                                        file="/WEB-INF/fragments/profile-role-label.jspf"
                                                                                        %>



                                                                                        <!-- ===== DÀN TRANG CHÍNH THEO BỐ CỤC PREMIUM ĐỒNG BỘ DONEZO ===== -->
                                                                                        <div
                                                                                            class="app-dashboard-container">

                                                                                            <!-- KÊNH SIDEBAR TRÁI (LEFT PANE) -->
                                                                                            <aside
                                                                                                class="dashboard-sidebar">
                                                                                                <div
                                                                                                    class="sidebar-brand-horizontal">
                                                                                                    <a href="${pageContext.request.contextPath}/index"
                                                                                                        class="brand-avatar-box"
                                                                                                        title="Trang chủ">
                                                                                                        <img src="${pageContext.request.contextPath}/assets/images/favicon.png"
                                                                                                            alt="Hipzi Logo">
                                                                                                    </a>
                                                                                                    <div
                                                                                                        class="brand-text-col">
                                                                                                        <span
                                                                                                            class="brand-title">Hipzi</span>
                                                                                                        <span
                                                                                                            class="brand-subtitle">Platform</span>
                                                                                                    </div>
                                                                                                    <button
                                                                                                        type="button"
                                                                                                        class="sidebar-toggle-btn"
                                                                                                        title="Thu gọn / Mở rộng"
                                                                                                        onclick="toggleSidebar()">
                                                                                                        <svg class="icon-collapse"
                                                                                                            width="16"
                                                                                                            height="16"
                                                                                                            viewBox="0 0 24 24"
                                                                                                            fill="none"
                                                                                                            stroke="currentColor"
                                                                                                            stroke-width="2.5">
                                                                                                            <rect x="3"
                                                                                                                y="3"
                                                                                                                width="18"
                                                                                                                height="18"
                                                                                                                rx="2"
                                                                                                                ry="2" />
                                                                                                            <line x1="9"
                                                                                                                y1="3"
                                                                                                                x2="9"
                                                                                                                y2="21" />
                                                                                                            <path
                                                                                                                d="M16 15l-3-3 3-3" />
                                                                                                        </svg>
                                                                                                        <svg class="icon-expand"
                                                                                                            width="16"
                                                                                                            height="16"
                                                                                                            viewBox="0 0 24 24"
                                                                                                            fill="none"
                                                                                                            stroke="currentColor"
                                                                                                            stroke-width="2.5"
                                                                                                            style="display: none;">
                                                                                                            <rect x="3"
                                                                                                                y="3"
                                                                                                                width="18"
                                                                                                                height="18"
                                                                                                                rx="2"
                                                                                                                ry="2" />
                                                                                                            <line x1="9"
                                                                                                                y1="3"
                                                                                                                x2="9"
                                                                                                                y2="21" />
                                                                                                            <path
                                                                                                                d="M13 9l3 3-3 3" />
                                                                                                        </svg>
                                                                                                    </button>
                                                                                                </div>

                                                                                                <div
                                                                                                    class="sidebar-section-label">
                                                                                                    Tổng quan</div>
                                                                                                <ul
                                                                                                    class="sidebar-menu">
                                                                                                    <li>
                                                                                                        <a id="nav-tab-dashboard"
                                                                                                            class="<%= "tab-dashboard".equals(initialTab) ? "active" : "" %>"
                                                                                                            onclick="switchTab('tab-dashboard')"
                                                                                                            title="Tổng
                                                                                                            quan học
                                                                                                            tập">
                                                                                                            <svg viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="currentColor">
                                                                                                                <rect
                                                                                                                    x="3"
                                                                                                                    y="3"
                                                                                                                    width="7"
                                                                                                                    height="9"
                                                                                                                    rx="1" />
                                                                                                                <rect
                                                                                                                    x="14"
                                                                                                                    y="3"
                                                                                                                    width="7"
                                                                                                                    height="5"
                                                                                                                    rx="1" />
                                                                                                                <rect
                                                                                                                    x="14"
                                                                                                                    y="12"
                                                                                                                    width="7"
                                                                                                                    height="9"
                                                                                                                    rx="1" />
                                                                                                                <rect
                                                                                                                    x="3"
                                                                                                                    y="16"
                                                                                                                    width="7"
                                                                                                                    height="5"
                                                                                                                    rx="1" />
                                                                                                            </svg>
                                                                                                            <span>Tổng
                                                                                                                quan học
                                                                                                                tập</span>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                    <li>
                                                                                                        <a id="nav-tab-profile"
                                                                                                            class="<%= ("tab-profile".equals(initialTab) || "tab-edit".equals(initialTab)) ? "active" : "" %>"
                                                                                                            onclick="switchTab('tab-profile')"
                                                                                                            title="Hồ sơ
                                                                                                            cá nhân">
                                                                                                            <svg viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="currentColor">
                                                                                                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                                                                                <circle cx="12" cy="7" r="4" />
                                                                                                            </svg>
                                                                                                            <span>Hồ sơ
                                                                                                                cá
                                                                                                                nhân</span>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                    <li>
                                                                                                        <a id="nav-tab-support"
                                                                                                            class="<%= "tab-support".equals(initialTab) ? "active" : "" %>"
                                                                                                            onclick="switchTab('tab-support')"
                                                                                                            title="Hỗ
                                                                                                            trợ học
                                                                                                            tập">
                                                                                                            <svg viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="currentColor">
                                                                                                                <circle
                                                                                                                    cx="12"
                                                                                                                    cy="12"
                                                                                                                    r="10" />
                                                                                                                <path
                                                                                                                    d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                                                                                                                <line
                                                                                                                    x1="12"
                                                                                                                    y1="17"
                                                                                                                    x2="12.01"
                                                                                                                    y2="17" />
                                                                                                            </svg>
                                                                                                            <span>Hỗ trợ
                                                                                                                học
                                                                                                                tập</span>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                </ul>

                                                                                                <div
                                                                                                    class="sidebar-section-label">
                                                                                                    Học tập & Luyện thi
                                                                                                </div>
                                                                                                <ul
                                                                                                    class="sidebar-menu">

                                                                                                    <li>
                                                                                                        <a id="nav-tab-my-classes"
                                                                                                            class="<%= "tab-my-classes".equals(initialTab) ? "active" : "" %>"
                                                                                                            onclick="switchTab('tab-my-classes')"
                                                                                                            title="Lớp học của tôi">
                                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                                                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                                                                                                                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                                                                                                            </svg>
                                                                                                            <span>Lớp học của tôi</span>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                    <li>
                                                                                                        <a id="nav-tab-my-courses"
                                                                                                            class="<%= "tab-my-courses".equals(initialTab) ? "active" : "" %>"
                                                                                                            onclick="switchTab('tab-my-courses')"
                                                                                                            title="Khóa học của tôi">
                                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                                                <polygon points="12 2 2 7 12 12 22 7 12 2"/>
                                                                                                                <polyline points="2 17 12 22 22 17"/>
                                                                                                                <polyline points="2 12 12 17 22 12"/>
                                                                                                            </svg>
                                                                                                            <span>Khóa học của tôi</span>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                </ul>

                                                                                                <div class="sidebar-section-label">
                                                                                                    Ví tiền
                                                                                                </div>
                                                                                                <ul class="sidebar-menu">
                                                                                                    <li>
                                                                                                        <a id="nav-tab-wallet-history"
                                                                                                            class="<%= "tab-wallet-history".equals(initialTab) ? "active" : "" %>"
                                                                                                            onclick="switchTab('tab-wallet-history')"
                                                                                                            title="Thanh toán học phí">
                                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                                                                                <rect x="2" y="4" width="20" height="16" rx="2" ry="2"/>
                                                                                                                <line x1="2" y1="10" x2="22" y2="10"/>
                                                                                                                <path d="M7 15h0M11 15h2"/>
                                                                                                            </svg>
                                                                                                            <span>Thanh toán học phí</span>
                                                                                                        </a>
                                                                                                    </li>
                                                                                                </ul>
                                                                                            </aside>

                                                                                            <!-- KÊNH PHẢI CHÍNH -->
                                                                                            <div
                                                                                                class="dashboard-main-section">

                                                                                                <!-- TOP BAR ĐỒNG BỘ DONEZO -->
                                                                                                <div
                                                                                                    class="dashboard-top-bar">
                                                                                                    <div
                                                                                                        class="top-bar-search-wrapper">
                                                                                                        <svg viewBox="0 0 24 24"
                                                                                                            fill="none"
                                                                                                            stroke="currentColor"
                                                                                                            stroke-width="2.5">
                                                                                                            <circle
                                                                                                                cx="11"
                                                                                                                cy="11"
                                                                                                                r="8" />
                                                                                                            <line
                                                                                                                x1="21"
                                                                                                                y1="21"
                                                                                                                x2="16.65"
                                                                                                                y2="16.65" />
                                                                                                        </svg>
                                                                                                        <input
                                                                                                            type="text"
                                                                                                            placeholder="Tìm kiếm tác vụ...">

                                                                                                    </div>

                                                                                                    <div
                                                                                                        class="top-bar-right">
                                                                                                        <!-- STREAK UI -->
                                                                                                        <button class="nav-bell-trigger streak-toggle-btn" id="streakToggleBtn"
                                                                                                                onclick="handleStreakClick()"
                                                                                                                title="Thắp lửa chuỗi học tập"
                                                                                                                aria-label="Thắp lửa chuỗi học tập"
                                                                                                                style="perspective: 1000px; overflow: visible; cursor: pointer; border: none;">
                                                                                                            <div id="streakCoin" style="width: 20px; height: 20px; position: relative; transition: transform 0.6s cubic-bezier(0.4, 0.2, 0.2, 1); transform-style: preserve-3d; margin: 0 auto;">
                                                                                                                <!-- Mặt trước: Ngọn lửa -->
                                                                                                                <div class="streak-front" style="position: absolute; width: 100%; height: 100%; backface-visibility: hidden; display: flex; align-items: center; justify-content: center;">
                                                                                                                    <svg class="icon-flame" id="streakFlameIcon" width="20" height="20" viewBox="0 0 24 24" 
                                                                                                                         fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                                                                                                                         style="transition: all 0.3s ease; color: #9ca3af;">
                                                                                                                        <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"></path>
                                                                                                                    </svg>
                                                                                                                </div>
                                                                                                                <!-- Mặt sau: Số chuỗi -->
                                                                                                                <div class="streak-back" style="position: absolute; width: 100%; height: 100%; backface-visibility: hidden; transform: rotateY(180deg); display: flex; align-items: center; justify-content: center;">
                                                                                                                    <span id="streakCountText" style="font-weight: 700; font-size: 0.95rem; color: #f97316;">0</span>
                                                                                                                </div>
                                                                                                            </div>
                                                                                                        </button>

                                                                                                        <!-- Toggle giao diện Sáng / Tối -->
                                                                                                        <div class="nav-bell-trigger dark-mode-toggle-btn" id="darkModeToggle"
                                                                                                                onclick="toggleDarkMode()"
                                                                                                                title="Chuyển chế độ sáng/tối"
                                                                                                                aria-label="Chuyển chế độ sáng/tối"
                                                                                                                style="position: relative; overflow: hidden; cursor: pointer; display: block; width: 40px; height: 40px; border-radius: 50%;">
                                                                                                            <!-- Icon MẶT TRỜI - hiển thị khi đang ở Light Mode -->
                                                                                                            <svg class="icon-sun" width="20" height="20" viewBox="0 0 24 24"
                                                                                                                 fill="none" stroke="currentColor" stroke-width="2.2"
                                                                                                                 style="position: absolute; top: 10px; left: 10px; transition: transform 0.5s ease, opacity 0.5s ease; opacity: 1; transform: rotate(0deg);">
                                                                                                                <circle cx="12" cy="12" r="5"/>
                                                                                                                <line x1="12" y1="1" x2="12" y2="3"/>
                                                                                                                <line x1="12" y1="21" x2="12" y2="23"/>
                                                                                                                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                                                                                                                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                                                                                                                <line x1="1" y1="12" x2="3" y2="12"/>
                                                                                                                <line x1="21" y1="12" x2="23" y2="12"/>
                                                                                                                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                                                                                                                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                                                                                                            </svg>
                                                                                                            <!-- Icon MẶT TRĂNG - hiển thị khi đang ở Dark Mode -->
                                                                                                            <svg class="icon-moon" width="20" height="20" viewBox="0 0 24 24"
                                                                                                                 fill="none" stroke="currentColor" stroke-width="2.2"
                                                                                                                 style="position: absolute; top: 10px; left: 10px; transition: transform 0.5s ease, opacity 0.5s ease; opacity: 0; transform: rotate(90deg);">
                                                                                                                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                                                                                                            </svg>
                                                                                                        </div>

                                                                                                        <!-- Notification dropdown fragment -->
                                                                                                        <%@ include
                                                                                                            file="/WEB-INF/fragments/notification-bell.jspf"
                                                                                                            %>

                                                                                                            <!-- Nút Đăng xuất -->
                                                                                                            <a href="${pageContext.request.contextPath}/logout"
                                                                                                                class="nav-bell-trigger"
                                                                                                                title="Đăng xuất"
                                                                                                                style="text-decoration: none;">
                                                                                                                <svg width="20"
                                                                                                                    height="20"
                                                                                                                    viewBox="0 0 24 24"
                                                                                                                    fill="none"
                                                                                                                    stroke="currentColor"
                                                                                                                    stroke-width="2.2">
                                                                                                                    <path
                                                                                                                        d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                                                                                                                    <polyline
                                                                                                                        points="16 17 21 12 16 7" />
                                                                                                                    <line
                                                                                                                        x1="21"
                                                                                                                        y1="12"
                                                                                                                        x2="9"
                                                                                                                        y2="12" />
                                                                                                                </svg>
                                                                                                            </a>

                                                                                                            <!-- User info card -->
                                                                                                            <div class="top-bar-user-card"
                                                                                                                onclick="switchTab('tab-profile')">
                                                                                                                <% if
                                                                                                                    (user
                                                                                                                    !=null
                                                                                                                    &&
                                                                                                                    user.getAvatarUrl()
                                                                                                                    !=null
                                                                                                                    &&
                                                                                                                    !user.getAvatarUrl().isEmpty())
                                                                                                                    { %>
                                                                                                                    <img src="<%= user.getAvatarUrl() %>"
                                                                                                                        class="top-bar-avatar"
                                                                                                                        alt="Avatar">
                                                                                                                    <% } else
                                                                                                                        {
                                                                                                                        %>
                                                                                                                        <div
                                                                                                                            class="top-bar-avatar-placeholder">
                                                                                                                            <%= initials
                                                                                                                                %>
                                                                                                                        </div>
                                                                                                                        <% }
                                                                                                                            %>
                                                                                                                            <div
                                                                                                                                class="top-bar-user-info">
                                                                                                                                <span
                                                                                                                                    class="top-bar-user-name">
                                                                                                                                    <%= user
                                                                                                                                        !=null
                                                                                                                                        ?
                                                                                                                                        user.getDisplayName()
                                                                                                                                        : "Học viên HIPZI"
                                                                                                                                        %>
                                                                                                                                </span>
                                                                                                                                <span
                                                                                                                                    class="top-bar-user-email">
                                                                                                                                    <%= user
                                                                                                                                        !=null
                                                                                                                                        ?
                                                                                                                                        user.getEmail()
                                                                                                                                        : "info@hipzi.vn"
                                                                                                                                        %>
                                                                                                                                </span>
                                                                                                                            </div>
                                                                                                            </div>
                                                                                                    </div>
                                                                                                </div>

                                                                                                <!-- CHỨA WORKSPACE TAB PANES -->
                                                                                                <main
                                                                                                    class="dashboard-content-wrapper">

                                                                                                    <!-- Banner dải màu trang trí phía trên cùng (Top Accent Strip) -->


                                                                                                    <!-- Thông báo nhắc nhở Onboarding (Nếu đăng ký qua Google mà chưa chọn role) -->
                                                                                                    <% if (user !=null
                                                                                                        &&
                                                                                                        !user.isOnboardingCompleted())
                                                                                                        { %>
                                                                                                        <div class="onboarding-banner"
                                                                                                            style="margin-top: -0.5rem;">
                                                                                                            <svg width="22"
                                                                                                                height="22"
                                                                                                                viewBox="0 0 24 24"
                                                                                                                fill="none"
                                                                                                                stroke="#92400e"
                                                                                                                stroke-width="2">
                                                                                                                <circle
                                                                                                                    cx="12"
                                                                                                                    cy="12"
                                                                                                                    r="10" />
                                                                                                                <line
                                                                                                                    x1="12"
                                                                                                                    y1="8"
                                                                                                                    x2="12"
                                                                                                                    y2="12" />
                                                                                                                <line
                                                                                                                    x1="12"
                                                                                                                    y1="16"
                                                                                                                    x2="12.01"
                                                                                                                    y2="16" />
                                                                                                            </svg>
                                                                                                            <p>Hồ sơ của
                                                                                                                bạn đang
                                                                                                                chờ hoàn
                                                                                                                tất
                                                                                                                thiết
                                                                                                                lập vai
                                                                                                                trò học
                                                                                                                viên sử
                                                                                                                dụng nền
                                                                                                                tảng.
                                                                                                            </p>
                                                                                                            <a
                                                                                                                href="${pageContext.request.contextPath}/onboarding">Hoàn
                                                                                                                tất
                                                                                                                ngay</a>
                                                                                                        </div>
                                                                                                        <% } %>

                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- TAB 1: HỒ SƠ CÁ NHÂN TỔNG QUAN             -->
                                                                                                            <!-- ========================================== -->
                                                                                                            <section
                                                                                                                id="tab-dashboard"
                                                                                                                class="tab-pane <%= "tab-dashboard".equals(initialTab) ? "active-pane" : "" %>">
                                                                                                                <div
                                                                                                                    class="tab-pane-header">
                                                                                                                    <div
                                                                                                                        class="tab-pane-header-left">
                                                                                                                        <h1>Tổng
                                                                                                                            quan
                                                                                                                            học
                                                                                                                            tập
                                                                                                                        </h1>
                                                                                                                        <p>Theo
                                                                                                                            dõi
                                                                                                                            nhanh
                                                                                                                            tiến
                                                                                                                            độ
                                                                                                                            học
                                                                                                                            tập,
                                                                                                                            khóa
                                                                                                                            học
                                                                                                                            và
                                                                                                                            lịch
                                                                                                                            học
                                                                                                                            của
                                                                                                                            bạn
                                                                                                                            trên
                                                                                                                            HIPZI.
                                                                                                                        </p>
                                                                                                                    </div>
                                                                                                                    <div
                                                                                                                        class="tab-pane-header-right">
                                                                                                                        <div
                                                                                                                            class="date-badge">
                                                                                                                            <svg width="15"
                                                                                                                                height="15"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor"
                                                                                                                                stroke-width="2">
                                                                                                                                <rect
                                                                                                                                    x="3"
                                                                                                                                    y="4"
                                                                                                                                    width="18"
                                                                                                                                    height="18"
                                                                                                                                    rx="2"
                                                                                                                                    ry="2" />
                                                                                                                                <line
                                                                                                                                    x1="16"
                                                                                                                                    y1="2"
                                                                                                                                    x2="16"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="8"
                                                                                                                                    y1="2"
                                                                                                                                    x2="8"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="3"
                                                                                                                                    y1="10"
                                                                                                                                    x2="21"
                                                                                                                                    y2="10" />
                                                                                                                            </svg>
                                                                                                                            <span>
                                                                                                                                <%= currentDateDisplay
                                                                                                                                    %>
                                                                                                                            </span>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>

                                                                                                                <!-- METRICS ROW (Donezo style) -->
                                                                                                                <div
                                                                                                                    class="metrics-row">
                                                                                                                    <!-- Metric 1: Active classrooms -->
                                                                                                                    <div class="metric-card primary"
                                                                                                                        onclick="switchTab('tab-my-classes')">
                                                                                                                        <div
                                                                                                                            class="metric-card-top">
                                                                                                                            <span
                                                                                                                                class="metric-card-title">Lớp
                                                                                                                                đang
                                                                                                                                học</span>
                                                                                                                            <div
                                                                                                                                class="metric-arrow-btn">
                                                                                                                                <svg width="16"
                                                                                                                                    height="16"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <line
                                                                                                                                        x1="7"
                                                                                                                                        y1="17"
                                                                                                                                        x2="17"
                                                                                                                                        y2="7" />
                                                                                                                                    <polyline
                                                                                                                                        points="7 7 17 7 17 17" />
                                                                                                                                </svg>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <div>
                                                                                                                            <div
                                                                                                                                class="metric-card-value">
                                                                                                                                0
                                                                                                                            </div>
                                                                                                                            <span
                                                                                                                                class="metric-card-sub">Lớp
                                                                                                                                học</span>
                                                                                                                        </div>
                                                                                                                        <div class="metric-ghost-icon"
                                                                                                                            aria-hidden="true">
                                                                                                                            <svg viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor">
                                                                                                                                <path
                                                                                                                                    d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                                                                                                                <path
                                                                                                                                    d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
                                                                                                                            </svg>
                                                                                                                        </div>
                                                                                                                    </div>

                                                                                                                    <!-- Metric 2: Active courses -->
                                                                                                                    <div class="metric-card secondary"
                                                                                                                        onclick="switchTab('tab-my-courses')">
                                                                                                                        <div
                                                                                                                            class="metric-card-top">
                                                                                                                            <span
                                                                                                                                class="metric-card-title">Khóa
                                                                                                                                học
                                                                                                                                đã
                                                                                                                                mua</span>
                                                                                                                            <div
                                                                                                                                class="metric-arrow-btn">
                                                                                                                                <svg width="16"
                                                                                                                                    height="16"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <line
                                                                                                                                        x1="7"
                                                                                                                                        y1="17"
                                                                                                                                        x2="17"
                                                                                                                                        y2="7" />
                                                                                                                                    <polyline
                                                                                                                                        points="7 7 17 7 17 17" />
                                                                                                                                </svg>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <div>
                                                                                                                            <div
                                                                                                                                class="metric-card-value">
                                                                                                                                0
                                                                                                                            </div>
                                                                                                                            <span
                                                                                                                                class="metric-card-sub"
                                                                                                                                style="background:#f5f3ff; color:#7c3aed;">Khóa
                                                                                                                                học</span>
                                                                                                                        </div>
                                                                                                                        <div class="metric-ghost-icon"
                                                                                                                            aria-hidden="true"
                                                                                                                            style="color:#7c3aed; background:#f5f3ff;">
                                                                                                                            <svg viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor">
                                                                                                                                <path
                                                                                                                                    d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
                                                                                                                            </svg>
                                                                                                                        </div>
                                                                                                                    </div>

                                                                                                                    <!-- Metric 4: Teaching schedule placeholder -->
                                                                                                                    <div class="metric-card secondary"
                                                                                                                        onclick="openScheduleModal()"
                                                                                                                        style="cursor: pointer; border-top-color: #3b82f6;">
                                                                                                                        <div
                                                                                                                            class="metric-card-top">
                                                                                                                            <span
                                                                                                                                class="metric-card-title">Xem
                                                                                                                                lịch
                                                                                                                                học</span>
                                                                                                                            <div
                                                                                                                                class="metric-arrow-btn">
                                                                                                                                <svg width="16"
                                                                                                                                    height="16"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <line
                                                                                                                                        x1="7"
                                                                                                                                        y1="17"
                                                                                                                                        x2="17"
                                                                                                                                        y2="7" />
                                                                                                                                    <polyline
                                                                                                                                        points="7 7 17 7 17 17" />
                                                                                                                                </svg>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <div>
                                                                                                                            <div class="metric-card-value"
                                                                                                                                style="font-size: 1.45rem; margin-top: 1.25rem;">
                                                                                                                                Xem
                                                                                                                                lịch
                                                                                                                                trình
                                                                                                                            </div>
                                                                                                                            <span
                                                                                                                                class="metric-card-sub"
                                                                                                                                style="background:#eff6ff; color:#2563eb;">Tuần
                                                                                                                                này</span>
                                                                                                                        </div>
                                                                                                                        <div class="metric-ghost-icon"
                                                                                                                            aria-hidden="true"
                                                                                                                            style="color:#2563eb; background:#eff6ff;">
                                                                                                                            <svg viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor">
                                                                                                                                <rect
                                                                                                                                    x="3"
                                                                                                                                    y="4"
                                                                                                                                    width="18"
                                                                                                                                    height="18"
                                                                                                                                    rx="2" />
                                                                                                                                <line
                                                                                                                                    x1="16"
                                                                                                                                    y1="2"
                                                                                                                                    x2="16"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="8"
                                                                                                                                    y1="2"
                                                                                                                                    x2="8"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="3"
                                                                                                                                    y1="10"
                                                                                                                                    x2="21"
                                                                                                                                    y2="10" />
                                                                                                                                <path
                                                                                                                                    d="M8 14h4" />
                                                                                                                                <path
                                                                                                                                    d="M8 18h8" />
                                                                                                                            </svg>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>

                                                                                                                <div
                                                                                                                    class="overview-analytics-grid">
                                                                                                                    <div
                                                                                                                        class="overview-chart-card">
                                                                                                                        <div
                                                                                                                            class="overview-chart-head">
                                                                                                                            <div
                                                                                                                                class="overview-chart-title-block">
                                                                                                                                <h2
                                                                                                                                    class="overview-chart-title">
                                                                                                                                    Tiến
                                                                                                                                    độ
                                                                                                                                    học
                                                                                                                                    tập
                                                                                                                                </h2>
                                                                                                                                <div class="overview-chart-summary"
                                                                                                                                    aria-label="T&#7893;ng quan th&#7901;i l&#432;&#7907;ng gi&#7843;ng d&#7841;y">
                                                                                                                                    <span
                                                                                                                                        class="overview-summary-pill taught">
                                                                                                                                        <strong
                                                                                                                                            id="overviewTotalTaught"><%= studyProgressStats.getWeeklyTotalHoursLabel() %></strong>
                                                                                                                                        <span>giờ
                                                                                                                                            đã
                                                                                                                                            học</span>
                                                                                                                                    </span>
                                                                                                                                    <span
                                                                                                                                        class="overview-summary-pill trend">
                                                                                                                                        <svg width="12"
                                                                                                                                            height="12"
                                                                                                                                            viewBox="0 0 24 24"
                                                                                                                                            fill="none"
                                                                                                                                            stroke="currentColor"
                                                                                                                                            stroke-width="3"
                                                                                                                                            stroke-linecap="round"
                                                                                                                                            stroke-linejoin="round"
                                                                                                                                            style="margin-right: -0.2rem;">
                                                                                                                                            <polyline
                                                                                                                                                points="23 6 13.5 15.5 8.5 10.5 1 18">
                                                                                                                                            </polyline>
                                                                                                                                            <polyline
                                                                                                                                                points="17 6 23 6 23 12">
                                                                                                                                            </polyline>
                                                                                                                                        </svg>
                                                                                                                                        <strong id="overviewTrendPercent"><%= studyProgressStats.getTrendPercentLabel() %></strong>
                                                                                                                                        <span>so
                                                                                                                                            với
                                                                                                                                            tuần
                                                                                                                                            trước</span>
                                                                                                                                    </span>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                            <div class="overview-period-switch"
                                                                                                                                id="overviewPeriodSwitch"
                                                                                                                                data-active="week"
                                                                                                                                aria-label="Chọn khoảng thời gian biểu đồ">
                                                                                                                                <button
                                                                                                                                    type="button"
                                                                                                                                    class="overview-period-btn is-active"
                                                                                                                                    data-period="week"
                                                                                                                                    aria-pressed="true">Tuần</button>
                                                                                                                                <button
                                                                                                                                    type="button"
                                                                                                                                    class="overview-period-btn"
                                                                                                                                    data-period="month"
                                                                                                                                    aria-pressed="false">Tháng</button>
                                                                                                                            </div>
                                                                                                                        </div>

                                                                                                                        <div class="overview-line-wrap"
                                                                                                                            id="overviewLineWrap">
                                                                                                                            <svg class="overview-line-chart"
                                                                                                                                viewBox="0 0 640 214"
                                                                                                                                role="img"
                                                                                                                                aria-label="Biểu đồ tiến độ học tập">
                                                                                                                                <defs>
                                                                                                                                    <linearGradient
                                                                                                                                        id="overviewTaughtFill"
                                                                                                                                        x1="0"
                                                                                                                                        y1="0"
                                                                                                                                        x2="0"
                                                                                                                                        y2="1">
                                                                                                                                        <stop
                                                                                                                                            offset="0%"
                                                                                                                                            stop-color="#059669"
                                                                                                                                            stop-opacity="0.18" />
                                                                                                                                        <stop
                                                                                                                                            offset="100%"
                                                                                                                                            stop-color="#059669"
                                                                                                                                            stop-opacity="0" />
                                                                                                                                    </linearGradient>
                                                                                                                                </defs>
                                                                                                                                <line
                                                                                                                                    x1="52"
                                                                                                                                    y1="24"
                                                                                                                                    x2="610"
                                                                                                                                    y2="24"
                                                                                                                                    stroke="#e2e8f0"
                                                                                                                                    stroke-width="1" />
                                                                                                                                <line
                                                                                                                                    x1="52"
                                                                                                                                    y1="70"
                                                                                                                                    x2="610"
                                                                                                                                    y2="70"
                                                                                                                                    stroke="#e2e8f0"
                                                                                                                                    stroke-width="1" />
                                                                                                                                <line
                                                                                                                                    x1="52"
                                                                                                                                    y1="116"
                                                                                                                                    x2="610"
                                                                                                                                    y2="116"
                                                                                                                                    stroke="#e2e8f0"
                                                                                                                                    stroke-width="1" />
                                                                                                                                <line
                                                                                                                                    x1="52"
                                                                                                                                    y1="162"
                                                                                                                                    x2="610"
                                                                                                                                    y2="162"
                                                                                                                                    stroke="#e2e8f0"
                                                                                                                                    stroke-width="1" />

                                                                                                                                <text
                                                                                                                                    x="4"
                                                                                                                                    y="28">6
                                                                                                                                    giờ</text>
                                                                                                                                <text
                                                                                                                                    x="4"
                                                                                                                                    y="74">4
                                                                                                                                    giờ</text>
                                                                                                                                <text
                                                                                                                                    x="4"
                                                                                                                                    y="120">2
                                                                                                                                    giờ</text>
                                                                                                                                <text
                                                                                                                                    x="4"
                                                                                                                                    y="166">0
                                                                                                                                    giờ</text>

                                                                                                                                <path
                                                                                                                                    id="overviewTaughtArea"
                                                                                                                                    d="M64 144 C108 128, 118 84, 156 94 C198 106, 206 58, 250 64 C294 70, 306 118, 344 112 C386 104, 396 42, 436 48 C478 54, 488 92, 526 86 C566 80, 572 52, 610 62 L610 162 L64 162 Z"
                                                                                                                                    fill="url(#overviewTaughtFill)" />
                                                                                                                                <path
                                                                                                                                    id="overviewTaughtLine"
                                                                                                                                    d="M64 144 C108 128, 118 84, 156 94 C198 106, 206 58, 250 64 C294 70, 306 118, 344 112 C386 104, 396 42, 436 48 C478 54, 488 92, 526 86 C566 80, 572 52, 610 62"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="#059669"
                                                                                                                                    stroke-width="3.2"
                                                                                                                                    stroke-linecap="round" />

                                                                                                                                <line
                                                                                                                                    id="overviewGuideLine"
                                                                                                                                    x1="250"
                                                                                                                                    y1="34"
                                                                                                                                    x2="250"
                                                                                                                                    y2="174"
                                                                                                                                    stroke="#cbd5e1"
                                                                                                                                    stroke-width="1.5"
                                                                                                                                    stroke-dasharray="4 6" />
                                                                                                                                <circle
                                                                                                                                    id="overviewTaughtDot"
                                                                                                                                    cx="250"
                                                                                                                                    cy="64"
                                                                                                                                    r="5"
                                                                                                                                    fill="#059669"
                                                                                                                                    stroke="#ffffff"
                                                                                                                                    stroke-width="3" />

                                                                                                                                <text
                                                                                                                                    id="overviewTick1"
                                                                                                                                    x="58"
                                                                                                                                    y="202">01/05</text>
                                                                                                                                <text
                                                                                                                                    id="overviewTick2"
                                                                                                                                    x="150"
                                                                                                                                    y="202">02/05</text>
                                                                                                                                <text
                                                                                                                                    id="overviewTick3"
                                                                                                                                    x="240"
                                                                                                                                    y="202">03/05</text>
                                                                                                                                <text
                                                                                                                                    id="overviewTick4"
                                                                                                                                    x="332"
                                                                                                                                    y="202">04/05</text>
                                                                                                                                <text
                                                                                                                                    id="overviewTick5"
                                                                                                                                    x="424"
                                                                                                                                    y="202">05/05</text>
                                                                                                                                <text
                                                                                                                                    id="overviewTick6"
                                                                                                                                    x="516"
                                                                                                                                    y="202">06/05</text>
                                                                                                                                <text
                                                                                                                                    id="overviewTick7"
                                                                                                                                    x="586"
                                                                                                                                    y="202">07/05</text>
                                                                                                                            </svg>

                                                                                                                            <div class="overview-line-tooltip"
                                                                                                                                id="overviewLineTooltip">
                                                                                                                                <strong
                                                                                                                                    id="overviewTooltipDate">03/05/2026</strong>
                                                                                                                                <div
                                                                                                                                    class="overview-tooltip-row">
                                                                                                                                    <span
                                                                                                                                        class="overview-tooltip-label"><span
                                                                                                                                            class="overview-tooltip-dot"
                                                                                                                                            style="background:#059669;"></span>Đã
                                                                                                                                        học</span>
                                                                                                                                    <span
                                                                                                                                        id="overviewTooltipTaught">4
                                                                                                                                        giờ</span>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                        </div>

                                                                                                                        <div
                                                                                                                            class="overview-chart-legend">
                                                                                                                            <span
                                                                                                                                class="overview-legend-item"><span
                                                                                                                                    class="overview-legend-dot"
                                                                                                                                    style="background:#059669;"></span>Giờ
                                                                                                                                đã
                                                                                                                                học</span>
                                                                                                                        </div>

                                                                                                            </section>




                                                                                                            <!-- TAB: THANH TOÁN HỌC PHÍ (Gộp Lịch sử giao dịch) -->
                                                                                                            <section id="tab-wallet-history" class="tab-pane <%= "tab-wallet-history".equals(initialTab) ? "active-pane" : "" %>">
    <%
        List<TuitionInvoice> tuitionInvoices = (List<TuitionInvoice>) request.getAttribute("tuitionInvoices");
        if (tuitionInvoices == null) tuitionInvoices = new java.util.ArrayList<TuitionInvoice>();
        int pendingTuitionCount = 0;
        int paidTuitionCount = 0;
        for (TuitionInvoice item : tuitionInvoices) {
            if (item.isPaid()) paidTuitionCount++; else if ("pending".equals(item.getStatus())) pendingTuitionCount++;
        }
        java.time.format.DateTimeFormatter tuitionDateFormat = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        SimpleDateFormat tuitionPaidFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    %>
    <div class="tab-pane-header">
        <div class="tab-pane-header-left">
            <h1>Thanh toán học phí</h1>
            <p>Hóa đơn lớp học sẽ xuất hiện trước thời hạn nộp 5 ngày và được SePay đối soát tự động.</p>
        </div>
    </div>

    <div class="premium-card" style="margin:0 0 1.5rem; padding:1.5rem;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;gap:1rem;">
            <h3 style="font-size:1.1rem;font-weight:800;color:var(--text-main);margin:0;">Hóa đơn chờ thanh toán</h3>
            <span style="background:#fff7ed;color:#c2410c;padding:.3rem .7rem;border-radius:999px;font-size:.8rem;font-weight:800;"><%= pendingTuitionCount %> khoản</span>
        </div>
        <% if (pendingTuitionCount == 0) { %>
            <div style="padding:2rem;text-align:center;border:1px dashed var(--border-dark);border-radius:12px;color:var(--text-muted);font-weight:700;">Hiện chưa có học phí đến kỳ thanh toán.</div>
        <% } else { %>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(290px,1fr));gap:1rem;">
                <% for (TuitionInvoice item : tuitionInvoices) { if (item.isPaid() || !"pending".equals(item.getStatus())) continue; %>
                <article style="border:1px solid <%= item.isOverdue() ? "#fecaca" : "var(--border-dark)" %>;border-radius:14px;padding:1.15rem;background:#fff;display:flex;flex-direction:column;gap:.8rem;">
                    <div style="display:flex;justify-content:space-between;gap:.75rem;align-items:flex-start;">
                        <div><div style="font-weight:850;color:var(--text-main);line-height:1.4;"><%= h(item.getClassroomTitle()) %></div><div style="font-size:.84rem;color:var(--text-muted);margin-top:.3rem;"><%= h(item.getTeacherName()) %></div></div>
                        <span style="white-space:nowrap;background:<%= item.isOverdue() ? "#fef2f2" : "#ecfdf5" %>;color:<%= item.isOverdue() ? "#dc2626" : "#047857" %>;padding:.25rem .55rem;border-radius:999px;font-size:.72rem;font-weight:800;"><%= item.isOverdue() ? "Quá hạn" : (item.getDaysUntilDue() == 0 ? "Hạn hôm nay" : "Còn " + item.getDaysUntilDue() + " ngày") %></span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:flex-end;gap:1rem;border-top:1px solid #f1f5f9;padding-top:.8rem;">
                        <div><div style="font-size:.78rem;color:var(--text-muted);font-weight:700;">Hạn <%= item.getDueDate().format(tuitionDateFormat) %></div><div style="font-size:1.2rem;color:#059669;font-weight:900;margin-top:.25rem;"><%= h(item.getAmountLabel()) %></div></div>
                        <a href="${pageContext.request.contextPath}/tuition-checkout?id=<%= h(item.getId()) %>" style="padding:.6rem .9rem;border-radius:9px;background:#059669;color:#fff;text-decoration:none;font-weight:850;font-size:.85rem;">Thanh toán QR</a>
                    </div>
                </article>
                <% } %>
            </div>
        <% } %>
    </div>

    <div class="premium-card" style="padding:0;overflow:hidden;">
        <div class="premium-card-header" style="padding:1.25rem 1.5rem;border-bottom:1px solid var(--border-dark);display:flex;justify-content:space-between;">
            <h3 class="premium-card-title" style="margin:0;font-size:1.1rem;font-weight:800;">Lịch sử học phí</h3>
            <span style="color:#64748b;font-size:.82rem;font-weight:750;"><%= paidTuitionCount %> giao dịch</span>
        </div>
        <% if (paidTuitionCount == 0) { %>
            <div style="padding:2rem;text-align:center;color:var(--text-muted);font-weight:700;">Chưa có giao dịch học phí đã hoàn tất.</div>
        <% } else { %>
        <div style="overflow-x:auto;"><table style="width:100%;border-collapse:collapse;text-align:left;font-size:.9rem;">
            <thead><tr style="background:#f8fafc;border-bottom:1px solid var(--border-dark);"><th style="padding:1rem 1.25rem;">Mã hóa đơn</th><th style="padding:1rem 1.25rem;">Ngày thanh toán</th><th style="padding:1rem 1.25rem;">Lớp học</th><th style="padding:1rem 1.25rem;text-align:right;">Số tiền</th><th style="padding:1rem 1.25rem;text-align:center;">Trạng thái</th></tr></thead>
            <tbody><% for (TuitionInvoice item : tuitionInvoices) { if (!item.isPaid()) continue; %>
                <tr style="border-bottom:1px solid var(--border-light);"><td style="padding:1rem 1.25rem;font-weight:800;"><%= h(item.getInvoiceCode()) %></td><td style="padding:1rem 1.25rem;color:var(--text-muted);"><%= item.getPaidAt() != null ? tuitionPaidFormat.format(item.getPaidAt()) : "" %></td><td style="padding:1rem 1.25rem;"><%= h(item.getClassroomTitle()) %></td><td style="padding:1rem 1.25rem;text-align:right;font-weight:900;color:#ef4444;">-<%= h(item.getAmountLabel()) %></td><td style="padding:1rem 1.25rem;text-align:center;"><span style="background:#ecfdf5;color:#047857;padding:.3rem .7rem;border-radius:999px;font-size:.75rem;font-weight:800;">Thành công</span></td></tr>
            <% } %></tbody>
        </table></div>
        <% } %>
    </div>
</section>

                                                                                                            </section>

                                                                                                            <!-- TAB: LỚP HỌC CỦA TÔI -->
                                                                                                            <section id="tab-my-classes" class="tab-pane <%= "tab-my-classes".equals(initialTab) ? "active-pane" : "" %>">
                                                                                                                <div class="tab-pane-header">
                                                                                                                    <div class="tab-pane-header-left">
                                                                                                                        <h1>Lớp học của tôi</h1>
                                                                                                                        <p>Theo dõi và quản lý các lớp học bạn đang tham gia.</p>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                                <div class="premium-card" style="margin-bottom: 1.5rem;">
                                                                                                                    <div class="premium-card-header">
                                                                                                                        <h3 class="premium-card-title">
                                                                                                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                                                                                                                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
                                                                                                                                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                                                                                                                            </svg>
                                                                                                                            Danh sách lớp học đang tham gia
                                                                                                                        </h3>
                                                                                                                    </div>
                                                                                                                    <%
                                                                                                                    List<Classroom> myClasses = (List<Classroom>) request.getAttribute("studentClasses");
                                                                                                                    if (myClasses == null || myClasses.isEmpty()) {
                                                                                                                    %>
                                                                                                                    <div class="dashboard-list" style="min-height: 200px; display: flex; align-items: center; justify-content: center; color: var(--text-muted); font-weight: 600;">
                                                                                                                        Hiện chưa có lớp học nào
                                                                                                                    </div>
                                                                                                                    <% } else { %>
                                                                                                                    <div class="courses-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem; padding: 1.5rem;">
                                                                                                                        <% for (Classroom cls : myClasses) { 
                                                                                                                            String thumbStyle = "background:linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%); display:flex; align-items:center; justify-content:center;";
                                                                                                                        %>
                                                                                                                        <article class="course-card" style="border: 1px solid var(--border-light); border-radius: 1rem; overflow: hidden; display: flex; flex-direction: column; background: #fff; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);">
                                                                                                                            <div class="card-thumb" style="position: relative; padding-top: 56.25%; background: var(--bg-soft);">
                                                                                                                                <div class="card-thumb-bg" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; <%= thumbStyle %>">
                                                                                                                                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.55)" stroke-width="1.25"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                            <div class="card-body" style="padding: 1.25rem; flex: 1; display: flex; flex-direction: column;">
                                                                                                                                <div class="card-subject" style="font-size: 0.75rem; font-weight: 700; color: var(--primary); text-transform: uppercase; margin-bottom: 0.5rem;"><%= h(cls.getSubject()) %></div>
                                                                                                                                <h3 class="card-title" style="font-size: 1.05rem; font-weight: 800; color: var(--text-main); margin: 0 0 0.5rem 0; line-height: 1.4;"><%= h(cls.getTitle()) %></h3>
                                                                                                                                <div class="card-teacher" style="font-size: 0.85rem; color: var(--text-muted); font-weight: 600; margin-bottom: 1rem;"><%= h(cls.getTeacherName()) %></div>
                                                                                                                                <div style="margin-top: auto;">
                                                                                                                                    <a href="${pageContext.request.contextPath}/class-detail?id=<%= h(cls.getId()) %>" class="btn btn-primary" style="display: block; text-align: center; width: 100%; padding: 0.6rem; border-radius: 0.5rem; text-decoration: none; font-size: 0.9rem; font-weight: 700; background: var(--primary); color: #fff;">Chi tiết</a>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                        </article>
                                                                                                                        <% } %>
                                                                                                                    </div>
                                                                                                                    <% } %>
                                                                                                                </div>
                                                                                                            </section>

                                                                                                            <!-- TAB: KHÓA HỌC CỦA TÔI -->
                                                                                                            <section id="tab-my-courses" class="tab-pane <%= "tab-my-courses".equals(initialTab) ? "active-pane" : "" %>">
                                                                                                                <div class="tab-pane-header">
                                                                                                                    <div class="tab-pane-header-left">
                                                                                                                        <h1>Khóa học của tôi</h1>
                                                                                                                        <p>Quản lý các khóa học bạn đã mua hoặc đang theo học.</p>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                                <div class="premium-card" style="margin-bottom: 1.5rem;">
                                                                                                                    <div class="premium-card-header">
                                                                                                                        <h3 class="premium-card-title">
                                                                                                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                                                                                                                <polygon points="12 2 2 7 12 12 22 7 12 2"/>
                                                                                                                                <polyline points="2 17 12 22 22 17"/>
                                                                                                                                <polyline points="2 12 12 17 22 12"/>
                                                                                                                            </svg>
                                                                                                                            Danh sách khóa học đã mua
                                                                                                                        </h3>
                                                                                                                    </div>
                                                                                                                    <%
                                                                                                                    List<Course> myCourses = (List<Course>) request.getAttribute("studentCourses");
                                                                                                                    if (myCourses == null || myCourses.isEmpty()) {
                                                                                                                    %>
                                                                                                                    <div class="dashboard-list" style="min-height: 200px; display: flex; align-items: center; justify-content: center; color: var(--text-muted); font-weight: 600;">
                                                                                                                        Hiện chưa có khóa học nào
                                                                                                                    </div>
                                                                                                                    <% } else { %>
                                                                                                                    <div class="courses-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem; padding: 1.5rem;">
                                                                                                                        <% for (Course course : myCourses) { 
                                                                                                                            String thumbUrl = course.getThumbnailUrl();
                                                                                                                            String thumbStyle = (thumbUrl != null && !thumbUrl.trim().isEmpty())
                                                                                                                                    ? "background-image:url('" + h(thumbUrl) + "'); background-size:cover; background-position:center;"
                                                                                                                                    : "background:" + h(course.getThumbnailGradientOrDefault()) + "; display:flex; align-items:center; justify-content:center;";
                                                                                                                        %>
                                                                                                                        <article class="course-card" style="border: 1px solid var(--border-light); border-radius: 1rem; overflow: hidden; display: flex; flex-direction: column; background: #fff; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);">
                                                                                                                            <div class="card-thumb" style="position: relative; padding-top: 56.25%; background: var(--bg-soft);">
                                                                                                                                <div class="card-thumb-bg" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; <%= thumbStyle %>">
                                                                                                                                    <% if (thumbUrl == null || thumbUrl.trim().isEmpty()) { %>
                                                                                                                                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.55)" stroke-width="1.25"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                                                                                                                                    <% } %>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                            <div class="card-body" style="padding: 1.25rem; flex: 1; display: flex; flex-direction: column;">
                                                                                                                                <div class="card-subject" style="font-size: 0.75rem; font-weight: 700; color: var(--primary); text-transform: uppercase; margin-bottom: 0.5rem;"><%= h(course.getSubjectName()) %></div>
                                                                                                                                <h3 class="card-title" style="font-size: 1.05rem; font-weight: 800; color: var(--text-main); margin: 0 0 0.5rem 0; line-height: 1.4;"><%= h(course.getTitle()) %></h3>
                                                                                                                                <div class="card-teacher" style="font-size: 0.85rem; color: var(--text-muted); font-weight: 600; margin-bottom: 1rem;"><%= h(course.getTeacherName()) %></div>
                                                                                                                                <div style="margin-top: auto;">
                                                                                                                                    <a href="${pageContext.request.contextPath}/course-detail?id=<%= h(course.getId()) %>" class="btn btn-primary" style="display: block; text-align: center; width: 100%; padding: 0.6rem; border-radius: 0.5rem; text-decoration: none; font-size: 0.9rem; font-weight: 700; background: var(--primary); color: #fff;">Chi tiết</a>
                                                                                                                                </div>
                                                                                                                            </div>
                                                                                                                        </article>
                                                                                                                        <% } %>
                                                                                                                    </div>
                                                                                                                    <% } %>
                                                                                                                </div>
                                                                                                            </section>

                                                                                                            <section
                                                                                                                id="tab-profile"
                                                                                                                class="tab-pane <%= "tab-profile".equals(initialTab) ? "active-pane" : "" %>">
                                                                                                                <div
                                                                                                                    class="tab-pane-header">
                                                                                                                    <div
                                                                                                                        class="tab-pane-header-left">
                                                                                                                        <h1>Hồ
                                                                                                                            sơ
                                                                                                                            cá
                                                                                                                            nhân
                                                                                                                        </h1>
                                                                                                                        <p>Quản
                                                                                                                            lý
                                                                                                                            thông
                                                                                                                            tin
                                                                                                                            tài
                                                                                                                            khoản,
                                                                                                                            mật
                                                                                                                            khẩu
                                                                                                                            đăng
                                                                                                                            nhập
                                                                                                                            và
                                                                                                                            xác
                                                                                                                            thực
                                                                                                                            hai
                                                                                                                            lớp.
                                                                                                                        </p>
                                                                                                                    </div>
                                                                                                                    <div
                                                                                                                        class="tab-pane-header-right">
                                                                                                                        <div
                                                                                                                            class="date-badge">
                                                                                                                            <svg width="15"
                                                                                                                                height="15"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor"
                                                                                                                                stroke-width="2">
                                                                                                                                <rect
                                                                                                                                    x="3"
                                                                                                                                    y="4"
                                                                                                                                    width="18"
                                                                                                                                    height="18"
                                                                                                                                    rx="2"
                                                                                                                                    ry="2" />
                                                                                                                                <line
                                                                                                                                    x1="16"
                                                                                                                                    y1="2"
                                                                                                                                    x2="16"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="8"
                                                                                                                                    y1="2"
                                                                                                                                    x2="8"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="3"
                                                                                                                                    y1="10"
                                                                                                                                    x2="21"
                                                                                                                                    y2="10" />
                                                                                                                            </svg>
                                                                                                                            <span>
                                                                                                                                <%= currentDateDisplay
                                                                                                                                    %>
                                                                                                                            </span>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>

                                                                                                                <!-- CHI TIẾT TÀI KHOẢN -->
                                                                                                                <div class="premium-card"
                                                                                                                    style="margin-top: 0.5rem;">
                                                                                                                    <div
                                                                                                                        class="premium-card-header">
                                                                                                                        <span
                                                                                                                            class="premium-card-title">
                                                                                                                            <svg width="20"
                                                                                                                                height="20"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor"
                                                                                                                                stroke-width="2.5">
                                                                                                                                <path
                                                                                                                                    d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                                                                                                <circle
                                                                                                                                    cx="12"
                                                                                                                                    cy="7"
                                                                                                                                    r="4" />
                                                                                                                            </svg>
                                                                                                                            Chi
                                                                                                                            tiết
                                                                                                                            tài
                                                                                                                            khoản
                                                                                                                        </span>
                                                                                                                        <div
                                                                                                                            class="account-header-actions">
                                                                                                                            <button
                                                                                                                                type="button"
                                                                                                                                id="accountEditTrigger"
                                                                                                                                onclick="toggleAccountNameEdit(true)"
                                                                                                                                class="btn-premium profile-edit-btn"
                                                                                                                                style="padding: 0.4rem 0.85rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                                                                                                                                <span>Chỉnh
                                                                                                                                    sửa</span>
                                                                                                                                <svg width="12"
                                                                                                                                    height="12"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <path
                                                                                                                                        d="M12 20h9" />
                                                                                                                                    <path
                                                                                                                                        d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                                                                                </svg>
                                                                                                                            </button>
                                                                                                                            <div id="accountEditActions"
                                                                                                                                class="account-edit-actions"
                                                                                                                                style="display: none;">
                                                                                                                                <button
                                                                                                                                    type="button"
                                                                                                                                    class="btn-premium account-cancel-btn"
                                                                                                                                    onclick="toggleAccountNameEdit(false)"
                                                                                                                                    style="padding: 0.4rem 0.85rem; font-size: 0.8rem;">Hủy
                                                                                                                                    bỏ</button>
                                                                                                                                <button
                                                                                                                                    type="submit"
                                                                                                                                    form="accountNameInlineForm"
                                                                                                                                    class="btn-premium account-save-btn"
                                                                                                                                    style="padding: 0.4rem 0.85rem; font-size: 0.8rem;">Lưu</button>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                    </div>

                                                                                                                    <form
                                                                                                                        id="studentAvatarUploadForm"
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
                                                                                                                            id="studentAvatarFile"
                                                                                                                            name="avatarFile"
                                                                                                                            accept="image/*"
                                                                                                                            onchange="document.getElementById('studentAvatarUploadForm').submit();">
                                                                                                                    </form>

                                                                                                                    <div
                                                                                                                        class="account-summary-panel">
                                                                                                                        <div
                                                                                                                            class="account-summary-main">
                                                                                                                            <div
                                                                                                                                class="account-avatar-wrap">
                                                                                                                                <% if
                                                                                                                                    (user
                                                                                                                                    !=null
                                                                                                                                    &&
                                                                                                                                    user.getAvatarUrl()
                                                                                                                                    !=null
                                                                                                                                    &&
                                                                                                                                    !user.getAvatarUrl().isEmpty())
                                                                                                                                    {
                                                                                                                                    %>
                                                                                                                                    <img src="<%= user.getAvatarUrl() %>"
                                                                                                                                        class="account-avatar-img"
                                                                                                                                        alt="Avatar">
                                                                                                                                    <% } else
                                                                                                                                        {
                                                                                                                                        %>
                                                                                                                                        <div
                                                                                                                                            class="account-avatar-placeholder">
                                                                                                                                            <%= initials
                                                                                                                                                %>
                                                                                                                                        </div>
                                                                                                                                        <% }
                                                                                                                                            %>
                                                                                                                                            <button
                                                                                                                                                type="button"
                                                                                                                                                class="avatar-camera-btn"
                                                                                                                                                title="Cập nhật ảnh đại diện"
                                                                                                                                                onclick="document.getElementById('studentAvatarFile').click();">
                                                                                                                                                <svg width="15"
                                                                                                                                                    height="15"
                                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                                    fill="none"
                                                                                                                                                    stroke="currentColor"
                                                                                                                                                    stroke-width="2.4">
                                                                                                                                                    <path
                                                                                                                                                        d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
                                                                                                                                                    <circle
                                                                                                                                                        cx="12"
                                                                                                                                                        cy="13"
                                                                                                                                                        r="4" />
                                                                                                                                                </svg>
                                                                                                                                            </button>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="account-identity">
                                                                                                                                <h3
                                                                                                                                    class="account-name">
                                                                                                                                    <%= user
                                                                                                                                        !=null
                                                                                                                                        ?
                                                                                                                                        user.getDisplayName()
                                                                                                                                        : "Học viên HIPZI"
                                                                                                                                        %>
                                                                                                                                </h3>
                                                                                                                                <form
                                                                                                                                    id="accountNameInlineForm"
                                                                                                                                    class="account-name-edit-form"
                                                                                                                                    action="${pageContext.request.contextPath}/profile"
                                                                                                                                    method="POST"
                                                                                                                                    style="display: none;">
                                                                                                                                    <input
                                                                                                                                        type="hidden"
                                                                                                                                        name="action"
                                                                                                                                        value="updateName">
                                                                                                                                    <input
                                                                                                                                        id="accountDisplayNameInput"
                                                                                                                                        class="account-name-input"
                                                                                                                                        type="text"
                                                                                                                                        name="displayName"
                                                                                                                                        required
                                                                                                                                        value="<%= user != null ? user.getDisplayName() : "" %>"
                                                                                                                                        placeholder="Nhập họ và tên của bạn...">
                                                                                                                                </form>
                                                                                                                                <span
                                                                                                                                    class="account-email"
                                                                                                                                    title="<%= user != null ? user.getEmail() : "" %>">
                                                                                                                                    <%= user
                                                                                                                                        !=null
                                                                                                                                        ?
                                                                                                                                        user.getEmail()
                                                                                                                                        : "info@hipzi.vn"
                                                                                                                                        %>
                                                                                                                                </span>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            class="account-side-meta">
                                                                                                                            <div
                                                                                                                                class="account-meta-pill">
                                                                                                                                <span
                                                                                                                                    class="account-meta-label">Ngày
                                                                                                                                    tham
                                                                                                                                    gia</span>
                                                                                                                                <span
                                                                                                                                    class="account-meta-value">
                                                                                                                                    <%= joinDate
                                                                                                                                        %>
                                                                                                                                </span>
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="account-meta-pill">
                                                                                                                                <span
                                                                                                                                    class="account-meta-label">Vai
                                                                                                                                    trò</span>
                                                                                                                                <span
                                                                                                                                    class="account-meta-value">
                                                                                                                                    <span
                                                                                                                                        class="role-tag student">Học
                                                                                                                                        viên</span>
                                                                                                                                </span>
                                                                                                                            </div>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>

                                                                                                                <!-- LƯỚI HAI KHUNG CON BÊN DƯỚI -->
                                                                                                                <div
                                                                                                                    style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-top: 0.5rem;">

                                                                                                                    <!-- KHUNG TRÁI: MẬT KHẨU ĐĂNG NHẬP -->
                                                                                                                    <div
                                                                                                                        class="premium-card">
                                                                                                                        <div
                                                                                                                            style="display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem;">
                                                                                                                            <div>
                                                                                                                                <span
                                                                                                                                    style="font-weight: 800; font-size: 0.9rem; color: var(--text-main); text-transform: uppercase; letter-spacing: 0.5px;">Mật
                                                                                                                                    khẩu
                                                                                                                                    đăng
                                                                                                                                    nhập</span>
                                                                                                                                <p
                                                                                                                                    style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; line-height: 1.5; margin: 0.35rem 0 0 0;">
                                                                                                                                    Cập
                                                                                                                                    nhật
                                                                                                                                    mật
                                                                                                                                    khẩu
                                                                                                                                    định
                                                                                                                                    kỳ
                                                                                                                                    để
                                                                                                                                    bảo
                                                                                                                                    mật
                                                                                                                                    tốt
                                                                                                                                    hơn.
                                                                                                                                </p>
                                                                                                                            </div>
                                                                                                                            <svg width="20"
                                                                                                                                height="20"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="#059669"
                                                                                                                                stroke-width="2">
                                                                                                                                <path
                                                                                                                                    d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                                                                            </svg>
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            style="display: flex; justify-content: space-between; align-items: center; gap: 1rem; margin-top: 1.1rem; flex-wrap: wrap;">
                                                                                                                            <div
                                                                                                                                style="display: flex; align-items: center; gap: 0.4rem; color: #10b981; font-weight: 700; font-size: 0.85rem;">
                                                                                                                                <svg width="16"
                                                                                                                                    height="16"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <path
                                                                                                                                        d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                                                                                </svg>
                                                                                                                                <span>Mật
                                                                                                                                    khẩu
                                                                                                                                    mạnh</span>
                                                                                                                            </div>
                                                                                                                            <button
                                                                                                                                type="button"
                                                                                                                                onclick="document.getElementById('pwd-modal-overlay').style.display='flex';"
                                                                                                                                class="btn-premium primary"
                                                                                                                                style="background: #059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">
                                                                                                                                <span>Đổi
                                                                                                                                    mật
                                                                                                                                    khẩu</span>
                                                                                                                                <svg width="14"
                                                                                                                                    height="14"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <path
                                                                                                                                        d="M12 20h9" />
                                                                                                                                    <path
                                                                                                                                        d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" />
                                                                                                                                </svg>
                                                                                                                            </button>
                                                                                                                        </div>
                                                                                                                    </div>

                                                                                                                    <!-- KHUNG PHẢI: BẢO MẬT 2 LỚP (OTP) -->
                                                                                                                    <div
                                                                                                                        class="premium-card">
                                                                                                                        <div
                                                                                                                            style="display: flex; justify-content: space-between; align-items: flex-start;">
                                                                                                                            <span
                                                                                                                                style="font-weight: 800; font-size: 0.9rem; color: var(--text-main); text-transform: uppercase; letter-spacing: 0.5px;">Bảo
                                                                                                                                mật
                                                                                                                                2
                                                                                                                                lớp
                                                                                                                                (OTP)</span>
                                                                                                                            <svg width="20"
                                                                                                                                height="20"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="#059669"
                                                                                                                                stroke-width="2">
                                                                                                                                <path
                                                                                                                                    d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                                                                                                            </svg>
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            style="display: flex; justify-content: space-between; align-items: center; gap: 1rem; margin-top: 1.1rem;">
                                                                                                                            <div>
                                                                                                                                <span
                                                                                                                                    style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); display: block;">Mã
                                                                                                                                    OTP
                                                                                                                                    qua
                                                                                                                                    Email</span>
                                                                                                                                <p
                                                                                                                                    style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; line-height: 1.5; margin: 0.35rem 0 0 0;">
                                                                                                                                    Tăng
                                                                                                                                    cường
                                                                                                                                    bảo
                                                                                                                                    vệ
                                                                                                                                    tài
                                                                                                                                    khoản
                                                                                                                                    khi
                                                                                                                                    đăng
                                                                                                                                    nhập
                                                                                                                                    ở
                                                                                                                                    thiết
                                                                                                                                    bị
                                                                                                                                    lạ.
                                                                                                                                </p>
                                                                                                                            </div>

                                                                                                                            <!-- Form ngầm xử lý toggle 2FA -->
                                                                                                                            <form
                                                                                                                                id="toggle2faForm"
                                                                                                                                action="${pageContext.request.contextPath}/profile"
                                                                                                                                method="POST"
                                                                                                                                style="display: none;">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="action"
                                                                                                                                    value="toggle2FA">
                                                                                                                            </form>

                                                                                                                            <!-- NÚT TOGGLE SWITCH THỰC TẾ -->
                                                                                                                            <% boolean
                                                                                                                                is2fa=(user
                                                                                                                                !=null
                                                                                                                                &&
                                                                                                                                user.isTwoFactorEnabled());
                                                                                                                                %>
                                                                                                                                <div id="otp-toggle-btn"
                                                                                                                                    onclick="document.getElementById('toggle2faForm').submit();"
                                                                                                                                    style="width: 44px; height: 24px; background: <%= is2fa ? "#10b981" : "#cbd5e1" %>
                                                                                                                                    ;
                                                                                                                                    border-radius:
                                                                                                                                    12px;
                                                                                                                                    padding:
                                                                                                                                    2px;
                                                                                                                                    cursor:
                                                                                                                                    pointer;
                                                                                                                                    transition:
                                                                                                                                    background
                                                                                                                                    0.3s
                                                                                                                                    ease;
                                                                                                                                    display:
                                                                                                                                    flex;
                                                                                                                                    align-items:
                                                                                                                                    center;">
                                                                                                                                    <div class="toggle-circle"
                                                                                                                                        style="width: 20px; height: 20px; background: #ffffff; border-radius: 50%; box-shadow: 0 1px 3px rgba(0,0,0,0.2); transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform: translateX(<%= is2fa ? "20px" : "0" %>
                                                                                                                                        );">
                                                                                                                                    </div>
                                                                                                                                </div>
                                                                                                                        </div>
                                                                                                                    </div>

                                                                                                                </div>
                                                                                                            </section>

                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- TAB: ĐĂNG KHÓA HỌC                         -->
                                                                                                            <!-- ========================================== -->


                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- TAB 4: ĐĂNG TẢI TÀI LIỆU                   -->
                                                                                                            <!-- ========================================== -->


                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- TAB 7: HỐ TRỢ HỌC TẬP                      -->
                                                                                                            <!-- ========================================== -->
                                                                                                            <section
                                                                                                                id="tab-support"
                                                                                                                class="tab-pane <%= "tab-support".equals(initialTab) ? "active-pane" : "" %>">
                                                                                                                <div
                                                                                                                    class="tab-pane-header">
                                                                                                                    <div
                                                                                                                        class="tab-pane-header-left">
                                                                                                                        <h1>Hỗ
                                                                                                                            trợ
                                                                                                                            học
                                                                                                                            tập
                                                                                                                        </h1>
                                                                                                                        <p>Gửi
                                                                                                                            yêu
                                                                                                                            cầu
                                                                                                                            hỗ
                                                                                                                            trợ
                                                                                                                            học
                                                                                                                            tập
                                                                                                                            và
                                                                                                                            kỹ
                                                                                                                            thuật
                                                                                                                            tới
                                                                                                                            ban
                                                                                                                            quản
                                                                                                                            trị
                                                                                                                            HIPZI.
                                                                                                                        </p>
                                                                                                                    </div>
                                                                                                                    <div
                                                                                                                        class="tab-pane-header-right">
                                                                                                                        <div
                                                                                                                            class="date-badge">
                                                                                                                            <svg width="15"
                                                                                                                                height="15"
                                                                                                                                viewBox="0 0 24 24"
                                                                                                                                fill="none"
                                                                                                                                stroke="currentColor"
                                                                                                                                stroke-width="2">
                                                                                                                                <rect
                                                                                                                                    x="3"
                                                                                                                                    y="4"
                                                                                                                                    width="18"
                                                                                                                                    height="18"
                                                                                                                                    rx="2"
                                                                                                                                    ry="2" />
                                                                                                                                <line
                                                                                                                                    x1="16"
                                                                                                                                    y1="2"
                                                                                                                                    x2="16"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="8"
                                                                                                                                    y1="2"
                                                                                                                                    x2="8"
                                                                                                                                    y2="6" />
                                                                                                                                <line
                                                                                                                                    x1="3"
                                                                                                                                    y1="10"
                                                                                                                                    x2="21"
                                                                                                                                    y2="10" />
                                                                                                                            </svg>
                                                                                                                            <span>
                                                                                                                                <%= currentDateDisplay
                                                                                                                                    %>
                                                                                                                            </span>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>

                                                                                                                <div class="dashboard-grid-layout"
                                                                                                                    style="align-items: start;">
                                                                                                                    <!-- SUPPORT FORM -->
                                                                                                                    <div
                                                                                                                        class="premium-card">
                                                                                                                        <div class="premium-card-header"
                                                                                                                            style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem;">
                                                                                                                            <span
                                                                                                                                class="premium-card-title">
                                                                                                                                <svg width="20"
                                                                                                                                    height="20"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <path
                                                                                                                                        d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                                                                                                                                    <polyline
                                                                                                                                        points="22,6 12,13 2,6" />
                                                                                                                                </svg>
                                                                                                                                Yêu
                                                                                                                                cầu
                                                                                                                                hỗ
                                                                                                                                trợ
                                                                                                                            </span>
                                                                                                                        </div>
                                                                                                                        <form
                                                                                                                            id="supportForm"
                                                                                                                            style="display: flex; flex-direction: column; gap: 1.25rem;"
                                                                                                                            class="form-edit-layout">
                                                                                                                            <div
                                                                                                                                class="form-group-premium">
                                                                                                                                <label>Tiêu
                                                                                                                                    đề
                                                                                                                                    cần
                                                                                                                                    hỗ
                                                                                                                                    trợ
                                                                                                                                    <span
                                                                                                                                        style="color:#ef4444;">*</span></label>
                                                                                                                                <input
                                                                                                                                    type="text"
                                                                                                                                    name="title"
                                                                                                                                    required
                                                                                                                                    placeholder="Nhập tiêu đề vắn tắt...">
                                                                                                                            </div>
                                                                                                                            <div
                                                                                                                                class="form-group-premium">
                                                                                                                                <label>Mô
                                                                                                                                    tả
                                                                                                                                    chi
                                                                                                                                    tiết
                                                                                                                                    <span
                                                                                                                                        style="color:#ef4444;">*</span></label>
                                                                                                                                <textarea
                                                                                                                                    name="content"
                                                                                                                                    rows="4"
                                                                                                                                    required
                                                                                                                                    placeholder="Mô tả khó khăn bạn đang gặp phải..."></textarea>
                                                                                                                            </div>
                                                                                                                            <div class="support-submit-row"
                                                                                                                                style="display: flex; justify-content: flex-end;">
                                                                                                                                <button
                                                                                                                                    type="submit"
                                                                                                                                    class="btn-premium primary">Gửi
                                                                                                                                    tin
                                                                                                                                    nhắn</button>
                                                                                                                            </div>
                                                                                                                        </form>
                                                                                                                    </div>

                                                                                                                    <!-- SUPPORT HISTORY -->
                                                                                                                    <div
                                                                                                                        class="premium-card">
                                                                                                                        <div class="premium-card-header"
                                                                                                                            style="border-bottom: 1px solid var(--border-dark); padding-bottom: 1rem; margin-bottom: 1.5rem; display:flex; align-items:center; justify-content:space-between; gap:1rem;">
                                                                                                                            <span
                                                                                                                                class="premium-card-title">
                                                                                                                                <svg width="20"
                                                                                                                                    height="20"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <path
                                                                                                                                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                                                                                                </svg>
                                                                                                                                Lịch
                                                                                                                                sử
                                                                                                                                hỗ
                                                                                                                                trợ
                                                                                                                            </span>
                                                                                                                            <span
                                                                                                                                style="font-size:0.72rem; font-weight:850; color:#059669; background:#dcfce7; border-radius:999px; padding:0.18rem 0.6rem;">
                                                                                                                                <%= userSupportTickets
                                                                                                                                    !=null
                                                                                                                                    ?
                                                                                                                                    userSupportTickets.size()
                                                                                                                                    :
                                                                                                                                    0
                                                                                                                                    %>
                                                                                                                                    yêu
                                                                                                                                    cầu
                                                                                                                            </span>
                                                                                                                        </div>
                                                                                                                        <div
                                                                                                                            style="display:flex; flex-direction:column; gap:0.75rem;">
                                                                                                                            <% if
                                                                                                                                (userSupportTickets
                                                                                                                                !=null
                                                                                                                                &&
                                                                                                                                !userSupportTickets.isEmpty())
                                                                                                                                {
                                                                                                                                for
                                                                                                                                (SupportTicket
                                                                                                                                ticket
                                                                                                                                :
                                                                                                                                userSupportTickets)
                                                                                                                                {
                                                                                                                                String
                                                                                                                                ticketTime=ticket.getLatestMessageAt()
                                                                                                                                !=null
                                                                                                                                ?
                                                                                                                                new
                                                                                                                                SimpleDateFormat("dd/MM/yyyy HH:mm").format(ticket.getLatestMessageAt())
                                                                                                                                : ""
                                                                                                                                ;
                                                                                                                                %>
                                                                                                                                <a href="${pageContext.request.contextPath}/student-profile?tab=support&supportTicketId=<%= h(ticket.getId()) %>"
                                                                                                                                    style="display:block; text-decoration:none; border:1px solid #e2e8f0; border-radius:0.9rem; padding:0.9rem; background:#f8fafc; transition: all 0.2s ease;"
                                                                                                                                    onmouseover="this.style.borderColor='var(--primary)'"
                                                                                                                                    onmouseout="this.style.borderColor='#e2e8f0'">
                                                                                                                                    <span
                                                                                                                                        style="display:block; color:#0f172a; font-weight:850; font-size:0.88rem;">
                                                                                                                                        <%= h(ticket.getTitle())
                                                                                                                                            %>
                                                                                                                                    </span>
                                                                                                                                    <span
                                                                                                                                        style="display:block; color:#64748b; font-weight:650; font-size:0.76rem; margin-top:0.25rem;">
                                                                                                                                        <%= h(ticket.getStatus())
                                                                                                                                            %>
                                                                                                                                            ·
                                                                                                                                            <%= ticketTime
                                                                                                                                                %>
                                                                                                                                    </span>
                                                                                                                                    <span
                                                                                                                                        style="display:block; color:#475569; font-size:0.78rem; margin-top:0.45rem; line-height:1.45;">
                                                                                                                                        <%= h(ticket.getLatestMessage())
                                                                                                                                            %>
                                                                                                                                    </span>
                                                                                                                                </a>
                                                                                                                                <% } }
                                                                                                                                    else
                                                                                                                                    {
                                                                                                                                    %>
                                                                                                                                    <div
                                                                                                                                        style="border:1px dashed #cbd5e1; border-radius:0.9rem; padding:1rem; text-align:center; color:#64748b; font-weight:750;">
                                                                                                                                        Bạn
                                                                                                                                        chưa
                                                                                                                                        gửi
                                                                                                                                        yêu
                                                                                                                                        cầu
                                                                                                                                        hỗ
                                                                                                                                        trợ
                                                                                                                                        nào.
                                                                                                                                    </div>
                                                                                                                                    <% }
                                                                                                                                        %>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                            </section>
                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- TAB: THỐNG KÊ SỐ DƯ (VÍ TIỀN)              -->
                                                                                                            <!-- ========================================== -->


                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- TAB: LỊCH SỬ GIAO DỊCH (VÍ TIỀN)           -->
                                                                                                            <!-- ========================================== -->


                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- MODAL OVERLAY: ĐỔI MẬT KHẨU HỆ THỐNG       -->
                                                                                                            <!-- ========================================== -->
                                                                                                            <!-- ========================================== -->
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
                                                                                                                                <svg width="18"
                                                                                                                                    height="18"
                                                                                                                                    viewBox="0 0 24 24"
                                                                                                                                    fill="none"
                                                                                                                                    stroke="currentColor"
                                                                                                                                    stroke-width="2.5">
                                                                                                                                    <rect
                                                                                                                                        x="3"
                                                                                                                                        y="11"
                                                                                                                                        width="18"
                                                                                                                                        height="11"
                                                                                                                                        rx="2" />
                                                                                                                                    <path
                                                                                                                                        d="M7 11V7a5 5 0 0 1 10 0v4" />
                                                                                                                                </svg>
                                                                                                                            </div>
                                                                                                                            <span
                                                                                                                                style="font-size:1.25rem; font-weight:800; color:var(--text-main);">Đổi
                                                                                                                                mật
                                                                                                                                khẩu</span>
                                                                                                                        </div>
                                                                                                                        <button
                                                                                                                            type="button"
                                                                                                                            onclick="document.getElementById('pwd-modal-overlay').style.display='none';"
                                                                                                                            style="background:none; border:none; font-size:1.25rem; color:var(--text-muted); cursor:pointer;">&times;</button>
                                                                                                                    </div>

                                                                                                                    <form
                                                                                                                        action="${pageContext.request.contextPath}/profile"
                                                                                                                        method="POST"
                                                                                                                        class="form-edit-layout"
                                                                                                                        style="display:flex; flex-direction:column; gap:1.25rem; padding: 0;">
                                                                                                                        <input
                                                                                                                            type="hidden"
                                                                                                                            name="action"
                                                                                                                            value="changePassword">

                                                                                                                        <div
                                                                                                                            class="form-group-premium">
                                                                                                                            <label>Mật
                                                                                                                                khẩu
                                                                                                                                hiện
                                                                                                                                tại
                                                                                                                                <span
                                                                                                                                    style="color:#ef4444;">*</span></label>
                                                                                                                            <input
                                                                                                                                type="password"
                                                                                                                                name="currentPassword"
                                                                                                                                required
                                                                                                                                placeholder="••••••••">
                                                                                                                        </div>

                                                                                                                        <div
                                                                                                                            class="form-group-premium">
                                                                                                                            <label>Mật
                                                                                                                                khẩu
                                                                                                                                mới
                                                                                                                                <span
                                                                                                                                    style="color:#ef4444;">*</span></label>
                                                                                                                            <input
                                                                                                                                type="password"
                                                                                                                                name="newPassword"
                                                                                                                                required
                                                                                                                                minlength="6"
                                                                                                                                placeholder="Mật khẩu ít nhất 6 ký tự">
                                                                                                                        </div>

                                                                                                                        <div
                                                                                                                            class="form-group-premium">
                                                                                                                            <label>Xác
                                                                                                                                nhận
                                                                                                                                mật
                                                                                                                                khẩu
                                                                                                                                mới
                                                                                                                                <span
                                                                                                                                    style="color:#ef4444;">*</span></label>
                                                                                                                            <input
                                                                                                                                type="password"
                                                                                                                                name="confirmPassword"
                                                                                                                                required
                                                                                                                                minlength="6"
                                                                                                                                placeholder="Nhập lại mật khẩu mới">
                                                                                                                        </div>

                                                                                                                        <div
                                                                                                                            class="form-actions-row-premium">
                                                                                                                            <button
                                                                                                                                type="button"
                                                                                                                                onclick="document.getElementById('pwd-modal-overlay').style.display='none';"
                                                                                                                                class="btn-premium secondary">Hủy
                                                                                                                                bỏ</button>
                                                                                                                            <button
                                                                                                                                type="submit"
                                                                                                                                class="btn-premium primary"
                                                                                                                                style="background:#059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">Cập
                                                                                                                                nhật
                                                                                                                                ngay</button>
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
                                                                                            let teacherFrameResizeObserver;

                                                                                            function syncTeacherDashboardFrameHeight() {
                                                                                                const dashboard = document.querySelector('.app-dashboard-container');
                                                                                                const contentWrapper = document.querySelector('.dashboard-content-wrapper');
                                                                                                const sidebar = document.querySelector('.dashboard-sidebar');
                                                                                                if (!dashboard || !contentWrapper) {
                                                                                                    return;
                                                                                                }

                                                                                                const dashboardTop = dashboard.getBoundingClientRect().top + window.scrollY;
                                                                                                const contentBottom = contentWrapper.getBoundingClientRect().bottom + window.scrollY;
                                                                                                const sidebarBottom = sidebar ? sidebar.getBoundingClientRect().bottom + window.scrollY : 0;
                                                                                                const layoutBottom = Math.max(contentBottom, sidebarBottom);
                                                                                                const frameHeight = Math.ceil(layoutBottom - dashboardTop + 20);
                                                                                                const pageBgHeight = Math.ceil(layoutBottom + 20);
                                                                                                dashboard.style.setProperty('--teacher-dashboard-frame-height', frameHeight + 'px');
                                                                                                document.body.style.setProperty('--teacher-page-bg-height', pageBgHeight + 'px');
                                                                                            }

                                                                                            function scheduleTeacherDashboardFrameSync() {
                                                                                                requestAnimationFrame(() => {
                                                                                                    syncTeacherDashboardFrameHeight();
                                                                                                    requestAnimationFrame(syncTeacherDashboardFrameHeight);
                                                                                                });
                                                                                            }

                                                                                            function observeTeacherDashboardFrame() {
                                                                                                const contentWrapper = document.querySelector('.dashboard-content-wrapper');
                                                                                                const sidebar = document.querySelector('.dashboard-sidebar');
                                                                                                if (!contentWrapper || typeof ResizeObserver === 'undefined') {
                                                                                                    scheduleTeacherDashboardFrameSync();
                                                                                                    return;
                                                                                                }

                                                                                                if (teacherFrameResizeObserver) {
                                                                                                    teacherFrameResizeObserver.disconnect();
                                                                                                }

                                                                                                teacherFrameResizeObserver = new ResizeObserver(scheduleTeacherDashboardFrameSync);
                                                                                                teacherFrameResizeObserver.observe(contentWrapper);
                                                                                                if (sidebar) {
                                                                                                    teacherFrameResizeObserver.observe(sidebar);
                                                                                                }
                                                                                                document.querySelectorAll('.tab-pane').forEach(pane => teacherFrameResizeObserver.observe(pane));
                                                                                                scheduleTeacherDashboardFrameSync();
                                                                                            }

                                                                                            function getTeacherTabSlug(tabId) {
                                                                                                return tabId.replace(/^tab-/, '');
                                                                                            }

                                                                                            function normalizeStudentTabId(tabValue) {
                                                                                                if (!tabValue) {
                                                                                                    return '';
                                                                                                }
                                                                                                return tabValue.startsWith('tab-') ? tabValue : 'tab-' + tabValue;
                                                                                            }

                                                                                            function updateStudentTabUrl(targetTabId, replace = false) {
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
                                                                                                'tab-materials': 'Đăng kí giảng dạy',
                                                                                                'tab-history': 'Đăng kí lớp học',
                                                                                                'tab-dashboard': 'Tổng quan học tập',
                                                                                                'tab-edit': 'Cập nhật thông tin',
                                                                                                'tab-profile': 'Hồ sơ cá nhân',
                                                                                                'tab-upload-material': 'Đăng tải tài liệu',
                                                                                                'tab-support': 'Hỗ trợ học tập',
                                                                                                'tab-balance-stats': 'Thống kê số dư',
                                                                                                'tab-transaction-history': 'Lịch sử giao dịch',

                                                                                                'tab-my-classes': 'Lớp học của tôi',
                                                                                                'tab-my-courses': 'Khóa học của tôi',
                                                                                                'tab-wallet-history': 'Thanh toán học phí'
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
                                                                                                    scheduleTeacherDashboardFrameSync();
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
                                                                                                scheduleTeacherDashboardFrameSync();
                                                                                            }

                                                                                            function toggleSidebar() {
                                                                                                const container = document.querySelector('.app-dashboard-container');
                                                                                                if (container) {
                                                                                                    container.classList.toggle('collapsed');
                                                                                                    const isCollapsed = container.classList.contains('collapsed');
                                                                                                    localStorage.setItem('sidebarCollapsed', isCollapsed ? 'true' : 'false');
                                                                                                    scheduleTeacherDashboardFrameSync();
                                                                                                }
                                                                                            }

                                                                                            function switchTab(targetTabId, options = {}) {
                                                                                                if (options.updateUrl !== false && options.replaceUrl !== true) {
                                                                                                    let newTab = targetTabId;
                                                                                                    if (newTab.startsWith('tab-')) newTab = newTab.substring(4);
                                                                                                    const currentTab = new URLSearchParams(window.location.search).get('tab') || 'dashboard';
                                                                                                    if (newTab !== currentTab) {
                                                                                                        window.location.href = '?tab=' + newTab;
                                                                                                        return;
                                                                                                    }
                                                                                                }
                                                                                                targetTabId = normalizeStudentTabId(targetTabId);
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
                                                                                                        updateStudentTabUrl(targetTabId, options.replaceUrl);
                                                                                                    }
                                                                                                    scheduleTeacherDashboardFrameSync();
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
                                                                                                    updateStudentTabUrl(targetTabId, options.replaceUrl);
                                                                                                }

                                                                                                requestAnimationFrame(() => {
                                                                                                    scheduleTeacherDashboardFrameSync();
                                                                                                    settleTeacherTabScroll();
                                                                                                });
                                                                                            }

                                                                                            const overviewStudyRawData = {
                                                                                                week: <%= weeklyStudyJson %>,
                                                                                                month: <%= monthlyStudyJson %>
                                                                                            };

                                                                                            function formatOverviewTotalHours(points) {
                                                                                                const total = (points || []).reduce((sum, point) => sum + (Number(point.hours) || 0), 0);
                                                                                                if (total <= 0) return '0';
                                                                                                if (total >= 10 || Math.abs(total - Math.round(total)) < 0.05) return String(Math.round(total));
                                                                                                return total.toFixed(1);
                                                                                            }

                                                                                            function buildOverviewChartPeriod(points) {
                                                                                                const safePoints = (points && points.length ? points : [{ label: '', fullLabel: '', hours: 0, hoursLabel: '0 giờ' }]).slice(0, 7);
                                                                                                while (safePoints.length < 7) {
                                                                                                    safePoints.push({ label: '', fullLabel: '', hours: 0, hoursLabel: '0 giờ' });
                                                                                                }
                                                                                                const maxHours = Math.max(1, ...safePoints.map(point => Number(point.hours) || 0));
                                                                                                const chartLeft = 64;
                                                                                                const chartRight = 610;
                                                                                                const chartBottom = 162;
                                                                                                const chartTop = 24;
                                                                                                const chartWidth = chartRight - chartLeft;
                                                                                                const chartHeight = chartBottom - chartTop;
                                                                                                const coords = safePoints.map((point, index) => {
                                                                                                    const value = Number(point.hours) || 0;
                                                                                                    const x = chartLeft + (chartWidth / 6) * index;
                                                                                                    const y = chartBottom - Math.min(1, value / maxHours) * chartHeight;
                                                                                                    return { x, y, point };
                                                                                                });
                                                                                                const selected = coords.reduce((best, current) => {
                                                                                                    const currentHours = Number(current.point.hours) || 0;
                                                                                                    const bestHours = Number(best.point.hours) || 0;
                                                                                                    return currentHours >= bestHours ? current : best;
                                                                                                }, coords[0]);
                                                                                                const line = coords.map((coord, index) => (index === 0 ? 'M' : 'L') + coord.x.toFixed(1) + ' ' + coord.y.toFixed(1)).join(' ');
                                                                                                return {
                                                                                                    ticks: safePoints.map(point => point.label || ''),
                                                                                                    points: coords.map(coord => ({
                                                                                                        x: coord.x,
                                                                                                        y: coord.y,
                                                                                                        label: coord.point.label || '',
                                                                                                        fullLabel: coord.point.fullLabel || coord.point.label || '',
                                                                                                        hoursLabel: coord.point.hoursLabel || '0 giờ'
                                                                                                    })),
                                                                                                    tooltipDate: selected.point.fullLabel || selected.point.label || '',
                                                                                                    totalTaught: formatOverviewTotalHours(safePoints),
                                                                                                    taught: selected.point.hoursLabel || '0 giờ',
                                                                                                    guideX: selected.x.toFixed(1),
                                                                                                    taughtDot: { x: selected.x.toFixed(1), y: selected.y.toFixed(1) },
                                                                                                    tooltipLeft: Math.max(18, Math.min(82, (selected.x / 640) * 100)).toFixed(1) + '%',
                                                                                                    taughtLine: line
                                                                                                };
                                                                                            }

                                                                                            const overviewChartPeriods = {
                                                                                                week: buildOverviewChartPeriod(overviewStudyRawData.week),
                                                                                                month: buildOverviewChartPeriod(overviewStudyRawData.month)
                                                                                            };

                                                                                            let currentOverviewChartPeriod = 'week';

                                                                                            function updateOverviewTooltipPoint(data, index) {
                                                                                                if (!data || !data.points || !data.points.length) {
                                                                                                    return;
                                                                                                }
                                                                                                const safeIndex = Math.max(0, Math.min(data.points.length - 1, index));
                                                                                                const point = data.points[safeIndex];
                                                                                                const tooltipDate = document.getElementById('overviewTooltipDate');
                                                                                                const tooltipTaught = document.getElementById('overviewTooltipTaught');
                                                                                                const guideLine = document.getElementById('overviewGuideLine');
                                                                                                const taughtDot = document.getElementById('overviewTaughtDot');
                                                                                                const tooltip = document.getElementById('overviewLineTooltip');
                                                                                                if (tooltipDate) tooltipDate.textContent = point.fullLabel || point.label || '';
                                                                                                if (tooltipTaught) tooltipTaught.textContent = point.hoursLabel || '0 giờ';
                                                                                                if (guideLine) {
                                                                                                    guideLine.setAttribute('x1', point.x.toFixed(1));
                                                                                                    guideLine.setAttribute('x2', point.x.toFixed(1));
                                                                                                }
                                                                                                if (taughtDot) {
                                                                                                    taughtDot.setAttribute('cx', point.x.toFixed(1));
                                                                                                    taughtDot.setAttribute('cy', point.y.toFixed(1));
                                                                                                }
                                                                                                if (tooltip) {
                                                                                                    tooltip.style.left = Math.max(18, Math.min(82, (point.x / 640) * 100)).toFixed(1) + '%';
                                                                                                }
                                                                                            }

                                                                                            function setOverviewChartPeriod(period) {
                                                                                                const switchEl = document.getElementById('overviewPeriodSwitch');
                                                                                                const lineWrap = document.getElementById('overviewLineWrap');
                                                                                                const data = overviewChartPeriods[period];
                                                                                                if (!switchEl || !data) {
                                                                                                    return;
                                                                                                }

                                                                                                currentOverviewChartPeriod = period;
                                                                                                switchEl.dataset.active = period;
                                                                                                switchEl.querySelectorAll('.overview-period-btn').forEach(button => {
                                                                                                    const isActive = button.dataset.period === period;
                                                                                                    button.classList.toggle('is-active', isActive);
                                                                                                    button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
                                                                                                });

                                                                                                if (lineWrap) {
                                                                                                    lineWrap.classList.add('is-switching');
                                                                                                }

                                                                                                window.setTimeout(() => {
                                                                                                    data.ticks.forEach((label, index) => {
                                                                                                        const tick = document.getElementById('overviewTick' + (index + 1));
                                                                                                        if (tick) {
                                                                                                            tick.textContent = label;
                                                                                                        }
                                                                                                    });

                                                                                                    const tooltipDate = document.getElementById('overviewTooltipDate');
                                                                                                    const tooltipTaught = document.getElementById('overviewTooltipTaught');
                                                                                                    const tooltipScheduled = document.getElementById('overviewTooltipScheduled');
                                                                                                    const totalTaught = document.getElementById('overviewTotalTaught');
                                                                                                    const totalScheduled = document.getElementById('overviewTotalScheduled');
                                                                                                    if (tooltipDate) tooltipDate.textContent = data.tooltipDate;
                                                                                                    if (tooltipTaught) tooltipTaught.textContent = data.taught;
                                                                                                    if (tooltipScheduled) tooltipScheduled.textContent = data.scheduled;
                                                                                                    if (totalTaught) totalTaught.textContent = data.totalTaught;
                                                                                                    if (totalScheduled) totalScheduled.textContent = data.totalScheduled;

                                                                                                    const taughtLine = document.getElementById('overviewTaughtLine');
                                                                                                    const scheduledLine = document.getElementById('overviewScheduledLine');
                                                                                                    const taughtArea = document.getElementById('overviewTaughtArea');
                                                                                                    const scheduledArea = document.getElementById('overviewScheduledArea');
                                                                                                    const guideLine = document.getElementById('overviewGuideLine');
                                                                                                    const taughtDot = document.getElementById('overviewTaughtDot');
                                                                                                    const scheduledDot = document.getElementById('overviewScheduledDot');
                                                                                                    const tooltip = document.getElementById('overviewLineTooltip');

                                                                                                    if (taughtLine) taughtLine.setAttribute('d', data.taughtLine);
                                                                                                    if (scheduledLine) scheduledLine.setAttribute('d', data.scheduledLine);
                                                                                                    if (taughtArea) taughtArea.setAttribute('d', data.taughtLine + ' L610 162 L64 162 Z');
                                                                                                    if (scheduledArea) scheduledArea.setAttribute('d', data.scheduledLine + ' L610 162 L64 162 Z');
                                                                                                    if (guideLine) {
                                                                                                        guideLine.setAttribute('x1', data.guideX);
                                                                                                        guideLine.setAttribute('x2', data.guideX);
                                                                                                    }
                                                                                                    if (taughtDot) {
                                                                                                        taughtDot.setAttribute('cx', data.taughtDot.x);
                                                                                                        taughtDot.setAttribute('cy', data.taughtDot.y);
                                                                                                    }
                                                                                                    if (scheduledDot) {
                                                                                                        scheduledDot.setAttribute('cx', data.scheduledDot.x);
                                                                                                        scheduledDot.setAttribute('cy', data.scheduledDot.y);
                                                                                                    }
                                                                                                    if (tooltip) {
                                                                                                        tooltip.style.left = data.tooltipLeft;
                                                                                                    }
                                                                                                    updateOverviewTooltipPoint(data, data.points ? data.points.length - 1 : 0);

                                                                                                    window.setTimeout(() => {
                                                                                                        if (lineWrap) {
                                                                                                            lineWrap.classList.remove('is-switching');
                                                                                                        }
                                                                                                    }, 120);
                                                                                                }, 120);
                                                                                            }

                                                                                            function initOverviewPeriodSwitch() {
                                                                                                const switchEl = document.getElementById('overviewPeriodSwitch');
                                                                                                if (!switchEl) {
                                                                                                    return;
                                                                                                }
                                                                                                const chartSvg = document.querySelector('#overviewLineWrap .overview-line-chart');
                                                                                                if (chartSvg && chartSvg.dataset.hoverBound !== 'true') {
                                                                                                    chartSvg.dataset.hoverBound = 'true';
                                                                                                    chartSvg.addEventListener('mousemove', event => {
                                                                                                        const data = overviewChartPeriods[currentOverviewChartPeriod] || overviewChartPeriods.week;
                                                                                                        if (!data || !data.points || !data.points.length) {
                                                                                                            return;
                                                                                                        }
                                                                                                        const rect = chartSvg.getBoundingClientRect();
                                                                                                        const mouseX = ((event.clientX - rect.left) / Math.max(1, rect.width)) * 640;
                                                                                                        let closestIndex = 0;
                                                                                                        let closestDistance = Number.POSITIVE_INFINITY;
                                                                                                        data.points.forEach((point, index) => {
                                                                                                            const distance = Math.abs(point.x - mouseX);
                                                                                                            if (distance < closestDistance) {
                                                                                                                closestDistance = distance;
                                                                                                                closestIndex = index;
                                                                                                            }
                                                                                                        });
                                                                                                        updateOverviewTooltipPoint(data, closestIndex);
                                                                                                    });
                                                                                                    chartSvg.addEventListener('mouseleave', () => {
                                                                                                        const data = overviewChartPeriods[currentOverviewChartPeriod] || overviewChartPeriods.week;
                                                                                                        updateOverviewTooltipPoint(data, data && data.points ? data.points.length - 1 : 0);
                                                                                                    });
                                                                                                }
                                                                                                switchEl.querySelectorAll('.overview-period-btn').forEach(button => {
                                                                                                    button.addEventListener('click', () => {
                                                                                                        if (button.classList.contains('is-active')) {
                                                                                                            return;
                                                                                                        }
                                                                                                        setOverviewChartPeriod(button.dataset.period);
                                                                                                    });
                                                                                                });
                                                                                                setOverviewChartPeriod(switchEl.dataset.active || 'week');
                                                                                            }

                                                                                            function initStudentStudyTracking() {
                                                                                                const endpoint = '${pageContext.request.contextPath}/student-study-session';
                                                                                                let activeStartedAt = Date.now();
                                                                                                let isVisible = document.visibilityState !== 'hidden';

                                                                                                function flushStudySeconds(useBeacon) {
                                                                                                    if (!isVisible && !useBeacon) {
                                                                                                        return;
                                                                                                    }
                                                                                                    const now = Date.now();
                                                                                                    const seconds = Math.floor((now - activeStartedAt) / 1000);
                                                                                                    if (seconds <= 0) {
                                                                                                        return;
                                                                                                    }
                                                                                                    activeStartedAt = now;
                                                                                                    const params = new URLSearchParams();
                                                                                                    params.set('seconds', String(seconds));
                                                                                                    if (useBeacon && navigator.sendBeacon) {
                                                                                                        navigator.sendBeacon(endpoint, params);
                                                                                                        return;
                                                                                                    }
                                                                                                    fetch(endpoint, {
                                                                                                        method: 'POST',
                                                                                                        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                                                                                                        body: params.toString(),
                                                                                                        credentials: 'same-origin',
                                                                                                        keepalive: true
                                                                                                    }).catch(() => {});
                                                                                                }

                                                                                                window.setInterval(() => {
                                                                                                    if (document.visibilityState !== 'hidden') {
                                                                                                        flushStudySeconds(false);
                                                                                                    }
                                                                                                }, 30000);

                                                                                                document.addEventListener('visibilitychange', () => {
                                                                                                    if (document.visibilityState === 'hidden') {
                                                                                                        flushStudySeconds(true);
                                                                                                        isVisible = false;
                                                                                                    } else {
                                                                                                        activeStartedAt = Date.now();
                                                                                                        isVisible = true;
                                                                                                    }
                                                                                                });

                                                                                                window.addEventListener('pagehide', () => flushStudySeconds(true));
                                                                                                window.addEventListener('beforeunload', () => flushStudySeconds(true));
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
                                                                                                    const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
                                                                                                    if (isCollapsed) {
                                                                                                        const container = document.querySelector('.app-dashboard-container');
                                                                                                        if (container) {
                                                                                                            container.classList.add('collapsed');
                                                                                                        }
                                                                                                    }
                                                                                                    observeTeacherDashboardFrame();
                                                                                                    initOverviewPeriodSwitch();
                                                                                                    initStudentStudyTracking();
                                                                                                });

                                                                                            window.addEventListener('DOMContentLoaded', () => {
                                                                                                const urlParams = new URLSearchParams(window.location.search);
                                                                                                const tabParam = urlParams.get('tab');
                                                                                                if (tabParam) {
                                                                                                    switchTab(normalizeStudentTabId(tabParam), { replaceUrl: true });
                                                                                                } else {
                                                                                                    const activePane = document.querySelector('.tab-pane.active-pane');
                                                                                                    if (activePane) {
                                                                                                        updateStudentTabUrl(activePane.id, true);
                                                                                                    }
                                                                                                }
                                                                                                scheduleTeacherDashboardFrameSync();
                                                                                            });

                                                                                            window.addEventListener('load', scheduleTeacherDashboardFrameSync);
                                                                                            window.addEventListener('resize', scheduleTeacherDashboardFrameSync);

                                                                                            document.querySelectorAll('.dashboard-content-wrapper details').forEach(detail => {
                                                                                                detail.addEventListener('toggle', scheduleTeacherDashboardFrameSync);
                                                                                            });

                                                                                            window.addEventListener('popstate', (event) => {
                                                                                                const stateTab = event.state && event.state.teacherTab;
                                                                                                const urlTab = new URLSearchParams(window.location.search).get('tab');
                                                                                                const targetTabId = stateTab || (urlTab ? normalizeStudentTabId(urlTab) : 'tab-materials');
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
                                                                                                supportForm.addEventListener('submit', function (e) {
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
                                                                                                                showToast('Đã gửi yêu cầu hỗ trợ. Phản hồi sẽ hiển thị trong tab hỗ trợ của bạn.');
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
                                                                                                const form = document.getElementById('teacher-profile-form');
                                                                                                if (form && form.dataset.updateLocked === 'true') {
                                                                                                    showToast('Nhấn Cập nhật hồ sơ trước khi chỉnh sửa hoặc gửi lại thông tin.', 'info');
                                                                                                    return false;
                                                                                                }

                                                                                                const checkboxes = document.querySelectorAll('input[name="teachingSubjects"]:checked');
                                                                                                if (checkboxes.length === 0) {
                                                                                                    showToast('Vui lòng chọn ít nhất một môn có thể dạy.', 'error');
                                                                                                    return false;
                                                                                                }
                                                                                                return true;
                                                                                            }

                                                                                            function syncTeachingSubjectLabelStates() {
                                                                                                document.querySelectorAll('input[name="teachingSubjects"]').forEach(input => {
                                                                                                    const label = input.closest('label');
                                                                                                    if (label) {
                                                                                                        label.classList.toggle('teacher-subject-selected', input.checked);
                                                                                                    }
                                                                                                });
                                                                                            }

                                                                                            document.querySelectorAll('input[name="teachingSubjects"]').forEach(input => {
                                                                                                input.addEventListener('change', syncTeachingSubjectLabelStates);
                                                                                            });
                                                                                            syncTeachingSubjectLabelStates();

                                                                                            function setTeachingRegistrationLocked(isLocked) {
                                                                                                const form = document.getElementById('teacher-profile-form');
                                                                                                const fieldset = document.getElementById('registration-fieldset');
                                                                                                if (!form || !fieldset) return;

                                                                                                fieldset.classList.toggle('teacher-registration-readonly', isLocked);
                                                                                                fieldset.classList.toggle('teacher-registration-editing', !isLocked);

                                                                                                form.querySelectorAll('input, select, textarea').forEach(control => {
                                                                                                    if (control.type === 'hidden') return;

                                                                                                    const disableWhenLocked = control.matches('select, input[type="radio"], input[type="checkbox"], input[type="file"]');
                                                                                                    if (disableWhenLocked) {
                                                                                                        control.disabled = isLocked;
                                                                                                        if (isLocked) {
                                                                                                            control.setAttribute('disabled', 'disabled');
                                                                                                        } else {
                                                                                                            control.removeAttribute('disabled');
                                                                                                        }
                                                                                                        return;
                                                                                                    }

                                                                                                    const supportsReadOnly = control.matches('input:not([type="radio"]):not([type="checkbox"]):not([type="file"]), textarea');
                                                                                                    if (supportsReadOnly && isLocked) {
                                                                                                        control.readOnly = true;
                                                                                                        control.setAttribute('readonly', 'readonly');
                                                                                                        control.setAttribute('aria-readonly', 'true');
                                                                                                    } else {
                                                                                                        control.readOnly = false;
                                                                                                        control.removeAttribute('readonly');
                                                                                                        control.setAttribute('aria-readonly', 'false');
                                                                                                    }
                                                                                                });
                                                                                            }

                                                                                            const teacherProfileForm = document.getElementById('teacher-profile-form');
                                                                                            if (teacherProfileForm && teacherProfileForm.dataset.updateLocked === 'true') {
                                                                                                setTeachingRegistrationLocked(true);
                                                                                            }

                                                                                            const teacherEvidenceInput = document.getElementById('teacherEvidenceFiles');
                                                                                            const teacherEvidenceFileName = document.getElementById('teacherEvidenceFileName');
                                                                                            const teacherEvidenceDropzone = document.querySelector('.teacher-evidence-dropzone');

                                                                                            function updateTeacherEvidenceFileName(files) {
                                                                                                if (!teacherEvidenceFileName) return;
                                                                                                if (!files || files.length === 0) {
                                                                                                    teacherEvidenceFileName.textContent = 'Chưa có tệp nào được chọn';
                                                                                                    return;
                                                                                                }
                                                                                                if (files.length === 1) {
                                                                                                    teacherEvidenceFileName.textContent = files[0].name;
                                                                                                    return;
                                                                                                }
                                                                                                teacherEvidenceFileName.textContent = files.length + ' tệp đã được chọn';
                                                                                            }

                                                                                            if (teacherEvidenceInput && teacherEvidenceDropzone) {
                                                                                                teacherEvidenceInput.addEventListener('change', () => {
                                                                                                    updateTeacherEvidenceFileName(teacherEvidenceInput.files);
                                                                                                });

                                                                                                ['dragenter', 'dragover'].forEach(eventName => {
                                                                                                    teacherEvidenceDropzone.addEventListener(eventName, event => {
                                                                                                        event.preventDefault();
                                                                                                        teacherEvidenceDropzone.classList.add('drag-over');
                                                                                                    });
                                                                                                });

                                                                                                ['dragleave', 'drop'].forEach(eventName => {
                                                                                                    teacherEvidenceDropzone.addEventListener(eventName, event => {
                                                                                                        event.preventDefault();
                                                                                                        teacherEvidenceDropzone.classList.remove('drag-over');
                                                                                                    });
                                                                                                });

                                                                                                teacherEvidenceDropzone.addEventListener('drop', event => {
                                                                                                    if (event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files.length > 0) {
                                                                                                        teacherEvidenceInput.files = event.dataTransfer.files;
                                                                                                        updateTeacherEvidenceFileName(teacherEvidenceInput.files);
                                                                                                    }
                                                                                                });
                                                                                            }

                                                                                            const materialFileInput = document.getElementById('materialFileUpload');
                                                                                            const materialFileNameDisplay = document.getElementById('materialFileNameDisplay');
                                                                                            const materialFileDropzone = document.querySelector('.material-file-dropzone');

                                                                                            function updateMaterialFileName(files) {
                                                                                                if (!materialFileNameDisplay) return;
                                                                                                if (!files || files.length === 0) {
                                                                                                    materialFileNameDisplay.textContent = 'Không có tệp nào được chọn';
                                                                                                    return;
                                                                                                }
                                                                                                if (files.length === 1) {
                                                                                                    materialFileNameDisplay.textContent = files[0].name;
                                                                                                    return;
                                                                                                }
                                                                                                materialFileNameDisplay.textContent = files.length + ' tệp đã được chọn';
                                                                                            }

                                                                                            if (materialFileInput && materialFileDropzone) {
                                                                                                materialFileInput.addEventListener('change', () => {
                                                                                                    updateMaterialFileName(materialFileInput.files);
                                                                                                });

                                                                                                ['dragenter', 'dragover'].forEach(eventName => {
                                                                                                    materialFileDropzone.addEventListener(eventName, event => {
                                                                                                        event.preventDefault();
                                                                                                        materialFileDropzone.classList.add('drag-over');
                                                                                                    });
                                                                                                });

                                                                                                ['dragleave', 'drop'].forEach(eventName => {
                                                                                                    materialFileDropzone.addEventListener(eventName, event => {
                                                                                                        event.preventDefault();
                                                                                                        materialFileDropzone.classList.remove('drag-over');
                                                                                                    });
                                                                                                });

                                                                                                materialFileDropzone.addEventListener('drop', event => {
                                                                                                    event.preventDefault();
                                                                                                    materialFileDropzone.classList.remove('drag-over');
                                                                                                    if (event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files.length > 0) {
                                                                                                        materialFileInput.files = event.dataTransfer.files;
                                                                                                        updateMaterialFileName(materialFileInput.files);
                                                                                                    }
                                                                                                });
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
                                                                                        <script
                                                                                            src="https://apis.google.com/js/api.js"
                                                                                            async defer></script>
                                                                                        <style>
                                                                                            @keyframes spin {
                                                                                                to {
                                                                                                    transform: rotate(360deg);
                                                                                                }
                                                                                            }

                                                                                            #btn-open-picker:hover {
                                                                                                border-color: #059669 !important;
                                                                                                background: #f0fdf4 !important;
                                                                                                box-shadow: 0 4px 14px rgba(5, 150, 105, 0.15) !important;
                                                                                                transform: translateY(-1px);
                                                                                            }
                                                                                        </style>
                                                                                        <script>
                                                                                            var pickerApiLoaded = false;
                                                                                            var pickerTokenPending = false;

                                                                                            function onGapiLoad() {
                                                                                                gapi.load('picker', function () { pickerApiLoaded = true; });
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
                                                                                                    .then(function (res) { return res.json(); })
                                                                                                    .then(function (data) {
                                                                                                        if (data.error) { showToast(data.error, 'error'); resetPickerBtn(); return; }
                                                                                                        if (!pickerApiLoaded) {
                                                                                                            var att = 0, t = setInterval(function () {
                                                                                                                att++;
                                                                                                                if (pickerApiLoaded) { clearInterval(t); buildAndShowPicker(data.accessToken, data.clientId); }
                                                                                                                else if (att > 30) { clearInterval(t); showToast('Google Picker chưa tải xong.', 'error'); resetPickerBtn(); }
                                                                                                            }, 200);
                                                                                                        } else { buildAndShowPicker(data.accessToken, data.clientId); }
                                                                                                    })
                                                                                                    .catch(function () { showToast('Không thể lấy token Drive.', 'error'); resetPickerBtn(); });
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
                                                                                                } catch (e) { showToast('Không thể mở Google Picker: ' + e.message, 'error'); }
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
                                                                                                ['courseGoogleDriveUrlManual', 'courseGoogleDriveFileIdManual', 'courseGoogleDriveFolderIdManual']
                                                                                                    .forEach(function (eid, i) { var el = document.getElementById(eid); if (el) el.value = vals[i]; });

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
                                                                                                ['courseGoogleDriveUrlHidden', 'courseGoogleDriveFileIdHidden', 'courseGoogleDriveFolderIdHidden',
                                                                                                    'courseGoogleDriveUrlManual', 'courseGoogleDriveFileIdManual', 'courseGoogleDriveFolderIdManual']
                                                                                                    .forEach(function (eid) { var el = document.getElementById(eid); if (el) el.value = ''; });
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

                                                                                            (function () {
                                                                                                var ai = document.querySelector('input[name="action"][value="registerCourse"]');
                                                                                                if (!ai) return;
                                                                                                var form = ai.closest('form');
                                                                                                if (!form) return;
                                                                                                form.addEventListener('submit', function () {
                                                                                                    var md = document.getElementById('manual-drive-inputs');
                                                                                                    if (!md || md.style.display === 'none') return;
                                                                                                    [['courseGoogleDriveUrlManual', 'courseGoogleDriveUrlHidden'],
                                                                                                    ['courseGoogleDriveFileIdManual', 'courseGoogleDriveFileIdHidden'],
                                                                                                    ['courseGoogleDriveFolderIdManual', 'courseGoogleDriveFolderIdHidden']]
                                                                                                        .forEach(function (pair) {
                                                                                                            var s = document.getElementById(pair[0]);
                                                                                                            var d = document.getElementById(pair[1]);
                                                                                                            if (s && d && s.value) d.value = s.value;
                                                                                                        });
                                                                                                });
                                                                                            })();

                                                                                            window.addEventListener('load', function () {
                                                                                                if (typeof gapi !== 'undefined') { onGapiLoad(); return; }
                                                                                                var a = 0, t = setInterval(function () {
                                                                                                    a++;
                                                                                                    if (typeof gapi !== 'undefined') { clearInterval(t); onGapiLoad(); }
                                                                                                    else if (a > 50) clearInterval(t);
                                                                                                }, 200);
                                                                                            });
                                                                                            function unlockTeachingForm() {
                                                                                                var form = document.getElementById('teacher-profile-form');
                                                                                                if (form) form.dataset.updateLocked = 'false';
                                                                                                setTeachingRegistrationLocked(false);
                                                                                                var approvedActions = document.getElementById('approved-form-actions');
                                                                                                if (approvedActions) approvedActions.classList.remove('is-hidden');
                                                                                                var helperText = document.getElementById('teacher-type-helper-text');
                                                                                                if (helperText) {
                                                                                                    helperText.textContent = 'Bạn có thể cập nhật nhóm giảng viên và thông tin xác minh bên dưới. Sau khi gửi, hồ sơ cập nhật sẽ được xét duyệt lại trước khi thay đổi có hiệu lực.';
                                                                                                }
                                                                                                var unlockBtn = document.getElementById('btn-unlock-teaching-form');
                                                                                                if (unlockBtn) {
                                                                                                    unlockBtn.style.display = 'none';
                                                                                                }
                                                                                                var formTarget = document.getElementById('teaching-registration-form-scroll-target');
                                                                                                if (formTarget) setTimeout(function () { formTarget.scrollIntoView({ behavior: 'smooth', block: 'start' }); }, 100);
                                                                                                if (typeof showToast === 'function') showToast('Hồ sơ đã được mở khóa. Chỉnh sửa và gửi lại để Staff xét duyệt.', 'info');
                                                                                            }
                                                                                            function cancelTeachingEdit() {
                                                                                                var form = document.getElementById('teacher-profile-form');
                                                                                                if (form) {
                                                                                                    form.reset();
                                                                                                    form.dataset.updateLocked = 'true';
                                                                                                }
                                                                                                setTeachingRegistrationLocked(true);
                                                                                                syncTeachingSubjectLabelStates();
                                                                                                var approvedActions = document.getElementById('approved-form-actions');
                                                                                                if (approvedActions) approvedActions.classList.add('is-hidden');
                                                                                                var helperText = document.getElementById('teacher-type-helper-text');
                                                                                                if (helperText) {
                                                                                                    helperText.textContent = form && form.dataset.defaultHelperText
                                                                                                        ? form.dataset.defaultHelperText
                                                                                                        : 'Hồ sơ của bạn đang được xét duyệt. Nhấn Cập nhật hồ sơ nếu cần chỉnh sửa hoặc bổ sung minh chứng.';
                                                                                                }
                                                                                                var unlockBtn = document.getElementById('btn-unlock-teaching-form');
                                                                                                if (unlockBtn) {
                                                                                                    unlockBtn.style.display = '';
                                                                                                }
                                                                                                window.scrollTo({ top: 0, behavior: 'smooth' });
                                                                                                if (typeof showToast === 'function') showToast('Đã hủy chỉnh sửa hồ sơ.', 'info');
                                                                                            }
                                                                                        </script>
                                                                                        <script
                                                                                            src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
                                                                                        </script>
        <script>
        // Xử lý Dark Mode Toggle
        function updateToggleIcon(isDark) {
            const moon = document.querySelector('.icon-moon');
            const sun = document.querySelector('.icon-sun');
            if (moon && sun) {
                if (isDark) {
                    // Tối -> Mặt trăng
                    sun.style.opacity = '0';
                    sun.style.transform = 'rotate(-90deg)';
                    moon.style.opacity = '1';
                    moon.style.transform = 'rotate(0deg)';
                } else {
                    // Sáng -> Mặt trời
                    sun.style.opacity = '1';
                    sun.style.transform = 'rotate(0deg)';
                    moon.style.opacity = '0';
                    moon.style.transform = 'rotate(90deg)';
                }
            }
        }

        function toggleDarkMode() {
            const isDark = document.documentElement.classList.toggle('dark-profile');
            localStorage.setItem('hipzi-student-theme', isDark ? 'dark' : 'light');
            updateToggleIcon(isDark);
        }

        // Initialize icon state on load
        document.addEventListener('DOMContentLoaded', () => {
            const isDark = document.documentElement.classList.contains('dark-profile');
            updateToggleIcon(isDark);
            if(typeof fetchStreakData === 'function') { fetchStreakData(); }
        });

        // Xử lý chuỗi thắp lửa - key localStorage theo user ID
        const STREAK_USER_ID = '<%= user != null ? user.getId() : "guest" %>';
        const STREAK_KEY = 'hipzi-streak-' + STREAK_USER_ID;

        function fetchStreakData() {
            // Ưu tiên lấy từ server (nguồn chính xác nhất)
            fetch('${pageContext.request.contextPath}/api/user/streak')
                .then(res => { if (res.ok) return res.json(); throw new Error(); })
                .then(data => {
                    if (data && !data.error) {
                        // Server trả về dữ liệu → dùng server làm nguồn gốc
                        // Đồng bộ lại vào localStorage
                        localStorage.setItem(STREAK_KEY, JSON.stringify({
                            count: data.streakCount,
                            lastDate: data.lastStreakDate || null,
                            isClaimedToday: data.isClaimedToday
                        }));
                        updateStreakUI(data.streakCount, data.isClaimedToday);
                    }
                })
                .catch(() => {
                    // Server chưa sẵn sàng → fallback về localStorage
                    const today = getTodayStr();
                    const stored = getStreakStored();
                    let streakCount = stored.count || 0;
                    let isClaimedToday = false;

                    if (stored.lastDate) {
                        const diffDays = diffInDays(stored.lastDate, today);
                        if (diffDays === 0) {
                            isClaimedToday = stored.isClaimedToday || false;
                        } else if (diffDays > 1) {
                            streakCount = 0; // Đứt chuỗi
                        }
                    }
                    updateStreakUI(streakCount, isClaimedToday);
                });
        }

        function updateStreakUI(count, isClaimed) {
            const icon = document.getElementById('streakFlameIcon');
            const text = document.getElementById('streakCountText');
            if (!icon) return;
            const path = icon.querySelector('path');
            if (text) text.innerText = count;

            if (isClaimed) {
                icon.setAttribute('stroke', '#f97316');
                icon.style.color = '#f97316';
                if (path) {
                    path.setAttribute('fill', '#f97316');
                    path.setAttribute('stroke', '#f97316');
                }
            } else {
                icon.setAttribute('stroke', '#9ca3af');
                icon.style.color = '#9ca3af';
                if (path) {
                    path.setAttribute('fill', 'none');
                    path.setAttribute('stroke', '#9ca3af');
                }
            }
        }

        let isFlipping = false;

        function handleStreakClick() {
            if (isFlipping) return; // Prevent spam clicking during animation
            
            const today = getTodayStr();
            const stored = getStreakStored();

            // Đã thắp hôm nay rồi -> Click chỉ lật qua lật lại
            if (stored.lastDate === today && stored.isClaimedToday) {
                toggleCoinFlip();
                return;
            }

            // Chưa thắp -> Thắp lửa + Lật tự động
            claimStreak();
        }

        function toggleCoinFlip() {
            const coin = document.getElementById('streakCoin');
            if (!coin) return;
            const currentRotation = coin.style.transform || 'rotateY(0deg)';
            if (currentRotation.includes('180deg')) {
                coin.style.transform = 'rotateY(0deg)';
            } else {
                coin.style.transform = 'rotateY(180deg)';
            }
        }

        function claimStreak() {
            const today = getTodayStr();
            const stored = getStreakStored();

            // Tính count mới ở client để UI phản hồi ngay
            let newCount = 1;
            if (stored.lastDate) {
                const diff = diffInDays(stored.lastDate, today);
                if (diff === 1) newCount = (stored.count || 0) + 1;
            }

            // Cập nhật localStorage tạm thời
            localStorage.setItem(STREAK_KEY, JSON.stringify({ count: newCount, lastDate: today, isClaimedToday: true }));
            updateStreakUI(newCount, true);
            
            // Bắn pháo hoa giấy chúc mừng
            fireConfetti();

            // Hiệu ứng lật 3D tự động (2s lật sang số, 2s lật về lửa)
            isFlipping = true;
            setTimeout(() => {
                const coin = document.getElementById('streakCoin');
                if (coin) coin.style.transform = 'rotateY(180deg)'; // Hiện số chuỗi
                
                setTimeout(() => {
                    if (coin) coin.style.transform = 'rotateY(0deg)'; // Hiện lại lửa
                    isFlipping = false;
                }, 2000);
            }, 2000);

            // Đồng bộ lên server → server là nguồn thật
            fetch('${pageContext.request.contextPath}/api/user/streak', { method: 'POST' })
                .then(res => { if (res.ok) return res.json(); throw new Error(); })
                .then(data => {
                    if (data && data.success) {
                        // Cập nhật lại từ server (giá trị chính xác)
                        localStorage.setItem(STREAK_KEY, JSON.stringify({
                            count: data.streakCount,
                            lastDate: today,
                            isClaimedToday: true
                        }));
                        updateStreakUI(data.streakCount, true);
                    }
                })
                .catch(() => {}); // Giữ nguyên localStorage nếu server lỗi
        }

        function getTodayStr() {
            const d = new Date();
            return d.getFullYear() + '-'
                + String(d.getMonth() + 1).padStart(2, '0') + '-'
                + String(d.getDate()).padStart(2, '0');
        }

        function getStreakStored() {
            try { return JSON.parse(localStorage.getItem(STREAK_KEY) || '{}'); }
            catch(e) { return {}; }
        }

        function diffInDays(from, to) {
            return Math.floor((new Date(to) - new Date(from)) / 86400000);

        }

        // Hàm hiệu ứng bắn giấy màu
        function fireConfetti() {
            if (typeof confetti === 'function') {
                const duration = 2000;
                const end = Date.now() + duration;

                (function frame() {
                    confetti({
                        particleCount: 5,
                        angle: 60,
                        spread: 55,
                        origin: { x: 0 },
                        colors: ['#f97316', '#fbbf24', '#ef4444']
                    });
                    confetti({
                        particleCount: 5,
                        angle: 120,
                        spread: 55,
                        origin: { x: 1 },
                        colors: ['#f97316', '#fbbf24', '#ef4444']
                    });

                    if (Date.now() < end) {
                        requestAnimationFrame(frame);
                    }
                }());
            }
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
                                                    </body>
                                                    <!-- ========================================== -->
                                                    <!-- MODAL: SCHEDULE GRID (REUSED)              -->
                                                    <!-- ========================================== -->
                                                    <div class="schedule-modal-backdrop" id="scheduleModal" onclick="closeScheduleModal(event)">
                                                        <div class="schedule-modal-box" id="scheduleModalBox" onclick="event.stopPropagation()">
                                                            <jsp:include page="/WEB-INF/views/partials/schedule-grid.jsp" />
                                                        </div>
                                                    </div>

                                                    <script>
                                                        let currentScheduleWeekOffset = 0;

                                                        function changeScheduleWeek(delta, reset = false) {
                                                            if (reset) {
                                                                currentScheduleWeekOffset = 0;
                                                            } else {
                                                                currentScheduleWeekOffset += delta;
                                                            }
                                                            
                                                            fetch('${pageContext.request.contextPath}/profile?action=getScheduleGrid&weekOffset=' + currentScheduleWeekOffset)
                                                                .then(res => res.text())
                                                                .then(html => {
                                                                    var box = document.getElementById('scheduleModalBox');
                                                                    if (box) {
                                                                        box.innerHTML = html;
                                                                    }
                                                                })
                                                                .catch(err => console.error("Error fetching schedule:", err));
                                                        }

                                                        function openScheduleModal() {
                                                            var modal = document.getElementById('scheduleModal');
                                                            if (modal) {
                                                                modal.classList.add('show');
                                                                document.body.style.overflow = 'hidden';
                                                            }
                                                        }

                                                        function closeScheduleModal(event) {
                                                            if (event && event.target !== event.currentTarget) return;
                                                            var modal = document.getElementById('scheduleModal');
                                                            if (modal) {
                                                                modal.classList.remove('show');
                                                                document.body.style.overflow = '';
                                                            }
                                                        }
                                                    </script>
</body>
</html>
