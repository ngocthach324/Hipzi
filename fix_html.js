const fs = require('fs');
const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let content = fs.readFileSync(filePath, 'utf8');

// The broken part ends with:
// d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
//                                                                                                     <circle cx="12"
//                                                                                     </div>

const brokenStart = `d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                                                                                                    <circle cx="12"
                                                                                    </div>`;

const fixedReplacement = `d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
                                                                                                    <circle cx="12" cy="10" r="3" />
                                                                                                </svg>
                                                                                                <span>Thành viên tích cực</span>
                                                                                            </div>
                                                                                        </div>
                                                                                    </div>

                                                                                    <!-- Nhóm Phải: Vai trò chính đưa lên ngang hàng -->
                                                                                    <div style="display:flex; flex-direction:column; align-items:flex-end; text-align:right;">
                                                                                        <span style="font-size:0.75rem; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px; display:block; margin-bottom:0.35rem;">Mã học viên</span>
                                                                                        <div class="highlight-user-roles" style="margin:0;">
                                                                                            <span class="role-tag student" onclick="event.stopPropagation(); copyStudentCode(this.textContent.trim());" title="Nhấn để sao chép mã học viên" style="font-size:0.85rem; padding:0.4rem 1.15rem; border-radius:2rem; cursor:pointer;">
                                                                                                <%= (user != null && user.getStudentCode() != null) ? user.getStudentCode() : "HZ-PENDING" %>
                                                                                            </span>
                                                                                        </div>
                                                                                    </div>`;

if (content.includes(brokenStart)) {
    content = content.replace(brokenStart, fixedReplacement);
    fs.writeFileSync(filePath, content, 'utf8');
    console.log("Fixed the HTML and inserted Mã học viên successfully.");
} else {
    // maybe different whitespace, let's use indexOf and substring
    const circleMatch = 'd="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />\r\n                                                                                                    <circle cx="12"\r\n                                                                                    </div>';
    const circleMatchN = 'd="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />\n                                                                                                    <circle cx="12"\n                                                                                    </div>';
    
    if (content.includes(circleMatch)) {
        content = content.replace(circleMatch, fixedReplacement);
        fs.writeFileSync(filePath, content, 'utf8');
        console.log("Fixed the HTML and inserted Mã học viên successfully (CRLF).");
    } else if (content.includes(circleMatchN)) {
        content = content.replace(circleMatchN, fixedReplacement);
        fs.writeFileSync(filePath, content, 'utf8');
        console.log("Fixed the HTML and inserted Mã học viên successfully (LF).");
    } else {
        console.log("Could not find the broken start string.");
    }
}
