# 12-testing-strategy.md

# HIPZI Testing Strategy

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Testing Strategy |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md, 07-system-architecture.md, 08-database-design.md, 09-api-design.md, 10-non-functional-requirements.md, 11-tech-plan.md |
| Primary Audience | Developer, AI Coding Agent, QA Engineer, Backend Engineer, Frontend Engineer, Product Owner |
| Language | English |

---

## 1. Purpose

This document defines the testing strategy for HIPZI.

The purpose of this document is to describe how HIPZI should be tested to ensure that the system works correctly, safely, and consistently with its business rules.

This document focuses on:

- Testing scope.
- Testing principles.
- Unit testing.
- Service testing.
- DAO testing.
- Servlet testing.
- JSP manual testing.
- Role-based access testing.
- Staff moderation testing.
- AI workflow testing.
- Student visibility testing.
- Regression testing.
- MVP testing priorities.

This document does not define full test code. Test code should be implemented during engineering execution.

---

## 2. Testing Context

HIPZI is an AI-powered EdTech platform with multiple roles and workflow-heavy business logic.

The platform must ensure that:

- Students only access approved and visible learning content.
- Teachers can create learning content only after approval.
- Staff can moderate teacher applications and learning materials.
- Admins can assign roles and govern platform-level actions.
- Staff cannot review their own content if they also have Teacher role.
- AI-generated content starts as draft.
- AI-generated content requires Teacher review before Student access.
- Quiz attempts are scored correctly.
- Duplicate quiz submissions are prevented.
- Important Staff and Admin actions are auditable.

Because of this, testing must focus not only on whether pages load, but also on whether business rules are enforced correctly.

---

## 3. Testing Goals

HIPZI testing should achieve the following goals:

- Verify that all MVP workflows work correctly.
- Verify that role-based access is enforced.
- Verify that business rules are implemented in backend services.
- Verify that Student-facing content is properly filtered.
- Verify that Staff moderation actions update content state correctly.
- Verify that AI-generated content cannot bypass review rules.
- Verify that quiz attempts and scoring are reliable.
- Verify that audit logs are created for important actions.
- Verify that invalid or unauthorized actions fail safely.
- Verify that JSP pages display correct data and workflow states.

---

## 4. Testing Principles

### 4.1 Test Business Rules First

HIPZI’s most important tests should cover business rules.

Critical rules include:

- Only approved Teachers can upload materials.
- Staff cannot review their own materials.
- Students can only see approved and visible materials.
- AI-generated content must start as draft.
- AI-generated content requires Teacher review.
- Admin-only actions require Admin role.
- Quiz attempts cannot be submitted twice.

---

### 4.2 Backend Tests Are Mandatory

Frontend checks are not enough.

Even if JSP pages hide buttons, backend Services and Servlets must still reject unauthorized actions.

Testing must verify backend enforcement directly.

---

### 4.3 Test Happy Paths and Edge Cases

Each important feature should be tested with:

- Happy path.
- Missing data.
- Invalid role.
- Invalid ownership.
- Invalid status transition.
- Duplicate action.
- Unauthorized access.
- Self-review prevention.

---

### 4.4 Test by Layer

HIPZI should be tested by technical layer:

- Service layer tests.
- DAO tests.
- Servlet integration tests.
- JSP manual tests.
- End-to-end workflow tests.

---

### 4.5 Keep Tests Traceable

Tests should reference related documentation where possible.

Example:

| Test | Related Rule |
|---|---|
| Student cannot see pending material | BR-MAT-004, AC-MAT-003, EC-MAT-002 |
| Staff cannot approve own material | BR-STF-005, AC-STF-004, EC-STF-002 |
| AI content starts as draft | BR-AI-002, AC-AI-001, EC-AI-003 |

---

## 5. Testing Levels

## 5.1 Unit Tests

Unit tests should test small pieces of logic in isolation.

Recommended targets:

- Utility classes.
- Validation helpers.
- Status transition helpers.
- Permission helper methods.
- Score calculation logic.
- DTO validation logic.

Example unit test targets:

- `PasswordUtil`
- `ValidationUtil`
- `RolePermissionService`
- `QuizScoringService`
- `MaterialStatusValidator`
- `AIContentStatusValidator`

---

## 5.2 Service Layer Tests

Service tests are the most important tests for HIPZI.

Services contain business logic and must be tested carefully.

Recommended service tests:

- `AuthService`
- `RolePermissionService`
- `TeacherApplicationService`
- `MaterialService`
- `MaterialModerationService`
- `AIContentService`
- `PracticeService`
- `AdminGovernanceService`
- `AuditLogService`

Service tests should verify:

