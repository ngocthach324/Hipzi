# Skill: Write Test

## 1. Purpose

Use this skill when writing or updating tests for HIPZI.

Tests should verify that HIPZI works correctly, safely, and consistently with its business rules.

---

## 2. Testing Priority

Prioritize tests for:

- Authentication.
- Role-based access.
- Teacher application workflow.
- Material upload.
- Staff moderation.
- Staff self-review prevention.
- Student visibility filtering.
- AI draft and Teacher review workflow.
- Quiz attempt submission.
- Duplicate submission prevention.
- Admin role assignment.
- Audit log creation.

---

## 3. Test Layer Selection

Choose test type based on the code being changed.

### Service Test

Use for:

- Business rules.
- Permission checks.
- Ownership checks.
- Status transitions.
- Audit log creation.
- AI draft rules.
- Quiz scoring.

### DAO Test

Use for:

- Database query correctness.
- Insert/update behavior.
- Student visibility query.
- Relationship mapping.
- Duplicate constraints.

### Servlet Test

Use for:

- Request handling.
- Session behavior.
- Role routing.
- Redirect/forward behavior.
- Form submission flow.

### Manual JSP Test

Use for:

- Page rendering.
- Forms.
- Status badges.
- Navigation.
- Empty states.
- Error states.

---

## 4. Test Naming Rules

Use descriptive names.

Good:

- `shouldCreateMaterialWhenTeacherIsApproved`
- `shouldRejectMaterialUploadWhenTeacherIsNotApproved`
- `shouldBlockStaffSelfReview`
- `shouldReturnOnlyApprovedVisibleMaterialsForStudent`
- `shouldPreventDuplicateQuizSubmission`
- `shouldCreateAuditLogWhenMaterialApproved`

Bad:

- `test1`
- `testMaterial`
- `testServlet`

---

## 5. Critical Test Cases

### Student Visibility

Test:

- Approved + visible material appears.
- Pending material does not appear.
- Rejected material does not appear.
- Hidden material does not appear.
- Archived material does not appear.
- Direct URL access is denied for unavailable material.

---

### Staff Self-Review

Test:

- Staff can approve another Teacher’s material.
- Staff cannot approve their own material.
- Staff cannot reject their own material.
- Self-review block creates audit log.

---

### AI Draft Rule

Test:

- AI quiz generation creates draft.
- AI flashcard generation creates draft.
- AI-assisted flag is stored.
- Student cannot access unreviewed AI content.
- Teacher review changes status correctly.

---

### Teacher Approval Rule

Test:

- Approved Teacher can upload material.
- Unapproved user cannot upload material.
- Rejected Teacher applicant cannot access Teacher tools.
- Staff approval grants Teacher role.

---

### Quiz Attempt Rule

Test:

- Student can start attempt.
- Student can submit answers.
- Score is calculated.
- Duplicate submit is blocked.
- Student cannot view another Student’s attempt.

---

### Admin Role Rule

Test:

- Admin can assign Staff role.
- Admin can revoke Staff role.
- Staff cannot assign roles.
- Role assignment creates audit log.

---

## 6. Test Data Rules

Use clear test data.

Examples:

- `studentUser`
- `teacherUser`
- `approvedTeacher`
- `staffUser`
- `adminUser`
- `pendingMaterial`
- `approvedVisibleMaterial`
- `hiddenMaterial`
- `aiDraftQuiz`
- `submittedAttempt`

Avoid ambiguous names like:

- `user1`
- `testMaterial`
- `abc`

---

## 7. Manual JSP Test Checklist

For JSP pages, verify:

- Page loads.
- Correct layout appears.
- Navigation is role-appropriate.
- Forms show validation errors.
- Status badges are correct.
- Buttons appear only when appropriate.
- Empty state appears when no data exists.
- Error state appears safely.
- POST success redirects properly.
- Page does not show unauthorized data.

---

## 8. Regression Rule

When fixing a bug, add a regression test if possible.

Example:

Bug:

    Student can access pending material through direct URL.

Regression test:

    shouldDenyStudentAccessToPendingMaterialByDirectUrl

---

## 9. Completion Response

When tests are written, summarize:

- Test files added or changed.
- Behaviors tested.
- Business rules covered.
- Any manual tests still required.
- Any untested risks.

---
