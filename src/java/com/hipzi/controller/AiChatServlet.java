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
            if (isGeneralLearningQuestion(message) && !isHipziResourceRequest(message)) {
                String reply = groq.isConfigured()
                        ? groq.chatGeneral(message)
                        : generalLearningFallback(message, request.getContextPath());
                writeJson(response, true, reply);
                return;
            }

            AiRecommendationService.AiContext aiContext = recommendationService.buildContext(message, request.getContextPath());
            if (isAvailabilityRequest(message)) {
                writeJson(response, true, availabilityReply(aiContext, message, request.getContextPath()));
                return;
            }
            if (isLearningRoadmapRequest(message)) {
                writeJson(response, true, learningRoadmapReply(message, aiContext, request.getContextPath()));
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

        if (normalized.contains("dang nhap") || normalized.contains("login")) {
            return "B\u1ea1n \u0111\u0103ng nh\u1eadp HIPZI theo c\u00e1c b\u01b0\u1edbc n\u00e0y nh\u00e9:\n"
                    + "1. B\u1ea5m n\u00fat B\u1eaft \u0111\u1ea7u ho\u1eb7c v\u00e0o trang \u0110\u0103ng nh\u1eadp.\n"
                    + "2. Nh\u1eadp email/m\u1eadt kh\u1ea9u ho\u1eb7c ch\u1ecdn \u0111\u0103ng nh\u1eadp Google n\u1ebfu c\u00f3.\n"
                    + "3. Sau khi \u0111\u0103ng nh\u1eadp, b\u1ea1n s\u1ebd \u0111\u01b0\u1ee3c chuy\u1ec3n v\u1ec1 h\u1ed3 s\u01a1 \u0111\u00fang vai tr\u00f2.\n"
                    + "Link: " + contextPath + "/login";
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
        return normalized.contains(" con ") || normalized.startsWith("con ")
                || normalized.contains("co mon") || normalized.contains("co lop")
                || normalized.contains("co khoa hoc") || normalized.contains("co tai lieu")
                || normalized.contains("he thong") || normalized.contains("lop hoc dang co")
                || normalized.contains("nhung lop hoc nao") || normalized.contains("danh sach lop");
    }

    private boolean isHipziResourceRequest(String message) {
        String normalized = normalize(message);
        boolean resourceWord = normalized.contains("tai lieu") || normalized.contains("kho tai lieu")
                || normalized.contains("lop hoc") || normalized.contains("khoa hoc")
                || normalized.contains("phong thi") || normalized.contains("thi thu")
                || normalized.contains("de thi");
        boolean lookupWord = normalized.contains("tim") || normalized.contains("co ")
                || normalized.startsWith("co ") || normalized.contains("con ")
                || normalized.startsWith("con ") || normalized.contains("danh sach")
                || normalized.contains("o dau") || normalized.contains("link")
                || normalized.contains("trong hipzi") || normalized.contains("tren hipzi");
        return resourceWord && lookupWord;
    }

    private boolean isGeneralLearningQuestion(String message) {
        String normalized = normalize(message);
        if (normalized.matches(".*\\d+\\s*(cong|tru|nhan|chia|\\+|\\-|x|\\*)\\s*\\d+.*")) {
            return true;
        }
        boolean learningAction = normalized.contains("giai thich")
                || normalized.contains("la gi")
                || normalized.contains("bang may")
                || normalized.contains("tinh ")
                || normalized.startsWith("tinh ")
                || normalized.contains("lo trinh")
                || normalized.contains("ke hoach")
                || normalized.contains("cach hoc")
                || normalized.contains("hoc nhu the nao")
                || normalized.contains("bat dau tu dau")
                || normalized.contains("nen hoc gi")
                || normalized.contains("goi y hoc")
                || normalized.contains("muon hoc")
                || normalized.contains("yeu phan")
                || normalized.contains("mat goc");
        boolean learningTopic = normalized.contains("hoc")
                || normalized.contains("toan")
                || normalized.contains("dai so")
                || normalized.contains("hinh hoc")
                || normalized.contains("luong giac")
                || normalized.contains("tieng anh")
                || normalized.contains("ngu van")
                || normalized.contains("vat ly")
                || normalized.contains("hoa hoc")
                || normalized.contains("sinh hoc")
                || normalized.contains("lap trinh")
                || normalized.contains("tin hoc")
                || normalized.matches(".*\\d+.*");
        return learningAction && learningTopic;
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

    private boolean isLearningRoadmapRequest(String message) {
        String normalized = normalize(message);
        boolean asksForPlan = normalized.contains("lo trinh")
                || normalized.contains("ke hoach")
                || normalized.contains("cach hoc")
                || normalized.contains("hoc nhu the nao")
                || normalized.contains("bat dau tu dau")
                || normalized.contains("bat dau tu")
                || normalized.contains("nen hoc gi")
                || normalized.contains("goi y hoc")
                || normalized.contains("muon hoc ve")
                || normalized.contains("yeu phan")
                || normalized.contains("mat goc");
        boolean learningTopic = normalized.contains("hoc") || normalized.contains("on tap")
                || normalized.contains("toan") || normalized.contains("luong giac")
                || normalized.contains("tieng anh") || normalized.contains("ngu van")
                || normalized.contains("vat ly") || normalized.contains("hoa hoc")
                || normalized.contains("sinh hoc") || normalized.contains("lap trinh")
                || normalized.contains("tin hoc");
        return asksForPlan && learningTopic;
    }

    private String learningRoadmapReply(String message, AiRecommendationService.AiContext context, String contextPath) {
        String normalized = normalize(message);
        String topic = readableLearningTopic(message, context);
        StringBuilder reply = new StringBuilder();

        if (normalized.contains("luong giac")) {
            reply.append("Được chứ. Nếu bạn đang yếu Toán lượng giác, mình gợi ý lộ trình cơ bản như này:\n")
                    .append("1. Ôn nền tảng: góc, radian/độ, đường tròn lượng giác, sin/cos/tan/cot.\n")
                    .append("2. Nắm giá trị đặc biệt: 0, 30, 45, 60, 90 độ và các góc liên quan trên đường tròn.\n")
                    .append("3. Học công thức cốt lõi: hệ thức cơ bản, công thức cộng, nhân đôi, hạ bậc.\n")
                    .append("4. Luyện biến đổi biểu thức: rút gọn, chứng minh đẳng thức, đổi sin-cos-tan hợp lý.\n")
                    .append("5. Học phương trình lượng giác cơ bản: sin x = a, cos x = a, tan x = a, rồi tới dạng biến đổi đơn giản.\n")
                    .append("6. Làm bài theo mức độ: nhận dạng công thức -> bài áp dụng -> bài tổng hợp.\n\n")
                    .append("Mỗi ngày bạn có thể học 45-60 phút: 15 phút ôn công thức, 30 phút làm bài, 10 phút ghi lại lỗi sai. ");
        } else {
            reply.append("Được chứ. Với ").append(topic.isEmpty() ? "chủ đề bạn đang học" : topic)
                    .append(", mình gợi ý lộ trình cơ bản:\n")
                    .append("1. Xác định mục tiêu: học để lấy lại gốc, ôn kiểm tra hay nâng cao.\n")
                    .append("2. Ôn khái niệm nền tảng và thuật ngữ chính trước khi làm bài.\n")
                    .append("3. Học từng dạng bài nhỏ, mỗi dạng làm vài ví dụ mẫu.\n")
                    .append("4. Luyện bài từ dễ đến trung bình, ghi lại lỗi sai lặp lại.\n")
                    .append("5. Sau 1-2 tuần, làm một bài tổng hợp để kiểm tra phần còn hổng.\n\n")
                    .append("Nếu bạn cho mình biết lớp và mục tiêu cụ thể, mình sẽ chia lịch học sát hơn. ");
        }

        String materialUrl = materialUrlForContext(context, contextPath);
        if (!materialUrl.isEmpty()) {
            reply.append("\n\nBạn cũng có thể mở Kho tài liệu HIPZI theo môn liên quan tại: ").append(materialUrl);
        } else {
            reply.append("\n\nBạn có thể tìm thêm tài liệu luyện tập trong Kho tài liệu HIPZI: ")
                    .append(contextPath).append("/material-repository");
        }

        return reply.toString();
    }

    private String readableLearningTopic(String message, AiRecommendationService.AiContext context) {
        String normalized = normalize(message);
        if (normalized.contains("luong giac")) return "Toán lượng giác";
        if (context != null && context.getHint() != null) {
            if (!context.getHint().getMaterialSubject().isEmpty()) return context.getHint().getMaterialSubject();
            if (!context.getHint().getClassroomSubject().isEmpty()) return context.getHint().getClassroomSubject();
        }
        if (normalized.contains("toan")) return "môn Toán";
        if (normalized.contains("tieng anh") || normalized.contains("english")) return "môn Tiếng Anh";
        if (normalized.contains("ngu van") || normalized.contains("van hoc")) return "môn Ngữ văn";
        if (normalized.contains("lap trinh") || normalized.contains("tin hoc")) return "Tin học/lập trình";
        return "";
    }

    private String generalLearningFallback(String message, String contextPath) {
        String normalized = normalize(message);
        if (normalized.matches(".*\\b1\\s*(\\+|cong)\\s*1\\b.*")) {
            return "1 + 1 = 2.";
        }
        if (normalized.contains("toan") && normalized.contains("lop 10")
                && (normalized.contains("lo trinh") || normalized.contains("ke hoach") || normalized.contains("cach hoc"))) {
            return "M\u00ecnh g\u1ee3i \u00fd l\u1ed9 tr\u00ecnh To\u00e1n l\u1edbp 10 c\u01a1 b\u1ea3n nh\u01b0 sau:\n"
                    + "1. \u00d4n \u0111\u1ea1i s\u1ed1 n\u1ec1n: m\u1ec7nh \u0111\u1ec1, t\u1eadp h\u1ee3p, bi\u1ebfn \u0111\u1ed5i bi\u1ec3u th\u1ee9c.\n"
                    + "2. H\u1ecdc h\u00e0m s\u1ed1 v\u00e0 \u0111\u1ed3 th\u1ecb, \u0111\u1eb7c bi\u1ec7t h\u00e0m b\u1eadc nh\u1ea5t, b\u1eadc hai.\n"
                    + "3. Luy\u1ec7n ph\u01b0\u01a1ng tr\u00ecnh, b\u1ea5t ph\u01b0\u01a1ng tr\u00ecnh v\u00e0 h\u1ec7 ph\u01b0\u01a1ng tr\u00ecnh c\u01a1 b\u1ea3n.\n"
                    + "4. H\u1ecdc vect\u01a1, t\u00edch v\u00f4 h\u01b0\u1edbng v\u00e0 h\u00ecnh h\u1ecdc t\u1ecda \u0111\u1ed9.\n"
                    + "5. Sau m\u1ed7i ch\u01b0\u01a1ng, l\u00e0m 1 \u0111\u1ec1 t\u1ed5ng h\u1ee3p \u0111\u1ec3 t\u00ecm ph\u1ea7n c\u00f2n h\u1ed5ng.\n\n"
                    + "B\u1ea1n c\u00f3 th\u1ec3 t\u00ecm th\u00eam t\u00e0i li\u1ec7u trong HIPZI: " + contextPath + "/material-repository?subject=To%C3%A1n&grade=L%E1%BB%9Bp+10";
        }
        if (isLearningRoadmapRequest(message)) {
            return "\u0110\u01b0\u1ee3c ch\u1ee9. M\u00ecnh g\u1ee3i \u00fd b\u1ea1n h\u1ecdc theo 5 b\u01b0\u1edbc:\n"
                    + "1. X\u00e1c \u0111\u1ecbnh m\u1ee5c ti\u00eau v\u00e0 ph\u1ea7n \u0111ang y\u1ebfu.\n"
                    + "2. \u00d4n kh\u00e1i ni\u1ec7m n\u1ec1n t\u1ea3ng tr\u01b0\u1edbc.\n"
                    + "3. L\u00e0m v\u00ed d\u1ee5 m\u1eabu theo t\u1eebng d\u1ea1ng.\n"
                    + "4. Luy\u1ec7n b\u00e0i t\u1eeb d\u1ec5 \u0111\u1ebfn trung b\u00ecnh v\u00e0 ghi l\u1ea1i l\u1ed7i sai.\n"
                    + "5. M\u1ed7i tu\u1ea7n l\u00e0m m\u1ed9t b\u00e0i t\u1ed5ng h\u1ee3p \u0111\u1ec3 ki\u1ec3m tra ti\u1ebfn \u0111\u1ed9.\n\n"
                    + "B\u1ea1n c\u00f3 th\u1ec3 t\u00ecm th\u00eam t\u00e0i li\u1ec7u trong HIPZI: " + contextPath + "/material-repository";
        }
        return "M\u00ecnh c\u00f3 th\u1ec3 tr\u1ea3 l\u1eddi c\u00e2u h\u1ecfi h\u1ecdc t\u1eadp chung, nh\u01b0ng hi\u1ec7n Groq ch\u01b0a \u0111\u01b0\u1ee3c c\u1ea5u h\u00ecnh. B\u1ea1n th\u00eam GROQ_API_KEYS \u0111\u1ec3 m\u00ecnh tr\u1ea3 l\u1eddi linh ho\u1ea1t h\u01a1n nh\u00e9.";
    }

    private String materialUrlForContext(AiRecommendationService.AiContext context, String contextPath) {
        if (context == null || context.getHint() == null) return "";
        AiRecommendationService.QueryHint hint = context.getHint();
        String subject = !hint.getMaterialSubject().isEmpty() ? hint.getMaterialSubject() : hint.getClassroomSubject();
        if (subject.isEmpty()) return "";
        String materialUrl = contextPath + "/material-repository?subject=" + url(subject);
        if (!hint.getGrade().isEmpty()) {
            materialUrl += "&grade=" + url(hint.getGrade());
        }
        return materialUrl;
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
        boolean wantsClassroom = normalized.contains("lop hoc") || normalized.contains("cac lop")
                || normalized.contains("danh sach lop") || normalized.contains("co lop")
                || normalized.contains("tim lop");
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
