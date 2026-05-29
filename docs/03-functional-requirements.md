# HIPZI Functional Requirements

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Functional Requirements Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Designer, Researcher |
| Language | English |

---

## 1. Purpose

This document defines the functional requirements for HIPZI.

Functional requirements describe what the system must do to support user needs and enforce business rules. This document focuses on system behavior, user interactions, permissions, workflows, and expected outcomes.

This document does not define:

- Database schema.
- API contracts.
- UI visual design.
- Deployment architecture.
- Implementation details.

Those details should be defined in later documents such as:

- `07-system-architecture.md`
- `08-database-design.md`
- `09-api-design.md`
- `14-ui-ux-design.md`

---

## 2. Functional Requirement Classification

Each functional requirement uses a stable ID so it can be referenced by user flows, acceptance criteria, edge cases, tests, and implementation tasks.

### 2.1 Functional Requirement ID Prefixes

| Prefix | Module |
|---|---|
| FR-AUTH | Authentication and Role Management |
| FR-STU | Student Learning |
| FR-TCH | Teacher / Lecturer |
| FR-STF | Staff Moderation |
| FR-ADM | Admin Governance |
| FR-MAT | Study Materials |
| FR-AI | AI Quiz and Flashcard Generation |
| FR-PRAC | Student Practice |
| FR-SEARCH | Search and Discovery |
| FR-PER | Personalization and Recommendation |
| FR-CLS | Class Management |
| FR-COURSE | Course Management |
| FR-PAR | Parent Features |
| FR-REP | Reporting |
| FR-REV | Review and Rating |
| FR-EXAM | Exam and Assessment |
| FR-PAY | Monetization and Payment |

### 2.2 Priority Levels

| Priority | Meaning |
|---|---|
| MVP | Required for the first usable version |
| Phase 2 | Important after the MVP is validated |
| Future | Long-term or advanced feature |

---

## 3. MVP Functional Scope

The MVP should validate the core HIPZI workflow:

> Teacher uploads learning material → Staff reviews and approves content → AI generates quiz or flashcards → Teacher reviews AI-generated content → Student practices → Platform tracks basic learning activity → Staff and Admins govern content quality.

The MVP should prioritize:

- Authentication and role-based access.
- Teacher application and Staff approval.
- Study material upload by approved Teachers.
- Staff moderation of uploaded materials.
- Student browsing of approved materials.
- AI quiz and flashcard generation.
- Teacher review of AI-generated learning content.
- Student quiz and flashcard practice.
- Basic learning history.
- Admin role and permission governance.

The MVP should not include:

- Full online exam system.
- Payment and subscription system.
- Parent dashboard.
- Built-in video classroom.
- Full course builder.
- Teacher marketplace monetization.
- Advanced analytics dashboard.

---

## 4. Authentication and Role Management Requirements

Authentication and role management define how users access HIPZI and how permissions are enforced across Students, Parents, Teachers, Staff, and Admins.

---

### FR-AUTH-001: User Registration

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall allow users to register an account. |
| Actors | Guest User |
| Preconditions | The user does not already have an account with the same identifier. |
| Trigger | Guest user submits registration information. |
| Expected Behavior | The system creates a user account and assigns the appropriate default role. |
| Related User Requirements | UR-STU-001 |
| Related Business Rules | BR-ROLE-001 |

---

### FR-AUTH-002: User Login and Logout

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall allow registered users to log in and log out. |
| Actors | Student, Parent, Teacher, Staff, Admin |
| Preconditions | The user has a registered account. |
| Trigger | User submits login credentials or selects logout. |
| Expected Behavior | The system authenticates valid users, creates a user session, and terminates the session on logout. |
| Related User Requirements | UR-STU-001, UR-GEN-001 |
| Related Business Rules | BR-ROLE-001, BR-ROLE-002 |

---

### FR-AUTH-003: Role Assignment

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall support assigning one or more roles to a user account. |
| Actors | Admin |
| Preconditions | The actor has Admin permissions. |
| Trigger | Admin assigns or updates user roles. |
| Expected Behavior | The system updates the user’s role assignments and applies the corresponding permissions. |
| Related User Requirements | UR-GEN-002, UR-ADM-002, UR-ADM-003 |
| Related Business Rules | BR-ROLE-001, BR-ROLE-004, BR-ADM-001, BR-ADM-002 |

---

### FR-AUTH-004: Role-Based Access Control

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall restrict access to features and data based on user roles. |
| Actors | Student, Parent, Teacher, Staff, Admin |
| Preconditions | The user is authenticated. |
| Trigger | User attempts to access a protected feature or resource. |
| Expected Behavior | The system allows access only if the user has the required role or permission. |
| Related User Requirements | UR-GEN-001, UR-GEN-003 |
| Related Business Rules | BR-ROLE-002, BR-ROLE-005, BR-ROLE-006 |

---

### FR-AUTH-005: Teacher and Staff Role Separation

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall treat Teacher and Staff as separate roles by default. |
| Actors | Admin, Teacher, Staff |
| Preconditions | User roles are defined in the platform. |
| Trigger | The system evaluates user permissions. |
| Expected Behavior | Teacher permissions and Staff permissions remain separate unless an Admin explicitly assigns both roles to the same user. |
| Related User Requirements | UR-GEN-003 |
| Related Business Rules | BR-ROLE-003, BR-ROLE-004 |

---

### FR-AUTH-006: Staff Permission Assignment

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall allow Admins to assign or revoke Staff permissions. |
| Actors | Admin |
| Preconditions | The actor has Admin permissions. |
| Trigger | Admin assigns or revokes the Staff role for a user. |
| Expected Behavior | The system updates Staff access and permission status for the selected user. |
| Related User Requirements | UR-ADM-003 |
| Related Business Rules | BR-ADM-001, BR-ROLE-004 |

