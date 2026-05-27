# HIPZI System Architecture

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | System Architecture Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, System Architect, QA Engineer, Designer |
| Language | English |

---

## 1. Purpose

This document defines the system architecture for HIPZI.

The purpose of this document is to describe how HIPZI should be structured at a high level so that developers and AI coding agents can implement the system consistently, safely, and maintainably.

This document focuses on:

- High-level system structure.
- Core architectural layers.
- Core business modules.
- Role and permission boundaries.
- AI integration boundaries.
- Moderation and governance architecture.
- Major system data flows.
- Status and state management.
- Scalability direction.
- Future extensibility.

This document does not define:

- Detailed database schema.
- Exact API request and response contracts.
- UI visual design.
- Infrastructure deployment scripts.
- Specific framework implementation details.

Those details should be refined in later documents such as:

- `08-database-design.md`
- `09-api-design.md`
- `10-non-functional-requirements.md`
- `11-tech-plan.md`
- `12-testing-strategy.md`
- `14-ui-ux-design.md`

---

## 2. Architecture Context

HIPZI is an AI-powered EdTech platform that supports multiple user groups and workflows.

The system must support:

- Students who browse approved learning materials and practice with quizzes or flashcards.
- Teachers / Lecturers who apply for verification, upload materials, create quizzes, generate flashcards, and manage future classes.
- Staff members who review teacher applications, moderate uploaded materials, handle reported content, and maintain day-to-day content quality.
- Admins who manage users, roles, Staff permissions, subjects, platform policies, audit logs, and override decisions.
- Parents in future phases who may view authorized Student learning progress.
- AI-powered workflows such as quiz generation, flashcard generation, explanation support, learning roadmap generation, and recommendations.

The architecture must preserve the current HIPZI governance model:

> Teachers create educational content.  
> Staff moderate teacher applications and uploaded content.  
> Admins govern roles, permissions, audits, and override decisions.  
> AI assists, but does not bypass human review or platform rules.

---

## 3. Architecture Goals

HIPZI architecture should support the following goals:

- Clear separation between Student, Teacher, Staff, Admin, and Parent workflows.
- Strong role-based access control.
- Safe teacher verification workflow.
- Safe Staff-based material moderation workflow.
- AI-assisted learning content generation without bypassing Teacher review.
- Student access only to approved and visible learning content.
- Scalable structure for future classes, courses, exams, personalization, recommendations, and payments.
- Maintainable module boundaries for developers and AI coding agents.
- Traceability from requirements to implementation.
- Easy extension without rewriting the entire system.
- Clear distinction between operational moderation and high-level governance.

---

## 4. Recommended Architecture Style

HIPZI should start with a **modular monolith architecture**.

### 4.1 Modular Monolith First

The initial implementation should be deployed as one main application, but internally it should be divided into clear modules.

Recommended modules include:

- Authentication Module.
- Role and Permission Module.
- User Profile Module.
- Teacher Application Module.
- Staff Moderation Module.
- Admin Governance Module.
- Study Material Module.
- AI Content Module.
- Student Practice Module.
- Search and Discovery Module.
- Personalization and Recommendation Module.
- Class and Course Module.
- Parent Module.
- Reporting, Review, and Rating Module.
- Exam and Assessment Module.
- Monetization and Payment Module.

### 4.2 Why Modular Monolith

A modular monolith is recommended because HIPZI is still in the MVP and early product validation stage.

Benefits:

- Faster development.
- Easier debugging.
- Lower operational complexity.
- Easier deployment.
- Easier data consistency.
- Better fit for a small or early-stage team.
- Clear business-domain separation without premature infrastructure complexity.
- Easier for AI coding agents to understand and modify the codebase.

### 4.3 Future Service Extraction

As HIPZI grows, some modules may be extracted into independent services.

Possible future services include:

- AI generation service.
- Search service.
- Recommendation service.
- Notification service.
- Payment service.
- Analytics service.
- File processing service.

Service extraction should only happen when a module has clear scale, performance, reliability, or team ownership requirements.

---

## 5. High-Level System Overview

HIPZI should be organized into the following high-level architecture:

    Client Layer
    ↓
    Application / API Layer
    ↓
    Domain / Business Layer
    ↓
    Data Access Layer
    ↓
    Database and Storage Layer

    Supporting Layers:
    - AI Integration Layer
    - Background Job Layer
    - External Services Layer
    - Observability and Audit Layer

The architecture should follow this principle:

> The frontend provides user experience.  
> The backend enforces permissions, business rules, workflows, and data integrity.

---

## 6. System Layers

### 6.1 Client Layer

The Client Layer contains user-facing interfaces.

HIPZI may include the following clients:

- Student Web App.
- Teacher Dashboard.
- Staff Moderation Dashboard.
- Admin Governance Dashboard.
- Parent Dashboard in future phases.

The Client Layer is responsible for:

- Displaying role-specific interfaces.
- Collecting user input.
- Showing validation messages.
- Calling backend APIs.
- Showing loading, empty, error, and success states.
- Hiding unavailable actions based on role.
- Presenting workflow status clearly to users.

The Client Layer must not be the only place where permission is enforced.

Frontend role checks improve user experience, but backend authorization must always be the source of truth.

---

### 6.2 Application / API Layer

The Application / API Layer receives client requests and coordinates system behavior.

Responsibilities:

- Route API requests.
- Authenticate users.
- Authorize user actions.
- Validate request input.
- Call domain services.
- Return consistent responses.
- Handle common errors.
- Apply rate limits where needed.
- Coordinate with background jobs for long-running tasks.

Example API areas:

- Auth APIs.
- User and role APIs.
- Teacher application APIs.
- Staff moderation APIs.
- Admin governance APIs.
- Material APIs.
- AI generation APIs.
- Practice APIs.
- Search APIs.
- Personalization APIs.
- Reporting APIs.
- Class and course APIs.
- Payment APIs in future phases.

The API Layer should not contain complex business logic directly. Complex business rules should be implemented in the Domain / Business Layer.

---

### 6.3 Domain / Business Layer

The Domain / Business Layer contains HIPZI’s core business logic.

This layer should enforce business rules such as:

- Only approved Teachers can upload learning materials.
- Teacher and Staff are separate roles by default.
- Staff cannot review their own content if they also have Teacher role.
- Students can only access approved and visible materials.
- AI-generated content must be saved as draft by default.
- AI-generated content must be reviewed by a Teacher before Student access.
- Admins can assign or revoke Staff permissions.
- Admins can audit or override Staff decisions.

The Domain Layer should be organized into services.

Recommended domain services:

- `AuthService`
- `RolePermissionService`
- `TeacherApplicationService`
- `StaffModerationService`
- `AdminGovernanceService`
- `MaterialService`
- `MaterialModerationService`
- `AIContentService`
- `PracticeService`
- `SearchService`
- `PersonalizationService`
- `ReportingService`
- `ClassService`
- `CourseService`
- `ParentAccessService`
- `PaymentService` in future phases

Important principle:

> Business rules must be centralized in domain services, not scattered across UI components or unrelated API handlers.

---

### 6.4 Data Access Layer

The Data Access Layer is responsible for reading and writing data.

Responsibilities:

- Query database records.
- Save domain state changes.
- Support transactions where needed.
- Hide raw database details from domain services.
- Provide repositories or data access functions per module.
- Prevent unauthorized data exposure through safe query patterns.

Recommended repositories:

- `UserRepository`
- `RoleRepository`
- `TeacherApplicationRepository`
- `TeacherProfileRepository`
- `MaterialRepository`
- `MaterialModerationRepository`
- `AIContentRepository`
- `QuizRepository`
- `FlashcardRepository`
- `QuizAttemptRepository`
- `LearningActivityRepository`
- `ModerationActionRepository`
- `ReportRepository`
- `AuditLogRepository`
- `ClassRepository`
- `CourseRepository`
- `PaymentRepository` in future phases

---

### 6.5 Database and Storage Layer

The Database and Storage Layer stores persistent system data.

HIPZI should store structured data in a primary database and uploaded files in object storage.

Structured data may include:

- Users.
- Roles.
- User-role assignments.
- Student profiles.
- Teacher profiles.
- Teacher applications.
- Staff permissions.
- Subjects.
- Materials.
- Material statuses.
- Material moderation actions.
- AI-generated content.
- Quizzes.
- Quiz questions.
- Flashcard sets.
- Flashcards.
- Quiz attempts.
- Learning history.
- Reports.
- Audit logs.
- Classes.
- Enrollments.
- Courses.
- Exams.
- Payment records in future phases.

File storage may include:

- Uploaded documents.
- Images.
- PDF files.
- Learning material files.
- Generated assets.
- Attachments.

Object storage should store files, while the database should store metadata and references to those files.

---

### 6.6 AI Integration Layer

The AI Integration Layer handles communication with AI models and AI-related workflows.

Responsibilities:

- Prepare material content for AI generation.
- Generate quiz drafts.
- Generate flashcard drafts.
- Generate AI explanations in Phase 2.
- Generate learning roadmaps in Phase 2.
- Recommend materials and Teachers in Phase 2.
- Store AI-generated content as draft.
- Preserve AI-assisted metadata.
- Prevent AI output from bypassing review workflows.

AI must be treated as an assistant, not an authority.

AI output should follow this workflow:

    AI Output
    → Draft
    → Teacher Review
    → Staff Review if required by policy
    → Student Visible

The AI Integration Layer should not directly publish content to Students.

---

### 6.7 Background Job Layer

Some operations should not block the main request-response cycle.

The Background Job Layer may handle:

- AI generation jobs.
- File processing.
- Document text extraction.
- Search indexing.
- Notification sending.
- Report aggregation.
- Analytics aggregation.
- Recommendation refresh.
- Payment processing in future phases.

