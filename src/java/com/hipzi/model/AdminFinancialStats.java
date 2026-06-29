package com.hipzi.model;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class AdminFinancialStats {
    private BigDecimal totalCourseRevenue = BigDecimal.ZERO;
    private BigDecimal totalWalletDeposits = BigDecimal.ZERO;
    private BigDecimal totalWithdrawals = BigDecimal.ZERO;
    private BigDecimal totalWalletBalance = BigDecimal.ZERO;
    private List<Map<String, Object>> recentTransactions;

    public BigDecimal getTotalCourseRevenue() { return totalCourseRevenue; }
    public void setTotalCourseRevenue(BigDecimal val) { this.totalCourseRevenue = val; }

    public BigDecimal getTotalWalletDeposits() { return totalWalletDeposits; }
    public void setTotalWalletDeposits(BigDecimal val) { this.totalWalletDeposits = val; }

    public BigDecimal getTotalWithdrawals() { return totalWithdrawals; }
    public void setTotalWithdrawals(BigDecimal val) { this.totalWithdrawals = val; }

    public BigDecimal getTotalWalletBalance() { return totalWalletBalance; }
    public void setTotalWalletBalance(BigDecimal val) { this.totalWalletBalance = val; }

    public List<Map<String, Object>> getRecentTransactions() { return recentTransactions; }
    public void setRecentTransactions(List<Map<String, Object>> recentTransactions) { this.recentTransactions = recentTransactions; }
}
