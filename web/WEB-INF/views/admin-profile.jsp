<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Role"%>
<%@page import="com.hipzi.model.Notification"%>
<%@page import="com.hipzi.model.SystemOverviewStats"%>
<%@page import="com.hipzi.model.AdminFinancialStats"%>
<%@page import="com.hipzi.model.AdminUserSummary"%>
<%@page import="com.hipzi.model.StaffUserGrowthStats"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.Course"%>
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
    StaffUserGrowthStats staffUserGrowthStats = (StaffUserGrowthStats) request.getAttribute("staffUserGrowthStats");
    if (staffUserGrowthStats == null) {
        staffUserGrowthStats = new StaffUserGrowthStats();
    }
    String staffWeeklyUserGrowthJson = staffUserGrowthJson(staffUserGrowthStats.getWeeklyPoints());
    String staffMonthlyUserGrowthJson = staffUserGrowthJson(staffUserGrowthStats.getMonthlyPoints());

    List<AdminUserSummary> managedUsers = (List<AdminUserSummary>) request.getAttribute("managedUsers");
    String searchUser = request.getAttribute("searchUser") != null ? (String) request.getAttribute("searchUser") : "";
    String userRoleParam = request.getAttribute("userRole") != null ? (String) request.getAttribute("userRole") : "ALL";
    if (userRoleParam.isEmpty()) userRoleParam = "ALL";
    String userStatusParam = request.getAttribute("userStatus") != null ? (String) request.getAttribute("userStatus") : "ALL";
    if (userStatusParam.isEmpty()) userStatusParam = "ALL";
    
    List<Classroom> managedClassrooms = (List<Classroom>) request.getAttribute("managedClassrooms");
    String classTitle = request.getAttribute("classTitle") != null ? (String) request.getAttribute("classTitle") : "";
    String classSubjectParam = request.getAttribute("classSubject") != null ? (String) request.getAttribute("classSubject") : "ALL";
    if (classSubjectParam.isEmpty()) classSubjectParam = "ALL";
    String classStatusParam = request.getAttribute("classStatus") != null ? (String) request.getAttribute("classStatus") : "ALL";
    if (classStatusParam.isEmpty()) classStatusParam = "ALL";
    List<String> classSubjects = (List<String>) request.getAttribute("classSubjects");

    List<Course> managedCourses = (List<Course>) request.getAttribute("managedCourses");
    String courseTitle = request.getAttribute("courseTitle") != null ? (String) request.getAttribute("courseTitle") : "";
    String courseSubjectParam = request.getAttribute("courseSubject") != null ? (String) request.getAttribute("courseSubject") : "ALL";
    if (courseSubjectParam.isEmpty()) courseSubjectParam = "ALL";
    String courseStatusParam = request.getAttribute("courseStatus") != null ? (String) request.getAttribute("courseStatus") : "ALL";
    if (courseStatusParam.isEmpty()) courseStatusParam = "ALL";
    List<Course> courseSubjects = (List<Course>) request.getAttribute("courseSubjects");

    String userRoleFilterLabel = "Tất cả";
    if ("teacher".equals(userRoleParam)) userRoleFilterLabel = "Giảng viên";
    else if ("student".equals(userRoleParam)) userRoleFilterLabel = "Học sinh";
    else if ("parent".equals(userRoleParam)) userRoleFilterLabel = "Phụ huynh";
    else if ("staff".equals(userRoleParam)) userRoleFilterLabel = "Nhân viên";

    String userStatusFilterLabel = "Tất cả";
    if ("active".equals(userStatusParam)) userStatusFilterLabel = "Đang hoạt động";
    else if ("disabled".equals(userStatusParam)) userStatusFilterLabel = "Bị ban";

    String classSubjectFilterLabel = "ALL".equals(classSubjectParam) ? "Tất cả môn học" : classSubjectParam;
    
    String classStatusFilterLabel = "Tất cả trạng thái";
    if ("open".equals(classStatusParam)) classStatusFilterLabel = "Đang mở";
    else if ("upcoming".equals(classStatusParam)) classStatusFilterLabel = "Sắp khai giảng";
    else if ("closed".equals(classStatusParam)) classStatusFilterLabel = "Đã đóng";

    String courseSubjectFilterLabel = "ALL".equals(courseSubjectParam) ? "Tất cả môn học" : courseSubjectParam;
    if (!"ALL".equals(courseSubjectParam) && courseSubjects != null) {
        for (Course s : courseSubjects) {
            if (s.getSubjectCode() != null && s.getSubjectCode().equals(courseSubjectParam)) {
                courseSubjectFilterLabel = s.getSubjectName();
                break;
            }
        }
    }

    String courseStatusFilterLabel = "Tất cả trạng thái";
    if ("pending_review".equals(courseStatusParam)) courseStatusFilterLabel = "Chờ duyệt";
    else if ("approved".equals(courseStatusParam)) courseStatusFilterLabel = "Đã duyệt";
    else if ("needs_revision".equals(courseStatusParam)) courseStatusFilterLabel = "Cần chỉnh sửa";
    else if ("rejected".equals(courseStatusParam)) courseStatusFilterLabel = "Từ chối";