---

### FR-AUTH-007: Protected Staff Tools

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall prevent users without Staff permissions from accessing Staff moderation tools. |
| Actors | Student, Parent, Teacher, Staff, Admin |
| Preconditions | Staff moderation tools exist. |
| Trigger | User attempts to access Staff moderation tools. |
| Expected Behavior | The system grants access only to users with Staff permissions or appropriate Admin authority. |
| Related User Requirements | UR-STF-001, UR-GEN-001 |
| Related Business Rules | BR-ROLE-006 |

---

### FR-AUTH-008: Protected Admin Tools

| Field | Value |
|---|---|
| Module | Authentication and Role Management |
| Priority | MVP |
| Description | The system shall prevent users without Admin permissions from accessing Admin governance tools. |
| Actors | Student, Parent, Teacher, Staff, Admin |
| Preconditions | Admin governance tools exist. |
| Trigger | User attempts to access Admin governance tools. |
| Expected Behavior | The system grants access only to users with Admin permissions. |
| Related User Requirements | UR-ADM-001, UR-GEN-001 |
| Related Business Rules | BR-ROLE-005 |

---

## 5. Student Learning Requirements

Student learning requirements define how learners discover materials, view content, practice, receive feedback, and build learning history.

---

### FR-STU-001: Student Dashboard Access

| Field | Value |
|---|---|
| Module | Student Learning |
| Priority | MVP |
| Description | The system shall provide Students with access to student-facing learning features. |
| Actors | Student |
| Preconditions | The user is authenticated with Student permissions. |
| Trigger | Student enters the platform. |
| Expected Behavior | The system displays relevant learning options such as subjects, materials, practice activities, and learning history where available. |
| Related User Requirements | UR-STU-001, UR-GEN-004 |
| Related Business Rules | BR-ROLE-002 |

---

### FR-STU-002: Browse Subjects

| Field | Value |
|---|---|
| Module | Student Learning |
| Priority | MVP |
| Description | The system shall allow Students to browse available subjects. |
| Actors | Student |
| Preconditions | Subjects are available on the platform. |
| Trigger | Student opens the subject browsing area. |
| Expected Behavior | The system displays available subjects and allows the Student to select a subject. |
| Related User Requirements | UR-STU-002 |
| Related Business Rules | BR-MAT-001 |

---

### FR-STU-003: Browse Approved Study Materials

| Field | Value |
|---|---|
| Module | Student Learning |
| Priority | MVP |
| Description | The system shall allow Students to browse approved and visible study materials. |
| Actors | Student |
| Preconditions | Approved and visible materials exist. |
| Trigger | Student opens material browsing or a subject page. |
| Expected Behavior | The system displays only materials that are approved and visible to Students. |
| Related User Requirements | UR-STU-002, UR-STU-004 |
| Related Business Rules | BR-MAT-004 |

---

### FR-STU-004: View Study Material Details

| Field | Value |
|---|---|
| Module | Student Learning |
| Priority | MVP |
| Description | The system shall allow Students to view details of approved study materials. |
| Actors | Student |
| Preconditions | The material is approved and visible. |
| Trigger | Student selects a material. |
| Expected Behavior | The system displays material details such as title, subject, description, teacher information, content, and available practice activities. |
| Related User Requirements | UR-STU-004 |
| Related Business Rules | BR-MAT-004 |

---

### FR-STU-005: Save Basic Learning Activity

| Field | Value |
|---|---|
| Module | Student Learning |
| Priority | MVP |
| Description | The system shall store basic Student learning activity. |
| Actors | Student |
| Preconditions | The Student interacts with learning materials or practice activities. |
| Trigger | Student views materials, starts quizzes, submits quizzes, or practices flashcards. |
| Expected Behavior | The system records basic learning activity for learning history and future personalization. |
| Related User Requirements | UR-STU-008 |
| Related Business Rules | BR-PRAC-003 |

---

## 6. Teacher / Lecturer Requirements

Teacher requirements define how educators apply, manage profiles, upload content, create AI-assisted learning resources, and manage future teaching workflows.

---

### FR-TCH-001: Submit Teacher Application

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Description | The system shall allow users to submit a teacher application. |
| Actors | User |
| Preconditions | The user has a registered account. |
| Trigger | User submits teacher application information. |
| Expected Behavior | The system records the application and sets the application status to Submitted or Pending Review. |
| Related User Requirements | UR-TCH-001, UR-TCH-002 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |

---

### FR-TCH-002: View Teacher Application Status

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Description | The system shall allow teacher applicants to view their application status. |
| Actors | Teacher Applicant |
| Preconditions | The user has submitted a teacher application. |
| Trigger | Applicant opens teacher application status page. |
| Expected Behavior | The system displays the current application status such as Draft, Submitted, Approved, Rejected, or Suspended. |
| Related User Requirements | UR-TCH-002 |
| Related Business Rules | BR-TCH-002, BR-TCH-003 |

---

### FR-TCH-003: Access Teacher Tools After Approval

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Description | The system shall allow only approved Teachers to access teacher tools. |
| Actors | Teacher |
| Preconditions | Teacher application has been approved by Staff. |
| Trigger | Teacher attempts to access teacher tools. |
| Expected Behavior | The system grants access to teacher tools only if the Teacher is approved and active. |
| Related User Requirements | UR-TCH-001, UR-TCH-003 |
| Related Business Rules | BR-TCH-002, BR-TCH-003, BR-TCH-004 |

---

### FR-TCH-004: Create and Maintain Teacher Profile

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Description | The system shall allow Teachers to create and maintain teacher profile information. |
| Actors | Teacher |
| Preconditions | The user is an approved Teacher or teacher applicant. |
| Trigger | Teacher creates or edits profile information. |
| Expected Behavior | The system saves teacher profile information such as subjects, experience, qualifications, introduction, and teaching preferences. |
| Related User Requirements | UR-TCH-002 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |

---

### FR-TCH-005: View Uploaded Materials and Review Status

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Description | The system shall allow Teachers to view their uploaded materials and moderation statuses. |
| Actors | Teacher |
| Preconditions | The Teacher has uploaded at least one material. |
| Trigger | Teacher opens material management area. |
| Expected Behavior | The system displays the Teacher’s uploaded materials and their statuses such as Draft, Pending Review, Approved, Rejected, Needs Revision, Hidden, or Archived. |
| Related User Requirements | UR-TCH-009 |
| Related Business Rules | BR-MAT-003, BR-MAT-006 |

---

### FR-TCH-006: Prevent Unapproved Teacher Uploads

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Description | The system shall prevent unapproved Teachers or regular users from uploading public learning materials. |
| Actors | User, Teacher Applicant, Teacher |
| Preconditions | The user is not an approved Teacher. |
| Trigger | User attempts to upload learning material. |
| Expected Behavior | The system blocks the upload attempt and informs the user that Teacher approval is required. |
| Related User Requirements | UR-TCH-003 |
| Related Business Rules | BR-TCH-003, BR-TCH-004 |

---

## 7. Staff Moderation Requirements

Staff moderation requirements define how Staff members review teacher applications, moderate materials, process reports, and escalate issues.

---

### FR-STF-001: Staff Moderation Dashboard

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Description | The system shall provide Staff with a moderation dashboard. |
| Actors | Staff |
| Preconditions | The user has Staff permissions. |
| Trigger | Staff opens the moderation dashboard. |
| Expected Behavior | The system displays teacher applications, uploaded materials pending review, and moderation tasks available to the Staff member. |
| Related User Requirements | UR-STF-001 |
| Related Business Rules | BR-STF-001, BR-STF-003 |

---

### FR-STF-002: View Teacher Applications

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Description | The system shall allow Staff to view submitted teacher applications. |
| Actors | Staff |
| Preconditions | Submitted teacher applications exist. |
| Trigger | Staff opens teacher application review queue. |
| Expected Behavior | The system displays teacher applications and relevant profile information for review. |
| Related User Requirements | UR-STF-002 |
| Related Business Rules | BR-STF-001 |

---

### FR-STF-003: Approve or Reject Teacher Applications

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Description | The system shall allow Staff to approve or reject teacher applications. |
| Actors | Staff |
| Preconditions | A teacher application is submitted and pending review. |
| Trigger | Staff selects an approval or rejection decision. |
| Expected Behavior | The system updates the teacher application status and grants or denies Teacher permissions accordingly. |
| Related User Requirements | UR-STF-003 |
| Related Business Rules | BR-STF-002, BR-TCH-002, BR-TCH-003 |

---

### FR-STF-004: View Materials Pending Review

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Description | The system shall allow Staff to view learning materials pending review. |
| Actors | Staff |
| Preconditions | Uploaded materials exist with Pending Review or similar moderation status. |
| Trigger | Staff opens material review queue. |
| Expected Behavior | The system displays materials requiring Staff moderation. |
| Related User Requirements | UR-STF-004 |
| Related Business Rules | BR-STF-003, BR-MAT-005 |

---

### FR-STF-005: Moderate Learning Materials

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Description | The system shall allow Staff to approve, reject, request revision, hide, or archive learning materials. |
| Actors | Staff |
| Preconditions | A material exists and is eligible for moderation action. |
| Trigger | Staff selects a moderation action. |
| Expected Behavior | The system updates the material status and controls its visibility based on the selected action. |
| Related User Requirements | UR-STF-005 |
| Related Business Rules | BR-STF-004, BR-MAT-003, BR-MAT-004, BR-MAT-005 |

---

### FR-STF-006: Prevent Staff Self-Review

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Description | The system shall prevent Staff members from reviewing or approving their own teacher application, uploaded materials, courses, quizzes, exams, or AI-generated learning content if they also hold a Teacher role. |
| Actors | Staff, Teacher |
| Preconditions | The user has both Staff and Teacher roles. |
| Trigger | User attempts to moderate their own content or application. |
| Expected Behavior | The system blocks the action and requires another Staff member or Admin to handle the review. |
| Related User Requirements | UR-STF-009 |
| Related Business Rules | BR-TCH-005, BR-STF-005 |

---

### FR-STF-007: Escalate Serious Issues to Admins

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | Phase 2 |
| Description | The system shall allow Staff to escalate serious policy violations, disputes, or high-risk moderation issues to Admins. |
| Actors | Staff, Admin |
| Preconditions | Staff identifies an issue requiring Admin authority. |
| Trigger | Staff selects escalation action. |
| Expected Behavior | The system records the escalation and makes it available for Admin review. |
| Related User Requirements | UR-STF-008, UR-ADM-009 |
| Related Business Rules | BR-STF-007, BR-ADM-006 |

---

### FR-STF-008: Process Reported Content

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | Phase 2 |
| Description | The system shall allow Staff to view and process reported content. |
| Actors | Staff |
| Preconditions | Users have submitted content reports. |
| Trigger | Staff opens reported content queue. |
| Expected Behavior | The system displays reports and allows Staff to take appropriate moderation actions. |
| Related User Requirements | UR-STF-006, UR-GEN-007 |
| Related Business Rules | BR-STF-006 |

---

## 8. Admin Governance Requirements

Admin governance requirements define platform-level authority over roles, Staff permissions, subjects, policies, audits, and overrides.

---

