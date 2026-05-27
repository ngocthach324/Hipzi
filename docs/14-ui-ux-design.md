# HIPZI UI/UX Design

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | UI/UX Design Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md, 07-system-architecture.md, 08-database-design.md, 09-api-design.md, 10-non-functional-requirements.md, 11-tech-plan.md, 12-testing-strategy.md, 13-decision-log.md |
| Primary Audience | Product Owner, Designer, Developer, AI Coding Agent, Frontend Engineer, Backend Engineer, QA Engineer |
| Language | English |

---

## 1. Purpose

This document defines the UI/UX design direction for HIPZI.

The purpose of this document is to guide the design and implementation of HIPZI’s user interface so that the platform feels modern, friendly, trustworthy, and easy to use.

This document focuses on:

- Visual design direction.
- Role-based user experience.
- Page structure.
- Navigation patterns.
- Dashboard design.
- Student learning experience.
- Teacher content creation experience.
- Staff moderation experience.
- Admin governance experience.
- AI-assisted content experience.
- Material browsing experience.
- Quiz and flashcard practice experience.
- Form behavior.
- Empty states.
- Error states.
- Loading states.
- Status badges.
- Responsive design.
- Accessibility expectations.

This document does not define final pixel-perfect mockups. It provides professional UI/UX guidance for implementation using JSP, HTML, CSS, and JavaScript.

---

## 2. UI/UX Context

HIPZI is an AI-powered EdTech platform that serves multiple user roles:

- Students.
- Teachers / Lecturers.
- Staff.
- Admins.
- Parents in future phases.

The platform must support both learning-focused experiences and governance-focused workflows.

This creates an important design challenge:

> HIPZI must feel bright, friendly, and motivating for Students, while still feeling clear, reliable, and professional for Teachers, Staff, and Admins.

HIPZI should not look like a generic admin panel, and it should not look overly childish. It should feel like a modern education platform with AI assistance and human-reviewed learning quality.

---

## 3. Design Vision

HIPZI’s UI/UX direction should be:

> A bright, friendly, AI-assisted learning platform with soft colors, rounded cards, clear role-based dashboards, and safe human-reviewed educational workflows.

The visual experience should communicate:

- Learning feels approachable.
- AI is helpful but controlled.
- Teachers can create content easily.
- Staff can review content efficiently.
- Admins can govern the platform confidently.
- Students can focus on progress and practice.
- The platform is safe, clear, and trustworthy.

---

## 4. Design Personality

HIPZI should feel like:

- A friendly learning companion.
- A smart AI study assistant.
- A clean education platform.
- A safe learning environment.
- A modern digital classroom.
- A supportive mentor.

HIPZI should not feel like:

- A cold corporate dashboard.
- A complex enterprise system.
- A childish game-only app.
- A cluttered learning management system.
- A generic SaaS template.
- A dark or stressful study platform.

---

## 5. Visual Design Direction

### 5.1 Overall Style

HIPZI should use a bright, soft, modern visual style.

Recommended style keywords:

- Bright.
- Friendly.
- Clean.
- Soft.
- Rounded.
- Calm.
- Helpful.
- Modern.
- Trustworthy.
- Student-centered.

The interface should use:

- Light backgrounds.
- Pastel accents.
- Rounded cards.
- Clear spacing.
- Soft shadows.
- Friendly illustrations or icons.
- Status badges.
- Simple and readable typography.

---

### 5.2 Design Inspiration Direction

HIPZI may draw inspiration from modern Dribbble-style EdTech dashboards, but it should not copy any specific design directly.

The recommended design mix:

- 70% soft pastel learning dashboard style.
- 20% light gamification and progress tracking.
- 10% clean educational landing page structure.

This means:

- Student pages can feel more playful and motivating.
- Teacher pages should feel productive and creative.
- Staff pages should feel operational and efficient.
- Admin pages should feel structured and trustworthy.

---

## 6. Color System

### 6.1 Color Principles

HIPZI should use a light and friendly color palette.

The color system should support:

- Learning motivation.
- Visual clarity.
- Role distinction.
- Status communication.
- Accessibility.
- Calm reading experience.

The platform should avoid:

- Overly saturated colors.
- Dark-heavy interface.
- Too many competing accent colors.
- Red-heavy warning design.
- Neon or harsh gradients.

---

### 6.2 Recommended Color Palette

| Token | Suggested Color Direction | Usage |
|---|---|---|
| Primary | Soft Teal / Mint Green | Main actions, brand identity, highlights |
| Secondary | Warm Yellow / Soft Orange | Positive emphasis, learning progress, CTA accents |
| Accent | Soft Lavender / Light Purple | AI features, recommendations, special cards |
| Background | Off-white / Very light mint | Main page background |
| Surface | White / Soft card white | Cards, panels, forms |
| Text Primary | Dark Navy / Charcoal | Main text |
| Text Secondary | Cool Gray | Descriptions, metadata |
| Success | Soft Green | Approved, completed, correct |
| Warning | Amber | Pending, needs review, needs attention |
| Error | Soft Red | Rejected, failed, blocked |
| Info | Soft Blue | Tips, neutral information |

---

### 6.3 Suggested CSS Variables

The implementation may define design tokens as CSS variables.

    :root {
      --color-primary: #42c7a5;
      --color-primary-soft: #dff8f1;
      --color-secondary: #f7c948;
      --color-secondary-soft: #fff4cc;
      --color-accent: #a78bfa;
      --color-accent-soft: #f0eaff;

      --color-background: #f7fbf8;
      --color-surface: #ffffff;
      --color-surface-soft: #f2f7f5;

      --color-text-primary: #17212b;
      --color-text-secondary: #5f6b7a;
      --color-border: #e6ecea;

      --color-success: #35b779;
      --color-success-soft: #e3f8ee;
      --color-warning: #f0a928;
      --color-warning-soft: #fff2d8;
      --color-error: #e85d5d;
      --color-error-soft: #ffe7e7;
      --color-info: #4f9df7;
      --color-info-soft: #e8f2ff;

      --font-sans: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;
    }

These values may be refined during visual implementation.

---
## 7. Typography

### 7.1 Typography Direction

HIPZI should use a modern, clean, readable sans-serif font system that supports Vietnamese characters well.

