package com.hipzi.util;

import com.hipzi.model.CourseOrder;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public final class PaymentConfig {
    private static final String DEFAULT_BANK_ACQ_ID = "970423";
    private static final String DEFAULT_BANK_ACCOUNT_NO = "86625062006";
    private static final String DEFAULT_BANK_ACCOUNT_NAME = "NGUYEN NGOC THACH";
    private static final String DEFAULT_QR_TEMPLATE = "compact2";

    private PaymentConfig() {
    }

    public static String bankAccountNo() {
        return configValue("BANK_ACCOUNT_NO", DEFAULT_BANK_ACCOUNT_NO);
    }

    public static String bankAccountName() {
        return configValue("BANK_ACCOUNT_NAME", DEFAULT_BANK_ACCOUNT_NAME);
    }

    public static String bankAcqId() {
        return configValue("BANK_ACQ_ID", DEFAULT_BANK_ACQ_ID);
    }

    public static String bankLabel() {
        String label = configValue("BANK_LABEL", "");
        if (!label.isEmpty()) {
            return label;
        }
        return "TPBank " + bankAccountNo();
    }

    public static String vietQrUrl(CourseOrder order) {
        if (order == null || order.getTotalAmount() == null) {
            return "";
        }

        BigDecimal amount = order.getTotalAmount().setScale(0, RoundingMode.HALF_UP);
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            return "";
        }
        String template = configValue("VIETQR_TEMPLATE", DEFAULT_QR_TEMPLATE);
        return "https://img.vietqr.io/image/"
                + encodePath(bankAcqId())
                + "-"
                + encodePath(bankAccountNo())
                + "-"
                + encodePath(template)
                + ".png?amount="
                + encode(amount.toPlainString())
                + "&addInfo="
                + encode(order.getPaymentContent())
                + "&accountName="
                + encode(bankAccountName());
    }

    public static String vietQrUrl(BigDecimal amountValue, String paymentContent) {
        if (amountValue == null || amountValue.compareTo(BigDecimal.ZERO) <= 0) return "";
        BigDecimal amount = amountValue.setScale(0, RoundingMode.HALF_UP);
        String template = configValue("VIETQR_TEMPLATE", DEFAULT_QR_TEMPLATE);
        return "https://img.vietqr.io/image/"
                + encodePath(bankAcqId()) + "-" + encodePath(bankAccountNo()) + "-" + encodePath(template)
                + ".png?amount=" + encode(amount.toPlainString())
                + "&addInfo=" + encode(paymentContent)
                + "&accountName=" + encode(bankAccountName());
    }
    private static String configValue(String key, String fallback) {
        String value = System.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }

    private static String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private static String encodePath(String value) {
        return encode(value).replace("+", "%20");
    }
}