### FR-ADM-001: Admin Governance Dashboard

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Description | The system shall provide Admins with an admin governance dashboard. |
| Actors | Admin |
| Preconditions | The user has Admin permissions. |
| Trigger | Admin opens the admin dashboard. |
| Expected Behavior | The system displays governance tools such as user management, role management, subject management, and platform-level controls. |
| Related User Requirements | UR-ADM-001 |
| Related Business Rules | BR-ADM-001, BR-ADM-002, BR-ADM-003 |

---

### FR-ADM-002: Manage User Accounts

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Description | The system shall allow Admins to view and manage user accounts. |
| Actors | Admin |
| Preconditions | User accounts exist. |
| Trigger | Admin opens user management. |
| Expected Behavior | The system allows Admins to view user accounts and manage account-level governance actions. |
| Related User Requirements | UR-ADM-002 |
| Related Business Rules | BR-ADM-002 |

---

### FR-ADM-003: Assign or Revoke Staff Role

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Description | The system shall allow Admins to assign or revoke the Staff role. |
| Actors | Admin |
| Preconditions | The target user exists. |
| Trigger | Admin updates the target user’s role assignments. |
| Expected Behavior | The system updates the user’s Staff role status and applies Staff permissions accordingly. |
| Related User Requirements | UR-ADM-003, UR-ADM-004 |
| Related Business Rules | BR-ADM-001, BR-ROLE-004, BR-TCH-006 |

---

### FR-ADM-004: Manage Subjects and Categories

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Description | The system shall allow Admins to create, update, and manage subjects and platform-level learning categories. |
| Actors | Admin |
| Preconditions | The actor has Admin permissions. |
| Trigger | Admin creates or updates a subject or category. |
| Expected Behavior | The system saves subject and category changes and makes them available for material categorization and browsing. |
| Related User Requirements | UR-ADM-008 |
| Related Business Rules | BR-ADM-003, BR-MAT-001 |

---

### FR-ADM-005: Audit Staff Moderation Actions

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | Phase 2 |
| Description | The system shall allow Admins to audit Staff moderation actions. |
| Actors | Admin |
| Preconditions | Staff moderation actions have been recorded. |
| Trigger | Admin opens moderation audit logs. |
| Expected Behavior | The system displays Staff decisions related to teacher applications, material moderation, hidden content, and escalated issues. |
| Related User Requirements | UR-ADM-006 |
| Related Business Rules | BR-ADM-004 |

---

### FR-ADM-006: Override Staff Decisions

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | Phase 2 |
| Description | The system shall allow Admins to override Staff decisions when necessary. |
| Actors | Admin |
| Preconditions | A Staff decision exists and is eligible for override. |
| Trigger | Admin selects an override action. |
| Expected Behavior | The system records the override and updates the affected application, material, or moderation case accordingly. |
| Related User Requirements | UR-ADM-007 |
| Related Business Rules | BR-ADM-005 |

---

## 9. Study Material Requirements

Study material requirements define how learning content is created, submitted, reviewed, displayed, and managed.

---

### FR-MAT-001: Upload Study Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Description | The system shall allow approved Teachers to upload study materials. |
| Actors | Teacher |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher uploads material content. |
| Expected Behavior | The system stores the uploaded material and assigns an initial moderation status. |
| Related User Requirements | UR-TCH-003 |
| Related Business Rules | BR-TCH-004, BR-MAT-002, BR-MAT-003 |

---

### FR-MAT-002: Required Material Information

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Description | The system shall require uploaded materials to include basic information such as title, subject, description, and content source. |
| Actors | Teacher |
| Preconditions | Teacher is uploading or editing material. |
| Trigger | Teacher submits material form. |
| Expected Behavior | The system validates required material information before saving or submitting for review. |
| Related User Requirements | UR-TCH-003, UR-TCH-004 |
| Related Business Rules | BR-MAT-001, BR-MAT-002 |

---

### FR-MAT-003: Assign Material Moderation Status

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Description | The system shall assign every uploaded material a moderation status. |
| Actors | Teacher, Staff |
| Preconditions | A material is created or submitted. |
| Trigger | Material is saved, submitted, reviewed, or moderated. |
| Expected Behavior | The system assigns or updates statuses such as Draft, Pending Review, Approved, Rejected, Needs Revision, Hidden, or Archived. |
| Related User Requirements | UR-TCH-003, UR-STF-005 |
| Related Business Rules | BR-MAT-003 |

---

### FR-MAT-004: Submit Material for Review

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Description | The system shall allow Teachers to submit uploaded materials for Staff review. |
| Actors | Teacher |
| Preconditions | The material has required information and belongs to the Teacher. |
| Trigger | Teacher selects submit for review. |
| Expected Behavior | The system changes the material status to Pending Review or equivalent review status. |
| Related User Requirements | UR-TCH-003, UR-TCH-008 |
| Related Business Rules | BR-MAT-003, BR-MAT-005 |

---

### FR-MAT-005: Display Only Approved Materials to Students

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Description | The system shall display only approved and visible materials to Students. |
| Actors | Student |
| Preconditions | Materials exist with different moderation statuses. |
| Trigger | Student browses or searches materials. |
| Expected Behavior | The system excludes Draft, Pending Review, Rejected, Needs Revision, Hidden, and Archived materials from student-facing pages. |
| Related User Requirements | UR-STU-002, UR-STU-004 |
| Related Business Rules | BR-MAT-004 |

---

### FR-MAT-006: Edit Draft or Rejected Materials

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Description | The system shall allow Teachers to edit their own Draft, Rejected, or Needs Revision materials. |
| Actors | Teacher |
| Preconditions | The material belongs to the Teacher and has an editable status. |
| Trigger | Teacher opens material editing. |
| Expected Behavior | The system allows the Teacher to update material content and resubmit it for review if needed. |
| Related User Requirements | UR-TCH-009 |
| Related Business Rules | BR-MAT-006 |

---

