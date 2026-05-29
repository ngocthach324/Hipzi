package com.hipzi.service;

import com.hipzi.model.ClassroomQuizQuestion;
import com.hipzi.util.SimpleJson;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class AiQuizParserService {

    private static final String API_URL = "https://api.openai.com/v1/responses";
    private static final String DEFAULT_MODEL = "gpt-4o-mini";
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    public List<ClassroomQuizQuestion> parseQuestions(String ocrText) throws Exception {
        String apiKey = System.getenv("OPENAI_API_KEY");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new IllegalStateException("OPENAI_API_KEY is not configured.");
        }
        if (ocrText == null || ocrText.trim().isEmpty()) {
            return new ArrayList<>();
        }

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(API_URL))
                .timeout(Duration.ofSeconds(60))
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(buildRequestBody(ocrText), StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("OpenAI API error " + response.statusCode() + ": " + response.body());
        }

        String outputText = extractOutputText(response.body());
        return parseQuestionsFromJson(outputText);
    }

    private String buildRequestBody(String ocrText) {
        Map<String, Object> request = new LinkedHashMap<>();
        request.put("model", getModel());
        request.put("temperature", 0);
        request.put("max_output_tokens", 12000);
        request.put("instructions",
                "Bạn là bộ chuẩn hóa OCR đề trắc nghiệm cho HIPZI. "
                + "Chỉ trích xuất câu hỏi và lựa chọn từ OCR text. "
                + "Không tự giải bài, không tự đoán đáp án đúng. "
                + "Chỉ điền correctOption khi OCR text có đáp án rõ ràng như 'Đáp án: A' hoặc bảng đáp án. "
                + "Nếu không chắc, để correctOption là chuỗi rỗng. "
                + "Sửa lỗi OCR nhẹ nhưng không bịa nội dung mới.");
        request.put("input", "OCR TEXT:\n" + ocrText);

        Map<String, Object> text = new LinkedHashMap<>();
        Map<String, Object> format = new LinkedHashMap<>();
        format.put("type", "json_schema");
        format.put("name", "hipzi_quiz_questions");
        format.put("strict", true);
        format.put("schema", buildSchema());
        text.put("format", format);
        request.put("text", text);
        return SimpleJson.stringify(request);
    }

    private Map<String, Object> buildSchema() {
        Map<String, Object> question = new LinkedHashMap<>();
        question.put("type", "object");
        question.put("additionalProperties", false);
        question.put("required", Arrays.asList(
                "questionText", "optionA", "optionB", "optionC", "optionD", "correctOption"));

        Map<String, Object> questionProperties = new LinkedHashMap<>();
        questionProperties.put("questionText", stringSchema());
        questionProperties.put("optionA", stringSchema());
        questionProperties.put("optionB", stringSchema());
        questionProperties.put("optionC", stringSchema());
        questionProperties.put("optionD", stringSchema());
        Map<String, Object> correctOption = stringSchema();
        correctOption.put("enum", Arrays.asList("", "A", "B", "C", "D"));
        questionProperties.put("correctOption", correctOption);
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

    private List<ClassroomQuizQuestion> parseQuestionsFromJson(String json) {
        Map<String, Object> root = SimpleJson.asObject(SimpleJson.parse(json));
        List<ClassroomQuizQuestion> questions = new ArrayList<>();
        int order = 1;
        for (Object item : SimpleJson.asArray(root.get("questions"))) {
            Map<String, Object> questionMap = SimpleJson.asObject(item);
            String questionText = SimpleJson.asString(questionMap, "questionText").trim();
            if (questionText.isEmpty()) {
                continue;
            }
            ClassroomQuizQuestion question = new ClassroomQuizQuestion();
            question.setQuestionText(questionText);
            question.setOptionA(SimpleJson.asString(questionMap, "optionA").trim());
            question.setOptionB(SimpleJson.asString(questionMap, "optionB").trim());
            question.setOptionC(SimpleJson.asString(questionMap, "optionC").trim());
            question.setOptionD(SimpleJson.asString(questionMap, "optionD").trim());
            question.setCorrectOption(normalizeOption(SimpleJson.asString(questionMap, "correctOption")));
            question.setSortOrder(order++);
            questions.add(question);
        }
        return questions;
    }

    private String normalizeOption(String option) {
        if (option == null) {
            return "";
        }
        String cleaned = option.trim().toUpperCase(Locale.ROOT);
        return cleaned.matches("[ABCD]") ? cleaned : "";
    }

    private String getModel() {
        String model = System.getenv("OPENAI_QUIZ_MODEL");
        return model == null || model.trim().isEmpty() ? DEFAULT_MODEL : model.trim();
    }
}
