const fs = require('fs');
const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let content = fs.readFileSync(filePath, 'utf8');

// Replace the Role block with Student Code block
// Using regex to handle \r\n vs \n
const roleRegex = /<div class="account-meta-pill">\s*<span class="account-meta-label">Vai trò<\/span>\s*<span class="account-meta-value">\s*<span class="role-tag student">Học viên<\/span>\s*<\/span>\s*<\/div>/g;

const newStudentCodeBlock = `<div class="account-meta-pill">
                                                                                        <span class="account-meta-label">Mã học viên</span>
                                                                                        <span class="account-meta-value">
                                                                                            <span class="role-tag student" onclick="event.stopPropagation(); copyStudentCode(this.textContent.trim());" title="Nhấn để sao chép mã học viên" style="cursor: pointer;"><%= (user != null && user.getStudentCode() != null) ? user.getStudentCode() : "HZ-PENDING" %></span>
                                                                                        </span>
                                                                                    </div>`;

content = content.replace(roleRegex, newStudentCodeBlock);

// Find and remove the old student code badge in the dashboard top section
const badgeStartStr = 'style="display:flex; align-items:center; gap:0.75rem;"';
const badgeStartIndex = content.indexOf(badgeStartStr);

if (badgeStartIndex !== -1) {
    // Find the enclosing <div before this
    const divStart = content.lastIndexOf('<div', badgeStartIndex);
    const badgeEndStr = '</div>\r\n                                                                                    </div>';
    const badgeEndIndex = content.indexOf('</div>\n                                                                                    </div>', badgeStartIndex) !== -1 ? content.indexOf('</div>\n                                                                                    </div>', badgeStartIndex) : content.indexOf(badgeEndStr, badgeStartIndex);

    if (divStart !== -1 && badgeEndIndex !== -1) {
        // Find the actual end of the block (the second </div>)
        const finalEnd = badgeEndIndex + badgeEndStr.length;
        content = content.substring(0, divStart) + content.substring(finalEnd);
        fs.writeFileSync(filePath, content);
        console.log("Successfully replaced the role block and removed the old student code badge.");
    } else {
        console.log("Found badge start but not end or div start.");
    }
} else {
    console.log("Could not find the old student code badge start.");
}
