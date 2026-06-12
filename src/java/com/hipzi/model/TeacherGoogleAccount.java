package com.hipzi.model;

import java.sql.Timestamp;

public class TeacherGoogleAccount {
    private String id;
    private String teacherId;
    private String googleUserId;
    private String googleEmail;
    private String scope;
    private String accessTokenEncrypted;
    private String refreshTokenEncrypted;
    private Timestamp tokenExpiresAt;
    private Timestamp connectedAt;
    private Timestamp lastRefreshedAt;
    private Timestamp revokedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }

    public String getGoogleUserId() { return googleUserId; }
    public void setGoogleUserId(String googleUserId) { this.googleUserId = googleUserId; }

    public String getGoogleEmail() { return googleEmail; }
    public void setGoogleEmail(String googleEmail) { this.googleEmail = googleEmail; }

    public String getScope() { return scope; }
    public void setScope(String scope) { this.scope = scope; }

    public String getAccessTokenEncrypted() { return accessTokenEncrypted; }
    public void setAccessTokenEncrypted(String accessTokenEncrypted) { this.accessTokenEncrypted = accessTokenEncrypted; }

    public String getRefreshTokenEncrypted() { return refreshTokenEncrypted; }
    public void setRefreshTokenEncrypted(String refreshTokenEncrypted) { this.refreshTokenEncrypted = refreshTokenEncrypted; }

    public Timestamp getTokenExpiresAt() { return tokenExpiresAt; }
    public void setTokenExpiresAt(Timestamp tokenExpiresAt) { this.tokenExpiresAt = tokenExpiresAt; }

    public Timestamp getConnectedAt() { return connectedAt; }
    public void setConnectedAt(Timestamp connectedAt) { this.connectedAt = connectedAt; }

    public Timestamp getLastRefreshedAt() { return lastRefreshedAt; }
    public void setLastRefreshedAt(Timestamp lastRefreshedAt) { this.lastRefreshedAt = lastRefreshedAt; }

    public Timestamp getRevokedAt() { return revokedAt; }
    public void setRevokedAt(Timestamp revokedAt) { this.revokedAt = revokedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public boolean isConnected() {
        return revokedAt == null && refreshTokenEncrypted != null && !refreshTokenEncrypted.trim().isEmpty();
    }
}
