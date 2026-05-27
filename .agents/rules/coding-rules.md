---
trigger: always_on
---

# HIPZI Coding Rules

## 1. Purpose

This file defines coding rules for HIPZI.

The goal is to keep the project clean, maintainable, and consistent for both human developers and AI coding agents.

HIPZI uses:

- Java.
- Servlet.
- JSP.
- MVC.
- Service Layer.
- DAO Layer.
- Relational database.

---

## 2. Naming Rules

### 2.1 Servlet Naming

Servlet classes must end with `Servlet`.

Examples:

- `LoginServlet`
- `RegisterServlet`
- `TeacherApplicationServlet`
- `MaterialCreateServlet`
- `MaterialSubmitReviewServlet`
- `StaffMaterialApproveServlet`
- `AIQuizGenerateServlet`
- `QuizAttemptSubmitServlet`
- `AdminAssignRoleServlet`

Avoid:

- `MaterialController`
- `HandleMaterial`
- `ActionServlet`
- `ProcessData`

---

### 2.2 Service Naming

Service classes must end with `Service`.

Examples:

- `AuthService`
- `RolePermissionService`
- `TeacherApplicationService`
- `MaterialService`
- `MaterialModerationService`
- `AIContentService`
- `PracticeService`
- `AdminGovernanceService`
- `AuditLogService`

---

### 2.3 DAO Naming

DAO classes must end with `Dao`.

Examples:

- `UserDao`
- `RoleDao`
- `UserRoleDao`
- `TeacherApplicationDao`
- `MaterialDao`
- `AIContentDao`
- `QuizDao`
- `QuizAttemptDao`
- `AuditLogDao`

Use `Dao` consistently. Do not mix `DAO`, `Repository`, and `DataAccess` in the same project unless a decision log explicitly changes this rule.

---

### 2.4 Model Naming

Model classes use singular nouns.

Examples:

- `User`
- `Role`
- `TeacherApplication`
- `Material`
- `AIContent`
- `Quiz`
- `QuizQuestion`
- `QuizOption`
- `FlashcardSet`
- `Flashcard`
- `QuizAttempt`
- `LearningActivity`
- `AuditLog`

---

### 2.5 DTO Naming

Request DTOs should end with `Request`.

Response DTOs should end with `Response`.

Examples:

- `LoginRequest`
- `RegisterRequest`
- `MaterialCreateRequest`
- `TeacherApplicationRequest`
- `AIQuizGenerateRequest`
- `QuizSubmitRequest`
- `ApiResponse`
- `PaginationResponse`

---

### 2.6 JSP Naming

JSP files must use kebab-case.

Examples:

- `login.jsp`
- `register.jsp`
- `dashboard.jsp`
- `material-form.jsp`
- `material-detail.jsp`
- `application-status.jsp`
- `material-review-detail.jsp`
- `review-ai-content.jsp`
- `quiz-attempt.jsp`
- `quiz-result.jsp`

Avoid:

- `MaterialForm.jsp`
- `materialForm.jsp`
- `teacher_application.jsp`

---

## 3. Package Rules

Recommended Java package structure:

    com.hipzi.config
    com.hipzi.controller
    com.hipzi.controller.auth
    com.hipzi.controller.student
    com.hipzi.controller.teacher
    com.hipzi.controller.staff
    com.hipzi.controller.admin
    com.hipzi.controller.material
    com.hipzi.controller.ai
    com.hipzi.controller.practice
    com.hipzi.service
    com.hipzi.dao
    com.hipzi.model
    com.hipzi.dto
    com.hipzi.filter
    com.hipzi.util
    com.hipzi.exception
    com.hipzi.integration.ai

Rules:

- Put Servlets in `controller`.
- Put business logic in `service`.
- Put database access in `dao`.
- Put domain objects in `model`.
- Put request/response objects in `dto`.
- Put authentication filters in `filter`.
- Put reusable helpers in `util`.
- Put external integrations in `integration`.

---

## 4. Layer Responsibility Rules

### 4.1 JSP Layer

JSP should only render prepared data.

JSP must not:

- Query database.
- Create DAO.
- Create Service.
- Contain approval logic.
- Contain AI generation logic.
- Contain quiz scoring logic.
- Contain role assignment logic.

---

### 4.2 Servlet Layer

Servlet should handle request flow.

Servlet may:

- Read request parameters.
- Build DTO.
- Call Service.
- Set request attributes.
- Forward to JSP.
- Redirect after POST.
- Return JSON if needed.

Servlet must not:

- Write SQL.
- Implement complex business logic.
- Duplicate Service rules.
- Directly call DAO unless the project explicitly allows a very simple read-only route.

---

### 4.3 Service Layer

Service must contain business rules.

Service must check:

- Authentication context where needed.
- Role permissions.
- Ownership.
- Status transitions.
- Self-review prevention.
- Student visibility.
- AI draft rules.
- Audit log creation.

---

### 4.4 DAO Layer

DAO must contain database access only.

DAO may:

- Run SQL queries.
- Insert records.
- Update records.
- Map result sets to models.
- Return lists, optional records, or counts.

DAO must not:

- Decide if user can access a feature.
- Decide if Staff can approve material.
- Decide if Student can see content.
- Render UI.
- Read HTTP requests.

---

## 5. Status and Enum Rules

Workflow statuses must be centralized.

Recommended enums:

- `TeacherApplicationStatus`
- `MaterialStatus`
- `MaterialVisibility`
- `AIContentStatus`
- `QuizStatus`
- `QuizAttemptStatus`
- `ReportStatus`
- `EnrollmentStatus`

Do not hardcode status strings repeatedly.

Bad:

    if (status.equals("approved")) { ... }

Better:

    if (status == MaterialStatus.APPROVED) { ... }

If database stores lowercase strings, conversion should be centralized.

---

## 6. Error Handling Rules

Use consistent exception types.

Recommended exceptions:

- `ValidationException`
- `UnauthorizedException`
- `ForbiddenException`
- `NotFoundException`
- `ConflictException`
- `InvalidStatusTransitionException`
- `SelfReviewNotAllowedException`
- `AIServiceException`

Rules:

- Expected errors should show user-friendly messages.
- Unexpected errors should be logged.
- Stack traces must not be shown to users.
- Database errors must not expose SQL details.
- AI provider errors must not expose secrets.

---

## 7. Validation Rules

Validate on both frontend and backend.

Backend validation is mandatory.

Validate:

- Required fields.
- Field length.
- Email format.
- Enum values.
- UUID or ID format.
- Ownership.
- Role permission.
- Status transition.
- File type.
- File size.
- Duplicate submission.

Validation errors should be clear and field-specific when possible.

---

## 8. Database Rules

If using JDBC:

- Always use prepared statements.
- Never concatenate user input into SQL.
- Close connections, statements, and result sets safely.
- Use connection pooling if possible.
- Use transactions for multi-step changes.
- Keep SQL in DAO classes.
- Use database constraints for important uniqueness rules.

Transaction examples:

- Approve Teacher application and assign Teacher role.
- Approve material and create moderation action.
- Assign Staff role and create audit log.
- Submit quiz attempt and save answers.
- Generate AI content and create quiz records.

---

## 9. Security Rules

Security must be enforced on the backend.

Rules:

- Use `AuthenticationFilter` for protected routes.
- Use role filters for role-specific routes.
- Services must still check critical authorization.
- Do not trust hidden buttons in JSP.
- Do not trust JavaScript validation.
- Do not store plain-text passwords.
- Do not expose sensitive data in JSP.
- Do not expose stack traces.
- Do not expose private content through direct URL.

---

## 10. File Upload Rules

File upload must be safe.

Rules:

- Validate file type.
- Validate file size.
- Generate safe storage names.
- Store metadata in database.
- Store file content outside database.
- Do not execute uploaded files.
- Prevent access to private or unapproved files.
- Use object storage for production if possible.

---

## 11. AI Integration Rules

AI integration must be isolated.

Rules:

- Do not call AI provider directly from JSP.
- Do not call AI provider directly from Servlet.
- Use `AIProviderAdapter`.
- Store AI content as draft.
- Mark AI-assisted content.
- Require Teacher review.
- Prevent Student access before review.
- Log AI failures.
- Preserve source material reference.

---

## 12. Testing Rules

When implementing code, add or update tests when possible.

Priority test targets:

- Service tests.
- DAO tests.
- Servlet workflow tests.
- Critical manual JSP tests.

Test names should describe behavior.

Good:

- `shouldCreateMaterialWhenTeacherIsApproved`
- `shouldRejectMaterialUploadWhenTeacherIsNotApproved`
- `shouldBlockStaffSelfReview`
- `shouldReturnOnlyApprovedVisibleMaterialsForStudent`
- `shouldPreventDuplicateQuizSubmission`

Bad:

- `test1`
- `testMaterial`
- `testServlet`

---

## 13. Comment Rules

Use comments only when they add value.

Good comments explain:

- Why a rule exists.
- Why a workflow transition is restricted.
- Why a security check is required.
- Why a transaction is needed.

Avoid comments that simply repeat code.

---

## 14. Refactoring Rules

When refactoring:

- Do not change behavior unless requested.
- Preserve business rules.
- Preserve test expectations.
- Preserve route behavior.
- Preserve JSP data requirements.
- Update docs if behavior changes.
- Keep changes small and reviewable.

---