Because HIPZI's MVP user-facing interface is Vietnamese-first, the selected font must render Vietnamese diacritics clearly and consistently across headings, body text, form labels, validation messages, status badges, and dashboard tables.

The typography should feel:

- Bright.
- Friendly.
- Modern.
- Clean.
- Trustworthy.
- Easy to read on Student learning pages.
- Professional enough for Teacher, Staff, and Admin workflows.

Avoid fonts that feel:

- Browser-default and unfinished.
- Decorative or novelty-driven.
- Hard to read at small sizes.
- Too playful for Staff/Admin governance pages.
- Inconsistent when rendering Vietnamese tone marks.

---

### 7.2 Recommended Font Choices

Recommended font direction:

| Priority | Font | Best For | Notes |
|---|---|---|---|
| Primary | Be Vietnam Pro | Vietnamese-first MVP UI | Strong Vietnamese support, clean forms, friendly learning pages, professional dashboards |
| Dashboard fallback | Plus Jakarta Sans | Modern EdTech dashboards | Friendly, polished, and suitable for role-based dashboards |
| Clean UI fallback | Inter | Forms, tables, admin surfaces | Highly readable and neutral |
| System fallback | Arial, sans-serif | Last-resort rendering | Available broadly when web fonts fail |

Final recommendation:

> Use `Be Vietnam Pro` as the primary HIPZI MVP UI font.

`Plus Jakarta Sans` and `Inter` should remain in the stack as modern fallbacks. Do not use decorative fonts for core UI text.

---

### 7.3 Final Font Stack

For HIPZI MVP, the recommended font stack is:

```css
font-family: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;
```

Recommended CSS token:

```css
:root {
  --font-sans: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;
}

body {
  font-family: var(--font-sans);
}
```

---

### 7.4 Typography Rules By Role

Student pages should prioritize readability and warmth:

- Use clear headings.
- Keep body text comfortable and spacious.
- Avoid dense blocks of text inside cards.
- Use friendly Vietnamese copy that is easy for learners to scan.

Teacher pages should feel productive and organized:

- Use concise headings.
- Make status labels and form labels easy to read.
- Keep writing tools and material management pages calm and structured.

Staff and Admin pages should feel professional and efficient:

- Use compact but readable table text.
- Preserve clear heading hierarchy.
- Keep status badges readable at small sizes.
- Avoid playful typography treatments in moderation and governance screens.

---

### 7.5 Typography Implementation Rules

Implementation should follow these rules:

- Use the shared `--font-sans` token instead of repeating font stacks across files.
- Use Vietnamese UI copy for all user-facing text.
- Keep technical identifiers in code, database fields, routes, CSS class names, and Java names in English.
- Use normal letter spacing for body text and controls.
- Keep line-height comfortable for Vietnamese diacritics.
- Test Vietnamese sample text in headings, forms, cards, badges, tables, and error messages.

---

## 8. Layout System

### 8.1 Spacing

HIPZI should use generous spacing.

Recommended spacing tokens:

| Token | Value |
|---|---|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| 2xl | 48px |
| 3xl | 64px |

Rules:

- Cards should not feel cramped.
- Forms should have clear vertical spacing.
- Dashboard sections should be visually separated.
- Mobile spacing should remain comfortable.

---

### 8.2 Card System

Cards are a core UI pattern in HIPZI.

Cards should be used for:

- Subjects.
- Materials.
- Quizzes.
- Flashcard sets.
- Teacher profiles.
- AI suggestions.
- Roadmap steps.
- Staff review items.
- Admin statistics.
- Learning progress.

Recommended card style:

- White or soft pastel background.
- Large rounded corners.
- Soft border or shadow.
- Clear heading.
- Short description.
- Metadata tags.
- Primary action button or link.
- Optional icon or illustration.

Recommended CSS style direction:

    .card {
      background: var(--color-surface);
      border: 1px solid var(--color-border);
      border-radius: 24px;
      padding: 24px;
      box-shadow: 0 12px 30px rgba(23, 33, 43, 0.06);
    }

---

### 8.3 Page Width

Recommended layout widths:

| Page Type | Width Direction |
|---|---|
| Landing page | Wide, centered sections |
| Dashboard | Full width with max content container |
| Forms | Narrow centered container |
| Detail pages | Medium content width |
| Staff/Admin tables | Wide content area |

---

### 8.4 Responsive Layout

HIPZI should support desktop and mobile layouts.

Desktop:

- Sidebar or top navigation.
- Multi-column dashboard cards.
- Tables for Staff/Admin.
- Wider content panels.

Mobile:

- Bottom navigation or collapsed menu.
- Single-column cards.
- Simplified filters.
- Touch-friendly buttons.
- Quiz and flashcards optimized for reading.

---

## 9. Navigation Design

### 9.1 Navigation Principles

Navigation should be role-based.

Users should only see navigation items relevant to their active role.

Rules:

- Students should not see Staff or Admin tools.
- Teachers should not see Staff tools unless they also have Staff role.
- Staff should not see Admin tools unless they also have Admin role.
- Admin navigation should be clearly separated from normal learning navigation.
- Multi-role users should be able to switch role context if needed.

---

### 9.2 Student Navigation

Recommended Student navigation:

- Dashboard.
- Browse Materials.
- Subjects.
- Quizzes.
- Flashcards.
- Learning History.
- AI Roadmap in Phase 2.
- Profile.

Primary goal:

> Help Students continue learning quickly.

---

### 9.3 Teacher Navigation

Recommended Teacher navigation:

- Dashboard.
- Teacher Application / Status.
- My Materials.
- Upload Material.
- AI Quiz Generator.
- AI Flashcard Generator.
- AI Drafts.
- Staff Feedback.
- Classes in Phase 2.
- Profile.

Primary goal:

> Help Teachers create, manage, and review educational content.

---

### 9.4 Staff Navigation

Recommended Staff navigation:

- Moderation Dashboard.
- Teacher Applications.
- Material Review Queue.
- Reports in Phase 2.
- Escalations in Phase 2.
- Review History.

Primary goal:

> Help Staff review content quickly and safely.

---

### 9.5 Admin Navigation

Recommended Admin navigation:

- Admin Dashboard.
- Users.
- Roles.
- Staff Management.
- Subjects.
- Audit Logs.
- Overrides in Phase 2.
- Settings.