- Correct role checks.
- Correct ownership checks.
- Correct status transitions.
- Correct rejection of invalid actions.
- Correct audit log creation.
- Correct handling of edge cases.

---

## 5.3 DAO Tests

DAO tests should verify database behavior.

Recommended DAO tests:

- `UserDao`
- `RoleDao`
- `TeacherApplicationDao`
- `MaterialDao`
- `MaterialModerationActionDao`
- `AIContentDao`
- `QuizDao`
- `QuizAttemptDao`
- `LearningActivityDao`
- `AuditLogDao`

DAO tests should verify:

- Records are inserted correctly.
- Records are updated correctly.
- Queries filter data correctly.
- Student-visible material query excludes hidden content.
- Duplicate records are prevented where required.
- Foreign key relationships are respected.

---

## 5.4 Servlet Integration Tests

Servlet tests should verify request handling.

Servlet tests should cover:

- Correct route handling.
- Correct session authentication.
- Correct role authorization.
- Correct request parameter reading.
- Correct service method call.
- Correct redirect or forward behavior.
- Correct error response or error page.

Recommended Servlet tests:

- `LoginServlet`
- `TeacherApplicationServlet`
- `MaterialCreateServlet`
- `MaterialSubmitReviewServlet`
- `StaffMaterialApproveServlet`
- `StaffMaterialRejectServlet`
- `AIQuizGenerateServlet`
- `AIContentReviewServlet`
- `QuizSubmitServlet`
- `AdminAssignRoleServlet`

---

## 5.5 JSP Manual Testing

Because HIPZI uses JSP, some UI testing should be done manually in MVP.

Manual JSP tests should verify:

- Pages render correctly.
- Forms show validation errors.
- Role-specific navigation appears correctly.
- Unauthorized pages are not accessible.
- Workflow statuses are displayed clearly.
- Staff queues display correct items.
- Student pages hide unavailable materials.
- AI draft/review pages clearly show review status.
- Quiz pages display questions and results correctly.

---

## 5.6 End-to-End Workflow Tests

End-to-end tests should verify complete product flows.

Important MVP workflows:

1. User registers and logs in.
2. User submits Teacher application.
3. Staff approves Teacher application.
4. Approved Teacher uploads material.
5. Teacher submits material for review.
6. Staff approves material.
7. Student views approved material.
8. Teacher generates AI quiz.
9. Teacher reviews AI quiz.
10. Student starts quiz.
11. Student submits quiz.
12. Student sees result.
13. Admin assigns Staff role.
14. Staff cannot review own material.

---

## 6. MVP Test Scope

The MVP testing scope should include the following areas:

- Authentication.
- Role-based access.
- Teacher application workflow.
- Staff teacher application review.
- Admin role assignment.
- Material creation.
- Material submission for review.
- Staff material moderation.
- Student material browsing.
- AI quiz generation.
- AI flashcard generation.
- Teacher review of AI content.
- Student quiz practice.
- Student flashcard practice.
- Learning activity storage.
- Audit log creation.
- Critical edge cases.

---

## 7. Authentication Test Cases

### TC-AUTH-001: User Registration Works

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-001 |
| Test Type | Integration / Manual |

Steps:

1. Open registration page.
2. Enter valid email, password, and display name.
3. Submit form.

Expected result:

- User account is created.
- User receives default role according to platform policy.
- User can log in after registration.

---

### TC-AUTH-002: Duplicate Registration Is Rejected

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-001 |
| Related EC | EC-AUTH-001 |

Steps:

1. Register with an email.
2. Attempt to register again with the same email.

Expected result:

- Second registration is rejected.
- No duplicate user is created.
- Error message is displayed.

---

### TC-AUTH-003: Login Works With Valid Credentials

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-002 |

Expected result:

- User is authenticated.
- Session is created.
- User is redirected to the correct dashboard.

---

### TC-AUTH-004: Login Fails With Invalid Credentials

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-002 |

Expected result:

- Login fails.
- Session is not created.
- Error message does not reveal whether email or password is wrong.

---

## 8. Role-Based Access Test Cases

### TC-RBAC-001: Student Cannot Access Staff Dashboard

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-003 |
| Related EC | EC-AUTH-003 |

Steps:

1. Log in as Student.
2. Attempt to open `/staff/dashboard`.

Expected result:

- Access is denied.
- User sees 403 page or is redirected appropriately.

---

### TC-RBAC-002: Teacher Without Staff Role Cannot Access Moderation

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-003 |
| Related EC | EC-AUTH-004 |

Expected result:

- Teacher cannot access Staff moderation pages.
- Backend rejects request even if URL is entered manually.

