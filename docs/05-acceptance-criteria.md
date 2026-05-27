# HIPZI Acceptance Criteria

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Acceptance Criteria Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, QA Engineer, Designer, Researcher |
| Language | English |

---

## 1. Purpose

This document defines the acceptance criteria for HIPZI.

Acceptance criteria describe the conditions that must be satisfied for a feature, user flow, or functional requirement to be considered complete and correct.

This document is intended to help:

- Product owners validate feature behavior.
- Developers understand expected outcomes.
- AI coding agents implement and self-check work.
- QA engineers design test cases.
- Designers understand required system states and feedback.

This document focuses on observable behavior and pass/fail conditions. It does not define implementation details, API contracts, database schema, or UI visual design.

---

## 2. Acceptance Criteria Classification

Each acceptance criterion uses a stable ID so that it can be referenced by tests, implementation tasks, user stories, and future documentation.

### 2.1 Acceptance Criteria ID Prefixes

| Prefix | Module |
|---|---|
| AC-AUTH | Authentication and Role Access |
| AC-TCH | Teacher / Lecturer |
| AC-STF | Staff Moderation |
| AC-ADM | Admin Governance |
| AC-MAT | Study Materials |
| AC-AI | AI Content Generation |
| AC-PRAC | Student Practice |
| AC-SEARCH | Search and Discovery |
| AC-PER | Personalization and Recommendation |
| AC-CLS | Class Management |
| AC-COURSE | Course Management |
| AC-PAR | Parent Features |
| AC-REP | Reporting |
| AC-REV | Review and Rating |
| AC-EXAM | Exam and Assessment |
| AC-PAY | Monetization and Payment |

### 2.2 Priority Levels

| Priority | Meaning |
|---|---|
| MVP | Required for the first usable version |
| Phase 2 | Important after the MVP is validated |
| Future | Long-term or advanced feature |

---

## 3. Acceptance Criteria Format

Acceptance criteria should follow the Given / When / Then format.

Example:

> Given an approved Teacher is authenticated,  
> When the Teacher uploads a material with all required information,  
> Then the system saves the material successfully.

Each criterion should be:

- Specific.
- Testable.
- Traceable to functional requirements.
- Traceable to business rules where applicable.
- Written from observable system behavior.
- Free from implementation-specific details unless required.

---

## 4. MVP Acceptance Criteria Overview

The MVP acceptance criteria should validate the following core HIPZI workflow:

> Teacher uploads learning material → Staff reviews and approves content → AI generates quiz or flashcards → Teacher reviews AI-generated content → Student practices → Platform tracks basic learning activity → Staff and Admins govern content quality.

The MVP must verify that:

- Users can register, log in, and log out.
- Role-based access is enforced.
- Teacher and Staff roles are separate by default.
- Staff permissions can only be assigned or revoked by Admins.
- Teacher applications require Staff review.
- Approved Teachers can upload learning materials.
- Staff can moderate uploaded materials.
- Students can only access approved and visible materials.
- AI-generated content is saved as draft by default.
- AI-generated content requires Teacher review before student access.
- Students can practice with quizzes and flashcards.
- Quiz attempts are scored and stored.
- Admins can manage roles and governance-level permissions.

---

## 5. Authentication and Role Access Criteria

### AC-AUTH-001: User Registration

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Related User Flow | UF-AUTH-001 |
| Related Functional Requirements | FR-AUTH-001 |
| Related Business Rules | BR-ROLE-001 |

#### Criteria

- Given a guest user provides valid registration information,  
  When the user submits the registration form,  
  Then the system creates a user account.

- Given the user account is created,  
  Then the system assigns the appropriate default role according to platform policy.

- Given required registration information is missing,  
  When the user submits the registration form,  
  Then the system shows validation errors and does not create the account.

- Given an account already exists with the same unique identifier,  
  When the user submits registration information,  
  Then the system prevents duplicate account creation.

---

### AC-AUTH-002: User Login and Logout

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Related User Flow | UF-AUTH-001 |
| Related Functional Requirements | FR-AUTH-002 |
| Related Business Rules | BR-ROLE-001, BR-ROLE-002 |

#### Criteria

- Given a registered user provides valid credentials,  
  When the user submits the login form,  
  Then the system authenticates the user.

- Given the user is authenticated,  
  When login succeeds,  
  Then the system redirects the user to the appropriate dashboard or landing area based on role.

- Given a user provides invalid credentials,  
  When the user submits the login form,  
  Then the system rejects authentication and shows an error.

- Given an authenticated user selects logout,  
  When logout is completed,  
  Then the system terminates the user session.

---

### AC-AUTH-003: Role-Based Access Control

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Related User Flow | UF-AUTH-002 |
| Related Functional Requirements | FR-AUTH-004 |
| Related Business Rules | BR-ROLE-002, BR-ROLE-005, BR-ROLE-006 |

#### Criteria

- Given an authenticated user attempts to access a protected feature,  
  When the user has the required role or permission,  
  Then the system grants access.

- Given an authenticated user attempts to access a protected feature,  
  When the user does not have the required role or permission,  
  Then the system denies access.

- Given a Student attempts to access Staff moderation tools,  
  When the request is made,  
  Then the system denies access.

- Given a Teacher without Staff role attempts to access Staff moderation tools,  
  When the request is made,  
  Then the system denies access.

- Given a Staff member attempts to access Admin governance tools,  
  When the Staff member does not have Admin permissions,  
  Then the system denies access.