### FR-MAT-007: Archive Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | Phase 2 |
| Description | The system shall allow eligible Teachers or Staff to archive materials according to platform rules. |
| Actors | Teacher, Staff |
| Preconditions | The material exists and the actor has permission. |
| Trigger | Actor selects archive action. |
| Expected Behavior | The system changes the material status to Archived and removes it from student-facing discovery. |
| Related User Requirements | UR-TCH-009, UR-STF-005 |
| Related Business Rules | BR-MAT-003, BR-MAT-007 |

---

## 10. AI Quiz and Flashcard Generation Requirements

AI generation requirements define how Teachers use AI to generate draft learning activities and how those activities are reviewed before publication.

---

### FR-AI-001: Generate Quiz from Material

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall allow approved Teachers to generate quizzes from uploaded materials using AI. |
| Actors | Teacher |
| Preconditions | The Teacher is approved and has access to eligible uploaded material. |
| Trigger | Teacher selects AI quiz generation. |
| Expected Behavior | The system generates quiz questions, answer options, correct answers, and explanations where possible. |
| Related User Requirements | UR-TCH-005 |
| Related Business Rules | BR-AI-002, BR-AI-006, BR-PRAC-001 |

---

### FR-AI-002: Generate Flashcards from Material

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall allow approved Teachers to generate flashcards from uploaded materials using AI. |
| Actors | Teacher |
| Preconditions | The Teacher is approved and has access to eligible uploaded material. |
| Trigger | Teacher selects AI flashcard generation. |
| Expected Behavior | The system generates flashcards containing prompts, answers, definitions, formulas, or key concepts where applicable. |
| Related User Requirements | UR-TCH-006 |
| Related Business Rules | BR-AI-002, BR-AI-006, BR-PRAC-001 |

---

### FR-AI-003: Save AI-Generated Content as Draft

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall save AI-generated quizzes and flashcards as drafts by default. |
| Actors | Teacher |
| Preconditions | AI generation is completed. |
| Trigger | AI returns generated content. |
| Expected Behavior | The system stores AI-generated content in a draft or reviewable state before it becomes available to Students. |
| Related User Requirements | UR-TCH-007 |
| Related Business Rules | BR-AI-002, BR-AI-006 |

---

### FR-AI-004: Review and Edit AI-Generated Content

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall allow Teachers to review and edit AI-generated quizzes, flashcards, answers, and explanations. |
| Actors | Teacher |
| Preconditions | AI-generated content exists in draft or reviewable state. |
| Trigger | Teacher opens AI-generated content editor. |
| Expected Behavior | The system allows the Teacher to modify AI-generated content before submission or publication. |
| Related User Requirements | UR-TCH-007 |
| Related Business Rules | BR-AI-002 |

---

### FR-AI-005: Prevent Unreviewed AI Content from Student Access

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall prevent unreviewed AI-generated quizzes and flashcards from being visible to Students. |
| Actors | Teacher, Student |
| Preconditions | AI-generated content exists but has not been reviewed by a Teacher. |
| Trigger | Student attempts to access generated content or content appears in student discovery. |
| Expected Behavior | The system blocks access or excludes the content until review and publication requirements are met. |
| Related User Requirements | UR-TCH-007, UR-STU-005, UR-STU-006 |
| Related Business Rules | BR-AI-002, BR-AI-006 |

---

### FR-AI-006: Mark AI-Assisted Content

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall mark AI-generated or AI-assisted educational content as AI-assisted where appropriate. |
| Actors | Teacher, Student, Staff |
| Preconditions | Content was generated or assisted by AI. |
| Trigger | AI-assisted content is displayed or reviewed. |
| Expected Behavior | The system clearly indicates that the content was generated or assisted by AI. |
| Related User Requirements | UR-GEN-006 |
| Related Business Rules | BR-AI-001 |

---

### FR-AI-007: Discard AI-Generated Content

| Field | Value |
|---|---|
| Module | AI Quiz and Flashcard Generation |
| Priority | MVP |
| Description | The system shall allow Teachers to discard AI-generated content. |
| Actors | Teacher |
| Preconditions | AI-generated content exists. |
| Trigger | Teacher selects discard action. |
| Expected Behavior | The system removes or marks the AI-generated content as discarded according to platform data retention policy. |
| Related User Requirements | UR-TCH-007 |
| Related Business Rules | BR-AI-002 |

---

## 11. Mock Exams Requirements

Mock Exams requirements define how Students participate in practice testing under the Exam Room.

---

### FR-MOCK-001: Start Mock Exam

| Field | Value |
|---|---|
| Module | Mock Exams |
| Priority | MVP |
| Description | The system shall allow Students to start a mock exam (Multiple choice, Flashcard, or Essay). |
| Actors | Student |
| Preconditions | The mock exam is published and active. |
| Trigger | Student selects start mock exam. |
| Expected Behavior | The system starts a mock exam attempt. |
| Related User Requirements | UR-STU-005 |
| Related Business Rules | BR-MOCK-001 |

---

### FR-MOCK-002: Submit Exam Answers

| Field | Value |
|---|---|
| Module | Mock Exams |
| Priority | MVP |
| Description | The system shall allow Students to submit answers for Trắc nghiệm or Tự luận. |
| Actors | Student |
| Preconditions | The Student has an active mock exam attempt. |
| Trigger | Student submits answers. |
| Expected Behavior | The system records the submitted answers and proceeds to scoring (for objective questions). |
| Related User Requirements | UR-STU-005 |
| Related Business Rules | BR-MOCK-002 |

---

### FR-MOCK-003: Store Exam Attempts