---

### TC-RBAC-003: Staff Cannot Access Admin Tools

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-003 |
| Related EC | EC-AUTH-005 |

Expected result:

- Staff without Admin role cannot access Admin dashboard.
- Role assignment pages are forbidden.

---

### TC-RBAC-004: Admin Can Assign Staff Role

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AUTH-005, AC-ADM-002 |

Expected result:

- Admin assigns Staff role.
- User receives active Staff permission.
- Audit log is created.

---

## 9. Teacher Application Test Cases

### TC-TCH-001: User Submits Teacher Application

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-TCH-001 |

Expected result:

- Application is created.
- Status becomes `pending_review`.
- Application appears in Staff review queue.

---

### TC-TCH-002: Duplicate Teacher Application Is Rejected

| Field | Value |
|---|---|
| Priority | MVP |
| Related EC | EC-TCH-001 |

Expected result:

- System prevents duplicate active application.
- Existing application status is shown.

---

### TC-TCH-003: Staff Approves Teacher Application

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-STF-002 |

Expected result:

- Application status becomes `approved`.
- Applicant receives Teacher role.
- Audit log is created.

---

### TC-TCH-004: Staff Rejects Teacher Application

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-STF-002 |

Expected result:

- Application status becomes `rejected`.
- Applicant does not receive Teacher role.
- Rejection reason is stored.
- Audit log is created.

---

## 10. Material Test Cases

### TC-MAT-001: Approved Teacher Creates Material

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-MAT-001 |

Expected result:

- Material is created.
- Owner is current Teacher.
- Status is `draft`.
- Required metadata is stored.

---

### TC-MAT-002: Unapproved Teacher Cannot Create Material

| Field | Value |
|---|---|
| Priority | MVP |
| Related EC | EC-TCH-003 |

Expected result:

- Material creation is blocked.
- Error message explains Teacher approval is required.

---

### TC-MAT-003: Teacher Submits Material for Review

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-MAT-002 |

Expected result:

- Material status changes from `draft` to `pending_review`.
- Material appears in Staff review queue.

---

### TC-MAT-004: Student Cannot See Pending Material

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-MAT-003 |
| Related EC | EC-MAT-002 |

Expected result:

- Pending material does not appear in Student browsing.
- Direct URL access is denied or returns not found.

---

### TC-MAT-005: Staff Approves Material

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-STF-003, AC-MAT-003 |

Expected result:

- Material status becomes `approved`.
- Visibility becomes `visible` according to policy.
- Student can see material.
- Moderation action is recorded.
- Audit log is created.

---

### TC-MAT-006: Staff Rejects Material

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-STF-003 |

Expected result:

- Material status becomes `rejected`.
- Student cannot see material.
- Teacher can see rejection status and reason.
- Audit log is created.

---

### TC-MAT-007: Staff Cannot Approve Own Material

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-STF-004 |
| Related EC | EC-STF-002 |

Expected result:

- Approval is blocked.
- Material status does not change.
- Self-review block is logged.

---

## 11. AI Content Test Cases

### TC-AI-001: Teacher Generates AI Quiz Draft

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AI-001 |

Expected result:

- AI quiz is generated.
- AI content status is `generated_draft`.
- Quiz is marked AI-assisted.
- Quiz is not visible to Students before Teacher review.

---

### TC-AI-002: AI Generation Failure Does Not Publish Content

| Field | Value |
|---|---|
| Priority | MVP |
| Related EC | EC-AI-001 |

Expected result:

- Error is shown.
- No incomplete content is published.
- Existing material remains unchanged.
- Failure is logged.

---

### TC-AI-003: Teacher Reviews AI Content

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AI-003 |

Expected result:

- Teacher can edit and save AI content.
- Status changes to `teacher_reviewed`.
- AI-assisted metadata remains.

---

### TC-AI-004: Student Cannot Access Unreviewed AI Content

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-AI-004 |
| Related EC | EC-AI-003 |

Expected result:

- Unreviewed AI quiz or flashcards are not listed.
- Direct URL access is denied.

---

## 12. Student Practice Test Cases

### TC-PRAC-001: Student Starts Quiz Attempt

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-PRAC-001 |

Expected result:

- Quiz attempt is created.
- Attempt status is `started`.
- Student sees quiz questions.

---

### TC-PRAC-002: Student Submits Quiz Answers

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-PRAC-002, AC-PRAC-003 |

Expected result:

- Answers are recorded.
- Score is calculated.
- Attempt status becomes `scored`.
- Student sees result.

---

### TC-PRAC-003: Duplicate Quiz Submission Is Blocked

