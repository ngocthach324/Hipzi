<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.Role"%>
<%@page import="com.hipzi.model.AdminUserSummary"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.Course"%>
<%@page import="com.hipzi.model.MockExam"%>
<%@page import="com.hipzi.model.TeacherApplication"%>
<%@page import="com.hipzi.model.Notification"%>
<%@page import="com.hipzi.model.SupportMessage"%>
<%@page import="com.hipzi.model.SupportTicket"%>
<%@page import="com.hipzi.model.StaffCourseTransaction"%>
<%@page import="com.hipzi.model.StaffUserGrowthStats"%>
<%@page import="com.hipzi.model.WithdrawalRequest"%>
<%@page import="com.hipzi.service.NotificationService"%>
<%@page import="com.hipzi.util.UserStatusWebSocket"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<!DOCTYPE html>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String teacherTypeLabel(String value) {
        if ("student_tutor".equals(value)) return "Gia sư sinh viên";
        if ("certified_pedagogy".equals(value)) return "Giảng viên có chứng chỉ sư phạm";
        if ("degree_specialist".equals(value)) return "Giảng viên chuyên môn";
        return "Chưa phân loại";
    }

    private String applicationStatusLabel(String value) {
        if ("approved".equals(value)) return "Đã duyệt";
        if ("rejected".equals(value)) return "Từ chối";
        if ("needs_more_info".equals(value)) return "Cần bổ sung";
        return "Chờ duyệt";
    }

    private String studyYearLabel(String value) {
        if ("year_1".equals(value)) return "Năm 1";
        if ("year_2".equals(value)) return "Năm 2";
        if ("year_3".equals(value)) return "Năm 3";
        if ("year_4".equals(value)) return "Năm 4";
        if ("year_5_plus".equals(value)) return "Năm 5 trở lên";
        if ("graduated".equals(value)) return "Đã tốt nghiệp";
        return "Không áp dụng";
    }

    private String userRoleLabel(String roles) {
        if (roles == null || roles.trim().isEmpty()) return "Chưa phân quyền";
        String lowered = roles.toLowerCase();
        if (lowered.contains("teacher") && lowered.contains("student")) return "Giảng viên, Học sinh";
        if (lowered.contains("teacher")) return "Giảng viên";
        if (lowered.contains("student")) return "Học sinh";
        return roles;
    }

    private String userStatusLabel(String status) {
        if ("active".equalsIgnoreCase(status)) return "Đang hoạt động";
        if ("disabled".equalsIgnoreCase(status)) return "Đã khóa";
        if ("pending".equalsIgnoreCase(status)) return "Chờ xác nhận";
        return status != null && !status.trim().isEmpty() ? status : "Chưa rõ";
    }

    private String withdrawalStatusStyle(String status) {
        if ("paid".equalsIgnoreCase(status)) return "background:#ecfdf5; color:#059669;";
        if ("processing".equalsIgnoreCase(status)) return "background:#eff6ff; color:#2563eb;";
        if ("rejected".equalsIgnoreCase(status) || "failed".equalsIgnoreCase(status) || "cancelled".equalsIgnoreCase(status)) return "background:#fef2f2; color:#dc2626;";
        return "background:#fff7ed; color:#c2410c;";
    }

    private String courseSaleStatusStyle(String status) {
        if ("paid".equalsIgnoreCase(status)) return "background:#ecfdf5; color:#059669;";
        if ("failed".equalsIgnoreCase(status) || "cancelled".equalsIgnoreCase(status) || "expired".equalsIgnoreCase(status)) return "background:#fef2f2; color:#dc2626;";
        return "background:#fff7ed; color:#c2410c;";
    }

    private String mockExamTypeLabel(String type) {
        if ("essay".equals(type)) return "Tự luận";
        return "Trắc nghiệm";
    }

    private String mockExamStatusLabel(String status) {
        if ("published".equals(status)) return "Đã xuất bản";
        if ("archived".equals(status)) return "Đã lưu trữ";
        return "Bản nháp";
    }

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
%>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ nhân viên - HIPZI</title>
    <meta name="description" content="Khu vực làm việc và quản lý hàng đợi kiểm duyệt tài liệu, hồ sơ đăng ký giảng viên dành cho nhân viên HIPZI.">
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

        /* ===== KHU VỰC SIDEBAR BÊN TRÁI (LEFT NAVIGATION PANE) ===== */
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

        /* Nav menu items */
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

        #nav-tab-materials,
        #nav-tab-practice {
            display: none !important;
        }

        .dashboard-main-section {
            display: flex;
            flex-direction: column;
            min-width: 0;
            gap: 1rem;
            flex: 1;
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
            box-shadow: var(--shadow);
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
        }
        /* ===== KHU VỰC SIDEBAR BÊN TRÁI (LEFT NAVIGATION PANE) ===== */
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

        .sidebar-section-label {
            font-size: 0.75rem;
            font-weight: 800;
            color: var(--text-muted);
            letter-spacing: 1px;
            text-transform: uppercase;
            margin: 1.05rem 0 0.3rem 0.35rem;
            white-space: nowrap;
        }

        /* Nav menu items */
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

        #nav-tab-materials,
        #nav-tab-practice {
            display: none !important;
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

        body.staff-profile-page #tab-overview,
        body.staff-profile-page #tab-profile {
            gap: 2rem;
        }

        body.staff-profile-page #tab-teacher-approval .tab-grouped-container,
        body.staff-profile-page #tab-manage-teachers .tab-grouped-container,
        body.staff-profile-page #tab-manage-classes .tab-grouped-container,
        body.staff-profile-page #tab-manage-courses .tab-grouped-container,
        body.staff-profile-page #tab-materials .tab-grouped-container,
        body.staff-profile-page #tab-practice .tab-grouped-container {
            background: transparent;
            border: none;
            border-radius: 0;
            box-shadow: none;
            padding: 0;
            min-height: 0;
            overflow: visible;
        }

        body.staff-profile-page #tab-teacher-approval .tab-header-accent,
        body.staff-profile-page #tab-manage-teachers .tab-header-accent,
        body.staff-profile-page #tab-manage-classes .tab-header-accent,
        body.staff-profile-page #tab-manage-courses .tab-header-accent,
        body.staff-profile-page #tab-materials .tab-header-accent,
        body.staff-profile-page #tab-practice .tab-header-accent {
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

        body.staff-profile-page #tab-teacher-approval .tab-header-title-text,
        body.staff-profile-page #tab-manage-teachers .tab-header-title-text,
        body.staff-profile-page #tab-manage-classes .tab-header-title-text,
        body.staff-profile-page #tab-manage-courses .tab-header-title-text,
        body.staff-profile-page #tab-materials .tab-header-title-text,
        body.staff-profile-page #tab-practice .tab-header-title-text {
            font-size: 1.75rem;
            line-height: 1.15;
            font-weight: 800;
            letter-spacing: -0.5px;
            color: var(--text-main);
        }

        body.staff-profile-page #tab-teacher-approval .tab-header-title-text::after,
        body.staff-profile-page #tab-manage-teachers .tab-header-title-text::after,
        body.staff-profile-page #tab-manage-classes .tab-header-title-text::after,
        body.staff-profile-page #tab-manage-courses .tab-header-title-text::after,
        body.staff-profile-page #tab-materials .tab-header-title-text::after,
        body.staff-profile-page #tab-practice .tab-header-title-text::after {
            display: block;
            margin-top: 0.35rem;
            color: #475569;
            font-size: 0.95rem;
            line-height: 1.45;
            font-weight: 600;
            letter-spacing: 0;
        }

        body.staff-profile-page #tab-teacher-approval .tab-header-title-text::after {
            content: "Xét duyệt hồ sơ đăng kí giảng dạy và cập nhật trạng thái cho giảng viên.";
        }

        body.staff-profile-page #tab-manage-teachers .tab-header-title-text::after {
            content: "Theo dõi danh sách giảng viên và học sinh đang sử dụng nền tảng.";
        }

        body.staff-profile-page #tab-manage-classes .tab-header-title-text::after {
            content: "Quản lý các lớp học đang mở, sắp khai giảng hoặc đã đóng trên HIPZI.";
        }

        body.staff-profile-page #tab-manage-courses .tab-header-title-text::after {
            content: "Rà soát khóa học, trạng thái duyệt và nội dung liên kết Google Drive.";
        }

        body.staff-profile-page #tab-materials .tab-header-title-text::after {
            content: "Kiểm tra hàng đợi tài liệu học tập do giảng viên gửi lên kho học liệu.";
        }

        body.staff-profile-page #tab-practice .tab-header-title-text::after {
            content: "Theo dõi yêu cầu đăng kí giảng viên và các bước xác minh nghiệp vụ.";
        }

        body.staff-profile-page #tab-teacher-approval .tab-header-date-pill,
        body.staff-profile-page #tab-manage-teachers .tab-header-date-pill,
        body.staff-profile-page #tab-manage-classes .tab-header-date-pill,
        body.staff-profile-page #tab-manage-courses .tab-header-date-pill,
        body.staff-profile-page #tab-materials .tab-header-date-pill,
        body.staff-profile-page #tab-practice .tab-header-date-pill {
            background: #ffffff;
            color: var(--text-main);
            border: 1px solid var(--border-dark);
            border-radius: 1rem;
            padding: 0.5rem 1rem;
            box-shadow: var(--shadow);
        }

        body.staff-profile-page #tab-teacher-approval .tab-body-content,
        body.staff-profile-page #tab-manage-teachers .tab-body-content,
        body.staff-profile-page #tab-manage-classes .tab-body-content,
        body.staff-profile-page #tab-manage-courses .tab-body-content,
        body.staff-profile-page #tab-materials .tab-body-content,
        body.staff-profile-page #tab-practice .tab-body-content {
            padding: 0;
            overflow: visible;
            gap: 1.5rem;
        }

        body.staff-profile-page #tab-teacher-approval .section-data-card,
        body.staff-profile-page #tab-manage-teachers .section-data-card,
        body.staff-profile-page #tab-manage-classes .section-data-card,
        body.staff-profile-page #tab-manage-courses .section-data-card,
        body.staff-profile-page #tab-materials .section-data-card,
        body.staff-profile-page #tab-practice .section-data-card {
            background: #ffffff;
            border: 1px solid #dbe4ee;
            border-radius: 1.25rem;
            padding: 1.65rem;
            box-shadow: 0 16px 36px rgba(15, 23, 42, 0.04);
            min-height: 420px;
        }

        body.staff-profile-page #tab-teacher-approval .card-header-layout,
        body.staff-profile-page #tab-manage-teachers .card-header-layout,
        body.staff-profile-page #tab-manage-classes .card-header-layout,
        body.staff-profile-page #tab-manage-courses .card-header-layout,
        body.staff-profile-page #tab-materials .card-header-layout,
        body.staff-profile-page #tab-practice .card-header-layout {
            padding-bottom: 1.15rem !important;
            margin-bottom: 1.5rem !important;
            border-bottom: 1px solid #dbe4ee !important;
        }

        body.staff-profile-page #tab-manage-teachers .section-data-card > form,
        body.staff-profile-page #tab-manage-classes .section-data-card > form,
        body.staff-profile-page #tab-manage-courses .section-data-card > form {
            background: #ffffff !important;
            border: 1px solid #dbe4ee !important;
            border-radius: 1rem !important;
            padding: 1rem !important;
            margin-bottom: 1.75rem !important;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.035);
        }

        body.staff-profile-page #tab-manage-teachers .section-data-card > form.management-toolbar,
        body.staff-profile-page #tab-manage-classes .section-data-card > form.management-toolbar,
        body.staff-profile-page #tab-manage-courses .section-data-card > form.management-toolbar {
            background: transparent !important;
            border: none !important;
            border-radius: 0 !important;
            padding: 0 !important;
            margin: 0.9rem 0 1.35rem !important;
            box-shadow: none !important;
        }

        body.staff-profile-page #tab-manage-teachers .section-data-card > form input,
        body.staff-profile-page #tab-manage-teachers .section-data-card > form select,
        body.staff-profile-page #tab-manage-classes .section-data-card > form input,
        body.staff-profile-page #tab-manage-classes .section-data-card > form select,
        body.staff-profile-page #tab-manage-courses .section-data-card > form input,
        body.staff-profile-page #tab-manage-courses .section-data-card > form select {
            background: #f8fafc !important;
            border-color: #dbe4ee !important;
            border-radius: 0.85rem !important;
            min-height: 3rem;
            font-weight: 700;
        }

        body.staff-profile-page #tab-manage-teachers .section-data-card > form.management-toolbar input,
        body.staff-profile-page #tab-manage-teachers .section-data-card > form.management-toolbar select,
        body.staff-profile-page #tab-manage-classes .section-data-card > form.management-toolbar input,
        body.staff-profile-page #tab-manage-classes .section-data-card > form.management-toolbar select,
        body.staff-profile-page #tab-manage-courses .section-data-card > form.management-toolbar input,
        body.staff-profile-page #tab-manage-courses .section-data-card > form.management-toolbar select {
            min-height: 0 !important;
            border: 1px solid var(--border-dark) !important;
            border-radius: 999px !important;
            padding: 0.7rem 1rem !important;
            font-size: 0.88rem !important;
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.03) !important;
        }

        body.staff-profile-page #tab-manage-teachers .section-data-card > form.management-toolbar input,
        body.staff-profile-page #tab-manage-classes .section-data-card > form.management-toolbar input,
        body.staff-profile-page #tab-manage-courses .section-data-card > form.management-toolbar input {
            background: #f8fafc !important;
            color: var(--text-main) !important;
            font-weight: 650 !important;
        }

        body.staff-profile-page #tab-manage-teachers .section-data-card > form.management-toolbar select,
        body.staff-profile-page #tab-manage-classes .section-data-card > form.management-toolbar select,
        body.staff-profile-page #tab-manage-courses .section-data-card > form.management-toolbar select {
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

        body.staff-profile-page #tab-manage-teachers .section-data-card > form > button,
        body.staff-profile-page #tab-manage-classes .section-data-card > form > button,
        body.staff-profile-page #tab-manage-courses .section-data-card > form > button {
            background: #059669 !important;
            color: #ffffff !important;
            border: none !important;
            border-radius: 0.85rem !important;
            min-height: 3rem;
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.18);
        }

        body.staff-profile-page #tab-teacher-approval .teacher-approval-grid,
        body.staff-profile-page #tab-manage-teachers .teacher-approval-grid,
        body.staff-profile-page #tab-manage-classes .staff-class-list,
        body.staff-profile-page #tab-manage-courses .staff-class-list {
            gap: 1.15rem;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-approval-card,
        body.staff-profile-page #tab-manage-teachers .teacher-approval-card,
        body.staff-profile-page #tab-manage-classes .staff-class-card,
        body.staff-profile-page #tab-manage-courses .staff-class-card {
            border: 1px solid #dbe4ee;
            border-left: 4px solid #059669;
            border-radius: 1rem;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.035);
        }

        body.staff-profile-page #tab-teacher-approval .empty-status-panel,
        body.staff-profile-page #tab-manage-teachers .empty-status-panel,
        body.staff-profile-page #tab-manage-classes .empty-status-panel,
        body.staff-profile-page #tab-manage-courses .empty-status-panel,
        body.staff-profile-page #tab-materials .empty-status-panel,
        body.staff-profile-page #tab-practice .empty-status-panel {
            background: #ffffff;
            border: 1px dashed #dbe4ee;
            border-radius: 1.25rem;
            box-shadow: none;
        }

        body.staff-profile-page #tab-teacher-approval .section-data-card {
            background: #ffffff;
            border: 1px solid #dbe4ee;
            border-radius: 1.5rem;
            padding: 1.5rem;
            min-height: 560px;
            overflow: hidden;
            box-shadow: none;
        }

        body.staff-profile-page #tab-teacher-approval .section-data-card.system-management-card,
        body.staff-profile-page #tab-manage-teachers .section-data-card.system-management-card,
        body.staff-profile-page #tab-manage-classes .section-data-card.system-management-card,
        body.staff-profile-page #tab-manage-courses .section-data-card.system-management-card {
            background: #ffffff;
            border: 1px solid #dbe4ee;
            border-radius: 1.5rem;
            padding: 1.5rem;
            min-height: 560px;
            overflow: hidden;
            box-shadow: none;
        }

        body.staff-profile-page #tab-teacher-approval .card-header-layout {
            padding: 0 0 1rem 0 !important;
            margin: 0 0 1.35rem 0 !important;
            background: transparent !important;
            border-bottom: 1px solid var(--border-dark) !important;
        }

        body.staff-profile-page #tab-teacher-approval .system-management-card .card-header-layout,
        body.staff-profile-page #tab-manage-teachers .system-management-card .card-header-layout,
        body.staff-profile-page #tab-manage-classes .system-management-card .card-header-layout,
        body.staff-profile-page #tab-manage-courses .system-management-card .card-header-layout {
            padding: 0 0 1rem 0 !important;
            margin: 0 0 1.45rem 0 !important;
            background: transparent !important;
            border-bottom: 1px solid var(--border-dark) !important;
        }

        body.staff-profile-page #tab-teacher-approval .card-header-title,
        body.staff-profile-page #tab-manage-teachers .card-header-title,
        body.staff-profile-page #tab-manage-classes .card-header-title,
        body.staff-profile-page #tab-manage-courses .card-header-title {
            display: inline-flex;
            align-items: center;
            gap: 0.6rem;
            color: var(--text-main);
            font-size: 1.1rem;
            font-weight: 900;
            line-height: 1.25;
        }

        body.staff-profile-page #tab-teacher-approval .card-header-title svg,
        body.staff-profile-page #tab-manage-teachers .card-header-title svg,
        body.staff-profile-page #tab-manage-classes .card-header-title svg,
        body.staff-profile-page #tab-manage-courses .card-header-title svg {
            color: #059669;
            stroke: currentColor;
        }

        body.staff-profile-page #tab-teacher-approval .card-header-layout > span,
        body.staff-profile-page #tab-manage-teachers .card-header-layout > span,
        body.staff-profile-page #tab-manage-classes .card-header-layout > span,
        body.staff-profile-page #tab-manage-courses .card-header-layout > span {
            font-size: 0.78rem !important;
            font-weight: 850 !important;
            color: #059669 !important;
            background: #dcfce7 !important;
            padding: 0.25rem 0.75rem !important;
            border-radius: 999px !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar {
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

        body.staff-profile-page #tab-teacher-approval .management-toolbar,
        body.staff-profile-page #tab-manage-teachers .management-toolbar {
            grid-template-columns: minmax(420px, calc((100% - 1rem) / 2)) 1fr 220px 220px auto;
        }

        body.staff-profile-page #tab-teacher-approval .management-toolbar select {
            grid-column: auto;
        }

        body.staff-profile-page #tab-teacher-approval .management-toolbar .management-filter-dropdown {
            grid-column: 4;
        }

        body.staff-profile-page #tab-manage-teachers .management-toolbar .management-filter-dropdown:first-of-type {
            grid-column: 3;
        }

        body.staff-profile-page #tab-manage-teachers .management-toolbar .management-filter-dropdown:nth-of-type(2) {
            grid-column: 4;
        }

        body.staff-profile-page #tab-manage-classes .management-toolbar .management-filter-dropdown:first-of-type,
        body.staff-profile-page #tab-manage-courses .management-toolbar .management-filter-dropdown:first-of-type {
            grid-column: 3;
        }

        body.staff-profile-page #tab-manage-classes .management-toolbar .management-filter-dropdown:nth-of-type(2),
        body.staff-profile-page #tab-manage-courses .management-toolbar .management-filter-dropdown:nth-of-type(2) {
            grid-column: 4;
        }

        body.staff-profile-page #tab-manage-teachers .management-toolbar > button,
        body.staff-profile-page #tab-manage-classes .management-toolbar > button,
        body.staff-profile-page #tab-manage-courses .management-toolbar > button {
            display: none !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar input,
        body.staff-profile-page .system-management-card .management-toolbar select {
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

        body.staff-profile-page .system-management-card .management-toolbar input {
            background-color: #f8fafc !important;
            font-weight: 650 !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar select {
            appearance: none;
            cursor: pointer;
            color: #0f172a !important;
            padding: 0.7rem 2.4rem 0.7rem 1rem !important;
            background: #ffffff linear-gradient(45deg, transparent 50%, #059669 50%), linear-gradient(135deg, #059669 50%, transparent 50%) !important;
            background-position: calc(100% - 1.25rem) 50%, calc(100% - 0.9rem) 50%;
            background-size: 0.45rem 0.45rem, 0.45rem 0.45rem;
            background-repeat: no-repeat;
        }

        body.staff-profile-page #tab-teacher-approval .system-management-card .management-toolbar select,
        body.staff-profile-page #tab-manage-teachers .system-management-card .management-toolbar select,
        body.staff-profile-page #tab-manage-classes .system-management-card .management-toolbar select,
        body.staff-profile-page #tab-manage-courses .system-management-card .management-toolbar select {
            background: #ffffff linear-gradient(45deg, transparent 50%, #059669 50%), linear-gradient(135deg, #059669 50%, transparent 50%) !important;
            background-position: calc(100% - 1.25rem) 50%, calc(100% - 0.9rem) 50% !important;
            background-size: 0.45rem 0.45rem, 0.45rem 0.45rem !important;
            background-repeat: no-repeat !important;
            color: #0f172a !important;
            border: 1px solid var(--border-dark) !important;
            border-radius: 999px !important;
            box-shadow: 0 8px 18px rgba(15, 23, 42, 0.03) !important;
        }

        body.staff-profile-page .management-filter-select-wrap {
            position: relative;
            min-width: 190px;
            width: 100%;
        }

        body.staff-profile-page .management-filter-select-wrap::after {
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

        body.staff-profile-page .system-management-card .management-toolbar .management-filter-select {
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

        body.staff-profile-page .system-management-card .management-toolbar .management-filter-select:focus {
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12) !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar .management-filter-select option {
            background: #ffffff !important;
            color: #475569 !important;
            font-weight: 700 !important;
        }

        body.staff-profile-page .management-filter-dropdown {
            position: relative;
            min-width: 220px;
            width: 100%;
        }

        body.staff-profile-page .management-filter-trigger {
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

        body.staff-profile-page .management-filter-trigger svg {
            flex: 0 0 auto;
            color: #059669;
        }

        body.staff-profile-page .management-filter-label {
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page .management-filter-dropdown.is-open .management-filter-trigger,
        body.staff-profile-page .management-filter-trigger:focus {
            border-color: #10b981;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
        }

        body.staff-profile-page .management-filter-menu {
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

        body.staff-profile-page .management-filter-dropdown.is-open .management-filter-menu {
            opacity: 1;
            visibility: visible;
            pointer-events: auto;
            transform: translateY(0) scale(1);
            transition-delay: 0s;
        }

        body.staff-profile-page .management-filter-option {
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

        body.staff-profile-page .management-filter-option:hover,
        body.staff-profile-page .management-filter-option.is-selected {
            background: #dff8ee;
            color: #059669;
        }

        body.staff-profile-page .management-filter-check {
            color: #059669;
            font-weight: 800;
            opacity: 0;
            transition: opacity 140ms ease;
        }

        body.staff-profile-page .management-filter-option.is-selected .management-filter-check {
            opacity: 1;
        }

        body.staff-profile-page .system-management-card .management-toolbar input:focus,
        body.staff-profile-page .system-management-card .management-toolbar select:focus {
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12) !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar > button {
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

        body.staff-profile-page #tab-teacher-approval .teacher-approval-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
            padding-top: 0.45rem !important;
        }

        body.staff-profile-page #tab-manage-teachers .teacher-approval-grid,
        body.staff-profile-page #tab-manage-classes .staff-class-list,
        body.staff-profile-page #tab-manage-courses .staff-class-list {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-approval-card {
            border: 1px solid #e2e8f0;
            border-left: 4px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1rem;
            background: #ffffff;
            cursor: pointer;
            box-shadow: 0 10px 20px rgba(15, 23, 42, 0.04);
            transition: border-color 0.18s ease, border-left-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background-color 0.18s ease;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-approval-card:hover,
        body.staff-profile-page #tab-teacher-approval .teacher-approval-card:focus-visible {
            border-color: #86efac;
            border-left-color: #059669;
            box-shadow: 0 18px 36px rgba(5, 150, 105, 0.14);
            transform: translateY(-2px);
            background: #f0fdf4;
            outline: none;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary {
            display: block;
            min-width: 0;
            margin: -1rem;
            padding: 1rem;
            border-radius: inherit;
            outline: none;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary:focus-visible {
            outline: none;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-top {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            align-items: flex-start;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-identity {
            min-width: 0;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-line {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            min-width: 0;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-avatar {
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

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-name {
            min-width: 0;
            color: #334155;
            font-weight: 850;
            font-size: 0.82rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-title {
            display: block;
            color: #0f172a;
            font-weight: 900;
            font-size: 0.98rem;
            margin-top: 0.55rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-bottom {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
            margin-top: 0.8rem;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-role {
            color: #334155;
            font-size: 0.78rem;
            font-weight: 850;
        }

        body.staff-profile-page #tab-teacher-approval .teacher-application-summary-date {
            color: #64748b;
            font-size: 0.72rem;
            font-weight: 850;
            text-align: right;
            line-height: 1.25;
        }

        body.staff-profile-page #tab-manage-teachers .teacher-approval-card,
        body.staff-profile-page #tab-manage-classes .staff-class-card,
        body.staff-profile-page #tab-manage-courses .staff-class-card {
            border: 1px solid #dbe4ee !important;
            border-left: 4px solid #e2e8f0 !important;
            border-radius: 1rem !important;
            padding: 1.35rem !important;
            background: #ffffff !important;
            box-shadow: 0 10px 20px rgba(15, 23, 42, 0.04) !important;
            transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background-color 0.18s ease;
        }

        body.staff-profile-page #tab-manage-teachers .teacher-approval-card:hover,
        body.staff-profile-page #tab-manage-classes .staff-class-card:hover,
        body.staff-profile-page #tab-manage-courses .staff-class-card:hover {
            border-color: #86efac !important;
            border-left-color: #059669 !important;
            box-shadow: 0 18px 36px rgba(5, 150, 105, 0.12) !important;
            transform: translateY(-2px);
            background: #f0fdf4 !important;
        }

        body.staff-profile-page #tab-manage-courses .staff-class-card {
            cursor: pointer;
            max-width: 680px;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-table {
            width: 100%;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            overflow: hidden;
            background: #ffffff;
            box-shadow: 0 10px 22px rgba(15, 23, 42, 0.035);
        }

        body.staff-profile-page #tab-manage-teachers .user-management-row {
            display: grid;
            grid-template-columns: minmax(260px, 1.7fr) 0.9fr 0.9fr 0.75fr;
            gap: 1rem;
            align-items: center;
            padding: 0.85rem 1rem;
            border-bottom: 1px solid #eef2f7;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-row:last-child {
            border-bottom: 0;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-head {
            background: #f8fafc;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.02em;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-item {
            transition: background-color 0.16s ease, box-shadow 0.16s ease;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-item:hover {
            background: #f0fdf4;
            box-shadow: inset 4px 0 0 #059669;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-main {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-width: 0;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-avatar {
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

        body.staff-profile-page #tab-manage-teachers .user-management-name {
            display: block;
            color: #0f172a;
            font-size: 0.9rem;
            font-weight: 900;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-email {
            display: block;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 700;
            margin-top: 0.12rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-cell {
            color: #334155;
            font-size: 0.82rem;
            font-weight: 800;
            min-width: 0;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 999px;
            padding: 0.22rem 0.7rem;
            font-size: 0.72rem;
            font-weight: 900;
            white-space: nowrap;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-pill.active {
            background: #dcfce7;
            color: #047857;
        }

        body.staff-profile-page #tab-manage-teachers .user-management-pill.disabled {
            background: #fee2e2;
            color: #dc2626;
        }

        @media (max-width: 900px) {
            body.staff-profile-page #tab-teacher-approval .teacher-approval-grid,
            body.staff-profile-page #tab-manage-teachers .teacher-approval-grid,
            body.staff-profile-page #tab-manage-classes .staff-class-list,
            body.staff-profile-page #tab-manage-courses .staff-class-list {
                grid-template-columns: 1fr;
            }

            body.staff-profile-page #tab-manage-teachers .user-management-row {
                grid-template-columns: 1fr;
                gap: 0.55rem;
            }

            body.staff-profile-page #tab-manage-teachers .user-management-head {
                display: none;
            }

            body.staff-profile-page .system-management-card .management-toolbar,
            body.staff-profile-page #tab-teacher-approval .management-toolbar,
            body.staff-profile-page #tab-manage-teachers .management-toolbar {
                grid-template-columns: 1fr;
            }

            body.staff-profile-page #tab-teacher-approval .management-toolbar select,
            body.staff-profile-page #tab-manage-teachers .management-toolbar select,
            body.staff-profile-page #tab-manage-classes .management-toolbar select,
            body.staff-profile-page #tab-manage-courses .management-toolbar select,
            body.staff-profile-page #tab-teacher-approval .management-toolbar .management-filter-dropdown,
            body.staff-profile-page #tab-manage-teachers .management-toolbar .management-filter-dropdown,
            body.staff-profile-page #tab-manage-classes .management-toolbar .management-filter-dropdown,
            body.staff-profile-page #tab-manage-courses .management-toolbar .management-filter-dropdown,
            body.staff-profile-page #tab-teacher-approval .management-toolbar .support-filter-select-wrap,
            body.staff-profile-page #tab-manage-teachers .management-toolbar .support-filter-select-wrap,
            body.staff-profile-page #tab-manage-classes .management-toolbar .support-filter-select-wrap,
            body.staff-profile-page #tab-manage-courses .management-toolbar .support-filter-select-wrap,
            body.staff-profile-page #tab-manage-teachers .management-toolbar > button,
            body.staff-profile-page #tab-manage-classes .management-toolbar > button,
            body.staff-profile-page #tab-manage-courses .management-toolbar > button {
                grid-column: auto;
            }
        }

        body.staff-profile-page #tab-overview .metrics-row,
        body.staff-profile-page #tab-overview .dashboard-grid-layout {
            margin: 0;
        }

        body.staff-profile-page #tab-profile .premium-card {
            background: #ffffff;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
            box-sizing: border-box;
        }

        body.staff-profile-page #tab-overview .premium-card {
            padding: 1.5rem;
        }

        body.staff-profile-page #tab-profile .security-password-card {
            min-height: 188px;
            justify-content: space-between;
        }

        body.staff-profile-page #tab-profile .security-card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        body.staff-profile-page #tab-profile .security-card-grid .premium-card {
            min-height: 188px;
            justify-content: space-between;
        }

        body.staff-profile-page #tab-support > .dashboard-grid-layout {
            display: none !important;
        }

        body.staff-profile-page #tab-support .support-ticket-layout {
            display: grid;
            grid-template-columns: 0.82fr 1.18fr;
            gap: 1.5rem;
            align-items: stretch;
            margin-top: 0.35rem;
        }

        body.staff-profile-page #tab-support .support-ticket-layout .premium-card {
            background: #ffffff;
            padding: 1.5rem !important;
            gap: 1.25rem;
            overflow: hidden;
        }

        body.staff-profile-page #tab-support .support-ticket-layout.is-mailbox-only {
            grid-template-columns: 1fr;
            width: 100%;
            max-width: none;
            margin-left: 0;
            margin-right: 0;
        }

        body.staff-profile-page #tab-support .support-ticket-layout.is-mailbox-only .premium-card {
            width: 100%;
            min-height: 520px !important;
        }

        body.staff-profile-page #tab-support .support-ticket-layout .premium-card-header {
            margin-bottom: 1.25rem !important;
        }

        body.staff-profile-page #tab-support .support-ticket-layout .premium-card > div:not(.premium-card-header),
        body.staff-profile-page #tab-support .support-ticket-layout .premium-card > form {
            margin-top: 0.25rem;
        }

        body.staff-profile-page #tab-support .support-ticket-layout .premium-card > div[style*="grid-template-columns:repeat(3"] {
            margin-bottom: 0.35rem;
        }

        body.staff-profile-page #tab-support .support-ticket-layout textarea {
            min-height: 120px;
        }

        body.staff-profile-page .support-toolbar {
            display: grid;
            grid-template-columns: minmax(420px, calc((100% - 1rem) / 2)) 1fr 190px 190px;
            gap: 1rem;
            align-items: center;
            margin: 0.25rem 0 1.25rem;
        }

        body.staff-profile-page .support-search-input {
            width: 100%;
            border: 1px solid var(--border-dark);
            background: #f8fafc;
            border-radius: 999px;
            padding: 0.7rem 1rem;
            font-size: 0.88rem;
            font-weight: 650;
            color: var(--text-main);
            outline: none;
        }

        body.staff-profile-page .support-filter-select-wrap {
            position: relative;
            min-width: 190px;
        }

        body.staff-profile-page .support-filter-select-wrap::after {
            content: none;
        }

        body.staff-profile-page .support-filter-select {
            width: 100%;
            appearance: none !important;
            -webkit-appearance: none !important;
            -moz-appearance: none !important;
            border: 1px solid #bbf7d0;
            background: #ffffff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%23059669' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E") no-repeat right 1rem center / 1rem 1rem !important;
            color: #047857;
            border-radius: 999px;
            padding: 0.7rem 2.4rem 0.7rem 1rem;
            font-size: 0.88rem;
            font-weight: 900;
            cursor: pointer;
            outline: none;
            box-shadow: 0 8px 20px rgba(5, 150, 105, 0.08);
        }

        body.staff-profile-page .support-filter-select::-ms-expand {
            display: none;
        }

        body.staff-profile-page .support-filter-select:focus {
            border-color: #059669;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12);
        }

        body.staff-profile-page .system-management-card .management-toolbar .support-filter-select-wrap {
            position: relative;
            min-width: 190px;
            width: 100%;
        }

        body.staff-profile-page .system-management-card .management-toolbar .support-filter-select-wrap::after {
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

        body.staff-profile-page .system-management-card .management-toolbar .support-filter-select {
            width: 100% !important;
            appearance: none !important;
            -webkit-appearance: none !important;
            -moz-appearance: none !important;
            border: 1px solid #bbf7d0 !important;
            background: #ffffff !important;
            background-image: none !important;
            color: #047857 !important;
            border-radius: 999px !important;
            padding: 0.7rem 2.4rem 0.7rem 1rem !important;
            font-size: 0.88rem !important;
            font-weight: 900 !important;
            cursor: pointer !important;
            outline: none !important;
            box-shadow: 0 8px 20px rgba(5, 150, 105, 0.08) !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar .support-filter-select:focus {
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.12) !important;
        }

        body.staff-profile-page .system-management-card .management-toolbar .support-filter-select option {
            background: #ffffff !important;
            color: #475569 !important;
            font-weight: 700 !important;
        }

        body.staff-profile-page .support-ticket-card.is-hidden {
            display: none !important;
        }

        body.staff-profile-page .support-load-more-wrap {
            display: flex;
            justify-content: center;
            margin-top: 1.35rem;
        }

        body.staff-profile-page .support-load-more-btn {
            min-width: 260px;
            border: 2px solid #059669;
            background: #f0fdf4;
            color: #047857;
            border-radius: 999px;
            padding: 0.9rem 1.5rem;
            font-size: 0.95rem;
            font-weight: 900;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.65rem;
            box-shadow: 0 14px 28px rgba(5, 150, 105, 0.08);
            transition: background-color 0.18s ease, color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
        }

        body.staff-profile-page .support-load-more-btn:hover {
            background: #059669;
            color: #ffffff;
            box-shadow: 0 18px 34px rgba(5, 150, 105, 0.18);
            transform: translateY(-1px);
        }

        body.staff-profile-page .support-load-more-btn svg {
            width: 18px;
            height: 18px;
            stroke: currentColor;
        }

        body.staff-profile-page #support-ticket-list {
            margin-top: 1.35rem;
        }

        body.staff-profile-page .support-ticket-card {
            transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease, background-color 0.18s ease;
        }

        body.staff-profile-page .support-ticket-card:hover {
            border-color: #86efac !important;
            border-left-color: #059669 !important;
            box-shadow: 0 18px 36px rgba(5, 150, 105, 0.14) !important;
            transform: translateY(-2px);
            background: #f0fdf4 !important;
        }

        body.staff-profile-page .support-sender-line {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            min-width: 0;
        }

        body.staff-profile-page .support-sender-avatar {
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
            font-weight: 950;
            overflow: hidden;
            box-shadow: 0 8px 18px rgba(5, 150, 105, 0.08);
        }

        body.staff-profile-page .support-sender-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        body.staff-profile-page .support-sender-name {
            min-width: 0;
            color: #334155;
            font-weight: 850;
            font-size: 0.82rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page .support-ticket-title {
            display: block;
            color: #0f172a;
            font-weight: 900;
            font-size: 0.98rem;
            margin-top: 0.55rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        body.staff-profile-page #tab-support .support-ticket-layout.is-mailbox-only #support-ticket-list {
            display: grid !important;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem !important;
        }

        @media (max-width: 760px) {
            body.staff-profile-page .support-toolbar {
                grid-template-columns: 1fr;
            }

            body.staff-profile-page .support-filter-select-wrap {
                min-width: 0;
                grid-column: auto !important;
            }

            body.staff-profile-page #tab-support .support-ticket-layout.is-mailbox-only #support-ticket-list {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 1100px) {
            body.staff-profile-page #tab-support .support-ticket-layout {
                grid-template-columns: 1fr;
            }
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
        }

        .metric-card-title {
            color: var(--text-muted);
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            opacity: 0.9;
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

        .premium-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .premium-card-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--text-main);
            font-size: 1.05rem;
            font-weight: 800;
        }

        .premium-card-title svg {
            color: var(--primary);
        }

        .account-header-actions {
            display: flex;
            align-items: center;
            gap: 0.65rem;
            flex-wrap: wrap;
        }

        .profile-edit-btn {
            background: var(--primary) !important;
            color: #ffffff !important;
            box-shadow: 0 12px 24px rgba(5, 150, 105, 0.18);
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

        .teacher-approval-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.25rem;
        }

        .teacher-approval-card {
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.15rem;
            background: #ffffff;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
            display: flex;
            flex-direction: column;
            gap: 1rem;
            transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
        }

        .teacher-approval-card:hover {
            border-color: rgba(5, 150, 105, 0.28);
            box-shadow: 0 16px 34px rgba(15, 23, 42, 0.08);
            transform: translateY(-2px);
        }

        .teacher-approval-card-head {
            display: flex;
            justify-content: space-between;
            gap: 1rem;
            align-items: flex-start;
        }

        .teacher-approval-name {
            margin: 0;
            color: var(--text-main);
            font-size: 1.05rem;
            font-weight: 800;
            line-height: 1.35;
        }

        .teacher-approval-email {
            color: var(--text-muted);
            font-size: 0.82rem;
            font-weight: 600;
            margin-top: 0.2rem;
        }

        .teacher-application-status {
            flex-shrink: 0;
            border-radius: 999px;
            padding: 0.24rem 0.7rem;
            font-size: 0.72rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            background: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
        }

        .teacher-application-status.approved {
            background: #ecfdf5;
            color: #047857;
            border-color: #a7f3d0;
        }

        .teacher-application-status.rejected {
            background: #fef2f2;
            color: #dc2626;
            border-color: #fecaca;
        }

        .teacher-application-status.needs_more_info {
            background: #eff6ff;
            color: #2563eb;
            border-color: #bfdbfe;
        }

        .teacher-presence-status {
            flex-shrink: 0;
            border-radius: 999px;
            padding: 0.24rem 0.7rem;
            font-size: 0.72rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            border: 1px solid #e2e8f0;
            background: #f1f5f9;
            color: #64748b;
        }

        .teacher-presence-status.online {
            background: #dcfce7;
            color: #15803d;
            border-color: #bbf7d0;
        }

        .teacher-presence-status.offline {
            background: #f8fafc;
            color: #64748b;
            border-color: #e2e8f0;
        }

        .staff-class-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .staff-class-card {
            border: 1px solid #e2e8f0;
            border-radius: 0.9rem;
            padding: 1rem;
            background: #ffffff;
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 1rem;
            align-items: start;
        }

        body.staff-profile-page #tab-manage-classes .staff-class-card {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto;
            gap: 1rem;
            align-items: start;
            cursor: pointer;
            max-width: 680px;
        }

        .staff-class-title {
            margin: 0 0 0.45rem 0;
            font-size: 1.05rem;
            font-weight: 850;
            color: var(--text-main);
            line-height: 1.35;
        }

        .class-status-pill {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.22rem 0.65rem;
            font-size: 0.72rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.35px;
        }

        .class-status-pill.open { background: #dcfce7; color: #15803d; }
        .class-status-pill.upcoming { background: #fef9c3; color: #a16207; }
        .class-status-pill.closed { background: #fee2e2; color: #b91c1c; }

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

        .teacher-approval-meta-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.75rem;
        }

        .teacher-approval-meta {
            border-radius: 0.75rem;
            background: #f8fafc;
            padding: 0.75rem;
            border: 1px solid #eef2f7;
        }

        .teacher-approval-meta span {
            display: block;
            color: var(--text-muted);
            font-size: 0.72rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin-bottom: 0.25rem;
        }

        .teacher-approval-meta strong {
            color: var(--text-main);
            font-size: 0.88rem;
            line-height: 1.45;
        }

        .teacher-detail-open-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            gap: 0.45rem;
            border-radius: 0.8rem;
            padding: 0.7rem 0.95rem;
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #bbf7d0;
            font-size: 0.84rem;
            font-weight: 900;
            cursor: pointer;
            transition: background 0.2s ease, border-color 0.2s ease;
        }

        .teacher-detail-open-btn:hover {
            background: #d1fae5;
            border-color: #86efac;
        }

        .teacher-application-modal {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 1.25rem;
            background: rgba(15, 23, 42, 0.54);
            backdrop-filter: blur(9px);
            -webkit-backdrop-filter: blur(9px);
        }

        .teacher-application-modal.active {
            display: flex;
            animation: fadeInOverlay 0.18s ease forwards;
        }

        .teacher-application-modal-card {
            width: min(860px, 100%);
            max-height: min(86vh, 820px);
            margin: auto;
            overflow-y: auto;
            border-radius: 1.25rem;
            background: #ffffff;
            border: 1px solid rgba(187, 247, 208, 0.95);
            box-shadow: 0 30px 80px rgba(15, 23, 42, 0.28);
            color: var(--text-main);
            animation: centeredModalIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        @keyframes centeredModalIn {
            from { opacity: 0; transform: translateY(12px) scale(0.96); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .teacher-application-modal-head {
            position: sticky;
            top: 0;
            z-index: 1;
            background: linear-gradient(135deg, #ecfdf5 0%, #ffffff 100%);
            border-bottom: 1px solid #d1fae5;
            padding: 1.35rem 1.5rem 1.1rem;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1rem;
        }

        .teacher-application-modal-hero {
            flex: 1;
            text-align: center;
            padding-left: 2.25rem;
        }

        .teacher-application-modal-icon {
            width: 66px;
            height: 66px;
            border-radius: 999px;
            margin: 0 auto 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #059669;
            background: #d1fae5;
            border: 1px solid #a7f3d0;
            box-shadow: inset 0 0 0 1px rgba(5, 150, 105, 0.08);
        }

        .teacher-application-modal-title {
            margin: 0;
            color: var(--text-main);
            font-size: 1.35rem;
            font-weight: 900;
            line-height: 1.35;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .teacher-application-modal-subtitle {
            color: var(--text-muted);
            font-size: 0.9rem;
            font-weight: 700;
            margin-top: 0.4rem;
        }

        .teacher-application-modal-close {
            width: 36px;
            height: 36px;
            border-radius: 999px;
            border: 1px solid #d1fae5;
            background: #ffffff;
            color: #475569;
            font-size: 1.2rem;
            line-height: 1;
            cursor: pointer;
            flex-shrink: 0;
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.08);
        }

        .teacher-application-modal-body {
            display: flex;
            flex-direction: column;
            gap: 1.1rem;
            padding: 1.4rem 1.6rem 1.6rem;
        }

        .teacher-application-modal .teacher-approval-meta {
            background: #f8fafc;
            border-color: #e2e8f0;
        }

        .teacher-application-modal .teacher-approval-meta span,
        .teacher-application-modal .teacher-approval-section-title {
            color: #059669;
        }

        .teacher-application-modal .teacher-approval-meta strong {
            color: var(--text-main);
        }

        .teacher-application-modal .teacher-approval-note {
            color: var(--text-muted);
        }

        .teacher-detail-panel {
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            background: #ffffff;
            padding: 1rem;
        }

        .teacher-approval-detail-body {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .teacher-approval-section-title {
            color: var(--text-main);
            font-size: 0.82rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin: 0 0 0.4rem 0;
        }

        .teacher-approval-note {
            color: var(--text-muted);
            font-size: 0.86rem;
            line-height: 1.6;
            margin: 0;
            white-space: pre-wrap;
        }

        .teacher-review-form {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            padding: 1rem;
            border-radius: 1rem;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .teacher-application-modal .form-group-edit label {
            color: var(--text-main);
        }

        .teacher-application-modal .form-group-edit textarea {
            background: #ffffff;
            border-color: #cbd5e1;
            color: var(--text-main);
        }

        .teacher-review-actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.65rem;
            flex-wrap: wrap;
        }

        .teacher-review-btn {
            border: none;
            border-radius: 999px;
            padding: 0.55rem 0.95rem;
            font-size: 0.78rem;
            font-weight: 900;
            cursor: pointer;
            color: #ffffff;
        }

        .teacher-review-btn.approve { background: #059669; }
        .teacher-review-btn.more { background: #2563eb; }
        .teacher-review-btn.reject { background: #dc2626; }

        .teacher-review-btn.cancel {
            background: #ffffff;
            color: var(--text-main);
            border: 1px solid #cbd5e1;
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
            .teacher-approval-grid {
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
            .teacher-approval-meta-grid {
                grid-template-columns: 1fr;
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



        .dashboard-main-section {
            display: flex;
            flex-direction: column;
            min-width: 0;
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
        }

        .nav-bell-trigger:hover {
            background: var(--primary-light);
            color: var(--primary);
            transform: translateY(-1px);
        }

        .dashboard-content-wrapper {
            height: auto !important;
            min-height: 0 !important;
            max-height: none !important;
            overflow: visible !important;
            flex: 1;
            padding: 2rem !important;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            gap: 2rem;
            background: #f9fafb !important;
            border: 1px solid var(--border-dark) !important;
            border-radius: 1.5rem !important;
            box-shadow: var(--shadow) !important;
        }

        .app-dashboard-container.collapsed .dashboard-body {
            grid-template-columns: 80px minmax(0, 1fr);
        }

        .app-dashboard-container.collapsed .dashboard-sidebar {
            width: 80px !important;
            padding: 1.5rem 0.5rem !important;
            align-items: center;
        }

        .app-dashboard-container.collapsed .sidebar-brand-horizontal {
            flex-direction: column;
            gap: 1rem;
            align-items: center;
        }

        .app-dashboard-container.collapsed .brand-text-col,
        .app-dashboard-container.collapsed .sidebar-menu li a span,
        .app-dashboard-container.collapsed .sidebar-section-label {
            display: none !important;
            opacity: 0;
            visibility: hidden;
        }

        .app-dashboard-container.collapsed .sidebar-toggle-btn {
            margin-left: 0;
        }

        .app-dashboard-container.collapsed .sidebar-toggle-btn .icon-collapse {
            display: none !important;
        }

        .app-dashboard-container.collapsed .sidebar-toggle-btn .icon-expand {
            display: block !important;
        }

        .app-dashboard-container.collapsed .sidebar-menu li a {
            width: 44px;
            height: 44px;
            padding: 0 !important;
            justify-content: center !important;
            margin: 0 auto;
        }

        .app-dashboard-container.collapsed .sidebar-menu li a.active::before {
            display: none !important;
        }

        @media (max-width: 1024px) {
            .dashboard-body {
                grid-template-columns: 1fr;
            }

            .dashboard-sidebar {
                width: 100% !important;
                height: auto !important;
                position: static !important;
            }

            .dashboard-top-bar {
                padding: 0 1rem;
            }
        }

        /* ===== BUTTON & FORM PREMIUM STYLES (MATCHING TEACHER PROFILE) ===== */
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
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        body.staff-profile-page {
            background: linear-gradient(135deg, #e6fcf5 0%, #ebfbee 50%, #dcfce7 100%) !important;
            background-attachment: fixed !important;
            font-family: var(--font-sans);
            margin: 0;
            padding: 0;
            min-height: 0;
            overflow-x: hidden;
        }

        body.staff-profile-page > .navbar {
            display: none !important;
        }

        body.staff-profile-page .app-dashboard-container {
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

        body.staff-profile-page .dashboard-sidebar {
            width: 270px;
            background: #ffffff;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            padding: 1.5rem 1.25rem;
            position: sticky;
            top: 0.75rem;
            height: calc(100vh - 1.5rem);
            box-shadow: var(--shadow);
            overflow-y: auto;
            overflow-x: hidden;
        }

        body.staff-profile-page .dashboard-sidebar::-webkit-scrollbar {
            width: 6px;
        }

        body.staff-profile-page .dashboard-sidebar::-webkit-scrollbar-thumb {
            background: transparent;
            border-radius: 999px;
        }

        body.staff-profile-page .dashboard-sidebar:hover::-webkit-scrollbar-thumb {
            background: rgba(100, 116, 139, 0.22);
        }

        body.staff-profile-page::-webkit-scrollbar {
            width: 8px;
        }

        body.staff-profile-page::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }

        body.staff-profile-page::-webkit-scrollbar-track {
            background: #f1f5f9;
        }

        body.staff-profile-page .sidebar-brand-horizontal {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 27px;
            width: 100%;
            text-decoration: none;
        }

        body.staff-profile-page .brand-avatar-box {
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

        body.staff-profile-page .brand-avatar-box img {
            width: 34px;
            height: 34px;
            object-fit: contain;
            animation: none;
            filter: none;
        }

        body.staff-profile-page .brand-text-col {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: flex-start;
            min-width: 0;
        }

        body.staff-profile-page .brand-title {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--text-main);
            line-height: 1.2;
            white-space: nowrap;
            letter-spacing: 0;
            background: none;
            -webkit-background-clip: initial;
            background-clip: initial;
            -webkit-text-fill-color: var(--text-main);
        }

        body.staff-profile-page .brand-subtitle {
            display: block;
            font-size: 0.65rem;
            font-weight: 800;
            color: var(--text-muted);
            letter-spacing: 0.8px;
            text-transform: uppercase;
            margin-top: 0.08rem;
            white-space: nowrap;
        }

        body.staff-profile-page .sidebar-toggle-btn {
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
            flex-shrink: 0;
        }

        body.staff-profile-page .sidebar-toggle-btn:hover {
            color: var(--primary);
            background: var(--primary-light);
            border-color: rgba(4, 120, 87, 0.2);
            transform: scale(1.05);
        }

        body.staff-profile-page .sidebar-menu li a {
            min-height: 46px;
            box-sizing: border-box;
        }

        body.staff-profile-page .dashboard-main-section {
            display: flex;
            flex-direction: column;
            min-width: 0;
            gap: 1rem;
            flex: 1;
        }

        body.staff-profile-page .dashboard-top-bar {
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
            box-shadow: var(--shadow);
        }

        body.staff-profile-page .dashboard-content-wrapper {
            background: #f8fafc;
            border: 1px solid var(--border-dark);
            border-radius: 1.5rem;
            padding: 2.5rem;
            box-shadow: var(--shadow-lg);
            min-height: calc(100vh - 6.75rem);
            overflow: visible;
        }

        body.staff-profile-page .premium-card,
        body.staff-profile-page .profile-card {
            border-radius: 1.5rem !important;
            border: 1px solid var(--border-dark) !important;
            box-shadow: var(--shadow) !important;
        }

        @media (max-width: 1024px) {
            body.staff-profile-page .app-dashboard-container {
                flex-direction: column;
                width: calc(100% - 1rem);
            }

            body.staff-profile-page .dashboard-sidebar {
                position: relative;
                top: 0;
                width: 100%;
                height: auto;
            }

            body.staff-profile-page .dashboard-top-bar {
                padding: 0 1rem;
            }
        }
    </style>
</head>
<body class="staff-profile-page">

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
        List<TeacherApplication> teacherApplications = (List<TeacherApplication>) request.getAttribute("teacherApplications");
        List<AdminUserSummary> managedUsers = (List<AdminUserSummary>) request.getAttribute("managedUsers");
        List<Classroom> managedClassrooms = (List<Classroom>) request.getAttribute("managedClassrooms");
        List<String> classSubjects = (List<String>) request.getAttribute("classSubjects");
        List<Course> managedCourses = (List<Course>) request.getAttribute("managedCourses");
        List<Course> courseSubjects = (List<Course>) request.getAttribute("courseSubjects");
        List<SupportTicket> staffSupportTickets = (List<SupportTicket>) request.getAttribute("staffSupportTickets");
        SupportTicket selectedSupportTicket = (SupportTicket) request.getAttribute("selectedSupportTicket");
        List<SupportMessage> supportMessages = (List<SupportMessage>) request.getAttribute("supportMessages");
        int supportOpenCount = 0;
        int supportWaitingStaffCount = 0;
        int supportResolvedCount = 0;
        int supportUnreadTodayCount = 0;
        int supportViewedCount = 0;
        String todaySupportKey = new SimpleDateFormat("yyyyMMdd").format(new Date());
        if (staffSupportTickets != null) {
            for (SupportTicket supportTicket : staffSupportTickets) {
                if (supportTicket == null || supportTicket.getStatus() == null) continue;
                if ("resolved".equals(supportTicket.getStatus()) || "closed".equals(supportTicket.getStatus())) {
                    supportResolvedCount++;
                } else {
                    supportOpenCount++;
                    if ("waiting_staff".equals(supportTicket.getStatus()) || "open".equals(supportTicket.getStatus())) {
                        supportWaitingStaffCount++;
                    }
                }
                boolean supportUnread = supportTicket.getUnreadMessageCount() > 0;
                if (!supportUnread) {
                    supportViewedCount++;
                } else if (supportTicket.getLatestUserMessageAt() != null
                        && todaySupportKey.equals(new SimpleDateFormat("yyyyMMdd").format(supportTicket.getLatestUserMessageAt()))) {
                    supportUnreadTodayCount++;
                }
            }
        }
        String searchUser = (String) request.getAttribute("searchUser");
        if (searchUser == null) searchUser = "";
        String userRoleParam = (String) request.getAttribute("userRole");
        if (userRoleParam == null || userRoleParam.isEmpty()) userRoleParam = "ALL";
        String userStatusParam = (String) request.getAttribute("userStatus");
        if (userStatusParam == null || userStatusParam.isEmpty()) userStatusParam = "ALL";
        String classTitle = (String) request.getAttribute("classTitle");
        if (classTitle == null) classTitle = "";
        String classSubjectParam = (String) request.getAttribute("classSubject");
        if (classSubjectParam == null || classSubjectParam.isEmpty()) classSubjectParam = "ALL";
        String classStatusParam = (String) request.getAttribute("classStatus");
        if (classStatusParam == null || classStatusParam.isEmpty()) classStatusParam = "ALL";
        String courseTitle = (String) request.getAttribute("courseTitle");
        if (courseTitle == null) courseTitle = "";
        String courseSubjectParam = (String) request.getAttribute("courseSubject");
        if (courseSubjectParam == null || courseSubjectParam.isEmpty()) courseSubjectParam = "ALL";
        String courseStatusParam = (String) request.getAttribute("courseStatus");
        if (courseStatusParam == null || courseStatusParam.isEmpty()) courseStatusParam = "ALL";
        String userRoleFilterLabel = "ALL".equals(userRoleParam) ? "Tất cả" : userRoleLabel(userRoleParam);
        String userStatusFilterLabel = "Tất cả";
        if ("active".equals(userStatusParam)) userStatusFilterLabel = "Đang hoạt động";
        else if ("disabled".equals(userStatusParam)) userStatusFilterLabel = "Bị ban";
        String classSubjectFilterLabel = "ALL".equals(classSubjectParam) ? "Tất cả môn học" : classSubjectParam;
        String classStatusFilterLabel = "Tất cả trạng thái";
        if ("open".equals(classStatusParam)) classStatusFilterLabel = "Đang mở";
        else if ("upcoming".equals(classStatusParam)) classStatusFilterLabel = "Sắp khai giảng";
        else if ("closed".equals(classStatusParam)) classStatusFilterLabel = "Đã đóng";
        String courseSubjectFilterLabel = "Tất cả môn học";
        if (courseSubjects != null && !"ALL".equals(courseSubjectParam)) {
            for (Course subject : courseSubjects) {
                if (subject.getSubjectCode() != null && subject.getSubjectCode().equals(courseSubjectParam)) {
                    courseSubjectFilterLabel = subject.getSubjectName();
                    break;
                }
            }
        }
        String courseStatusFilterLabel = "Tất cả trạng thái";
        if ("pending_review".equals(courseStatusParam)) courseStatusFilterLabel = "Chờ duyệt";
        else if ("approved".equals(courseStatusParam)) courseStatusFilterLabel = "Đã duyệt";
        else if ("needs_revision".equals(courseStatusParam)) courseStatusFilterLabel = "Cần chỉnh sửa";
        else if ("rejected".equals(courseStatusParam)) courseStatusFilterLabel = "Từ chối";
        Object staffTotalUsersObj = request.getAttribute("staffTotalUsers");
        int staffTotalUsers = staffTotalUsersObj instanceof Number ? ((Number) staffTotalUsersObj).intValue() : 0;
        Object staffActiveClassCountObj = request.getAttribute("staffActiveClassCount");
        int staffActiveClassCount = staffActiveClassCountObj instanceof Number ? ((Number) staffActiveClassCountObj).intValue() : 0;
        Object staffCourseCountObj = request.getAttribute("staffCourseCount");
        int staffCourseCount = staffCourseCountObj instanceof Number ? ((Number) staffCourseCountObj).intValue() : 0;
        Object staffMaterialCountObj = request.getAttribute("staffMaterialCount");
        int staffMaterialCount = staffMaterialCountObj instanceof Number ? ((Number) staffMaterialCountObj).intValue() : 0;
        StaffUserGrowthStats staffUserGrowthStats = (StaffUserGrowthStats) request.getAttribute("staffUserGrowthStats");
        if (staffUserGrowthStats == null) {
            staffUserGrowthStats = new StaffUserGrowthStats();
        }
        List<MockExam> staffMockExams = (List<MockExam>) request.getAttribute("staffMockExams");
        String staffWeeklyUserGrowthJson = staffUserGrowthJson(staffUserGrowthStats.getWeeklyPoints());
        String staffMonthlyUserGrowthJson = staffUserGrowthJson(staffUserGrowthStats.getMonthlyPoints());
        String activeStaffTab = request.getParameter("tab");
        if (activeStaffTab == null || activeStaffTab.trim().isEmpty()) {
            activeStaffTab = "tab-teacher-approval";
        } else {
            activeStaffTab = activeStaffTab.trim();
            if (!activeStaffTab.startsWith("tab-")) {
                activeStaffTab = "tab-" + activeStaffTab;
            }
            if ("tab-security".equals(activeStaffTab)) {
                activeStaffTab = "tab-profile";
            }
            if (!activeStaffTab.equals("tab-teacher-approval") &&
                !activeStaffTab.equals("tab-manage-teachers") &&
                !activeStaffTab.equals("tab-manage-classes") &&
                !activeStaffTab.equals("tab-manage-courses") &&
                !activeStaffTab.equals("tab-transaction-management") &&
                !activeStaffTab.equals("tab-overview") &&
                !activeStaffTab.equals("tab-profile") &&
                !activeStaffTab.equals("tab-edit") &&
                !activeStaffTab.equals("tab-materials") &&
                !activeStaffTab.equals("tab-mock-exams") &&
                !activeStaffTab.equals("tab-practice") &&
                !activeStaffTab.equals("tab-support")) {
                activeStaffTab = "tab-teacher-approval";
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
                        <a onclick="switchTab('tab-overview')">
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
                    <a id="nav-tab-overview" class="<%= "tab-overview".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-overview')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/></svg>
                        <span>Tổng quan</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-profile" class="<%= ("tab-profile".equals(activeStaffTab) || "tab-edit".equals(activeStaffTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        <span>Hồ sơ cá nhân</span>
                    </a>
                </li>

                <li>
                    <a id="nav-tab-support" class="<%= "tab-support".equals(activeStaffTab) ? "active" : "" %>" onclick="window.location.href='${pageContext.request.contextPath}/staff-profile?tab=support'">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <span>Hỗ trợ nghiệp vụ</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">Quản lý hệ thống</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-teacher-approval" class="<%= "tab-teacher-approval".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-teacher-approval')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/></svg>
                        <span>Duyệt hồ sơ giảng viên</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-manage-teachers" class="<%= "tab-manage-teachers".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-manage-teachers')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        <span>Quản lý người dùng</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-manage-classes" class="<%= "tab-manage-classes".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-manage-classes')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                        <span>Quản lý lớp học</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-manage-courses" class="<%= "tab-manage-courses".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-manage-courses')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 6.5v12"/><path d="M5 8.5c2.6 0 4.9.5 7 2 2.1-1.5 4.4-2 7-2v11c-2.6 0-4.9.5-7 2-2.1-1.5-4.4-2-7-2z"/></svg>
                        <span>Quản lý khóa học</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-transaction-management" class="<%= "tab-transaction-management".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-transaction-management')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M7 15h3"/><path d="M15 15h2"/></svg>
                        <span>Quản lý giao dịch</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-materials" class="<%= "tab-materials".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-materials')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
                        <span>Hàng đợi duyệt tài liệu</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-mock-exams" class="<%= "tab-mock-exams".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-mock-exams')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                        <span>Đăng tải thi thử</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-practice" class="<%= "tab-practice".equals(activeStaffTab) ? "active" : "" %>" onclick="switchTab('tab-practice')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/></svg>
                        <span>Đăng ký giảng viên</span>
                    </a>
                </li>
            </ul>
            </aside>

            <!-- KÊNH NỘI DUNG PHẢI (RIGHT CONTENT PANE) -->
            <div class="dashboard-main-section">
                <div class="dashboard-top-bar">
                    <div class="top-bar-search-wrapper">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Tìm kiếm tác vụ...">
                    </div>

                    <div class="top-bar-right">
                        <button type="button" class="nav-bell-trigger" title="Chuyển chế độ sáng/tối" onclick="alert('Chức năng chuyển đổi giao diện sáng/tối đang được phát triển.')">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
                        </button>

                        <a href="${pageContext.request.contextPath}/logout" class="nav-bell-trigger" title="Đăng xuất">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        </a>
                        <div class="top-bar-user-card" onclick="switchTab('tab-profile')">
                            <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                <img src="<%= user.getAvatarUrl() %>" class="top-bar-avatar" alt="Avatar">
                            <% } else { %>
                                <div class="top-bar-avatar-placeholder"><%= initials %></div>
                            <% } %>
                            <div class="top-bar-user-info">
                                <span class="top-bar-user-name"><%= user != null ? user.getDisplayName() : "Nhân viên HIPZI" %></span>
                                <span class="top-bar-user-email"><%= user != null ? user.getEmail() : "staff@hipzi.vn" %></span>
                            </div>
                        </div>
                    </div>
                </div>

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
            <section id="tab-teacher-approval" class="tab-pane <%= "tab-teacher-approval".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Duyệt hồ sơ giảng viên</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card system-management-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/></svg>
                                    <span>Hồ sơ giảng viên đã đăng kí giảng dạy</span>
                                </div>
                                <span style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">
                                    <%= teacherApplications != null ? teacherApplications.size() : 0 %> hồ sơ
                                </span>
                            </div>

                            <div class="management-toolbar">
                                <input id="teacher-approval-search" type="search" placeholder="Tìm hồ sơ giảng viên">
                                <input id="teacher-approval-status-filter" type="hidden" value="all">
                                <div class="management-filter-dropdown" data-target-input="teacher-approval-status-filter">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label">Tất cả trạng thái</span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option is-selected" data-value="all">Tất cả trạng thái <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option" data-value="pending">Chờ duyệt <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option" data-value="approved">Đã duyệt <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option" data-value="needs_more_info">Cần bổ sung <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option" data-value="rejected">Từ chối <span class="management-filter-check">&#10003;</span></button>
                                    </div>
                                </div>
                            </div>

                            <% if (teacherApplications != null && !teacherApplications.isEmpty()) { %>
                                <div class="teacher-approval-grid" style="padding-top:1.5rem;">
                                    <% for (TeacherApplication app : teacherApplications) {
                                        String status = app.getStatus() != null ? app.getStatus() : "pending";
                                        String approvalSearchText = (String.valueOf(app.getApplicantName()) + " "
                                                + String.valueOf(app.getApplicantEmail()) + " "
                                                + String.valueOf(app.getTeachingSubjects()) + " "
                                                + String.valueOf(app.getInstitutionName()) + " "
                                                + String.valueOf(app.getSpecialization()) + " "
                                                + teacherTypeLabel(app.getTeacherType())).toLowerCase();
                                        String applicantName = app.getApplicantName() != null ? app.getApplicantName().trim() : "";
                                        String applicantInitial = "G";
                                        if (!applicantName.isEmpty()) {
                                            String[] applicantNameParts = applicantName.split("\\s+");
                                            applicantInitial = applicantNameParts[applicantNameParts.length - 1].substring(0, 1).toUpperCase();
                                        }
                                        String applicationSubmittedAt = app.getSubmittedAt() != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(app.getSubmittedAt()) : "Chưa có dữ liệu";
                                    %>
                                        <div class="teacher-approval-card" data-approval-status="<%= h(status) %>" data-approval-search="<%= h(approvalSearchText) %>">
                                            <div class="teacher-application-summary"
                                                 role="button"
                                                 tabindex="0"
                                                 onclick="openTeacherApplicationModal('teacher-application-modal-<%= h(app.getId()) %>')"
                                                 onkeydown="if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); openTeacherApplicationModal('teacher-application-modal-<%= h(app.getId()) %>'); }">
                                                <div class="teacher-application-summary-top">
                                                    <div class="teacher-application-summary-identity">
                                                        <span class="teacher-application-summary-line">
                                                            <span class="teacher-application-summary-avatar"><%= h(applicantInitial) %></span>
                                                            <span class="teacher-application-summary-name"><%= h(app.getApplicantName()) %></span>
                                                        </span>
                                                        <span class="teacher-application-summary-title"><%= h(app.getApplicantEmail()) %></span>
                                                    </div>
                                                    <span class="teacher-application-status <%= h(status) %>"><%= applicationStatusLabel(status) %></span>
                                                </div>
                                                <div class="teacher-application-summary-bottom">
                                                    <span class="teacher-application-summary-role">Nhóm: <%= teacherTypeLabel(app.getTeacherType()) %></span>
                                                    <span class="teacher-application-summary-date">Ngày gửi: <%= h(applicationSubmittedAt) %></span>
                                                </div>
                                            </div>

                                            <div id="teacher-application-modal-<%= h(app.getId()) %>" class="teacher-application-modal" onclick="closeTeacherApplicationModalOnBackdrop(event, this)">
                                                <div class="teacher-application-modal-card" role="dialog" aria-modal="true" aria-labelledby="teacher-application-title-<%= h(app.getId()) %>">
                                                    <div class="teacher-application-modal-head">
                                                        <div class="teacher-application-modal-hero">
                                                            <div class="teacher-application-modal-icon">
                                                                <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                                                            </div>
                                                            <h3 id="teacher-application-title-<%= h(app.getId()) %>" class="teacher-application-modal-title"><%= h(app.getApplicantName()) %></h3>
                                                            <div class="teacher-application-modal-subtitle"><%= h(app.getApplicantEmail()) %> · <%= teacherTypeLabel(app.getTeacherType()) %></div>
                                                        </div>
                                                        <button type="button" class="teacher-application-modal-close" onclick="closeTeacherApplicationModal('teacher-application-modal-<%= h(app.getId()) %>')">&times;</button>
                                                    </div>
                                                    <div class="teacher-application-modal-body">
                                                        <div class="teacher-approval-meta-grid">
                                                            <div class="teacher-approval-meta">
                                                                <span>Nhóm giảng viên</span>
                                                                <strong><%= teacherTypeLabel(app.getTeacherType()) %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Trạng thái</span>
                                                                <strong><%= applicationStatusLabel(status) %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Môn có thể dạy</span>
                                                                <strong><%= h(app.getTeachingSubjects()) %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Đơn vị / trường</span>
                                                                <strong><%= h(app.getInstitutionName()) %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Chuyên môn</span>
                                                                <strong><%= h(app.getSpecialization()) %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Năm học hiện tại</span>
                                                                <strong><%= studyYearLabel(app.getCurrentStudyYear()) %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Nơi công tác</span>
                                                                <strong><%= app.getWorkplace() != null && !app.getWorkplace().trim().isEmpty() ? h(app.getWorkplace()) : "Chưa cung cấp" %></strong>
                                                            </div>
                                                            <div class="teacher-approval-meta">
                                                                <span>Ngày gửi</span>
                                                                <strong><%= app.getSubmittedAt() != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(app.getSubmittedAt()) : "Chưa có dữ liệu" %></strong>
                                                            </div>
                                                        </div>
                                                        <div class="teacher-approval-detail-body">
                                            <div class="teacher-detail-panel">
                                                <p class="teacher-approval-section-title">Hồ sơ cá nhân</p>
                                                <p class="teacher-approval-note"><%= h(app.getTeacherBio()) %></p>
                                            </div>

                                            <div class="teacher-detail-panel">
                                                <p class="teacher-approval-section-title">Kinh nghiệm / chứng chỉ</p>
                                                <p class="teacher-approval-note"><%= h(app.getTeachingExperience()) %><% if (app.getCredentialsSummary() != null && !app.getCredentialsSummary().trim().isEmpty()) { %>
<%= h(app.getCredentialsSummary()) %><% } %></p>
                                            </div>

                                            <div class="teacher-detail-panel">
                                                <p class="teacher-approval-section-title">Minh chứng</p>
                                                <div class="teacher-approval-note">
                                                    <%
                                                        String ev = app.getEvidenceSummary();
                                                        if (ev == null || ev.trim().isEmpty() || "Chưa đính kèm minh chứng.".equals(ev)) {
                                                            out.print(h(ev != null ? ev : "Chưa đính kèm minh chứng."));
                                                        } else {
                                                            String[] lines = ev.split("\n");
                                                            for (String line : lines) {
                                                                if (line.trim().isEmpty()) continue;
                                                                int colonIdx = line.indexOf(": /");
                                                                if (colonIdx != -1) {
                                                                    String textPart = line.substring(0, colonIdx);
                                                                    String urlPart = line.substring(colonIdx + 2).trim();
                                                    %>
                                                                    <div style="margin-bottom: 0.35rem;">
                                                                        <%= h(textPart) %>: 
                                                                        <a href="<%= h(urlPart) %>" target="_blank" style="color: #047857; text-decoration: underline; font-weight: 600;">Xem minh chứng &rarr;</a>
                                                                    </div>
                                                    <%
                                                                } else {
                                                    %>
                                                                    <div style="margin-bottom: 0.35rem;"><%= h(line) %></div>
                                                    <%
                                                                }
                                                            }
                                                        }
                                                    %>
                                                </div>
                                            </div>

                                            <form action="${pageContext.request.contextPath}/staff-profile" method="POST" class="teacher-review-form">
                                                <input type="hidden" name="action" value="reviewTeacherApplication">
                                                <input type="hidden" name="applicationId" value="<%= h(app.getId()) %>">
                                                <div class="form-group-edit">
                                                    <label>Ghi chú duyệt hồ sơ</label>
                                                    <textarea name="reviewNote" rows="2" placeholder="Nhập ghi chú phản hồi cho hồ sơ này..."><%= h(app.getReviewNote()) %></textarea>
                                                </div>
                                                <div class="teacher-review-actions">
                                                    <button type="button" class="teacher-review-btn cancel" onclick="closeTeacherApplicationModal('teacher-application-modal-<%= h(app.getId()) %>')">Hủy bỏ</button>
                                                    <button type="submit" name="decision" value="approved" class="teacher-review-btn approve">Duyệt</button>
                                                    <button type="submit" name="decision" value="rejected" class="teacher-review-btn reject">Từ chối</button>
                                                </div>
                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="empty-status-panel" style="padding:4rem 2rem;">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    <span style="font-weight:700; color:var(--text-main);">Chưa có hồ sơ giảng viên nào</span>
                                    <p style="font-size:0.85rem; max-width:420px; margin:0;">Khi giảng viên gửi hồ sơ ở tab Đăng kí giảng dạy, hồ sơ sẽ xuất hiện tại đây để nhân viên rà soát và cập nhật trạng thái.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: QUẢN LÝ NGƯỜI DÙNG                   -->
            <!-- ========================================== -->
            <section id="tab-manage-teachers" class="tab-pane <%= "tab-manage-teachers".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Quản lý người dùng</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                    <div class="tab-body-content">
                        <div class="section-data-card system-management-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                    <span>Danh sách người dùng</span>
                                </div>
                                <span><%= managedUsers != null ? managedUsers.size() : 0 %> người dùng</span>
                            </div>

                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/staff-profile" style="display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap; background: #f8fafc; padding: 1rem; border-radius: 0.75rem; border: 1px solid #e2e8f0;">
                                <input type="hidden" name="tab" value="manage-teachers">
                                <input type="text" name="searchUser" value="<%= h(searchUser) %>" placeholder="Tìm tên hoặc email người dùng..." style="flex: 1; min-width: 200px; padding: 0.6rem 1rem; border: 1px solid #cbd5e1; border-radius: 0.5rem; outline: none; font-size: 0.9rem;">
                                <input id="user-role-filter" type="hidden" name="userRole" value="<%= h(userRoleParam) %>">
                                <div class="management-filter-dropdown" data-target-input="user-role-filter" data-submit-on-change="true">
                                    <button type="button" class="management-filter-trigger" aria-haspopup="listbox" aria-expanded="false">
                                        <span class="management-filter-label"><%= h(userRoleFilterLabel) %></span>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
                                    </button>
                                    <div class="management-filter-menu" role="listbox">
                                        <button type="button" class="management-filter-option <%= "ALL".equals(userRoleParam) ? "is-selected" : "" %>" data-value="ALL">Tất cả <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "teacher".equals(userRoleParam) ? "is-selected" : "" %>" data-value="teacher">Giảng viên <span class="management-filter-check">&#10003;</span></button>
                                        <button type="button" class="management-filter-option <%= "student".equals(userRoleParam) ? "is-selected" : "" %>" data-value="student">Học sinh <span class="management-filter-check">&#10003;</span></button>
                                    </div>
                                </div>
                                <input id="user-status-filter" type="hidden" name="userStatus" value="<%= h(userStatusParam) %>">
                                <div class="management-filter-dropdown" data-target-input="user-status-filter" data-submit-on-change="true">
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

                            <% if (managedUsers != null && !managedUsers.isEmpty()) { %>
                                <div class="user-management-table">
                                    <div class="user-management-row user-management-head">
                                        <span>Người dùng</span>
                                        <span>Vai trò</span>
                                        <span>Tài khoản</span>
                                        <span>Trực tuyến</span>
                                    </div>
                                    <% for (AdminUserSummary managedUser : managedUsers) {
                                        boolean managedUserOnline = UserStatusWebSocket.isUserOnline(managedUser.getId());
                                        String managedUserRoleNames = managedUser.getRoles() != null ? managedUser.getRoles() : "";
                                        boolean isTeacherUser = managedUserRoleNames.toLowerCase().contains("teacher");
                                        String managedUserName = managedUser.getDisplayName() != null ? managedUser.getDisplayName().trim() : "";
                                        String managedUserInitial = "U";
                                        if (!managedUserName.isEmpty()) {
                                            String[] managedUserNameParts = managedUserName.split("\\s+");
                                            managedUserInitial = managedUserNameParts[managedUserNameParts.length - 1].substring(0, 1).toUpperCase();
                                        }
                                        String accountStatus = managedUser.getAccountStatus() != null ? managedUser.getAccountStatus().toLowerCase() : "";
                                        String statusClass = "disabled".equals(accountStatus) ? "disabled" : "active";
                                    %>
                                        <div class="user-management-row user-management-item">
                                            <div class="user-management-main">
                                                <span class="user-management-avatar" style="background:<%= isTeacherUser ? "#dcfce7" : "#e0f2fe" %>; color:<%= isTeacherUser ? "#047857" : "#0284c7" %>; border-color:<%= isTeacherUser ? "#bbf7d0" : "#bae6fd" %>;"><%= h(managedUserInitial) %></span>
                                                <div style="min-width:0;">
                                                    <span class="user-management-name"><%= h(managedUser.getDisplayName()) %></span>
                                                    <span class="user-management-email"><%= h(managedUser.getEmail()) %></span>
                                                </div>
                                            </div>
                                            <div class="user-management-cell"><%= h(userRoleLabel(managedUserRoleNames)) %></div>
                                            <div class="user-management-cell">
                                                <span class="user-management-pill <%= h(statusClass) %>"><%= h(userStatusLabel(managedUser.getAccountStatus())) %></span>
                                            </div>
                                            <div class="user-management-cell">
                                                <span class="teacher-presence-status <%= managedUserOnline ? "online" : "offline" %>" data-teacher-status-user-id="<%= h(managedUser.getId()) %>"><%= managedUserOnline ? "Online" : "Offline" %></span>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="empty-status-panel" style="padding:4rem 2rem;">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="opacity: 0.5; margin-bottom: 1rem;"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                    <span style="font-weight:700; color:var(--text-main);">Không tìm thấy người dùng</span>
                                    <p style="font-size:0.85rem; max-width:420px; margin:0; margin-top: 0.5rem;">Không có giảng viên hoặc học sinh phù hợp với bộ lọc hiện tại.</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB: QUẢN LÝ LỚP HỌC (MOCKUP)             -->
            <!-- ========================================== -->
            <section id="tab-manage-classes" class="tab-pane <%= "tab-manage-classes".equals(activeStaffTab) ? "active-pane" : "" %>">
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

                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/staff-profile" style="display:flex; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap; background:#f8fafc; padding:1rem; border-radius:0.75rem; border:1px solid #e2e8f0;">
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
                                                    <form action="${pageContext.request.contextPath}/staff-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa lớp học này khỏi hệ thống?');">
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

            <section id="tab-manage-courses" class="tab-pane <%= "tab-manage-courses".equals(activeStaffTab) ? "active-pane" : "" %>">
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

                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/staff-profile" style="display:flex; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap; background:#f8fafc; padding:1rem; border-radius:0.75rem; border:1px solid #e2e8f0;">
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
                                                <form action="${pageContext.request.contextPath}/staff-profile" method="POST" style="display:flex; flex-direction:column; gap:0.75rem; margin-top:1rem;">
                                                    <input type="hidden" name="action" value="reviewCourse">
                                                    <input type="hidden" name="courseId" value="<%= h(course.getId()) %>">
                                                    <textarea name="reviewNote" rows="3" placeholder="Ghi chú duyệt hoặc yêu cầu chỉnh sửa..." style="width:100%; resize:vertical; padding:0.8rem 0.9rem; border:1px solid #cbd5e1; border-radius:0.8rem; font-size:0.9rem;"><%= h(course.getReviewNote()) %></textarea>
                                                    <div class="class-detail-actions" style="margin-top:0; padding-top:0; border-top:0;">
                                                        <button type="button" class="class-detail-cancel" onclick="closeClassDetailModal('<%= h(courseModalId) %>')">Hủy bỏ</button>
                                                        <button type="submit" name="decision" value="approved" class="class-detail-cancel" style="border-color:#bbf7d0; color:#047857;">Duyệt</button>
                                                        <button type="submit" name="decision" value="rejected" class="class-detail-delete">Từ chối</button>
                                                    </div>
                                                </form>
                                                <form action="${pageContext.request.contextPath}/staff-profile" method="POST" onsubmit="return confirm('Bạn chắc chắn muốn xóa tạm khóa học này?');">
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

            <section id="tab-transaction-management" class="tab-pane <%= "tab-transaction-management".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Quản lý giao dịch</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card system-management-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3a2 2 0 0 0 0-4z"/><circle cx="18" cy="12" r="1"/></svg>
                                    <span>Yêu cầu rút tiền MoMo</span>
                                </div>
                                <span style="font-size:0.8rem; font-weight:700; color:#be185d; background:#fdf2f8; padding:0.2rem 0.75rem; border-radius:1rem;">Manual payout</span>
                            </div>

                            <%
                                List<WithdrawalRequest> withdrawalRequests = (List<WithdrawalRequest>) request.getAttribute("withdrawalRequests");
                                String withdrawalStatus = request.getAttribute("withdrawalStatus") != null ? String.valueOf(request.getAttribute("withdrawalStatus")) : "";
                                String withdrawalSearch = request.getAttribute("withdrawalSearch") != null ? String.valueOf(request.getAttribute("withdrawalSearch")) : "";
                            %>
                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/staff-profile" style="display:flex; align-items:center; gap:1rem;">
                                <input type="hidden" name="tab" value="transaction-management">
                                <input name="withdrawalSearch" value="<%= h(withdrawalSearch) %>" type="search" placeholder="Tìm theo giảng viên, SĐT MoMo, mã yêu cầu" style="flex:1; min-width:260px;">
                                <select name="withdrawalStatus" onchange="this.form.submit()" style="margin-left:auto; width:220px; min-width:220px; border:1px solid #e2e8f0; border-radius:0.8rem; padding:0.8rem 1rem; font-weight:750; color:#0f172a; background:#ffffff; white-space:nowrap;">
                                    <option value="all" <%= withdrawalStatus.isEmpty() || "all".equals(withdrawalStatus) ? "selected" : "" %>>Tất cả trạng thái</option>
                                    <option value="pending" <%= "pending".equals(withdrawalStatus) ? "selected" : "" %>>Chờ xử lý</option>
                                    <option value="processing" <%= "processing".equals(withdrawalStatus) ? "selected" : "" %>>Đang xử lý</option>
                                    <option value="paid" <%= "paid".equals(withdrawalStatus) ? "selected" : "" %>>Đã thanh toán</option>
                                    <option value="rejected" <%= "rejected".equals(withdrawalStatus) ? "selected" : "" %>>Từ chối</option>
                                    <option value="failed" <%= "failed".equals(withdrawalStatus) ? "selected" : "" %>>Thất bại</option>
                                </select>
                            </form>

                            <div style="overflow:auto; border:1px solid #e2e8f0; border-radius:1rem; margin-top:1rem;">
                                <table style="width:100%; border-collapse:collapse; min-width:820px;">
                                    <thead style="background:#f8fafc;">
                                        <tr>
                                            <th style="text-align:left; padding:1rem; color:#64748b; font-weight:900;">Mã yêu cầu</th>
                                            <th style="text-align:left; padding:1rem; color:#64748b; font-weight:900;">Giảng viên</th>
                                            <th style="text-align:right; padding:1rem; color:#64748b; font-weight:900;">Số tiền</th>
                                            <th style="text-align:center; padding:1rem; color:#64748b; font-weight:900;">Trạng thái</th>
                                            <th style="text-align:right; padding:1rem; color:#64748b; font-weight:900;">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (withdrawalRequests == null || withdrawalRequests.isEmpty()) { %>
                                            <tr>
                                                <td colspan="5" style="padding:2rem; text-align:center; color:#64748b; font-weight:750;">Chưa có yêu cầu rút tiền MoMo phù hợp.</td>
                                            </tr>
                                        <% } else { %>
                                            <% for (WithdrawalRequest wr : withdrawalRequests) { %>
                                                <tr style="border-top:1px solid #eef2f7;">
                                                    <td style="padding:1rem; font-weight:900; color:#0f172a;"><%= h(wr.getRequestCode()) %></td>
                                                    <td style="padding:1rem;">
                                                        <strong style="display:block; color:#0f172a;"><%= h(wr.getTeacherName()) %></strong>
                                                    </td>
                                                    <td style="padding:1rem; text-align:right; color:#be185d; font-weight:900;"><%= h(wr.getAmountLabel()) %></td>
                                                    <td style="padding:1rem; text-align:center;"><span style="display:inline-flex; white-space:nowrap; <%= withdrawalStatusStyle(wr.getStatus()) %> padding:0.35rem 0.85rem; border-radius:999px; font-weight:850; font-size:0.78rem;"><%= h(wr.getStatusLabel()) %></span></td>
                                                    <td style="padding:1rem; text-align:right;">
                                                        <div style="display:flex; justify-content:flex-end; align-items:center; gap:0.45rem; flex-wrap:wrap;">
                                                            <% if (wr.isOpenStatus()) { %>
                                                                <form action="${pageContext.request.contextPath}/staff-profile" method="POST" style="display:inline;">
                                                                    <input type="hidden" name="action" value="markWithdrawalPaid">
                                                                    <input type="hidden" name="withdrawalId" value="<%= h(wr.getId()) %>">
                                                                    <button type="submit" class="btn-premium primary" style="padding:0.55rem 0.9rem; font-size:0.82rem; background:#059669; box-shadow:none; white-space:nowrap;">Thanh toán</button>
                                                                </form>
                                                                <form action="${pageContext.request.contextPath}/staff-profile" method="POST" style="display:inline;">
                                                                    <input type="hidden" name="action" value="rejectWithdrawal">
                                                                    <input type="hidden" name="withdrawalId" value="<%= h(wr.getId()) %>">
                                                                    <input type="hidden" name="staffNote" value="Staff từ chối yêu cầu rút tiền MoMo.">
                                                                    <button type="submit" class="btn-premium secondary" style="padding:0.55rem 0.9rem; font-size:0.82rem; white-space:nowrap;">Từ chối</button>
                                                                </form>
                                                            <% } %>
                                                            <button type="button"
                                                                    class="btn-premium secondary"
                                                                    style="padding:0.55rem 0.9rem; font-size:0.82rem; white-space:nowrap;"
                                                                    data-code="<%= h(wr.getRequestCode()) %>"
                                                                    data-teacher="<%= h(wr.getTeacherName()) %>"
                                                                    data-email="<%= h(wr.getTeacherEmail()) %>"
                                                                    data-balance="<%= h(wr.getTeacherWalletBalanceLabel()) %>"
                                                                    data-phone="<%= h(wr.getMomoPhone()) %>"
                                                                    data-receiver="<%= h(wr.getReceiverName()) %>"
                                                                    data-amount="<%= h(wr.getAmountLabel()) %>"
                                                                    data-status="<%= h(wr.getStatusLabel()) %>"
                                                                    data-note="<%= h(wr.getTeacherNote() != null ? wr.getTeacherNote() : "") %>"
                                                                    data-reference="<%= h(wr.getPayoutReference() != null ? wr.getPayoutReference() : "") %>"
                                                                    onclick="openWithdrawalDetail(this)">Xem chi tiết</button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>

                            <div id="withdrawal-detail-modal" style="display:none; position:fixed; inset:0; z-index:10000; background:rgba(15,23,42,0.45); backdrop-filter:blur(5px); align-items:center; justify-content:center; padding:1.5rem;">
                                <div style="width:min(760px, calc(100vw - 2rem)); max-height:calc(100vh - 3rem); background:#ffffff; border:1px solid #e2e8f0; border-radius:1.25rem; box-shadow:0 24px 70px rgba(15,23,42,0.22); overflow:hidden; display:flex; flex-direction:column;">
                                    <div style="padding:1.1rem 1.5rem; border-bottom:1px solid #e2e8f0; display:flex; align-items:flex-start; justify-content:space-between; gap:1rem;">
                                        <div>
                                            <div style="display:inline-flex; align-items:center; gap:0.45rem; padding:0.25rem 0.7rem; border-radius:999px; background:#fdf2f8; color:#be185d; font-weight:800; font-size:0.76rem; margin-bottom:0.65rem;">
                                                <span style="width:7px; height:7px; border-radius:50%; background:#db2777;"></span>
                                                MoMo payout
                                            </div>
                                            <h3 style="margin:0; color:#0f172a; font-size:1.35rem; font-weight:900;">Chi tiết yêu cầu rút tiền</h3>
                                            <p id="withdrawal-detail-code" style="margin:0.35rem 0 0; color:#64748b; font-weight:750;"></p>
                                        </div>
                                        <button type="button" onclick="closeWithdrawalDetail()" aria-label="Đóng chi tiết rút tiền" style="width:38px; height:38px; border-radius:50%; border:1px solid #e2e8f0; background:#f8fafc; color:#64748b; font-size:1.35rem; cursor:pointer;">&times;</button>
                                    </div>
                                    <div style="padding:1.35rem 1.5rem; display:grid; grid-template-columns:repeat(auto-fit, minmax(260px, 1fr)); gap:1rem; overflow-y:auto;">
                                        <div style="grid-column:1 / -1; border:1px solid #bbf7d0; background:#ecfdf5; border-radius:0.9rem; padding:0.9rem 1rem; display:flex; align-items:center; justify-content:space-between; gap:1rem;">
                                            <span style="color:#047857; font-weight:800;">Số dư hiện tại của giảng viên</span>
                                            <strong id="withdrawal-detail-balance" style="color:#065f46; font-size:1.1rem;"></strong>
                                        </div>
                                        <div style="display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Tài khoản giảng viên</label>
                                            <div id="withdrawal-detail-teacher" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:800; color:#0f172a; min-height:52px;"></div>
                                        </div>
                                        <div style="display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Email giảng viên</label>
                                            <div id="withdrawal-detail-email" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:800; color:#0f172a; min-height:52px;"></div>
                                        </div>
                                        <div style="display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Số tiền muốn rút</label>
                                            <div id="withdrawal-detail-amount" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:900; color:#be185d; min-height:52px;"></div>
                                        </div>
                                        <div style="display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Số điện thoại MoMo</label>
                                            <div id="withdrawal-detail-phone" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:800; color:#0f172a; min-height:52px;"></div>
                                        </div>
                                        <div style="grid-column:1 / -1; display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Tên người nhận MoMo</label>
                                            <div id="withdrawal-detail-receiver" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:800; color:#0f172a; min-height:52px;"></div>
                                        </div>
                                        <div style="display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Trạng thái</label>
                                            <div id="withdrawal-detail-status" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:800; color:#0f172a; min-height:52px;"></div>
                                        </div>
                                        <div style="display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Mã giao dịch chi trả</label>
                                            <div id="withdrawal-detail-reference" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; font-weight:800; color:#0f172a; min-height:52px;"></div>
                                        </div>
                                        <div style="grid-column:1 / -1; display:grid; gap:0.45rem;">
                                            <label style="font-weight:800; color:#0f172a;">Ghi chú</label>
                                            <div id="withdrawal-detail-note" style="border:1px solid #cbd5e1; border-radius:0.85rem; padding:0.9rem 1rem; color:#475569; font-weight:700; min-height:72px;"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="section-data-card system-management-card" style="margin-top:1.25rem;">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 6.5v12"/><path d="M5 8.5c2.6 0 4.9.5 7 2 2.1-1.5 4.4-2 7-2v11c-2.6 0-4.9.5-7 2-2.1-1.5-4.4-2-7-2z"/></svg>
                                    <span>Giao dịch khóa học & học phí</span>
                                </div>
                                <span style="font-size:0.8rem; font-weight:700; color:#047857; background:#ecfdf5; padding:0.2rem 0.75rem; border-radius:1rem;">SePay</span>
                            </div>

                            <%
                                List<StaffCourseTransaction> staffCourseTransactions = (List<StaffCourseTransaction>) request.getAttribute("staffCourseTransactions");
                                String saleStatus = request.getAttribute("saleStatus") != null ? String.valueOf(request.getAttribute("saleStatus")) : "";
                                String saleSearch = request.getAttribute("saleSearch") != null ? String.valueOf(request.getAttribute("saleSearch")) : "";
                            %>
                            <form class="management-toolbar" method="GET" action="${pageContext.request.contextPath}/staff-profile" style="display:flex; align-items:center; gap:1rem; margin-top:1rem;">
                                <input type="hidden" name="tab" value="transaction-management">
                                <input name="saleSearch" value="<%= h(saleSearch) %>" type="search" placeholder="Tìm mã đơn, học viên, giảng viên, lớp hoặc khóa học" style="flex:1; min-width:260px;">
                                <select name="saleStatus" onchange="this.form.submit()" style="margin-left:auto; width:220px; min-width:220px; border:1px solid #e2e8f0; border-radius:0.8rem; padding:0.8rem 1rem; font-weight:750; color:#0f172a; background:#ffffff; white-space:nowrap;">
                                    <option value="all" <%= saleStatus.isEmpty() || "all".equals(saleStatus) ? "selected" : "" %>>Tất cả trạng thái</option>
                                    <option value="pending" <%= "pending".equals(saleStatus) ? "selected" : "" %>>Chờ xử lý</option>
                                    <option value="paid" <%= "paid".equals(saleStatus) ? "selected" : "" %>>Đã thanh toán</option>
                                    <option value="failed" <%= "failed".equals(saleStatus) ? "selected" : "" %>>Thất bại</option>
                                </select>
                            </form>

                            <div style="overflow:auto; border:1px solid #e2e8f0; border-radius:1rem; margin-top:1rem;">
                                <table style="width:100%; border-collapse:collapse; min-width:920px;">
                                    <thead style="background:#f8fafc;">
                                        <tr>
                                            <th style="text-align:left; padding:1rem; color:#64748b; font-weight:900;">Mã đơn</th>
                                            <th style="text-align:left; padding:1rem; color:#64748b; font-weight:900;">Học viên</th>
                                            <th style="text-align:left; padding:1rem; color:#64748b; font-weight:900;">Giảng viên</th>
                                            <th style="text-align:left; padding:1rem; color:#64748b; font-weight:900;">Nội dung</th>
                                            <th style="text-align:right; padding:1rem; color:#64748b; font-weight:900;">Số tiền</th>
                                            <th style="text-align:center; padding:1rem; color:#64748b; font-weight:900;">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (staffCourseTransactions == null || staffCourseTransactions.isEmpty()) { %>
                                            <tr>
                                                <td colspan="6" style="padding:2rem; text-align:center; color:#64748b; font-weight:750;">Chưa có giao dịch SePay phù hợp.</td>
                                            </tr>
                                        <% } else { %>
                                            <% for (StaffCourseTransaction sale : staffCourseTransactions) { %>
                                                <tr style="border-top:1px solid #eef2f7;">
                                                    <td style="padding:1rem; font-weight:900; color:#0f172a;"><%= h(sale.getOrderCode()) %></td>
                                                    <td style="padding:1rem;">
                                                        <strong style="display:block; color:#0f172a;"><%= h(sale.getStudentName()) %></strong>
                                                        <span style="color:#64748b; font-weight:650; font-size:0.82rem;"><%= h(sale.getStudentEmail()) %></span>
                                                    </td>
                                                    <td style="padding:1rem;">
                                                        <strong style="display:block; color:#0f172a;"><%= h(sale.getTeacherName()) %></strong>
                                                        <span style="color:#64748b; font-weight:650; font-size:0.82rem;"><%= h(sale.getTeacherEmail()) %></span>
                                                    </td>
                                                    <td style="padding:1rem; color:#0f172a; font-weight:750;"><%= h(sale.getCourseTitle()) %></td>
                                                    <td style="padding:1rem; text-align:right; color:<%= sale.isPaid() ? "#059669" : "#f97316" %>; font-weight:900;"><%= h(sale.getAmountLabel()) %></td>
                                                    <td style="padding:1rem; text-align:center;"><span style="display:inline-flex; white-space:nowrap; <%= courseSaleStatusStyle(sale.getStatus()) %> padding:0.35rem 0.85rem; border-radius:999px; font-weight:850; font-size:0.78rem;"><%= h(sale.getStatusLabel()) %></span></td>
                                                </tr>
                                            <% } %>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="tab-overview" class="tab-pane <%= "tab-overview".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Tổng quan</h1>
                        <p>Theo dõi nhanh các chỉ số vận hành chính của hệ thống HIPZI.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="metrics-row">
                    <div class="metric-card primary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Tổng người dùng</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= staffTotalUsers %></div>
                            <span class="metric-card-sub">Tài khoản</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        </div>
                    </div>

                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Lớp học hoạt động</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= staffActiveClassCount %></div>
                            <span class="metric-card-sub" style="background:#f5f3ff; color:#7c3aed;">Đang vận hành</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true" style="color:#7c3aed; background:#f5f3ff;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                        </div>
                    </div>

                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Khóa học hiện có</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= staffCourseCount %></div>
                            <span class="metric-card-sub" style="background:#fff7ed; color:#ea580c;">Khóa học</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true" style="color:#ea580c; background:#fff7ed;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                        </div>
                    </div>

                    <div class="metric-card secondary">
                        <div class="metric-card-top">
                            <span class="metric-card-title">Tài liệu</span>
                            <div class="metric-arrow-btn">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/></svg>
                            </div>
                        </div>
                        <div>
                            <div class="metric-card-value"><%= staffMaterialCount %></div>
                            <span class="metric-card-sub" style="background:#eff6ff; color:#2563eb;">Kho học liệu</span>
                        </div>
                        <div class="metric-ghost-icon" aria-hidden="true" style="color:#2563eb; background:#eff6ff;">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                        </div>
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

                <div class="dashboard-grid-layout" style="display:none;">
                    <div class="premium-card" style="grid-column: 1 / -1; display:none;">
                        <div class="premium-card-header">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                Chi tiết tài khoản
                            </span>
                            <div class="account-header-actions">
                                <button type="button" onclick="switchTab('tab-edit')" class="btn-premium profile-edit-btn" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                                    <span>Chỉnh sửa</span>
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                </button>
                            </div>
                        </div>

                        <form id="staffAvatarUploadForm" action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" style="display:none;">
                            <input type="hidden" name="action" value="updateAvatar">
                            <input type="file" id="staffAvatarFile" name="avatarFile" accept="image/*" onchange="document.getElementById('staffAvatarUploadForm').submit();">
                        </form>

                        <div class="account-summary-panel">
                            <div class="account-summary-main">
                                <div class="account-avatar-wrap">
                                    <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                        <img src="<%= user.getAvatarUrl() %>" class="account-avatar-img" alt="Avatar">
                                    <% } else { %>
                                        <div class="account-avatar-placeholder"><%= initials %></div>
                                    <% } %>
                                    <button type="button" class="avatar-camera-btn" title="Cập nhật ảnh đại diện" onclick="document.getElementById('staffAvatarFile').click();">
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                                    </button>
                                </div>
                                <div class="account-identity">
                                    <h3 class="account-name"><%= user != null ? user.getDisplayName() : "Nhân viên HIPZI" %></h3>
                                    <span class="account-email" title="<%= user != null ? user.getEmail() : "" %>"><%= user != null ? user.getEmail() : "staff@hipzi.vn" %></span>
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
                                        <span class="role-tag staff">Nhân viên</span>
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
            <section id="tab-edit" class="tab-pane <%= "tab-edit".equals(activeStaffTab) ? "active-pane" : "" %>">
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
            <section id="tab-profile" class="tab-pane <%= "tab-profile".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hồ sơ cá nhân</h1>
                        <p>Quản lý thông tin tài khoản, mật khẩu đăng nhập và xác thực hai lớp.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="premium-card" style="grid-column: 1 / -1;">
                    <div class="premium-card-header">
                        <span class="premium-card-title">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            Chi tiết tài khoản
                        </span>
                        <div class="account-header-actions">
                            <button type="button" onclick="switchTab('tab-edit')" class="btn-premium profile-edit-btn" style="padding: 0.4rem 0.85rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                                <span>Chỉnh sửa</span>
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </button>
                        </div>
                    </div>

                    <div class="account-summary-panel">
                        <div class="account-summary-main">
                            <div class="account-avatar-wrap">
                                <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                    <img src="<%= user.getAvatarUrl() %>" class="account-avatar-img" alt="Avatar">
                                <% } else { %>
                                    <div class="account-avatar-placeholder"><%= initials %></div>
                                <% } %>
                                <button type="button" class="avatar-camera-btn" title="Cập nhật ảnh đại diện" onclick="document.getElementById('staffAvatarFile').click();">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                                </button>
                            </div>
                            <div class="account-identity">
                                <h3 class="account-name"><%= user != null ? user.getDisplayName() : "Nhân viên HIPZI" %></h3>
                                <span class="account-email" title="<%= user != null ? user.getEmail() : "" %>"><%= user != null ? user.getEmail() : "staff@hipzi.vn" %></span>
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
                                    <span class="role-tag staff">Nhân viên</span>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="security-card-grid">
                    <div class="premium-card security-password-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1.25rem;">
                            <div>
                                <span style="font-weight: 800; font-size: 1.15rem; color: var(--text-main); letter-spacing: 0.5px; text-transform: uppercase; display: block;">Mật khẩu đăng nhập</span>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin: 0.35rem 0 0 0;">Cập nhật mật khẩu định kỳ để bảo mật tốt hơn.</p>
                            </div>
                        </div>

                        <div style="padding: 1rem 0 0 0; border-top: 1px solid var(--border-light); display: flex; align-items: center; justify-content: space-between; gap: 1.5rem; flex-wrap: wrap;">
                            <div style="display: flex; align-items: center; gap: 0.4rem; color: #10b981; font-weight: 700; font-size: 0.85rem;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                <span>Mật khẩu mạnh</span>
                            </div>
                            <button type="button" onclick="document.getElementById('pwd-modal-overlay').style.display='flex';" class="btn-premium primary" style="background: #059669; box-shadow: 0 4px 14px rgba(5, 150, 105, 0.25);">
                                <span>Đổi mật khẩu</span>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            </button>
                        </div>
                    </div>

                    <div class="premium-card">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                            <span style="font-weight: 800; font-size: 0.9rem; color: var(--text-main); text-transform: uppercase; letter-spacing: 0.5px;">Bảo mật 2 lớp (OTP)</span>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem; margin-top: 1.1rem;">
                            <div>
                                <span style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); display: block;">Mã OTP qua Email</span>
                                <p style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; line-height: 1.5; margin: 0.35rem 0 0 0;">Tăng cường bảo vệ tài khoản khi đăng nhập ở thiết bị lạ.</p>
                            </div>
                            
                            <form id="toggle2faForm" action="${pageContext.request.contextPath}/profile" method="POST" style="display: none;">
                                <input type="hidden" name="action" value="toggle2FA">
                            </form>

                            <% boolean is2fa = (user != null && user.isTwoFactorEnabled()); %>
                            <div id="otp-toggle-btn" onclick="document.getElementById('toggle2faForm').submit();" style="width: 44px; height: 24px; background: <%= is2fa ? "#10b981" : "#cbd5e1" %>; border-radius: 12px; padding: 2px; cursor: pointer; transition: background 0.3s ease; display: flex; align-items: center;">
                                <div class="toggle-circle" style="width: 20px; height: 20px; background: #ffffff; border-radius: 50%; box-shadow: 0 1px 3px rgba(0,0,0,0.2); transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); transform: translateX(<%= is2fa ? "20px" : "0" %>);"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <!-- TAB 4: TÀI LIỆU ĐÃ LƯU                     -->
            <!-- ========================================== -->
            <section id="tab-materials" class="tab-pane <%= "tab-materials".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Hàng đợi kiểm duyệt</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
                                    <span>Danh sách hàng đợi kiểm duyệt học liệu</span>
                                </div>
                                <a onclick="showToast('Đang làm mới hàng đợi kiểm duyệt...', 'info')" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease; text-decoration:none;">
                                    <span>Làm mới</span>
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                </a>
                            </div>
                            <div class="empty-status-panel" style="padding:4rem 2rem;">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                <span style="font-weight:700; color:var(--text-main);">Hàng đợi tài liệu trống</span>
                                <p style="font-size:0.85rem; max-width:400px; margin:0;">Hiện tại không có bài giảng hay tài liệu mới nào đang chờ kiểm duyệt từ phía các Giảng viên.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ========================================== -->
            <jsp:include page="/WEB-INF/views/partials/staff-mock-exams-tab.jsp" />

            <!-- TAB 5: LỊCH SỬ LUYỆN TẬP                   -->
            <!-- ========================================== -->
            <section id="tab-practice" class="tab-pane <%= "tab-practice".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-grouped-container">
                    <div class="tab-header-accent">
                        <div class="tab-header-title-text">Hồ sơ ứng tuyển</div>
                        <div class="tab-header-date-pill">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>

                    <div class="tab-body-content">
                        <div class="section-data-card">
                            <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                                <div class="card-header-title">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/></svg>
                                    <span>Hồ sơ ứng tuyển Giảng viên / Chuyên gia</span>
                                </div>
                                <a onclick="showToast('Đang tải danh sách hồ sơ...', 'info')" style="display:inline-flex; align-items:center; justify-content:center; gap:0.5rem; background:#059669; color:#ffffff; font-weight:800; font-size:0.85rem; padding:0.65rem 1.35rem; border-radius:9999px; border:none; box-shadow:0 4px 14px rgba(5, 150, 105, 0.25); cursor:pointer; transition:all 0.2s ease; text-decoration:none;">
                                    <span>Xem tất cả</span>
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                </a>
                            </div>
                            <div class="empty-status-panel" style="padding:4rem 2rem;">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                <span style="font-weight:700; color:var(--text-main);">Không có yêu cầu đăng ký mới</span>
                                <p style="font-size:0.85rem; max-width:400px; margin:0;">Các hồ sơ yêu cầu trở thành Giảng viên từ người dùng sẽ được liệt kê tại đây để rà soát chứng chỉ chuyên môn.</p>
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
                                    <span>Thông báo hệ thống nội bộ</span>
                                </div>
                                <span style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">Mới nhất</span>
                            </div>

                            <div style="padding-top:1.5rem; display:flex; flex-direction:column; gap:1rem;">
                                <div style="padding:1rem 1.25rem; border-radius:0.75rem; background:#f0fdf4; border-left:4px solid var(--primary); display:flex; gap:1rem; align-items:flex-start; box-shadow:0 4px 12px rgba(0,0,0,0.02);">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2.5" style="flex-shrink:0; margin-top:0.15rem;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                    <div>
                                        <span style="font-weight:700; font-size:0.95rem; color:var(--text-main); display:block;">Cấp quyền Nhân viên kiểm duyệt thành công</span>
                                        <p style="font-size:0.85rem; color:var(--text-muted); margin:0.25rem 0 0 0;">Tài khoản của bạn đã được cấu hình các phân quyền cần thiết để tham gia điều phối, phê duyệt tài liệu và hồ sơ ứng tuyển.</p>
                                        <span style="font-size:0.75rem; color:#94a3b8; display:block; margin-top:0.35rem;"><%= currentDateDisplay %></span>
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
            <section id="tab-support" class="tab-pane <%= "tab-support".equals(activeStaffTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>Hỗ trợ nghiệp vụ</h1>
                        <p>Tiếp nhận yêu cầu hỗ trợ từ học viên, giảng viên và phản hồi trực tiếp trong hệ thống.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="support-ticket-layout <%= selectedSupportTicket == null ? "is-mailbox-only" : "" %>">
                    <div class="premium-card" style="min-height:560px;">
                        <div class="premium-card-header" style="border-bottom:1px solid var(--border-dark); padding-bottom:1rem; margin-bottom:0;">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15a4 4 0 0 1-4 4H7l-4 4V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4z"/></svg>
                                Hộp thư hỗ trợ
                            </span>
                            <span style="font-size:0.78rem; font-weight:850; color:#059669; background:#dcfce7; padding:0.25rem 0.75rem; border-radius:999px;"><%= supportUnreadTodayCount %> chưa đọc hôm nay</span>
                        </div>

                        <div class="support-toolbar" style="margin-top:0.9rem;">
                            <input id="support-ticket-search" class="support-search-input" type="search" placeholder="Tìm kiếm tin nhắn">
                            <div class="support-filter-select-wrap" style="grid-column:3;">
                                <select id="support-role-filter" class="support-filter-select" aria-label="Lọc vai trò người gửi">
                                    <option value="all">Tất cả vai trò</option>
                                    <option value="student">Học sinh</option>
                                    <option value="teacher">Giảng viên</option>
                                </select>
                            </div>
                            <div class="support-filter-select-wrap" style="grid-column:4;">
                                <select id="support-ticket-filter" class="support-filter-select" aria-label="Lọc yêu cầu hỗ trợ">
                                    <option value="all">Tất cả</option>
                                    <option value="unread">Chưa đọc</option>
                                    <option value="viewed">Đã xem</option>
                                    <option value="replied">Đã phản hồi</option>
                                </select>
                            </div>
                        </div>

                        <div id="support-ticket-list" style="display:flex; flex-direction:column; gap:0.85rem;">
                            <% if (staffSupportTickets != null && !staffSupportTickets.isEmpty()) {
                                for (SupportTicket ticket : staffSupportTickets) {
                                    boolean isSelectedTicket = selectedSupportTicket != null && selectedSupportTicket.getId() != null && selectedSupportTicket.getId().equals(ticket.getId());
                                    String statusText = "Đang mở";
                                    String statusColor = "#2563eb";
                                    String statusBg = "#eff6ff";
                                    if ("waiting_staff".equals(ticket.getStatus()) || "open".equals(ticket.getStatus())) {
                                        statusText = "Cần phản hồi";
                                        statusColor = "#047857";
                                        statusBg = "#dcfce7";
                                    } else if ("waiting_user".equals(ticket.getStatus())) {
                                        statusText = "Chờ user";
                                        statusColor = "#b45309";
                                        statusBg = "#ffedd5";
                                    } else if ("resolved".equals(ticket.getStatus()) || "closed".equals(ticket.getStatus())) {
                                        statusText = "Đã xử lý";
                                        statusColor = "#475569";
                                        statusBg = "#f1f5f9";
                                    }
                                    boolean isUnreadTicket = ticket.getUnreadMessageCount() > 0;
                                    boolean isRepliedTicket = !isUnreadTicket
                                            && ("staff".equals(ticket.getLatestSenderRole()) || "admin".equals(ticket.getLatestSenderRole()));
                                    String cardState = isUnreadTicket ? "unread" : (isRepliedTicket ? "replied" : "viewed");
                                    String cardBadgeText = "Đã xem";
                                    String cardBadgeColor = "#047857";
                                    String cardBadgeBg = "#dcfce7";
                                    if (isUnreadTicket) {
                                        int newMessageCount = ticket.getUnreadMessageCount();
                                        cardBadgeText = newMessageCount + " tin nhắn mới";
                                        cardBadgeColor = "#b45309";
                                        cardBadgeBg = "#ffedd5";
                                    } else if (isRepliedTicket) {
                                        cardBadgeText = "Đã phản hồi";
                                        cardBadgeColor = "#2563eb";
                                        cardBadgeBg = "#dbeafe";
                                    }
                                    String sourceRoleLabel = h(ticket.getSourceRole());
                                    if ("teacher".equals(ticket.getSourceRole())) {
                                        sourceRoleLabel = "Giảng viên";
                                    } else if ("student".equals(ticket.getSourceRole())) {
                                        sourceRoleLabel = "Học viên";
                                    } else if ("parent".equals(ticket.getSourceRole())) {
                                        sourceRoleLabel = "Phụ huynh";
                                    } else if ("staff".equals(ticket.getSourceRole())) {
                                        sourceRoleLabel = "Nhân viên";
                                    } else if ("admin".equals(ticket.getSourceRole())) {
                                        sourceRoleLabel = "Quản trị viên";
                                    }
                                    String senderInitial = "U";
                                    if (ticket.getUserName() != null && !ticket.getUserName().trim().isEmpty()) {
                                        senderInitial = ticket.getUserName().trim().substring(0, 1).toUpperCase();
                                    }
                                    String userMessageTime = ticket.getLatestUserMessageAt() != null
                                            ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(ticket.getLatestUserMessageAt())
                                            : "Chưa có tin nhắn";
                                    String staffViewedTime = ticket.getStaffLastReadAt() != null
                                            ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(ticket.getStaffLastReadAt())
                                            : "Chưa xem";
                                    String staffReplyTime = ticket.getLatestStaffMessageAt() != null
                                            ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(ticket.getLatestStaffMessageAt())
                                            : "Chưa phản hồi";
                                    String ticketSearchText = (String.valueOf(ticket.getTitle()) + " "
                                            + String.valueOf(ticket.getUserName()) + " "
                                            + String.valueOf(ticket.getSourceRole())).toLowerCase();
                            %>
                            <a class="support-ticket-card" data-support-role="<%= h(ticket.getSourceRole()) %>" data-support-state="<%= cardState %>" data-support-search="<%= h(ticketSearchText) %>" href="${pageContext.request.contextPath}/staff-profile?tab=support&supportView=detail&supportTicketId=<%= h(ticket.getId()) %>" style="display:block; text-decoration:none; text-align:left; border:1px solid <%= isSelectedTicket ? "#99f6e4" : "#e2e8f0" %>; border-left:4px solid <%= isSelectedTicket ? "#059669" : "#e2e8f0" %>; background:<%= isSelectedTicket ? "#f0fdfa" : "#ffffff" %>; border-radius:1rem; padding:1rem; cursor:pointer; box-shadow:0 10px 20px rgba(15,23,42,0.04);">
                                <div style="display:flex; justify-content:space-between; gap:1rem; align-items:flex-start;">
                                    <div style="min-width:0;">
                                        <span class="support-sender-line">
                                            <span class="support-sender-avatar">
                                                <% if (ticket.getUserAvatarUrl() != null && !ticket.getUserAvatarUrl().trim().isEmpty()) { %>
                                                    <img src="<%= h(ticket.getUserAvatarUrl()) %>" alt="<%= h(ticket.getUserName()) %>">
                                                <% } else { %>
                                                    <%= h(senderInitial) %>
                                                <% } %>
                                            </span>
                                            <span class="support-sender-name"><%= h(ticket.getUserName()) %></span>
                                        </span>
                                        <span class="support-ticket-title"><%= h(ticket.getTitle()) %></span>
                                    </div>
                                    <span style="flex-shrink:0; color:<%= cardBadgeColor %>; background:<%= cardBadgeBg %>; border-radius:999px; padding:0.18rem 0.55rem; font-size:0.68rem; font-weight:900;"><%= cardBadgeText %></span>
                                </div>
                                <div style="display:flex; align-items:center; justify-content:space-between; gap:1rem; flex-wrap:wrap; margin-top:0.8rem;">
                                    <span style="color:#334155; font-size:0.78rem; font-weight:850;">Vai trò: <%= sourceRoleLabel %></span>
                                    <span style="display:flex; flex-direction:column; gap:0.18rem; color:#64748b; font-size:0.72rem; font-weight:850; text-align:right; line-height:1.25;">
                                        <span>Người dùng gửi: <%= userMessageTime %></span>
                                        <% if (isRepliedTicket) { %>
                                        <span>Phản hồi: <%= staffReplyTime %></span>
                                        <% } else if (!isUnreadTicket) { %>
                                        <span>Đã xem: <%= staffViewedTime %></span>
                                        <% } %>
                                    </span>
                                </div>
                            </a>
                            <% } } else { %>
                            <div style="border:1px dashed #cbd5e1; border-radius:1rem; padding:1.25rem; text-align:center; color:#64748b; font-weight:800;">
                                Chưa có yêu cầu hỗ trợ nào.
                            </div>
                            <% } %>
                        </div>
                        <div class="support-load-more-wrap">
                            <button id="support-load-more" type="button" class="support-load-more-btn">
                                Xem thêm yêu cầu
                                <svg viewBox="0 0 24 24" fill="none" stroke-width="2.4"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>
                            </button>
                        </div>
                    </div>

                    <% if (selectedSupportTicket != null) { %>
                    <div class="premium-card" style="min-height:560px;">
                        <div class="premium-card-header" style="border-bottom:1px solid var(--border-dark); padding-bottom:1rem; margin-bottom:0;">
                            <span class="premium-card-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 4h16v12H5.17L4 17.17V4z"/><path d="M8 8h8"/><path d="M8 12h5"/></svg>
                                Chi tiết yêu cầu
                            </span>
                            <% if (selectedSupportTicket != null) { %>
                            <span style="font-size:0.78rem; font-weight:850; color:#059669; background:#dcfce7; padding:0.25rem 0.75rem; border-radius:999px;"><%= h(selectedSupportTicket.getStatus()) %></span>
                            <% } %>
                        </div>

                        <div style="display:grid; grid-template-columns:1fr auto; gap:1rem; align-items:start; padding:1rem; border:1px solid #e2e8f0; border-radius:1rem; background:#f8fafc;">
                            <div>
                                <h3 style="margin:0; color:#0f172a; font-size:1.15rem; font-weight:900;"><%= h(selectedSupportTicket.getTitle()) %></h3>
                                <p style="margin:0.35rem 0 0 0; color:#64748b; font-size:0.85rem; font-weight:650;"><%= h(selectedSupportTicket.getUserName()) %> - <%= h(selectedSupportTicket.getSourceRole()) %> - <%= h(selectedSupportTicket.getUserEmail()) %></p>
                            </div>
                            <div style="text-align:right;">
                                <span style="display:block; color:#64748b; font-size:0.72rem; font-weight:850; text-transform:uppercase;">Mã ticket</span>
                                <span style="display:block; color:#0f172a; font-size:0.9rem; font-weight:900; margin-top:0.2rem;"><%= h(selectedSupportTicket.getId().substring(0, 8).toUpperCase()) %></span>
                            </div>
                        </div>

                        <div style="display:flex; flex-direction:column; gap:1rem; flex:1; min-height:0;">
                            <% if (supportMessages != null && !supportMessages.isEmpty()) {
                                for (SupportMessage message : supportMessages) {
                                    boolean fromStaff = "staff".equals(message.getSenderRole()) || "admin".equals(message.getSenderRole());
                                    String messageTime = message.getCreatedAt() != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(message.getCreatedAt()) : "";
                            %>
                            <div style="align-self:<%= fromStaff ? "flex-end" : "flex-start" %>; max-width:78%; background:<%= fromStaff ? "#ecfdf5" : "#f1f5f9" %>; border:1px solid <%= fromStaff ? "#bbf7d0" : "#e2e8f0" %>; border-radius:<%= fromStaff ? "1rem 1rem 0.25rem 1rem" : "1rem 1rem 1rem 0.25rem" %>; padding:1rem;">
                                <span style="display:block; color:<%= fromStaff ? "#047857" : "#64748b" %>; font-size:0.72rem; font-weight:850; margin-bottom:0.35rem;"><%= fromStaff ? "HIPZI Support" : h(message.getSenderName()) %> - <%= messageTime %></span>
                                <p style="margin:0; color:#0f172a; font-size:0.9rem; line-height:1.55;"><%= h(message.getMessage()) %></p>
                            </div>
                            <% } } %>
                        </div>

                        <form id="supportReplyForm" action="${pageContext.request.contextPath}/support" method="POST" style="display:flex; flex-direction:column; gap:1rem; border-top:1px solid var(--border-dark); padding-top:1rem;">
                            <input type="hidden" name="action" value="reply">
                            <input type="hidden" name="ticketId" value="<%= h(selectedSupportTicket.getId()) %>">
                            <div class="form-group-premium">
                                <label>Nội dung phản hồi <span class="field-required">*</span></label>
                                <textarea name="replyContent" rows="4" required placeholder="Nhập phản hồi để gửi lại người dùng trong tab hỗ trợ của họ..."></textarea>
                            </div>
                            <div style="display:flex; justify-content:space-between; gap:1rem; flex-wrap:wrap;">
                                <button type="submit" name="nextStatus" value="waiting_user" class="btn-premium primary" style="min-width:190px;">
                                    <span>Gửi phản hồi</span>
                                </button>
                                <button type="submit" name="nextStatus" value="resolved" class="btn-premium secondary" style="min-width:150px;">Đánh dấu đã xử lý</button>
                            </div>
                        </form>
                    </div>
                    <% } %>
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
                            <details style="background: #f8fafc; padding: 1.25rem; border-radius: 1rem; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s ease; box-shadow: var(--shadow);">
                                <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-main); list-style: none; display: flex; justify-content: space-between; align-items: center;">
                                    <span>Làm thế nào để tải xuống bài giảng?</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9l6 6 6-6"/></svg>
                                </summary>
                                <p style="font-size: 0.9rem; color: var(--text-muted); margin: 1rem 0 0 0; line-height: 1.6; padding-top: 1rem; border-top: 1px dashed #e2e8f0;">
                                    Học viên có thể tải xuống các file đính kèm miễn phí khi tài liệu đã được duyệt và chuyển sang chế độ hiển thị công khai.
                                </p>
                            </details>

                            <details style="background: #f8fafc; padding: 1.25rem; border-radius: 1rem; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s ease; box-shadow: var(--shadow);">
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
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: -0.75rem; margin-bottom: 1rem; line-height: 1.5;">Gửi yêu cầu trực tiếp đến đội ngũ kỹ thuật nếu bạn gặp sự cố nghiêm trọng.</p>
                        <form id="supportForm" style="display: flex; flex-direction: column; gap: 1.25rem;" class="form-edit-layout">
                            <div class="form-group-premium">
                                <label>Tiêu đề cần hỗ trợ <span class="field-required">*</span></label>
                                <input type="text" name="title" required placeholder="Nhập tiêu đề vắn tắt...">
                            </div>
                            <div class="form-group-premium">
                                <label>Mô tả chi tiết <span class="field-required">*</span></label>
                                <textarea name="content" rows="4" required placeholder="Mô tả khó khăn bạn đang gặp phải..."></textarea>
                            </div>
                            <div class="support-submit-row" style="display: flex; justify-content: flex-end; margin-top: 0.5rem;">
                                <button type="submit" class="btn-premium primary" style="width: 100%;">Gửi tin nhắn</button>
                            </div>
                        </form>
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

    
    <!-- ===== JAVASCRIPT XỬ LÝ CHUYỂN TAB MƯỢT MÀ ===== -->
    <script>
        window.HipziStaffUserGrowthData = {
            week: <%= staffWeeklyUserGrowthJson %>,
            month: <%= staffMonthlyUserGrowthJson %>
        };
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/staff-user-growth-chart.js?v=1"></script>
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

        function setWithdrawalDetailText(id, value) {
            const el = document.getElementById(id);
            if (el) {
                el.textContent = value && value.trim() ? value : 'Chưa có thông tin';
            }
        }

        function openWithdrawalDetail(button) {
            const modal = document.getElementById('withdrawal-detail-modal');
            if (!modal || !button) return;
            const data = button.dataset;
            setWithdrawalDetailText('withdrawal-detail-code', data.code ? 'Mã yêu cầu ' + data.code : '');
            setWithdrawalDetailText('withdrawal-detail-balance', data.balance);
            setWithdrawalDetailText('withdrawal-detail-teacher', data.teacher);
            setWithdrawalDetailText('withdrawal-detail-email', data.email);
            setWithdrawalDetailText('withdrawal-detail-amount', data.amount);
            setWithdrawalDetailText('withdrawal-detail-phone', data.phone);
            setWithdrawalDetailText('withdrawal-detail-receiver', data.receiver);
            setWithdrawalDetailText('withdrawal-detail-status', data.status);
            setWithdrawalDetailText('withdrawal-detail-reference', data.reference);
            setWithdrawalDetailText('withdrawal-detail-note', data.note);
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }

        function closeWithdrawalDetail() {
            const modal = document.getElementById('withdrawal-detail-modal');
            if (!modal) return;
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }

        let profileTabSwitchTimer;

        function getProfileTabSlug(tabId) {
            return tabId.replace(/^tab-/, '');
        }

        function normalizeProfileTabId(tabValue) {
            if (!tabValue) return '';
            const normalized = tabValue.startsWith('tab-') ? tabValue : 'tab-' + tabValue;
            return normalized === 'tab-security' ? 'tab-profile' : normalized;
        }

        function updateProfileTabUrl(targetTabId, replace = false) {
            if (!window.history || !window.history.pushState) return;
            const url = new URL(window.location.href);
            url.searchParams.set('tab', getProfileTabSlug(targetTabId));
            const isSupportDetail = targetTabId === 'tab-support' && url.searchParams.get('supportView') === 'detail';
            if (!isSupportDetail) {
                url.searchParams.delete('supportView');
                url.searchParams.delete('supportTicketId');
            }
            const state = { profileTab: targetTabId };
            if (replace) {
                window.history.replaceState(state, '', url);
            } else {
                window.history.pushState(state, '', url);
            }
        }

        const TAB_TITLES = {
            'tab-teacher-approval': 'Duyệt hồ sơ giảng viên',
            'tab-manage-teachers': 'Quản lý người dùng',
            'tab-manage-classes': 'Quản lý lớp học',
            'tab-manage-courses': 'Quản lý khóa học',
            'tab-transaction-management': 'Quản lý giao dịch',
            'tab-overview': 'Tổng quan',
            'tab-profile': 'Hồ sơ cá nhân',
            'tab-edit': 'Cập nhật thông tin',
            'tab-materials': 'Hàng đợi duyệt tài liệu',
            'tab-mock-exams': 'Đăng tải thi thử',
            'tab-practice': 'Đăng ký giảng viên',
            'tab-notifications': 'Thông báo hệ thống',
            'tab-support': 'Hỗ trợ nghiệp vụ',
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

        function toggleSidebar() {
            const container = document.querySelector('.app-dashboard-container');
            if (!container) return;
            container.classList.toggle('collapsed');
            localStorage.setItem('staffSidebarCollapsed', container.classList.contains('collapsed') ? 'true' : 'false');
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

        function openTeacherApplicationModal(modalId) {
            const modal = document.getElementById(modalId);
            if (!modal) return;
            if (modal.parentElement !== document.body) {
                document.body.appendChild(modal);
            }
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeTeacherApplicationModal(modalId) {
            const modal = document.getElementById(modalId);
            if (!modal) return;
            modal.classList.remove('active');
            document.body.style.overflow = '';
        }

        function closeTeacherApplicationModalOnBackdrop(event, modal) {
            if (event.target === modal) {
                modal.classList.remove('active');
                document.body.style.overflow = '';
            }
        }

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
                document.querySelectorAll('.teacher-application-modal.active').forEach(modal => {
                    modal.classList.remove('active');
                });
                document.querySelectorAll('.class-detail-modal.active').forEach(modal => {
                    modal.classList.remove('active');
                });
                document.body.style.overflow = '';
            }
        });

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
            const container = document.querySelector('.app-dashboard-container');
            if (container && localStorage.getItem('staffSidebarCollapsed') === 'true') {
                container.classList.add('collapsed');
            }
            setupManagementFilterDropdowns();
            setupTeacherApprovalFilters();
            setupSupportTicketFilters();
            initStaffUserGrowthChart();
            const urlParams = new URLSearchParams(window.location.search);
            const tabParam = urlParams.get('tab');
            if (tabParam) {
                switchTab(tabParam, { replaceUrl: true, updateUrl: true });
            } else {
                const activePane = document.querySelector('.tab-pane.active-pane');
                if (activePane) updateProfileTabUrl(activePane.id, true);
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

        function setupTeacherApprovalFilters() {
            const searchInput = document.getElementById('teacher-approval-search');
            const statusSelect = document.getElementById('teacher-approval-status-filter');
            const cards = Array.from(document.querySelectorAll('#tab-teacher-approval .teacher-approval-card'));
            if (!searchInput && !statusSelect) return;

            function applyFilters() {
                const keyword = searchInput ? searchInput.value.trim().toLowerCase() : '';
                const status = statusSelect ? statusSelect.value : 'all';
                cards.forEach(card => {
                    const matchesText = !keyword || (card.dataset.approvalSearch || '').includes(keyword);
                    const matchesStatus = status === 'all' || card.dataset.approvalStatus === status;
                    card.style.display = matchesText && matchesStatus ? '' : 'none';
                });
            }

            if (searchInput) searchInput.addEventListener('input', applyFilters);
            if (statusSelect) statusSelect.addEventListener('change', applyFilters);
            applyFilters();
        }

        function setupSupportTicketFilters() {
            const searchInput = document.getElementById('support-ticket-search');
            const filterSelect = document.getElementById('support-ticket-filter');
            const roleSelect = document.getElementById('support-role-filter');
            const loadMoreButton = document.getElementById('support-load-more');
            const cards = Array.from(document.querySelectorAll('.support-ticket-card'));
            const pageSize = 10;
            let visibleLimit = pageSize;

            function applyFilters(resetLimit = false) {
                if (resetLimit) visibleLimit = pageSize;
                const keyword = searchInput ? searchInput.value.trim().toLowerCase() : '';
                const activeFilter = filterSelect ? filterSelect.value : 'all';
                const activeRole = roleSelect ? roleSelect.value : 'all';
                const matchedCards = cards.filter(card => {
                    const matchesText = !keyword || (card.dataset.supportSearch || '').includes(keyword);
                    const matchesState = activeFilter === 'all' || card.dataset.supportState === activeFilter;
                    const matchesRole = activeRole === 'all' || card.dataset.supportRole === activeRole;
                    return matchesText && matchesState && matchesRole;
                });

                cards.forEach(card => card.classList.add('is-hidden'));
                matchedCards.slice(0, visibleLimit).forEach(card => card.classList.remove('is-hidden'));

                if (loadMoreButton) {
                    const hasMore = matchedCards.length > visibleLimit;
                    loadMoreButton.parentElement.style.display = hasMore ? 'flex' : 'none';
                }
            }

            if (searchInput) {
                searchInput.addEventListener('input', () => applyFilters(true));
            }

            if (filterSelect) {
                filterSelect.addEventListener('change', () => applyFilters(true));
            }

            if (roleSelect) {
                roleSelect.addEventListener('change', () => applyFilters(true));
            }

            if (loadMoreButton) {
                loadMoreButton.addEventListener('click', () => {
                    visibleLimit += pageSize;
                    applyFilters(false);
                });
            }

            applyFilters(true);
        }

        window.addEventListener('popstate', (event) => {
            const stateTab = event.state && event.state.profileTab;
            const urlTab = new URLSearchParams(window.location.search).get('tab');
            switchTab(stateTab || urlTab || 'tab-teacher-approval', { updateUrl: false });
        });

        // Xử lý gửi form hỗ trợ qua Servlet
        function updateTeacherPresence(userId, status) {
            const isOnline = String(status).toLowerCase() === 'online';
            document.querySelectorAll('[data-teacher-status-user-id="' + userId + '"]').forEach(badge => {
                badge.textContent = isOnline ? 'Online' : 'Offline';
                badge.classList.toggle('online', isOnline);
                badge.classList.toggle('offline', !isOnline);
            });
        }

        function connectStaffStatusSocket() {
            <% if (user != null && user.getId() != null) { %>
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + '${pageContext.request.contextPath}/status-ws';
            const ws = new WebSocket(wsUrl);

            ws.onopen = () => {
                ws.send(JSON.stringify({ type: 'auth', userId: '<%= h(user.getId()) %>' }));
            };

            ws.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    if (data.type === 'status') {
                        updateTeacherPresence(data.userId, data.status);
                    } else if (data.type === 'bulk_status' && data.statuses) {
                        document.querySelectorAll('[data-teacher-status-user-id]').forEach(badge => {
                            updateTeacherPresence(badge.dataset.teacherStatusUserId, data.statuses[badge.dataset.teacherStatusUserId] || 'offline');
                        });
                    }
                } catch (err) {
                    console.warn('Không đọc được trạng thái WebSocket', err);
                }
            };
            <% } %>
        }

        window.addEventListener('DOMContentLoaded', () => {
            connectStaffStatusSocket();
            toggleMockExamTypeFields();
        });

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

    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=2"></script>
</body>
</html>