| Field | Value |
|---|---|
| Module | Mock Exams |
| Priority | MVP |
| Description | The system shall store Student exam attempts and scores. |
| Actors | Student |
| Preconditions | Student submits or completes an exam attempt. |
| Trigger | Exam attempt is submitted or scored. |
| Expected Behavior | The system stores attempt details for learning history. |
| Related User Requirements | UR-STU-008 |
| Related Business Rules | BR-MOCK-003 |

---

## 12. Search and Discovery Requirements

Search and discovery requirements define how Students find relevant approved learning content.

---

### FR-SEARCH-001: Search Approved Materials by Keyword

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Description | The system shall allow Students to search approved materials by keyword. |
| Actors | Student |
| Preconditions | Approved materials exist. |
| Trigger | Student enters a search query. |
| Expected Behavior | The system returns matching approved and visible materials. |
| Related User Requirements | UR-STU-003 |
| Related Business Rules | BR-MAT-004 |

---

### FR-SEARCH-002: Filter Materials by Subject

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Description | The system shall allow Students to filter materials by subject. |
| Actors | Student |
| Preconditions | Subjects and approved materials exist. |
| Trigger | Student selects a subject filter. |
| Expected Behavior | The system displays approved and visible materials associated with the selected subject. |
| Related User Requirements | UR-STU-002, UR-STU-003 |
| Related Business Rules | BR-MAT-001, BR-MAT-004 |

---

### FR-SEARCH-003: Exclude Unapproved Materials from Search

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Description | The system shall exclude Draft, Pending Review, Rejected, Needs Revision, Hidden, and Archived materials from Student search results. |
| Actors | Student |
| Preconditions | Materials exist with different statuses. |
| Trigger | Student searches or filters materials. |
| Expected Behavior | The system returns only approved and visible materials. |
| Related User Requirements | UR-STU-003 |
| Related Business Rules | BR-MAT-004 |

---

### FR-SEARCH-004: Natural-Language Search

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | Phase 2 |
| Description | The system shall support natural-language search for learning materials. |
| Actors | Student |
| Preconditions | Search index or AI-assisted retrieval capability exists. |
| Trigger | Student enters a natural-language query. |
| Expected Behavior | The system returns relevant approved materials based on the query intent. |
| Related User Requirements | UR-STU-003 |
| Related Business Rules | BR-PER-003 |

---

## 13. Personalization and Recommendation Requirements

Personalization requirements define how Students provide learning context and how AI recommends roadmaps, materials, and Teachers.

---

### FR-PER-001: Submit Learning Personalization Input

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall allow Students to submit learning goals, current level, weak areas, available study time, and learning preferences. |
| Actors | Student |
| Preconditions | The Student is authenticated. |
| Trigger | Student submits personalization input. |
| Expected Behavior | The system stores the Student’s input for AI analysis and personalized recommendations. |
| Related User Requirements | UR-STU-011 |
| Related Business Rules | BR-PER-001, BR-PER-006 |

---

### FR-PER-002: Analyze Student Learning Needs

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall allow AI to analyze Student input and available learning history to identify learning needs, weak areas, and priority topics. |
| Actors | Student, AI System |
| Preconditions | Student has provided input or has learning history available. |
| Trigger | Student requests learning analysis or roadmap generation. |
| Expected Behavior | The system generates an analysis of learning needs and weak areas. |
| Related User Requirements | UR-STU-012 |
| Related Business Rules | BR-PER-001, BR-PER-005 |

---

### FR-PER-003: Generate Personalized Learning Roadmap

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall generate a personalized learning roadmap based on Student goals, weak areas, available time, current level, and platform data. |
| Actors | Student, AI System |
| Preconditions | Student input or learning history is available. |
| Trigger | Student requests a learning roadmap. |
| Expected Behavior | The system generates a recommended roadmap with learning order, suggested topics, and next actions. |
| Related User Requirements | UR-STU-013 |
| Related Business Rules | BR-PER-001, BR-PER-002, BR-PER-005 |

---

### FR-PER-004: Recommend Study Materials

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall recommend approved study materials based on Student roadmap, weak areas, subject interests, and current level. |
| Actors | Student, AI System |
| Preconditions | Approved materials exist and Student personalization context is available. |
| Trigger | Student requests recommendations or views roadmap. |
| Expected Behavior | The system recommends only approved and visible materials. |
| Related User Requirements | UR-STU-014 |
| Related Business Rules | BR-PER-003, BR-MAT-004 |

---

### FR-PER-005: Recommend Verified Teachers

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall recommend verified and active Teachers based on Student subject needs, learning level, schedule, and preferences. |
| Actors | Student, AI System |
| Preconditions | Verified Teachers are available and eligible for recommendation. |
| Trigger | Student requests teacher recommendations or receives roadmap guidance. |
| Expected Behavior | The system recommends only verified and active Teachers. |
| Related User Requirements | UR-STU-015 |
| Related Business Rules | BR-PER-004 |

---

### FR-PER-006: Request More Input When Data Is Insufficient

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall ask Students for more input when there is insufficient data for personalization. |
| Actors | Student, AI System |
| Preconditions | Student personalization request lacks enough context. |
| Trigger | Student requests analysis, roadmap, or recommendations. |
| Expected Behavior | The system asks clarifying questions or provides a general roadmap if appropriate. |
| Related User Requirements | UR-STU-011, UR-STU-012 |
| Related Business Rules | BR-PER-005 |

---

### FR-PER-007: Update Learning Preferences

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Description | The system shall allow Students to update learning goals, weak areas, available study time, and learning preferences. |
| Actors | Student |
| Preconditions | Student has a profile or personalization settings. |
| Trigger | Student edits learning preferences. |
| Expected Behavior | The system updates the stored preferences and uses them for future personalization. |
| Related User Requirements | UR-STU-011 |
| Related Business Rules | BR-PER-006 |

---

## 14. Class and Course Requirements

Class and course requirements are planned after the MVP, once core material and practice workflows are validated.

