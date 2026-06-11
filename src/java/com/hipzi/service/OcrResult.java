package com.hipzi.service;

public class OcrResult {
    private String plainText;
    private String markdown;
    private String layoutJson;
    private String provider;
    private String requestId;

    public String getPlainText() {
        return plainText;
    }

    public void setPlainText(String plainText) {
        this.plainText = plainText;
    }

    public String getMarkdown() {
        return markdown;
    }

    public void setMarkdown(String markdown) {
        this.markdown = markdown;
    }

    public String getLayoutJson() {
        return layoutJson;
    }

    public void setLayoutJson(String layoutJson) {
        this.layoutJson = layoutJson;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public boolean hasText() {
        return !isBlank(plainText) || !isBlank(markdown);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
