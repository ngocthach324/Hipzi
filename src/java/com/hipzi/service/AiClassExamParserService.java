package com.hipzi.service;

import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.util.SimpleJson;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class AiClassExamParserService {

    private static final String API_URL = "https://api.openai.com/v1/responses";
    private static final String DEFAULT_MODEL = "gpt-4o-mini";
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    public List<ClassroomExamQuestion> parseQuestions(String sourceText, String examType) throws Exception {
        return parseQuestions(sourceText, null, null, examType);
    }

    public List<ClassroomExamQuestion> parseQuestions(
            String sourceText, byte[] imageBytes, String imageContentType, String examType) throws Exception {
        String apiKey = System.getenv("OPENAI_API_KEY");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new IllegalStateException("OPENAI_API_KEY is not configured.");
        }
        if ((sourceText == null || sourceText.trim().isEmpty())
                && (imageBytes == null || imageBytes.length == 0)) {
            return new ArrayList<>();
        }

        String normalizedType = normalizeExamType(examType);
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(API_URL))
                .timeout(Duration.ofSeconds(60))
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(
                        buildRequestBody(sourceText, imageBytes, imageContentType, normalizedType),
                        StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("OpenAI API error " + response.statusCode() + ": " + response.body());
        }
        return parseQuestionsFromJson(extractOutputText(response.body()), normalizedType);
    }

    private String buildRequestBody(String sourceText, byte[] imageBytes, String imageContentType, String examType) {
        Map<String, Object> request = new LinkedHashMap<>();
        request.put("model", getModel());
        request.put("temperature", 0);
        request.put("max_output_tokens", 12000);
        request.put("instructions",
                "Bạn là bộ chuẩn hóa đề thi lớp học cho HIPZI. "
                + "Chỉ trích xuất nội dung có trong SOURCE TEXT, sửa lỗi OCR nhẹ nhưng không bịa câu hỏi mới. "
                + ("essay".equals(examType)
                        ? "Đề là tự luận. Tách từng câu hỏi vào questionText. Để optionA, optionB, optionC, optionD và correctOption là chuỗi rỗng. "
                        + "Chỉ điền referenceAnswer khi nguồn có đáp án hoặc hướng dẫn rõ ràng. "
                        : "Đề là trắc nghiệm. Tách từng câu hỏi và các lựa chọn A, B, C, D. "
                        + "Chỉ điền correctOption khi nguồn ghi đáp án rõ ràng; nếu không chắc, để chuỗi rỗng. "
                        + "Để referenceAnswer là chuỗi rỗng. ")
                + "Giữ points là số nguyên dương, mặc định 1 nếu nguồn không ghi điểm.");
        request.put("input", buildInput(sourceText, imageBytes, imageContentType));

        Map<String, Object> text = new LinkedHashMap<>();
        Map<String, Object> format = new LinkedHashMap<>();
        format.put("type", "json_schema");
        format.put("name", "hipzi_class_exam_questions");
        format.put("strict", true);
        format.put("schema", buildSchema());
        text.put("format", format);
        request.put("text", text);
        return SimpleJson.stringify(request);
    }

    private Object buildInput(String sourceText, byte[] imageBytes, String imageContentType) {
        String cleanedText = sourceText == null ? "" : sourceText.trim();
        if (imageBytes == null || imageBytes.length == 0) {
            return "SOURCE TEXT:\n" + cleanedText;
        }
        List<Object> content = new ArrayList<>();
        Map<String, Object> textInput = new LinkedHashMap<>();
        textInput.put("type", "input_text");
        textInput.put("text", cleanedText.isEmpty()
                ? "Hãy trích xuất đề thi từ ảnh đính kèm."
                : "SOURCE TEXT BỔ SUNG:\n" + cleanedText + "\n\nHãy đối chiếu thêm ảnh đính kèm.");
        content.add(textInput);

        Map<String, Object> imageInput = new LinkedHashMap<>();
        imageInput.put("type", "input_image");
        imageInput.put("image_url", "data:" + normalizeImageContentType(imageContentType) + ";base64,"
                + Base64.getEncoder().encodeToString(imageBytes));
        imageInput.put("detail", "high");
        content.add(imageInput);

        Map<String, Object> message = new LinkedHashMap<>();
        message.put("role", "user");
        message.put("content", content);
        return Arrays.asList(message);
    }

    private String normalizeImageContentType(String contentType) {
        if ("image/jpeg".equalsIgnoreCase(contentType)
                || "image/webp".equalsIgnoreCase(contentType)) {
            return contentType.toLowerCase(Locale.ROOT);
        }
        return "image/png";
    }

    private Map<String, Object> buildSchema() {
        Map<String, Object> question = new LinkedHashMap<>();
        question.put("type", "object");
        question.put("additionalProperties", false);
        question.put("required", Arrays.asList(
                "questionText", "optionA", "optionB", "optionC", "optionD",
                "correctOption", "referenceAnswer", "points"));

        Map<String, Object> questionProperties = new LinkedHashMap<>();
        questionProperties.put("questionText", stringSchema());
        questionProperties.put("optionA", stringSchema());
        questionProperties.put("optionB", stringSchema());
        questionProperties.put("optionC", stringSchema());
        questionProperties.put("optionD", stringSchema());
        Map<String, Object> correctOption = stringSchema();
        correctOption.put("enum", Arrays.asList("", "A", "B", "C", "D"));
        questionProperties.put("correctOption", correctOption);
        questionProperties.put("referenceAnswer", stringSchema());
        Map<String, Object> points = new LinkedHashMap<>();
        points.put("type", "integer");
        points.put("minimum", 1);
        questionProperties.put("points", points);
        question.put("properties", questionProperties);

        Map<String, Object> questions = new LinkedHashMap<>();
        questions.put("type", "array");
        questions.put("items", question);

        Map<String, Object> properties = new LinkedHashMap<>();
        properties.put("questions", questions);

        Map<String, Object> schema = new LinkedHashMap<>();
        schema.put("type", "object");
        schema.put("additionalProperties", false);
        schema.put("required", Arrays.asList("questions"));
        schema.put("properties", properties);
        return schema;
    }

    private Map<String, Object> stringSchema() {
        Map<String, Object> schema = new LinkedHashMap<>();
        schema.put("type", "string");
        return schema;
    }

    private String extractOutputText(String responseJson) {
        Map<String, Object> root = SimpleJson.asObject(SimpleJson.parse(responseJson));
        for (Object outputItem : SimpleJson.asArray(root.get("output"))) {
            Map<String, Object> output = SimpleJson.asObject(outputItem);
            for (Object contentItem : SimpleJson.asArray(output.get("content"))) {
                Map<String, Object> content = SimpleJson.asObject(contentItem);
                if ("output_text".equals(SimpleJson.asString(content, "type"))) {
                    return SimpleJson.asString(content, "text");
                }
            }
        }
        throw new IllegalStateException("OpenAI response did not include output_text.");
    }

    private List<ClassroomExamQuestion> parseQuestionsFromJson(String json, String examType) {
        Map<String, Object> root = SimpleJson.asObject(SimpleJson.parse(json));
        List<ClassroomExamQuestion> questions = new ArrayList<>();
        int order = 1;
        for (Object item : SimpleJson.asArray(root.get("questions"))) {
            Map<String, Object> questionMap = SimpleJson.asObject(item);
            String questionText = SimpleJson.asString(questionMap, "questionText").trim();
            if (questionText.isEmpty()) {
                continue;
            }
            ClassroomExamQuestion question = new ClassroomExamQuestion();
            question.setQuestionText(questionText);
            if (!"essay".equals(examType)) {
                question.setOptionA(SimpleJson.asString(questionMap, "optionA").trim());
                question.setOptionB(SimpleJson.asString(questionMap, "optionB").trim());
                question.setOptionC(SimpleJson.asString(questionMap, "optionC").trim());
                question.setOptionD(SimpleJson.asString(questionMap, "optionD").trim());
                question.setCorrectOption(normalizeOption(SimpleJson.asString(questionMap, "correctOption")));
            }
            question.setReferenceAnswer(SimpleJson.asString(questionMap, "referenceAnswer").trim());
            try {
                question.setPoints(Double.parseDouble(String.valueOf(questionMap.get("points"))));
            } catch (NumberFormatException | NullPointerException e) {
                question.setPoints(1.0);
            }
            question.setSortOrder(order++);
            questions.add(question);
        }
        return questions;
    }

    private String normalizeExamType(String examType) {
        return "essay".equals(examType) ? "essay" : "multiple_choice";
    }

    private String normalizeOption(String option) {
        if (option == null) {
            return "";
        }
        String cleaned = option.trim().toUpperCase(Locale.ROOT);
        return cleaned.matches("[ABCD]") ? cleaned : "";
    }

    private int readPositiveInt(Object value, int defaultValue) {
        if (value instanceof Number) {
            int parsed = ((Number) value).intValue();
            return parsed > 0 ? parsed : defaultValue;
        }
        return defaultValue;
    }

    private String getModel() {
        String model = System.getenv("OPENAI_EXAM_MODEL");
        return model == null || model.trim().isEmpty() ? DEFAULT_MODEL : model.trim();
    }
}