---

### AC-AUTH-004: Teacher and Staff Role Separation

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Related User Flow | UF-AUTH-002 |
| Related Functional Requirements | FR-AUTH-005 |
| Related Business Rules | BR-ROLE-003, BR-ROLE-004 |

#### Criteria

- Given a user is assigned the Teacher role,  
  When the user accesses the platform,  
  Then the user does not automatically receive Staff permissions.

- Given a user is assigned the Staff role,  
  When the user accesses the platform,  
  Then the user does not automatically receive Teacher permissions.

- Given a user should hold both Teacher and Staff roles,  
  When an Admin explicitly assigns both roles,  
  Then the system grants both sets of permissions according to role rules.

- Given a user has both Teacher and Staff roles,  
  Then the system must still enforce self-review prevention rules.

---

### AC-AUTH-005: Admin Assigns or Revokes Staff Role

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-AUTH-003, FR-AUTH-006, FR-ADM-003 |
| Related Business Rules | BR-ROLE-004, BR-ADM-001, BR-ADM-002 |

#### Criteria

- Given an authenticated Admin selects a user,  
  When the Admin assigns the Staff role,  
  Then the system grants Staff permissions to the selected user.

- Given a user has been assigned the Staff role,  
  When the user logs in,  
  Then the user can access Staff moderation tools.

- Given an authenticated Admin revokes the Staff role from a user,  
  When the change is saved,  
  Then the system removes Staff permissions from that user.

- Given a non-Admin user attempts to assign or revoke Staff permissions,  
  When the request is made,  
  Then the system denies the action.

---

## 6. Teacher / Lecturer Criteria

### AC-TCH-001: Submit Teacher Application

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Related User Flow | UF-TCH-001 |
| Related Functional Requirements | FR-TCH-001 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |

#### Criteria

- Given a registered user wants to become a Teacher,  
  When the user submits valid teacher application information,  
  Then the system creates a teacher application.

- Given the teacher application is created,  
  Then the system sets the application status to Submitted or Pending Review.

- Given required teacher application information is missing,  
  When the user submits the application,  
  Then the system shows validation errors and does not submit the application.

- Given a user already has a pending teacher application,  
  When the user attempts to submit another application,  
  Then the system prevents duplicate submission.

---

### AC-TCH-002: View Teacher Application Status

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Related User Flow | UF-TCH-002 |
| Related Functional Requirements | FR-TCH-002 |
| Related Business Rules | BR-TCH-002, BR-TCH-003 |

#### Criteria

- Given a user has submitted a teacher application,  
  When the user opens the application status page,  
  Then the system displays the current application status.

- Given the application has been approved,  
  When the applicant views the status,  
  Then the system shows the approved status.

- Given the application has been rejected,  
  When the applicant views the status,  
  Then the system shows the rejected status and rejection reason when available.

- Given the user has not submitted a teacher application,  
  When the user opens the teacher application status page,  
  Then the system shows an option to start a teacher application.

---

### AC-TCH-003: Approved Teacher Access to Teacher Tools

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Related User Flow | UF-TCH-002 |
| Related Functional Requirements | FR-TCH-003 |
| Related Business Rules | BR-TCH-002, BR-TCH-003, BR-TCH-004 |

#### Criteria

- Given a teacher application has been approved by Staff,  
  When the applicant accesses the platform,  
  Then the system grants Teacher permissions.

- Given an approved Teacher opens the teacher dashboard,  
  When the request is made,  
  Then the system displays teacher tools.

- Given a user is not an approved Teacher,  
  When the user attempts to access teacher-only tools,  
  Then the system denies access.

- Given a teacher application has been rejected,  
  When the applicant attempts to access teacher tools,  
  Then the system denies access.

---

### AC-TCH-004: Teacher Profile Management

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Related User Flow | UF-TCH-001 |
| Related Functional Requirements | FR-TCH-004 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |

#### Criteria

- Given a teacher applicant or approved Teacher opens profile editing,  
  When the user submits valid profile information,  
  Then the system saves the profile information.

- Given profile information includes teaching subjects, experience, qualifications, introduction, or teaching preferences,  
  When the profile is saved,  
  Then the system stores the provided information.

- Given required profile information is missing,  
  When the user submits the profile,  
  Then the system shows validation errors.

---

## 7. Staff Moderation Criteria

### AC-STF-001: Staff Moderation Dashboard Access

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Related User Flow | UF-STF-001, UF-STF-002 |
| Related Functional Requirements | FR-STF-001 |
| Related Business Rules | BR-ROLE-006, BR-STF-001, BR-STF-003 |

#### Criteria

- Given an authenticated user has Staff permissions,  
  When the user opens the moderation dashboard,  
  Then the system displays Staff moderation tools.

- Given an authenticated user does not have Staff permissions,  
  When the user attempts to open the moderation dashboard,  
  Then the system denies access.

- Given Staff moderation tasks exist,  
  When Staff opens the dashboard,  
  Then the system displays available moderation queues.

---

### AC-STF-002: Staff Reviews Teacher Applications

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Related User Flow | UF-STF-001 |
| Related Functional Requirements | FR-STF-002, FR-STF-003 |
| Related Business Rules | BR-STF-001, BR-STF-002, BR-TCH-002, BR-TCH-003 |

#### Criteria

