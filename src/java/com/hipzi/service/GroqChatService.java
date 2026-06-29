package com.hipzi.service;

import com.hipzi.model.Classroom;
import com.hipzi.model.Course;
import com.hipzi.model.Material;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

public class GroqChatService {
    private static final String GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";
    private final GroqKeyRotator keyRotator;
    private final String model;
    private final HttpClient httpClient;

    public GroqChatService(String apiKeys, String model) {
        this.keyRotator = new GroqKeyRotator(apiKeys);
        this.model = (model == null || model.trim().isEmpty()) ? "llama-3.1-8b-instant" : model.trim();
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(12))
                .build();
    }

    public boolean isConfigured() {
        return keyRotator.hasKeys();
    }

    public String chat(String userMessage, AiRecommendationService.AiContext context) throws IOException, InterruptedException {
        if (!isConfigured()) {
            return "Hipzi AI chua duoc cau hinh Groq API key. Vui long them GROQ_API_KEYS tren server.";
        }

        int attempts = 0;
        IOException lastIo = null;
        while (attempts < 4) {
            GroqKeyRotator.Lease lease = keyRotator.nextLease();
            if (lease == null) {
                return "Hipzi AI dang ban vi tat ca key tam thoi cham gioi han. Ban thu lai sau mot chut nhe.";
            }
            attempts++;
            String payload = buildPayload(userMessage, context);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(GROQ_URL))
                    .timeout(Duration.ofSeconds(35))
                    .header("Authorization", "Bearer " + lease.getKey())
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .build();
            try {
                HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                int status = response.statusCode();
                if (status == 200) {
                    return extractContent(response.body());
                }
                if (status == 429 || status == 503 || status == 500) {
                    keyRotator.markLimited(lease.getIndex());
                    continue;
                }
                return "Hipzi AI chua the tra loi luc nay. Ma loi Groq: " + status + ".";
            } catch (IOException e) {
                lastIo = e;
                keyRotator.markLimited(lease.getIndex());
            }
        }
        if (lastIo != null) {
            throw lastIo;
        }
        return "Hipzi AI dang qua tai. Ban thu lai sau mot chut nhe.";
    }

    public String chatGeneral(String userMessage) throws IOException, InterruptedException {
        if (!isConfigured()) {
            return "Hipzi AI chua duoc cau hinh Groq API key. Vui long them GROQ_API_KEYS tren server.";
        }

        int attempts = 0;
        IOException lastIo = null;
        while (attempts < 4) {
            GroqKeyRotator.Lease lease = keyRotator.nextLease();
            if (lease == null) {
                return "Hipzi AI dang ban vi tat ca key tam thoi cham gioi han. Ban thu lai sau mot chut nhe.";
            }
            attempts++;
            String payload = buildGeneralPayload(userMessage);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(GROQ_URL))
                    .timeout(Duration.ofSeconds(35))
                    .header("Authorization", "Bearer " + lease.getKey())
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                    .build();
            try {
                HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                int status = response.statusCode();
                if (status == 200) {
                    return extractContent(response.body());
                }
                if (status == 429 || status == 503 || status == 500) {
                    keyRotator.markLimited(lease.getIndex());
                    continue;
                }
                return "Hipzi AI chua the tra loi luc nay. Ma loi Groq: " + status + ".";
            } catch (IOException e) {
                lastIo = e;
                keyRotator.markLimited(lease.getIndex());
            }
        }
        if (lastIo != null) {
            throw lastIo;
        }
        return "Hipzi AI dang qua tai. Ban thu lai sau mot chut nhe.";
    }

    private String buildPayload(String userMessage, AiRecommendationService.AiContext context) {
        String system = "Ban la Hipzi AI, tro ly hoc tap tren website HIPZI. "
                + "Tra loi bang tieng Viet co dau, ngan gon, than thien. "
                + "Neu co danh sach du lieu that ben duoi, chi goi y lop hoc/khoa hoc/tai lieu nam trong danh sach do, khong bia them. "
                + "Khong goi y nguoi dung sang website khac. "
                + "Neu nguoi dung hoi cach dung website, huong dan theo cac muc HIPZI: Kho tai lieu, Lop hoc, Phong thi, Khoa hoc. "
                + "Neu khong co du lieu phu hop cho yeu cau goi y hoc tap, hoi lai ngan gon de lay mon, lop hoac chu de.";
        String user = "Cau hoi cua nguoi dung: " + nullToEmpty(userMessage)
                + "\n\nDu lieu that tim duoc trong HIPZI:\n" + contextText(context)
                + "\nHay tra loi va neu co item phu hop thi liet ke ten + link.";
        return "{"
                + "\"model\":\"" + json(model) + "\","
                + "\"temperature\":0.35,"
                + "\"max_tokens\":650,"
                + "\"messages\":["
                + "{\"role\":\"system\",\"content\":\"" + json(system) + "\"},"
                + "{\"role\":\"user\",\"content\":\"" + json(user) + "\"}"
                + "]"
                + "}";
    }

    private String buildGeneralPayload(String userMessage) {
        String system = "Ban la Hipzi AI, tro ly hoc tap tren website HIPZI. "
                + "Tra loi truc tiep cac cau hoi hoc tap pho thong bang tieng Viet co dau, ngan gon, than thien. "
                + "Co the giai thich phep tinh, khai niem, bai hoc, cach hoc va lo trinh hoc tap. "
                + "Khong bat buoc phai co du lieu trong database HIPZI moi duoc tra loi. "
                + "Neu nguoi dung hoi tim lop hoc, khoa hoc, tai lieu cu the trong HIPZI thi chi nen noi rang he thong se kiem tra du lieu HIPZI, khong bia ten tai nguyen. "
                + "Khong goi y nguoi dung sang website khac.";
        String user = "Cau hoi cua nguoi dung: " + nullToEmpty(userMessage)
                + "\nHay tra loi nhu mot tro ly hoc tap. Neu phu hop, co the noi nguoi dung tim them tai lieu trong HIPZI nhung khong chi tra link.";
        return "{"
                + "\"model\":\"" + json(model) + "\","
                + "\"temperature\":0.35,"
                + "\"max_tokens\":650,"
                + "\"messages\":["
                + "{\"role\":\"system\",\"content\":\"" + json(system) + "\"},"
                + "{\"role\":\"user\",\"content\":\"" + json(user) + "\"}"
                + "]"
                + "}";
    }

    private String contextText(AiRecommendationService.AiContext context) {
        if (context == null || !context.hasData()) {
            return "Khong co lop hoc, khoa hoc hoac tai lieu phu hop trong database cho truy van nay. "
                    + "Neu user hoi cach su dung website, tra loi bang dieu huong HIPZI. "
                    + "Neu user can goi y hoc tap, hoi lai de lay mon, lop hoac chu de.";
        }
        StringBuilder sb = new StringBuilder();
        int index = 1;
        if (!context.getClassrooms().isEmpty()) {
            sb.append("Lop hoc:\n");
            for (Classroom classroom : context.getClassrooms()) {
                sb.append(index++).append(". ")
                        .append(nullToEmpty(classroom.getTitle()))
                        .append(" | Mon: ").append(nullToEmpty(classroom.getSubject()))
                        .append(" | Lop/cap do: ").append(nullToEmpty(classroom.getGrade()))
                        .append(" | Giao vien: ").append(nullToEmpty(classroom.getTeacherName()))
                        .append(" | Lich: ").append(nullToEmpty(classroom.getSchedule()))
                        .append(" | Link: ").append(context.getContextPath()).append("/classroom?id=").append(classroom.getId())
                        .append("\n");
            }
        }
        index = 1;
        if (!context.getCourses().isEmpty()) {
            sb.append("Khoa hoc:\n");
            for (Course course : context.getCourses()) {
                sb.append(index++).append(". ")
                        .append(nullToEmpty(course.getTitle()))
                        .append(" | Mon: ").append(nullToEmpty(course.getSubjectName()))
                        .append(" | Lop/cap do: ").append(nullToEmpty(course.getGradeLevel()))
                        .append(" | Link: ").append(context.getContextPath()).append("/course-detail?id=").append(course.getId())
                        .append("\n");
            }
        }
        index = 1;
        if (!context.getMaterials().isEmpty()) {
            sb.append("Tai lieu:\n");
            for (Material material : context.getMaterials()) {
                sb.append(index++).append(". ")
                        .append(nullToEmpty(material.getTitle()))
                        .append(" | Mon: ").append(nullToEmpty(material.getSubject()))
                        .append(" | Lop/cap do: ").append(nullToEmpty(material.getGrade()))
                        .append(" | Link: ").append(context.getContextPath()).append("/repository-material-preview?id=").append(material.getId())
                        .append("\n");
            }
        }
        return sb.toString();
    }

    private String extractContent(String json) {
        if (json == null || json.isEmpty()) return "";
        String marker = "\"content\"";
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

    private String json(String value) {
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

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
