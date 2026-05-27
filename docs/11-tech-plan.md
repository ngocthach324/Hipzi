# HIPZI Technical Plan

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Technical Plan |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md, 07-system-architecture.md, 08-database-design.md, 09-api-design.md, 10-non-functional-requirements.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Backend Engineer, Frontend Engineer, QA Engineer |
| Language | English |

---

## 1. Purpose

This document defines the technical implementation plan for HIPZI.

The purpose of this document is to translate HIPZI’s product requirements, architecture, database design, API design, and non-functional requirements into a practical engineering plan.

This document defines:

- Selected technology stack.
- Frontend implementation approach using JSP.
- Backend implementation approach using Java Servlet with MVC and Service Layer.
- Project structure.
- Module implementation plan.
- Development phases.
- Coding boundaries.
- AI Agent development workflow.
- Testing direction.
- Deployment direction.
- MVP implementation roadmap.

This document does not define detailed source code, exact database migrations, or final UI visual design. Those should be implemented during engineering execution.

---

## 2. Technical Direction

HIPZI will be developed as a Java web application using a traditional server-rendered architecture.

### 2.1 Frontend Direction

Frontend will be developed using:

- JSP.
- HTML.
- CSS.
- JavaScript.
- JSTL where needed.
- Reusable JSP fragments or includes.

JSP will be responsible for rendering pages such as:

- Student dashboard.
- Teacher dashboard.
- Staff moderation dashboard.
- Admin governance dashboard.
- Material detail pages.
- Quiz practice pages.
- AI-generated content review pages.

### 2.2 Backend Direction

Backend will be developed using:

- Java Servlet.
- MVC architecture.
- Service Layer.
- DAO or Repository Layer.
- JDBC or ORM depending on final implementation decision.
- Relational database, preferably PostgreSQL or MySQL.

The backend will be responsible for:

- Request handling.
- Authentication.
- Authorization.
- Business rule enforcement.
- Workflow state transitions.
- Database access.
- AI integration.
- File upload handling.
- Audit logging.

### 2.3 Architecture Style

HIPZI should use a modular monolith architecture.

The system will be deployed as one main Java web application, but internally separated into modules.

This is suitable for HIPZI because:

- The project is in MVP stage.
- JSP and Servlet fit well with an MVC monolith.
- Business logic can be centralized in Services.
- DAO/Repository classes can isolate database operations.
- Future modules can still be separated if the platform grows.

---

## 3. Selected Technology Stack

### 3.1 Frontend Stack

| Area | Technology |
|---|---|
| Page rendering | JSP |
| Markup | HTML |
| Styling | CSS |
| Client interaction | JavaScript |
| JSP helpers | JSTL |
| Reusable layout | JSP includes / fragments |
| Form validation | HTML validation + JavaScript + backend validation |

### 3.2 Backend Stack

| Area | Technology |
|---|---|
| Backend language | Java |
| Web layer | Servlet |
| Architecture | MVC |
| Business logic | Service Layer |
| Data access | DAO / Repository |
| Database access | JDBC or ORM |
| Authentication | Servlet Session or token-based approach |
| File upload | Servlet multipart upload |
| JSON handling | Jackson or equivalent library |
| Build tool | Maven or Gradle |
| Server | Apache Tomcat or compatible Servlet container |

### 3.3 Database Stack

| Area | Recommendation |
|---|---|
| Primary database | PostgreSQL or MySQL |
| Local development | PostgreSQL / MySQL / optional H2 for testing |
| File storage | Local storage for development, object storage for production |
| Migration tool | Flyway or Liquibase recommended |

### 3.4 Testing Stack

| Area | Recommendation |
|---|---|
| Unit testing | JUnit |
| Mocking | Mockito |
| Integration testing | JUnit + test database |
| Servlet testing | Mock request/response utilities or integration tests |
| UI testing | Manual first, automated later |
| API testing | Postman, Bruno, or automated integration tests |

---

## 4. Technical Architecture Overview

HIPZI should follow a classic MVC architecture with a Service Layer.

Recommended flow:

    Browser
    → JSP Page / HTML Form
    → Servlet Controller
    → Service Layer
    → DAO / Repository Layer
    → Database

For API-style interactions:

    Browser / JavaScript
    → Servlet API Controller
    → Service Layer
    → DAO / Repository Layer
    → Database
    → JSON Response

For AI generation:

    Teacher JSP Page
    → AI Generation Servlet
    → AIContentService
    → AI Provider Adapter
    → AI Content Stored as Draft
    → Teacher Review JSP Page

---

## 5. MVC Responsibility Separation

### 5.1 Model

The Model represents application data and domain objects.

Examples:

- `User`
- `Role`
- `TeacherApplication`
- `Material`
- `AIContent`
- `Quiz`
- `QuizQuestion`
- `FlashcardSet`
- `QuizAttempt`
- `LearningActivity`
- `AuditLog`

Models should not contain heavy business logic.

They should mainly represent data structure and basic domain attributes.

---

### 5.2 View

The View will be implemented using JSP.

JSP should be responsible for:

- Rendering HTML.
- Showing form fields.
- Showing validation messages.
- Displaying user-facing data.
- Including shared layouts.
- Showing role-specific navigation.
- Showing workflow status.

JSP should not contain complex business logic.

Avoid putting database queries, permission rules, or workflow transitions directly inside JSP files.

---

