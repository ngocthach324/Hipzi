<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.TuitionInvoice"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    TuitionInvoice invoice = (TuitionInvoice) request.getAttribute("invoice");
    String qr = (String) request.getAttribute("vietQrUrl");
    String bankLabel = (String) request.getAttribute("bankLabel");
    String bankName = (String) request.getAttribute("bankAccountName");
    String dueLabel = invoice.getDueDate() != null ? invoice.getDueDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Thanh toán học phí - HIPZI</title>
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=12">
    <style>
        body{margin:0;background:#f0fdf4;color:#0f172a;font-family:"Be Vietnam Pro",Arial,sans-serif}body:before,body:after{display:none!important}
        .shell{width:min(980px,calc(100% - 32px));margin:48px auto}.back{color:#047857;text-decoration:none;font-weight:800}
        .head{margin:24px 0}.head h1{margin:0 0 8px;font-size:clamp(1.6rem,4vw,2.25rem)}.head p{margin:0;color:#64748b}
        .grid{display:grid;grid-template-columns:minmax(0,1fr) 330px;gap:20px}.card{background:#fff;border:1px solid #dbe7e3;border-radius:18px;padding:24px;box-shadow:0 18px 40px rgba(15,23,42,.07)}
        .qr{width:min(280px,100%);aspect-ratio:1;margin:auto}.qr img{width:100%;height:100%;object-fit:contain}.row{padding:14px 0;border-bottom:1px solid #e2e8f0}.row:last-child{border:0}.label{font-size:.8rem;color:#64748b;font-weight:700;margin-bottom:5px}.value{font-weight:900;overflow-wrap:anywhere}.amount{font-size:1.55rem;color:#059669}.status{display:inline-flex;padding:7px 12px;border-radius:999px;background:#fff7ed;color:#c2410c;font-weight:800}.status.paid{background:#ecfdf5;color:#047857}
        button,.button{width:100%;box-sizing:border-box;border:0;border-radius:11px;padding:13px 16px;background:#059669;color:#fff;font:inherit;font-weight:900;cursor:pointer;text-align:center;text-decoration:none;display:block;margin-top:12px}.secondary{background:#f1f5f9;color:#334155}
        .note{margin-top:16px;padding:14px;border-radius:12px;background:#f0fdfa;color:#115e59;font-size:.9rem;line-height:1.55;font-weight:650}@media(max-width:760px){.grid{grid-template-columns:1fr}.shell{margin-top:24px}}
    </style>
</head>
<body><main class="shell">
    <a class="back" href="${pageContext.request.contextPath}/student-profile?tab=wallet-history">← Quay lại học phí</a>
    <div class="head"><h1>Thanh toán học phí lớp</h1><p>Mã hóa đơn <strong><%=h(invoice.getInvoiceCode())%></strong> · Hạn nộp <%=h(dueLabel)%></p></div>
    <div class="grid">
        <section class="card"><div class="qr"><img src="<%=h(qr)%>" alt="QR thanh toán học phí"></div><div class="note">Quét QR và giữ nguyên số tiền, nội dung chuyển khoản. Tiền được chuyển vào tài khoản HIPZI; SePay sẽ tự động đối soát và cộng doanh thu vào số dư giảng viên.</div></section>
        <aside class="card">
            <span id="status" class="status <%=invoice.isPaid()?"paid":""%>"><%=invoice.isPaid()?"Đã thanh toán":"Chờ thanh toán"%></span>
            <div class="row"><div class="label">Lớp học</div><div class="value"><%=h(invoice.getClassroomTitle())%></div></div>
            <div class="row"><div class="label">Giảng viên</div><div class="value"><%=h(invoice.getTeacherName())%></div></div>
            <div class="row"><div class="label">Số tiền</div><div class="value amount"><%=h(invoice.getAmountLabel())%></div></div>
            <div class="row"><div class="label">Tài khoản nhận</div><div class="value"><%=h(bankLabel)%> · <%=h(bankName)%></div></div>
            <div class="row"><div class="label">Nội dung chuyển khoản</div><div class="value" id="content"><%=h(invoice.getPaymentContent())%></div></div>
            <% if (!invoice.isPaid()) { %><button type="button" onclick="copyContent()">Sao chép nội dung</button><button type="button" class="secondary" onclick="checkStatus()">Kiểm tra thanh toán</button><% } %>
        </aside>
    </div>
</main><script>
async function copyContent(){await navigator.clipboard.writeText(document.getElementById('content').textContent.trim());}
async function checkStatus(){const r=await fetch('${pageContext.request.contextPath}/tuition-checkout?action=status&id=<%=h(invoice.getId())%>');const d=await r.json();if(d.paid){const s=document.getElementById('status');s.textContent='Đã thanh toán';s.classList.add('paid');setTimeout(()=>location.href='${pageContext.request.contextPath}/student-profile?tab=wallet-history',800);}}
<% if (!invoice.isPaid()) { %>setInterval(checkStatus,5000);<% } %>
</script></body></html>