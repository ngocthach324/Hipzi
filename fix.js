const fs = require('fs');
const file = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let content = fs.readFileSync(file, 'utf8');

const regex = /box-shadow:\s*0 0 0 3px var\(--primary-light\);\s*background:\s*#ffffff;\s*\/\* ===== HEADER CỦA TAB ===== \*\//;

if (regex.test(content)) {
    content = content.replace(regex, 'box-shadow: 0 0 0 3px var(--primary-light);\n            background: #ffffff;\n        }\n\n        /* ===== HEADER CỦA TAB ===== */');
    fs.writeFileSync(file, content, 'utf8');
    console.log('Fixed brace successfully.');
} else {
    console.log('Regex did not match.');
}
