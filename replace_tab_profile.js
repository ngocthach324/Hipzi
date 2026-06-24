const fs = require('fs');

const teacherFile = 'e:/PRJ/HipZi/web/WEB-INF/views/teacher-profile.jsp';
const studentFile = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';

const teacherContent = fs.readFileSync(teacherFile, 'utf8');
let studentContent = fs.readFileSync(studentFile, 'utf8');

// Extract the section tab-profile from teacher
const teacherTabStart = '<section id="tab-profile" class="tab-pane <%= "tab-profile".equals(initialTeacherTab) ? "active-pane" : "" %>">';
const teacherTabEnd = '</section>';
const startIndex = teacherContent.indexOf(teacherTabStart);
const endIndex = teacherContent.indexOf(teacherTabEnd, startIndex) + teacherTabEnd.length;

if (startIndex === -1 || endIndex === -1) {
    console.error("Could not find tab-profile in teacher-profile.jsp");
    process.exit(1);
}

let newLayout = teacherContent.substring(startIndex, endIndex);

// Adapt it for the student:
// 1. Change initialTeacherTab to activeTab
newLayout = newLayout.replace(/initialTeacherTab/g, 'activeTab');

// 2. Change teacherAvatarUploadForm to avatarUploadForm (or leave it as is, but avatarUploadForm is standard for student)
newLayout = newLayout.replace(/teacherAvatarUploadForm/g, 'avatarUploadForm');
newLayout = newLayout.replace(/teacherAvatarFile/g, 'avatarFileInput');

// 3. Change "Giảng viên HIPZI" to "Học viên HIPZI"
newLayout = newLayout.replace(/"Giảng viên HIPZI"/g, '"Học viên HIPZI"');

// 4. Change the "Vai trò" block to "Mã học viên" block
const roleBlock = `<div class="account-meta-pill">
                                <span class="account-meta-label">Vai trò</span>
                                <span class="account-meta-value">
                                    <span class="role-tag teacher">Giảng viên</span>
                                </span>
                            </div>`;

const studentCodeBlock = `<div class="account-meta-pill">
                                <span class="account-meta-label">Mã học viên</span>
                                <span class="account-meta-value">
                                    <span class="role-tag student" onclick="event.stopPropagation(); copyStudentCode(this.textContent.trim());" title="Nhấn để sao chép mã học viên" style="cursor:pointer;">
                                        <%= (user != null && user.getStudentCode() != null) ? user.getStudentCode() : "HZ-PENDING" %>
                                    </span>
                                </span>
                            </div>`;

if(newLayout.includes(roleBlock)) {
    newLayout = newLayout.replace(roleBlock, studentCodeBlock);
} else {
    console.error("Could not find role block to replace with student code block.");
    // try a more generic replace
    newLayout = newLayout.replace(/<div class="account-meta-pill">\s*<span class="account-meta-label">Vai trò<\/span>[\s\S]*?<\/div>/, studentCodeBlock);
}

// 5. Replace the entire tab-profile in student-profile.jsp
const studentTabStartRegex = /<section id="tab-profile"[^>]*>/;
const match = studentContent.match(studentTabStartRegex);
if (!match) {
    console.error("Could not find tab-profile in student-profile.jsp");
    process.exit(1);
}

const studentStartIndex = match.index;
// Find the next </section> after the start
let studentEndIndex = studentContent.indexOf('</section>', studentStartIndex);
if(studentEndIndex !== -1) {
    studentEndIndex += '</section>'.length;
} else {
    console.error("Could not find closing </section> for tab-profile in student.");
    process.exit(1);
}

// Ensure we are replacing the exact chunk
studentContent = studentContent.substring(0, studentStartIndex) + newLayout + studentContent.substring(studentEndIndex);

// Add the missing CSS class definition for `account-summary-panel` etc. if not present in student
// Teacher profile has these CSS inside the file? Let's check.
// Wait, the user already said in step 3: "tốt lắm tiếp theo thì hãy thiết kế tab profile của student ( ảnh 2 ) cho giống với tba profile của teacher ( ảnh 1 ) nhé"
// And in step 7: "ồ có vẻ là chưa áp dụng css và thỉ phải ..."
// So I MUST ensure the CSS is injected. I'll just write the layout first, then I'll check CSS.

fs.writeFileSync(studentFile, studentContent, 'utf8');
console.log("Successfully replaced tab-profile in student-profile.jsp");
