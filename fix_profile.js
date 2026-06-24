const fs = require('fs');
const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let content = fs.readFileSync(filePath, 'utf8');

// 1. INJECT CSS
const cssToInject = `
        /* ===== THỀ METRICS (DONEZO STYLE) ===== */
        .metrics-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.25rem;
        }

        @media (max-width: 1024px) {
            .metrics-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 640px) {
            .metrics-row {
                grid-template-columns: 1fr;
            }
        }

        .metric-card {
            border-radius: 1.5rem;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 140px;
            box-sizing: border-box;
            position: relative;
            overflow: hidden;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-top: 4px solid var(--primary);
            color: var(--text-main);
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
            cursor: pointer;
        }

        .metric-card.primary {
            background: #ffffff;
            color: var(--text-main);
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.06);
        }

        .metric-card.secondary {
            background: #ffffff;
        }

        .metrics-row .metric-card:nth-child(1) {
            border-top-color: var(--primary);
        }

        .metrics-row .metric-card:nth-child(2) {
            border-top-color: #7c3aed;
        }

        .metrics-row .metric-card:nth-child(3) {
            border-top-color: #ea580c;
        }

        .metrics-row .metric-card:nth-child(4) {
            border-top-color: #2563eb;
        }

        .metric-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 16px 34px rgba(15, 23, 42, 0.1);
        }

        .metric-card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .metric-card-title {
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            opacity: 0.9;
        }

        .metric-card.secondary .metric-card-title {
            color: var(--text-muted);
        }

        .metric-card.primary .metric-card-title {
            color: var(--text-muted);
        }

        .metric-arrow-btn {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-dark);
            background: var(--border-light);
            color: var(--primary);
            transition: all 0.2s ease;
        }

        .metric-card.secondary .metric-arrow-btn {
            border-color: var(--border-dark);
            background: var(--border-light);
            color: var(--text-main);
        }

        .metric-card-value {
            font-size: 2.2rem;
            font-weight: 800;
            margin: 0.75rem 0 0.35rem 0;
            line-height: 1;
            position: relative;
            z-index: 1;
        }

        .metric-card-sub {
            font-size: 0.78rem;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            padding: 0.24rem 0.62rem;
            border-radius: 0.5rem;
            width: fit-content;
            position: relative;
            z-index: 1;
        }

        .metric-card.primary .metric-card-sub {
            background: var(--primary-light);
            color: var(--primary);
        }

        .metric-card.secondary .metric-card-sub {
            background: var(--primary-light);
            color: var(--primary);
        }

        .metric-ghost-icon {
            position: absolute;
            right: 1.15rem;
            bottom: 1rem;
            width: 64px;
            height: 64px;
            border-radius: 1.25rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            background: var(--primary-light);
            opacity: 0.28;
            transform: rotate(-6deg);
            pointer-events: none;
        }

        .metric-ghost-icon svg {
            width: 34px;
            height: 34px;
            stroke-width: 2.1;
        }
`;
const insertCssAt = content.indexOf('/* Buttons & Forms - Copied from teacher-profile */');
if (insertCssAt > -1 && !content.includes('.metrics-row')) {
    content = content.substring(0, insertCssAt) + cssToInject + "\n        " + content.substring(insertCssAt);
}

// 2. INJECT DASHBOARD HTML
const startStr = '<!-- Lưới 4 Thẻ bên trong (2 thẻ trên, 2 thẻ dưới) -->';
const endStr = '</section>';
const startIndex = content.indexOf(startStr);
const endIndex = content.indexOf(endStr, startIndex);

