package com.hipzi.model;

public class CourseAccessSummary {
    private int total;
    private int granted;
    private int failed;
    private int pending;
    private String studentEmail;
    private String lastError;

    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }

    public int getGranted() { return granted; }
    public void setGranted(int granted) { this.granted = granted; }

    public int getFailed() { return failed; }
    public void setFailed(int failed) { this.failed = failed; }

    public int getPending() { return pending; }
    public void setPending(int pending) { this.pending = pending; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getLastError() { return lastError; }
    public void setLastError(String lastError) { this.lastError = lastError; }

    public boolean isAllGranted() {
        return total > 0 && granted == total;
    }

    public boolean hasFailure() {
        return failed > 0;
    }

    public boolean hasPending() {
        return pending > 0 || total == 0;
    }
}