### 5.3 Controller

Controllers will be implemented using Servlets.

Servlets should be responsible for:

- Receiving HTTP requests.
- Reading request parameters.
- Validating basic request structure.
- Checking authentication where needed.
- Calling the correct Service method.
- Handling success or error result.
- Forwarding to JSP pages or returning JSON.
- Redirecting after successful form submission.

Servlets should not contain complex business logic.

---

### 5.4 Service Layer

The Service Layer contains business logic.

Services should enforce HIPZI rules such as:

- Only approved Teachers can upload materials.
- Staff cannot review their own content.
- Students can only access approved and visible content.
- AI-generated content must start as draft.
- Teacher review is required before AI content becomes Student-visible.
- Admin-only actions require Admin role.
- Quiz attempts cannot be submitted twice.

The Service Layer is the most important backend layer for business correctness.

---

### 5.5 DAO / Repository Layer

DAO or Repository classes handle database operations.

Responsibilities:

- Query data.
- Insert records.
- Update records.
- Delete or soft delete records.
- Map database rows to model objects.
- Keep SQL or ORM logic away from Servlets and JSP.

DAO classes should not contain high-level business rules.

---

## 6. Recommended Project Structure

Recommended Java web project structure:

    hipzi/
    ├── src/
    │   ├── main/
    │   │   ├── java/
    │   │   │   └── com/
    │   │   │       └── hipzi/
    │   │   │           ├── config/
    │   │   │           ├── controller/
    │   │   │           │   ├── auth/
    │   │   │           │   ├── student/
    │   │   │           │   ├── teacher/
    │   │   │           │   ├── staff/
    │   │   │           │   ├── admin/
    │   │   │           │   ├── material/
    │   │   │           │   ├── ai/
    │   │   │           │   └── practice/
    │   │   │           ├── service/
    │   │   │           ├── dao/
    │   │   │           ├── model/
    │   │   │           ├── dto/
    │   │   │           ├── filter/
    │   │   │           ├── util/
    │   │   │           ├── exception/
    │   │   │           └── integration/
    │   │   │               └── ai/
    │   │   ├── resources/
    │   │   │   ├── db/
    │   │   │   ├── application.properties
    │   │   │   └── logging.properties
    │   │   └── webapp/
    │   │       ├── WEB-INF/
    │   │       │   ├── views/
    │   │       │   │   ├── layout/
    │   │       │   │   ├── auth/
    │   │       │   │   ├── student/
    │   │       │   │   ├── teacher/
    │   │       │   │   ├── staff/
    │   │       │   │   ├── admin/
    │   │       │   │   ├── material/
    │   │       │   │   ├── ai/
    │   │       │   │   └── practice/
    │   │       │   └── web.xml
    │   │       ├── assets/
    │   │       │   ├── css/
    │   │       │   ├── js/
    │   │       │   └── images/
    │   │       └── index.jsp
    │   └── test/
    │       └── java/
    ├── docs/
    ├── pom.xml
    └── README.md

---

## 7. Package Responsibility

### 7.1 `controller`

Contains Servlet controllers.

Examples:

- `LoginServlet`
- `RegisterServlet`
- `TeacherApplicationServlet`
- `MaterialCreateServlet`
- `MaterialSubmitReviewServlet`
- `StaffMaterialApproveServlet`
- `AIQuizGenerationServlet`
- `QuizAttemptSubmitServlet`
- `AdminRoleServlet`

Servlets should be thin and should delegate business logic to Services.

---

### 7.2 `service`

Contains business logic.

Examples:

- `AuthService`
- `UserService`
- `RolePermissionService`
- `TeacherApplicationService`
- `MaterialService`
- `MaterialModerationService`
- `AIContentService`
- `QuizService`
- `PracticeService`
- `SearchService`
- `AdminGovernanceService`
- `AuditLogService`

Services should enforce business rules and workflow transitions.

---

### 7.3 `dao`

Contains database access logic.

Examples:

- `UserDao`
- `RoleDao`
- `TeacherApplicationDao`
- `MaterialDao`
- `MaterialModerationActionDao`
- `AIContentDao`
- `QuizDao`
- `FlashcardDao`
- `QuizAttemptDao`
- `LearningActivityDao`
- `AuditLogDao`

DAO classes should return Models or DTOs and should not handle request/response logic.

---

### 7.4 `model`

Contains domain models.

Examples:

- `User`
- `Role`
- `TeacherProfile`
- `TeacherApplication`
- `Subject`
- `Material`
- `AIContent`
- `Quiz`
- `QuizQuestion`
- `QuizOption`
- `FlashcardSet`
- `Flashcard`
- `QuizAttempt`
- `AuditLog`

---

### 7.5 `dto`

Contains request and response DTOs.

Examples:

- `LoginRequest`
- `RegisterRequest`
- `MaterialCreateRequest`
- `TeacherApplicationRequest`
- `AIQuizGenerateRequest`
- `QuizSubmitRequest`
- `ApiResponse`
- `PaginationResponse`

DTOs help avoid exposing database models directly to the frontend or API responses.

---

### 7.6 `filter`

Contains Servlet filters.

Recommended filters:

- `AuthenticationFilter`
- `AuthorizationFilter`
- `AdminOnlyFilter`
- `StaffOnlyFilter`
- `TeacherOnlyFilter`
- `EncodingFilter`
- `LoggingFilter`

