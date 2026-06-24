const fs = require('fs');
const { execSync } = require('child_process');

const studentFile = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
const teacherFile = 'e:/PRJ/HipZi/web/WEB-INF/views/teacher-profile.jsp';

// 1. Get original file from git HEAD
let content = execSync('git show HEAD:web/WEB-INF/views/student-profile.jsp').toString('utf8');

// 2. Fix the missing `}` for textarea:focus
content = content.replace(
    '        .form-group-premium textarea:focus {\n            border-color: var(--primary);\n            box-shadow: 0 0 0 3px var(--primary-light);\n            background: #ffffff;\n\n        /* ===== HEADER CỦA TAB ===== */',
    '        .form-group-premium textarea:focus {\n            border-color: var(--primary);\n            box-shadow: 0 0 0 3px var(--primary-light);\n            background: #ffffff;\n        }\n\n        /* ===== HEADER CỦA TAB ===== */'
);

// 3. Fix the .tab-pane flex layout
content = content.replace(
    '        body.student-profile-page .tab-pane {\n            display: none;\n            animation: fadeUp 0.28s ease-out;\n        }\n\n        body.student-profile-page .tab-pane.active-pane {\n            display: block;\n        }',
    '        body.student-profile-page .tab-pane {\n            display: none;\n            flex-direction: column;\n            gap: 2rem;\n            animation: fadeUp 0.28s ease-out;\n        }\n\n        body.student-profile-page .tab-pane.active-pane {\n            display: flex;\n        }'
);

// 4. Inject metric-card CSS
const teacherLines = fs.readFileSync(teacherFile, 'utf8').split('\n');
const cssLines = teacherLines.slice(588, 753).join('\n');
if (!content.includes('.metrics-row {')) {
    content = content.replace('</style>', '\n' + cssLines + '\n</style>');
}

// 5. Fix tab-dashboard header and wrappers
// Find the exact old HTML wrapper
const oldHeader = `<!-- Bảng nội dung Tổng quan học tập -->
                                                                        <div
                                                                            style="flex:1; min-height:0; overflow:hidden; display:flex; flex-direction:column;">

                                                                            <!-- Nửa dưới: Nền trắng tích hợp Lời chào & Lưới 4 Thẻ -->
                                                                            <div
                                                                                style="background:linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); padding:2rem; display:flex; flex-direction:column; gap:1.5rem; flex:1; min-height:0; overflow-y:auto;">

                                                                                <!-- Hàng Tiêu đề Lời chào -->
                                                                                <div
                                                                                    style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
                                                                                    <div>
                                                                                        <h2
                                                                                            style="font-size:1.65rem; font-weight:800; color:var(--text-main); margin:0.25rem 0 0 0;">
                                                                                            Chào mừng trở lại, <%= user
                                                                                                !=null ?
                                                                                                user.getDisplayName()
                                                                                                : "Học viên HIPZI" %>!
                                                                                        </h2>
                                                                                    </div>
                                                                                    
                                                                                </div>`;

const newHeader = `<div class="tab-pane-header">
                                                                            <div class="tab-pane-header-left">
                                                                                <h1>Tổng quan học tập</h1>
                                                                                <p>Theo dõi tiến độ, lớp học, khóa học và lịch học của bạn trên HIPZI.</p>
                                                                            </div>
                                                                            <div class="tab-pane-header-right">
                                                                                <div class="date-badge">
                                                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                                                                    <span><%= currentDateDisplay %></span>
                                                                                </div>
                                                                            </div>
                                                                        </div>`;

content = content.replace(oldHeader, newHeader);

// Fix the closing tags at the end of tab-dashboard
const oldFooter = `                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </section>`;

const newFooter = `                                                                                </div>
                                                                    </section>`;

content = content.replace(oldFooter, newFooter);

fs.writeFileSync(studentFile, content, 'utf8');
console.log('Successfully recovered and updated student-profile.jsp');