Primary goal:

> Help Admins govern platform roles, content, and policy-level decisions.

---

## 10. Role-Based UI Overview

### 10.1 Student UI Personality

Student UI should be:

- Friendly.
- Motivating.
- Simple.
- Visual.
- Progress-oriented.
- Slightly playful.

Student UI should emphasize:

- Continue learning.
- Recommended materials.
- Quiz practice.
- Flashcard practice.
- Learning progress.
- Weak areas.
- AI study help in Phase 2.

---

### 10.2 Teacher UI Personality

Teacher UI should be:

- Productive.
- Organized.
- Encouraging.
- Content-focused.
- AI-assisted.

Teacher UI should emphasize:

- Material creation.
- Upload flow.
- AI quiz/flashcard generation.
- AI draft review.
- Material approval status.
- Staff feedback.
- Content quality.

---

### 10.3 Staff UI Personality

Staff UI should be:

- Clear.
- Fast.
- Operational.
- Trustworthy.
- Low distraction.

Staff UI should emphasize:

- Review queue.
- Status.
- Applicant details.
- Material details.
- Decision actions.
- Review notes.
- Self-review restrictions.
- Audit trail.

---

### 10.4 Admin UI Personality

Admin UI should be:

- Professional.
- Structured.
- Reliable.
- Data-oriented.
- Governance-focused.

Admin UI should emphasize:

- User management.
- Role assignment.
- Staff permissions.
- Subject management.
- Audit logs.
- Override decisions.
- System safety.

---

## 11. Landing Page UX

### 11.1 Purpose

The landing page introduces HIPZI to new users.

It should explain:

- What HIPZI is.
- Who it is for.
- How AI helps.
- Why the platform is trustworthy.
- How Students, Teachers, and Staff interact.

---

### 11.2 Landing Page Sections

Recommended sections:

1. Hero section.
2. Value proposition.
3. How HIPZI works.
4. Student benefits.
5. Teacher benefits.
6. AI-assisted learning section.
7. Human-reviewed content trust section.
8. Call to action.
9. Footer.

---

### 11.3 Hero Section

Hero should include:

- Clear headline.
- Short description.
- Primary CTA.
- Secondary CTA.
- Friendly illustration or learning visual.

Example headline direction:

> Learn smarter with AI-assisted study materials.

Example subheading direction:

> HIPZI helps Students learn from approved materials, practice with quizzes and flashcards, and receive smarter learning support through human-reviewed AI tools.

Recommended CTAs:

- Start Learning.
- Become a Teacher.
- Explore Materials.

---

### 11.4 Landing Page Visual Style

The landing page should use:

- Bright background.
- Large friendly headline.
- Soft pastel shapes.
- Student-focused illustration.
- Rounded cards showing platform benefits.
- Clear CTA buttons.

---

## 12. Student Experience Design

### 12.1 Student Dashboard

The Student Dashboard should help Students quickly continue learning.

Recommended sections:

- Welcome card.
- Continue Learning.
- Recommended Materials.
- Practice Quizzes.
- Flashcard Sets.
- Recent Activity.
- Learning Progress.
- AI Roadmap in Phase 2.

Example layout:

    Welcome, Ngoc
    "Ready to continue your learning journey?"

    [Continue Learning Card]
    [Recommended Materials]
    [Practice Quizzes]
    [Flashcards]
    [Recent Results]
    [Learning Progress]

---

### 12.2 Student Dashboard Cards

Recommended cards:

#### Continue Learning Card

Shows:

- Last viewed material.
- Subject.
- Progress.
- Continue button.

#### Recommended Material Card

Shows:

- Subject badge.
- Title.
- Short description.
- Difficulty.
- Estimated time.
- Start Learning button.

#### Quiz Practice Card

Shows:

- Quiz title.
- Number of questions.
- Difficulty.
- Last score if attempted.
- Start Quiz button.

#### Flashcard Card

Shows:

- Flashcard set title.
- Number of cards.
- Subject.
- Practice button.

---

### 12.3 Material Browsing Page

Purpose:

> Help Students find approved learning materials easily.

Recommended elements:

- Page title.
- Search bar.
- Subject filter.
- Difficulty filter.
- Material cards.
- Empty state if no results.
- Pagination or load more.

Material cards should show:

- Subject.
- Title.
- Description.
- Teacher name if available.
- Difficulty.
- Number of quizzes.
- Number of flashcards.
- AI-assisted badge if relevant.
- Start Learning button.

Student-facing rule:

> Only approved and visible materials should appear.

---

### 12.4 Material Detail Page

Purpose:

> Help Students understand and study a selected material.

Recommended sections:

- Material title.
- Subject badge.
- Teacher information.
- Description.
- Main content.
- Attached files.
- Available quizzes.
- Available flashcards.
- Related materials.

Important UX rule:

If material is no longer available, show:

> This material is currently unavailable.

Do not expose moderation details to Students.

---

### 12.5 Student Learning History

Purpose:

> Help Students see past learning activity.

Recommended elements:

- Recently viewed materials.
- Completed quizzes.
- Quiz scores.
- Flashcard practice history.
- Progress summary.
- Weak areas in Phase 2.

This page should feel encouraging, not judgmental.

Use friendly language:

- "Keep going."
- "You are making progress."
- "Review this topic again."
- "Try another practice quiz."

---

## 13. Teacher Experience Design

### 13.1 Teacher Dashboard

Purpose:

> Help Teachers manage learning content and AI-assisted creation.

Recommended sections:

- Teacher status.
- My Materials.
- Upload New Material.
- Pending Review Materials.
- Staff Feedback.
- AI Drafts.
- Quick Actions.

Example quick actions:

- Upload Material.
- Generate Quiz.
- Generate Flashcards.
- Review AI Drafts.
- View Staff Feedback.

---

### 13.2 Teacher Application Page

Purpose:

> Help users apply to become verified Teachers.

Recommended form sections:

- Basic teaching profile.
- Teaching subjects.
- Experience summary.
- Qualifications.
- Short introduction.
- Optional supporting information.

UX rules:

- Explain why verification is needed.
- Show required fields clearly.
- Show progress or status after submission.
- Avoid making the form feel intimidating.

---

### 13.3 Teacher Application Status Page

Statuses:

- Draft.
- Pending Review.
- Approved.
- Rejected.
- Suspended.

Recommended UI:

| Status | UX Treatment |
|---|---|
| Draft | Neutral badge, continue application button |
| Pending Review | Amber badge, waiting message |
| Approved | Green badge, go to Teacher Dashboard button |
| Rejected | Red badge, show reason and next steps |
| Suspended | Red/Warning badge, contact support or view policy |

---

### 13.4 Teacher Material Management Page

Purpose:

> Help Teachers manage their uploaded materials.

Recommended elements:

- Material list.
- Status filter.
- Subject filter.
- Create material button.
- Material status badges.
- Staff feedback indicator.
- Edit button where allowed.
- Submit for review button where allowed.

Material status badge colors:

| Status | Badge Style |
|---|---|
| Draft | Gray |
| Pending Review | Amber |
| Approved | Green |
| Rejected | Red |
| Needs Revision | Orange |
| Hidden | Gray / muted |
| Archived | Gray / outlined |

---

### 13.5 Material Creation Form

Recommended sections:

- Title.
- Subject.
- Description.
- Content text.
- File upload.
- Difficulty level.
- Grade level.
- Save Draft button.
- Submit for Review button.

UX rules:

- Save Draft should be available before complete submission.
- Submit for Review should validate required fields.
- Show clear validation messages.
- Show upload status.
- Show what happens after submission.

Example helper text:

> Submitted materials will be reviewed by Staff before becoming visible to Students.

---

### 13.6 Staff Feedback View for Teacher

If Staff rejects or requests revision, Teacher should see:

- Material title.
- Current status.
- Staff feedback.
- Revision suggestions.
- Edit Material button.
- Resubmit for Review button.

UX should be constructive.

Avoid harsh wording.

Recommended tone:

> Staff requested revisions. Please review the feedback below and update your material before resubmitting.

---

## 14. AI Content Experience Design

### 14.1 AI Design Principle

AI should feel helpful, but controlled.

The UI must communicate:

- AI is assisting.
- AI output is not final.
- Teacher review is required.
- Student access depends on review status.

---

### 14.2 AI Badge System

AI-assisted content should use clear badges.

Recommended badges:

| Badge | Meaning |
|---|---|
| AI-assisted | Content was generated or assisted by AI |
| Draft | Not reviewed yet |
| Teacher Reviewed | Teacher has reviewed the AI content |
| Staff Review Required | Staff approval is still needed |
| Approved | Ready or visible according to policy |
| Discarded | Removed from active use |

---

### 14.3 AI Quiz Generation Page

Purpose:

> Help Teachers generate quiz drafts from learning materials.

Recommended fields:

- Source material.
- Number of questions.
- Difficulty.
- Question types.
- Additional instructions.
- Generate button.

Recommended UX flow:

    Select material
    → Configure quiz generation
    → Click Generate Quiz
    → Show loading state
    → Save result as draft
    → Redirect to AI review page

Important message:

> AI-generated quizzes are saved as drafts and must be reviewed before Students can access them.

---

### 14.4 AI Flashcard Generation Page

Purpose:

> Help Teachers generate flashcard drafts from materials.

Recommended fields:

- Source material.
- Number of cards.
- Difficulty.
- Focus topics.
- Generate button.

Important message:

> AI-generated flashcards may need correction. Please review before publishing.

---

### 14.5 AI Content Review Page

Purpose:

> Help Teachers review, edit, approve, or discard AI-generated content.

Recommended layout:

- Source material summary.
- AI-assisted badge.
- Draft status.
- Editable generated questions or cards.
- Explanation fields.
- Save changes button.
- Mark as Teacher Reviewed button.
- Discard button.

For quizzes:

Each question should show:

- Question text.
- Question type.
- Answer options.
- Correct answer.
- Explanation.
- Edit controls.

For flashcards:

Each card should show:

- Front text.
- Back text.
- Explanation if available.
- Edit controls.

---

### 14.6 AI Loading State

AI generation may take time.

Recommended loading state:

- Friendly message.
- Progress indicator.
- Do not allow duplicate click.
- Explain that generation may take a few moments.

Example message:

> HIPZI AI is preparing your quiz draft. This may take a moment.

---

### 14.7 AI Failure State

If AI generation fails, show:

- Clear error message.
- Retry button.
- No broken draft.
- No Student publication.

Example message:

> AI generation failed. Your original material is safe. Please try again.

---

## 15. Staff Moderation Experience Design

### 15.1 Staff Dashboard

Purpose:

> Help Staff review pending work efficiently.

Recommended dashboard sections:

- Pending Teacher Applications.
- Pending Material Reviews.
- Needs Revision.
- Reported Content in Phase 2.
- Recent Decisions.
- Escalations in Phase 2.

Staff dashboard should prioritize clarity over decoration.

---

### 15.2 Teacher Application Review Queue

Recommended table/card fields:

- Applicant name.
- Submitted date.
- Teaching subjects.
- Status.
- Review button.

Filters:

- Status.
- Subject.
- Submitted date.
- Search by applicant name.

---

### 15.3 Teacher Application Detail Review

Recommended sections:

- Applicant profile.
- Teaching subjects.
- Experience.
- Qualifications.
- Submitted information.
- Review notes.
- Approve button.
- Reject button.

Reject action should require a reason.

Approve action should show confirmation.

---

### 15.4 Material Review Queue

Recommended fields:

- Material title.
- Teacher name.
- Subject.
- Submitted date.
- Status.
- Review button.

Filters:

- Subject.
- Status.
- Teacher.
- Date.

---

### 15.5 Material Review Detail Page

Recommended sections:

- Material summary.
- Teacher information.
- Subject and metadata.
- Main content.
- Attached files.
- AI-generated content indicator if relevant.
- Moderation history.
- Review action panel.

Review actions:

- Approve.
- Reject.
- Request Revision.
- Hide.
- Archive.

Reject and request revision should require reason.

---

### 15.6 Self-Review Block UX

If a Staff user also owns the material as Teacher, show:

> You cannot review your own content. Another Staff member or Admin must handle this review.

Actions should be disabled.

The system should not rely only on disabled buttons. Backend must also block the action.

---

## 16. Admin Governance Experience Design

### 16.1 Admin Dashboard

Purpose:

> Help Admins manage platform governance.

Recommended sections:

- User count.
- Teacher count.
- Staff count.
- Pending reviews summary.
- Recent role changes.
- Recent moderation activity.
- Audit log shortcut.
- Subject management shortcut.

Admin UI should be professional and structured.

---

### 16.2 User Management Page

Recommended elements:

- Search users.
- Filter by role.
- Filter by account status.
- User table.
- Role badges.
- View detail button.
- Assign role action.
- Revoke role action.

User table columns:

- Name.
- Email.
- Roles.
- Account status.
- Created date.
- Actions.

---

### 16.3 Role Management UX

When assigning roles:

- Show current roles.
- Show available roles.
- Explain impact of Staff role.
- Require confirmation for sensitive roles.
- Create audit log.

Example warning for Staff role:

> Staff users can review Teacher applications and learning materials. Self-review rules still apply.

---

### 16.4 Subject Management Page

Recommended elements:

- Subject list.
- Add subject button.
- Edit subject.
- Active/inactive status.
- Parent subject if hierarchy is used.

Subjects should be simple to manage because they affect material categorization and browsing.

---

### 16.5 Audit Log Page

Recommended elements:

- Action type filter.
- Actor filter.
- Entity type filter.
- Date range filter.
- Audit table.

Audit columns:

- Timestamp.
- Actor.
- Role.
- Action.
- Target entity.
- Previous value.
- New value.
- Reason.

Audit log should be readable, not overly technical.

---

## 17. Quiz Practice UX

### 17.1 Quiz Start Page

Recommended elements:

- Quiz title.
- Material source.
- Number of questions.
- Difficulty.
- Estimated time.
- Start Quiz button.

Important note:

> Practice quizzes are for learning feedback.

---

### 17.2 Quiz Attempt Page

Recommended elements:

- Question number.
- Question text.
- Answer options.
- Progress indicator.
- Save or next button if multi-step.
- Submit button.
- Clear selected answer option.

UX rules:

- Do not show correct answers before submission.
- Make answer options large and clickable.
- Show progress clearly.
- Prevent accidental double submission.

---

### 17.3 Quiz Result Page

Recommended elements:

- Score.
- Correct count.
- Incorrect count.
- Question review.
- Explanations.
- Retake button if allowed.
- Recommended next action.

Tone should be encouraging.

Example messages:

- "Great progress."
- "Review these topics to improve."
- "Try again when you are ready."

---

### 17.4 Incorrect Answer Feedback

Feedback should be educational.

For each incorrect answer:

- Show selected answer.
- Show correct answer if allowed.
- Show explanation.
- Link to related material if possible.

---

## 18. Flashcard Practice UX

### 18.1 Flashcard Set Page

Recommended elements:

- Set title.
- Material source.
- Number of cards.
- Start Practice button.

---

### 18.2 Flashcard Practice Screen

Recommended interaction:

- Show front side.
- Click or tap to reveal answer.
- Show back side.
- Next card button.
- Previous card button.
- Mark as known / needs review in Phase 2.

UX style:

- Large centered card.
- Smooth simple flip effect if possible.
- Keyboard support in Phase 2.
- Mobile-friendly touch area.

---

### 18.3 Empty Flashcard Set

If no flashcards exist, show:

> This flashcard set is empty.

Recommended action:

- Back to material.
- Try another flashcard set.

---

## 19. Form UX

### 19.1 Form Principles

Forms should be:

- Clear.
- Short where possible.
- Grouped by purpose.
- Easy to validate.
- Friendly in tone.
- Accessible.

---

### 19.2 Required Fields

Required fields should be clearly marked.

Recommended format:

- Label.
- Required indicator.
- Helper text if needed.
- Error message below field.

Example:

    Title *
    Enter a clear title for your learning material.
    Error: Title is required.

---

### 19.3 Form Actions

Recommended action order:

- Primary action on the right.
- Secondary action on the left or beside it.
- Destructive action separated or visually distinct.

Examples:

Material form:

- Save Draft.
- Submit for Review.

AI draft review:

- Save Changes.
- Mark as Teacher Reviewed.
- Discard Draft.

Staff review:

- Approve.
- Request Revision.
- Reject.

---

### 19.4 Confirmation Dialogs

Use confirmation for important actions:

- Approve Teacher application.
- Reject Teacher application.
- Approve material.
- Reject material.
- Assign Staff role.
- Revoke Staff role.
- Archive material.
- Discard AI content.

Confirmation should explain consequences.

---

## 20. Status Badge System

Status badges are critical in HIPZI because many workflows depend on status.

### 20.1 Material Status Badges

| Status | Label | Style |
|---|---|---|
| draft | Draft | Neutral gray |
| pending_review | Pending Review | Amber |
| approved | Approved | Green |
| rejected | Rejected | Red |
| needs_revision | Needs Revision | Orange |
| hidden | Hidden | Muted gray |
| archived | Archived | Outlined gray |

---

### 20.2 Teacher Application Badges

| Status | Label | Style |
|---|---|---|
| draft | Draft | Neutral |
| pending_review | Pending Review | Amber |
| approved | Approved | Green |
| rejected | Rejected | Red |
| suspended | Suspended | Red / dark warning |

---

### 20.3 AI Content Badges

| Status | Label | Style |
|---|---|---|
| generated_draft | AI Draft | Purple / soft accent |
| teacher_reviewed | Teacher Reviewed | Blue or green |
| submitted_for_review | Staff Review Required | Amber |
| approved | Approved | Green |
| rejected | Rejected | Red |
| published | Published | Green |
| discarded | Discarded | Gray |

---

### 20.4 Quiz Attempt Badges

| Status | Label | Style |
|---|---|---|
| started | In Progress | Blue |
| submitted | Submitted | Amber |
| scored | Scored | Green |
| reviewed | Reviewed | Green |
| incomplete | Incomplete | Gray |

---

## 21. Empty States

Empty states should be helpful, not blank.

### 21.1 No Materials Found

Message:

> No materials found.

Helper text:

> Try a different keyword or choose another subject.

Action:

- Clear filters.
- Browse all subjects.

---

### 21.2 Teacher Has No Materials

Message:

> You have not created any materials yet.

Helper text:

> Upload your first learning material and submit it for Staff review.

Action:

- Upload Material.

---

### 21.3 Staff Review Queue Empty

Message:

> No items need review right now.

Helper text:

> New teacher applications and material submissions will appear here.

---

### 21.4 No AI Drafts

Message:

> No AI drafts yet.

Helper text:

> Generate a quiz or flashcards from one of your learning materials.

Action:

- Generate Quiz.
- Generate Flashcards.

---

### 21.5 No Learning History

Message:

> Your learning history is empty.

Helper text:

> Start a quiz or practice flashcards to see your progress here.

Action:

- Browse Materials.

---

## 22. Error States

### 22.1 Permission Error

Message:

> You do not have permission to access this page.

Helper text:

> If you believe this is a mistake, contact the platform administrator.

---

### 22.2 Content Unavailable

Message:

> This content is currently unavailable.

Possible reasons:

- It is under review.
- It was hidden.
- It was archived.
- It is no longer visible.

Do not expose internal moderation details to Students.

---

### 22.3 AI Generation Error

Message:

> AI generation failed.

Helper text:

> Your original material is safe. Please try again.

Action:

- Try Again.
- Back to Material.

---

### 22.4 Quiz Submission Error

Message:

> Your quiz could not be submitted.

Possible helper text:

- Please check your answers and try again.
- This attempt has already been submitted.
- This quiz is no longer available.

---

### 22.5 System Error

Message:

> Something went wrong.

Helper text:

> Please try again later.

Do not show stack traces or internal server details.

---

## 23. Loading States

Loading states should make the system feel responsive.

Use loading states for:

- Login.
- Search.
- Material loading.
- Staff review action.
- AI generation.
- Quiz submission.
- File upload.
- Role assignment.

Examples:

- Button loading spinner.
- Skeleton cards.
- Progress message.
- Disabled duplicate action button.

AI loading message:

> HIPZI AI is preparing your draft. This may take a moment.

Quiz submission loading message:

> Submitting your answers...

---

## 24. Responsive Design

### 24.1 Desktop

Desktop layout should support:

- Sidebar navigation.
- Multi-column dashboards.
- Tables for Staff/Admin.
- Large review panels.
- Split view for content and actions.

---

### 24.2 Tablet

Tablet layout should support:

- Collapsible sidebar.
- Two-column card grids.
- Larger touch targets.
- Simplified tables.

---

### 24.3 Mobile

Mobile layout should support:

- Single-column cards.
- Top or bottom navigation.
- Large buttons.
- Simplified filters.
- Scroll-friendly material detail.
- Mobile quiz practice.
- Mobile flashcards.

Priority for mobile:

- Student browsing.
- Material reading.
- Quiz practice.
- Flashcard practice.

Staff/Admin mobile support can be simpler, but should not be broken.

---

## 25. Accessibility Requirements

HIPZI should follow basic accessibility practices from MVP.

### 25.1 General Accessibility

Requirements:

- Use semantic HTML where possible.
- Use proper heading hierarchy.
- Use labels for form fields.
- Use readable contrast.
- Use keyboard-accessible buttons and links.
- Avoid color-only meaning.
- Provide clear focus states.
- Provide alt text for meaningful images.
- Ensure error messages are connected to fields.

---

### 25.2 Quiz Accessibility

Quiz UI should:

- Allow keyboard selection.
- Clearly identify selected answer.
- Avoid relying only on color for correct/incorrect feedback.
- Provide text explanation.
- Use readable spacing between answers.

---

### 25.3 Flashcard Accessibility

Flashcard UI should:

- Support click/tap reveal.
- Support keyboard reveal in future.
- Keep text large and readable.
- Avoid animation that prevents reading.

---

### 25.4 Staff/Admin Accessibility

Staff and Admin pages should:

- Use clear table headers.
- Provide accessible action buttons.
- Make status badges readable.
- Support keyboard navigation for major actions.

---

## 26. JSP Implementation Guidelines

Since HIPZI uses JSP, UI implementation should follow these rules:

### 26.1 JSP Responsibility

JSP should:

- Render HTML.
- Display data from request attributes.
- Show validation messages.
- Show role-based navigation using prepared data.
- Use JSTL for simple loops and conditions.
- Include shared layout components.

JSP should not:

- Query the database.
- Perform business logic.
- Decide workflow status.
- Call AI services.
- Perform authorization as the only protection.

---

### 26.2 Shared JSP Layout

Recommended shared layout files:

- `header.jsp`
- `footer.jsp`
- `sidebar.jsp`
- `main-layout.jsp`
- `alert.jsp`
- `status-badge.jsp`
- `pagination.jsp`

Shared components reduce duplication.

---

### 26.3 JSP View Folders

Recommended view folders:

    WEB-INF/views/
    ├── layout/
    ├── auth/
    ├── student/
    ├── teacher/
    ├── staff/
    ├── admin/
    ├── material/
    ├── ai/
    ├── practice/
    └── error/

---

### 26.4 JSP Naming

JSP files should use kebab-case.

Examples:

- `material-detail.jsp`
- `material-form.jsp`
- `application-status.jsp`
- `material-review-detail.jsp`
- `review-ai-content.jsp`
- `quiz-attempt.jsp`
- `quiz-result.jsp`

---

## 27. CSS Implementation Guidelines

### 27.1 CSS Structure

Recommended CSS structure:

    assets/css/
    ├── main.css
    ├── tokens.css
    ├── layout.css
    ├── components.css
    ├── forms.css
    ├── dashboard.css
    ├── material.css
    ├── quiz.css
    ├── staff.css
    └── admin.css

---

### 27.2 CSS Principles

CSS should:

- Use design tokens.
- Define and use `--font-sans: "Be Vietnam Pro", "Plus Jakarta Sans", "Inter", Arial, sans-serif;`.
- Use reusable classes.
- Avoid excessive inline styling.
- Keep components consistent.
- Support responsive behavior.
- Support accessibility states.

---

### 27.3 Component Class Examples

Recommended component class names:

- `.app-shell`
- `.sidebar`
- `.topbar`
- `.page-header`
- `.card`
- `.card-grid`
- `.status-badge`
- `.primary-button`
- `.secondary-button`
- `.danger-button`
- `.form-group`
- `.form-error`
- `.empty-state`
- `.loading-state`
- `.review-panel`
- `.quiz-option`
- `.flashcard`

