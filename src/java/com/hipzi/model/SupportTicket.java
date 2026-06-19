package com.hipzi.model;

import java.sql.Timestamp;

public class SupportTicket {
    private String id;
    private String userId;
    private String assignedStaffId;
    private String title;
    private String status;
    private String priority;
    private String sourceRole;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp resolvedAt;
    private Timestamp closedAt;

    private String userName;
    private String userEmail;
    private String latestMessage;
    private String latestSenderRole;
    private Timestamp latestMessageAt;
    private int messageCount;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getAssignedStaffId() { return assignedStaffId; }
    public void setAssignedStaffId(String assignedStaffId) { this.assignedStaffId = assignedStaffId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getSourceRole() { return sourceRole; }
    public void setSourceRole(String sourceRole) { this.sourceRole = sourceRole; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Timestamp getClosedAt() { return closedAt; }
    public void setClosedAt(Timestamp closedAt) { this.closedAt = closedAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getLatestMessage() { return latestMessage; }
    public void setLatestMessage(String latestMessage) { this.latestMessage = latestMessage; }

    public String getLatestSenderRole() { return latestSenderRole; }
    public void setLatestSenderRole(String latestSenderRole) { this.latestSenderRole = latestSenderRole; }

    public Timestamp getLatestMessageAt() { return latestMessageAt; }
    public void setLatestMessageAt(Timestamp latestMessageAt) { this.latestMessageAt = latestMessageAt; }

    public int getMessageCount() { return messageCount; }
    public void setMessageCount(int messageCount) { this.messageCount = messageCount; }
}
