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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=3">
    <style>
        body {
            min-height: 100vh;
            margin: 0;
            background: #eef6f1;
            color: #102033;
        }

        .preview-shell {
            min-height: 100vh;
            display: grid;
            grid-template-rows: auto 1fr;
        }

        .preview-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            padding: 1rem 1.25rem;
            background: rgba(255, 255, 255, 0.96);
            border-bottom: 1px solid #dbe7df;
            box-shadow: 0 12px 30px rgba(16, 32, 51, 0.08);
            position: sticky;
            top: 0;
            z-index: 2;
        }

        .preview-title strong,
        .preview-title span {
            display: block;
        }

        .preview-title strong {
            font-size: 1rem;
        }

        .preview-title span {
            margin-top: 0.15rem;
            color: #64748b;
            font-size: 0.88rem;
        }

        .preview-actions {
            display: flex;
            gap: 0.65rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .preview-btn {
            border: 1px solid #bbf7d0;
            border-radius: 999px;
            padding: 0.65rem 1rem;
            background: #ffffff;
            color: #15803d;
            font-weight: 850;
            text-decoration: none;
            white-space: nowrap;
        }

        .preview-btn.primary {
            background: #059669;
            border-color: #059669;
            color: #ffffff;
        }

        .preview-stage {
            padding: 1rem;
            min-height: 0;
        }

        .preview-frame,
        .preview-image {
            width: 100%;
            height: calc(100vh - 104px);
            min-height: 560px;
            border: 1px solid #dbe7df;
            border-radius: 1rem;
            background: #ffffff;
            box-shadow: 0 18px 50px rgba(16, 32, 51, 0.12);
        }

        .preview-image {
            object-fit: contain;
            padding: 1rem;
            box-sizing: border-box;
        }

        .preview-empty {
            max-width: 760px;
            margin: 4rem auto;
            padding: 1.5rem;
            border-radius: 1rem;
            background: #ffffff;
            border: 1px solid #dbe7df;
            color: #475569;
            line-height: 1.7;
        }

        @media (max-width: 720px) {
            .preview-bar {
                align-items: flex-start;
                flex-direction: column;
            }

            .preview-actions {
                width: 100%;
                justify-content: flex-start;
            }

            .preview-frame,
            .preview-image {
                height: calc(100vh - 168px);
                min-height: 420px;
            }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap">
</head>
<body>
    <main class="preview-shell">
        <header class="preview-bar">
            <div class="preview-title">
                <strong><%= h(title) %></strong>
                <span><%= h(fileName) %></span>
            </div>
            <div class="preview-actions">
                <a class="preview-btn" href="${pageContext.request.contextPath}/material-repository">Quay lại kho</a>
                <a class="preview-btn primary" href="${pageContext.request.contextPath}/repository-material-file?id=<%= h(materialId) %>&mode=download">Tải</a>
            </div>
        </header>

        <section class="preview-stage">
            <% if (isPdf) { %>
                <iframe class="preview-frame" src="<%= h(signedUrl) %>" title="<%= h(title) %>"></iframe>
            <% } else if (isImage) { %>
                <img class="preview-image" src="<%= h(signedUrl) %>" alt="<%= h(title) %>">
            <% } else if (isOffice) { %>
                <iframe class="preview-frame" src="<%= h(officeViewerUrl) %>" title="<%= h(title) %>"></iframe>
            <% } else { %>
                <div class="preview-empty">
                    Định dạng này chưa hỗ trợ xem trước trực tiếp trong trình duyệt. Bạn vẫn có thể dùng nút Tải để mở trên thiết bị.
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
