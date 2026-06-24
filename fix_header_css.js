const fs = require('fs');

const teacherFile = 'e:/PRJ/HipZi/web/WEB-INF/views/teacher-profile.jsp';
const studentFile = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';

const teacherLines = fs.readFileSync(teacherFile, 'utf8').split('\n');
let studentContent = fs.readFileSync(studentFile, 'utf8');

// Copy lines 542 to 588 (0-indexed 541 to 587)
const cssLines = teacherLines.slice(541, 588).join('\n');

// Inject before </style>
if (!studentContent.includes('.tab-pane-header {')) {
    studentContent = studentContent.replace('</style>', '\n' + cssLines + '\n</style>');
    fs.writeFileSync(studentFile, studentContent, 'utf8');
    console.log('Successfully injected tab-pane-header CSS.');
} else {
    console.log('tab-pane-header CSS already exists.');
}
