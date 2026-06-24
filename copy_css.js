const fs = require('fs');

const teacherFile = 'e:/PRJ/HipZi/web/WEB-INF/views/teacher-profile.jsp';
const studentFile = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';

const teacherLines = fs.readFileSync(teacherFile, 'utf8').split('\n');
let studentContent = fs.readFileSync(studentFile, 'utf8');

// Copy lines 1168 to 1750 (0-indexed 1167 to 1749)
const cssLines = teacherLines.slice(1167, 1750).join('\n');

if (!studentContent.includes('.premium-card {')) {
    studentContent = studentContent.replace('</style>', '\n' + cssLines + '\n</style>');
    fs.writeFileSync(studentFile, studentContent, 'utf8');
    console.log('Successfully injected premium CSS.');
} else {
    // maybe .premium-card { exists but it's only the body.student-profile-page one
    // Let's replace the one we find
    const regex = /body\.student-profile-page \.premium-card \{/;
    if(regex.test(studentContent)) {
         studentContent = studentContent.replace('</style>', '\n' + cssLines + '\n</style>');
         fs.writeFileSync(studentFile, studentContent, 'utf8');
         console.log('Successfully injected premium CSS (despite body match).');
    } else {
         console.log('Premium CSS already exists in student-profile.jsp.');
    }
}