- Given submitted teacher applications exist,  
  When Staff opens the teacher application queue,  
  Then the system displays applications pending review.

- Given Staff selects a teacher application,  
  When the application details are opened,  
  Then the system displays relevant applicant information.

- Given Staff approves a teacher application,  
  When the approval is saved,  
  Then the application status becomes Approved.

- Given Staff approves a teacher application,  
  When the approval is saved,  
  Then the applicant receives Teacher permissions.

- Given Staff rejects a teacher application,  
  When the rejection is saved,  
  Then the application status becomes Rejected.

- Given Staff rejects a teacher application,  
  When the rejection is saved,  
  Then the applicant does not receive Teacher permissions.

---

### AC-STF-003: Staff Reviews Uploaded Materials

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Related User Flow | UF-STF-002 |
| Related Functional Requirements | FR-STF-004, FR-STF-005 |
| Related Business Rules | BR-STF-003, BR-STF-004, BR-MAT-003, BR-MAT-005 |

#### Criteria

- Given materials are submitted for review,  
  When Staff opens the material review queue,  
  Then the system displays materials with Pending Review status.

- Given Staff selects a pending material,  
  When the material is opened,  
  Then the system displays title, subject, description, content, owner, and moderation status.

- Given Staff approves a pending material,  
  When the action is saved,  
  Then the material status becomes Approved.

- Given Staff rejects a pending material,  
  When the action is saved,  
  Then the material status becomes Rejected.

- Given Staff requests revision for a material,  
  When the action is saved,  
  Then the material status becomes Needs Revision.

- Given Staff hides a material,  
  When the action is saved,  
  Then the material status becomes Hidden.

- Given Staff archives a material,  
  When the action is saved,  
  Then the material status becomes Archived.

---

### AC-STF-004: Staff Self-Review Prevention

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Related User Flow | UF-STF-001, UF-STF-002 |
| Related Functional Requirements | FR-STF-006 |
| Related Business Rules | BR-TCH-005, BR-STF-005 |

#### Criteria

- Given a user has both Teacher and Staff roles,  
  When the user attempts to review their own teacher application,  
  Then the system blocks the action.

- Given a user has both Teacher and Staff roles,  
  When the user attempts to approve their own uploaded material,  
  Then the system blocks the action.

- Given a user has both Teacher and Staff roles,  
  When the user attempts to moderate their own AI-generated learning content,  
  Then the system blocks the action.

- Given self-review is blocked,  
  Then the system requires another Staff member or Admin to handle the review.

---

### AC-STF-005: Staff Escalates Serious Issues

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | Phase 2 |
| Related User Flow | UF-STF-003 |
| Related Functional Requirements | FR-STF-007 |
| Related Business Rules | BR-STF-007, BR-ADM-006 |

#### Criteria

- Given Staff identifies a serious policy violation or dispute,  
  When Staff selects escalation,  
  Then the system creates an escalation case for Admin review.

- Given an issue is escalated,  
  When Admin opens governance tools,  
  Then the escalated issue is visible to Admin.

- Given Staff does not have authority to resolve an issue,  
  When escalation is required,  
  Then Staff can escalate instead of making a final decision.

---

## 8. Admin Governance Criteria

### AC-ADM-001: Admin Governance Dashboard Access

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-ADM-001 |
| Related Business Rules | BR-ROLE-005, BR-ADM-001, BR-ADM-002 |

#### Criteria

- Given an authenticated Admin,  
  When the Admin opens the governance dashboard,  
  Then the system displays Admin governance tools.

- Given a non-Admin user attempts to access the governance dashboard,  
  When the request is made,  
  Then the system denies access.

- Given Admin governance tools are displayed,  
  Then the Admin can access user and role management features.

---

### AC-ADM-002: Admin Manages User Roles

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-ADM-002, FR-ADM-003 |
| Related Business Rules | BR-ADM-001, BR-ADM-002, BR-ROLE-004 |

#### Criteria

- Given an Admin opens user management,  
  When user accounts exist,  
  Then the system displays manageable user accounts.

- Given an Admin assigns a role to a user,  
  When the change is saved,  
  Then the system updates the user’s role assignments.

- Given an Admin revokes a role from a user,  
  When the change is saved,  
  Then the system removes the corresponding permissions.

- Given a role assignment changes,  
  Then the system applies the updated permissions on the user’s next access or active session refresh.

---

### AC-ADM-003: Admin Manages Subjects and Categories

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-ADM-004 |
| Related Business Rules | BR-ADM-003, BR-MAT-001 |

#### Criteria

- Given an Admin creates a subject with valid information,  
  When the subject is saved,  
  Then the system makes the subject available for material categorization.

- Given an Admin updates a subject,  
  When the update is saved,  
  Then the system applies the updated subject information.

- Given a Teacher uploads material,  
  When subjects are available,  
  Then the Teacher can select an available subject.

- Given a Student browses subjects,  
  When subjects are available,  
  Then the system displays available subjects.

---

### AC-ADM-004: Admin Audits Staff Actions

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | Phase 2 |
| Related User Flow | UF-ADM-002 |
| Related Functional Requirements | FR-ADM-005 |
| Related Business Rules | BR-ADM-004 |

#### Criteria

- Given Staff moderation actions have been recorded,  
  When Admin opens moderation audit logs,  
  Then the system displays Staff moderation actions.

- Given Admin filters moderation logs,  
  When matching actions exist,  
  Then the system displays matching results.

