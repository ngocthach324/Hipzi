const fs = require('fs');
const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let lines = fs.readFileSync(filePath, 'utf8').split('\n');

// Find the line that has /* ===== HEADER CỦA TAB ===== */
let targetLineIndex = -1;
for (let i = 2030; i < 2060; i++) {
    if (lines[i] && lines[i].includes('/* ===== HEADER CỦA TAB ===== */')) {
        targetLineIndex = i;
        break;
    }
}

if (targetLineIndex !== -1) {
    // Insert `        }` before this line
    lines.splice(targetLineIndex, 0, '        }');
    fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
    console.log('Successfully fixed missing closing brace.');
} else {
    console.log('Could not find header comment.');
}
