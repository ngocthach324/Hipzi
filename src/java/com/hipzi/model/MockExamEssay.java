package com.hipzi.model;

import java.sql.Timestamp;

public class MockExamEssay {
    private String id;
    private String mockExamId;
    private String promptText;
    private String referenceAnswer;
    private int sortOrder;
    private Timestamp createdAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getMockExamId() { return mockExamId; }
    public void setMockExamId(String mockExamId) { this.mockExamId = mockExamId; }

    public String getPromptText() { return promptText; }
    public void setPromptText(String promptText) { this.promptText = promptText; }

    public String getReferenceAnswer() { return referenceAnswer; }
    public void setReferenceAnswer(String referenceAnswer) { this.referenceAnswer = referenceAnswer; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
