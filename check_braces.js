const fs = require('fs');
const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
const lines = fs.readFileSync(filePath, 'utf8').split('\n');

let braceCount = 0;
let errors = [];

for (let i = 35; i <= 2095; i++) { // First style block
    const line = lines[i] || '';
    // Count { and } ignoring comments is hard, but let's do a simple count
    for (let char of line) {
        if (char === '{') braceCount++;
        if (char === '}') braceCount--;
    }
    if (braceCount < 0) {
        errors.push(`Extra closing brace at line ${i}`);
        braceCount = 0; // reset
    }
}

console.log('Final brace count in first block:', braceCount);
if (errors.length > 0) {
    console.log('Errors:', errors);
} else {
    console.log('No extra closing braces found.');
}