if (startIndex > -1 && endIndex > -1) {
    const dashboardReplacementHtml = `<!-- Lưới 4 Thẻ bên trong -->
                                                                                <div class="metrics-row">
                                                                                    
                                                                                    <!-- Lớp học đã tham gia -->
                                                                                    <div class="metric-card primary" onclick="switchTab('tab-classes')">
                                                                                        <div class="metric-card-top">
                                                                                            <span class="metric-card-title">Lớp học đã tham gia</span>
                                                                                            <div class="metric-arrow-btn">
                                                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="19" x2="19" y2="5"></line><polyline points="10 5 19 5 19 14"></polyline></svg>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="metric-card-value"><%= studentProfile.getActiveClassesCount() %></div>
                                                                                        <span class="metric-card-sub">Lớp hoạt động</span>
                                                                                        <div class="metric-ghost-icon">
                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path></svg>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Khóa học đã mua -->
                                                                                    <div class="metric-card secondary" onclick="switchTab('tab-courses')">
                                                                                        <div class="metric-card-top">
                                                                                            <span class="metric-card-title">Khóa học đã mua</span>
                                                                                            <div class="metric-arrow-btn">
                                                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="19" x2="19" y2="5"></line><polyline points="10 5 19 5 19 14"></polyline></svg>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="metric-card-value">0</div>
                                                                                        <span class="metric-card-sub" style="background:#f5f3ff; color:#7c3aed;">Đang phát hành</span>
                                                                                        <div class="metric-ghost-icon" style="color:#7c3aed; background:#f5f3ff;">
                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Cấp độ học viên -->
                                                                                    <div class="metric-card secondary">
                                                                                        <div class="metric-card-top">
                                                                                            <span class="metric-card-title">Cấp độ học viên</span>
                                                                                            <div class="metric-arrow-btn">
                                                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="19" x2="19" y2="5"></line><polyline points="10 5 19 5 19 14"></polyline></svg>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="metric-card-value">Cấp <%= studentProfile.getCurrentLevel() %></div>
                                                                                        <span class="metric-card-sub" style="background:#fff7ed; color:#ea580c;">Mới bắt đầu</span>
                                                                                        <div class="metric-ghost-icon" style="color:#ea580c; background:#fff7ed;">
                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Đặt lịch học -->
                                                                                    <div class="metric-card secondary" onclick="openScheduleModal()" style="cursor: pointer; border-top-color: #3b82f6;">
                                                                                        <div class="metric-card-top">
                                                                                            <span class="metric-card-title">Đặt lịch học</span>
                                                                                            <div class="metric-arrow-btn">
                                                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="19" x2="19" y2="5"></line><polyline points="10 5 19 5 19 14"></polyline></svg>
                                                                                            </div>
                                                                                        </div>
                                                                                        <div class="metric-card-value" style="font-size: 1.45rem; margin-top: 1.25rem;">Xem lịch trình</div>
                                                                                        <span class="metric-card-sub" style="background:#eff6ff; color:#2563eb;">Tuần này</span>
                                                                                        <div class="metric-ghost-icon" style="color:#2563eb; background:#eff6ff;">
                                                                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                                                                                        </div>
                                                                                    </div>

                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    `;
    content = content.substring(0, startIndex) + dashboardReplacementHtml + content.substring(endIndex);
}

// 3. REPLACE ROLE PILL WITH STUDENT CODE PILL
const roleRegex = /<div class="account-meta-pill">\s*<span class="account-meta-label">Vai trò<\/span>\s*<span class="account-meta-value">\s*<span class="role-tag student">Học viên<\/span>\s*<\/span>\s*<\/div>/g;
const newStudentCodeBlock = `<div class="account-meta-pill">
                                                                                        <span class="account-meta-label">Mã học viên</span>
                                                                                        <span class="account-meta-value">
                                                                                            <span class="role-tag student" onclick="event.stopPropagation(); copyStudentCode(this.textContent.trim());" title="Nhấn để sao chép mã học viên" style="cursor: pointer;"><%= (user != null && user.getStudentCode() != null) ? user.getStudentCode() : "HZ-PENDING" %></span>
                                                                                        </span>
                                                                                    </div>`;
content = content.replace(roleRegex, newStudentCodeBlock);

// 4. REMOVE THE OLD DASHBOARD STUDENT CODE BADGE SAFELY
// The old dashboard badge starts with '<div style="display:flex; align-items:center; gap:0.5rem; background:#f0fdf4;'
const exactBadgeStart = '<div style="display:flex; align-items:center; gap:0.5rem; background:#f0fdf4; border:1px solid #bbf7d0;';
const actualBadgeStart = content.indexOf(exactBadgeStart);

if (actualBadgeStart > -1) {
    // The parent div is one level up
    const parentDivStart = content.lastIndexOf('<div', actualBadgeStart - 1);
    
    // The end is marked by "HZ-PENDING" %></span></div></div>
    const pendingIndex = content.indexOf('HZ-PENDING" %>', actualBadgeStart);
    if (pendingIndex > -1) {
        // Find the second </div> after HZ-PENDING
        let endIdx = content.indexOf('</div>', pendingIndex); // first </div>
        if (endIdx > -1) {
            endIdx = content.indexOf('</div>', endIdx + 6); // second </div>
            if (endIdx > -1) {
                content = content.substring(0, parentDivStart) + content.substring(endIdx + 6);
            }
        }
    }
}

fs.writeFileSync(filePath, content);
console.log('All changes applied successfully!');
