# Skill: Fix Bug

## 1. Purpose

Use this skill when fixing a bug in HIPZI.

A bug may be related to:

- JSP rendering.
- Servlet request handling.
- Service business logic.
- DAO query.
- Database data.
- Role permissions.
- Student visibility.
- Staff moderation.
- AI generation.
- Quiz submission.
- Admin governance.
- CSS or JavaScript behavior.

---

## 2. Bug Fix Mindset

The AI agent must:

- Reproduce or understand the bug.
- Identify the affected layer.
- Find the smallest safe fix.
- Avoid breaking business rules.
- Add or update tests when possible.
- Check for regression risk.
- Update docs if the bug reveals unclear behavior.

---

## 3. Bug Analysis Checklist

Before fixing, answer:

1. What is the observed behavior?
2. What is the expected behavior?
3. Which user role is affected?
4. Which workflow is affected?
5. Is this a UI bug, backend bug, database bug, or rule bug?
6. Which docs define the expected behavior?
7. Which business rule is involved?
8. Which tests should catch this bug?
9. Is this bug a security risk?
10. Is this bug related to Student visibility or Staff self-review?

---

## 4. Layer Diagnosis Guide

### JSP Bug

Symptoms:

- Data not displayed.
- Wrong status badge.
- Wrong button visible.
- Form validation message missing.
- Layout broken.

Check:

- Request attributes.
- JSP condition.
- JSTL loop.
- CSS class.
- Shared layout include.

---

### Servlet Bug

Symptoms:

- Wrong redirect.
- Wrong JSP forward.
- Request parameter missing.
- POST action not working.
- Session not checked.
- Wrong Service called.

Check:

- URL mapping.
- `doGet` and `doPost`.
- Request parameter names.
- DTO construction.
- Redirect path.
- Error handling.

---

### Service Bug

Symptoms:

- Business rule not enforced.
- Wrong status transition.
- Unauthorized action allowed.
- Self-review allowed.
- Student sees hidden content.
- AI content published too early.
- Duplicate quiz submission allowed.

Check:

- Role checks.
- Ownership checks.
- Status transition logic.
- Visibility rule.
- Audit log creation.
- Transaction boundary.

---

### DAO Bug

Symptoms:

- Wrong data returned.
- Query missing filter.
- Insert/update fails.
- Duplicate data created.
- Student query shows hidden data.

Check:

- SQL query.
- Prepared statement parameters.
- WHERE clauses.
- Joins.
- Transaction behavior.
- Result mapping.

---

### Database Bug

Symptoms:

- Missing table.
- Wrong column.
- Constraint error.
- Invalid status value.
- Foreign key issue.

Check:

- Migration files.
- Seed data.
- Constraints.
- Indexes.
- Enum values.

---

## 5. Critical Bug Rules

If bug involves any of these, treat as high priority:

- Student can see unapproved content.
- Staff can approve own content.
- Teacher without approval can upload material.
- Staff can access Admin tools.
- Student can access another Student’s quiz attempt.
- AI content appears to Students before Teacher review.
- Quiz can be submitted twice.
- Password or sensitive data is exposed.
- Audit log is missing for sensitive action.

---

## 6. Fix Process

1. Identify affected workflow.
2. Read related docs.
3. Find affected files.
4. Write or identify failing test if possible.
5. Apply smallest safe fix.
6. Run or describe tests.
7. Check related edge cases.
8. Check if docs need update.
9. Summarize fix.

---

## 7. Regression Checklist

After fixing, verify:

- Authentication still works.
- Role access still works.
- Student visibility is still safe.
- Staff self-review is still blocked.
- AI draft rule still holds.
- Related workflow still works.
- No unrelated route was broken.
- Error handling remains safe.

---

## 8. Completion Response

When complete, summarize:

- Bug cause.
- Layer affected.
- Fix applied.
- Files changed.
- Tests added or recommended.
- Regression risks.
- Documentation updates if needed.

---