---

## 28. JavaScript Implementation Guidelines

JavaScript should enhance the user experience, not replace backend rules.

Use JavaScript for:

- Form helper behavior.
- Dynamic filters.
- AI generation loading state.
- Quiz option selection.
- Flashcard flip.
- Confirmation dialogs.
- File upload preview.

Do not use JavaScript as the only layer for:

- Authorization.
- Role checks.
- Material visibility.
- Status transition rules.
- Quiz scoring integrity.
- AI content publication rules.

Backend must always validate important actions.

---

## 29. Component Guidelines

### 29.1 Buttons

Button types:

| Button | Usage |
|---|---|
| Primary | Main action |
| Secondary | Alternative action |
| Ghost | Low emphasis action |
| Danger | Destructive action |
| Disabled | Unavailable action |

Examples:

- Start Learning.
- Upload Material.
- Submit for Review.
- Generate Quiz.
- Approve.
- Reject.
- Assign Role.

---

### 29.2 Cards

Card variants:

| Card Type | Usage |
|---|---|
| Learning Card | Materials, quizzes, flashcards |
| Progress Card | Student progress |
| Review Card | Staff queue items |
| Admin Card | Metrics and governance |
| AI Card | AI drafts and suggestions |
| Empty Card | Empty state container |

---

### 29.3 Tables

Tables should be used mainly for Staff and Admin workflows.

Table features:

- Search.
- Filter.
- Pagination.
- Status badge.
- Clear action buttons.
- Empty state.

Avoid using dense tables for Student pages unless necessary.

---

### 29.4 Modals

Modals should be used for confirmations, not complex workflows.

Good modal use cases:

- Confirm approval.
- Confirm rejection.
- Confirm role assignment.
- Confirm discard AI draft.
- Confirm archive material.

Avoid putting long forms inside modals.

---

## 30. Page-Level UX Specifications

### 30.1 Login Page

Elements:

- HIPZI logo.
- Email field.
- Password field.
- Login button.
- Register link.
- Friendly welcome message.

Style:

- Centered card.
- Soft background.
- Clean form.

---

### 30.2 Register Page

Elements:

- Display name field.
- Email field.
- Password field.
- Confirm password field if needed.
- Register button.
- Login link.

UX:

- Clear validation.
- Friendly onboarding.
- Default role assigned according to platform policy.

---

### 30.3 Student Dashboard Page

Elements:

- Welcome heading.
- Continue learning.
- Recommended materials.
- Practice quizzes.
- Flashcards.
- Recent activity.
- Progress cards.

Style:

- Soft cards.
- Friendly illustrations/icons.
- Motivational tone.

---

### 30.4 Teacher Dashboard Page

Elements:

- Teacher status.
- My materials summary.
- Pending review count.
- AI drafts.
- Upload material CTA.
- Staff feedback.

Style:

- Productive and organized.
- Less playful than Student dashboard.
- Clear workflow statuses.

---

### 30.5 Staff Dashboard Page

Elements:

- Pending teacher applications.
- Pending material reviews.
- Recent moderation actions.
- Queue filters.
- Review shortcuts.

Style:

- Operational.
- Table and queue focused.
- Clear action priority.

---

### 30.6 Admin Dashboard Page

Elements:

- User summary.
- Role summary.
- Staff management.
- Subject management.
- Audit log summary.

Style:

- Professional.
- Structured.
- Data-oriented.

---

## 31. UX Copywriting Guidelines

HIPZI should use clear and friendly language.

### 31.1 Tone

Use tone that is:

- Helpful.
- Encouraging.
- Clear.
- Calm.
- Respectful.
- Professional.

Avoid tone that is:

- Harsh.
- Overly technical.
- Blaming.
- Too childish.
- Too robotic.

---

### 31.2 Example Copy

Good:

> Your material has been submitted for review.

Avoid:

> Status changed to pending_review.

Good:

> AI generated a draft. Please review it before Students can access it.

Avoid:

> AI output object created.

Good:

> You cannot review your own content.

Avoid:

> Forbidden due to self-review policy violation.

---

## 32. UX Rules for Critical Business Logic

### 32.1 Student Visibility Rule

Student UI must never show:

- Draft materials.
- Pending review materials.
- Rejected materials.
- Needs revision materials.
- Hidden materials.
- Archived materials.
- Unreviewed AI content.

If a Student accesses unavailable content, show a safe unavailable state.

---

### 32.2 Teacher Approval Rule

Unapproved Teachers should see:

- Application status.
- Clear next step.
- Explanation that Teacher approval is required before uploading materials.

They should not see full Teacher content tools until approved.

---

### 32.3 Staff Self-Review Rule

If Staff is also the content owner:

- Show self-review restriction message.
- Disable moderation actions.
- Backend must still block action.

---

### 32.4 AI Draft Rule

AI-generated content should clearly show:

- AI-assisted badge.
- Draft status.
- Teacher review requirement.
- Student visibility status.

---

### 32.5 Admin Role Assignment Rule

Admin role assignment UI should:

- Show current user roles.
- Confirm sensitive role assignment.
- Explain Staff role impact.
- Record audit log.

---

## 33. Design Quality Checklist

Before implementing or approving a page, check:

| Question | Expected Answer |
|---|---|
| Is the page role-appropriate? | Yes |
| Is the primary action clear? | Yes |
| Are statuses visible and understandable? | Yes |
| Are errors clear and safe? | Yes |
| Are empty states helpful? | Yes |
| Is the page responsive? | Yes |
| Is the page accessible by keyboard where needed? | Yes |
| Is the visual style consistent with HIPZI? | Yes |
| Does JSP only render prepared data? | Yes |
| Are backend rules still enforced outside UI? | Yes |

---

## 34. MVP UI/UX Scope

The MVP should include polished UI/UX for:

- Landing page.
- Login page.
- Register page.
- Student dashboard.
- Material browsing.
- Material detail.
- Quiz practice.
- Quiz result.
- Flashcard practice.
- Teacher application.
- Teacher application status.
- Teacher dashboard.
- Material creation form.
- Teacher material management.
- AI quiz generation.
- AI flashcard generation.
- AI content review.
- Staff dashboard.
- Teacher application review.
- Material review queue.
- Material review detail.
- Admin dashboard.
- User management.
- Role assignment.
- Subject management.
- Basic audit log view if implemented.
- Error pages.

