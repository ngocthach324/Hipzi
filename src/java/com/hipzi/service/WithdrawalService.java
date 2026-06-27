package com.hipzi.service;

import com.hipzi.dao.WithdrawalRequestDao;
import com.hipzi.model.User;
import com.hipzi.model.WithdrawalRequest;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class WithdrawalService {
    private static final BigDecimal MIN_WITHDRAWAL_AMOUNT = new BigDecimal("10000");
    private final WithdrawalRequestDao withdrawalDao = new WithdrawalRequestDao();

    public WithdrawalResult requestMomoWithdrawal(
            User teacher,
            BigDecimal amount,
            String momoPhone,
            String receiverName,
            String note) {
        if (teacher == null || teacher.getId() == null || teacher.getId().trim().isEmpty()) {
            return WithdrawalResult.error("Không tìm thấy tài khoản giảng viên.");
        }
        String validationError = validateMomoRequest(amount, momoPhone, receiverName);
        if (validationError != null) {
            return WithdrawalResult.error(validationError);
        }

        WithdrawalRequest request = withdrawalDao.createMomoRequest(
                teacher.getId(),
                amount,
                momoPhone.trim(),
                receiverName.trim(),
                note
        );
        if (request == null) {
            return WithdrawalResult.error("Số dư không đủ hoặc yêu cầu rút tiền chưa thể tạo. Vui lòng thử lại.");
        }
        return WithdrawalResult.success(request);
    }

    public WithdrawalResult processStaffAction(
            String action,
            String requestId,
            String staffId,
            String payoutReference,
            String staffNote) {
        if (isBlank(requestId) || isBlank(staffId)) {
            return WithdrawalResult.error("Yêu cầu xử lý rút tiền không hợp lệ.");
        }
        boolean ok;
        if ("markWithdrawalProcessing".equals(action)) {
            ok = withdrawalDao.markProcessing(requestId, staffId, staffNote);
            return ok ? WithdrawalResult.message("Đã chuyển yêu cầu rút tiền sang trạng thái đang xử lý.")
                    : WithdrawalResult.error("Không thể cập nhật yêu cầu rút tiền này.");
        }
        if ("markWithdrawalPaid".equals(action)) {
            String reference = isBlank(payoutReference)
                    ? "MOMO-MANUAL-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                    : payoutReference.trim();
            ok = withdrawalDao.markPaid(requestId, staffId, reference, staffNote);
            return ok ? WithdrawalResult.message("Đã xác nhận thanh toán yêu cầu rút tiền MoMo.")
                    : WithdrawalResult.error("Không thể xác nhận thanh toán yêu cầu này.");
        }
        if ("rejectWithdrawal".equals(action) || "failWithdrawal".equals(action)) {
            String note = isBlank(staffNote) ? "Staff từ chối yêu cầu rút tiền MoMo." : staffNote.trim();
            String status = "failWithdrawal".equals(action) ? "failed" : "rejected";
            ok = withdrawalDao.rejectOrFail(requestId, staffId, status, note);
            return ok ? WithdrawalResult.message("Đã hoàn tiền và cập nhật trạng thái yêu cầu rút tiền.")
                    : WithdrawalResult.error("Không thể cập nhật yêu cầu rút tiền này.");
        }
        return WithdrawalResult.error("Không nhận diện được thao tác rút tiền.");
    }

    private String validateMomoRequest(BigDecimal amount, String momoPhone, String receiverName) {
        if (amount == null || amount.compareTo(MIN_WITHDRAWAL_AMOUNT) < 0) {
            return "Số tiền rút tối thiểu là 10.000đ.";
        }
        if (momoPhone == null || !momoPhone.trim().matches("^0\\d{9}$")) {
            return "Vui lòng nhập số điện thoại MoMo hợp lệ.";
        }
        if (receiverName == null || receiverName.trim().length() < 2) {
            return "Vui lòng nhập tên người nhận MoMo.";
        }
        return null;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static class WithdrawalResult {
        private final boolean success;
        private final String message;
        private final WithdrawalRequest request;

        private WithdrawalResult(boolean success, String message, WithdrawalRequest request) {
            this.success = success;
            this.message = message;
            this.request = request;
        }

        public static WithdrawalResult success(WithdrawalRequest request) {
            return new WithdrawalResult(true, "Đã tạo yêu cầu rút tiền MoMo. Staff sẽ xử lý trong thời gian sớm nhất.", request);
        }

        public static WithdrawalResult message(String message) {
            return new WithdrawalResult(true, message, null);
        }

        public static WithdrawalResult error(String message) {
            return new WithdrawalResult(false, message, null);
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public WithdrawalRequest getRequest() { return request; }
    }
}