Filters should enforce cross-cutting concerns such as authentication and role-based access.

---

### 7.7 `integration`

Contains external service adapters.

Examples:

- `AIProviderClient`
- `AIProviderAdapter`
- `FileStorageAdapter`
- `EmailAdapter`

This helps avoid coupling business logic directly to external vendors.

---

### 7.8 `util`

Contains shared utilities.

Examples:

- `PasswordUtil`
- `ValidationUtil`
- `DateTimeUtil`
- `FileUploadUtil`
- `JsonUtil`
- `SlugUtil`

Utilities should remain generic and should not contain business rules.

---

## 8. JSP View Structure

JSP views should be organized by role and feature.

Recommended JSP structure:

    WEB-INF/views/
    ├── layout/
    │   ├── header.jsp
    │   ├── footer.jsp
    │   ├── sidebar.jsp
    │   └── main-layout.jsp
    ├── auth/
    │   ├── login.jsp
    │   └── register.jsp
    ├── student/
    │   ├── dashboard.jsp
    │   ├── materials.jsp
    │   ├── material-detail.jsp
    │   ├── quiz-attempt.jsp
    │   ├── quiz-result.jsp
    │   └── flashcards.jsp
    ├── teacher/
    │   ├── dashboard.jsp
    │   ├── application.jsp
    │   ├── application-status.jsp
    │   ├── materials.jsp
    │   ├── material-form.jsp
    │   └── material-status.jsp
    ├── staff/
    │   ├── dashboard.jsp
    │   ├── teacher-applications.jsp
    │   ├── teacher-application-detail.jsp
    │   ├── material-review-queue.jsp
    │   └── material-review-detail.jsp
    ├── admin/
    │   ├── dashboard.jsp
    │   ├── users.jsp
    │   ├── user-detail.jsp
    │   ├── subjects.jsp
    │   └── audit-logs.jsp
    ├── ai/
    │   ├── generate-quiz.jsp
    │   ├── generate-flashcards.jsp
    │   └── review-ai-content.jsp
    └── error/
        ├── 403.jsp
        ├── 404.jsp
        └── 500.jsp

Important rule:

> JSP files should render data prepared by Servlets and Services.  
> JSP files should not query the database directly.

---

## 9. Request Flow Examples

### 9.1 Login Flow

    User opens login.jsp
    → LoginServlet receives POST request
    → AuthService validates credentials
    → UserDao loads user data
    → AuthService creates session
    → Servlet redirects user to role-based dashboard

---

### 9.2 Teacher Application Submission Flow

    User opens teacher/application.jsp
    → TeacherApplicationServlet receives POST request
    → TeacherApplicationService validates request
    → TeacherApplicationDao creates application
    → AuditLogService logs submission if needed
    → Servlet redirects to application-status.jsp

---

### 9.3 Material Upload Flow

    Approved Teacher opens teacher/material-form.jsp
    → MaterialCreateServlet receives POST request
    → MaterialService verifies approved Teacher status
    → MaterialService validates material fields
    → MaterialDao saves material as draft
    → Servlet redirects to teacher/materials.jsp

---

### 9.4 Material Submit Review Flow

    Teacher clicks Submit for Review
    → MaterialSubmitReviewServlet receives POST request
    → MaterialService verifies ownership
    → MaterialService validates material completeness
    → MaterialService changes status to pending_review
    → MaterialDao updates material
    → Servlet redirects to material status page

---

### 9.5 Staff Material Approval Flow

    Staff opens material-review-detail.jsp
    → StaffMaterialApproveServlet receives POST request
    → MaterialModerationService verifies Staff role
    → MaterialModerationService checks self-review prevention
    → MaterialModerationService changes status to approved
    → MaterialModerationActionDao logs moderation action
    → AuditLogService logs approval
    → Servlet redirects to Staff review queue

---

### 9.6 AI Quiz Generation Flow

    Teacher opens AI quiz generation page
    → AIQuizGenerationServlet receives POST request
    → AIContentService verifies Teacher access to material
    → AIContentService calls AIProviderAdapter
    → AIContentService stores AI content as generated_draft
    → QuizDao stores generated quiz and questions
    → Servlet redirects to AI content review page

---

### 9.7 Student Quiz Practice Flow

    Student opens approved quiz
    → QuizAttemptStartServlet creates quiz attempt
    → quiz-attempt.jsp displays questions
    → QuizAttemptSubmitServlet receives answers
    → PracticeService verifies attempt ownership
    → PracticeService prevents duplicate submission
    → PracticeService calculates score
    → QuizAttemptDao stores result
    → Servlet forwards to quiz-result.jsp

---

## 10. Core Backend Services

### 10.1 `AuthService`

Responsibilities:

- Register user.
- Login user.
- Logout user.
- Validate credentials.
- Manage session information.
- Check account status.

Important rules:

- Do not store plain-text passwords.
- Disabled or suspended users cannot access protected features.
- Invalid login responses should not reveal sensitive details.

---

### 10.2 `RolePermissionService`

Responsibilities:

- Check user roles.
- Check active role assignment.
- Determine whether user is Student, Teacher, Staff, Admin, or Parent.
- Enforce role-based permission rules.
- Support multi-role users.
- Support Admin role assignment.

Important rules:

- Teacher and Staff roles are separate by default.
- Admin must explicitly assign Staff role.
- Backend authorization is mandatory.

---