---

## 35. Phase 2 UI/UX Scope

Phase 2 should improve or add:

- AI learning roadmap.
- Personalization input flow.
- Recommended materials.
- Recommended Teachers.
- Natural-language search.
- Report content flow.
- Staff report queue.
- Class management.
- Enrollment request UX.
- Notifications.
- Improved progress analytics.
- Better responsive mobile experience.
- More advanced accessibility support.

---

## 36. Future UI/UX Scope

Future UI/UX may include:

- Parent dashboard.
- Payment and subscription screens.
- Teacher marketplace.
- Course builder.
- Course learning experience.
- Formal exam interface.
- Written answer grading review.
- Review and rating system.
- Advanced analytics dashboard.
- Mobile app design.

---

## 37. UI/UX Risks

### 37.1 Risk: Interface Becomes Too Admin-Like

| Field | Value |
|---|---|
| Risk | HIPZI may feel like a generic management system instead of a friendly learning platform. |
| Impact | Students may feel less motivated to use the platform. |
| Mitigation | Use soft colors, learning cards, friendly copy, and progress-focused Student UI. |

---

### 37.2 Risk: Interface Becomes Too Playful

| Field | Value |
|---|---|
| Risk | The platform may look childish and reduce trust for Teachers, Staff, and Admins. |
| Impact | Professional users may not take moderation and governance seriously. |
| Mitigation | Keep Staff/Admin UI clean, structured, and professional. Use playful elements mainly in Student experience. |

---

### 37.3 Risk: AI Content Status Is Unclear

| Field | Value |
|---|---|
| Risk | Teachers may think AI-generated content is already public, or Students may access content too early. |
| Impact | Unsafe learning experience. |
| Mitigation | Use strong AI badges, clear draft status, and explicit review CTAs. |

---

### 37.4 Risk: Too Many Statuses Confuse Users

| Field | Value |
|---|---|
| Risk | Users may not understand draft, pending review, approved, rejected, hidden, archived, and needs revision. |
| Impact | Teacher and Staff workflows become confusing. |
| Mitigation | Use consistent status badges, helper text, and status-specific actions. |

---

### 37.5 Risk: JSP Pages Become Inconsistent

| Field | Value |
|---|---|
| Risk | Different pages may use different spacing, buttons, forms, and badges. |
| Impact | User experience feels unprofessional. |
| Mitigation | Use shared JSP layout files, CSS tokens, reusable components, and this UI/UX specification. |

---

## 38. Implementation Notes for AI Coding Agent

When implementing UI/UX, the AI coding agent should:

1. Read this document before creating JSP pages.
2. Use shared layout components.
3. Keep JSP focused on rendering.
4. Use consistent status badges.
5. Use role-specific navigation.
6. Use backend-provided permission flags only for display convenience.
7. Never rely on UI-only authorization.
8. Use friendly copywriting.
9. Add empty, loading, and error states.
10. Keep Student UI bright and motivating.
11. Keep Staff/Admin UI clear and professional.
12. Update this document if UI direction changes significantly.

---

## 39. UI/UX Acceptance Checklist for MVP

A UI/UX implementation is acceptable for MVP when:

- Main pages follow the bright and friendly HIPZI design direction.
- Student pages are easy and motivating to use.
- Teacher pages clearly support content creation and review workflows.
- Staff pages clearly support moderation actions.
- Admin pages clearly support governance actions.
- AI-generated content is clearly labeled.
- Status badges are consistent.
- Forms have clear validation messages.
- Empty states are helpful.
- Error states are safe and understandable.
- Loading states exist for slow actions.
- Student-facing pages hide unavailable content.
- Pages are usable on common desktop and mobile screen sizes.
- JSP files use shared layouts and consistent styling.

---

## Vietnamese Interface Language

HIPZI's MVP user-facing interface must use Vietnamese as the primary language.

All visible website copy should be written in Vietnamese, including:

- Page titles
- Navigation items
- Buttons
- Form labels
- Helper text
- Validation messages
- Empty states
- Error states
- Loading states
- Status badges
- Dashboard descriptions
- Teacher application messages
- Staff moderation messages
- Admin management labels
- Permission and unavailable-content messages

### Tone of Voice

Vietnamese UI copy should be:

- Friendly.
- Clear.
- Encouraging.
- Easy to understand.
- Professional where needed.
- Not overly formal.
- Not too childish.

Student-facing Vietnamese copy should feel warm, simple, and motivating.

Teacher, Staff, and Admin Vietnamese copy should remain clear, respectful, and professional.

### Example Copy

| English Meaning | Vietnamese UI Copy |
|---|---|
| Start Learning | Bắt đầu học |
| Continue Learning | Tiếp tục học |
| Upload Material | Tải tài liệu lên |
| Submit for Review | Gửi duyệt |
| Pending Review | Đang chờ duyệt |
| Approved | Đã duyệt |
| Rejected | Bị từ chối |
| Needs Revision | Cần chỉnh sửa |
| No materials found | Không tìm thấy tài liệu phù hợp |
| You do not have permission | Bạn không có quyền truy cập trang này |

Technical identifiers in code may remain English, but user-facing labels must be Vietnamese.

Examples:

- Java class names, method names, DTO names, DAO names, database fields, routes, and CSS class names should remain English.
- JSP page titles, buttons, labels, helper text, validation messages, empty states, error states, loading states, and status labels should be Vietnamese.
- Font family names should remain as official font names, such as `Be Vietnam Pro`, `Plus Jakarta Sans`, and `Inter`.

## 40. Final Design Direction Summary

HIPZI should use the following design direction:

> Bright, friendly, soft, modern, AI-assisted, and trustworthy.

Student experience should feel:

> Motivating, simple, visual, and supportive.

Teacher experience should feel:

> Productive, creative, organized, and AI-assisted.

Staff experience should feel:

> Clear, efficient, structured, and moderation-focused.

Admin experience should feel:

> Professional, reliable, controlled, and governance-focused.

AI experience should feel:

> Helpful, transparent, review-based, and safe.

The most important UI/UX principle is:

> HIPZI should make learning feel easier while making content quality and platform governance feel clear and trustworthy.
