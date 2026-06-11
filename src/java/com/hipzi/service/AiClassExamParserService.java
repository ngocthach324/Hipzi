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
                + "Chỉ trích xuất nội dung có trong SOURCE TEXT, OCR MARKDOWN, OCR PLAIN TEXT, OCR LAYOUT hoặc ảnh đính kèm; "
                + "sửa lỗi OCR nhẹ nhưng không bịa câu hỏi mới. "
                + "Ưu tiên giữ cấu trúc câu hỏi, lựa chọn, bảng và thứ tự từ OCR MARKDOWN/LAYOUT khi có. "
                + "Không bọc nội dung bằng ký hiệu LaTeX $...$. Chuyển ký hiệu toán phổ biến sang dạng dễ đọc trong ô nhập: "
                + "\\times thành ×, \\frac{a}{b} thành a/b, \\sqrt{x} thành √(x), \\sqrt[3]{x} thành ∛(x), \\angle thành ∠, ^\\circ thành °. "
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
            String questionText = normalizeExtractedMathText(SimpleJson.asString(questionMap, "questionText").trim());
            if (questionText.isEmpty()) {
                continue;
            }
            ClassroomExamQuestion question = new ClassroomExamQuestion();
            question.setQuestionText(questionText);
            if (!"essay".equals(examType)) {
                question.setOptionA(normalizeExtractedMathText(SimpleJson.asString(questionMap, "optionA").trim()));
                question.setOptionB(normalizeExtractedMathText(SimpleJson.asString(questionMap, "optionB").trim()));
                question.setOptionC(normalizeExtractedMathText(SimpleJson.asString(questionMap, "optionC").trim()));
                question.setOptionD(normalizeExtractedMathText(SimpleJson.asString(questionMap, "optionD").trim()));
                question.setCorrectOption(normalizeOption(SimpleJson.asString(questionMap, "correctOption")));
            }
            question.setReferenceAnswer(normalizeExtractedMathText(SimpleJson.asString(questionMap, "referenceAnswer").trim()));
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

    private String normalizeExtractedMathText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "";
        }
        String text = value.trim();

        text = text.replace("\times", "×")
                .replace("\text", "text")
                .replace("\frac{", "\\frac{");
        text = text.replace('\t', '\\');
        text = text.replace("\\times", "×")
                .replace("\\imes", "×")
                .replace("\\cdot", "·")
                .replace("\\div", "÷")
                .replace("\\pm", "±")
                .replace("\\leq", "≤")
                .replace("\\geq", "≥")
                .replace("\\neq", "≠")
                .replace("\\infty", "∞")
                .replace("\\angle", "∠")
                .replace("\\triangle", "△")
                .replace("\\circ", "°")
                .replace("\\degree", "°");

        text = replaceIndexedRoots(text);
        text = replaceSimpleCommand(text, "\\sqrt", "√");
        text = replaceFractions(text);
        text = replaceTextCommands(text);

        text = text.replaceAll("\\$+", "")
                .replaceAll("\\\\left|\\\\right", "")
                .replaceAll("\\\\\\(|\\\\\\)|\\\\\\[|\\\\\\]", "")
                .replaceAll("\\s+°", "°")
                .replaceAll("\\s{2,}", " ")
                .trim();
        return text;
    }

    private String replaceIndexedRoots(String text) {
        String result = text;
        int index = result.indexOf("\\sqrt[");
        while (index >= 0) {
            int bracketOpen = index + "\\sqrt".length();
            int bracketClose = result.indexOf(']', bracketOpen + 1);
            if (bracketClose < 0 || bracketClose + 1 >= result.length() || result.charAt(bracketClose + 1) != '{') {
                break;
            }
            int radicandOpen = bracketClose + 1;
            int radicandClose = findMatchingBrace(result, radicandOpen);
            if (radicandClose < 0) {
                break;
            }
            String rootIndex = result.substring(bracketOpen + 1, bracketClose).trim();
            String radicand = result.substring(radicandOpen + 1, radicandClose);
            String symbol = "3".equals(rootIndex) ? "∛" : ("4".equals(rootIndex) ? "∜" : rootIndex + "√");
            result = result.substring(0, index) + symbol + "(" + radicand + ")" + result.substring(radicandClose + 1);
            index = result.indexOf("\\sqrt[", index + symbol.length() + radicand.length() + 2);
        }
        return result;
    }

    private String replaceSimpleCommand(String text, String command, String replacement) {
        String result = text;
        String marker = command + "{";
        int index = result.indexOf(marker);
        while (index >= 0) {
            int open = index + command.length();
            int close = findMatchingBrace(result, open);
            if (close < 0) {
                break;
            }
            String inside = result.substring(open + 1, close);
            result = result.substring(0, index) + replacement + "(" + inside + ")" + result.substring(close + 1);
            index = result.indexOf(marker, index + replacement.length());
        }
        return result;
    }

    private String replaceFractions(String text) {
        String result = text;
        int index = result.indexOf("\\frac{");
        while (index >= 0) {
            int numeratorOpen = index + "\\frac".length();
            int numeratorClose = findMatchingBrace(result, numeratorOpen);
            if (numeratorClose < 0 || numeratorClose + 1 >= result.length() || result.charAt(numeratorClose + 1) != '{') {
                break;
            }
            int denominatorOpen = numeratorClose + 1;
            int denominatorClose = findMatchingBrace(result, denominatorOpen);
            if (denominatorClose < 0) {
                break;
            }
            String numerator = result.substring(numeratorOpen + 1, numeratorClose);
            String denominator = result.substring(denominatorOpen + 1, denominatorClose);
            result = result.substring(0, index) + numerator + "/" + denominator + result.substring(denominatorClose + 1);
            index = result.indexOf("\\frac{", index + numerator.length() + denominator.length() + 1);
        }
        return result;
    }

    private String replaceTextCommands(String text) {
        String result = text;
        for (String command : Arrays.asList("\\text", "\\ext", "text", "ext")) {
            String marker = command + "{";
            int index = result.indexOf(marker);
            while (index >= 0) {
                int open = index + command.length();
                int close = findMatchingBrace(result, open);
                if (close < 0) {
                    break;
                }
                String inside = result.substring(open + 1, close);
                result = result.substring(0, index) + inside + result.substring(close + 1);
                index = result.indexOf(marker, index + inside.length());
            }
        }
        return result;
    }

    private int findMatchingBrace(String text, int openIndex) {
        if (text == null || openIndex < 0 || openIndex >= text.length() || text.charAt(openIndex) != '{') {
            return -1;
        }
        int depth = 0;
        for (int i = openIndex; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '{') {
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0) {
                    return i;
                }
            }
        }
        return -1;
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