### 10.3 `TeacherApplicationService`

Responsibilities:

- Submit Teacher application.
- Prevent duplicate active applications.
- View application status.
- Allow Staff review.
- Approve application.
- Reject application.
- Grant Teacher role after approval.

Important rules:

- Staff cannot approve their own application.
- Rejected users do not receive Teacher permissions.
- Approved users receive Teacher permissions.

---

### 10.4 `MaterialService`

Responsibilities:

- Create material.
- Update material.
- Validate material fields.
- Check material ownership.
- Submit material for review.
- List Teacher-owned materials.
- List Student-visible materials.
- Enforce material visibility.

Important rules:

- Only approved Teachers can create materials.
- Student-facing material queries must return only approved and visible materials.
- Teacher cannot edit another Teacher’s material.

---

### 10.5 `MaterialModerationService`

Responsibilities:

- List pending materials.
- Approve material.
- Reject material.
- Request revision.
- Hide material.
- Archive material.
- Create moderation action record.
- Create audit logs.

Important rules:

- Staff role is required.
- Staff cannot review their own material.
- Material status transitions must be valid.
- Student visibility must update after moderation decision.

---

### 10.6 `AIContentService`

Responsibilities:

- Generate AI quiz draft.
- Generate AI flashcard draft.
- Store AI content metadata.
- Mark AI content as AI-assisted.
- Allow Teacher review.
- Discard AI content.
- Prevent Student access before required review.

Important rules:

- AI output starts as draft.
- Teacher review is required.
- Staff review may be required by policy.
- AI content must not be published directly to Students.

---

### 10.7 `PracticeService`

Responsibilities:

- Start quiz attempt.
- Submit quiz answers.
- Prevent duplicate submission.
- Calculate score.
- Store quiz attempt.
- Store learning activity.
- Return quiz result.

Important rules:

- Student can only submit their own attempt.
- Quiz must be available.
- Invalid evaluation rules must not produce invalid score.
- Retakes should create new attempts.

---

### 10.8 `AdminGovernanceService`

Responsibilities:

- List users.
- Assign roles.
- Revoke roles.
- Manage subjects.
- View audit logs.
- Override Staff decisions in Phase 2.

Important rules:

- Admin role is required.
- Role changes should create audit logs.
- Staff role assignment does not disable self-review prevention.

---

### 10.9 `AuditLogService`

Responsibilities:

- Create audit logs.
- Store actor, action, target entity, old value, new value, reason, and timestamp.
- Support future Admin audit dashboard.

Important actions to log:

- Role assignment.
- Staff role revocation.
- Teacher application approval.
- Teacher application rejection.
- Material approval.
- Material rejection.
- Material revision request.
- Material hide.
- Material archive.
- Admin override.
- Self-review blocked.

---

## 11. DAO Layer Plan

DAO classes should isolate database access from business logic.

### 11.1 Required MVP DAOs

- `UserDao`
- `RoleDao`
- `UserRoleDao`
- `StudentProfileDao`
- `TeacherProfileDao`
- `TeacherApplicationDao`
- `SubjectDao`
- `MaterialDao`
- `MaterialFileDao`
- `MaterialModerationActionDao`
- `AIContentDao`
- `QuizDao`
- `QuizQuestionDao`
- `QuizOptionDao`
- `FlashcardSetDao`
- `FlashcardDao`
- `QuizAttemptDao`
- `QuizAttemptAnswerDao`
- `LearningActivityDao`
- `AuditLogDao`

### 11.2 DAO Rules

DAO classes should:

- Use prepared statements if using JDBC.
- Avoid SQL injection.
- Return domain models or DTOs.
- Keep database logic out of Servlets.
- Keep business logic out of DAO classes.
- Support transactions when needed.

---

## 12. Database Implementation Plan

### 12.1 MVP Database Tables

The MVP should implement these tables first:

- `users`
- `roles`
- `user_roles`
- `student_profiles`
- `teacher_profiles`
- `teacher_applications`
- `subjects`
- `materials`
- `material_files`
- `material_moderation_actions`
- `ai_contents`
- `quizzes`
- `quiz_questions`
- `quiz_options`
- `flashcard_sets`
- `flashcards`
- `quiz_attempts`
- `quiz_attempt_answers`
- `learning_activities`
- `audit_logs`

### 12.2 Database Migration Plan

Recommended approach:

- Use Flyway or Liquibase.
- Store migration files in `src/main/resources/db/migration`.
- Keep database schema versioned.
- Avoid manual production database edits.

Example migration order:

    V1__create_users_and_roles.sql
    V2__create_profiles.sql
    V3__create_teacher_applications.sql
    V4__create_subjects.sql
    V5__create_materials.sql
    V6__create_ai_content.sql
    V7__create_quizzes_and_flashcards.sql
    V8__create_quiz_attempts.sql
    V9__create_audit_logs.sql

---

## 13. Authentication and Session Plan

### 13.1 Session-Based Authentication

For JSP and Servlet architecture, session-based authentication is a practical MVP choice.

Recommended approach:

- On successful login, store authenticated user ID in session.
- Store active roles in session or load them per request.
- Use `AuthenticationFilter` to protect authenticated routes.
- Use role-specific filters or helper methods for authorization.
- Clear session on logout.

### 13.2 Session Data

Session may store:

- `currentUserId`
- `displayName`
- `roles`
- `isAuthenticated`