- Given Admin opens a Staff action record,  
  Then the system displays decision details, actor, target item, status change, and timestamp where available.

---

### AC-ADM-005: Admin Overrides Staff Decision

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | Phase 2 |
| Related User Flow | UF-ADM-003 |
| Related Functional Requirements | FR-ADM-006 |
| Related Business Rules | BR-ADM-005, BR-ADM-006 |

#### Criteria

- Given a Staff decision exists and is eligible for override,  
  When Admin performs an override action,  
  Then the system updates the affected record.

- Given Admin overrides a Staff decision,  
  Then the system records the override action.

- Given an override affects material visibility,  
  When the override is saved,  
  Then student-facing access updates accordingly.

- Given an override affects teacher status,  
  When the override is saved,  
  Then Teacher permissions update accordingly.

---

## 9. Study Material Criteria

### AC-MAT-001: Approved Teacher Uploads Study Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Related User Flow | UF-MAT-001 |
| Related Functional Requirements | FR-MAT-001, FR-MAT-002 |
| Related Business Rules | BR-TCH-004, BR-MAT-001, BR-MAT-002 |

#### Criteria

- Given an authenticated user is an approved Teacher,  
  When the Teacher uploads a material with required information,  
  Then the system saves the material successfully.

- Given the material is saved,  
  Then the system assigns the Teacher as the material owner.

- Given the material is saved,  
  Then the system associates the material with at least one subject or learning category.

- Given required material information is missing,  
  When the Teacher submits the material,  
  Then the system shows validation errors.

- Given an unauthenticated user or unapproved Teacher attempts to upload material,  
  When the upload action is attempted,  
  Then the system blocks the action.

---

### AC-MAT-002: Material Moderation Status

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Related User Flow | UF-MAT-001, UF-STF-002 |
| Related Functional Requirements | FR-MAT-003, FR-MAT-004 |
| Related Business Rules | BR-MAT-003, BR-MAT-005 |

#### Criteria

- Given a Teacher saves a material without submitting it for review,  
  When the save action succeeds,  
  Then the material status becomes Draft.

- Given a Teacher submits a material for review,  
  When the submission succeeds,  
  Then the material status becomes Pending Review.

- Given Staff approves a Pending Review material,  
  When the action is saved,  
  Then the material status becomes Approved.

- Given Staff rejects a Pending Review material,  
  When the action is saved,  
  Then the material status becomes Rejected.

- Given Staff requests revision,  
  When the action is saved,  
  Then the material status becomes Needs Revision.

- Given Staff hides a material,  
  When the action is saved,  
  Then the material status becomes Hidden.

- Given Staff archives a material,  
  When the action is saved,  
  Then the material status becomes Archived.

---

### AC-MAT-003: Student Material Visibility

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-MAT-005, FR-STU-003, FR-STU-004 |
| Related Business Rules | BR-MAT-004 |

#### Criteria

- Given a material is Approved and visible,  
  When a Student browses materials,  
  Then the material is displayed.

- Given a material is Draft,  
  When a Student browses materials,  
  Then the material is not displayed.

- Given a material is Pending Review,  
  When a Student browses materials,  
  Then the material is not displayed.

- Given a material is Rejected,  
  When a Student browses materials,  
  Then the material is not displayed.

- Given a material is Needs Revision,  
  When a Student browses materials,  
  Then the material is not displayed.

- Given a material is Hidden,  
  When a Student browses materials,  
  Then the material is not displayed.

- Given a material is Archived,  
  When a Student browses materials,  
  Then the material is not displayed.

---

### AC-MAT-004: Teacher Revises Material After Feedback

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Related User Flow | UF-MAT-002 |
| Related Functional Requirements | FR-MAT-006 |
| Related Business Rules | BR-MAT-006 |

#### Criteria

- Given a Teacher owns a material with Rejected or Needs Revision status,  
  When the Teacher opens the material editor,  
  Then the system allows the Teacher to edit the material.

- Given the Teacher edits the material and saves changes,  
  Then the system stores the updated material.

- Given the Teacher resubmits the revised material,  
  Then the system changes the material status to Pending Review.

- Given a Teacher attempts to edit another Teacher’s material,  
  Then the system denies access.

---

## 10. AI Content Generation Criteria

### AC-AI-001: Generate Quiz with AI

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Related User Flow | UF-AI-001 |
| Related Functional Requirements | FR-AI-001, FR-AI-003 |
| Related Business Rules | BR-AI-002, BR-AI-006, BR-PRAC-001 |

#### Criteria

- Given an approved Teacher has access to eligible material,  
  When the Teacher selects Generate Quiz,  
  Then the system generates a quiz draft using AI.

- Given AI quiz generation succeeds,  
  Then the system saves the generated quiz as Draft.

- Given the quiz is generated by AI,  
  Then the system marks the quiz as AI-assisted.

- Given AI generation fails,  
  Then the system shows an error and does not publish any generated content to Students.

---

### AC-AI-002: Generate Flashcards with AI

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Related User Flow | UF-AI-002 |
| Related Functional Requirements | FR-AI-002, FR-AI-003 |
| Related Business Rules | BR-AI-002, BR-AI-006, BR-PRAC-001 |

#### Criteria

- Given an approved Teacher has access to eligible material,  
  When the Teacher selects Generate Flashcards,  
  Then the system generates flashcard drafts using AI.

- Given AI flashcard generation succeeds,  
  Then the system saves the generated flashcards as Draft.