---

### FR-CLS-001: Create Class

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Description | The system shall allow approved Teachers to create classes. |
| Actors | Teacher |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher creates a class. |
| Expected Behavior | The system creates a class associated with the Teacher. |
| Related User Requirements | UR-TCH-010 |
| Related Business Rules | BR-CLS-001 |

---

### FR-CLS-002: Request Class Enrollment

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Description | The system shall allow Students to request enrollment in teacher-managed classes. |
| Actors | Student |
| Preconditions | The class exists and accepts enrollment requests. |
| Trigger | Student selects request enrollment. |
| Expected Behavior | The system creates an enrollment request for Teacher review. |
| Related User Requirements | UR-STU-017 |
| Related Business Rules | BR-CLS-002 |

---

### FR-CLS-003: Approve or Reject Enrollment Request

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Description | The system shall allow Teachers to approve or reject class enrollment requests. |
| Actors | Teacher |
| Preconditions | A Student has requested enrollment in the Teacher’s class. |
| Trigger | Teacher selects approve or reject. |
| Expected Behavior | The system updates the enrollment status and controls class access accordingly. |
| Related User Requirements | UR-TCH-011 |
| Related Business Rules | BR-CLS-003 |

---

### FR-COURSE-001: Create Structured Course

| Field | Value |
|---|---|
| Module | Course Management |
| Priority | MVP |
| Description | The system shall allow Teachers to create structured courses. |
| Actors | Teacher |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher creates a course. |
| Expected Behavior | The system creates a course structure that can contain modules, lessons, materials, quizzes, and assignments. |
| Related User Requirements | UR-TCH-015 |
| Related Business Rules | BR-CLS-004 |

---

### FR-COURSE-002: Submit Course for Review

| Field | Value |
|---|---|
| Module | Course Management |
| Priority | MVP |
| Description | The system shall allow Teachers to submit courses for Staff review before public listing when required by platform policy. |
| Actors | Teacher, Staff |
| Preconditions | The course exists and is ready for review. |
| Trigger | Teacher submits the course for review. |
| Expected Behavior | The system sends the course to Staff review and controls public visibility based on moderation status. |
| Related User Requirements | UR-TCH-015, UR-STF-005 |
| Related Business Rules | BR-CLS-005 |

---

### FR-WALLET-001: View Wallet Balance

| Field | Value |
|---|---|
| Module | Wallet Management |
| Priority | MVP |
| Description | The system shall display the wallet balance for the authenticated user. |
| Actors | Student, Teacher |
| Preconditions | User is logged in. |
| Trigger | User navigates to their profile or dashboard. |
| Expected Behavior | The current wallet balance is fetched and displayed. |
| Related User Requirements | UR-STU-018 |
| Related Business Rules | BR-WLT-001 |

---

### FR-WALLET-002: Purchase Course via Wallet

| Field | Value |
|---|---|
| Module | Wallet Management |
| Priority | MVP |
| Description | The system shall allow a Student to purchase a Course using their Wallet Balance. |
| Actors | Student |
| Preconditions | Course is active, Student has sufficient balance. |
| Trigger | Student clicks purchase on a course. |
| Expected Behavior | The system deducts the balance, grants access to the course, and records the wallet transaction. |
| Related User Requirements | UR-STU-018 |
| Related Business Rules | BR-WLT-002 |

---

## 15. Parent Requirements

Parent features are future scope and should be developed after core student, teacher, staff, and admin workflows are stable.

---

### FR-PAR-001: Parent Account Access

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Description | The system shall allow Parents to create and access parent accounts. |
| Actors | Parent |
| Preconditions | Parent features are enabled. |
| Trigger | Parent registers or logs in. |
| Expected Behavior | The system provides Parent access to parent-facing features. |
| Related User Requirements | UR-PAR-001 |
| Related Business Rules | BR-PAR-001 |

---

### FR-PAR-002: Link Parent to Student

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Description | The system shall allow Parents to link with Student accounts through verified authorization. |
| Actors | Parent, Student |
| Preconditions | Parent and Student accounts exist. |
| Trigger | Parent requests student linkage or Student authorizes linkage. |
| Expected Behavior | The system verifies the relationship before allowing Parent access to Student learning data. |
| Related User Requirements | UR-PAR-003 |
| Related Business Rules | BR-PAR-002 |

---

### FR-PAR-003: View Student Learning Progress

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Description | The system shall allow authorized Parents to view Student learning progress. |
| Actors | Parent |
| Preconditions | Parent-student relationship is verified. |
| Trigger | Parent opens student progress dashboard. |
| Expected Behavior | The system displays permitted learning progress data. |
| Related User Requirements | UR-PAR-003, UR-PAR-004 |
| Related Business Rules | BR-PAR-002 |

---

## 16. Reporting, Review, and Rating Requirements

Reporting, review, and rating features support content quality, platform trust, and future community features.

---

### FR-REP-001: Report Incorrect or Inappropriate Content

| Field | Value |
|---|---|
| Module | Reporting |
| Priority | Phase 2 |
| Description | The system shall allow users to report incorrect, inappropriate, or low-quality content. |
| Actors | Student, Teacher, Parent |
| Preconditions | The user is authenticated and can access the content. |
| Trigger | User submits a report. |
| Expected Behavior | The system records the report and makes it available for Staff review. |
| Related User Requirements | UR-GEN-007 |
| Related Business Rules | BR-STF-006, BR-AI-005 |

---

### FR-REP-002: Report AI Mistakes