Do not store sensitive data in session.

### 13.3 Authorization Checks

Authorization should be checked in:

- Filters for route-level protection.
- Services for business-level protection.
- DAO queries for safe data filtering when needed.

---

## 14. Servlet Routing Plan

### 14.1 Auth Routes

| Servlet | Path | Purpose |
|---|---|---|
| `RegisterServlet` | `/register` | Register user |
| `LoginServlet` | `/login` | Login user |
| `LogoutServlet` | `/logout` | Logout user |
| `CurrentUserServlet` | `/me` | Current user data if JSON needed |

---

### 14.2 Student Routes

| Servlet | Path | Purpose |
|---|---|---|
| `StudentDashboardServlet` | `/student/dashboard` | Student dashboard |
| `MaterialBrowseServlet` | `/materials` | Browse approved materials |
| `MaterialDetailServlet` | `/materials/detail` | View material detail |
| `QuizStartServlet` | `/practice/quiz/start` | Start quiz attempt |
| `QuizSubmitServlet` | `/practice/quiz/submit` | Submit quiz answers |
| `QuizResultServlet` | `/practice/quiz/result` | View quiz result |
| `FlashcardPracticeServlet` | `/practice/flashcards` | Practice flashcards |

---

### 14.3 Teacher Routes

| Servlet | Path | Purpose |
|---|---|---|
| `TeacherDashboardServlet` | `/teacher/dashboard` | Teacher dashboard |
| `TeacherApplicationServlet` | `/teacher/application` | Submit teacher application |
| `TeacherApplicationStatusServlet` | `/teacher/application/status` | View application status |
| `TeacherMaterialListServlet` | `/teacher/materials` | List own materials |
| `MaterialCreateServlet` | `/teacher/materials/create` | Create material |
| `MaterialEditServlet` | `/teacher/materials/edit` | Edit material |
| `MaterialSubmitReviewServlet` | `/teacher/materials/submit-review` | Submit material for review |
| `AIQuizGenerateServlet` | `/teacher/ai/generate-quiz` | Generate AI quiz |
| `AIFlashcardGenerateServlet` | `/teacher/ai/generate-flashcards` | Generate AI flashcards |
| `AIContentReviewServlet` | `/teacher/ai/review` | Review AI content |

---

### 14.4 Staff Routes

| Servlet | Path | Purpose |
|---|---|---|
| `StaffDashboardServlet` | `/staff/dashboard` | Staff dashboard |
| `StaffTeacherApplicationListServlet` | `/staff/teacher-applications` | List applications |
| `StaffTeacherApplicationDetailServlet` | `/staff/teacher-applications/detail` | Review application |
| `StaffTeacherApplicationApproveServlet` | `/staff/teacher-applications/approve` | Approve application |
| `StaffTeacherApplicationRejectServlet` | `/staff/teacher-applications/reject` | Reject application |
| `StaffMaterialQueueServlet` | `/staff/materials` | Material review queue |
| `StaffMaterialDetailServlet` | `/staff/materials/detail` | Material review detail |
| `StaffMaterialApproveServlet` | `/staff/materials/approve` | Approve material |
| `StaffMaterialRejectServlet` | `/staff/materials/reject` | Reject material |
| `StaffMaterialRevisionServlet` | `/staff/materials/request-revision` | Request revision |
| `StaffMaterialHideServlet` | `/staff/materials/hide` | Hide material |
| `StaffMaterialArchiveServlet` | `/staff/materials/archive` | Archive material |

---

### 14.5 Admin Routes

| Servlet | Path | Purpose |
|---|---|---|
| `AdminDashboardServlet` | `/admin/dashboard` | Admin dashboard |
| `AdminUserListServlet` | `/admin/users` | User management |
| `AdminUserDetailServlet` | `/admin/users/detail` | User detail |
| `AdminAssignRoleServlet` | `/admin/users/assign-role` | Assign role |
| `AdminRevokeRoleServlet` | `/admin/users/revoke-role` | Revoke role |
| `AdminSubjectListServlet` | `/admin/subjects` | Manage subjects |
| `AdminSubjectCreateServlet` | `/admin/subjects/create` | Create subject |
| `AdminSubjectEditServlet` | `/admin/subjects/edit` | Edit subject |
| `AdminAuditLogServlet` | `/admin/audit-logs` | Audit logs in Phase 2 |

---

## 15. JSP and Servlet Form Handling Pattern

### 15.1 Recommended Pattern

For form-based JSP workflows:

    GET Servlet
    → Load required data
    → Forward to JSP

    POST Servlet
    → Read request parameters
    → Validate input
    → Call Service
    → On success, redirect
    → On failure, forward back to JSP with errors

### 15.2 Why Redirect After POST

After successful POST, use redirect to avoid duplicate form submission on page refresh.

Recommended pattern:

    POST success
    → response.sendRedirect(...)

This follows the Post/Redirect/Get pattern.

---

## 16. API and JSP Coexistence Plan

HIPZI can use both:

- JSP-rendered pages for main user flows.
- JSON endpoints for dynamic UI interactions where needed.

### 16.1 JSP-Rendered Flows

Recommended for MVP:

- Login.
- Register.
- Student material browsing.
- Teacher application.
- Teacher material management.
- Staff moderation.
- Admin user management.
- Quiz practice.

### 16.2 JSON Endpoints

Useful for:

- AI generation progress.
- Search suggestions.
- Dynamic quiz submission if needed.
- Dashboard statistics.
- Future personalization.
- Future notifications.

Do not overcomplicate MVP with too many JSON APIs if JSP form flows are sufficient.

---

## 17. AI Integration Plan

### 17.1 AI Provider Adapter

AI integration should be isolated behind an adapter.

Recommended classes:

- `AIProviderAdapter`
- `AIQuizGenerationRequest`
- `AIQuizGenerationResult`
- `AIFlashcardGenerationRequest`
- `AIFlashcardGenerationResult`

The rest of the system should not depend directly on the AI provider’s API.

### 17.2 AI Generation Rules

AI generation must follow HIPZI rules:

- Only approved Teachers can generate AI content from eligible materials.
- AI output must be saved as draft.
- AI-assisted metadata must be stored.
- Teacher review is required.
- Student access is blocked until review requirements are completed.

### 17.3 AI Failure Handling

If AI generation fails:

- Show clear error to Teacher.
- Do not publish generated output.
- Do not damage source material.
- Log AI failure.
- Allow retry where appropriate.

---

## 18. File Upload Plan

### 18.1 MVP File Upload

For MVP, file upload may use Servlet multipart upload.

Uploaded files should be:

- Validated by file type.
- Validated by file size.
- Stored in local development storage or object storage.
- Referenced in `material_files`.
- Protected from unauthorized access.

### 18.2 Production File Storage

For production, files should not rely only on local server storage.

Recommended future production approach:

- Object storage.
- File metadata in database.
- Private access URLs when needed.
- Malware scanning if infrastructure supports it.

---

## 19. Security Implementation Plan

### 19.1 Authentication Filter

`AuthenticationFilter` should protect authenticated routes.

Protected route examples:

- `/student/*`
- `/teacher/*`
- `/staff/*`
- `/admin/*`
- `/practice/*`

### 19.2 Role Filters

Recommended filters:

- `TeacherOnlyFilter`
- `StaffOnlyFilter`
- `AdminOnlyFilter`

However, route-level filters are not enough. Services must still enforce critical rules.

### 19.3 Service-Level Authorization

Service methods must check business-level rules.

Examples:

- `MaterialService.createMaterial()` checks approved Teacher status.
- `MaterialModerationService.approveMaterial()` checks Staff role and self-review rule.
- `AdminGovernanceService.assignRole()` checks Admin role.
- `PracticeService.submitAttempt()` checks attempt ownership.

---

## 20. Validation Plan

Validation should happen at multiple levels.

### 20.1 Frontend Validation

JSP and JavaScript can provide basic validation for user experience.

Examples:

- Required fields.
- Basic email format.
- File size preview.
- Empty form prevention.

### 20.2 Backend Validation

Backend validation is mandatory.

Backend must validate:

- Required fields.
- Field types.
- Enum values.
- Ownership.
- Role permissions.
- Status transitions.
- File upload constraints.

Frontend validation must not be trusted as the only validation layer.

---

## 21. Error Handling Plan

### 21.1 User-Facing Errors

JSP pages should show clear user-facing errors.

Examples:

- Invalid email or password.
- Required fields are missing.
- You do not have permission.
- Material is no longer available.
- AI generation failed.
- Quiz cannot be submitted twice.

### 21.2 System Errors

Unexpected errors should:

- Be logged internally.
- Show a safe error page.
- Not expose stack traces to users.
- Preserve existing data.

Recommended error pages:

- `403.jsp`
- `404.jsp`
- `500.jsp`

---

## 22. Audit Logging Plan

Audit logging should be included from MVP for key governance actions.

### 22.1 Actions to Audit

- Assign role.
- Revoke role.
- Approve Teacher application.
- Reject Teacher application.
- Approve material.
- Reject material.
- Request material revision.
- Hide material.
- Archive material.
- Block self-review attempt.
- Admin override in Phase 2.

### 22.2 Audit Log Fields

Recommended fields:

- Actor user ID.
- Actor role.
- Action.
- Target entity type.
- Target entity ID.
- Previous value.
- New value.
- Reason.
- Timestamp.

---

## 23. Testing Plan Overview

Detailed testing strategy should be defined in `12-testing-strategy.md`.

### 23.1 MVP Test Focus

MVP testing should focus on:

- Authentication.
- Role-based access.
- Teacher application workflow.
- Staff moderation workflow.
- Staff self-review prevention.
- Admin role assignment.
- Material upload and status transitions.
- Student visibility filtering.
- AI draft generation and Teacher review.
- Quiz attempt submission.
- Duplicate quiz submission prevention.
- Audit log creation.

### 23.2 Recommended Test Types

- Unit tests for services.
- DAO tests for database queries.
- Integration tests for Servlet workflows.
- Manual UI tests for JSP pages.
- Security tests for unauthorized access.
- Regression tests for critical business rules.

---

## 24. Development Phase Plan

### 24.1 Phase 0: Project Setup

Goals:

- Create Java web project.
- Configure Maven or Gradle.
- Configure Servlet container.
- Set up JSP structure.
- Set up database connection.
- Set up base packages.
- Set up error pages.
- Set up common layout.

Deliverables:

- Running Java web application.
- Basic home page.
- Database connection working.
- Basic project structure complete.

---

### 24.2 Phase 1: Authentication and Roles

Goals:

