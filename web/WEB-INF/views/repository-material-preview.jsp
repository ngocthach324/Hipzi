<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="com.hipzi.model.Material"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private boolean hasExt(String fileName, String... extensions) {
        String lower = fileName == null ? "" : fileName.toLowerCase();
        for (String extension : extensions) {
            if (lower.endsWith(extension)) return true;
        }
        return false;
    }
%>
<%
    Material material = (Material) request.getAttribute("material");
    String signedUrl = (String) request.getAttribute("signedUrl");
    String materialId = material != null ? material.getId() : "";
    String title = material != null && material.getTitle() != null ? material.getTitle() : "Tài liệu";
    String fileName = material != null && material.getOriginalFileName() != null ? material.getOriginalFileName() : title;
    String fileType = material != null && material.getFileType() != null ? material.getFileType().toLowerCase() : "";
    boolean isPdf = fileType.contains("pdf") || hasExt(fileName, ".pdf");
    boolean isImage = fileType.startsWith("image/") || hasExt(fileName, ".png", ".jpg", ".jpeg", ".webp");
    boolean isOffice = hasExt(fileName, ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx")
            || fileType.contains("word")
            || fileType.contains("presentation")
            || fileType.contains("spreadsheet")
            || fileType.contains("msword")
            || fileType.contains("ms-powerpoint")
            || fileType.contains("ms-excel");
    String officeViewerUrl = "https://view.officeapps.live.com/op/embed.aspx?src="
            + URLEncoder.encode(signedUrl == null ? "" : signedUrl, StandardCharsets.UTF_8);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= h(title) %> - Xem trước</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <style>
        body {
            margin: 0;
            padding: 0;
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            background: #333333;
        }

        .preview-shell {
            width: 100%;
            height: 100%;
        }

        .preview-stage {
            width: 100%;
            height: 100%;
        }

        .preview-frame,
        .preview-image {
            width: 100%;
            height: 100%;
            border: none;
            display: block;
        }

        .preview-image {
            object-fit: contain;
        }

        .preview-empty {
            max-width: 760px;
            margin: 4rem auto;
            padding: 1.5rem;
            border-radius: 1rem;
            background: #ffffff;
            color: #475569;
            line-height: 1.7;
            font-family: sans-serif;
            text-align: center;
        }
    </style>
</head>
<body>
    <main class="preview-shell">
        <section class="preview-stage">
            <% if (isPdf) { %>
                <iframe class="preview-frame" src="<%= h(signedUrl) %>" title="<%= h(title) %>"></iframe>
            <% } else if (isImage) { %>
                <img class="preview-image" src="<%= h(signedUrl) %>" alt="<%= h(title) %>">
            <% } else if (isOffice) { %>
                <iframe class="preview-frame" src="<%= h(officeViewerUrl) %>" title="<%= h(title) %>"></iframe>
            <% } else { %>
                <div class="preview-empty">
                    Định dạng này chưa hỗ trợ xem trước trực tiếp trong trình duyệt.
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
