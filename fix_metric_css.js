const fs = require('fs');

const teacherFile = 'e:/PRJ/HipZi/web/WEB-INF/views/teacher-profile.jsp';
const studentFile = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';

const teacherLines = fs.readFileSync(teacherFile, 'utf8').split('\n');
let studentContent = fs.readFileSync(studentFile, 'utf8');

// The CSS for metrics cards is from line 589 to 752 (0-indexed 588 to 751) in teacher-profile.jsp
// Let's copy lines 588 to 752 just to be safe.
const cssLines = teacherLines.slice(588, 753).join('\n');

// Inject into student-profile.jsp before the first </style> (which is around line 2093)
if (!studentContent.includes('.metrics-row {')) {
    studentContent = studentContent.replace('</style>', '\n' + cssLines + '\n</style>');
    fs.writeFileSync(studentFile, studentContent, 'utf8');
    console.log('Successfully injected metric-card CSS.');
} else {
    console.log('metric-card CSS already exists.');
}
