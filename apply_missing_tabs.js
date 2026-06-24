const fs = require('fs');

const teacherPath = 'e:\\PRJ\\HipZi\\web\\WEB-INF\\views\\teacher-profile.jsp';
const studentPath = 'e:\\PRJ\\HipZi\\web\\WEB-INF\\views\\student-profile.jsp';

let teacherContent = fs.readFileSync(teacherPath, 'utf8');
let studentContent = fs.readFileSync(studentPath, 'utf8');

// 1. EXTRACT TAB-DASHBOARD FROM TEACHER
const dashboardRegex = /<section id="tab-dashboard"[^>]*>([\s\S]*?)<\/section>/;
const dashboardMatch = teacherContent.match(dashboardRegex);
if (dashboardMatch) {
    let dashboardHtml = `<section id="tab-dashboard" class="tab-pane <%= "tab-dashboard".equals(initialTab) ? "active-pane" : "" %>">\n${dashboardMatch[1]}</section>\n`;
    
    // Convert teacher content to student content
    dashboardHtml = dashboardHtml.replace('Tổng quan hệ thống', 'Tổng quan học tập');
    dashboardHtml = dashboardHtml.replace('Theo dõi nhanh hoạt động giảng dạy, khóa học, tài liệu và lịch dạy của bạn trên HIPZI.', 'Theo dõi nhanh tiến độ học tập, tài liệu đã lưu và lịch học của bạn trên HIPZI.');
    
    // Metric 1: Lớp đang dạy -> Tài liệu đã lưu
    dashboardHtml = dashboardHtml.replace('Lớp đang dạy', 'Tài liệu đã lưu');
    dashboardHtml = dashboardHtml.replace('<%= teacherClassrooms != null ? teacherClassrooms.size() : 0 %>', '0');
    dashboardHtml = dashboardHtml.replace('Lớp hoạt động', 'Tài liệu');
    dashboardHtml = dashboardHtml.replace('onclick="switchTab(\'tab-class-registration\')"', 'onclick="switchTab(\'tab-materials\')"');
    
    // Metric 2: Khóa học của tôi -> Lớp đang học
    dashboardHtml = dashboardHtml.replace('Khóa học của tôi', 'Lớp đang học');
    dashboardHtml = dashboardHtml.replace('<%= teacherCourses != null ? teacherCourses.size() : 0 %>', '0');
    dashboardHtml = dashboardHtml.replace('Đang phát hành', 'Đang tham gia');
    dashboardHtml = dashboardHtml.replace('onclick="switchTab(\'tab-course-registration\')"', 'onclick="switchTab(\'tab-history\')"');
    
    // Metric 3: Số tài liệu -> Bài tập hoàn thành
    dashboardHtml = dashboardHtml.replace('Số tài liệu', 'Bài tập hoàn thành');
    dashboardHtml = dashboardHtml.replace('<%= teacherMaterialCount %>', '0');
    dashboardHtml = dashboardHtml.replace('Tài liệu đã đăng', 'Bài tập');
    dashboardHtml = dashboardHtml.replace('onclick="switchTab(\'tab-upload-material\')"', 'onclick="switchTab(\'tab-history\')"');
    
    // Metric 4: Đặt lịch dạy -> Xem lịch học
    dashboardHtml = dashboardHtml.replace('Đặt lịch dạy', 'Xem lịch học');
    dashboardHtml = dashboardHtml.replace('openScheduleModal()', 'switchTab(\'tab-history\')');
    
    // Charts
    dashboardHtml = dashboardHtml.replace(/Thời lượng giảng dạy/g, 'Tiến độ học tập');
    dashboardHtml = dashboardHtml.replace(/Đã dạy/g, 'Đã học');
    dashboardHtml = dashboardHtml.replace(/Giờ đã dạy/g, 'Giờ đã học');
    dashboardHtml = dashboardHtml.replace(/Đánh giá học sinh/g, 'Phân bổ thời gian học');
    dashboardHtml = dashboardHtml.replace('Hài lòng', 'Bài thi');
    dashboardHtml = dashboardHtml.replace('Tạm được', 'Thực hành');
    dashboardHtml = dashboardHtml.replace('Cần cải thiện', 'Lý thuyết');
    
    // Insert before tab-materials
    studentContent = studentContent.replace('<section id="tab-materials"', dashboardHtml + '\n            <section id="tab-materials"');
}

// 2. FIX SIDEBAR TEXT
studentContent = studentContent.replace(/Tổng quan hệ thống/g, 'Tổng quan học tập');
studentContent = studentContent.replace(/Hỗ trợ giảng dạy/g, 'Hỗ trợ học tập');

// 3. FIX JS: normalizeTeacherTabId -> normalizeStudentTabId
studentContent = studentContent.replace(/function normalizeTeacherTabId\(tabValue\) {[\s\S]*?return tabValue.startsWith\('tab-'\) \? tabValue : 'tab-' \+ tabValue;[\s\S]*?}/, 
`function normalizeStudentTabId(tabValue) {
            if (!tabValue) {
                return '';
            }
            return tabValue.startsWith('tab-') ? tabValue : 'tab-' + tabValue;
        }`);
studentContent = studentContent.replace(/normalizeTeacherTabId/g, 'normalizeStudentTabId');
studentContent = studentContent.replace(/updateTeacherTabUrl/g, 'updateStudentTabUrl');

// 4. FIX TAB-PROFILE
// Replace Giảng viên -> Học viên
const profileStart = studentContent.indexOf('<section id="tab-profile"');
const profileEnd = studentContent.indexOf('</section>', profileStart) + 10;
let profileHtml = studentContent.substring(profileStart, profileEnd);
profileHtml = profileHtml.replace('Giảng viên HIPZI', 'Học viên HIPZI');
profileHtml = profileHtml.replace('Giảng viên</span>', 'Học viên</span>');
profileHtml = profileHtml.replace('role-tag teacher', 'role-tag student');
profileHtml = profileHtml.replace(/teacherAvatarUploadForm/g, 'studentAvatarUploadForm');
profileHtml = profileHtml.replace(/teacherAvatarFile/g, 'studentAvatarFile');
studentContent = studentContent.substring(0, profileStart) + profileHtml + studentContent.substring(profileEnd);

// 5. FIX TAB-SUPPORT
const supportStart = studentContent.indexOf('<section id="tab-support"');
const supportEnd = studentContent.indexOf('</section>', supportStart) + 10;
let supportHtml = studentContent.substring(supportStart, supportEnd);
supportHtml = supportHtml.replace('Hỗ trợ giảng dạy', 'Hỗ trợ học tập');
supportHtml = supportHtml.replace('Giải đáp thắc mắc và gửi yêu cầu trợ giúp kỹ thuật từ ban quản trị HIPZI.', 'Gửi yêu cầu hỗ trợ học tập và kỹ thuật tới ban quản trị HIPZI.');
supportHtml = supportHtml.replace(/teacher-profile\?tab=support/g, 'student-profile?tab=support');
studentContent = studentContent.substring(0, supportStart) + supportHtml + studentContent.substring(supportEnd);

// Write back
fs.writeFileSync(studentPath, studentContent);
console.log("Successfully injected tab-dashboard and fixed all tabs in student-profile.jsp");
