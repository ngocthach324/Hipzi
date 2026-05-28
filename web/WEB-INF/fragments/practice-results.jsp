<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Quiz"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    if (quizzes == null || quizzes.isEmpty()) {
%>
    <div class="empty-state">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
        <h3>Chưa có học phần phù hợp</h3>
        <p>Hãy thử đổi môn học, khối lớp, hình thức hoặc từ khóa tìm kiếm.</p>
    </div>
<%
    } else {
        for (Quiz quiz : quizzes) {
%>
        <div class="material-card">
            <div class="material-card-header">
                <span class="subject-badge" style="background: var(--color-secondary-soft, #fff4cc); color: var(--color-secondary, #f0a928);"><%= h(quiz.getSubject()) %></span>
                <span class="view-count">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                    <%= quiz.getAttemptCount() %> lượt học
                </span>
            </div>
            <div class="material-card-body">
                <div style="margin-bottom: 0.5rem;">
                    <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 700; background-color:#fff4cc; color:#b27b00;"><%= h(quiz.getType()) %></span>
                    <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 700; background-color:#ecfdf5; color:#047857; margin-left:0.35rem;"><%= h(quiz.getGrade()) %></span>
                </div>
                <h3 class="material-title"><%= h(quiz.getTitle()) %></h3>
                <p class="teacher-name">GV: <%= h(quiz.getTeacherName()) %></p>
                <p class="teacher-name">Độ khó: <%= h(quiz.getDifficulty()) %> • <%= quiz.getQuestionCount() %> thẻ/câu hỏi</p>
            </div>
            <div class="material-card-footer">
                <a href="<%= request.getContextPath() %>/login.jsp" class="btn btn-primary btn-full" style="background: var(--color-secondary, #f0a928); border-color: var(--color-secondary, #f0a928); color: #ffffff; font-weight: 600; border-radius: 9999px;">Bắt đầu học</a>
            </div>
        </div>
<%
        }
    }
%>