| Field | Value |
|---|---|
| Module | Reporting |
| Priority | Phase 2 |
| Description | The system shall allow users to report incorrect AI-generated explanations, answers, quizzes, flashcards, or recommendations. |
| Actors | Student, Teacher |
| Preconditions | AI-generated or AI-assisted content is visible to the user. |
| Trigger | User submits an AI mistake report. |
| Expected Behavior | The system records the report for Staff review or future quality improvement. |
| Related User Requirements | UR-GEN-007 |
| Related Business Rules | BR-AI-005 |

---

### FR-REV-001: Review Interacted Content

| Field | Value |
|---|---|
| Module | Review and Rating |
| Priority | Future |
| Description | The system shall allow users to review or rate materials, teachers, classes, or courses they have interacted with. |
| Actors | Student, Parent |
| Preconditions | The user has interacted with the target item. |
| Trigger | User submits rating or review. |
| Expected Behavior | The system stores the review and applies platform review visibility rules. |
| Related User Requirements | UR-STU-018, UR-PAR-002 |
| Related Business Rules | BR-REV-001, BR-REV-003 |

---

### FR-REV-002: Prevent Teacher Self-Review

| Field | Value |
|---|---|
| Module | Review and Rating |
| Priority | Future |
| Description | The system shall prevent Teachers from reviewing or rating their own materials, classes, or courses. |
| Actors | Teacher |
| Preconditions | Teacher attempts to review own content. |
| Trigger | Teacher submits review for own content. |
| Expected Behavior | The system blocks the review submission. |
| Related User Requirements | UR-GEN-005 |
| Related Business Rules | BR-REV-002 |

---

## 17. Exam and Assessment Requirements

Exam and assessment features are future scope and should be implemented carefully due to assessment integrity and AI accuracy concerns.

---

### FR-EXAM-001: Create Online Exam

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Description | The system shall allow Teachers to create online exams. |
| Actors | Teacher |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher creates an exam. |
| Expected Behavior | The system creates an online exam with configured questions, settings, and availability rules. |
| Related User Requirements | UR-TCH-016 |
| Related Business Rules | BR-EXAM-001, BR-EXAM-002 |

---

### FR-EXAM-002: Take Online Exam

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Description | The system shall allow Students to take online exams. |
| Actors | Student |
| Preconditions | The exam is available to the Student. |
| Trigger | Student starts the exam. |
| Expected Behavior | The system starts an exam attempt and enforces exam settings. |
| Related User Requirements | UR-STU-019 |
| Related Business Rules | BR-EXAM-001, BR-EXAM-002, BR-EXAM-005 |

---

### FR-EXAM-003: Auto-Grade Objective Questions

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Description | The system shall automatically grade objective exam questions when correct answers or evaluation rules are defined. |
| Actors | Student, Teacher |
| Preconditions | Exam contains objective questions with evaluation rules. |
| Trigger | Student submits exam. |
| Expected Behavior | The system calculates scores for objective questions. |
| Related User Requirements | UR-TCH-016 |
| Related Business Rules | BR-EXAM-003 |

---

### FR-EXAM-004: Require Teacher Review for AI-Assisted Written Grading

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Description | The system shall require Teacher review before finalizing AI-assisted grading for written responses. |
| Actors | Teacher, AI System |
| Preconditions | AI-assisted grading is used for written responses. |
| Trigger | AI generates grading suggestion. |
| Expected Behavior | The system keeps the grading result as a suggestion until Teacher review is completed. |
| Related User Requirements | UR-TCH-014, UR-TCH-016 |
| Related Business Rules | BR-EXAM-004 |

---

## 18. Monetization and Payment Requirements

Monetization and payment features are future scope and should not be included in the MVP unless explicitly required.

---

### FR-PAY-001: Premium Access Control

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Description | The system shall support premium feature access rules if paid plans are introduced. |
| Actors | Student, Parent, Teacher |
| Preconditions | Premium features are enabled. |
| Trigger | User attempts to access premium features. |
| Expected Behavior | The system grants or restricts access based on the user’s plan or entitlement. |
| Related User Requirements | UR-GEN-001 |
| Related Business Rules | BR-PAY-001, BR-PAY-002 |

---

### FR-PAY-002: Teacher Marketplace Transaction Support

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Description | The system shall support teacher marketplace transactions if paid teacher services are introduced. |
| Actors | Student, Parent, Teacher, Admin |
| Preconditions | Marketplace monetization is enabled. |
| Trigger | User initiates a paid teacher service transaction. |
| Expected Behavior | The system processes the transaction according to payment and marketplace policies. |
| Related User Requirements | UR-PAR-002, UR-TCH-015 |
| Related Business Rules | BR-PAY-003 |

---

## 19. MVP Functional Requirement Summary

The MVP should implement the following functional areas first:

- User registration, login, logout.
- Role-based access control.
- Teacher and Staff role separation.
- Admin assignment and revocation of Staff permissions.
- Teacher application submission.
- Staff review and approval of teacher applications.
- Approved Teacher access to teacher tools.
- Study material upload by approved Teachers.
- Material status management.
- Staff material moderation.
- Student browsing of approved materials.
- Student material detail viewing.
- AI quiz generation from materials.
- AI flashcard generation from materials.
- Teacher review and editing of AI-generated content.
- Student quiz and flashcard practice.
- Quiz scoring and feedback.
- Basic learning activity storage.
- Admin subject management.
- Admin governance dashboard.

---

## 20. Notes for Future Refinement

This document defines system behavior at the functional requirement level.

Future documents should refine these requirements into:

- User flows.
- Acceptance criteria.
- Edge cases.
- System architecture.
- Database design.
- API design.
- UI/UX design.
- Testing strategy.
- Implementation tasks.

Each acceptance criterion should reference one or more functional requirements from this document.

Example traceability:

> UR-STU-013 → BR-PER-002 → FR-PER-003 → AC-PER-003

The next recommended document is `04-user-flow.md`, followed by `05-acceptance-criteria.md` and `06-edge-cases.md`.