- Given the flashcards are generated by AI,  
  Then the system marks them as AI-assisted.

- Given AI generation fails,  
  Then the system shows an error and does not publish any generated flashcards to Students.

---

### AC-AI-003: Teacher Reviews AI-Generated Content

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Related User Flow | UF-AI-003 |
| Related Functional Requirements | FR-AI-004 |
| Related Business Rules | BR-AI-002 |

#### Criteria

- Given AI-generated content exists in Draft state,  
  When the Teacher opens the content editor,  
  Then the system allows the Teacher to review the content.

- Given the Teacher edits AI-generated content,  
  When the changes are saved,  
  Then the system stores the edited content.

- Given the Teacher completes review,  
  When the review action is saved,  
  Then the system marks the content as Teacher Reviewed.

- Given the Teacher discards AI-generated content,  
  When the discard action is confirmed,  
  Then the system removes or marks the content as discarded according to platform policy.

---

### AC-AI-004: Unreviewed AI Content Is Not Visible to Students

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Related User Flow | UF-AI-003 |
| Related Functional Requirements | FR-AI-005 |
| Related Business Rules | BR-AI-002, BR-AI-006 |

#### Criteria

- Given an AI-generated quiz has not been reviewed by a Teacher,  
  When a Student views available practice activities,  
  Then the quiz is not displayed.

- Given AI-generated flashcards have not been reviewed by a Teacher,  
  When a Student views available practice activities,  
  Then the flashcards are not displayed.

- Given AI-generated content requires Staff approval according to policy,  
  When Teacher review is completed but Staff approval is missing,  
  Then the content remains unavailable to Students.

---

### AC-AI-005: AI-Assisted Label Visibility

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Related User Flow | UF-AI-001, UF-AI-002, UF-AI-003 |
| Related Functional Requirements | FR-AI-006 |
| Related Business Rules | BR-AI-001 |

#### Criteria

- Given content was generated or assisted by AI,  
  When the content is displayed to Teacher, Staff, or Student,  
  Then the system indicates that the content is AI-assisted where appropriate.

- Given AI-assisted content is reviewed or edited by a Teacher,  
  Then the AI-assisted origin remains traceable according to platform policy.

---

## 11. Student Practice Criteria

### AC-PRAC-001: Start Practice Quiz

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-001 |
| Related Business Rules | BR-PRAC-001, BR-MAT-004 |

#### Criteria

- Given a Student opens an approved and visible quiz,  
  When the Student selects Start Quiz,  
  Then the system creates a quiz attempt.

- Given the quiz is not approved or not visible,  
  When the Student attempts to start it,  
  Then the system blocks access.

- Given the quiz is no longer available,  
  When the Student attempts to start it,  
  Then the system shows an appropriate unavailable state.

---

### AC-PRAC-002: Submit Quiz Answers

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-002 |
| Related Business Rules | BR-PRAC-002, BR-PRAC-003 |

#### Criteria

- Given a Student has started a quiz attempt,  
  When the Student submits answers,  
  Then the system records the submitted answers.

- Given required answers are missing according to quiz rules,  
  When the Student submits,  
  Then the system either prevents submission or handles unanswered questions according to quiz settings.

- Given the quiz attempt has already been submitted,  
  When the Student attempts duplicate submission,  
  Then the system prevents duplicate scoring.

---

### AC-PRAC-003: Calculate and Display Quiz Results

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-003, FR-PRAC-004 |
| Related Business Rules | BR-PRAC-002, BR-PRAC-004 |

#### Criteria

- Given a quiz has valid answer keys or evaluation rules,  
  When the Student submits the quiz,  
  Then the system calculates the quiz score.

- Given the quiz is scored,  
  When the result page is displayed,  
  Then the Student sees the score.

- Given the quiz is scored,  
  Then the Student can see correct and incorrect answers where quiz settings allow.

- Given explanations are available,  
  Then the system displays explanations after submission where appropriate.

- Given a quiz lacks valid evaluation rules,  
  Then the system does not produce an invalid score.

---

### AC-PRAC-004: Store Quiz Attempt in Learning History

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-005, FR-STU-005 |
| Related Business Rules | BR-PRAC-003 |

#### Criteria

- Given a Student submits a quiz attempt,  
  When the attempt is processed,  
  Then the system stores the attempt in learning history.

- Given the attempt is stored,  
  Then the Student can access basic attempt history where learning history is available.

- Given future personalization uses learning history,  
  Then stored quiz attempts are available as input according to platform policy.

---

### AC-PRAC-005: Retake Practice Quiz

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-006 |
| Related Business Rules | BR-PRAC-005 |

#### Criteria

- Given a quiz is a practice quiz and retakes are allowed,  
  When the Student selects Retake,  
  Then the system creates a new quiz attempt.

- Given the activity is restricted or configured as non-retakable,  
  When the Student attempts a retake,  
  Then the system blocks the retake.

- Given a new retake attempt is created,  
  Then the previous attempt remains preserved in learning history.

---

### AC-PRAC-006: Practice with Flashcards

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Related User Flow | UF-PRAC-002 |
| Related Functional Requirements | FR-PRAC-007 |
| Related Business Rules | BR-PRAC-001, BR-MAT-004 |

#### Criteria

- Given approved and visible flashcards exist,  
  When the Student opens the flashcard set,  
  Then the system displays flashcards for practice.