- Implement registration.
- Implement login.
- Implement logout.
- Implement session management.
- Implement roles.
- Implement role filters.

Deliverables:

- User can register.
- User can log in and log out.
- Role-based route protection works.
- Admin can be seeded manually or through database script.

---

### 24.3 Phase 2: Teacher Application Workflow

Goals:

- Implement Teacher application form.
- Implement Teacher application status page.
- Implement Staff application review queue.
- Implement Staff approve and reject actions.
- Grant Teacher role on approval.

Deliverables:

- User can apply to become Teacher.
- Staff can approve or reject application.
- Approved user gains Teacher permissions.
- Rejected user does not gain Teacher permissions.
- Audit logs are created.

---

### 24.4 Phase 3: Material Upload and Moderation

Goals:

- Implement Teacher material creation.
- Implement material file upload.
- Implement material submit for review.
- Implement Staff material review queue.
- Implement approve, reject, request revision, hide, and archive.
- Implement Student material browsing.

Deliverables:

- Approved Teacher can upload material.
- Staff can moderate material.
- Students see only approved and visible materials.
- Teacher can revise rejected or needs-revision materials.
- Staff self-review prevention works.

---

### 24.5 Phase 4: AI Quiz and Flashcard Generation

Goals:

- Implement AI provider adapter.
- Implement AI quiz generation.
- Implement AI flashcard generation.
- Store AI-generated content as draft.
- Implement Teacher AI content review page.
- Prevent unreviewed AI content from Student access.

Deliverables:

- Teacher can generate AI quiz draft.
- Teacher can generate AI flashcard draft.
- Teacher can review and edit AI output.
- AI-assisted content is traceable.
- Students cannot access unreviewed AI content.

---

### 24.6 Phase 5: Student Practice

Goals:

- Implement quiz listing for approved materials.
- Implement quiz attempt start.
- Implement quiz answer submission.
- Implement scoring.
- Implement quiz result page.
- Implement flashcard practice.
- Store learning activity.

Deliverables:

- Student can start quiz.
- Student can submit answers.
- System calculates score.
- Student sees feedback.
- Quiz attempt is stored.
- Flashcards are usable.
- Duplicate submission is blocked.

---

### 24.7 Phase 6: Admin Governance

Goals:

- Implement Admin dashboard.
- Implement user management.
- Implement role assignment and revocation.
- Implement subject management.
- Implement basic audit log viewing.

Deliverables:

- Admin can assign Staff role.
- Admin can revoke Staff role.
- Admin can manage subjects.
- Admin can view important audit logs.
- Staff cannot access Admin tools.

---

### 24.8 Phase 7: Polish, Testing, and MVP Release

Goals:

- Improve UI consistency.
- Improve error handling.
- Add missing validation.
- Add tests.
- Fix critical bugs.
- Review docs and implementation traceability.
- Prepare MVP deployment.

Deliverables:

- MVP feature set complete.
- Critical workflows tested.
- Known issues documented.
- Release candidate ready.

---

## 25. MVP Implementation Priority

The MVP should prioritize features in this order:

1. Project setup.
2. Authentication and sessions.
3. Role-based access.
4. Admin role seeding.
5. Teacher application workflow.
6. Staff application review.
7. Material upload.
8. Staff material moderation.
9. Student material browsing.
10. AI quiz generation.
11. AI flashcard generation.
12. Teacher AI content review.
13. Student quiz practice.
14. Student flashcard practice.
15. Learning activity.
16. Audit logs.
17. Basic Admin governance.

---

## 26. AI Coding Agent Workflow

When using an AI coding agent, the agent should follow this workflow:

1. Read relevant documentation before coding.
2. Identify related business rules.
3. Identify related functional requirements.
4. Identify related user flows.
5. Identify related acceptance criteria.
6. Identify related edge cases.
7. Check database entities involved.
8. Check API or Servlet route involved.
9. Implement Controller, Service, DAO, Model, and JSP changes.
10. Add or update tests where possible.
11. Update documentation if behavior changes.
12. Summarize what was changed.

Example for material approval:

- Read `02-business-rules.md`.
- Read `03-functional-requirements.md`.
- Read `04-user-flow.md`.
- Read `05-acceptance-criteria.md`.
- Read `06-edge-cases.md`.
- Check `materials`, `material_moderation_actions`, and `audit_logs`.
- Implement `StaffMaterialApproveServlet`.
- Implement `MaterialModerationService.approveMaterial()`.
- Implement `MaterialDao.updateStatus()`.
- Implement audit log creation.
- Update Staff JSP page.

---

## 27. Coding Conventions

Detailed coding conventions should be defined in `13-engineering-conventions.md`.

Recommended conventions:

- Servlet classes end with `Servlet`.
- Service classes end with `Service`.
- DAO classes end with `Dao`.
- Model classes use singular nouns.
- JSP files use kebab-case.
- Constants should be centralized.
- Status values should not be hardcoded repeatedly.
- Business rules should not be duplicated across Servlets.
- SQL queries should use prepared statements.
- JSP should not contain database logic.

---

## 28. Technical Risks

### 28.1 Risk: Business Logic Placed Inside JSP

| Field | Value |
|---|---|
| Risk | JSP files may become difficult to maintain if they contain business logic. |
| Impact | System becomes hard to debug and unsafe. |
| Mitigation | Keep JSP focused on rendering. Put business logic in Services. |

