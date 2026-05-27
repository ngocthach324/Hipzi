---
trigger: always_on
---

# .agents/rules/ui-conventions.md

# HIPZI UI Conventions

## 1. Purpose

This file defines UI conventions that the AI coding agent must follow when creating or modifying JSP, CSS, and JavaScript for HIPZI.

HIPZI should have a bright, friendly, soft, modern, AI-assisted, and trustworthy interface.

---

## 2. Design Personality

HIPZI should feel like:

- A friendly learning companion.
- A smart AI study assistant.
- A clean education platform.
- A safe learning environment.
- A supportive mentor.

HIPZI should not feel like:

- A cold corporate dashboard.
- A childish game-only app.
- A cluttered admin panel.
- A generic SaaS template.
- A dark or stressful learning platform.

---

## 3. Visual Direction

Use:

- Light backgrounds.
- Soft pastel colors.
- Rounded cards.
- Friendly icons.
- Clear spacing.
- Soft shadows.
- Clear status badges.
- Readable typography.
- Calm and encouraging copywriting.

Avoid:

- Harsh colors.
- Overly dark layouts.
- Too many visual effects.
- Dense text blocks.
- Confusing status labels.
- Unclear call-to-action buttons.

---

## 4. Recommended Color Direction

Color usage:

- Primary: Soft Teal / Mint Green.
- Secondary: Warm Yellow / Soft Orange.
- Accent: Soft Lavender / Purple for AI features.
- Background: Off-white or very light mint.
- Surface: White.
- Text: Dark navy or charcoal.
- Success: Green.
- Warning: Amber.
- Error: Soft red.
- Info: Soft blue.

AI-related UI should commonly use soft purple or accent styling.

---

## 5. Typography Rules

Recommended fonts:

- Primary: `Be Vietnam Pro`.
- Modern dashboard fallback: `Plus Jakarta Sans`.
- Clean UI fallback: `Inter`.
- System fallback: `Arial`, `sans-serif`.

Recommended font stack:

```css
font-family: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;
```

Rules:

- Use clear heading hierarchy.
- Keep body text readable.
- Avoid decorative fonts.
- Use bold only for important emphasis.
- Avoid long paragraphs inside cards.
- Use `Be Vietnam Pro` for Vietnamese-first MVP UI readability.
- Ensure Vietnamese diacritics render clearly in headings, body text, badges, forms, validation messages, and tables.
- Keep Student pages friendly and comfortable to read.
- Keep Teacher, Staff, and Admin pages professional and clean.
- Use a shared CSS font token such as `--font-sans` instead of repeating font stacks.

---

## 6. Card Rules

Use cards for:

- Materials.
- Subjects.
- Quizzes.
- Flashcard sets.
- AI drafts.
- Teacher profiles.
- Staff review items.
- Student progress.
- Admin metrics.

Card style:

- Rounded corners.
- Clear title.
- Short description.
- Metadata badges.
- Primary action.
- Soft border or shadow.
- Comfortable padding.

---

## 7. Status Badge Rules

Use consistent status badges.

Material statuses:

- Draft: gray.
- Pending Review: amber.
- Approved: green.
- Rejected: red.
- Needs Revision: orange.
- Hidden: muted gray.
- Archived: outlined gray.

AI statuses:

- AI Draft: soft purple.
- Teacher Reviewed: blue or green.
- Staff Review Required: amber.
- Approved: green.
- Rejected: red.
- Discarded: gray.

Teacher application statuses:

- Draft: gray.
- Pending Review: amber.
- Approved: green.
- Rejected: red.
- Suspended: red warning.

---

## 8. Role-Based UI Tone

### Student UI

Student UI should be:

- Friendly.
- Motivating.
- Visual.
- Simple.
- Slightly playful.

Use cards, progress indicators, and encouraging copy.

---

### Teacher UI

Teacher UI should be:

- Productive.
- Organized.
- Creative.
- AI-assisted.
- Clear about review status.

---

### Staff UI

Staff UI should be:

- Clear.
- Efficient.
- Operational.
- Low distraction.
- Review-focused.

Use queues, tables, filters, and clear actions.

---

### Admin UI

Admin UI should be:

- Professional.
- Structured.
- Data-oriented.
- Governance-focused.

Use tables, filters, audit log views, and clear role badges.

---

## 9. Button Rules

Use button types consistently:

- Primary button: main action.
- Secondary button: alternative action.
- Ghost button: low-priority action.
- Danger button: destructive action.
- Disabled button: unavailable action.

Examples:

- Start Learning.
- Upload Material.
- Submit for Review.
- Generate Quiz.
- Mark as Teacher Reviewed.
- Approve.
- Reject.
- Assign Role.

Destructive actions should be visually distinct.

---

## 10. Form Rules

Forms should have:

- Clear labels.
- Required field indicators.
- Helper text where needed.
- Field-level error messages.
- Primary and secondary actions.
- Clear success and failure messages.

Important forms:

- Register.
- Login.
- Teacher application.
- Material creation.
- AI generation.
- Staff rejection reason.
- Admin role assignment.

---

## 11. Empty State Rules

Empty states should be helpful.

Examples:

Student no materials:

    No materials found.
    Try a different keyword or choose another subject.

Teacher no materials:

    You have not created any materials yet.
    Upload your first learning material and submit it for Staff review.

Staff queue empty:

    No items need review right now.
    New teacher applications and material submissions will appear here.

AI drafts empty:

    No AI drafts yet.
    Generate a quiz or flashcards from one of your learning materials.

---

## 12. Error State Rules

Use clear and safe error messages.

Do not expose technical details.

Examples:

Permission error:

    You do not have permission to access this page.

Content unavailable:

    This content is currently unavailable.

AI error:

    AI generation failed. Your original material is safe. Please try again.

System error:

    Something went wrong. Please try again later.

---

## 13. Loading State Rules

Use loading states for:

- Login.
- Search.
- Material loading.
- AI generation.
- File upload.
- Quiz submission.
- Staff moderation action.
- Admin role assignment.

AI loading message:

    HIPZI AI is preparing your draft. This may take a moment.

Disable duplicate action buttons while processing.

---

## 14. JSP UI Rules

JSP should use shared layout components.

Recommended shared files:

- `header.jsp`
- `footer.jsp`
- `sidebar.jsp`
- `main-layout.jsp`
- `alert.jsp`
- `status-badge.jsp`
- `pagination.jsp`

Do not duplicate navigation and common UI blocks across many JSP files.

---

## 15. CSS Rules

Recommended CSS structure:

    assets/css/
    ├── tokens.css
    ├── main.css
    ├── layout.css
    ├── components.css
    ├── forms.css
    ├── dashboard.css
    ├── material.css
    ├── quiz.css
    ├── staff.css
    └── admin.css

Rules:

- Use reusable classes.
- Avoid excessive inline styles.
- Use design tokens.
- Define `--font-sans: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;` in `tokens.css`.
- Keep spacing consistent.
- Keep button styles consistent.
- Keep badge styles consistent.

---

## 16. JavaScript UI Rules

JavaScript may enhance UI.

Allowed uses:

- Form helper behavior.
- Confirmation dialogs.
- Loading state.
- Flashcard flip.
- Quiz option selection.
- File preview.
- Search interaction.

JavaScript must not be the only protection for:

- Authorization.
- Role checks.
- Student visibility.
- Quiz scoring integrity.
- AI publication rules.

---

## 17. Accessibility Rules

UI should support:

- Semantic HTML.
- Proper labels.
- Keyboard-accessible buttons.
- Clear focus states.
- Readable contrast.
- Error messages connected to fields.
- Non-color-only status communication.
- Alt text for meaningful images.

---

## Vietnamese UI Language Rule

HIPZI's user-facing MVP interface must be written in Vietnamese.

The AI coding agent must write Vietnamese copy for:

- JSP page titles
- Navigation labels
- Button text
- Form labels
- Helper text
- Validation messages
- Empty states
- Error states
- Loading states
- Status badge labels
- Dashboard descriptions
- Staff/Admin action messages
- Permission and unavailable-content messages

Vietnamese UI copy should be friendly, clear, encouraging, easy to understand, and professional where needed.

Code identifiers, class names, method names, database fields, routes, CSS class names, and technical documentation should remain in English.

Font family names should remain as official font names, such as `Be Vietnam Pro`, `Plus Jakarta Sans`, and `Inter`.

Examples:

- `MaterialCreateServlet` is correct.
- `MaterialService` is correct.
- `material.status = approved` is correct.
- Button text should be `Gửi duyệt`, not `Submit for Review`.
- Error message should be `Bạn không có quyền truy cập trang này`, not `You do not have permission to access this page`.