- Given the Student reveals a flashcard answer,  
  Then the system displays the answer or explanation.

- Given the flashcard set is hidden or not approved,  
  When the Student attempts to open it,  
  Then the system blocks access.

- Given the flashcard set is empty,  
  Then the system displays an empty state.

---

## 12. Search and Discovery Criteria

### AC-SEARCH-001: Search Approved Materials by Keyword

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-SEARCH-001 |
| Related Business Rules | BR-MAT-004 |

#### Criteria

- Given approved and visible materials exist,  
  When a Student searches by keyword,  
  Then the system returns matching approved and visible materials.

- Given no materials match the keyword,  
  When the Student searches,  
  Then the system displays an empty state.

- Given matching materials exist but are not approved or not visible,  
  When the Student searches,  
  Then those materials are excluded from results.

---

### AC-SEARCH-002: Filter Materials by Subject

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-SEARCH-002 |
| Related Business Rules | BR-MAT-001, BR-MAT-004 |

#### Criteria

- Given subjects and approved materials exist,  
  When a Student selects a subject filter,  
  Then the system displays approved and visible materials associated with that subject.

- Given a subject has no approved materials,  
  When the Student selects the subject,  
  Then the system displays an empty state.

- Given materials under a subject are hidden, rejected, archived, or pending review,  
  When the Student filters by that subject,  
  Then those materials are excluded.

---

### AC-SEARCH-003: Natural-Language Search

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | Phase 2 |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-SEARCH-004 |
| Related Business Rules | BR-PER-003, BR-MAT-004 |

#### Criteria

- Given natural-language search is enabled,  
  When a Student enters a learning-related query,  
  Then the system returns relevant approved and visible materials.

- Given the query is vague,  
  When search results are generated,  
  Then the system may show broad results, suggestions, or an empty state.

- Given hidden or unapproved materials match the query,  
  Then the system excludes those materials from results.

---

## 13. Personalization and Recommendation Criteria

### AC-PER-001: Submit Learning Personalization Input

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Related User Flow | UF-PER-001 |
| Related Functional Requirements | FR-PER-001, FR-PER-007 |
| Related Business Rules | BR-PER-001, BR-PER-006 |

#### Criteria

- Given an authenticated Student provides learning goals, current level, weak areas, available study time, and learning preferences,  
  When the Student submits personalization input,  
  Then the system saves the input.

- Given required personalization information is missing,  
  When the Student submits the form,  
  Then the system asks for missing information or allows partial input according to platform policy.

- Given a Student updates learning preferences,  
  When the update is saved,  
  Then the system uses the updated information for future personalization.

---

### AC-PER-002: AI Analyzes Learning Needs

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Related User Flow | UF-PER-002 |
| Related Functional Requirements | FR-PER-002 |
| Related Business Rules | BR-PER-001, BR-PER-005 |

#### Criteria

- Given a Student has provided learning input or has learning history,  
  When the Student requests AI analysis,  
  Then the system analyzes the Student’s learning needs.

- Given the system has enough context,  
  Then the system identifies weak areas and priority topics.

- Given the system has insufficient context,  
  Then the system asks clarifying questions or provides a general analysis.

---

### AC-PER-003: Generate Personalized Learning Roadmap

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Related User Flow | UF-PER-002 |
| Related Functional Requirements | FR-PER-003 |
| Related Business Rules | BR-PER-001, BR-PER-002, BR-PER-005 |

#### Criteria

- Given Student learning context is available,  
  When the Student requests a roadmap,  
  Then the system generates a personalized learning roadmap.

- Given a roadmap is generated,  
  Then the roadmap includes recommended learning order, topics, and next actions.

- Given the roadmap is displayed,  
  Then the system presents it as a recommendation, not a mandatory academic requirement.

- Given the Student changes goals or weak areas,  
  When roadmap generation is requested again,  
  Then the roadmap reflects the updated context.

---

### AC-PER-004: Recommend Study Materials

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Related User Flow | UF-PER-003 |
| Related Functional Requirements | FR-PER-004 |
| Related Business Rules | BR-PER-003, BR-MAT-004 |

#### Criteria

- Given a Student has a roadmap or learning context,  
  When material recommendations are generated,  
  Then the system recommends relevant study materials.

- Given recommended materials are displayed,  
  Then all recommended materials must be approved and visible.

- Given no approved materials match the Student’s needs,  
  Then the system shows fallback suggestions or asks the Student to broaden criteria.

- Given a recommended material becomes hidden or archived,  
  Then the system removes it from recommendations.

---

### AC-PER-005: Recommend Verified Teachers

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Related User Flow | UF-PER-003 |
| Related Functional Requirements | FR-PER-005 |
| Related Business Rules | BR-PER-004 |

#### Criteria

- Given a Student has learning needs or roadmap context,  
  When Teacher recommendations are generated,  
  Then the system recommends relevant Teachers.

- Given Teachers are recommended,  
  Then all recommended Teachers must be verified and active.

- Given no verified Teachers match the Student’s criteria,  
  Then the system shows fallback options or asks the Student to broaden preferences.

- Given a Teacher becomes inactive or unverified,  
  Then the system removes that Teacher from recommendations.

---

## 14. Class and Course Criteria

### AC-CLS-001: Teacher Creates Class

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Related User Flow | UF-CLS-001 |
| Related Functional Requirements | FR-CLS-001 |
| Related Business Rules | BR-CLS-001 |

