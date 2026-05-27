---
description: 
---

# Workflow: Fix

## 1. Purpose

Use this workflow when fixing a bug in HIPZI.

---

## 2. Fix Process

### Step 1: Understand the Bug

Identify:

- Observed behavior.
- Expected behavior.
- Affected role.
- Affected workflow.
- Affected page or route.
- Severity.

---

### Step 2: Locate the Layer

Determine whether the bug is in:

- JSP.
- Servlet.
- Service.
- DAO.
- Database.
- CSS.
- JavaScript.
- Configuration.
- Test data.

---

### Step 3: Read Related Docs

Check:

- Business rule.
- Functional requirement.
- Acceptance criteria.
- Edge case.
- API/Servlet design.
- Testing strategy.

---

### Step 4: Find Root Cause

Look for:

- Missing role check.
- Missing ownership check.
- Wrong status transition.
- Missing visibility filter.
- Wrong DAO query.
- Wrong JSP condition.
- Wrong request parameter.
- Missing audit log.
- Incorrect redirect.

---

### Step 5: Apply Smallest Safe Fix

Rules:

- Do not rewrite unrelated code.
- Do not change business behavior unless required.
- Do not bypass docs.
- Do not add workaround in JSP for backend bug.
- Fix the layer where the bug truly belongs.

---

### Step 6: Add Regression Test

If possible, add a test that would fail before the fix and pass after the fix.

---

### Step 7: Verify Critical Rules

After fix, verify:

- Student visibility still safe.
- Staff self-review still blocked.
- AI draft rule still enforced.
- Role-based access still protected.
- Quiz duplicate submission still blocked.
- Audit logging still works.

---

### Step 8: Summarize

Final summary should include:

- Root cause.
- Fix applied.
- Files changed.
- Tests added or recommended.
- Regression risk.
- Docs update if needed.

---