Long-running operations should be queued and processed asynchronously when appropriate.

Background jobs should support:

- Job status tracking.
- Retry behavior.
- Error logging.
- Safe failure handling.
- Idempotency where needed.

---

### 6.8 External Services Layer

HIPZI may integrate with external services.

Possible external services:

- AI model provider.
- Object storage provider.
- Email provider.
- Search provider.
- Payment provider in future phases.
- Analytics provider.
- Monitoring provider.

External services should be accessed through internal adapters so that the rest of the system is not tightly coupled to a specific vendor.

Example adapters:

- `AIProviderAdapter`
- `FileStorageAdapter`
- `EmailProviderAdapter`
- `SearchProviderAdapter`
- `PaymentProviderAdapter`

---

### 6.9 Observability and Audit Layer

HIPZI should capture important system events for debugging, moderation, and governance.

The system should support:

- Error logging.
- Request logging where appropriate.
- Moderation action logs.
- Role assignment logs.
- Admin override logs.
- AI generation logs.
- Report handling logs.
- Security-related events.

For MVP, logging can be basic.

For Phase 2, Admin audit views should be added.

---

## 7. Core Modules

### 7.1 Authentication Module

The Authentication Module manages account access.

Responsibilities:

- User registration.
- User login.
- User logout.
- Session management.
- Authentication state validation.
- Password or provider-based authentication depending on implementation.

Related documents:

- `FR-AUTH-001`
- `FR-AUTH-002`
- `AC-AUTH-001`
- `AC-AUTH-002`
- `EC-AUTH-001`
- `EC-AUTH-002`

---

### 7.2 Role and Permission Module

The Role and Permission Module controls access to protected features.

Responsibilities:

- Assign user roles.
- Support multiple roles.
- Enforce role-based access.
- Protect Staff tools.
- Protect Admin tools.
- Separate Teacher and Staff roles by default.
- Support Admin assignment and revocation of Staff role.

Primary roles:

- Student.
- Parent.
- Teacher.
- Staff.
- Admin.

Important principle:

> Frontend may hide unauthorized actions, but backend must enforce authorization.

Related documents:

- `BR-ROLE-001` to `BR-ROLE-006`
- `FR-AUTH-003` to `FR-AUTH-008`
- `AC-AUTH-003` to `AC-AUTH-005`
- `EC-AUTH-003` to `EC-AUTH-006`

---

### 7.3 User Profile Module

The User Profile Module manages user profile information.

Responsibilities:

- Store basic profile information.
- Store Student learning profile in Phase 2.
- Store Teacher profile information.
- Store Parent profile information in future phases.
- Support role-specific profile views.

Teacher profile information may include:

- Teaching subjects.
- Experience.
- Qualifications.
- Introduction.
- Teaching preferences.
- Verification status.

---

### 7.4 Teacher Application Module

The Teacher Application Module manages the process of becoming a verified Teacher.

Responsibilities:

- Create teacher applications.
- Store application details.
- Track application status.
- Allow applicants to view status.
- Send applications to Staff review queue.
- Apply Teacher permissions after Staff approval.
- Prevent rejected or pending applicants from accessing Teacher-only tools.

Teacher application statuses:

    Draft
    Submitted / Pending Review
    Approved
    Rejected
    Suspended

Related documents:

- `BR-TCH-001` to `BR-TCH-007`
- `FR-TCH-001` to `FR-TCH-006`
- `UF-TCH-001`
- `UF-TCH-002`
- `AC-TCH-001` to `AC-TCH-004`
- `EC-TCH-001` to `EC-TCH-004`

---

### 7.5 Staff Moderation Module

The Staff Moderation Module supports day-to-day platform quality control.

Responsibilities:

- Review teacher applications.
- Approve or reject teacher applications.
- Review uploaded learning materials.
- Approve, reject, request revision, hide, or archive materials.
- Review reported content in Phase 2.
- Escalate serious issues to Admins in Phase 2.
- Prevent Staff self-review if the Staff member also has Teacher role.

Important principle:

> Staff handles operational review. Admin governs, audits, and overrides.

Related documents:

- `BR-STF-001` to `BR-STF-007`
- `FR-STF-001` to `FR-STF-008`
- `UF-STF-001` to `UF-STF-003`
- `AC-STF-001` to `AC-STF-005`
- `EC-STF-001` to `EC-STF-006`

---

### 7.6 Admin Governance Module

The Admin Governance Module supports high-level platform control.

Responsibilities:

- Manage user accounts.
- Assign or revoke roles.
- Assign or revoke Staff permissions.
- Manage subjects and platform-level categories.
- Audit Staff actions in Phase 2.
- Override Staff decisions in Phase 2.
- Handle serious policy violations or disputes.

Admin responsibilities should remain separate from Staff daily operations.

Related documents:

- `BR-ADM-001` to `BR-ADM-006`
- `FR-ADM-001` to `FR-ADM-006`
- `UF-ADM-001` to `UF-ADM-003`
- `AC-ADM-001` to `AC-ADM-005`
- `EC-ADM-001` to `EC-ADM-004`

---

### 7.7 Study Material Module

The Study Material Module manages learning materials.

Responsibilities:

- Allow approved Teachers to upload materials.
- Store required material information.
- Associate materials with subjects or categories.
- Assign material owner.
- Assign moderation status.
- Submit materials for Staff review.
- Display only approved and visible materials to Students.
- Allow Teachers to revise Draft, Rejected, or Needs Revision materials.
- Support archived and hidden states.

Material statuses:

    Draft
    Pending Review
    Approved
    Rejected
    Needs Revision
    Hidden
    Archived

Student visibility rule:

    Only Approved and Visible materials can be shown to Students.

Related documents:

- `BR-MAT-001` to `BR-MAT-007`
- `FR-MAT-001` to `FR-MAT-007`
- `UF-MAT-001` to `UF-MAT-003`
- `AC-MAT-001` to `AC-MAT-004`
- `EC-MAT-001` to `EC-MAT-006`

---

### 7.8 AI Content Module

The AI Content Module manages AI-generated educational content.

Responsibilities:

- Generate quiz drafts from materials.
- Generate flashcard drafts from materials.
- Store AI-generated content as Draft.
- Mark AI-assisted content.
- Allow Teacher review and editing.
- Prevent unreviewed AI content from Student access.
- Support Staff approval if platform policy requires it.
- Allow Teachers to discard AI-generated content.

AI content lifecycle:

    Generated Draft
    → Teacher Reviewed
    → Submitted for Review if required
    → Approved / Rejected
    → Published / Discarded

Important principle:

> AI assists. Teacher reviews. Staff moderates when required.

Related documents:

- `BR-AI-001` to `BR-AI-006`
- `FR-AI-001` to `FR-AI-007`
- `UF-AI-001` to `UF-AI-003`
- `AC-AI-001` to `AC-AI-005`
- `EC-AI-001` to `EC-AI-006`

---

### 7.9 Student Practice Module

The Student Practice Module supports quizzes and flashcards.

Responsibilities:

- Start quiz attempts.
- Submit answers.
- Calculate scores.
- Display feedback.
- Store quiz attempts.
- Support retakes for practice quizzes.
- Display flashcards.
- Store basic practice activity.

Practice quiz principle:

> Practice quiz scores are learning feedback, not formal academic grades.

Related documents:

- `BR-PRAC-001` to `BR-PRAC-005`
- `FR-PRAC-001` to `FR-PRAC-007`
- `UF-PRAC-001`
- `UF-PRAC-002`
- `AC-PRAC-001` to `AC-PRAC-006`
- `EC-PRAC-001` to `EC-PRAC-006`

---

### 7.10 Search and Discovery Module

The Search and Discovery Module helps Students find learning content.

Responsibilities:

- Search approved materials by keyword.
- Filter materials by subject.
- Exclude unapproved or hidden content.
- Support natural-language search in Phase 2.
- Support search by topic, difficulty, grade, Teacher, or learning goal in future phases.

Important rule:

    Student search results must only include Approved and Visible materials.

Related documents:

- `FR-SEARCH-001` to `FR-SEARCH-004`
- `AC-SEARCH-001` to `AC-SEARCH-003`
- `EC-SEARCH-001` to `EC-SEARCH-003`

---

### 7.11 Personalization and Recommendation Module

The Personalization and Recommendation Module is planned for Phase 2.

Responsibilities:

- Collect Student learning goals.
- Collect current level, weak areas, available time, and preferences.
- Analyze Student learning needs using AI.
- Generate personalized learning roadmaps.
- Recommend approved materials.
- Recommend verified and active Teachers.
- Ask clarifying questions when data is insufficient.
- Allow Students to update preferences.

Recommendation safety rules:

    Recommended materials must be Approved and Visible.
    Recommended Teachers must be Verified and Active.

Related documents:

- `BR-PER-001` to `BR-PER-006`
- `FR-PER-001` to `FR-PER-007`
- `UF-PER-001` to `UF-PER-003`
- `AC-PER-001` to `AC-PER-005`
- `EC-PER-001` to `EC-PER-005`

---

### 7.12 Class and Course Module

The Class and Course Module is planned for Phase 2 and future phases.

Responsibilities:

- Allow approved Teachers to create classes.
- Allow Students to request enrollment.
- Allow Teachers to approve or reject enrollment requests.
- Support class-specific materials.
- Support structured courses in future phases.
- Support Course → Module → Lesson → Material → Quiz / Assignment hierarchy.

Course hierarchy:

    Course
    → Module
    → Lesson
    → Material
    → Quiz / Assignment

Related documents:

- `BR-CLS-001` to `BR-CLS-005`
- `FR-CLS-001` to `FR-CLS-003`
- `FR-COURSE-001` to `FR-COURSE-002`
- `UF-CLS-001` to `UF-CLS-003`
- `UF-COURSE-001`
- `AC-CLS-001` to `AC-CLS-003`
- `AC-COURSE-001` to `AC-COURSE-002`

---

### 7.13 Parent Module

The Parent Module is future scope.

Responsibilities:

- Allow Parent accounts.
- Link Parents to Students through verified authorization.
- Allow Parents to view permitted Student learning progress.
- Provide learning summaries in future phases.

Privacy principle:

> Parent access to Student data requires verified relationship or authorization.

Related documents:

- `BR-PAR-001` to `BR-PAR-002`
- `FR-PAR-001` to `FR-PAR-003`
- `UF-PAR-001` to `UF-PAR-002`
- `AC-PAR-001` to `AC-PAR-002`
- `EC-PAR-001` to `EC-PAR-002`

---

### 7.14 Reporting, Review, and Rating Module

This module supports quality feedback and trust.

Responsibilities:

- Allow users to report incorrect or inappropriate content.
- Allow users to report AI mistakes.
- Allow Staff to process reports.
- Allow reviews and ratings in future phases.
- Prevent Teachers from reviewing their own content.
- Support review moderation.

Related documents:

- `BR-REV-001` to `BR-REV-003`
- `FR-REP-001` to `FR-REP-002`
- `FR-REV-001` to `FR-REV-002`
- `UF-REP-001`
- `UF-REV-001`
- `AC-REP-001`
- `AC-REV-001` to `AC-REV-002`
- `EC-REP-001` to `EC-REP-002`
- `EC-REV-001` to `EC-REV-002`

---

### 7.15 Exam and Assessment Module

The Exam and Assessment Module is future scope.

Responsibilities:

- Allow Teachers to create online exams.
- Allow Students to take online exams.
- Support timed exams.
- Support attempt limits.
- Automatically grade objective questions.
- Require Teacher review for AI-assisted written grading.
- Prevent answer access before submission.

Important principle:

> Formal exams must be clearly distinguished from practice quizzes.

Related documents:

- `BR-EXAM-001` to `BR-EXAM-005`
- `FR-EXAM-001` to `FR-EXAM-004`
- `UF-EXAM-001` to `UF-EXAM-002`
- `AC-EXAM-001` to `AC-EXAM-004`
- `EC-EXAM-001` to `EC-EXAM-004`

---

### 7.16 Monetization and Payment Module

The Monetization and Payment Module is future scope.

Responsibilities:

- Support premium access rules.
- Support subscription plans.
- Support teacher marketplace transactions.
- Support commission calculation.
- Prevent premium access without entitlement.
- Handle failed payments safely.

Related documents:

- `BR-PAY-001` to `BR-PAY-003`
- `FR-PAY-001` to `FR-PAY-002`
- `UF-PAY-001` to `UF-PAY-002`
- `AC-PAY-001` to `AC-PAY-002`
- `EC-PAY-001` to `EC-PAY-003`

---

## 8. Role and Permission Architecture

HIPZI should use role-based access control.

### 8.1 Core Roles

| Role | Description |
|---|---|
| Student | Learner who studies materials, practices quizzes, and receives recommendations |
| Parent | Future role that can view authorized Student progress |
| Teacher | Verified educator who creates learning content and manages future classes |
| Staff | Platform operator who reviews teacher applications and moderates content |
| Admin | High-level governance role that manages roles, policies, audits, and overrides |

### 8.2 Role Separation

Teacher and Staff must be separate roles by default.

A Teacher does not automatically become Staff.

A Staff member does not automatically become Teacher.

A user may hold both Teacher and Staff roles only when explicitly assigned by an Admin.

### 8.3 Multi-Role Users

HIPZI should support users with multiple roles.

Example:

    User A: Student
    User B: Teacher
    User C: Staff
    User D: Teacher + Staff
    User E: Admin

If a user has both Teacher and Staff roles, the system must enforce self-review prevention.

### 8.4 Authorization Enforcement

Authorization must be enforced in the backend.

Frontend role checks are useful for user experience, but they must not be considered secure by themselves.

Protected actions include:

- Uploading learning materials.
- Reviewing teacher applications.
- Approving or rejecting materials.
- Assigning Staff role.
- Accessing Admin tools.
- Overriding Staff decisions.
- Viewing non-public materials.
- Publishing AI-generated content.

---

## 9. Major System Data Flows

### 9.1 Teacher Application Flow

    User submits teacher application
    → System stores application as Pending Review
    → Staff reviews application
    → Staff approves or rejects
    → If approved, system grants Teacher permissions
    → If rejected, user remains without Teacher permissions

### 9.2 Material Upload and Moderation Flow

    Approved Teacher uploads material
    → System saves material as Draft or Pending Review
    → Staff reviews material
    → Staff approves, rejects, requests revision, hides, or archives
    → If approved and visible, Student can access
    → Otherwise, Student cannot access