#### Criteria

- Given an approved Teacher creates a class with required information,  
  When the class is saved,  
  Then the system creates the class.

- Given an unapproved Teacher attempts to create a class,  
  When the action is attempted,  
  Then the system blocks the action.

- Given required class information is missing,  
  When the Teacher submits the class form,  
  Then the system shows validation errors.

---

### AC-CLS-002: Student Requests Class Enrollment

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Related User Flow | UF-CLS-002 |
| Related Functional Requirements | FR-CLS-002 |
| Related Business Rules | BR-CLS-002 |

#### Criteria

- Given a class accepts enrollment requests,  
  When a Student requests enrollment,  
  Then the system creates an enrollment request.

- Given an enrollment request is created,  
  Then the status becomes Requested.

- Given the Student has already requested enrollment,  
  When the Student attempts another request,  
  Then the system prevents duplicate requests.

---

### AC-CLS-003: Teacher Approves Enrollment

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Related User Flow | UF-CLS-003 |
| Related Functional Requirements | FR-CLS-003 |
| Related Business Rules | BR-CLS-003 |

#### Criteria

- Given a Student enrollment request exists,  
  When the Teacher approves the request,  
  Then the enrollment status becomes Approved.

- Given the enrollment is approved,  
  Then the Student gains access to class-specific materials according to class settings.

- Given the Teacher rejects the request,  
  Then the enrollment status becomes Rejected.

- Given the enrollment is rejected,  
  Then the Student does not gain class access.

---

### AC-COURSE-001: Teacher Creates Structured Course

| Field | Value |
|---|---|
| Module | Course Management |
| Priority | Future |
| Related User Flow | UF-COURSE-001 |
| Related Functional Requirements | FR-COURSE-001 |
| Related Business Rules | BR-CLS-004 |

#### Criteria

- Given an approved Teacher creates a course,  
  When required course information is provided,  
  Then the system saves the course.

- Given a Teacher adds modules and lessons,  
  When the course is saved,  
  Then the system preserves the course structure.

- Given a course contains materials, quizzes, or assignments,  
  Then those items are associated with the correct lesson or module.

---

### AC-COURSE-002: Staff Reviews Course Before Public Listing

| Field | Value |
|---|---|
| Module | Course Management |
| Priority | Future |
| Related User Flow | UF-COURSE-001 |
| Related Functional Requirements | FR-COURSE-002 |
| Related Business Rules | BR-CLS-005 |

#### Criteria

- Given platform policy requires course review,  
  When a Teacher submits a course for public listing,  
  Then the course enters Staff review.

- Given Staff approves the course,  
  Then the course becomes eligible for public listing.

- Given Staff rejects or requests revision,  
  Then the course remains unavailable for public listing.

---

## 15. Parent Criteria

### AC-PAR-001: Parent Links to Student Account

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Related User Flow | UF-PAR-001 |
| Related Functional Requirements | FR-PAR-001, FR-PAR-002 |
| Related Business Rules | BR-PAR-001, BR-PAR-002 |

#### Criteria

- Given Parent features are enabled,  
  When a Parent requests linkage to a Student account,  
  Then the system starts a verification process.

- Given the parent-student relationship is verified,  
  Then the system creates the linkage.

- Given the relationship is not verified,  
  Then the system denies access to Student learning data.

---

### AC-PAR-002: Parent Views Student Progress

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Related User Flow | UF-PAR-002 |
| Related Functional Requirements | FR-PAR-003 |
| Related Business Rules | BR-PAR-002 |

#### Criteria

- Given a Parent has a verified relationship with a Student,  
  When the Parent opens the progress dashboard,  
  Then the system displays permitted Student learning data.

- Given the Parent does not have verified authorization,  
  When the Parent attempts to view Student progress,  
  Then the system denies access.

- Given Student progress data is unavailable,  
  Then the system displays an empty state.

---

## 16. Reporting, Review, and Rating Criteria

### AC-REP-001: User Reports Content or AI Mistake

| Field | Value |
|---|---|
| Module | Reporting |
| Priority | Phase 2 |
| Related User Flow | UF-REP-001 |
| Related Functional Requirements | FR-REP-001, FR-REP-002 |
| Related Business Rules | BR-STF-006, BR-AI-005 |

#### Criteria

- Given an authenticated user can access content,  
  When the user submits a report,  
  Then the system records the report.

- Given the report is recorded,  
  Then the report becomes available for Staff review.

- Given required report information is missing,  
  When the user submits the report,  
  Then the system shows validation errors or requests additional information.

- Given the report is about AI-generated content,  
  Then the report is associated with the AI-assisted content record where applicable.

---

### AC-REV-001: User Reviews Interacted Content

| Field | Value |
|---|---|
| Module | Review and Rating |
| Priority | Future |
| Related User Flow | UF-REV-001 |
| Related Functional Requirements | FR-REV-001 |
| Related Business Rules | BR-REV-001, BR-REV-003 |

#### Criteria

- Given a user has interacted with a material, Teacher, class, or course,  
  When the user submits a valid review,  
  Then the system saves the review.

- Given a user has not interacted with the target item,  
  When the user attempts to submit a review,  
  Then the system blocks the review.

- Given a review violates platform policy,  
  When Staff moderates the review,  
  Then the review may be hidden or removed.

---

### AC-REV-002: Prevent Teacher Self-Review

