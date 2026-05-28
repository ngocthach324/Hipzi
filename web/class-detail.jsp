<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%@page import="com.hipzi.model.ClassroomEnrollment"%>
<%@page import="com.hipzi.model.ClassroomModule"%>
<%@page import="com.hipzi.model.User"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }
%>
<%
    Classroom classroom = (Classroom) request.getAttribute("classroom");
    User user = (User) session.getAttribute("loggedUser");
    List<ClassroomModule> learningModules = (List<ClassroomModule>) request.getAttribute("learningModules");
    List<ClassroomModule> requirementModules = (List<ClassroomModule>) request.getAttribute("requirementModules");
    ClassroomEnrollment joinRequest = (ClassroomEnrollment) request.getAttribute("joinRequest");
    boolean canEditClassModules = Boolean.TRUE.equals(request.getAttribute("canEditClassModules"));
    String initials = "H";
    if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().trim().split("\\s+");
        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
    }

    String title = classroom != null ? classroom.getTitle() : "Lớp học HIPZI";
    String subject = classroom != null ? classroom.getSubject() : "Môn học";
    String grade = classroom != null && classroom.getGrade() != null && !classroom.getGrade().isEmpty() ? classroom.getGrade() : "Mọi trình độ";
    String teacherName = classroom != null && classroom.getTeacherName() != null && !classroom.getTeacherName().isEmpty() ? classroom.getTeacherName() : "Giảng viên HIPZI";
    String teacherSchool = classroom != null && classroom.getTeacherSchool() != null && !classroom.getTeacherSchool().isEmpty() ? classroom.getTeacherSchool() : "Đơn vị giảng dạy đang cập nhật";
    String schedule = classroom != null && classroom.getSchedule() != null ? classroom.getSchedule() : "Lịch học đang cập nhật";
    String status = classroom != null ? classroom.getStatus() : "open";
    String statusLabel = classroom != null ? classroom.getStatusLabel() : "Đang mở";
    String description = classroom != null && classroom.getDescription() != null && !classroom.getDescription().trim().isEmpty()
            ? classroom.getDescription()
            : "Lớp học được thiết kế theo lộ trình rõ ràng, kết hợp giảng dạy trực tiếp, tài liệu ôn tập và bài luyện tập sau mỗi buổi để học viên nắm chắc kiến thức cốt lõi.";
    int studentCount = classroom != null ? classroom.getStudentCount() : 0;

    String safeTitle = title.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeSubject = subject.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeGrade = grade.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeTeacherName = teacherName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeTeacherSchool = teacherSchool.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeSchedule = schedule.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeStatusLabel = statusLabel.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeDescription = description.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String safeContactHref = h(request.getContextPath() + "/support");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= safeTitle %> - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    <style>
        body {
            background: #f8fafc;
            min-height: 100vh;
        }

        .class-detail-shell {
            max-width: 1180px;
            margin: 0 auto;
            padding: 7rem 1.25rem 4rem;
        }

        .class-back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            color: #6d28d9;
            font-weight: 800;
            text-decoration: none;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }

        .class-hero {
            position: relative;
            min-height: 430px;
            border: 1px solid rgba(255, 255, 255, 0.55);
            border-radius: 1.5rem;
            overflow: hidden;
            box-shadow: 0 26px 70px rgba(49, 46, 129, 0.22);
            background:
                radial-gradient(circle at 78% 18%, rgba(255, 255, 255, 0.32), transparent 20%),
                linear-gradient(135deg, #6d28d9 0%, #4f46e5 46%, #059669 100%);
            isolation: isolate;
        }

        .class-hero::before,
        .class-hero::after {
            content: "";
            position: absolute;
            inset: auto;
            border-radius: 999px;
            pointer-events: none;
            z-index: -1;
        }

        .class-hero::before {
            width: 360px;
            height: 360px;
            right: -90px;
            top: -110px;
            background: rgba(255, 255, 255, 0.18);
            filter: blur(2px);
            animation: heroFloat 9s ease-in-out infinite alternate;
        }

        .class-hero::after {
            width: 260px;
            height: 260px;
            left: 46%;
            bottom: -150px;
            background: rgba(16, 185, 129, 0.42);
            animation: heroPulse 7s ease-in-out infinite;
        }

        .class-hero-band {
            min-height: 430px;
            padding: 3rem;
            color: #ffffff;
            display: flex;
            align-items: center;
            position: relative;
        }

        .class-hero-band::before {
            content: "";
            position: absolute;
            right: 2.2rem;
            top: 2rem;
            width: min(32vw, 360px);
            aspect-ratio: 1;
            background:
                linear-gradient(135deg, rgba(109, 40, 217, 0.05), rgba(5, 150, 105, 0.42)),
                url('${pageContext.request.contextPath}/assets/images/capybara_study.png') center / contain no-repeat;
            border-radius: 1.2rem;
            opacity: 0.5;
            animation: imageDrift 8s ease-in-out infinite alternate;
        }

        .class-hero-content {
            max-width: 760px;
            position: relative;
            z-index: 1;
            animation: heroContentIn 700ms ease both;
        }

        .class-kicker-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.6rem;
            margin-bottom: 1rem;
        }

        .class-pill {
            display: inline-flex;
            align-items: center;
            border-radius: 999px;
            padding: 0.45rem 0.95rem;
            font-size: 0.82rem;
            font-weight: 900;
            background: rgba(255, 255, 255, 0.18);
            border: 1px solid rgba(255, 255, 255, 0.32);
            backdrop-filter: blur(12px);
        }

        .class-hero h1 {
            margin: 0;
            font-size: clamp(2.7rem, 7vw, 5.6rem);
            line-height: 0.98;
            letter-spacing: 0;
            max-width: 850px;
            text-shadow: 0 14px 35px rgba(15, 23, 42, 0.28);
        }

        .class-hero p {
            margin: 1.15rem 0 0;
            color: rgba(255, 255, 255, 0.9);
            line-height: 1.55;
            font-size: 1.15rem;
            max-width: 620px;
            font-weight: 650;
        }

        .hero-join-actions {
            display: flex;
            align-items: center;
            gap: 0.85rem;
            margin-top: 1.7rem;
            flex-wrap: wrap;
        }

        .hero-join-btn {
            border: none;
            border-radius: 999px;
            padding: 0.95rem 1.6rem;
            min-width: 210px;
            background: #ffffff;
            color: #6d28d9;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.22);
            font-weight: 950;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: transform 180ms ease, box-shadow 180ms ease;
        }

        .hero-join-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 22px 50px rgba(15, 23, 42, 0.28);
        }

        .hero-join-btn.secondary {
            background: rgba(255, 255, 255, 0.14);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.35);
        }

        .join-request-state {
            display: grid;
            gap: 0.8rem;
            max-width: 560px;
        }

        .join-request-note {
            padding: 0.9rem 1rem;
            border-radius: 1rem;
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.28);
            color: #ffffff;
            font-weight: 850;
            line-height: 1.5;
            backdrop-filter: blur(14px);
        }

        .class-hero {
            min-height: 500px;
            background:
                radial-gradient(circle at 20% 18%, rgba(255, 255, 255, 0.18), transparent 24%),
                radial-gradient(circle at 80% 78%, rgba(16, 185, 129, 0.32), transparent 30%),
                linear-gradient(135deg, #26115f 0%, #4f22d8 42%, #1b7f89 100%);
        }

        .class-hero-band {
            min-height: 500px;
            display: grid;
            grid-template-columns: minmax(0, 0.95fr) minmax(320px, 0.85fr);
            gap: 2rem;
            align-items: center;
            padding: 3.4rem 4rem;
        }

        .class-hero-band::before {
            content: none;
        }

        .class-hero-content {
            max-width: 680px;
        }

        .class-hero h1 {
            max-width: 720px;
            font-size: clamp(3rem, 6.3vw, 6.35rem);
            line-height: 0.94;
        }

        .class-hero p,
        .class-kicker-row {
            display: none;
        }

        .hero-join-actions {
            margin-top: 2rem;
        }

        .hero-join-btn {
            min-width: 230px;
            padding: 1rem 1.7rem;
            color: #37118f;
        }

        .hero-visual {
            min-height: 360px;
            position: relative;
            display: grid;
            place-items: center;
            isolation: isolate;
            animation: visualIn 900ms ease both;
        }

        .hero-orbit {
            position: absolute;
            width: min(34vw, 390px);
            aspect-ratio: 1;
            border: 1px solid rgba(255, 255, 255, 0.22);
            border-radius: 50%;
            animation: orbitSpin 18s linear infinite;
        }

        .hero-orbit::before,
        .hero-orbit::after {
            content: "";
            position: absolute;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: #ffffff;
            box-shadow: 0 0 32px rgba(255, 255, 255, 0.72);
        }

        .hero-orbit::before {
            top: 18%;
            left: 5%;
        }

        .hero-orbit::after {
            right: 10%;
            bottom: 13%;
            background: #86efac;
        }

        .classroom-visual-card {
            position: relative;
            width: min(36vw, 430px);
            min-width: 320px;
            aspect-ratio: 1.18;
            border-radius: 1.45rem;
            background:
                linear-gradient(145deg, rgba(255, 255, 255, 0.28), rgba(255, 255, 255, 0.08)),
                linear-gradient(135deg, rgba(255, 255, 255, 0.18), rgba(45, 212, 191, 0.16));
            border: 1px solid rgba(255, 255, 255, 0.34);
            box-shadow:
                0 28px 70px rgba(0, 0, 0, 0.28),
                inset 0 1px 0 rgba(255, 255, 255, 0.32);
            backdrop-filter: blur(18px);
            transform: rotate(-3deg);
            animation: glassFloat 5.8s ease-in-out infinite alternate;
            overflow: hidden;
        }

        .classroom-visual-card::before {
            content: "";
            position: absolute;
            inset: 1.1rem;
            border-radius: 1rem;
            background:
                linear-gradient(rgba(255, 255, 255, 0.12) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.12) 1px, transparent 1px);
            background-size: 34px 34px;
            opacity: 0.45;
        }

        .visual-board {
            position: absolute;
            left: 13%;
            right: 13%;
            top: 15%;
            height: 36%;
            border-radius: 1rem;
            background: rgba(15, 23, 42, 0.34);
            border: 1px solid rgba(255, 255, 255, 0.22);
            box-shadow: inset 0 0 35px rgba(45, 212, 191, 0.18);
        }

        .visual-board::before,
        .visual-board::after {
            content: "";
            position: absolute;
            left: 11%;
            right: 11%;
            height: 10px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.72);
        }

        .visual-board::before {
            top: 30%;
        }

        .visual-board::after {
            top: 57%;
            right: 36%;
            background: rgba(134, 239, 172, 0.9);
        }

        .visual-desk {
            position: absolute;
            left: 18%;
            right: 18%;
            bottom: 22%;
            height: 12%;
            border-radius: 999px;
            background: linear-gradient(90deg, #ffffff, #dbeafe);
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.28);
        }

        .visual-screen {
            position: absolute;
            left: 36%;
            right: 36%;
            bottom: 33%;
            height: 20%;
            border-radius: 0.75rem 0.75rem 0.35rem 0.35rem;
            background: linear-gradient(135deg, #f8fafc, #a7f3d0);
            box-shadow: 0 16px 35px rgba(15, 23, 42, 0.24);
            animation: screenGlow 2.8s ease-in-out infinite;
        }

        .floating-chip {
            position: absolute;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 74px;
            height: 42px;
            border-radius: 999px;
            color: #ffffff;
            font-weight: 950;
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.28);
            box-shadow: 0 18px 36px rgba(15, 23, 42, 0.18);
            backdrop-filter: blur(12px);
            animation: chipFloat 4.5s ease-in-out infinite alternate;
        }

        .floating-chip.one {
            top: 13%;
            left: -4%;
        }

        .floating-chip.two {
            right: -3%;
            top: 35%;
            animation-delay: 0.8s;
        }

        .floating-chip.three {
            left: 13%;
            bottom: 5%;
            animation-delay: 1.4s;
        }

        @keyframes visualIn {
            from { opacity: 0; transform: translateX(28px) scale(0.96); }
            to { opacity: 1; transform: translateX(0) scale(1); }
        }

        @keyframes orbitSpin {
            to { transform: rotate(360deg); }
        }

        @keyframes glassFloat {
            from { transform: rotate(-3deg) translateY(0); }
            to { transform: rotate(2deg) translateY(-16px); }
        }

        @keyframes screenGlow {
            0%, 100% { box-shadow: 0 16px 35px rgba(15, 23, 42, 0.24); }
            50% { box-shadow: 0 20px 44px rgba(45, 212, 191, 0.34); }
        }

        @keyframes chipFloat {
            from { transform: translateY(0); }
            to { transform: translateY(-14px); }
        }

        .class-overview {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 340px;
            gap: 1.25rem;
            padding: 1.5rem;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.9rem;
        }

        .detail-item {
            background: #f8fafc;
            border: 1px solid #edf2f7;
            border-radius: 0.75rem;
            padding: 0.95rem;
        }

        .detail-label {
            display: block;
            color: #64748b;
            font-size: 0.72rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin-bottom: 0.35rem;
        }

        .detail-value {
            color: #0f172a;
            font-weight: 850;
            line-height: 1.45;
        }

        .join-panel {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.15rem;
            box-shadow: 0 10px 25px rgba(15, 23, 42, 0.05);
        }

        .join-panel h2 {
            margin: 0 0 0.35rem;
            font-size: 1.15rem;
            color: #0f172a;
        }

        .join-panel p {
            margin: 0 0 1rem;
            color: #64748b;
            line-height: 1.55;
            font-size: 0.9rem;
        }

        .join-action {
            width: 100%;
            border-radius: 999px;
            padding: 0.82rem 1rem;
            font-weight: 850;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
        }

        .join-action.btn-primary {
            background: #6d28d9;
            border-color: #6d28d9;
            color: #ffffff;
        }

        @keyframes heroFloat {
            from { transform: translate3d(0, 0, 0) scale(1); }
            to { transform: translate3d(-22px, 28px, 0) scale(1.08); }
        }

        @keyframes heroPulse {
            0%, 100% { transform: scale(0.92); opacity: 0.52; }
            50% { transform: scale(1.18); opacity: 0.32; }
        }

        @keyframes imageDrift {
            from { transform: translateY(0) rotate(0deg); }
            to { transform: translateY(18px) rotate(-2deg); }
        }

        @keyframes heroContentIn {
            from { opacity: 0; transform: translateY(18px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .class-content-layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 320px;
            gap: 1.25rem;
            margin-top: 1.25rem;
            align-items: start;
        }

        .content-section {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.35rem;
            margin-bottom: 1.25rem;
        }

        .content-section h2 {
            margin: 0 0 1rem;
            font-size: 1.25rem;
            color: #0f172a;
        }

        .content-section p {
            color: #475569;
            line-height: 1.7;
            margin: 0;
        }

        .module-list {
            display: grid;
            gap: 0.8rem;
        }

        .module-item {
            display: grid;
            grid-template-columns: 42px minmax(0, 1fr);
            gap: 0.8rem;
            align-items: start;
            padding: 0.85rem;
            background: #f8fafc;
            border: 1px solid #eef2f7;
            border-radius: 0.8rem;
        }

        .module-number {
            width: 42px;
            height: 42px;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #ede9fe;
            color: #6d28d9;
            font-weight: 900;
        }

        .module-item strong {
            display: block;
            color: #0f172a;
            margin-bottom: 0.25rem;
        }

        .module-item span {
            color: #64748b;
            line-height: 1.5;
            font-size: 0.92rem;
        }

        .module-edit-toggle {
            margin-top: 0.75rem;
            border: 1px solid #ddd6fe;
            border-radius: 999px;
            background: #ffffff;
            color: #6d28d9;
            font-weight: 850;
            cursor: pointer;
            padding: 0.45rem 0.8rem;
            font-size: 0.88rem;
            line-height: 1;
        }

        .module-edit-form,
        .module-add-form {
            margin-top: 0.8rem;
            padding: 1rem;
            border-radius: 0.8rem;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            display: none;
            gap: 0.75rem;
            color: #0f172a;
            font-size: 0.95rem;
            line-height: 1.5;
        }

        .module-add-form {
            display: grid;
            background: #fbfdff;
        }

        .module-edit-form.active {
            display: grid;
        }

        .module-form-grid {
            display: grid;
            grid-template-columns: 90px minmax(0, 1fr);
            gap: 0.75rem;
        }

        .module-field {
            display: grid;
            gap: 0.35rem;
        }

        .module-field label {
            color: #334155;
            font-size: 0.78rem;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0;
        }

        .module-field input,
        .module-field textarea {
            width: 100%;
            border: 1px solid #cbd5e1;
            border-radius: 0.65rem;
            padding: 0.72rem 0.85rem;
            font-family: inherit;
            font-size: 0.95rem;
            font-weight: 650;
            line-height: 1.55;
            color: #0f172a;
            outline: none;
            background: #ffffff;
        }

        .module-field input::placeholder,
        .module-field textarea::placeholder {
            color: #94a3b8;
            font-weight: 550;
        }

        .module-field input:focus,
        .module-field textarea:focus {
            border-color: #6d28d9;
            box-shadow: 0 0 0 3px rgba(109, 40, 217, 0.12);
        }

        .module-field textarea {
            min-height: 82px;
            resize: vertical;
        }

        .module-actions {
            display: flex;
            gap: 0.65rem;
            justify-content: flex-end;
            flex-wrap: wrap;
        }

        .module-mini-btn {
            border: 1px solid #ddd6fe;
            color: #6d28d9;
            background: #ffffff;
            border-radius: 999px;
            padding: 0.6rem 1rem;
            font-weight: 850;
            cursor: pointer;
            font-size: 0.9rem;
        }

        .module-mini-btn.primary {
            background: #6d28d9;
            border-color: #6d28d9;
            color: #ffffff;
        }

        .teacher-only-note {
            margin: 0 0 1rem;
            color: #047857;
            background: #ecfdf5;
            border: 1px solid #bbf7d0;
            border-radius: 0.8rem;
            padding: 0.8rem 0.95rem;
            font-weight: 750;
            font-size: 0.9rem;
        }

        .custom-toast-container {
            position: fixed;
            top: 5.5rem;
            right: 1rem;
            z-index: 9999;
            display: grid;
            gap: 0.75rem;
        }

        .custom-toast-msg {
            border-radius: 0.8rem;
            padding: 0.85rem 1rem;
            background: #dcfce7;
            color: #15803d;
            border: 1px solid #bbf7d0;
            font-weight: 850;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.12);
        }

        .custom-toast-msg.error {
            background: #fef2f2;
            color: #dc2626;
            border-color: #fecaca;
        }

        .teacher-panel {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 1rem;
            padding: 1.25rem;
            position: sticky;
            top: 6rem;
        }

        .teacher-avatar {
            width: 58px;
            height: 58px;
            border-radius: 50%;
            background: #ede9fe;
            color: #6d28d9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 1.35rem;
            margin-bottom: 0.9rem;
        }

        .teacher-panel h2 {
            margin: 0;
            font-size: 1.15rem;
            color: #0f172a;
        }

        .teacher-panel p {
            margin: 0.4rem 0 1rem;
            color: #64748b;
            line-height: 1.55;
        }

        .side-list {
            display: grid;
            gap: 0.75rem;
            margin-top: 1rem;
        }

        .side-list div {
            display: flex;
            gap: 0.55rem;
            color: #475569;
            font-weight: 650;
            font-size: 0.9rem;
        }

        @media (max-width: 980px) {
            .class-overview,
            .class-content-layout {
                grid-template-columns: 1fr;
            }

            .teacher-panel {
                position: static;
            }
        }

        @media (max-width: 720px) {
            .class-detail-shell {
                padding: 6rem 1rem 3rem;
            }

            .class-hero-band {
                min-height: 520px;
                padding: 1.35rem;
                align-items: flex-end;
            }

            .class-hero-band::before {
                content: none;
            }

            .class-hero-band {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .hero-visual {
                min-height: 250px;
                order: -1;
            }

            .classroom-visual-card {
                width: min(82vw, 330px);
                min-width: 0;
            }

            .hero-orbit {
                width: min(80vw, 320px);
            }

            .floating-chip {
                min-width: 60px;
                height: 36px;
                font-size: 0.82rem;
            }

            .class-overview {
                padding: 1rem;
            }

            .detail-grid {
                grid-template-columns: 1fr;
            }

            .staff-class-card {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

    <header class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/index.jsp" class="logo">
                <img src="${pageContext.request.contextPath}/favicon.png" alt="HIPZI Logo">
                <span>HIPZI</span>
            </a>
            <ul class="nav-links">
                <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                <li><a href="${pageContext.request.contextPath}/classes" class="active">Lớp học</a></li>
                <li><a href="${pageContext.request.contextPath}/practice">Luyện tập</a></li>
                <li><a href="${pageContext.request.contextPath}/exam-room">Phòng thi</a></li>
                <li><a href="${pageContext.request.contextPath}/index.jsp#ai-roadmap">Hipzi AI</a></li>
            </ul>

            <% if (user != null) { %>
                <div class="navbar-user-controls">
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>
                    <div class="nav-avatar-dropdown">
                        <div class="nav-avatar-frame" title="<%= profileMenuLabel %>">
                            <% if (user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                                <img src="<%= user.getAvatarUrl() %>" alt="Avatar">
                            <% } else { %>
                                <span class="nav-avatar-initials"><%= initials %></span>
                            <% } %>
                        </div>
                        <div class="dropdown-menu-popup">
                            <a href="${pageContext.request.contextPath}/profile">
                                <span><%= profileMenuLabel %></span>
                            </a>
                            <div style="height:1px; background:var(--border-dark); margin:0.35rem 0;"></div>
                            <a href="${pageContext.request.contextPath}/logout" class="danger-link">
                                <span>Đăng xuất</span>
                            </a>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="nav-actions">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Bắt đầu</a>
                </div>
            <% } %>
        </div>
    </header>

    <main class="class-detail-shell">
        <a class="class-back-link" href="${pageContext.request.contextPath}/classes">
            <span>←</span>
            <span>Quay lại danh sách lớp</span>
        </a>

        <section class="class-hero">
            <div class="class-hero-band">
                <div class="class-hero-content">
                    <h1>Chào mừng đến với phòng học HIPZI</h1>
                    <div class="hero-join-actions">
                        <% if (canEditClassModules) { %>
                            <a class="hero-join-btn" href="${pageContext.request.contextPath}/classroom?id=<%= h(classroom.getId()) %>">Vào không gian quản lý lớp</a>
                        <% } else if ("closed".equals(status)) { %>
                            <a class="hero-join-btn secondary" href="${pageContext.request.contextPath}/classes">Tìm lớp khác</a>
                        <% } else if (user == null) { %>
                            <a class="hero-join-btn" href="${pageContext.request.contextPath}/login.jsp">Đăng nhập để tham gia</a>
                        <% } else if (joinRequest != null && "accepted".equals(joinRequest.getStatus())) { %>
                            <a class="hero-join-btn" href="${pageContext.request.contextPath}/classroom?id=<%= h(classroom.getId()) %>">Vào không gian lớp</a>
                            <a class="hero-join-btn secondary" href="<%= safeContactHref %>">Liên hệ với giảng viên</a>
                        <% } else if (joinRequest != null && "pending".equals(joinRequest.getStatus())) { %>
                            <div class="join-request-state">
                                <div class="join-request-note">Đã xin vào lớp, vui lòng đợi giảng viên chấp nhận.</div>
                                <a class="hero-join-btn secondary" href="<%= safeContactHref %>">Liên hệ với giảng viên</a>
                            </div>
                        <% } else { %>
                            <form action="${pageContext.request.contextPath}/class-detail" method="POST">
                                <input type="hidden" name="action" value="requestJoin">
                                <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                <button type="submit" class="hero-join-btn"><%= joinRequest != null && "rejected".equals(joinRequest.getStatus()) ? "Gửi lại yêu cầu" : "Tham gia lớp ngay" %></button>
                            </form>
                        <% } %>
                    </div>
                </div>
                <div class="hero-visual" aria-hidden="true">
                    <div class="hero-orbit"></div>
                    <div class="classroom-visual-card">
                        <div class="visual-board"></div>
                        <div class="visual-screen"></div>
                        <div class="visual-desk"></div>
                        <span class="floating-chip one">LIVE</span>
                        <span class="floating-chip two">AI</span>
                        <span class="floating-chip three">XP</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="class-content-layout">
            <div>
                <section class="content-section">
                    <h2>Tổng quan lớp học</h2>
                    <p><%= safeDescription %> Lớp tập trung vào việc hệ thống hóa kiến thức, luyện bài theo mức độ tăng dần và phản hồi thường xuyên để học viên biết mình đang mạnh ở đâu, cần bổ sung phần nào.</p>
                </section>

                <section class="content-section">
                    <h2>Nội dung học tập</h2>
                    <% if (canEditClassModules) { %>
                        <p class="teacher-only-note">Bạn đang chỉnh sửa lớp của mình. Các module bên dưới sẽ hiển thị công khai trong trang chi tiết lớp.</p>
                    <% } %>
                    <div class="module-list">
                        <% if (learningModules != null) {
                            int displayIndex = 1;
                            for (ClassroomModule module : learningModules) {
                                boolean persisted = module.getId() != null && !module.getId().trim().isEmpty();
                        %>
                            <div class="module-item">
                                <div class="module-number"><%= displayIndex++ %></div>
                                <div>
                                    <strong><%= h(module.getTitle()) %></strong>
                                    <span><%= h(module.getDescription()) %></span>
                                    <% if (canEditClassModules && persisted) { %>
                                        <button type="button" class="module-edit-toggle" onclick="toggleModuleForm('module-form-<%= h(module.getId()) %>')">Chỉnh sửa</button>
                                        <form id="module-form-<%= h(module.getId()) %>" class="module-edit-form" action="${pageContext.request.contextPath}/class-detail" method="POST">
                                            <input type="hidden" name="action" value="updateModule">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="moduleId" value="<%= h(module.getId()) %>">
                                            <input type="hidden" name="moduleType" value="learning_content">
                                            <div class="module-form-grid">
                                                <div class="module-field">
                                                    <label>Thứ tự</label>
                                                    <input type="number" name="sortOrder" min="1" value="<%= module.getSortOrder() %>" required>
                                                </div>
                                                <div class="module-field">
                                                    <label>Tiêu đề</label>
                                                    <input type="text" name="moduleTitle" value="<%= h(module.getTitle()) %>" required>
                                                </div>
                                            </div>
                                            <div class="module-field">
                                                <label>Mô tả</label>
                                                <textarea name="moduleDescription" required><%= h(module.getDescription()) %></textarea>
                                            </div>
                                            <div class="module-actions">
                                                <button type="button" class="module-mini-btn" onclick="toggleModuleForm('module-form-<%= h(module.getId()) %>')">Hủy</button>
                                                <button type="submit" class="module-mini-btn primary">Lưu</button>
                                            </div>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>

                    <% if (canEditClassModules) { %>
                        <form class="module-add-form" action="${pageContext.request.contextPath}/class-detail" method="POST">
                            <input type="hidden" name="action" value="addModule">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <input type="hidden" name="moduleType" value="learning_content">
                            <div class="module-form-grid">
                                <div class="module-field">
                                    <label>Thứ tự</label>
                                    <input type="number" name="sortOrder" min="1" value="<%= learningModules != null ? learningModules.size() + 1 : 1 %>" required>
                                </div>
                                <div class="module-field">
                                    <label>Tiêu đề module mới</label>
                                    <input type="text" name="moduleTitle" placeholder="Ví dụ: Luyện đề tổng hợp" required>
                                </div>
                            </div>
                            <div class="module-field">
                                <label>Mô tả</label>
                                <textarea name="moduleDescription" placeholder="Mô tả nội dung học tập mà học viên sẽ nhận được..." required></textarea>
                            </div>
                            <div class="module-actions">
                                <button type="submit" class="module-mini-btn primary">Thêm</button>
                            </div>
                        </form>
                    <% } %>
                </section>

                <section class="content-section">
                    <h2>Yêu cầu đầu vào</h2>
                    <div class="module-list">
                        <% if (requirementModules != null) {
                            int displayIndex = 1;
                            for (ClassroomModule module : requirementModules) {
                                boolean persisted = module.getId() != null && !module.getId().trim().isEmpty();
                        %>
                            <div class="module-item">
                                <div class="module-number"><%= displayIndex++ %></div>
                                <div>
                                    <strong><%= h(module.getTitle()) %></strong>
                                    <span><%= h(module.getDescription()) %></span>
                                    <% if (canEditClassModules && persisted) { %>
                                        <button type="button" class="module-edit-toggle" onclick="toggleModuleForm('module-form-<%= h(module.getId()) %>')">Chỉnh sửa</button>
                                        <form id="module-form-<%= h(module.getId()) %>" class="module-edit-form" action="${pageContext.request.contextPath}/class-detail" method="POST">
                                            <input type="hidden" name="action" value="updateModule">
                                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                                            <input type="hidden" name="moduleId" value="<%= h(module.getId()) %>">
                                            <input type="hidden" name="moduleType" value="entry_requirement">
                                            <div class="module-form-grid">
                                                <div class="module-field">
                                                    <label>Thứ tự</label>
                                                    <input type="number" name="sortOrder" min="1" value="<%= module.getSortOrder() %>" required>
                                                </div>
                                                <div class="module-field">
                                                    <label>Tiêu đề</label>
                                                    <input type="text" name="moduleTitle" value="<%= h(module.getTitle()) %>" required>
                                                </div>
                                            </div>
                                            <div class="module-field">
                                                <label>Mô tả</label>
                                                <textarea name="moduleDescription" required><%= h(module.getDescription()) %></textarea>
                                            </div>
                                            <div class="module-actions">
                                                <button type="button" class="module-mini-btn" onclick="toggleModuleForm('module-form-<%= h(module.getId()) %>')">Hủy</button>
                                                <button type="submit" class="module-mini-btn primary">Lưu</button>
                                            </div>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        <%  }
                        } %>
                    </div>

                    <% if (canEditClassModules) { %>
                        <form class="module-add-form" action="${pageContext.request.contextPath}/class-detail" method="POST">
                            <input type="hidden" name="action" value="addModule">
                            <input type="hidden" name="classId" value="<%= h(classroom.getId()) %>">
                            <input type="hidden" name="moduleType" value="entry_requirement">
                            <div class="module-form-grid">
                                <div class="module-field">
                                    <label>Thứ tự</label>
                                    <input type="number" name="sortOrder" min="1" value="<%= requirementModules != null ? requirementModules.size() + 1 : 1 %>" required>
                                </div>
                                <div class="module-field">
                                    <label>Tiêu đề yêu cầu mới</label>
                                    <input type="text" name="moduleTitle" placeholder="Ví dụ: Kiến thức cần có trước khi học" required>
                                </div>
                            </div>
                            <div class="module-field">
                                <label>Mô tả</label>
                                <textarea name="moduleDescription" placeholder="Mô tả yêu cầu, tài liệu hoặc thiết bị cần chuẩn bị..." required></textarea>
                            </div>
                            <div class="module-actions">
                                <button type="submit" class="module-mini-btn primary">Thêm</button>
                            </div>
                        </form>
                    <% } %>
                </section>
            </div>

            <aside class="teacher-panel">
                <div class="teacher-avatar"><%= safeTeacherName.substring(0, 1).toUpperCase() %></div>
                <h2><%= safeTeacherName %></h2>
                <p><%= safeTeacherSchool %></p>
                <div class="side-list">
                    <div>
                        <span>•</span>
                        <span>Môn phụ trách: <strong><%= safeSubject %></strong></span>
                    </div>
                    <div>
                        <span>•</span>
                        <span>Lớp phù hợp: <strong><%= safeGrade %></strong></span>
                    </div>
                    <div>
                        <span>•</span>
                        <span>Lịch chính: <strong><%= safeSchedule %></strong></span>
                    </div>
                    <div>
                        <span>•</span>
                        <span>Sĩ số hiện tại: <strong><%= studentCount %> học viên</strong></span>
                    </div>
                    <div>
                        <span>•</span>
                        <span>Hỗ trợ qua thông báo và tài liệu sau buổi học.</span>
                    </div>
                </div>
            </aside>
        </section>
    </main>

    <script>
        function toggleModuleForm(formId) {
            const form = document.getElementById(formId);
            if (form) {
                form.classList.toggle('active');
            }
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
            toast.className = 'custom-toast-msg ' + (type === 'error' ? 'error' : '');
            toast.textContent = message;
            container.appendChild(toast);
            setTimeout(() => toast.remove(), 3000);
        }

        <% if (session.getAttribute("toastMsg") != null) {
            String msg = (String) session.getAttribute("toastMsg");
            String type = (String) session.getAttribute("toastType");
            session.removeAttribute("toastMsg");
            session.removeAttribute("toastType");
        %>
        window.addEventListener('DOMContentLoaded', () => {
            showToast("<%= msg.replace("\\", "\\\\").replace("\"", "\\\"") %>", "<%= type != null ? type : "success" %>");
        });
        <% } %>
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/navbar.js"></script>
</body>
</html>