### 9.3 AI Quiz and Flashcard Generation Flow

    Teacher selects AI generation
    → System sends eligible material content to AI
    → AI returns draft quiz or flashcards
    → System saves output as Draft
    → Teacher reviews and edits
    → Content becomes Teacher Reviewed
    → Staff approval may be required by policy
    → Student can access only after required review is complete

### 9.4 Student Practice Flow

    Student opens approved material
    → Student starts quiz or flashcards
    → System creates practice session or attempt
    → Student submits answers or completes practice
    → System calculates score when possible
    → System stores learning activity
    → Student receives feedback

### 9.5 Personalization Flow

    Student submits goals, level, weak areas, time, and preferences
    → System stores personalization input
    → AI analyzes input and learning history
    → AI generates recommended roadmap
    → System recommends approved materials
    → System recommends verified active Teachers

### 9.6 Admin Governance Flow

    Admin opens governance dashboard
    → Admin manages users, roles, or subjects
    → Admin assigns or revokes Staff role
    → Admin audits Staff actions
    → Admin overrides decisions when necessary

---

## 10. Status and State Architecture

HIPZI should model important workflow states explicitly.

### 10.1 Teacher Application Status

    Draft
    Submitted / Pending Review
    Approved
    Rejected
    Suspended

### 10.2 Material Status

    Draft
    Pending Review
    Approved
    Rejected
    Needs Revision
    Hidden
    Archived

### 10.3 AI Content Status

    Generated Draft
    Teacher Reviewed
    Submitted for Review
    Approved
    Rejected
    Published
    Discarded

### 10.4 Quiz Attempt Status

    Started
    Submitted
    Scored
    Reviewed
    Incomplete

### 10.5 Class Enrollment Status

    Requested
    Approved
    Rejected
    Active
    Removed

### 10.6 Report Status

    Submitted
    In Review
    Resolved
    Dismissed
    Escalated

Status transitions should be handled by domain services, not scattered across unrelated components.

---

## 11. Security and Access Control Architecture

### 11.1 Authentication

The system should authenticate users before allowing access to protected features.

Protected areas include:

- Student dashboard.
- Teacher dashboard.
- Staff moderation dashboard.
- Admin governance dashboard.
- Parent dashboard in future phases.

### 11.2 Authorization

The system must check permissions before performing protected actions.

Authorization should be enforced in:

- API routes.
- Domain services.
- Data access queries where appropriate.

### 11.3 Content Visibility Security

Student-facing APIs must only return content that is approved and visible.

This rule applies to:

- Material browsing.
- Material detail view.
- Search results.
- Recommendations.
- Practice activities.
- Course listings in future phases.

### 11.4 Self-Review Prevention

If a user has both Teacher and Staff roles, the system must prevent the user from reviewing:

- Their own teacher application.
- Their own uploaded materials.
- Their own courses.
- Their own quizzes.
- Their own exams.
- Their own AI-generated learning content.

### 11.5 Admin Protection

Admin-only operations must be protected.

Examples:

- Assigning roles.
- Revoking roles.
- Assigning Staff permissions.
- Managing governance policies.
- Overriding Staff decisions.
- Accessing platform-wide audit logs.

---

## 12. AI Architecture

### 12.1 AI Responsibilities

The AI system may support:

- Quiz generation.
- Flashcard generation.
- Explanation support.
- Learning roadmap generation.
- Material recommendation.
- Teacher recommendation.
- Teaching assistant tools.
- AI-assisted grading in future phases.

### 12.2 AI Boundaries

AI must not:

- Publish content directly to Students without required review.
- Recommend unapproved materials.
- Recommend unverified or inactive Teachers.
- Finalize written exam grading without Teacher review.
- Override Staff or Admin governance rules.
- Expose private Student data without permission.

### 12.3 AI Content Lifecycle

    Material Input
    → AI Generation
    → Draft Output
    → Teacher Review
    → Staff Review if required
    → Student Visible if approved

### 12.4 AI Metadata

AI-generated content should preserve metadata such as:

- AI-assisted flag.
- Source material.
- Generated timestamp.
- Reviewing Teacher.
- Review status.
- Staff approval status if required.
- Discarded status if removed.

### 12.5 AI Failure Handling

If AI generation fails, the system should:

- Not publish incomplete output.
- Show an error to the Teacher.
- Allow retry where appropriate.
- Log the failure for debugging.
- Preserve existing content.

---

## 13. Data Architecture Overview

Detailed database design should be defined in `08-database-design.md`.

At the architecture level, HIPZI should organize data around these major entities:

- User.
- Role.
- UserRole.
- StudentProfile.
- TeacherProfile.
- TeacherApplication.
- StaffPermission.
- Subject.
- Material.
- MaterialVersion.
- MaterialModerationAction.
- AIContent.
- Quiz.
- QuizQuestion.
- FlashcardSet.
- Flashcard.
- QuizAttempt.
- QuizAnswer.
- LearningActivity.
- Report.
- AdminAuditLog.
- Class.
- Enrollment.
- Course.
- Module.
- Lesson.
- Assignment.
- Exam.
- PaymentRecord.

