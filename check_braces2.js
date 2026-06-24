const fs = require('fs');
const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
const lines = fs.readFileSync(filePath, 'utf8').split('\n');

let stack = [];

for (let i = 35; i <= 2095; i++) {
    const line = lines[i] || '';
    
    // Simple parsing, ignoring comments and strings for now
    // Actually, let's just strip block comments first for accurate counting
    
    for (let j = 0; j < line.length; j++) {
        if (line[j] === '{') {
            stack.push({lineNum: i, text: line});
        } else if (line[j] === '}') {
            stack.pop();
        }
    }
}

console.log('Unclosed braces at:');
for (let item of stack) {
    console.log(`Line ${item.lineNum}: ${item.text.trim()}`);
}
