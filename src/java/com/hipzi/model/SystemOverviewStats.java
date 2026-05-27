package com.hipzi.model;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

public class SystemOverviewStats {
    private int totalUsers;
    private int activeUsers;
    private int inactiveUsers;
    private int verifiedUsers;
    private int usersWithoutRole;
    private int totalMaterials;
    private int totalClassrooms;
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private Map<String, Integer> roleCounts = new LinkedHashMap<>();

    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    public int getActiveUsers() { return activeUsers; }
    public void setActiveUsers(int activeUsers) { this.activeUsers = activeUsers; }

    public int getInactiveUsers() { return inactiveUsers; }
    public void setInactiveUsers(int inactiveUsers) { this.inactiveUsers = inactiveUsers; }

    public int getVerifiedUsers() { return verifiedUsers; }
    public void setVerifiedUsers(int verifiedUsers) { this.verifiedUsers = verifiedUsers; }

    public int getUsersWithoutRole() { return usersWithoutRole; }
    public void setUsersWithoutRole(int usersWithoutRole) { this.usersWithoutRole = usersWithoutRole; }

    public int getTotalMaterials() { return totalMaterials; }
    public void setTotalMaterials(int totalMaterials) { this.totalMaterials = totalMaterials; }

    public int getTotalClassrooms() { return totalClassrooms; }
    public void setTotalClassrooms(int totalClassrooms) { this.totalClassrooms = totalClassrooms; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue != null ? totalRevenue : BigDecimal.ZERO;
    }

    public Map<String, Integer> getRoleCounts() { return roleCounts; }
    public void setRoleCounts(Map<String, Integer> roleCounts) {
        this.roleCounts = roleCounts != null ? roleCounts : new LinkedHashMap<>();
    }

    public int getRoleCount(String roleName) {
        if (roleName == null || roleCounts == null) return 0;
        return roleCounts.getOrDefault(roleName.toLowerCase(), 0);
    }
}