| Field | Value |
|---|---|
| Module | Review and Rating |
| Priority | Future |
| Related User Flow | UF-REV-001 |
| Related Functional Requirements | FR-REV-002 |
| Related Business Rules | BR-REV-002 |

#### Criteria

- Given a Teacher attempts to review their own material,  
  When the review is submitted,  
  Then the system blocks the review.

- Given a Teacher attempts to review their own class or course,  
  When the review is submitted,  
  Then the system blocks the review.

---

## 17. Exam and Assessment Criteria

### AC-EXAM-001: Teacher Creates Online Exam

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Related User Flow | UF-EXAM-001 |
| Related Functional Requirements | FR-EXAM-001 |
| Related Business Rules | BR-EXAM-001, BR-EXAM-002 |

#### Criteria

- Given an approved Teacher creates an exam with required information,  
  When the exam is saved,  
  Then the system creates the exam.

- Given exam timing, attempt limits, or availability windows are configured,  
  Then the system stores those settings.

- Given required exam information is missing,  
  Then the system shows validation errors.

---

### AC-EXAM-002: Student Takes Online Exam

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-002 |
| Related Business Rules | BR-EXAM-001, BR-EXAM-002, BR-EXAM-005 |

#### Criteria

- Given an exam is available to a Student,  
  When the Student starts the exam,  
  Then the system creates an exam attempt.

- Given a Student submits the exam,  
  Then the system records the submission.

- Given the exam has not been submitted,  
  When the Student attempts to access correct answers,  
  Then the system blocks access.

- Given the exam availability window has closed,  
  When the Student attempts to start the exam,  
  Then the system blocks access.

---

### AC-EXAM-003: Auto-Grade Objective Questions

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-003 |
| Related Business Rules | BR-EXAM-003 |

#### Criteria

- Given an exam contains objective questions with valid answer keys,  
  When the Student submits the exam,  
  Then the system automatically grades objective questions.

- Given objective grading is completed,  
  Then the system stores the objective score.

---

### AC-EXAM-004: Teacher Review Required for AI-Assisted Written Grading

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-004 |
| Related Business Rules | BR-EXAM-004 |

#### Criteria

- Given AI-assisted grading is used for written responses,  
  When AI generates a grading suggestion,  
  Then the result remains a suggestion.

- Given a written response has AI-assisted grading,  
  Then Teacher review is required before finalizing the grade.

- Given Teacher has not reviewed the AI-assisted grade,  
  Then the system does not mark the grade as final.

---

## 18. Monetization and Payment Criteria

### AC-PAY-001: Premium Feature Access

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Related User Flow | UF-PAY-001 |
| Related Functional Requirements | FR-PAY-001 |
| Related Business Rules | BR-PAY-001, BR-PAY-002 |

#### Criteria

- Given premium features are enabled,  
  When a user with valid entitlement accesses a premium feature,  
  Then the system grants access.

- Given a user without valid entitlement attempts to access a premium feature,  
  Then the system restricts access.

- Given premium access rules change,  
  Then feature access follows the current entitlement policy.

---

### AC-PAY-002: Teacher Marketplace Transaction

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Related User Flow | UF-PAY-002 |
| Related Functional Requirements | FR-PAY-002 |
| Related Business Rules | BR-PAY-003 |

#### Criteria

- Given marketplace monetization is enabled,  
  When a Student or Parent initiates a paid teacher service transaction,  
  Then the system processes the transaction according to marketplace policy.

- Given the payment succeeds,  
  Then the system confirms the transaction.

- Given the payment fails,  
  Then the system does not complete the transaction.

- Given platform commission applies,  
  Then the system records commission according to defined policy.

---

## 19. MVP Acceptance Criteria Summary

The MVP is considered acceptable when the following criteria groups are satisfied:

- Users can register, log in, and log out.
- Role-based access is enforced.
- Teacher and Staff roles are separate by default.
- Admins can assign and revoke Staff permissions.
- Teacher applications can be submitted.
- Staff can approve or reject teacher applications.
- Approved Teachers receive Teacher permissions.
- Rejected Teacher applicants do not receive Teacher permissions.
- Approved Teachers can upload study materials.
- Uploaded materials have required metadata and moderation status.
- Staff can approve, reject, request revision, hide, or archive materials.
- Staff cannot review their own content if they also have a Teacher role.
- Students can only see approved and visible materials.
- AI quiz and flashcard generation creates draft content.
- AI-assisted content is identifiable.
- Teacher review is required before AI-generated content becomes available to Students.
- Students can start, submit, and receive feedback for practice quizzes.
- Quiz attempts are stored in learning history.
- Students can practice with approved flashcards.
- Search and filtering exclude unapproved or hidden materials.
- Admins can manage roles, subjects, and Staff permissions.

---

## 20. Notes for Testing

Acceptance criteria should be used as the foundation for future test cases in `12-testing-strategy.md`.

Each test case should reference:

- One or more acceptance criteria.
- Related functional requirements.
- Related business rules.
- Related user flows.

Recommended testing focus for MVP:

- Role-based access.
- Teacher approval workflow.
- Staff moderation workflow.
- Self-review prevention.
- Material visibility rules.
- AI-generated content review rules.
- Student practice and scoring.
- Search result filtering.
- Admin role assignment.

Example traceability:

> UF-MAT-001 → FR-MAT-001 → BR-MAT-003 → AC-MAT-001

The next recommended document is `06-edge-cases.md`.