---

### 28.2 Risk: Servlets Become Too Large

| Field | Value |
|---|---|
| Risk | Servlet controllers may contain validation, business logic, and database code together. |
| Impact | Code becomes hard to test and maintain. |
| Mitigation | Keep Servlets thin. Delegate to Services and DAOs. |

---

### 28.3 Risk: Permission Checks Are Inconsistent

| Field | Value |
|---|---|
| Risk | Some routes may forget to check roles or ownership. |
| Impact | Unauthorized access may occur. |
| Mitigation | Use filters and service-level authorization. |

---

### 28.4 Risk: Student Visibility Filtering Is Missed

| Field | Value |
|---|---|
| Risk | Student may access pending, hidden, rejected, or archived content. |
| Impact | Core platform trust is broken. |
| Mitigation | Centralize Student-visible material queries in `MaterialService` and `MaterialDao`. |

---

### 28.5 Risk: AI Content Is Published Too Early

| Field | Value |
|---|---|
| Risk | AI-generated content may become visible before Teacher review. |
| Impact | Students may receive inaccurate content. |
| Mitigation | Store AI output as draft and block Student access until review is complete. |

---

### 28.6 Risk: Traditional JSP/Servlet Structure Becomes Messy

| Field | Value |
|---|---|
| Risk | Without strict structure, JSP and Servlet projects can become difficult to scale. |
| Impact | Maintainability decreases over time. |
| Mitigation | Use MVC strictly, organize packages by responsibility, and keep documentation updated. |

---

## 29. Deployment Plan

### 29.1 MVP Deployment

MVP can be deployed using:

- Apache Tomcat.
- Java application packaged as WAR.
- PostgreSQL or MySQL database.
- Environment-based configuration.

### 29.2 Deployment Requirements

Deployment should include:

- Database connection configuration.
- File storage configuration.
- AI provider configuration.
- Environment variables.
- Logging configuration.
- Error page configuration.

### 29.3 Environment Separation

Recommended environments:

- Development.
- Staging.
- Production.

For early MVP, development and production may be enough, but staging is recommended before real users.

---

## 30. Documentation Alignment

Implementation should remain aligned with the HIPZI documentation set.

Important traceability examples:

### 30.1 Material Upload

| Layer | Reference |
|---|---|
| Business Rule | BR-TCH-004, BR-MAT-001 |
| Functional Requirement | FR-MAT-001 |
| User Flow | UF-MAT-001 |
| Acceptance Criteria | AC-MAT-001 |
| Edge Case | EC-TCH-003, EC-MAT-001 |
| Database | materials, material_files |
| Servlet | MaterialCreateServlet |
| Service | MaterialService |
| DAO | MaterialDao |
| JSP | teacher/material-form.jsp |

### 30.2 Staff Material Approval

| Layer | Reference |
|---|---|
| Business Rule | BR-STF-004, BR-STF-005 |
| Functional Requirement | FR-STF-005, FR-STF-006 |
| User Flow | UF-STF-002 |
| Acceptance Criteria | AC-STF-003, AC-STF-004 |
| Edge Case | EC-STF-002 |
| Database | materials, material_moderation_actions, audit_logs |
| Servlet | StaffMaterialApproveServlet |
| Service | MaterialModerationService |
| DAO | MaterialDao, MaterialModerationActionDao |
| JSP | staff/material-review-detail.jsp |

### 30.3 AI Quiz Generation

| Layer | Reference |
|---|---|
| Business Rule | BR-AI-002, BR-AI-006 |
| Functional Requirement | FR-AI-001, FR-AI-003 |
| User Flow | UF-AI-001 |
| Acceptance Criteria | AC-AI-001 |
| Edge Case | EC-AI-001, EC-AI-002 |
| Database | ai_contents, quizzes, quiz_questions, quiz_options |
| Servlet | AIQuizGenerateServlet |
| Service | AIContentService |
| DAO | AIContentDao, QuizDao |
| JSP | ai/generate-quiz.jsp, ai/review-ai-content.jsp |

---

## 31. MVP Completion Criteria

The technical MVP can be considered complete when:

- The application runs on a Servlet container.
- JSP pages render core user flows.
- Users can register, log in, and log out.
- Role-based access is enforced.
- Teacher application workflow works.
- Staff can approve or reject Teacher applications.
- Approved Teachers can upload materials.
- Staff can moderate materials.
- Students can browse only approved and visible materials.
- AI quiz and flashcard generation creates draft content.
- Teacher can review AI-generated content.
- Students can practice quizzes and flashcards.
- Quiz attempts are stored and scored.
- Admin can assign and revoke Staff role.
- Audit logs exist for important actions.
- Critical business rules are tested manually or automatically.
- Critical edge cases are handled.

---

## 32. Next Document

The next recommended document is:

`12-testing-strategy.md`

That document should define:

- Testing scope.
- Unit testing strategy.
- Integration testing strategy.
- Servlet testing strategy.
- JSP manual testing checklist.
- Role-based access tests.
- Staff moderation tests.
- AI workflow tests.
- Student visibility tests.
- Regression testing plan.

The technical plan should guide implementation while preserving the core HIPZI principle:

> JSP renders the user experience.  
> Servlets control request flow.  
> Services enforce business rules.  
> DAOs manage database access.  
> Staff moderates content.  
> Admin governs the platform.  
> AI assists, but does not bypass human review.