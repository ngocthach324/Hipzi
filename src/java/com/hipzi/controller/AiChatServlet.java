package com.hipzi.controller;

import com.hipzi.service.AiRecommendationService;
import com.hipzi.service.GroqChatService;
import com.hipzi.model.Classroom;
import com.hipzi.model.Course;
import com.hipzi.model.Material;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "AiChatServlet", urlPatterns = {"/ai-chat"})
public class AiChatServlet extends HttpServlet {
    private final AiRecommendationService recommendationService = new AiRecommendationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String body = readBody(request);
        String message = extractJsonString(body, "message");
        if (message == null || message.trim().isEmpty()) {
            writeJson(response, false, "B\u1ea1n nh\u1eadp c\u00e2u h\u1ecfi tr\u01b0\u1edbc nh\u00e9.");
            return;
        }

        try {
            String directReply = directReply(message, request.getContextPath());
            if (!directReply.isEmpty()) {
                writeJson(response, true, directReply);
                return;
            }

            GroqChatService groq = new GroqChatService(config(request, "GROQ_API_KEYS"), config(request, "GROQ_MODEL"));
            AiRecommendationService.AiContext aiContext = recommendationService.buildContext(message, request.getContextPath());
            if (isAvailabilityRequest(message)) {
                writeJson(response, true, availabilityReply(aiContext, message, request.getContextPath()));
                return;
            }
            if (isStudyMaterialRequest(message, aiContext)) {
                writeJson(response, true, materialRecommendationReply(aiContext, request.getContextPath()));
                return;
            }
            if (!aiContext.hasData() && isRecommendationRequest(message)) {
                writeJson(response, true, noDataRecommendationReply(message, request.getContextPath()));
                return;
            }
            String reply = groq.chat(message, aiContext);
            writeJson(response, true, reply);
        } catch (Exception e) {
            System.err.println("AiChatServlet error: " + e.getMessage());
            writeJson(response, false, "Hipzi AI \u0111ang b\u1eadn m\u1ed9t ch\u00fat. B\u1ea1n th\u1eed l\u1ea1i sau nh\u00e9.");
        }
    }

    private String directReply(String message, String contextPath) {
        String normalized = normalize(message);
        boolean asksWhere = normalized.contains(" o dau") || normalized.contains(" dau nhi")
                || normalized.contains(" tim ") || normalized.startsWith("tim ")
                || normalized.contains("huong dan");

        if (normalized.length() <= 30 && (normalized.equals("chao ban") || normalized.equals("chao")
                || normalized.equals("hi") || normalized.equals("hello") || normalized.startsWith("xin chao"))) {
            return "Ch\u00e0o b\u1ea1n, m\u00ecnh l\u00e0 Hipzi AI. B\u1ea1n mu\u1ed1n m\u00ecnh h\u1ed7 tr\u1ee3 t\u00ecm l\u1edbp h\u1ecdc, t\u00e0i li\u1ec7u, kh\u00f3a h\u1ecdc hay ph\u00f2ng thi tr\u00ean HIPZI?";
        }

        if (normalized.contains("dang tai tai lieu") || normalized.contains("upload tai lieu")
                || normalized.contains("tai tai lieu len") || normalized.contains("them tai lieu")) {
            return "B\u1ea1n c\u00f3 th\u1ec3 \u0111\u0103ng t\u1ea3i t\u00e0i li\u1ec7u trong trang Gi\u1ea3ng vi\u00ean.\n"
                    + "C\u00e1c b\u01b0\u1edbc:\n"
                    + "1. \u0110\u0103ng nh\u1eadp b\u1eb1ng t\u00e0i kho\u1ea3n gi\u1ea3ng vi\u00ean, staff ho\u1eb7c admin.\n"
                    + "2. V\u00e0o H\u1ed3 s\u01a1 gi\u1ea3ng vi\u00ean > tab \u0110\u0103ng t\u1ea3i t\u00e0i li\u1ec7u.\n"
                    + "3. Nh\u1eadp ti\u00eau \u0111\u1ec1, m\u00f4n, l\u1edbp, lo\u1ea1i t\u00e0i li\u1ec7u v\u00e0 ch\u1ecdn file.\n"
                    + "Link: " + contextPath + "/teacher-profile?tab=upload-material";
        }

        if (normalized.contains("dang khoa hoc") || normalized.contains("dang tai khoa hoc")
                || normalized.contains("tao khoa hoc") || normalized.contains("them khoa hoc")) {
            return "Gi\u1ea3ng vi\u00ean c\u00f3 th\u1ec3 \u0111\u0103ng kh\u00f3a h\u1ecdc trong H\u1ed3 s\u01a1 gi\u1ea3ng vi\u00ean.\n"
                    + "C\u00e1c b\u01b0\u1edbc:\n"
                    + "1. V\u00e0o tab \u0110\u0103ng kh\u00f3a h\u1ecdc.\n"
                    + "2. Nh\u1eadp t\u00ean kh\u00f3a, m\u00f4n, c\u1ea5p \u0111\u1ed9, gi\u00e1 v\u00e0 link Google Drive n\u1ed9i dung.\n"
                    + "3. G\u1eedi duy\u1ec7t \u0111\u1ec3 staff ki\u1ec3m tra.\n"
                    + "Link: " + contextPath + "/teacher-profile?tab=course-registration";
        }

        if (normalized.contains("tao lop") || normalized.contains("dang ki lop day")
                || normalized.contains("dang ky lop day") || normalized.contains("mo lop")) {
            return "Gi\u1ea3ng vi\u00ean t\u1ea1o l\u1edbp h\u1ecdc trong H\u1ed3 s\u01a1 gi\u1ea3ng vi\u00ean.\n"
                    + "C\u00e1c b\u01b0\u1edbc:\n"
                    + "1. V\u00e0o tab \u0110\u0103ng k\u00ed l\u1edbp h\u1ecdc.\n"
                    + "2. Nh\u1eadp t\u00ean l\u1edbp, m\u00f4n, l\u1edbp, l\u1ecbch h\u1ecdc v\u00e0 link ph\u00f2ng online n\u1ebfu c\u00f3.\n"
                    + "3. L\u01b0u l\u1edbp \u0111\u1ec3 h\u1ecdc sinh c\u00f3 th\u1ec3 t\u00ecm v\u00e0 xin tham gia.\n"
                    + "Link: " + contextPath + "/teacher-profile?tab=class-registration";
        }

        if (normalized.contains("mua khoa hoc") || normalized.contains("thanh toan khoa hoc")
                || normalized.contains("checkout") || normalized.contains("gio hang")) {
            return "B\u1ea1n mua kh\u00f3a h\u1ecdc theo flow n\u00e0y nh\u00e9:\n"
                    + "1. V\u00e0o m\u1ee5c Kh\u00f3a h\u1ecdc v\u00e0 ch\u1ecdn kh\u00f3a ph\u00f9 h\u1ee3p.\n"
                    + "2. Trong trang chi ti\u1ebft, b\u1ea5m Th\u00eam v\u00e0o gi\u1ecf h\u00e0ng ho\u1eb7c Mua ngay.\n"
                    + "3. V\u00e0o Gi\u1ecf h\u00e0ng r\u1ed3i thanh to\u00e1n.\n"
                    + "Link kh\u00f3a h\u1ecdc: " + contextPath + "/courses\n"
                    + "Link gi\u1ecf h\u00e0ng: " + contextPath + "/cart";
        }

        if ((normalized.contains("tai lieu") || normalized.contains("kho tai lieu")) && asksWhere) {
            return "B\u1ea1n v\u00e0o m\u1ee5c Kho t\u00e0i li\u1ec7u \u1edf thanh menu tr\u00ean c\u00f9ng nh\u00e9.\n"
                    + "Link: " + contextPath + "/material-repository\n"
                    + "B\u1ea1n c\u00f3 th\u1ec3 t\u00ecm theo m\u00f4n, l\u1edbp ho\u1eb7c t\u1eeb kh\u00f3a \u00f4n t\u1eadp.";
        }

        if (normalized.contains("lop hoc") && (normalized.contains("dang ki") || normalized.contains("dang ky") || asksWhere)) {
            return "B\u1ea1n v\u00e0o m\u1ee5c L\u1edbp h\u1ecdc tr\u00ean thanh menu, ch\u1ecdn l\u1edbp ph\u00f9 h\u1ee3p r\u1ed3i g\u1eedi y\u00eau c\u1ea7u tham gia.\n"
                    + "Link: " + contextPath + "/classes";
        }

        if (normalized.contains("tu van lop hoc")) {
            return "B\u1ea1n cho m\u00ecnh bi\u1ebft m\u00f4n h\u1ecdc, l\u1edbp v\u00e0 m\u1ee5c ti\u00eau hi\u1ec7n t\u1ea1i nh\u00e9. M\u00ecnh s\u1ebd t\u00ecm l\u1edbp h\u1ecdc ph\u00f9 h\u1ee3p trong HIPZI cho b\u1ea1n.";
        }

        if ((normalized.contains("khoa hoc") || normalized.contains("course")) && asksWhere) {
            return "B\u1ea1n v\u00e0o m\u1ee5c Kh\u00f3a h\u1ecdc \u0111\u1ec3 xem c\u00e1c kh\u00f3a \u0111ang m\u1edf.\n"
                    + "Link: " + contextPath + "/courses";
        }

        if ((normalized.contains("phong thi") || normalized.contains("thi thu") || normalized.contains("de thi")) && asksWhere) {
            return "B\u1ea1n v\u00e0o m\u1ee5c Ph\u00f2ng thi \u0111\u1ec3 xem \u0111\u1ec1 thi th\u1eed v\u00e0 b\u00e0i luy\u1ec7n t\u1eadp.\n"
                    + "Link: " + contextPath + "/mock-exams";
        }

        return "";
    }

    private boolean isRecommendationRequest(String message) {
        String normalized = normalize(message);
        return normalized.contains("yeu") || normalized.contains("nen hoc") || normalized.contains("goi y")
                || normalized.contains("tai lieu") || normalized.contains("khoa hoc") || normalized.contains("on tap")
                || normalized.contains("lop hoc") || normalized.contains("hoc gi") || normalized.contains("can hoc");
    }

    private boolean isAvailabilityRequest(String message) {
        String normalized = normalize(message);
        return normalized.contains(" con ") || normalized.startsWith("con ") || normalized.contains(" co ")
                || normalized.startsWith("co ") || normalized.contains("co mon") || normalized.contains("co lop")
                || normalized.contains("he thong") || normalized.contains("lop hoc dang co")
                || normalized.contains("nhung lop hoc nao") || normalized.contains("danh sach lop");
    }

    private boolean isStudyMaterialRequest(String message, AiRecommendationService.AiContext context) {
        String normalized = normalize(message);
        boolean hasSubject = context != null && context.getHint() != null
                && (!context.getHint().getMaterialSubject().isEmpty() || !context.getHint().getClassroomSubject().isEmpty());
        return hasSubject && (normalized.contains("muon hoc") || normalized.contains("hoc mon")
                || normalized.contains("hoc kem") || normalized.contains("yeu") || normalized.contains("mat goc")
                || normalized.contains("on tap") || normalized.contains("can tai lieu")
                || normalized.contains("goi y tai lieu") || normalized.contains("nen hoc gi"));
    }

    private String materialRecommendationReply(AiRecommendationService.AiContext context, String contextPath) {
        AiRecommendationService.QueryHint hint = context.getHint();
        String subject = !hint.getMaterialSubject().isEmpty() ? hint.getMaterialSubject() : hint.getClassroomSubject();
        String grade = hint.getGrade();
        String materialUrl = contextPath + "/material-repository?subject=" + url(subject);
        if (!grade.isEmpty()) {
            materialUrl += "&grade=" + url(grade);
        }

        StringBuilder reply = new StringBuilder();
        reply.append("M\u00ecnh g\u1ee3i \u00fd b\u1ea1n b\u1eaft \u0111\u1ea7u t\u1eeb Kho t\u00e0i li\u1ec7u ");
        reply.append(subject.isEmpty() ? "ph\u00f9 h\u1ee3p" : "m\u00f4n " + subject);
        if (!grade.isEmpty()) {
            reply.append(" - ").append(grade);
        }
        reply.append(":\n").append(materialUrl);

        if (!context.getMaterials().isEmpty()) {
            reply.append("\n\nT\u00e0i li\u1ec7u \u0111ang c\u00f3:");
            for (Material material : context.getMaterials()) {
                reply.append("\n- ").append(nullToEmpty(material.getTitle()))
                        .append(" | ").append(nullToEmpty(material.getGrade()))
                        .append("\n  ").append(contextPath).append("/repository-material-preview?id=").append(material.getId());
            }
        } else {
            reply.append("\n\nHi\u1ec7n m\u00ecnh ch\u01b0a th\u1ea5y t\u00e0i li\u1ec7u c\u1ee5 th\u1ec3 \u0111\u1ec3 li\u1ec7t k\u00ea, nh\u01b0ng link tr\u00ean s\u1ebd m\u1edf s\u1eb5n b\u1ed9 l\u1ecdc theo m\u00f4n cho b\u1ea1n.");
        }

        List<Classroom> classrooms = filteredClassroomsForHint(context);
        if (!classrooms.isEmpty()) {
            reply.append("\n\nL\u1edbp h\u1ecdc li\u00ean quan:");
            for (Classroom classroom : classrooms) {
                reply.append("\n- ").append(nullToEmpty(classroom.getTitle()))
                        .append(" | ").append(nullToEmpty(classroom.getGrade()))
                        .append("\n  ").append(contextPath).append("/classroom?id=").append(classroom.getId());
            }
        }

        return reply.toString();
    }

    private String availabilityReply(AiRecommendationService.AiContext context, String message, String contextPath) {
        String normalized = normalize(message);
        String target = readableTarget(context.getHint(), normalized);
        List<Classroom> classrooms = filteredClassroomsForHint(context);
        boolean wantsClassroom = normalized.contains("lop") || normalized.contains("lop hoc");
        boolean wantsCourse = normalized.contains("khoa hoc") || normalized.contains("course");
        boolean wantsMaterial = normalized.contains("tai lieu") || normalized.contains("kho tai lieu");

        if (!wantsClassroom && !wantsCourse && !wantsMaterial) {
            wantsClassroom = true;
            wantsCourse = true;
            wantsMaterial = true;
        }

        StringBuilder reply = new StringBuilder();
        boolean hasRequestedData = (wantsClassroom && !classrooms.isEmpty())
                || (wantsCourse && !context.getCourses().isEmpty())
                || (wantsMaterial && !context.getMaterials().isEmpty());

        if (!hasRequestedData) {
            reply.append("M\u00ecnh ch\u01b0a th\u1ea5y ");
            reply.append(target.isEmpty() ? "d\u1eef li\u1ec7u ph\u00f9 h\u1ee3p" : "d\u1eef li\u1ec7u " + target + " ph\u00f9 h\u1ee3p");
            reply.append(" trong HIPZI.");
            reply.append("\nB\u1ea1n c\u00f3 th\u1ec3 th\u1eed t\u00ecm nhanh \u1edf L\u1edbp h\u1ecdc: ").append(contextPath).append("/classes");
            reply.append("\nHo\u1eb7c Kho t\u00e0i li\u1ec7u: ").append(contextPath).append("/material-repository");
            return reply.toString();
        }

        reply.append("C\u00f3 nh\u00e9. M\u00ecnh t\u00ecm th\u1ea5y trong HIPZI");
        if (!target.isEmpty()) {
            reply.append(" cho ").append(target);
        }
        reply.append(":");

        if (wantsClassroom && !classrooms.isEmpty()) {
            reply.append("\n\nL\u1edbp h\u1ecdc:");
            for (Classroom classroom : classrooms) {
                reply.append("\n- ").append(nullToEmpty(classroom.getTitle()))
                        .append(" | ").append(nullToEmpty(classroom.getGrade()))
                        .append(" | GV: ").append(nullToEmpty(classroom.getTeacherName()))
                        .append("\n  ").append(contextPath).append("/classroom?id=").append(classroom.getId());
            }
        }

        if (wantsCourse && !context.getCourses().isEmpty()) {
            reply.append("\n\nKh\u00f3a h\u1ecdc:");
            for (Course course : context.getCourses()) {
                reply.append("\n- ").append(nullToEmpty(course.getTitle()))
                        .append(" | ").append(nullToEmpty(course.getGradeLevel()))
                        .append("\n  ").append(contextPath).append("/course-detail?id=").append(course.getId());
            }
        }

        if (wantsMaterial && !context.getMaterials().isEmpty()) {
            reply.append("\n\nT\u00e0i li\u1ec7u:");
            for (Material material : context.getMaterials()) {
                reply.append("\n- ").append(nullToEmpty(material.getTitle()))
                        .append(" | ").append(nullToEmpty(material.getGrade()))
                        .append("\n  ").append(contextPath).append("/repository-material-preview?id=").append(material.getId());
            }
        }

        if ((wantsClassroom && classrooms.isEmpty())
                || (wantsCourse && context.getCourses().isEmpty())
                || (wantsMaterial && context.getMaterials().isEmpty())) {
            reply.append("\n\nM\u1ed9t s\u1ed1 nh\u00f3m b\u1ea1n h\u1ecfi hi\u1ec7n ch\u01b0a c\u00f3 d\u1eef li\u1ec7u c\u00f4ng khai ph\u00f9 h\u1ee3p.");
        }

        return reply.toString();
    }

    private String noDataRecommendationReply(String message, String contextPath) {
        String normalized = normalize(message);
        String target = "";
        if (normalized.contains("toan")) {
            target = "To\u00e1n";
        } else if (normalized.contains("tieng anh") || normalized.contains("english")) {
            target = "Ti\u1ebfng Anh";
        } else if (normalized.contains("ngu van") || normalized.contains("van hoc")) {
            target = "Ng\u1eef v\u0103n";
        }

        String prefix = target.isEmpty()
                ? "M\u00ecnh ch\u01b0a th\u1ea5y d\u1eef li\u1ec7u ph\u00f9 h\u1ee3p trong HIPZI cho y\u00eau c\u1ea7u n\u00e0y."
                : "M\u00ecnh ch\u01b0a th\u1ea5y l\u1edbp h\u1ecdc, kh\u00f3a h\u1ecdc ho\u1eb7c t\u00e0i li\u1ec7u " + target + " ph\u00f9 h\u1ee3p trong HIPZI.";
        return prefix + "\nB\u1ea1n c\u00f3 th\u1ec3 th\u1eed t\u00ecm trong Kho t\u00e0i li\u1ec7u: " + contextPath + "/material-repository"
                + "\nHo\u1eb7c xem Kh\u00f3a h\u1ecdc: " + contextPath + "/courses"
                + "\nN\u1ebfu mu\u1ed1n, h\u00e3y n\u00f3i r\u00f5 m\u00f4n, l\u1edbp v\u00e0 ch\u1ee7 \u0111\u1ec1 \u0111\u1ec3 m\u00ecnh t\u00ecm s\u00e1t h\u01a1n.";
    }

    private String normalize(String value) {
        if (value == null) return "";
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('\u0111', 'd')
                .replace('\u0110', 'D')
                .toLowerCase(Locale.ROOT);
        return normalized.replaceAll("[^a-z0-9\\s]", " ").replaceAll("\\s+", " ").trim();
    }

    private String readableTarget(AiRecommendationService.QueryHint hint, String normalizedMessage) {
        if (normalizedMessage.contains("lap trinh") || normalizedMessage.contains("python")
                || normalizedMessage.contains("java") || normalizedMessage.contains("javascript")) {
            return "l\u1eadp tr\u00ecnh/Tin h\u1ecdc";
        }
        if (hint == null) return "";
        if (!hint.getClassroomSubject().isEmpty()) return hint.getClassroomSubject();
        if (!hint.getMaterialSubject().isEmpty()) return hint.getMaterialSubject();
        return "";
    }

    private List<Classroom> filteredClassroomsForHint(AiRecommendationService.AiContext context) {
        List<Classroom> out = new ArrayList<>();
        if (context == null || context.getClassrooms() == null) return out;
        AiRecommendationService.QueryHint hint = context.getHint();
        String subject = hint == null ? "" : normalize(hint.getClassroomSubject());
        String grade = hint == null ? "" : normalize(hint.getGrade());
        for (Classroom classroom : context.getClassrooms()) {
            if (classroom == null) continue;
            String subjectHaystack = normalize(nullToEmpty(classroom.getSubject()) + " " + nullToEmpty(classroom.getTitle()));
            String gradeHaystack = normalize(nullToEmpty(classroom.getGrade()) + " " + nullToEmpty(classroom.getTitle()));
            if (!subject.isEmpty() && !matchesSubject(subjectHaystack, subject)) {
                continue;
            }
            if (!grade.isEmpty() && !gradeHaystack.contains(grade)) {
                continue;
            }
            out.add(classroom);
        }
        return out;
    }

    private boolean matchesSubject(String haystack, String subject) {
        if (subject == null || subject.isEmpty()) return true;
        if (haystack == null) return false;
        if (subject.length() <= 3) {
            return (" " + haystack + " ").contains(" " + subject + " ");
        }
        return haystack.contains(subject);
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }

    private String url(String value) {
        if (value == null) return "";
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private String extractJsonString(String json, String key) {
        if (json == null || key == null) return "";
        String marker = "\"" + key + "\"";
        int markerIndex = json.indexOf(marker);
        if (markerIndex < 0) return "";
        int colon = json.indexOf(':', markerIndex + marker.length());
        if (colon < 0) return "";
        int start = json.indexOf('"', colon + 1);
        if (start < 0) return "";
        StringBuilder out = new StringBuilder();
        boolean escape = false;
        for (int i = start + 1; i < json.length(); i++) {
            char c = json.charAt(i);
            if (escape) {
                if (c == 'n') out.append('\n');
                else if (c == 'r') out.append('\r');
                else if (c == 't') out.append('\t');
                else if (c == 'u' && i + 4 < json.length()) {
                    String hex = json.substring(i + 1, i + 5);
                    try {
                        out.append((char) Integer.parseInt(hex, 16));
                        i += 4;
                    } catch (NumberFormatException ex) {
                        out.append("\\u").append(hex);
                        i += 4;
                    }
                } else {
                    out.append(c);
                }
                escape = false;
            } else if (c == '\\') {
                escape = true;
            } else if (c == '"') {
                break;
            } else {
                out.append(c);
            }
        }
        return out.toString();
    }

    private String config(HttpServletRequest request, String name) {
        String value = getServletContext().getInitParameter(name);
        if (value == null || value.trim().isEmpty()) {
            value = getServletContext().getInitParameter(name.toLowerCase().replace('_', '.'));
        }
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(name);
        }
        return value;
    }

    private void writeJson(HttpServletResponse response, boolean success, String reply) throws IOException {
        String json = "{\"success\":" + success + ",\"reply\":\"" + jsonEscape(reply) + "\"}";
        response.getOutputStream().write(json.getBytes(StandardCharsets.UTF_8));
    }

    private String jsonEscape(String value) {
        if (value == null) return "";
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '"': out.append("\\\""); break;
                case '\\': out.append("\\\\"); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                default:
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int) c));
                    } else {
                        out.append(c);
                    }
            }
        }
        return out.toString();
    }
}