Not all entities are required for MVP.

MVP should focus on:

- User.
- Role.
- UserRole.
- TeacherProfile.
- TeacherApplication.
- Subject.
- Material.
- MaterialModerationAction.
- AIContent.
- Quiz.
- QuizQuestion.
- FlashcardSet.
- Flashcard.
- QuizAttempt.
- LearningActivity.
- AuditLog or basic action log.

---

## 14. API Architecture Overview

Detailed API design should be defined in `09-api-design.md`.

At the architecture level, APIs should be grouped by domain:

    /auth
    /users
    /roles
    /teacher-applications
    /staff
    /admin
    /materials
    /ai-content
    /quizzes
    /flashcards
    /practice
    /search
    /personalization
    /classes
    /courses
    /reports
    /exams
    /payments

API design should follow these principles:

- Role checks must happen on protected endpoints.
- Student endpoints must filter visibility.
- Staff endpoints must enforce Staff permissions.
- Admin endpoints must enforce Admin permissions.
- Mutation endpoints must validate status transitions.
- AI endpoints must return draft content, not automatically published content.
- Errors should be consistent and understandable.

---

## 15. Frontend Architecture Overview

Detailed UI/UX design should be defined in `14-ui-ux-design.md`.

The frontend should be organized around role-specific experiences.

### 15.1 Student Interface

Student interface should include:

- Dashboard.
- Subject browsing.
- Material browsing.
- Material detail.
- Quiz practice.
- Flashcard practice.
- Learning history.
- AI personalization in Phase 2.

### 15.2 Teacher Interface

Teacher interface should include:

- Teacher application page.
- Teacher profile.
- Teacher dashboard.
- Material management.
- Material upload.
- AI quiz generation.
- AI flashcard generation.
- AI content review.
- Class management in Phase 2.

### 15.3 Staff Interface

Staff interface should include:

- Moderation dashboard.
- Teacher application review queue.
- Material review queue.
- Report queue in Phase 2.
- Escalation tools in Phase 2.

### 15.4 Admin Interface

Admin interface should include:

- Governance dashboard.
- User management.
- Role management.
- Staff permission assignment.
- Subject/category management.
- Audit logs in Phase 2.
- Override tools in Phase 2.

### 15.5 Parent Interface

Parent interface is future scope and may include:

- Linked Student view.
- Student progress dashboard.
- Learning summary.

---

## 16. Background Job Architecture

HIPZI may use background jobs for operations that are long-running or asynchronous.

Possible background jobs:

- AI quiz generation.
- AI flashcard generation.
- Document text extraction.
- File processing.
- Search indexing.
- Recommendation generation.
- Email notifications.
- Report aggregation.
- Analytics updates.
- Payment processing in future phases.

Background jobs should have:

- Job status.
- Retry behavior.
- Error logging.
- Safe failure handling.
- Idempotency where needed.

---

## 17. Notification Architecture

Notifications are not required for the earliest MVP but should be considered for Phase 2.

Possible notifications:

- Teacher application approved or rejected.
- Material approved, rejected, or needs revision.
- Staff escalation created.
- Student enrollment request received.
- Enrollment approved or rejected.
- Report resolved.
- Payment status updated in future phases.

Notifications may be delivered through:

- In-app notifications.
- Email notifications.
- Future mobile push notifications.

---

## 18. Observability, Audit, and Logging

HIPZI should log important events for debugging and governance.

### 18.1 System Logs

System logs may include:

- Authentication errors.
- Authorization failures.
- API errors.
- AI generation failures.
- File upload failures.
- Background job failures.

### 18.2 Audit Logs

Audit logs should include:

- Role assignments.
- Staff role revocation.
- Teacher application decisions.
- Material moderation decisions.
- Admin overrides.
- Content hiding or archiving.
- Staff self-review prevention events.
- Serious policy escalations.

### 18.3 AI Logs

AI logs may include:

- AI generation request metadata.
- Source material ID.
- Generation status.
- Error status.
- Reviewing Teacher.
- AI-assisted flag.

Logs should avoid exposing sensitive Student data unnecessarily.

---

## 19. Scalability and Future Evolution

HIPZI should begin with a modular monolith but remain ready for future scaling.

### 19.1 Modules That May Scale Independently

Potential future extraction candidates:

- AI generation.
- Search and indexing.
- Recommendation.
- Notification.
- Payment.
- Analytics.
- File processing.

### 19.2 Scaling Triggers

A module may be extracted when:

- It has heavy traffic.
- It requires independent scaling.
- It has long-running workloads.
- It needs separate infrastructure.
- It has a separate team owner.
- It creates performance bottlenecks.

### 19.3 Future Architecture Direction