%>
<%!
    private String staffUserGrowthJson(List<StaffUserGrowthStats.Point> points) {
        StringBuilder json = new StringBuilder("[");
        if (points != null) {
            for (int i = 0; i < points.size(); i++) {
                StaffUserGrowthStats.Point point = points.get(i);
                if (i > 0) json.append(",");
                json.append("{\"label\":\"")
                        .append(jsEscape(point.getLabel()))
                        .append("\",\"fullLabel\":\"")
                        .append(jsEscape(point.getFullLabel()))
                        .append("\",\"count\":")
                        .append(point.getCount())
                        .append(",\"countLabel\":\"")
                        .append(jsEscape(point.getCountLabel()))
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

    private String escAttr(String value) {
        if (value == null) return "";
        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private String h(String value) {
        return escAttr(value);
    }

    private String userRoleLabel(String roles) {
        if (roles == null) return "Học sinh";
        roles = roles.toLowerCase();
        if (roles.contains("admin")) return "Quản trị viên";
        if (roles.contains("staff")) return "Nhân viên";
        if (roles.contains("teacher")) return "Giảng viên";
        return "Học sinh";
    }

    private String userStatusLabel(String status) {
        if (status == null) return "Unknown";
        if (status.equalsIgnoreCase("active")) return "Đang hoạt động";
        if (status.equalsIgnoreCase("disabled") || status.equalsIgnoreCase("banned") || status.equalsIgnoreCase("suspended")) return "Bị ban";
        return status;
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/staff-user-growth-chart.css?v=1">
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

        .managed-role-pill-btn {
            border: none;
            cursor: pointer;
            transition: all 0.18s ease;
        }
        .managed-role-pill-btn:hover {
            background: #d1fae5;
            box-shadow: 0 2px 8px rgba(5,150,105,0.18);
            transform: translateY(-1px);
        }

        .role-option-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.9rem 0.5rem;
            border: 2px solid #e2e8f0;
            border-radius: 1rem;
            cursor: pointer;
            transition: all 0.18s ease;
            background: #f8fafc;
            user-select: none;
        }
        .role-option-card:hover {
            border-color: #a78bfa;
            background: #faf5ff;
        }
        .role-option-card.selected {
            border-color: #7c3aed;
            background: #ede9fe;
            box-shadow: 0 0 0 3px rgba(124,58,237,0.12);
        }
        .role-option-icon {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .role-option-label {
            font-size: 0.8rem;
            font-weight: 800;
            color: #0f172a;
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
        #tab-teacher-approval .tab-grouped-container,
        #tab-manage-teachers .tab-grouped-container,
        #tab-manage-classes .tab-grouped-container,
        #tab-manage-courses .tab-grouped-container,
        #tab-users .tab-grouped-container,
        #tab-practice .tab-grouped-container {
            background: transparent;
            border: none;
            border-radius: 0;
            box-shadow: none;
            padding: 0;
            min-height: 0;
            overflow: visible;
        }

        #tab-teacher-approval .tab-header-accent,
        #tab-manage-teachers .tab-header-accent,
        #tab-manage-classes .tab-header-accent,
        #tab-manage-courses .tab-header-accent,
        #tab-users .tab-header-accent,
        #tab-practice .tab-header-accent {
            display: flex;
            color: var(--text-main);
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 1rem;
            padding: 0 0 1rem 0;
            margin-bottom: 2rem;
            border-bottom: 1px solid var(--border-dark);
        }

        #tab-teacher-approval .tab-header-title-text,
        #tab-manage-teachers .tab-header-title-text,
        #tab-manage-classes .tab-header-title-text,
        #tab-manage-courses .tab-header-title-text,
        #tab-users .tab-header-title-text,
        #tab-practice .tab-header-title-text {
            font-size: 1.75rem;
            line-height: 1.15;
            font-weight: 800;
            letter-spacing: -0.5px;
            color: var(--text-main);
        }

        #tab-teacher-approval .tab-header-title-text::after,
        #tab-manage-teachers .tab-header-title-text::after,
        #tab-manage-classes .tab-header-title-text::after,
        #tab-manage-courses .tab-header-title-text::after,
        #tab-users .tab-header-title-text::after,
        #tab-practice .tab-header-title-text::after {
            display: block;
            margin-top: 0.35rem;
            color: #475569;
            font-size: 0.95rem;
            line-height: 1.45;
            font-weight: 600;
            letter-spacing: 0;
        }

        #tab-teacher-approval .tab-header-title-text::after {
            content: "Xét duyệt hồ sơ đăng kí giảng dạy và cập nhật trạng thái cho giảng viên.";
        }

        #tab-manage-teachers .tab-header-title-text::after {
            content: "Theo dõi danh sách giảng viên và học sinh đang sử dụng nền tảng.";
        }

        #tab-manage-classes .tab-header-title-text::after {
            content: "Quản lý các lớp học đang mở, sắp khai giảng hoặc đã đóng trên HIPZI.";
        }

        #tab-manage-courses .tab-header-title-text::after {
            content: "Rà soát khóa học, trạng thái duyệt và nội dung liên kết Google Drive.";
        }

        #tab-users .tab-header-title-text::after {
            content: "Kiểm tra hàng đợi tài liệu học tập do giảng viên gửi lên kho học liệu.";
        }

        #tab-practice .tab-header-title-text::after {
            content: "Theo dõi yêu cầu đăng kí giảng viên và các bước xác minh nghiệp vụ.";
        }

        #tab-teacher-approval .tab-header-date-pill,
        #tab-manage-teachers .tab-header-date-pill,
        #tab-manage-classes .tab-header-date-pill,
        #tab-manage-courses .tab-header-date-pill,
        #tab-users .tab-header-date-pill,
        #tab-practice .tab-header-date-pill {
            background: #ffffff;
            color: var(--text-main);
            border: 1px solid var(--border-dark);
            border-radius: 1rem;
            padding: 0.5rem 1rem;
            box-shadow: var(--shadow);
        }

        #tab-teacher-approval .tab-body-content,
        #tab-manage-teachers .tab-body-content,
        #tab-manage-classes .tab-body-content,
        #tab-manage-courses .tab-body-content,
        #tab-users .tab-body-content,
        #tab-practice .tab-body-content {
            padding: 0;
            overflow: visible;
            gap: 1.5rem;
        }

        #tab-teacher-approval .section-data-card,
        #tab-manage-teachers .section-data-card,
        #tab-manage-classes .section-data-card,
        #tab-manage-courses .section-data-card,
        #tab-users .section-data-card,
        #tab-practice .section-data-card {
            background: #ffffff;
            border: 1px solid #dbe4ee;
            border-radius: 1.25rem;
            padding: 1.65rem;
            box-shadow: 0 16px 36px rgba(15, 23, 42, 0.04);
            min-height: 420px;
        }

        #tab-teacher-approval .card-header-layout,
        #tab-manage-teachers .card-header-layout,
        #tab-manage-classes .card-header-layout,
        #tab-manage-courses .card-header-layout,
        #tab-users .card-header-layout,
        #tab-practice .card-header-layout {
            padding-bottom: 1.15rem !important;
            margin-bottom: 1.5rem !important;
            border-bottom: 1px solid #dbe4ee !important;
        }

        #tab-manage-teachers .section-data-card > form,
        #tab-manage-classes .section-data-card > form,
        #tab-manage-courses .section-data-card > form {
            background: #ffffff !important;
            border: 1px solid #dbe4ee !important;
            border-radius: 1rem !important;
            padding: 1rem !important;
            margin-bottom: 1.75rem !important;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.035);
        }

        #tab-manage-teachers .section-data-card > form.management-toolbar,
        #tab-manage-classes .section-data-card > form.management-toolbar,
        #tab-manage-courses .section-data-card > form.management-toolbar {
            background: transparent !important;
            border: none !important;
            border-radius: 0 !important;
            padding: 0 !important;
            margin: 0.9rem 0 1.35rem !important;
            box-shadow: none !important;
        }

        #tab-manage-teachers .section-data-card > form input,
        #tab-manage-teachers .section-data-card > form select,
        #tab-manage-classes .section-data-card > form input,
        #tab-manage-classes .section-data-card > form select,
        #tab-manage-courses .section-data-card > form input,
        #tab-manage-courses .section-data-card > form select {
            background: #f8fafc !important;
            border-color: #dbe4ee !important;
            border-radius: 0.85rem !important;
            min-height: 3rem;
            font-weight: 700;
        }

        #tab-manage-teachers .section-data-card > form.management-toolbar input,
        #tab-manage-teachers .section-data-card > form.management-toolbar select,
        #tab-manage-classes .section-data-card > form.management-toolbar input,
        #tab-manage-classes .section-data-card > form.management-toolbar select,
        #tab-manage-courses .section-data-card > form.management-toolbar input,
        #tab-manage-courses .section-data-card > form.management-toolbar select {
            min-height: 0 !important;
            border: 1px solid var(--border-dark) !important;
            border-radius: 999px !important;
            padding: 0.7rem 1rem !important;
            font-size: 0.88rem !important;
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.03) !important;
        }

        #tab-manage-teachers .section-data-card > form.management-toolbar input,
        #tab-manage-classes .section-data-card > form.management-toolbar input,
        #tab-manage-courses .section-data-card > form.management-toolbar input {
            background: #f8fafc !important;
            color: var(--text-main) !important;
            font-weight: 650 !important;
        }

        #tab-manage-teachers .section-data-card > form.management-toolbar select,
        #tab-manage-classes .section-data-card > form.management-toolbar select,
        #tab-manage-courses .section-data-card > form.management-toolbar select {
            appearance: none !important;
            background-color: #ffffff !important;
            background-image: linear-gradient(45deg, transparent 50%, #059669 50%), linear-gradient(135deg, #059669 50%, transparent 50%) !important;
            background-position: calc(100% - 1.25rem) 50%, calc(100% - 0.9rem) 50% !important;
            background-size: 0.45rem 0.45rem, 0.45rem 0.45rem !important;
            background-repeat: no-repeat !important;
            color: #0f172a !important;
            padding: 0.7rem 2.4rem 0.7rem 1rem !important;
            font-weight: 900 !important;
        }

        #tab-manage-teachers .section-data-card > form > button,
        #tab-manage-classes .section-data-card > form > button,
        #tab-manage-courses .section-data-card > form > button {
            background: #059669 !important;
            color: #ffffff !important;
            border: none !important;
            border-radius: 0.85rem !important;
            min-height: 3rem;
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.18);
        }

        #tab-teacher-approval .teacher-approval-grid,
        #tab-manage-teachers .teacher-approval-grid,
        #tab-manage-classes .staff-class-list,
        #tab-manage-courses .staff-class-list {
            gap: 1.15rem;
        }

        #tab-teacher-approval .teacher-approval-card,
        #tab-manage-teachers .teacher-approval-card,
        #tab-manage-classes .staff-class-card,
        #tab-manage-courses .staff-class-card {
            border: 1px solid #dbe4ee;
            border-left: 4px solid #059669;
            border-radius: 1rem;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.035);
        }

        #tab-teacher-approval .empty-status-panel,
        #tab-manage-teachers .empty-status-panel,
        #tab-manage-classes .empty-status-panel,
        #tab-manage-courses .empty-status-panel,
        #tab-users .empty-status-panel,
        #tab-practice .empty-status-panel {
            background: #ffffff;
            border: 1px dashed #dbe4ee;
            border-radius: 1.25rem;
            box-shadow: none;
        }

        #tab-teacher-approval .section-data-card {
            background: #ffffff;
            border: 1px solid #dbe4ee;
            border-radius: 1.5rem;
            padding: 1.5rem;
            min-height: 560px;
            overflow: hidden;
            box-shadow: none;
        }

        #tab-teacher-approval .section-data-card.system-management-card,
        #tab-manage-teachers .section-data-card.system-management-card,
        #tab-manage-classes .section-data-card.system-management-card,
        #tab-manage-courses .section-data-card.system-management-card {
            background: #ffffff;
            border: 1px solid #dbe4ee;
            border-radius: 1.5rem;
            padding: 1.5rem;
            min-height: 560px;
            overflow: hidden;
            box-shadow: none;
        }

        #tab-teacher-approval .card-header-layout {
            padding: 0 0 1rem 0 !important;
            margin: 0 0 1.35rem 0 !important;
            background: transparent !important;
            border-bottom: 1px solid var(--border-dark) !important;
        }

        #tab-teacher-approval .system-management-card .card-header-layout,
        #tab-manage-teachers .system-management-card .card-header-layout,
        #tab-manage-classes .system-management-card .card-header-layout,
        #tab-manage-courses .system-management-card .card-header-layout {
            padding: 0 0 1rem 0 !important;
            margin: 0 0 1.45rem 0 !important;
            background: transparent !important;
            border-bottom: 1px solid var(--border-dark) !important;
        }

        #tab-teacher-approval .card-header-title,
        #tab-manage-teachers .card-header-title,
        #tab-manage-classes .card-header-title,
        #tab-manage-courses .card-header-title {
            display: inline-flex;
            align-items: center;
            gap: 0.6rem;
            color: var(--text-main);
            font-size: 1.1rem;
            font-weight: 900;
            line-height: 1.25;
        }

        #tab-teacher-approval .card-header-title svg,
        #tab-manage-teachers .card-header-title svg,
        #tab-manage-classes .card-header-title svg,
        #tab-manage-courses .card-header-title svg {
            color: #059669;
            stroke: currentColor;
        }

        #tab-teacher-approval .card-header-layout > span,
        #tab-manage-teachers .card-header-layout > span,
        #tab-manage-classes .card-header-layout > span,
        #tab-manage-courses .card-header-layout > span {
            font-size: 0.78rem !important;
            font-weight: 850 !important;
            color: #059669 !important;
            background: #dcfce7 !important;
            padding: 0.25rem 0.75rem !important;
            border-radius: 999px !important;
        }

        .system-management-card .management-toolbar {
            display: grid !important;
            grid-template-columns: minmax(420px, calc((100% - 1rem) / 2)) 1fr 220px 220px auto;
            gap: 1rem !important;
            align-items: center;
            margin: 0.9rem 0 1.35rem !important;
            padding: 0 !important;
            background: transparent !important;
            border: none !important;
            border-radius: 0 !important;
            box-shadow: none !important;
        }

        #tab-teacher-approval .management-toolbar,
        #tab-manage-teachers .management-toolbar {
            grid-template-columns: minmax(420px, calc((100% - 1rem) / 2)) 1fr 220px 220px auto;
        }

        #tab-teacher-approval .management-toolbar select {
            grid-column: auto;
        }

        #tab-teacher-approval .management-toolbar .management-filter-dropdown {
            grid-column: 4;
        }

        #tab-manage-teachers .management-toolbar .management-filter-dropdown:first-of-type {
            grid-column: 3;
        }

        #tab-manage-teachers .management-toolbar .management-filter-dropdown:nth-of-type(2) {
            grid-column: 4;
        }

        #tab-manage-classes .management-toolbar .management-filter-dropdown:first-of-type,
        #tab-manage-courses .management-toolbar .management-filter-dropdown:first-of-type {
            grid-column: 3;
        }

        #tab-manage-classes .management-toolbar .management-filter-dropdown:nth-of-type(2),
        #tab-manage-courses .management-toolbar .management-filter-dropdown:nth-of-type(2) {
            grid-column: 4;
        }

        #tab-manage-teachers .management-toolbar > button,
        #tab-manage-classes .management-toolbar > button,
        #tab-manage-courses .management-toolbar > button {
            display: none !important;
        }

        .system-management-card .management-toolbar input,
        .system-management-card .management-toolbar select {
            width: 100% !important;
            min-height: 0 !important;
            border: 1px solid var(--border-dark) !important;
            background-color: #ffffff !important;
            color: var(--text-main) !important;
            border-radius: 999px !important;
            padding: 0.7rem 1rem !important;
            font-size: 0.88rem !important;
            font-weight: 900 !important;
            outline: none !important;
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.03) !important;
        }

        .system-management-card .management-toolbar input {
            background-color: #f8fafc !important;
            font-weight: 650 !important;
        }

        .system-management-card .management-toolbar select {
            appearance: none;
            cursor: pointer;
            color: #0f172a !important;
            padding: 0.7rem 2.4rem 0.7rem 1rem !important;
            background: #ffffff linear-gradient(45deg, transparent 50%, #059669 50%), linear-gradient(135deg, #059669 50%, transparent 50%) !important;
            background-position: calc(100% - 1.25rem) 50%, calc(100% - 0.9rem) 50%;
            background-size: 0.45rem 0.45rem, 0.45rem 0.45rem;
            background-repeat: no-repeat;
        }

        #tab-teacher-approval .system-management-card .management-toolbar select,
        #tab-manage-teachers .system-management-card .management-toolbar select,
        #tab-manage-classes .system-management-card .management-toolbar select,
        #tab-manage-courses .system-management-card .management-toolbar select {
            background: #ffffff linear-gradient(45deg, transparent 50%, #059669 50%), linear-gradient(135deg, #059669 50%, transparent 50%) !important;
            background-position: calc(100% - 1.25rem) 50%, calc(100% - 0.9rem) 50% !important;
            background-size: 0.45rem 0.45rem, 0.45rem 0.45rem !important;
            background-repeat: no-repeat !important;
            color: #0f172a !important;
            border: 1px solid var(--border-dark) !important;
            border-radius: 999px !important;
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.03) !important;
        }

        .management-filter-select-wrap {
            position: relative;
            min-width: 190px;
            width: 100%;
        }

        .management-filter-select-wrap::after {
            content: "";
            position: absolute;
            right: 1rem;
            top: 50%;
            width: 0.55rem;
            height: 0.55rem;
            border-right: 2px solid #059669;
            border-bottom: 2px solid #059669;
            transform: translateY(-65%) rotate(45deg);
            pointer-events: none;
        }

        .system-management-card .management-toolbar .management-filter-select {
            width: 100% !important;
            appearance: none !important;
            border: 1px solid var(--border-dark) !important;
            background: #ffffff !important;
            color: #0f172a !important;
            border-radius: 999px !important;
            padding: 0.7rem 2.4rem 0.7rem 1rem !important;
            font-size: 0.88rem !important;
            font-weight: 900 !important;
            cursor: pointer !important;
            outline: none !important;
            box-shadow: 0 8px 20px rgba(15, 23, 42, 0.04) !important;
        }

        .system-management-card .management-toolbar .management-filter-select:focus {
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12) !important;
        }

        .system-management-card .management-toolbar .management-filter-select option {
            background: #ffffff !important;
            color: #475569 !important;
            font-weight: 700 !important;
        }

        .management-filter-dropdown {
            position: relative;
            min-width: 220px;
            width: 100%;
        }

        .management-filter-trigger {
            width: 100%;
            min-height: 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.9rem;
            border: 1px solid #99f6e4;
            background: #ffffff;
            color: #334155;
            border-radius: 0.9rem;
            padding: 0.7rem 0.9rem 0.7rem 1rem;
            font-size: 0.88rem;
            font-weight: 700;
            cursor: pointer;
            outline: none;
            box-shadow: 0 8px 20px rgba(5, 150, 105, 0.06);
            white-space: nowrap;
            transition: border-color 180ms ease, box-shadow 180ms ease, background-color 180ms ease, color 180ms ease;
        }

        .management-filter-trigger svg {
            flex: 0 0 auto;
            color: #059669;
        }

        .management-filter-label {
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .management-filter-dropdown.is-open .management-filter-trigger,
        .management-filter-trigger:focus {
            border-color: #10b981;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
        }

        .management-filter-menu {
            position: absolute;
            top: calc(100% + 0.55rem);
            right: 0;
            z-index: 40;
            display: grid;
            gap: 0.2rem;
            width: 100%;
            min-width: 100%;
            padding: 0.45rem;
            border: 1px solid #ccfbf1;
            border-radius: 0.9rem;
            background: #ffffff;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
            transform: translateY(-0.35rem) scale(0.98);
            transform-origin: top right;
            transition: opacity 170ms ease, transform 170ms cubic-bezier(0.16, 1, 0.3, 1), visibility 0s linear 170ms;
        }

        .management-filter-dropdown.is-open .management-filter-menu {
            opacity: 1;
            visibility: visible;
            pointer-events: auto;
            transform: translateY(0) scale(1);
            transition-delay: 0s;
        }

        .management-filter-option {
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.8rem;
            border: 0;
            background: transparent;
            color: #475569;
            border-radius: 0.65rem;
            padding: 0.58rem 0.7rem;
            font-size: 0.86rem;
            font-weight: 700;
            text-align: left;
            cursor: pointer;
            white-space: nowrap;
            box-sizing: border-box;
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            transition: background-color 150ms ease, color 150ms ease;
        }

        .management-filter-option:hover,
        .management-filter-option.is-selected {
            background: #dff8ee;
            color: #059669;
        }

        .management-filter-check {
            color: #059669;
            font-weight: 800;
            opacity: 0;
            transition: opacity 140ms ease;
        }

        .management-filter-option.is-selected .management-filter-check {
            opacity: 1;
        }

        .system-management-card .management-toolbar input:focus,
        .system-management-card .management-toolbar select:focus {
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12) !important;
        }

        .system-management-card .management-toolbar > button {
            min-height: 0 !important;
            border-radius: 999px !important;
            background: #059669 !important;
            color: #ffffff !important;
            border: none !important;
            padding: 0.7rem 1.35rem !important;
            font-size: 0.88rem !important;
            font-weight: 900 !important;
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.16) !important;
            white-space: nowrap;
        }

        #tab-teacher-approval .teacher-approval-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
            padding-top: 0.45rem !important;
        }

        #tab-manage-teachers .teacher-approval-grid,
        #tab-manage-classes .staff-class-list,
        #tab-manage-courses .staff-class-list {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
        }

        #tab-teacher-approval .teacher-approval-card {
            border: 1px solid #e2e8f0;
            border-left: 4px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1rem;
            background: #ffffff;
            cursor: pointer;
            box-shadow: 0 10px 20px rgba(15, 23, 42, 0.04);
            transition: border-color 0.18s ease, border-left-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background-color 0.18s ease;
        }

        #tab-teacher-approval .teacher-approval-card:hover,
        #tab-teacher-approval .teacher-approval-card:focus-visible {
            border-color: #86efac;
            border-left-color: #059669;
            box-shadow: 0 18px 36px rgba(5, 150, 105, 0.14);
            transform: translateY(-2px);
            background: #f0fdf4;
            outline: none;
        }

        #tab-teacher-approval .teacher-application-summary {
            display: block;
            min-width: 0;
            margin: -1rem;
            padding: 1rem;
            border-radius: inherit;
            outline: none;
        }

        #tab-teacher-approval .teacher-application-summary:focus-visible {
            outline: none;
        }

        #tab-teacher-approval .teacher-application-summary-top {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            align-items: flex-start;
        }

        #tab-teacher-approval .teacher-application-summary-identity {
            min-width: 0;
        }

        #tab-teacher-approval .teacher-application-summary-line {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            min-width: 0;
        }

        #tab-teacher-approval .teacher-application-summary-avatar {
            width: 2rem;
            height: 2rem;
            border-radius: 999px;
            flex: 0 0 2rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #dcfce7;
            color: #047857;
            border: 1px solid #bbf7d0;
            font-size: 0.78rem;
            font-weight: 900;
            overflow: hidden;
            box-shadow: 0 8px 18px rgba(5, 150, 105, 0.08);
        }

        #tab-teacher-approval .teacher-application-summary-name {
            min-width: 0;
            color: #334155;
            font-weight: 850;
            font-size: 0.82rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        #tab-teacher-approval .teacher-application-summary-title {
            display: block;
            color: #0f172a;
            font-weight: 900;
            font-size: 0.98rem;
            margin-top: 0.55rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        #tab-teacher-approval .teacher-application-summary-bottom {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
            margin-top: 0.8rem;
        }

        #tab-teacher-approval .teacher-application-summary-role {
            color: #334155;
            font-size: 0.78rem;
            font-weight: 850;
        }

        #tab-teacher-approval .teacher-application-summary-date {
            color: #64748b;
            font-size: 0.72rem;
            font-weight: 850;
            text-align: right;
            line-height: 1.25;
        }

        #tab-manage-teachers .teacher-approval-card,
        #tab-manage-classes .staff-class-card,
        #tab-manage-courses .staff-class-card {
            border: 1px solid #dbe4ee !important;
            border-left: 4px solid #e2e8f0 !important;
            border-radius: 1rem !important;
            padding: 1.35rem !important;
            background: #ffffff !important;
            box-shadow: 0 10px 20px rgba(15, 23, 42, 0.04) !important;
            transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background-color 0.18s ease;
        }

        #tab-manage-teachers .teacher-approval-card:hover,
        #tab-manage-classes .staff-class-card:hover,
        #tab-manage-courses .staff-class-card:hover {
            border-color: #86efac !important;
            border-left-color: #059669 !important;
            box-shadow: 0 18px 36px rgba(5, 150, 105, 0.12) !important;
            transform: translateY(-2px);
            background: #f0fdf4 !important;
        }

        #tab-manage-courses .staff-class-card {
            cursor: pointer;
            max-width: 680px;
        }

        #tab-manage-teachers .user-management-table {
            width: 100%;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            overflow: hidden;
            background: #ffffff;
            box-shadow: 0 10px 22px rgba(15, 23, 42, 0.035);
        }

        #tab-manage-teachers .user-management-row {
            display: grid;
            grid-template-columns: minmax(260px, 1.7fr) 0.9fr 0.9fr 0.75fr;
            gap: 1rem;
            align-items: center;
            padding: 0.85rem 1rem;
            border-bottom: 1px solid #eef2f7;
        }

        #tab-manage-teachers .user-management-row:last-child {
            border-bottom: 0;
        }

        #tab-manage-teachers .user-management-head {
            background: #f8fafc;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.02em;
        }

        #tab-manage-teachers .user-management-item {
            transition: background-color 0.16s ease, box-shadow 0.16s ease;
        }

        #tab-manage-teachers .user-management-item:hover {
            background: #f0fdf4;
            box-shadow: inset 4px 0 0 #059669;
        }

        #tab-manage-teachers .user-management-main {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-width: 0;
        }

        #tab-manage-teachers .user-management-avatar {
            width: 2.2rem;
            height: 2.2rem;
            border-radius: 0.55rem;
            flex: 0 0 2.2rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #dcfce7;
            color: #047857;
            border: 1px solid #bbf7d0;
            font-size: 0.82rem;
            font-weight: 900;
        }

        #tab-manage-teachers .user-management-name {
            display: block;
            color: #0f172a;
            font-size: 0.9rem;
            font-weight: 900;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        #tab-manage-teachers .user-management-email {
            display: block;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 700;
            margin-top: 0.12rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        #tab-manage-teachers .user-management-cell {
            color: #334155;
            font-size: 0.82rem;
            font-weight: 800;
            min-width: 0;
        }

        #tab-manage-teachers .user-management-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            padding: 0.22rem 0.7rem;
            font-size: 0.72rem;
            font-weight: 900;
            white-space: nowrap;
        }

        #tab-manage-teachers .user-management-pill.active {
            background: #dcfce7;
            color: #047857;
        }

        #tab-manage-teachers .user-management-pill.disabled {
            background: #fee2e2;
            color: #dc2626;
        }

        @media (max-width: 900px) {
            #tab-teacher-approval .teacher-approval-grid,
            #tab-manage-teachers .teacher-approval-grid,
            #tab-manage-classes .staff-class-list,
            #tab-manage-courses .staff-class-list {
                grid-template-columns: 1fr;
            }

            #tab-manage-teachers .user-management-row {
                grid-template-columns: 1fr;
                gap: 0.55rem;
            }

            #tab-manage-teachers .user-management-head {
                display: none;
            }

            .system-management-card .management-toolbar,
            #tab-teacher-approval .management-toolbar,
            #tab-manage-teachers .management-toolbar {
                grid-template-columns: 1fr;
            }

            #tab-teacher-approval .management-toolbar select,
            #tab-manage-teachers .management-toolbar select,
            #tab-manage-classes .management-toolbar select,
            #tab-manage-courses .management-toolbar select,
            #tab-teacher-approval .management-toolbar .management-filter-dropdown,
            #tab-manage-teachers .management-toolbar .management-filter-dropdown,
            #tab-manage-classes .management-toolbar .management-filter-dropdown,
            #tab-manage-courses .management-toolbar .management-filter-dropdown,
            #tab-teacher-approval .management-toolbar .support-filter-select-wrap,
            #tab-manage-teachers .management-toolbar .support-filter-select-wrap,
            #tab-manage-classes .management-toolbar .support-filter-select-wrap,
            #tab-manage-courses .management-toolbar .support-filter-select-wrap,
            #tab-manage-teachers .management-toolbar > button,
            #tab-manage-classes .management-toolbar > button,
            #tab-manage-courses .management-toolbar > button {
                grid-column: auto;
            }
        }

        .class-detail-modal {
            position: fixed;
            inset: 0;
            z-index: 9998;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.25rem;
            background: rgba(15, 23, 42, 0.45);
            backdrop-filter: blur(4px);
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
            transition: opacity 180ms ease, visibility 0s linear 180ms;
        }

        .class-detail-modal.active {
            opacity: 1;
            visibility: visible;
            pointer-events: auto;
            transition-delay: 0s;
        }

        .class-detail-modal-card {
            width: min(100%, 680px);
            max-height: calc(100vh - 2.5rem);
            overflow: auto;
            border: 1px solid #dbe4ee;
            border-left: 4px solid #059669;
            border-radius: 1rem;
            background: #ffffff;
            padding: 1.35rem;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.2);
            transform: translateY(0.6rem) scale(0.98);
            transition: transform 180ms cubic-bezier(0.16, 1, 0.3, 1);
        }

        .class-detail-modal.active .class-detail-modal-card {
            transform: translateY(0) scale(1);
        }

        .class-detail-actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            margin-top: 1.1rem;
            padding-top: 1rem;
            border-top: 1px solid #eef2f7;
        }

        .class-detail-cancel,
        .class-detail-delete {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            min-height: 2.75rem;
            border-radius: 0.8rem;
            padding: 0 1.15rem;
            font-weight: 850;
            cursor: pointer;
            background: #ffffff;
        }

        .class-detail-cancel {
            border: 1px solid #cbd5e1;
            color: #0f172a;
        }

        .class-detail-delete {
            border: 1px solid #fecaca;
            color: #dc2626;
        }

        .class-detail-cancel:hover {
            background: #f8fafc;
        }

        .class-detail-delete:hover {
            background: #fef2f2;
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
        
        AdminFinancialStats financialOverview = (AdminFinancialStats) request.getAttribute("financialOverview");
        if (financialOverview == null) {
            financialOverview = new AdminFinancialStats();
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
                !activeAdminTab.equals("tab-users") &&
                !activeAdminTab.equals("tab-manage-classes") &&
                !activeAdminTab.equals("tab-manage-courses") &&
                !activeAdminTab.equals("tab-revenue") &&
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
                <%= "tab-users".equals(activeAdminTab) ? "Quản lý người dùng" :
                    "tab-manage-classes".equals(activeAdminTab) ? "Quản lý lớp học" :
                    "tab-manage-courses".equals(activeAdminTab) ? "Quản lý khóa học" :
                    "tab-revenue".equals(activeAdminTab) ? "Thống kê tiền" :
                    "tab-edit".equals(activeAdminTab) ? "Cập nhật thông tin" :
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
                        <a id="nav-tab-users" class="<%= "tab-users".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-users')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-8 0v2"/><circle cx="12" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M2 21v-2a4 4 0 0 1 3-3.87"/></svg>
                                <span>Quản lý người dùng</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-manage-classes" class="<%= "tab-manage-classes".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-manage-classes')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                                <span>Quản lý lớp học</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-manage-courses" class="<%= "tab-manage-courses".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-manage-courses')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 6.5v12"/><path d="M5 8.5c2.6 0 4.9.5 7 2 2.1-1.5 4.4-2 7-2v11c-2.6 0-4.9.5-7 2-2.1-1.5-4.4-2-7-2z"/></svg>
                                <span>Quản lý khóa học</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>
                    <li>
                        <a id="nav-tab-revenue" class="<%= "tab-revenue".equals(activeAdminTab) ? "active" : "" %>" onclick="switchTab('tab-revenue')">
                            <div class="menu-label-group">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><circle cx="12" cy="14.5" r="2.2"/></svg>
                                <span>Thống kê tiền</span>
                            </div>
                            <span class="menu-indicator">&rarr;</span>
                        </a>
                    </li>                    <li>
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
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng khóa học</div>
                                    <div class="system-metric-value"><%= numberFmt.format(systemOverview.getTotalCourses()) %></div>
                                </div>
                                <div class="system-metric-note">Các khóa học đang có trên hệ thống</div>
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
                        <div class="overview-chart-card" style="margin-top: 1.5rem;">
                            <div class="overview-chart-head">
                                <div class="overview-chart-title-block">
                                    <h2 class="overview-chart-title">Tăng trưởng người dùng</h2>
                                    <div class="overview-chart-summary" aria-label="Tổng quan tăng trưởng người dùng">
                                        <span class="overview-summary-pill taught">
                                            <strong id="staffUserGrowthTotal"><%= staffUserGrowthStats.getWeeklyTotal() %></strong>
                                            <span>người dùng mới</span>
                                        </span>
                                        <span class="overview-summary-pill trend">
                                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="margin-right: -0.2rem;">
                                                <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
                                                <polyline points="17 6 23 6 23 12"></polyline>
                                            </svg>
                                            <strong id="staffUserGrowthTrend"><%= staffUserGrowthStats.getTrendPercentLabel() %></strong>
                                            <span>so với tuần trước</span>
                                        </span>
                                    </div>
                                </div>
                                <div class="overview-period-switch" id="staffUserGrowthPeriodSwitch" data-active="week" aria-label="Chọn khoảng thời gian biểu đồ người dùng">
                                    <button type="button" class="overview-period-btn is-active" data-period="week" aria-pressed="true">Tuần</button>
                                    <button type="button" class="overview-period-btn" data-period="month" aria-pressed="false">Tháng</button>
                                </div>
                            </div>
        
                            <div class="overview-line-wrap" id="staffUserGrowthLineWrap">
                                <svg id="staffUserGrowthChart" class="overview-line-chart" viewBox="0 0 640 214" role="img" aria-label="Biểu đồ tăng trưởng người dùng">
                                    <defs>
                                        <linearGradient id="staffUserGrowthFill" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stop-color="#059669" stop-opacity="0.18" />
                                            <stop offset="100%" stop-color="#059669" stop-opacity="0" />
                                        </linearGradient>
                                    </defs>
                                    <line x1="52" y1="24" x2="610" y2="24" stroke="#e2e8f0" stroke-width="1" />
                                    <line x1="52" y1="70" x2="610" y2="70" stroke="#e2e8f0" stroke-width="1" />
                                    <line x1="52" y1="116" x2="610" y2="116" stroke="#e2e8f0" stroke-width="1" />
                                    <line x1="52" y1="162" x2="610" y2="162" stroke="#e2e8f0" stroke-width="1" />
        
                                    <text id="staffUserGrowthY4" x="4" y="28">3</text>
                                    <text id="staffUserGrowthY3" x="4" y="74">2</text>
                                    <text id="staffUserGrowthY2" x="4" y="120">1</text>
                                    <text id="staffUserGrowthY1" x="4" y="166">0</text>
        
                                    <path id="staffUserGrowthArea" d="M64 162 L610 162 L610 162 L64 162 Z" fill="url(#staffUserGrowthFill)" />
                                    <path id="staffUserGrowthLine" d="M64 162 L610 162" fill="none" stroke="#059669" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" />
                                    <line id="staffUserGrowthGuideLine" x1="610" y1="34" x2="610" y2="174" stroke="#cbd5e1" stroke-width="1.5" stroke-dasharray="4 6" />
                                    <circle id="staffUserGrowthDot" cx="610" cy="162" r="5" fill="#059669" stroke="#ffffff" stroke-width="3" />
        
                                    <text id="staffUserGrowthTick1" x="58" y="202"></text>
                                    <text id="staffUserGrowthTick2" x="150" y="202"></text>
                                    <text id="staffUserGrowthTick3" x="240" y="202"></text>
                                    <text id="staffUserGrowthTick4" x="332" y="202"></text>
                                    <text id="staffUserGrowthTick5" x="424" y="202"></text>
                                    <text id="staffUserGrowthTick6" x="516" y="202"></text>
                                    <text id="staffUserGrowthTick7" x="586" y="202"></text>
                                </svg>
        
                                <div class="overview-line-tooltip" id="staffUserGrowthTooltip">
                                    <strong id="staffUserGrowthTooltipDate"></strong>
                                    <div class="overview-tooltip-row">
                                        <span class="overview-tooltip-label"><span class="overview-tooltip-dot" style="background:#059669;"></span>Đăng ký mới</span>
                                        <span id="staffUserGrowthTooltipValue">0 tài khoản</span>
                                    </div>
                                </div>
                            </div>
        
                            <div class="overview-chart-legend">
                                <span class="overview-legend-item"><span class="overview-legend-dot" style="background:#059669;"></span>Người dùng mới</span>
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

            <!-- ========================================== -->
            <!-- TAB 4: TÀI LIỆU ĐÃ LƯU                     -->
            <!-- ========================================== -->
            <section id="tab-users" class="tab-pane <%= "tab-users".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Quản lý người dùng</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    <span>Danh sách người dùng</span>
                                </div>
                                <span style="font-size:0.82rem; font-weight:800; color:#059669; background:#ecfdf5; padding:0.4rem 1rem; border-radius:999px;"><%= numberFmt.format(adminUserTotalCount) %> người dùng</span>
                            </div>
                            
                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/admin-profile" style="display: grid; grid-template-columns: minmax(200px, 1fr) auto auto auto; gap: 1rem; align-items: center; margin-top: 1.5rem; margin-bottom: 1.5rem; background: #f8fafc; padding: 1rem; border-radius: 0.75rem; border: 1px solid #e2e8f0;">
                                <input type="hidden" name="tab" value="users">
                                <input type="text" name="searchUser" value="<%= h(searchUser) %>" placeholder="Tìm tên hoặc email người dùng..." style="flex: 1; min-width: 200px; padding: 0.6rem 1rem; border: 1px solid #cbd5e1; border-radius: 0.5rem; outline: none; font-size: 0.9rem;">
                                <input id="admin-user-role-filter" type="hidden" name="userRole" value="<%= h(userRoleParam) %>">
                                <div class="management-filter-dropdown" data-target-input="admin-user-role-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(userRoleFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(userRoleParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "teacher".equals(userRoleParam) ? "is-selected" : "" %>" data-value="teacher">Giảng viên <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "student".equals(userRoleParam) ? "is-selected" : "" %>" data-value="student">Học sinh <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "parent".equals(userRoleParam) ? "is-selected" : "" %>" data-value="parent">Phụ huynh <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "staff".equals(userRoleParam) ? "is-selected" : "" %>" data-value="staff">Nhân viên <span class="management-filter-check">&#10003;</span></button>
                                    </div>
                                </div>
                                <input id="admin-user-status-filter" type="hidden" name="userStatus" value="<%= h(userStatusParam) %>">
                                <div class="management-filter-dropdown" data-target-input="admin-user-status-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(userStatusFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(userStatusParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "active".equals(userStatusParam) ? "is-selected" : "" %>" data-value="active">Đang hoạt động <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "disabled".equals(userStatusParam) ? "is-selected" : "" %>" data-value="disabled">Bị ban <span class="management-filter-check">&#10003;</span></button>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary" style="padding: 0.6rem 1.25rem; border-radius: 0.5rem; font-weight: 700;">Lọc kết quả</button>
                            </form>
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
                                            <td>
                                                <button type="button"
                                                        class="managed-role-pill managed-role-pill-btn"
                                                        data-userid="<%= managedUser.getId() %>"
                                                        data-current-role="<%= managedRoles %>"
                                                        data-name="<%= escAttr(managedName) %>"
                                                        onclick="openChangeRoleModal(this)"
                                                        title="Nhấn để đổi vai trò"
                                                        aria-label="Đổi vai trò người dùng">
                                                    <%= managedRoles %>
                                                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="margin-left:4px;opacity:0.6;"><polyline points="6 9 12 15 18 9"/></svg>
                                                </button>
                                            </td>
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
                                                    <% if ("active".equalsIgnoreCase(managedStatus)) { %>
                                                        <form action="${pageContext.request.contextPath}/admin-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn khóa tài khoản này?');" style="margin:0;">
                                                            <input type="hidden" name="action" value="banUser">
                                                            <input type="hidden" name="targetUserId" value="<%= managedUser.getId() %>">
                                                            <input type="hidden" name="userPage" value="<%= adminUserPage %>">
                                                            <button type="submit"
                                                                    class="table-action-btn ban"
                                                                    title="Ban tài khoản"
                                                                    aria-label="Ban tài khoản người dùng">
                                                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                                                            </button>
                                                        </form>
                                                    <% } else { %>
                                                        <form action="${pageContext.request.contextPath}/admin-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn mở khóa tài khoản này?');" style="margin:0;">
                                                            <input type="hidden" name="action" value="unbanUser">
                                                            <input type="hidden" name="targetUserId" value="<%= managedUser.getId() %>">
                                                            <input type="hidden" name="userPage" value="<%= adminUserPage %>">
                                                            <button type="submit"
                                                                    class="table-action-btn"
                                                                    style="color: #059669; background: #ecfdf5; border: none; padding: 0.5rem; border-radius: 0.5rem; cursor: pointer; transition: all 0.2s ease;"
                                                                    title="Mở khóa tài khoản"
                                                                    aria-label="Mở khóa tài khoản người dùng"
                                                                    onmouseover="this.style.background='#d1fae5';"
                                                                    onmouseout="this.style.background='#ecfdf5';">
                                                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>
                                                            </button>
                                                        </form>
                                                    <% } %>
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
                                        <a class="admin-page-link <%= p == adminUserPage ? "active" : "" %>" href="${pageContext.request.contextPath}/admin-profile?tab=users&userPage=<%= p %>"><%= p %></a>
                                    <% } %>
                                </div>
                            </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: QUẢN LÝ NGƯỜI DÙNG                   -->
            <!-- ========================================== -->

            <!-- ========================================== -->
            <!-- TAB: QUẢN LÝ LỚP HỌC (MOCKUP)             -->
            <!-- ========================================== -->
            <section id="tab-manage-classes" class="tab-pane <%= "tab-manage-classes".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Quản lý lớp học</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                    <div class="tab-body-content">
                        <div class="section-data-card system-management-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                                    <span>Danh sách lớp học</span>
                                </div>
                                <span><%= managedClassrooms != null ? managedClassrooms.size() : 0 %> lớp học</span>
                            </div>

                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/admin-profile" style="display:flex; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap; background:#f8fafc; padding:1rem; border-radius:0.75rem; border:1px solid #e2e8f0;">
                                <input type="hidden" name="tab" value="manage-classes">
                                <input type="text" name="classTitle" value="<%= h(classTitle) %>" placeholder="Tìm tên lớp học..." style="flex:1; min-width:220px; padding:0.6rem 1rem; border:1px solid #cbd5e1; border-radius:0.5rem; outline:none; font-size:0.9rem;">
                                <input id="class-subject-filter" type="hidden" name="classSubject" value="<%= h(classSubjectParam) %>">
                                <div class="management-filter-dropdown" data-target-input="class-subject-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(classSubjectFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(classSubjectParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả môn học <span class="management-filter-check">&#10003;</span></button>
                                        <% if (classSubjects != null) {
                                            for (String subject : classSubjects) { %>
                                                <button type="button" class="management-filter-option <%= subject.equals(classSubjectParam) ? "is-selected" : "" %>" data-value="<%= h(subject) %>"><%= h(subject) %> <span class="management-filter-check">&#10003;</span></button>
                                        <%  }
                                        } %>
                                    </div>
                                </div>
                                <input id="class-status-filter" type="hidden" name="classStatus" value="<%= h(classStatusParam) %>">
                                <div class="management-filter-dropdown" data-target-input="class-status-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(classStatusFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(classStatusParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả trạng thái <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "open".equals(classStatusParam) ? "is-selected" : "" %>" data-value="open">Đang mở <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "upcoming".equals(classStatusParam) ? "is-selected" : "" %>" data-value="upcoming">Sắp khai giảng <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "closed".equals(classStatusParam) ? "is-selected" : "" %>" data-value="closed">Đã đóng <span class="management-filter-check">&#10003;</span></button>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary" style="padding:0.6rem 1.25rem; border-radius:0.5rem; font-weight:700;">Lọc lớp học</button>
                            </form>

                            <% if (managedClassrooms != null && !managedClassrooms.isEmpty()) { %>
                                <div class="staff-class-list">
                                    <% for (Classroom cls : managedClassrooms) { %>
                                        <%
                                            String classModalId = "class-detail-modal-" + cls.getId();
                                        %>
                                        <div class="staff-class-card"
                                             role="button"
                                             tabindex="0"
                                             onclick="openClassDetailModal('<%= h(classModalId) %>')"
                                             onkeydown="if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); openClassDetailModal('<%= h(classModalId) %>'); }">
                                            <div style="min-width:0;">
                                                <h3 class="staff-class-title"><%= h(cls.getTitle()) %></h3>
                                                <div style="display:flex; gap:1rem; flex-wrap:wrap; color:var(--text-muted); font-size:0.86rem; font-weight:650;">
                                                    <span>Giảng viên: <strong style="color:var(--text-main);"><%= h(cls.getTeacherName()) %></strong></span>
                                                </div>
                                            </div>
                                            <span class="class-status-pill <%= h(cls.getStatus()) %>"><%= h(cls.getStatusLabel()) %></span>
                                        </div>
                                        <div id="<%= h(classModalId) %>" class="class-detail-modal" onclick="closeClassDetailModalOnBackdrop(event, this)">
                                            <div class="class-detail-modal-card" role="dialog" aria-modal="true" aria-labelledby="class-detail-title-<%= h(cls.getId()) %>">
                                                <h3 id="class-detail-title-<%= h(cls.getId()) %>" class="staff-class-title"><%= h(cls.getTitle()) %></h3>
                                                <div class="teacher-approval-meta-grid" style="margin-top:1rem;">
                                                    <div class="teacher-approval-meta">
                                                        <span>Môn học</span>
                                                        <strong><%= h(cls.getSubject()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Lớp</span>
                                                        <strong><%= h(cls.getGrade() != null && !cls.getGrade().isEmpty() ? cls.getGrade() : "Chưa cập nhật") %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Giảng viên</span>
                                                        <strong><%= h(cls.getTeacherName()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Lịch học</span>
                                                        <strong><%= h(cls.getSchedule()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Sĩ số</span>
                                                        <strong><%= cls.getStudentCount() %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Mã lớp</span>
                                                        <strong><%= h(cls.getClassCode()) %></strong>
                                                    </div>
                                                </div>
                                                <% if (cls.getDescription() != null && !cls.getDescription().trim().isEmpty()) { %>
                                                    <div class="teacher-approval-note" style="margin-top:1rem;">
                                                        <span>Mô tả</span>
                                                        <p><%= h(cls.getDescription()) %></p>
                                                    </div>
                                                <% } %>
                                                <div class="class-detail-actions">
                                                    <button type="button" class="class-detail-cancel" onclick="closeClassDetailModal('<%= h(classModalId) %>')">Hủy bỏ</button>
                                                    <form action="${pageContext.request.contextPath}/admin-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa lớp học này khỏi hệ thống?');">
                                                        <input type="hidden" name="action" value="deleteManagedClass">
                                                        <input type="hidden" name="classId" value="<%= h(cls.getId()) %>">
                                                        <button type="submit" class="class-detail-delete" title="Xóa lớp học">
                                                            <span>Xóa</span>
                                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="empty-status-panel" style="padding:4rem 2rem;">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                    <span style="font-weight:700; color:var(--text-main);">Không tìm thấy lớp học</span>
                                    <p style="font-size:0.85rem; max-width:420px; margin:0;">Không có lớp học phù hợp với bộ lọc hiện tại.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>

            <section id="tab-manage-courses" class="tab-pane <%= "tab-manage-courses".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Quản lý khóa học</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                    <div class="tab-body-content">
                        <div class="section-data-card system-management-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 6.5v12"/><path d="M5 8.5c2.6 0 4.9.5 7 2 2.1-1.5 4.4-2 7-2v11c-2.6 0-4.9.5-7 2-2.1-1.5-4.4-2-7-2z"/></svg>
                                    <span>Danh sách khóa học</span>
                                </div>
                                <span><%= managedCourses != null ? managedCourses.size() : 0 %> khóa học</span>
                            </div>

                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/admin-profile" style="display:flex; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap; background:#f8fafc; padding:1rem; border-radius:0.75rem; border:1px solid #e2e8f0;">
                                <input type="hidden" name="tab" value="manage-courses">
                                <input type="text" name="courseTitle" value="<%= h(courseTitle) %>" placeholder="Tìm tên khóa học hoặc giảng viên..." style="flex:1; min-width:220px; padding:0.6rem 1rem; border:1px solid #cbd5e1; border-radius:0.5rem; outline:none; font-size:0.9rem;">
                                <input id="course-subject-filter" type="hidden" name="courseSubject" value="<%= h(courseSubjectParam) %>">
                                <div class="management-filter-dropdown" data-target-input="course-subject-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(courseSubjectFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(courseSubjectParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả môn học <span class="management-filter-check">&#10003;</span></button>
                                        <% if (courseSubjects != null) {
                                            for (Course subject : courseSubjects) { %>
                                                <button type="button" class="management-filter-option <%= subject.getSubjectCode() != null && subject.getSubjectCode().equals(courseSubjectParam) ? "is-selected" : "" %>" data-value="<%= h(subject.getSubjectCode()) %>"><%= h(subject.getSubjectName()) %> <span class="management-filter-check">&#10003;</span></button>
                                        <%  }
                                        } %>
                                    </div>
                                </div>
                                <input id="course-status-filter" type="hidden" name="courseStatus" value="<%= h(courseStatusParam) %>">
                                <div class="management-filter-dropdown" data-target-input="course-status-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(courseStatusFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(courseStatusParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả trạng thái <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "pending_review".equals(courseStatusParam) ? "is-selected" : "" %>" data-value="pending_review">Chờ duyệt <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "approved".equals(courseStatusParam) ? "is-selected" : "" %>" data-value="approved">Đã duyệt <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "needs_revision".equals(courseStatusParam) ? "is-selected" : "" %>" data-value="needs_revision">Cần chỉnh sửa <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "rejected".equals(courseStatusParam) ? "is-selected" : "" %>" data-value="rejected">Từ chối <span class="management-filter-check">&#10003;</span></button>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary" style="padding:0.6rem 1.25rem; border-radius:0.5rem; font-weight:700;">Lọc khóa học</button>
                            </form>

                            <% if (managedCourses != null && !managedCourses.isEmpty()) { %>
                                <div class="staff-class-list">
                                    <% for (Course course : managedCourses) {
                                        String courseStatus = course.getStatus() != null ? course.getStatus() : "pending_review";
                                        String statusBg = "approved".equals(courseStatus) ? "#dcfce7" : ("rejected".equals(courseStatus) ? "#fee2e2" : ("needs_revision".equals(courseStatus) ? "#ffedd5" : "#fef9c3"));
                                        String statusColor = "approved".equals(courseStatus) ? "#15803d" : ("rejected".equals(courseStatus) ? "#b91c1c" : ("needs_revision".equals(courseStatus) ? "#c2410c" : "#a16207"));
                                        String courseModalId = "course-detail-modal-" + course.getId();
                                    %>
                                        <div class="staff-class-card"
                                             role="button"
                                             tabindex="0"
                                             onclick="openClassDetailModal('<%= h(courseModalId) %>')"
                                             onkeydown="if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); openClassDetailModal('<%= h(courseModalId) %>'); }">
                                            <div style="min-width:0;">
                                                <h3 class="staff-class-title"><%= h(course.getTitle()) %></h3>
                                                <div style="display:flex; gap:1rem; flex-wrap:wrap; color:var(--text-muted); font-size:0.86rem; font-weight:650;">
                                                    <span>Giảng viên: <strong style="color:var(--text-main);"><%= h(course.getTeacherName()) %></strong></span>
                                                </div>
                                            </div>
                                            <span style="font-size:0.75rem; font-weight:800; color:<%= statusColor %>; background:<%= statusBg %>; padding:0.25rem 0.65rem; border-radius:999px; white-space:nowrap;"><%= h(course.getStatusLabel()) %></span>
                                        </div>
                                        <div id="<%= h(courseModalId) %>" class="class-detail-modal" onclick="closeClassDetailModalOnBackdrop(event, this)">
                                            <div class="class-detail-modal-card" role="dialog" aria-modal="true" aria-labelledby="course-detail-title-<%= h(course.getId()) %>">
                                                <h3 id="course-detail-title-<%= h(course.getId()) %>" class="staff-class-title"><%= h(course.getTitle()) %></h3>
                                                <div class="teacher-approval-meta-grid" style="margin-top:1rem;">
                                                    <div class="teacher-approval-meta">
                                                        <span>Môn học</span>
                                                        <strong><%= h(course.getSubjectName()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Trạng thái</span>
                                                        <strong><%= h(course.getStatusLabel()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Giá</span>
                                                        <strong><%= h(course.getPriceLabel()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Giảng viên</span>
                                                        <strong><%= h(course.getTeacherName()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Email Drive</span>
                                                        <strong><%= h(course.getDriveOwnerEmail()) %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Bài học</span>
                                                        <strong><%= course.getLessonsCount() %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Học viên</span>
                                                        <strong><%= course.getStudentsCount() %></strong>
                                                    </div>
                                                    <div class="teacher-approval-meta">
                                                        <span>Ngày gửi</span>
                                                        <strong><%= course.getSubmittedAt() != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(course.getSubmittedAt()) : "Chưa cập nhật" %></strong>
                                                    </div>
                                                </div>
                                                <% if (course.getShortDescription() != null && !course.getShortDescription().trim().isEmpty()) { %>
                                                    <div class="teacher-approval-note" style="margin-top:1rem;">
                                                        <span>Mô tả</span>
                                                        <p><%= h(course.getShortDescription()) %></p>
                                                    </div>
                                                <% } %>
                                                <div style="margin-top:1rem;">
                                                    <a href="<%= h(course.getGoogleDriveUrl()) %>" target="_blank" rel="noopener" style="color:#047857; font-weight:850; font-size:0.9rem; text-decoration:none;">Mở Google Drive →</a>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/admin-profile" method="POST" style="display:flex; flex-direction:column; gap:0.75rem; margin-top:1rem;">
                                                    <input type="hidden" name="action" value="reviewCourse">
                                                    <input type="hidden" name="courseId" value="<%= h(course.getId()) %>">
                                                    <textarea name="reviewNote" rows="3" placeholder="Ghi chú duyệt hoặc yêu cầu chỉnh sửa..." style="width:100%; resize:vertical; padding:0.8rem 0.9rem; border:1px solid #cbd5e1; border-radius:0.8rem; font-size:0.9rem;"><%= h(course.getReviewNote()) %></textarea>
                                                    <div class="class-detail-actions" style="margin-top:0; padding-top:0; border-top:0;">
                                                        <button type="button" class="class-detail-cancel" onclick="closeClassDetailModal('<%= h(courseModalId) %>')">Hủy bỏ</button>
                                                        <button type="submit" name="decision" value="approved" class="class-detail-cancel" style="border-color:#bbf7d0; color:#047857;">Duyệt</button>
                                                        <button type="submit" name="decision" value="needs_revision" class="class-detail-cancel" style="border-color:#fed7aa; color:#c2410c;">Yêu cầu sửa</button>
                                                        <button type="submit" name="decision" value="rejected" class="class-detail-delete">Từ chối</button>
                                                    </div>
                                                </form>
                                                <form action="${pageContext.request.contextPath}/admin-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa tạm khóa học này?');">
                                                    <input type="hidden" name="action" value="deleteManagedCourse">
                                                    <input type="hidden" name="courseId" value="<%= h(course.getId()) %>">
                                                    <input type="hidden" name="deleteReason" value="Staff soft delete from profile">
                                                    <div class="class-detail-actions" style="margin-top:0.75rem;">
                                                        <button type="submit" class="class-detail-delete" title="Xóa tạm khóa học">
                                                            <span>Xóa tạm</span>
                                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="empty-status-panel" style="padding:4rem 2rem;">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 6.5v12"/><path d="M5 8.5c2.6 0 4.9.5 7 2 2.1-1.5 4.4-2 7-2v11c-2.6 0-4.9.5-7 2-2.1-1.5-4.4-2-7-2z"/></svg>
                                    <span style="font-weight:700; color:var(--text-main);">Không tìm thấy khóa học</span>
                                    <p style="font-size:0.85rem; max-width:420px; margin:0;">Khóa học do giảng viên gửi sẽ xuất hiện ở đây để staff kiểm tra Google Drive, nội dung và trạng thái hiển thị.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: DUYET HO SO GIANG VIEN                -->
            <!-- ========================================== -->

            <!-- ========================================== -->
            <!-- TAB REVENUE: THỐNG KÊ TIỀN                 -->
            <!-- ========================================== -->
            <section id="tab-revenue" class="tab-pane <%= "tab-revenue".equals(activeAdminTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Thống kê tiền</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div style="padding: 1.5rem;">
                        <h3 style="font-size: 1.25rem; font-weight: 700; color: #0f172a; margin-bottom: 1.25rem;">Tổng quan tài chính</h3>
                        <div class="system-overview-grid" style="grid-template-columns: repeat(2, 1fr);">
                            <div class="system-metric-card">
                                <div class="system-metric-icon" style="color: #059669; background: #dcfce7;">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng doanh thu khóa học</div>
                                    <div class="system-metric-value"><%= currencyFmt.format(financialOverview.getTotalCourseRevenue()) %></div>
                                </div>
                                <div class="system-metric-note">Khóa học đã thanh toán</div>
                            </div>

                            <div class="system-metric-card">
                                <div class="system-metric-icon" style="color: #8b5cf6; background: #ede9fe;">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><polyline points="19 12 12 19 5 12"></polyline></svg>
                                </div>
                                <div>
                                    <div class="system-metric-label">Tổng tiền đã rút</div>
                                    <div class="system-metric-value"><%= currencyFmt.format(financialOverview.getTotalWithdrawals()) %></div>
                                </div>
                                <div class="system-metric-note">Đã chuyển cho giảng viên</div>
                            </div>
                        </div>
                        
                        <div style="margin-top: 2rem;">
                            <h3 style="font-size: 1.25rem; font-weight: 700; color: #0f172a; margin-bottom: 1.25rem;">Giao dịch mua khóa học gần nhất</h3>
                            <div class="user-management-table" style="margin: 0; padding: 0;">
                                <div class="user-management-header" style="display: grid; gap: 1rem; grid-template-columns: 2fr 1fr 1fr 1fr;">
                                    <div>Người dùng</div>
                                    <div>Mã đơn hàng</div>
                                    <div>Số tiền</div>
                                    <div>Trạng thái</div>
                                </div>
                                <% if (financialOverview.getRecentTransactions() != null && !financialOverview.getRecentTransactions().isEmpty()) { 
                                    SimpleDateFormat dt = new SimpleDateFormat("HH:mm - dd/MM/yyyy");
                                    for (Map<String, Object> tx : financialOverview.getRecentTransactions()) { %>
                                    <div class="user-management-row" style="display: grid; gap: 1rem; border-bottom: 1px solid #eef2f7; padding: 1rem 0; grid-template-columns: 2fr 1fr 1fr 1fr; align-items: center;">
                                        <div style="display: flex; flex-direction: column; gap: 0.25rem;">
                                            <span style="font-weight: 600; color: #1e293b;"><%= h((String) tx.get("user")) %></span>
                                            <span style="font-size: 0.85rem; color: #64748b;"><%= dt.format((java.util.Date) tx.get("date")) %></span>
                                        </div>
                                        <div style="font-family: monospace; color: #334155;"><%= h((String) tx.get("code")) %></div>
                                        <div style="font-weight: 600; color: #059669;"><%= currencyFmt.format((java.math.BigDecimal) tx.get("amount")) %></div>
                                        <div>
                                            <span class="user-status-badge <%= "paid".equals(tx.get("status")) ? "status-active" : "status-disabled" %>">
                                                <%= "paid".equals(tx.get("status")) ? "Thành công" : "Đang chờ" %>
                                            </span>
                                        </div>
                                    </div>
                                <%  } 
                                } else { %>
                                    <div style="padding: 2rem; text-align: center; color: #64748b;">
                                        Không có giao dịch nào gần đây.
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            
            <!-- ========================================== -->
            <!-- TAB REVENUE: THỐNG KÊ TIỀN                 -->
            <!-- ========================================== -->
            
            
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

            <!-- ========================================== -->
            <!-- MODAL: ĐỔI VAI TRÒ NGƯỜI DÙNG             -->
            <!-- ========================================== -->
            <div id="changeRoleModal" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15,23,42,0.55); backdrop-filter:blur(6px); z-index:10000; display:none; justify-content:center; align-items:center; padding:1rem;" aria-hidden="true">
                <div style="background:#ffffff; border-radius:1.5rem; width:100%; max-width:430px; padding:2rem; box-shadow:0 20px 25px -5px rgba(0,0,0,0.15), 0 8px 10px -6px rgba(0,0,0,0.1); border:1px solid #e2e8f0; animation:modalScaleUp 0.25s ease-out;" role="dialog" aria-modal="true">
                    <!-- Header -->
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                        <div style="display:flex; align-items:center; gap:0.65rem;">
                            <div style="width:36px; height:36px; border-radius:50%; background:#ede9fe; color:#7c3aed; display:flex; justify-content:center; align-items:center;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                            <div>
                                <div style="font-size:1.1rem; font-weight:850; color:#0f172a;">Đổi vai trò</div>
                                <div id="changeRoleUserName" style="font-size:0.82rem; color:#64748b; font-weight:600; margin-top:0.1rem;">-</div>
                            </div>
                        </div>
                        <button type="button" onclick="closeChangeRoleModal()" style="background:none; border:none; font-size:1.35rem; color:#64748b; cursor:pointer; line-height:1;">&times;</button>
                    </div>

                    <!-- Current role display -->
                    <div style="background:#f8fafc; border-radius:1rem; padding:0.9rem 1.1rem; margin-bottom:1.25rem; display:flex; align-items:center; gap:0.65rem; border:1px solid #e2e8f0;">
                        <span style="font-size:0.82rem; color:#64748b; font-weight:700;">Vai trò hiện tại:</span>
                        <span id="changeRoleCurrentBadge" style="display:inline-block; background:#ecfdf5; color:#059669; border-radius:999px; padding:0.2rem 0.65rem; font-size:0.78rem; font-weight:850; text-transform:capitalize;">-</span>
                    </div>

                    <!-- Role selection -->
                    <form id="changeRoleForm" action="${pageContext.request.contextPath}/admin-profile" method="POST">
                        <input type="hidden" name="action" value="changeRole">
                        <input type="hidden" name="userPage" value="1">
                        <input type="hidden" id="changeRoleUserId" name="targetUserId" value="">

                        <div style="margin-bottom:1.25rem;">
                            <label style="font-size:0.85rem; font-weight:750; color:#0f172a; display:block; margin-bottom:0.75rem;">Chọn vai trò mới</label>
                            <div style="display:grid; grid-template-columns:1fr 1fr; gap:0.65rem;" id="roleOptions">
                                <label class="role-option-card" data-role="student">
                                    <input type="radio" name="newRole" value="student" style="display:none;">
                                    <div class="role-option-icon" style="background:#dbeafe; color:#2563eb;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                                    </div>
                                    <span class="role-option-label">Student</span>
                                </label>
                                <label class="role-option-card" data-role="teacher">
                                    <input type="radio" name="newRole" value="teacher" style="display:none;">
                                    <div class="role-option-icon" style="background:#dcfce7; color:#16a34a;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                                    </div>
                                    <span class="role-option-label">Teacher</span>
                                </label>
                                <label class="role-option-card" data-role="staff">
                                    <input type="radio" name="newRole" value="staff" style="display:none;">
                                    <div class="role-option-icon" style="background:#fef3c7; color:#d97706;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                    </div>
                                    <span class="role-option-label">Staff</span>
                                </label>
                                <label class="role-option-card" data-role="parent">
                                    <input type="radio" name="newRole" value="parent" style="display:none;">
                                    <div class="role-option-icon" style="background:#fce7f3; color:#be185d;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/></svg>
                                    </div>
                                    <span class="role-option-label">Parent</span>
                                </label>
                            </div>
                        </div>

                        <!-- Warning -->
                        <div style="background:#fef9c3; border:1px solid #fde047; border-radius:0.75rem; padding:0.75rem 1rem; margin-bottom:1.25rem; display:flex; align-items:flex-start; gap:0.5rem;">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#ca8a04" stroke-width="2.5" style="flex-shrink:0; margin-top:1px;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                            <span style="font-size:0.78rem; color:#92400e; font-weight:700;">Hành động này sẽ xóa toàn bộ vai trò cũ và chỉ giữ lại vai trò mới được chọn.</span>
                        </div>

                        <!-- Actions -->
                        <div style="display:flex; justify-content:flex-end; gap:0.75rem;">
                            <button type="button" onclick="closeChangeRoleModal()" style="padding:0.65rem 1.25rem; border-radius:0.75rem; background:#f1f5f9; color:#475569; font-weight:700; border:none; cursor:pointer; font-size:0.9rem;">Hủy bỏ</button>
                            <button type="submit" id="changeRoleSubmitBtn" disabled style="display:inline-flex; align-items:center; gap:0.5rem; background:#7c3aed; color:#ffffff; font-weight:800; font-size:0.9rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(124,58,237,0.3); cursor:not-allowed; opacity:0.5; transition:all 0.2s;">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                Xác nhận đổi role
                            </button>
                        </div>
                    </form>
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
        function openClassDetailModal(modalId) {
            const modal = document.getElementById(modalId);
            if (!modal) return;
            if (modal.parentElement !== document.body) {
                document.body.appendChild(modal);
            }
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeClassDetailModal(modalId) {
            const modal = document.getElementById(modalId);
            if (!modal) return;
            modal.classList.remove('active');
            document.body.style.overflow = '';
        }

        function closeClassDetailModalOnBackdrop(event, modal) {
            if (event.target === modal) {
                modal.classList.remove('active');
                document.body.style.overflow = '';
            }
        }

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                document.querySelectorAll('.class-detail-modal.active').forEach(m => {
                    m.classList.remove('active');
                    document.body.style.overflow = '';
                });
            }
        });

        function setupManagementFilterDropdowns() {
            const dropdowns = Array.from(document.querySelectorAll('.management-filter-dropdown'));
            if (!dropdowns.length) return;

            function closeDropdown(dropdown) {
                dropdown.classList.remove('is-open');
                const trigger = dropdown.querySelector('.management-filter-trigger');
                if (trigger) trigger.setAttribute('aria-expanded', 'false');
            }

            dropdowns.forEach(dropdown => {
                const trigger = dropdown.querySelector('.management-filter-trigger');
                const label = dropdown.querySelector('.management-filter-label');
                const options = Array.from(dropdown.querySelectorAll('.management-filter-option'));
                const targetInput = document.getElementById(dropdown.dataset.targetInput || '');
                if (!trigger || !label || !targetInput) return;

                trigger.addEventListener('click', (event) => {
                    event.stopPropagation();
                    const willOpen = !dropdown.classList.contains('is-open');
                    dropdowns.forEach(closeDropdown);
                    dropdown.classList.toggle('is-open', willOpen);
                    trigger.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
                });

                options.forEach(option => {
                    option.addEventListener('click', (event) => {
                        event.stopPropagation();
                        const value = option.dataset.value || '';
                        targetInput.value = value;
                        label.textContent = option.textContent.replace(/\u2713/g, '').trim();
                        options.forEach(item => item.classList.toggle('is-selected', item === option));
                        targetInput.dispatchEvent(new Event('change', { bubbles: true }));
                        closeDropdown(dropdown);

                        if (dropdown.dataset.submitOnChange === 'true') {
                            const form = dropdown.closest('form');
                            if (form) {
                                if (typeof form.requestSubmit === 'function') form.requestSubmit();
                                else form.submit();
                            }
                        }
                    });
                });
            });

            document.addEventListener('click', () => dropdowns.forEach(closeDropdown));
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape') dropdowns.forEach(closeDropdown);
            });
        }

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

        // ─── Change Role Modal ────────────────────────────────────────
        function openChangeRoleModal(btn) {
            const modal = document.getElementById('changeRoleModal');
            if (!modal || !btn) return;

            const userId = btn.dataset.userid;
            const currentRole = btn.dataset.currentRole || '';
            const name = btn.dataset.name || 'Người dùng';

            document.getElementById('changeRoleUserId').value = userId;
            document.getElementById('changeRoleUserName').textContent = name;
            document.getElementById('changeRoleCurrentBadge').textContent = currentRole;

            // Reset selection
            document.querySelectorAll('.role-option-card').forEach(card => {
                card.classList.remove('selected');
                card.querySelector('input[type=radio]').checked = false;
            });
            document.getElementById('changeRoleSubmitBtn').disabled = true;
            document.getElementById('changeRoleSubmitBtn').style.opacity = '0.5';
            document.getElementById('changeRoleSubmitBtn').style.cursor = 'not-allowed';

            modal.style.display = 'flex';
            modal.setAttribute('aria-hidden', 'false');
        }

        function closeChangeRoleModal() {
            const modal = document.getElementById('changeRoleModal');
            if (!modal) return;
            modal.style.display = 'none';
            modal.setAttribute('aria-hidden', 'true');
        }

        // Role card click → select + enable submit
        document.querySelectorAll('.role-option-card').forEach(card => {
            card.addEventListener('click', () => {
                document.querySelectorAll('.role-option-card').forEach(c => c.classList.remove('selected'));
                card.classList.add('selected');
                card.querySelector('input[type=radio]').checked = true;
                const submitBtn = document.getElementById('changeRoleSubmitBtn');
                submitBtn.disabled = false;
                submitBtn.style.opacity = '1';
                submitBtn.style.cursor = 'pointer';
            });
        });

        // Close on backdrop click
        document.getElementById('changeRoleModal').addEventListener('click', (e) => {
            if (e.target === document.getElementById('changeRoleModal')) closeChangeRoleModal();
        });

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
            'tab-users': 'Quản lý người dùng',
            'tab-manage-classes': 'Quản lý lớp học',
            'tab-manage-courses': 'Quản lý khóa học',
            'tab-revenue': 'Thống kê tiền',
            'tab-edit': 'Cập nhật thông tin',
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
            if (options.updateUrl !== false && options.replaceUrl !== true) {
                let newTab = targetTabId;
                if (newTab.startsWith('tab-')) newTab = newTab.substring(4);
                const currentTab = new URLSearchParams(window.location.search).get('tab') || 'system-dashboard';
                if (newTab !== currentTab) {
                    window.location.href = '?tab=' + newTab;
                    return;
                }
            }
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
            setupManagementFilterDropdowns();
            const urlParams = new URLSearchParams(window.location.search);
            const tabParam = urlParams.get('tab');
            if (tabParam) {
                switchTab(tabParam, { replaceUrl: true });
            } else {
                const activePane = document.querySelector('.tab-pane.active-pane');
                if (activePane) updateProfileTabUrl(activePane.id, true);
            }
            initAdminStatusWS();
            if (typeof initStaffUserGrowthChart === 'function') {
                initStaffUserGrowthChart();
            }
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
    <script>
        window.HipziStaffUserGrowthData = {
            week: <%= staffWeeklyUserGrowthJson %>,
            month: <%= staffMonthlyUserGrowthJson %>
        };
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/staff-user-growth-chart.js?v=1"></script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>

