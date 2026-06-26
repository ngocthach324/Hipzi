package com.hipzi.model;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class User {
    private String id;
    private String email;
    private String passwordHash;
    private String displayName;
    private String avatarUrl;
    private String accountStatus;
    // OAuth fields
    private String oauthProvider;       // e.g. 'google', null nếu dùng email/password
    private String oauthSub;            // Subject ID từ OAuth provider
    // Onboarding
    private boolean onboardingCompleted; // false = chưa chọn role → redirect /onboarding.jsp
    private boolean emailVerified;       // true = đã xác minh email lần đầu
    private boolean twoFactorEnabled;    // true = yêu cầu OTP khi đăng nhập
    private String studentCode;
    private double walletBalance;        // Số dư ví
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp deletedAt;
    
    // Streak
    private int streakCount;
    private LocalDate lastStreakDate;
    
    // Non-DB field for convenience
    private List<Role> roles;

    public User() {
        this.roles = new ArrayList<>();
        this.walletBalance = 0.0;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getAccountStatus() { return accountStatus; }
    public void setAccountStatus(String accountStatus) { this.accountStatus = accountStatus; }

    public String getOauthProvider() { return oauthProvider; }
    public void setOauthProvider(String oauthProvider) { this.oauthProvider = oauthProvider; }

    public String getOauthSub() { return oauthSub; }
    public void setOauthSub(String oauthSub) { this.oauthSub = oauthSub; }

    public boolean isOnboardingCompleted() { return onboardingCompleted; }
    public void setOnboardingCompleted(boolean onboardingCompleted) { this.onboardingCompleted = onboardingCompleted; }

    public boolean isEmailVerified() { return emailVerified; }
    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }

    public boolean isTwoFactorEnabled() { return twoFactorEnabled; }
    public void setTwoFactorEnabled(boolean twoFactorEnabled) { this.twoFactorEnabled = twoFactorEnabled; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Timestamp getDeletedAt() { return deletedAt; }
    public void setDeletedAt(Timestamp deletedAt) { this.deletedAt = deletedAt; }

    public int getStreakCount() { return streakCount; }
    public void setStreakCount(int streakCount) { this.streakCount = streakCount; }

    public LocalDate getLastStreakDate() { return lastStreakDate; }
    public void setLastStreakDate(LocalDate lastStreakDate) { this.lastStreakDate = lastStreakDate; }

    public double getWalletBalance() { return walletBalance; }
    public void setWalletBalance(double walletBalance) { this.walletBalance = walletBalance; }

    public List<Role> getRoles() { return roles; }
    public void setRoles(List<Role> roles) { this.roles = roles; }
    
    public void addRole(Role role) {
        if (this.roles == null) {
            this.roles = new ArrayList<>();
        }
        this.roles.add(role);
    }
}