Possible future architecture:

    Web Client
    → API Gateway
    → Core Application Service
    → AI Service
    → Search Service
    → Recommendation Service
    → Notification Service
    → Payment Service
    → Analytics Service
    → Database / Storage / Cache

This should not be implemented prematurely.

---

## 20. MVP Architecture Scope

The MVP should include the following architecture components:

- Web application.
- Backend API.
- Authentication and role-based access.
- User and role management.
- Teacher application workflow.
- Staff moderation dashboard.
- Admin role assignment and subject management.
- Study material upload and moderation.
- Student material browsing.
- AI quiz and flashcard generation.
- Teacher review of AI-generated content.
- Student quiz and flashcard practice.
- Basic learning history.
- Basic logging.
- Primary database.
- File storage for uploaded materials.

The MVP should not require:

- Microservices.
- Full payment infrastructure.
- Advanced analytics pipeline.
- Full online exam system.
- Parent dashboard.
- Mobile app.
- Complex recommendation engine.
- Full course builder.

---

## 21. Architectural Decisions

### AD-001: Use Modular Monolith for MVP

| Field | Value |
|---|---|
| Decision | HIPZI should start as a modular monolith. |
| Reason | This reduces operational complexity while preserving modular boundaries. |
| Impact | Modules should be clearly separated in code even if deployed together. |

### AD-002: Backend Authorization Is Required

| Field | Value |
|---|---|
| Decision | All protected actions must be authorized on the backend. |
| Reason | Frontend checks alone are not secure. |
| Impact | Every protected API endpoint must verify user permissions. |

### AD-003: Staff Handles Moderation, Admin Handles Governance

| Field | Value |
|---|---|
| Decision | Staff should handle day-to-day review workflows, while Admin handles role assignment, audit, and override. |
| Reason | This preserves clear operational and governance boundaries. |
| Impact | Staff and Admin modules should remain separate. |

### AD-004: AI Output Must Start as Draft

| Field | Value |
|---|---|
| Decision | AI-generated educational content must be saved as draft by default. |
| Reason | AI-generated content may be inaccurate and requires human review. |
| Impact | AI content should not be student-visible until review requirements are satisfied. |

### AD-005: Student-Facing Content Must Be Visibility-Filtered

| Field | Value |
|---|---|
| Decision | Student-facing content queries must return only approved and visible content. |
| Reason | Students should not access draft, pending, rejected, hidden, or archived materials. |
| Impact | Visibility checks must exist in APIs and domain services, not only UI. |

---

## 22. Architecture Risks

### 22.1 Permission Logic Spread Across the Codebase

| Field | Value |
|---|---|
| Risk | Permission checks may be duplicated inconsistently across UI, API, and services. |
| Impact | Unauthorized access or inconsistent behavior may occur. |
| Mitigation | Centralize permission checks in backend authorization utilities and domain services. |

### 22.2 Staff and Admin Responsibilities Become Mixed

| Field | Value |
|---|---|
| Risk | Staff moderation and Admin governance may be implemented as the same workflow. |
| Impact | The system may become difficult to scale and audit. |
| Mitigation | Keep Staff operational workflows separate from Admin governance workflows. |

### 22.3 AI Content Bypasses Human Review

| Field | Value |
|---|---|
| Risk | AI-generated quizzes or flashcards may become visible to Students too early. |
| Impact | Students may receive inaccurate or low-quality learning content. |
| Mitigation | Store AI output as Draft and enforce Teacher review before Student access. |

### 22.4 Student Visibility Filtering Is Only Implemented in UI

| Field | Value |
|---|---|
| Risk | Hidden or unapproved materials may be accessible through direct API calls. |
| Impact | Students may access content that should not be public. |
| Mitigation | Enforce visibility filtering in backend APIs and domain services. |

### 22.5 Premature Microservice Complexity

| Field | Value |
|---|---|
| Risk | Splitting services too early may slow development and increase operational burden. |
| Impact | MVP development may become unnecessarily complex. |
| Mitigation | Start with modular monolith and extract services only when justified by scale or ownership. |

---

## 23. Notes for Future Refinement

This architecture should guide the next technical documents:

- `08-database-design.md`
- `09-api-design.md`
- `10-non-functional-requirements.md`
- `11-tech-plan.md`
- `12-testing-strategy.md`
- `14-ui-ux-design.md`

When writing database design, each core module should map to clear entities and relationships.

When writing API design, each protected endpoint should reference role and permission rules.

When writing testing strategy, test cases should focus on:

- Role-based access.
- Teacher and Staff separation.
- Staff self-review prevention.
- Material moderation status.
- Student visibility filtering.
- AI content review workflow.
- Quiz attempt storage.
- Admin role assignment.
- Future personalization safety.

Example traceability:

> EC-MAT-002 → AC-MAT-003 → FR-MAT-005 → BR-MAT-004 → System Architecture: Study Material Module

The next recommended document is `08-database-design.md`.