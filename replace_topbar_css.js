const fs = require('fs');
const file = 'e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp';
let content = fs.readFileSync(file, 'utf8');

const newCSS = `        body.student-profile-page .dashboard-top-bar {
            height: 72px;
            background: #ffffff;
            border-bottom: 1px solid var(--border-light);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2rem;
            position: sticky;
            top: 0;
            z-index: 90;
        }

        body.student-profile-page .top-bar-search-wrapper {
            display: flex;
            align-items: center;
            background: var(--bg-surface);
            border-radius: 999px;
            padding: 0.6rem 1.25rem;
            width: 380px;
            gap: 0.75rem;
            border: 1px solid var(--border-light);
            transition: all 0.2s ease;
        }

        body.student-profile-page .top-bar-search-wrapper:focus-within {
            background: #ffffff;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
        }

        body.student-profile-page .top-bar-search-wrapper svg {
            color: var(--text-muted);
            width: 18px;
            height: 18px;
        }

        body.student-profile-page .top-bar-search-wrapper input {
            border: none;
            background: transparent;
            outline: none;
            font-size: 0.85rem;
            color: var(--text-main);
            width: 100%;
            font-family: inherit;
        }

        body.student-profile-page .top-bar-right {
            display: flex;
            align-items: center;
            gap: 1.25rem;
            height: 42px;
        }

        body.student-profile-page .nav-bell-trigger {
            background: none;
            border: none;
            cursor: pointer;
            width: 42px;
            height: 42px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-muted);
            position: relative;
            transition: all 0.2s ease;
        }

        body.student-profile-page .nav-bell-trigger:hover {
            background: var(--bg-body);
            color: var(--primary);
        }

        body.student-profile-page .top-bar-user-card {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding-left: 0.75rem;
            border-left: 1px solid var(--border-dark);
            cursor: pointer;
            height: 42px;
            flex: 0 0 auto;
        }

        body.student-profile-page .top-bar-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--border-dark);
        }

        body.student-profile-page .top-bar-avatar-placeholder {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--primary-light);
            color: var(--primary);
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid var(--border-dark);
        }

        body.student-profile-page .top-bar-user-info {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        body.student-profile-page .top-bar-user-name {
            font-size: 0.82rem;
            font-weight: 800;
            color: var(--text-main);
            white-space: nowrap;
        }

        body.student-profile-page .top-bar-user-email {
            font-size: 0.7rem;
            font-weight: 600;
            color: var(--text-muted);
            white-space: nowrap;
        }
`;

const lines = content.split('\\n');
const startIdx = lines.findIndex(l => l.includes('body.student-profile-page .dashboard-top-bar {'));
const endIdx = lines.findIndex((l, idx) => idx > startIdx && l.includes('body.student-profile-page .top-bar-user-email {')) + 6;

if (startIdx !== -1 && endIdx !== -1) {
    const before = lines.slice(0, startIdx).join('\\n');
    const after = lines.slice(endIdx).join('\\n');
    content = before + '\\n' + newCSS + '\\n' + after;
    fs.writeFileSync(file, content);
    console.log('Replaced top bar CSS!');
} else {
    console.log('Could not find CSS block!');
}
