<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Material"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String displaySubject(String subject) {
        if (subject == null) return "";
        String key = normalizeKey(subject);
        if ("toan".equals(key)) return "Toán học";
        if ("van".equals(key) || "nguvan".equals(key)) return "Ngữ văn";
        if ("anh".equals(key) || "tienganh".equals(key)) return "Tiếng Anh";
        if ("ly".equals(key) || "vatly".equals(key) || "vatli".equals(key)) return "Vật lí";
        if ("hoa".equals(key) || "hoahoc".equals(key)) return "Hóa học";
        if ("sinh".equals(key) || "sinhhoc".equals(key)) return "Sinh học";
        if ("lichsu".equals(key)) return "Lịch sử";
        if ("dialy".equals(key) || "diali".equals(key)) return "Địa lí";
        if ("congnghe".equals(key)) return "Công nghệ";
        if ("tinhoc".equals(key)) return "Tin học";
        return subject.trim();
    }

    private String displayType(String type) {
        String key = normalizeKey(type);
        if ("deontap".equals(key)) return "Đề ôn tập";
        if ("lythuyet".equals(key)) return "Lý thuyết";
        return type == null || type.trim().isEmpty() ? "Lý thuyết" : type.trim();
    }

    private String displayTitle(Material material) {
        String raw = material == null ? "" : material.getTitle();
        if (raw == null || raw.trim().isEmpty()) {
            raw = material != null ? material.getOriginalFileName() : "";
        }

        String base = stripExtension(raw).replace('_', '-').replaceAll("\\s+", "-");
        String key = normalizeSlug(base);
        String subject = displaySubject(material != null ? material.getSubject() : "");

        if (key.matches(".*de-thi-thu-(tot-nghiep|tn)-thpt-20[0-9]{2}-mon-.*")) {
            String year = firstYear(key);
            return "Đề thi thử tốt nghiệp THPT" + (year.isEmpty() ? "" : " " + year) + " môn " + subject;
        }
        if (key.matches(".*de-khao-sat-chat-luong.*")) {
            String year = firstYear(key);
            return "Đề khảo sát chất lượng" + (year.isEmpty() ? "" : " " + year) + " môn " + subject;
        }
        if (key.matches(".*de-kscl.*")) {
            String year = firstYear(key);
            return "Đề khảo sát chất lượng" + (year.isEmpty() ? "" : " " + year) + " môn " + subject;
        }

        return titleCaseVietnamese(base);
    }

    private String displayDescription(Material material) {
        if (material == null) return "";
        if ("SYSTEM".equalsIgnoreCase(material.getUploadedBy())
                && material.getOriginalFileName() != null
                && !material.getOriginalFileName().trim().isEmpty()) {
            return material.getOriginalFileName().trim();
        }
        String subject = displaySubject(material.getSubject());
        String grade = material.getGrade() == null ? "" : material.getGrade().trim();
        if ("Ôn thi THPT".equalsIgnoreCase(grade)) {
            return "Tài liệu ôn thi THPT môn " + subject + ".";
        }
        if (!grade.isEmpty()) {
            return "Tài liệu " + grade + " môn " + subject + ".";
        }
        return "Tài liệu môn " + subject + ".";
    }

    private String stripExtension(String value) {
        if (value == null) return "";
        int dot = value.lastIndexOf('.');
        return dot > 0 ? value.substring(0, dot) : value;
    }

    private String firstYear(String key) {
        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("(20[0-9]{2})").matcher(key);
        return matcher.find() ? matcher.group(1) : "";
    }

    private String titleCaseVietnamese(String value) {
        String[] tokens = stripExtension(value).replace('-', ' ').replace('_', ' ').replaceAll("\\s+", " ").trim().split(" ");
        StringBuilder result = new StringBuilder();
        for (String token : tokens) {
            String word = displayWord(token);
            if (word.isEmpty()) continue;
            if (result.length() > 0) result.append(' ');
            result.append(word);
        }
        return result.toString();
    }

    private String displayWord(String token) {
        String key = normalizeKey(token);
        if (key.isEmpty()) return "";
        if ("de".equals(key)) return "Đề";
        if ("thi".equals(key)) return "thi";
        if ("thu".equals(key)) return "thử";
        if ("tot".equals(key)) return "tốt";
        if ("nghiep".equals(key)) return "nghiệp";
        if ("thpt".equals(key)) return "THPT";
        if ("tn".equals(key)) return "TN";
        if ("mon".equals(key)) return "môn";
        if ("toan".equals(key)) return "Toán";
        if ("ngu".equals(key)) return "ngữ";
        if ("van".equals(key)) return "văn";
        if ("tieng".equals(key)) return "tiếng";
        if ("anh".equals(key)) return "Anh";
        if ("vat".equals(key)) return "vật";
        if ("ly".equals(key) || "li".equals(key)) return "lí";
        if ("hoa".equals(key)) return "hóa";
        if ("hoc".equals(key)) return "học";
        if ("sinh".equals(key)) return "sinh";
        if ("lich".equals(key)) return "lịch";
        if ("su".equals(key)) return "sử";
        if ("dia".equals(key)) return "địa";
        if ("cong".equals(key)) return "công";
        if ("nghe".equals(key)) return "nghệ";
        if ("lan".equals(key)) return "lần";
        if ("so".equals(key)) return "sở";
        if ("gddt".equals(key)) return "GD&ĐT";
        if ("tp".equals(key)) return "TP";
        if (key.matches("[0-9]+")) return token;
        return token.substring(0, 1).toUpperCase(java.util.Locale.ROOT) + token.substring(1).toLowerCase(java.util.Locale.ROOT);
    }

    private String normalizeKey(String value) {
        if (value == null) return "";
        return java.text.Normalizer.normalize(value, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace("đ", "d")
                .replace("Đ", "D")
                .replaceAll("[^A-Za-z0-9]", "")
                .toLowerCase(java.util.Locale.ROOT);
    }

    private String normalizeSlug(String value) {
        if (value == null) return "";
        return java.text.Normalizer.normalize(value, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace("đ", "d")
                .replace("Đ", "D")
                .replaceAll("[^A-Za-z0-9]+", "-")
                .replaceAll("^-+|-+$", "")
                .toLowerCase(java.util.Locale.ROOT);
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
            String materialTypeLabel = displayType(material.getType());
%>
        <div class="material-card">
            <div class="material-card-header">
                <span class="subject-badge"><%= h(displaySubject(material.getSubject())) %></span>
                <span class="view-count">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    <%= material.getViewCount() %>
                </span>
            </div>
            <div class="material-card-body">
                <div style="margin-bottom: 0.5rem;">
                    <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 500; background-color: <%= "Đề ôn tập".equalsIgnoreCase(materialTypeLabel) ? "#fff4cc" : "#e8f2ff" %>; color: <%= "Đề ôn tập".equalsIgnoreCase(materialTypeLabel) ? "#b27b00" : "#0052cc" %>;">
                        <%= h(materialTypeLabel) %>
                    </span>
                    <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 500; background-color:#ecfdf5; color:#047857; margin-left:0.35rem;"><%= h(material.getGrade()) %></span>
                </div>
                <h3 class="material-title"><%= h(displayTitle(material)) %></h3>
                <p class="material-description"><%= h(displayDescription(material)) %></p>
                <p class="teacher-name">GV: <%= h(material.getTeacherName() != null && !material.getTeacherName().isEmpty() ? material.getTeacherName() : "HIPZI Teacher") %></p>
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