| Field | Value |
|---|---|
| Priority | MVP |
| Related EC | EC-PRAC-001 |

Expected result:

- Second submission is rejected.
- Score is not duplicated.
- Learning history remains consistent.

---

### TC-PRAC-004: Student Cannot View Another Student’s Attempt

| Field | Value |
|---|---|
| Priority | MVP |
| Related NFR | NFR-PRIV-002 |

Expected result:

- Access is denied.
- No other Student result data is exposed.

---

## 13. Search Test Cases

### TC-SEARCH-001: Search Returns Only Approved Materials

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-SEARCH-001 |
| Related EC | EC-SEARCH-001 |

Expected result:

- Search results include only approved and visible materials.
- Hidden, rejected, pending, archived, and draft materials are excluded.

---

### TC-SEARCH-002: No Search Results Shows Empty State

| Field | Value |
|---|---|
| Priority | MVP |
| Related EC | EC-SEARCH-002 |

Expected result:

- User sees clear empty state.
- No error occurs.

---

## 14. Admin Test Cases

### TC-ADM-001: Admin Assigns Staff Role

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-ADM-002 |

Expected result:

- Staff role is assigned.
- User can access Staff dashboard.
- Audit log is created.

---

### TC-ADM-002: Admin Revokes Staff Role

| Field | Value |
|---|---|
| Priority | MVP |
| Related AC | AC-ADM-002 |

Expected result:

- Staff role is revoked.
- User can no longer access Staff dashboard.
- Audit log is created.

---

### TC-ADM-003: Non-Admin Cannot Assign Role

| Field | Value |
|---|---|
| Priority | MVP |
| Related EC | EC-ADM-001 |

Expected result:

- Request is denied.
- No role changes are made.

---

## 15. Audit Log Test Cases

### TC-AUDIT-001: Material Approval Creates Audit Log

| Field | Value |
|---|---|
| Priority | MVP |
| Related NFR | NFR-OBS-002 |

Expected result:

- Audit log contains actor, action, target entity, previous status, new status, and timestamp.

---

### TC-AUDIT-002: Role Assignment Creates Audit Log

| Field | Value |
|---|---|
| Priority | MVP |
| Related NFR | NFR-OBS-002 |

Expected result:

- Role assignment is traceable in audit logs.

---

## 16. Regression Testing

Regression testing should be performed whenever core logic changes.

Critical regression areas:

- Authentication.
- Role permissions.
- Teacher approval.
- Material moderation.
- Student visibility filtering.
- Staff self-review prevention.
- AI content draft and review workflow.
- Quiz submission and scoring.
- Admin role assignment.
- Audit logging.

Regression tests should be run before every MVP release candidate.

---

## 17. Manual Testing Checklist for MVP

Before MVP release, manually verify:

- User can register.
- User can log in.
- User can log out.
- Student cannot access Staff pages.
- Staff cannot access Admin pages.
- User can submit Teacher application.
- Staff can approve Teacher application.
- Approved Teacher can upload material.
- Teacher can submit material for review.
- Staff can approve material.
- Student can see approved material.
- Student cannot see pending material.
- Teacher can generate AI quiz.
- AI quiz starts as draft.
- Teacher can review AI quiz.
- Student can practice quiz after review.
- Quiz result is shown.
- Duplicate quiz submit is blocked.
- Admin can assign Staff role.
- Audit logs are created for important actions.

---

## 18. Testing Tools Recommendation

Recommended tools:

| Testing Area | Tool |
|---|---|
| Unit testing | JUnit |
| Mocking | Mockito |
| DAO testing | JUnit with test database |
| API/manual testing | Postman or Bruno |
| Browser testing | Manual browser testing |
| Database inspection | SQL client |
| Build verification | Maven or Gradle test command |

---

## 19. MVP Testing Completion Criteria

MVP testing can be considered complete when:

- All critical MVP workflows pass.
- Role-based access is verified.
- Staff self-review prevention is verified.
- Student visibility filtering is verified.
- AI draft and Teacher review workflow is verified.
- Quiz submission and scoring are verified.
- Duplicate submissions are blocked.
- Admin role assignment is verified.
- Audit logs are created for important actions.
- Critical edge cases are tested.
- No known critical security or data integrity issue remains open.

---

## 20. Notes for AI Coding Agent

When implementing a feature, the AI coding agent should:

1. Read related business rules.
2. Read related functional requirements.
3. Read related acceptance criteria.
4. Read related edge cases.
5. Identify required tests.
6. Implement Service tests first when possible.
7. Implement Servlet or DAO tests where needed.
8. Verify JSP workflow manually if automated UI testing is not available.
9. Update this testing strategy if a new critical workflow is added.

---