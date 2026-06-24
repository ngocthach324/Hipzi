const fs = require('fs');
const content = fs.readFileSync('e:\\PRJ\\HipZi\\web\\WEB-INF\\views\\student-profile.jsp', 'utf8');

// Check 1: Sections exist
const sections = ['tab-dashboard', 'tab-materials', 'tab-history', 'tab-profile', 'tab-support'];
sections.forEach(s => {
    const found = content.includes('id="' + s + '"');
    console.log('Section ' + s + ': ' + (found ? 'OK' : 'MISSING'));
});

console.log('---');

// Check 2: Teacher text leaks
const teacherLeaks = ['Tổng quan hệ thống', 'Hỗ trợ giảng dạy', 'Giảng viên HIPZI', 'teacher-profile?tab=support', 'role-tag teacher'];
teacherLeaks.forEach(t => {
    const found = content.includes(t);
    console.log('Teacher leak "' + t + '": ' + (found ? '❌ LEAK PRESENT' : '✅ clean'));
});

console.log('---');

// Check 3: Student content present
const studentTexts = ['Tổng quan học tập', 'Hỗ trợ học tập', 'Học viên HIPZI', 'student-profile?tab=support', 'Tài liệu đã lưu', 'Lớp đang học', 'Bài tập hoàn thành'];
studentTexts.forEach(t => {
    const found = content.includes(t);
    console.log('Student text "' + t + '": ' + (found ? '✅ OK' : '❌ MISSING'));
});

console.log('---');

// Check 4: JS function
console.log('normalizeStudentTabId func: ' + (content.includes('normalizeStudentTabId') ? '✅ OK' : '❌ MISSING'));
console.log('normalizeTeacherTabId leak: ' + (content.includes('normalizeTeacherTabId') ? '❌ LEAK PRESENT' : '✅ clean'));
