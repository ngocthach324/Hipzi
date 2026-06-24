const fs = require('fs');

const filePath = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let content = fs.readFileSync(filePath, 'utf8');

// Replace boolean is2fa=(user with boolean is2faSec=(user at the specific occurrence
// Let's use a regex that matches the exact block near line 3262
const regex = /<% boolean is2fa=\(user\s*!=null &&\s*user\.isTwoFactorEnabled\(\)\);\s*%>\s*<div id="otp-toggle-btn"/;

if (regex.test(content)) {
    content = content.replace(
        /<% boolean is2fa=\(user\s*!=null &&\s*user\.isTwoFactorEnabled\(\)\);\s*%>\s*<div id="otp-toggle-btn"/,
        `<% boolean is2faSec=(user\n!=null &&\nuser.isTwoFactorEnabled());\n%>\n<div id="otp-toggle-btn"`
    );
    // There are 2 more usages inside that specific div
    // But since `is2fa` is also used in `tab-profile`, we must only replace it inside `tab-security`!
    // So let's find the specific string index.
    
    // Instead of regex, let's just do a string replace for the exact lines in the file.
    let lines = content.split('\n');
    for (let i = 3250; i < 3280; i++) {
        if (lines[i].includes('<% boolean is2fa=(user')) {
            lines[i] = lines[i].replace('<% boolean is2fa=(user', '<% boolean is2faSec=(user');
        }
        if (lines[i].includes('background:<%= is2fa ?')) {
            lines[i] = lines[i].replace('background:<%= is2fa ?', 'background:<%= is2faSec ?');
        }
        if (lines[i].includes('translateX(<%= is2fa ?')) {
            lines[i] = lines[i].replace('translateX(<%= is2fa ?', 'translateX(<%= is2faSec ?');
        }
    }
    fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
    console.log("Replaced successfully.");
} else {
    // If regex failed, let's just do the line approach anyway
    let lines = content.split('\n');
    for (let i = 3250; i < 3280; i++) {
        if (lines[i] && lines[i].includes('<% boolean is2fa=(user')) {
            lines[i] = lines[i].replace('<% boolean is2fa=(user', '<% boolean is2faSec=(user');
        }
        if (lines[i] && lines[i].includes('background:<%= is2fa ?')) {
            lines[i] = lines[i].replace('background:<%= is2fa ?', 'background:<%= is2faSec ?');
        }
        if (lines[i] && lines[i].includes('translateX(<%= is2fa ?')) {
            lines[i] = lines[i].replace('translateX(<%= is2fa ?', 'translateX(<%= is2faSec ?');
        }
    }
    fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
    console.log("Replaced using lines approach.");
}
