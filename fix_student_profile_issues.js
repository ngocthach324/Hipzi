const fs = require('fs');

const studentPath = 'e:\\PRJ\\HipZi\\web\\WEB-INF\\views\\student-profile.jsp';
let studentContent = fs.readFileSync(studentPath, 'utf8');

// 1. Fix Sidebar
const sidebarReplacement = `<aside class="dashboard-sidebar">
            <div class="sidebar-brand-horizontal">
                <a href="\${pageContext.request.contextPath}/index" class="brand-avatar-box" title="Trang chủ">
                    <img src="\${pageContext.request.contextPath}/assets/images/favicon.png" alt="Hipzi Logo">
                </a>
                <div class="brand-text-col">
                    <span class="brand-title">Hipzi</span>
                    <span class="brand-subtitle">Platform</span>
                </div>
                <button type="button" class="sidebar-toggle-btn" title="Thu gọn / Mở rộng" onclick="toggleSidebar()">
                    <svg class="icon-collapse" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M16 15l-3-3 3-3"/></svg>
                    <svg class="icon-expand" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="display: none;"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M13 9l3 3-3 3"/></svg>
                </button>
            </div>
            
            <div class="sidebar-section-label">Tổng quan</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-dashboard" class="<%= "tab-dashboard".equals(initialTab) ? "active" : "" %>" onclick="switchTab('tab-dashboard')" title="Tổng quan học tập">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/></svg>
                        <span>Tổng quan học tập</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-profile" class="<%= ("tab-profile".equals(initialTab) || "tab-edit".equals(initialTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')" title="Hồ sơ cá nhân">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <span>Hồ sơ cá nhân</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-support" class="<%= "tab-support".equals(initialTab) ? "active" : "" %>" onclick="switchTab('tab-support')" title="Hỗ trợ học tập">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <span>Hỗ trợ học tập</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">Học tập & Luyện thi</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-materials" class="<%= "tab-materials".equals(initialTab) ? "active" : "" %>" onclick="switchTab('tab-materials')" title="Tài liệu đã lưu">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path></svg>
                        <span>Tài liệu đã lưu</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-history" class="<%= "tab-history".equals(initialTab) ? "active" : "" %>" onclick="switchTab('tab-history')" title="Lịch sử học tập">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        <span>Lịch sử học tập</span>
                    </a>
                </li>
            </ul>
        </aside>`;

const sidebarStartStr = '<aside class="dashboard-sidebar">';
const sidebarEndStr = '</aside>';
const sidebarStartIdx = studentContent.indexOf(sidebarStartStr);
const sidebarEndIdx = studentContent.indexOf(sidebarEndStr, sidebarStartIdx) + sidebarEndStr.length;

if (sidebarStartIdx !== -1 && sidebarEndIdx !== -1) {
    studentContent = studentContent.substring(0, sidebarStartIdx) + sidebarReplacement + studentContent.substring(sidebarEndIdx);
} else {
    console.error("Could not find sidebar");
}

// 2. Fix stray '">\n'
studentContent = studentContent.replace(/<section id="tab-dashboard" class="tab-pane [^>]*">\n">/, '<section id="tab-dashboard" class="tab-pane <%= "tab-dashboard".equals(initialTab) ? "active-pane" : "" %>">');

// 3. Fix charts text
studentContent = studentContent.replace(/>Thời lượng giảng dạy</g, '>Tiến độ học tập<');
studentContent = studentContent.replace(/>18\.5<[\s\S]*?giờ đã dạy/g, '>0</span> giờ đã học');
// I will also target just "giờ đã dạy" to "giờ đã học" across tab-dashboard just in case
const dashboardStart = studentContent.indexOf('<section id="tab-dashboard"');
const dashboardEnd = studentContent.indexOf('</section>', dashboardStart) + 10;
let dashboardHtml = studentContent.substring(dashboardStart, dashboardEnd);
dashboardHtml = dashboardHtml.replace(/giờ đã dạy/g, 'giờ đã học');
dashboardHtml = dashboardHtml.replace(/>18\.5</g, '>0<'); // Reset the hardcoded 18.5 hours to 0

studentContent = studentContent.substring(0, dashboardStart) + dashboardHtml + studentContent.substring(dashboardEnd);

fs.writeFileSync(studentPath, studentContent);
console.log("Fixes applied.");
