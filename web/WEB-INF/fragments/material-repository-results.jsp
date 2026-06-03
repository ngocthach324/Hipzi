<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Material"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    private String formatFileSize(long size) {
        if (size <= 0) return "";
        double kb = size / 1024.0;
        if (kb < 1024) return String.format(java.util.Locale.US, "%.0f KB", kb);
        return String.format(java.util.Locale.US, "%.1f MB", kb / 1024.0);
    }
%>
<%
    List<Material> materials = (List<Material>) request.getAttribute("materials");
    if (materials == null || materials.isEmpty()) {
%>
    <div class="empty-state">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
        <h3>Không tìm thấy tài liệu</h3>
        <p>Chưa có tài liệu nào cho môn học này. Hãy thử tìm kiếm với từ khóa khác.</p>
    </div>
<%
    } else {
        for (Material material : materials) {
%>
        <div class="material-card">
            <div class="material-card-header">
                <span class="subject-badge"><%= h(material.getSubject()) %></span>
                <span class="view-count">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    <%= material.getViewCount() %>
                </span>
            </div>
            <div class="material-card-body">
                <div style="margin-bottom: 0.5rem;">
                    <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 500; background-color: <%= "Đề ôn tập".equalsIgnoreCase(material.getType()) ? "#fff4cc" : "#e8f2ff" %>; color: <%= "Đề ôn tập".equalsIgnoreCase(material.getType()) ? "#b27b00" : "#0052cc" %>;">
                        <%= h(material.getType() != null ? material.getType() : "Lý thuyết") %>
                    </span>
                    <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 500; background-color:#ecfdf5; color:#047857; margin-left:0.35rem;"><%= h(material.getGrade()) %></span>
                </div>
                <h3 class="material-title"><%= h(material.getTitle()) %></h3>
                <% if (material.getDescription() != null && !material.getDescription().isEmpty()) { %>
                    <p style="color:#64748b; font-size:0.85rem; line-height:1.55; margin:0.45rem 0 0 0;"><%= h(material.getDescription()) %></p>
                <% } %>
                <p class="teacher-name">GV: <%= h(material.getTeacherName() != null && !material.getTeacherName().isEmpty() ? material.getTeacherName() : "HIPZI Teacher") %></p>
                <p style="color:#94a3b8; font-size:0.78rem; margin:0.35rem 0 0 0;">
                    <%= h(material.getOriginalFileName()) %>
                    <% if (material.getFileSize() > 0) { %>
                        · <%= formatFileSize(material.getFileSize()) %>
                    <% } %>
                </p>
                <% if (material.getRatingCount() > 0) { %>
                    <p style="color:#d97706; font-size:0.8rem; font-weight:700; margin:0.35rem 0 0 0;">★ <%= String.format(java.util.Locale.US, "%.1f", material.getRatingAverage()) %> (<%= material.getRatingCount() %> đánh giá)</p>
                <% } %>
            </div>
            <div class="material-card-footer">
                <a href="<%= request.getContextPath() %>/repository-material-preview?id=<%= h(material.getId()) %>" target="_blank" rel="noopener" class="btn btn-primary btn-full" style="border-radius: 9999px; font-weight: 600;">Xem tài liệu</a>
            </div>
        </div>
<%
        }
    }
%>
<%
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    if (totalPages != null && totalPages > 1) {
%>
    <div class="repo-pagination">
        <button type="button" class="page-btn" <%= currentPage <= 1 ? "disabled" : "" %> data-page="<%= currentPage - 1 %>">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 18l-6-6 6-6"/></svg>
        </button>
        <%
            int startPage = Math.max(1, currentPage - 2);
            int endPage = Math.min(totalPages, currentPage + 2);
            if (startPage > 1) {
        %>
            <button type="button" class="page-btn" data-page="1">1</button>
            <% if (startPage > 2) { %> <span style="align-self: center; color: #94a3b8;">...</span> <% } %>
        <%
            }
            for (int i = startPage; i <= endPage; i++) {
        %>
            <button type="button" class="page-btn <%= i == currentPage ? "active" : "" %>" data-page="<%= i %>"><%= i %></button>
        <%
            }
            if (endPage < totalPages) {
        %>
            <% if (endPage < totalPages - 1) { %> <span style="align-self: center; color: #94a3b8;">...</span> <% } %>
            <button type="button" class="page-btn" data-page="<%= totalPages %>"><%= totalPages %></button>
        <%
            }
        %>
        <button type="button" class="page-btn" <%= currentPage >= totalPages ? "disabled" : "" %> data-page="<%= currentPage + 1 %>">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>
        </button>
    </div>
<%
    }
%>
