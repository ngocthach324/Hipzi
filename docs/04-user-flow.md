# HIPZI User Flows

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | User Flow Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Designer, Researcher |
| Language | English |

---

## 1. Purpose

This document defines the primary user flows for HIPZI.

User flows describe how users move through the system to complete specific goals. They connect user requirements, business rules, and functional requirements into practical step-by-step workflows.

This document focuses on:

- User goals.
- Main flow steps.
- Alternative flows.
- End states.
- Role responsibilities.
- Workflow transitions.
- Related requirements and business rules.

This document does not define:

- UI visual design.
- Database schema.
- API contracts.
- Implementation details.
- Test cases.

Those details should be refined in later documents such as:

- `05-acceptance-criteria.md`
- `06-edge-cases.md`
- `08-database-design.md`
- `09-api-design.md`
- `14-ui-ux-design.md`

---

## 2. User Flow Classification

Each user flow uses a stable ID so that it can be referenced by acceptance criteria, edge cases, tests, and implementation tasks.

### 2.1 User Flow ID Prefixes

| Prefix | Flow Group |
|---|---|
| UF-AUTH | Authentication and Role Access |
| UF-STU | Student Learning |
| UF-TCH | Teacher / Lecturer |
| UF-STF | Staff Moderation |
| UF-ADM | Admin Governance |
| UF-MAT | Study Materials |
| UF-AI | AI Content Generation |
| UF-PRAC | Student Practice |
| UF-PER | Personalization and Recommendation |
| UF-CLS | Class Management |
| UF-COURSE | Course Management |
| UF-PAR | Parent Features |
| UF-REP | Reporting |
| UF-REV | Review and Rating |
| UF-EXAM | Exam and Assessment |
| UF-PAY | Monetization and Payment |

### 2.2 Priority Levels

| Priority | Meaning |
|---|---|
| MVP | Required for the first usable version |
| Phase 2 | Important after the MVP is validated |
| Future | Long-term or advanced flow |

---

## 3. Core MVP Flow Overview

The MVP should validate the following core learning workflow:

> Teacher uploads learning material → Staff reviews and approves content → AI generates quiz or flashcards → Teacher reviews AI-generated content → Student practices → Platform tracks basic learning activity → Staff and Admins govern content quality.

The MVP user flows should prioritize:

- User registration and login.
- Role-based access.
- Teacher application submission.
- Staff review of teacher applications.
- Teacher material upload.
- Staff material moderation.
- Student material browsing.
- AI quiz and flashcard generation.
- Teacher review of AI-generated content.
- Student quiz and flashcard practice.
- Basic learning history.
- Admin Staff role assignment.

---

## 4. Authentication and Role Access Flows

### UF-AUTH-001: User Registration and Login

| Field | Value |
|---|---|
| Primary Actor | Guest User |
| Supporting Actors | System |
| Priority | MVP |
| Goal | A new user creates an account and logs into HIPZI. |
| Preconditions | The user does not already have an account with the same identifier. |
| Trigger | Guest user selects registration or login. |
| Success Outcome | The user is authenticated and redirected to the appropriate area based on role. |
| Related Requirements | FR-AUTH-001, FR-AUTH-002 |
| Related Business Rules | BR-ROLE-001, BR-ROLE-002 |

#### Main Flow

1. Guest user opens HIPZI.
2. Guest user selects the registration option.
3. Guest user enters required account information.
4. System validates the submitted information.
5. System creates the user account.
6. System assigns the default role according to platform policy.
7. User logs in with valid credentials.
8. System authenticates the user.
9. System redirects the user to the appropriate dashboard or landing area.

#### Alternative Flows

- If the submitted account identifier already exists, the system shows an account conflict error.
- If required registration information is missing, the system shows validation errors.
- If login credentials are invalid, the system rejects authentication and shows an error.
- If the user has multiple roles, the system may route the user to a role selection or default dashboard.

#### End State

The user is registered, authenticated, and has access to role-appropriate features.

---

### UF-AUTH-002: Role-Based Access Check

| Field | Value |
|---|---|
| Primary Actor | Authenticated User |
| Supporting Actors | System |
| Priority | MVP |
| Goal | The system controls access to protected features based on user role. |
| Preconditions | The user is authenticated. |
| Trigger | User attempts to access a protected feature. |
| Success Outcome | The user is allowed or denied access based on role permissions. |
| Related Requirements | FR-AUTH-004, FR-AUTH-007, FR-AUTH-008 |
| Related Business Rules | BR-ROLE-002, BR-ROLE-005, BR-ROLE-006 |

#### Main Flow

1. Authenticated user attempts to access a protected feature.
2. System identifies the user’s assigned role or roles.
3. System checks whether the user has permission for the requested feature.
4. If permission exists, the system grants access.
5. If permission does not exist, the system blocks access and shows an appropriate message.

#### Alternative Flows

- If the user session is expired, the system redirects the user to login.
- If the feature requires Staff permissions and the user is only a Teacher, the system denies access.
- If the feature requires Admin permissions and the user is Staff, the system denies access unless Admin-level permission is explicitly granted.

#### End State

Protected features remain accessible only to authorized roles.

---

## 5. Teacher / Lecturer Flows

### UF-TCH-001: Teacher Application Submission

| Field | Value |
|---|---|
| Primary Actor | User |
| Supporting Actors | Staff |
| Priority | MVP |
| Goal | A user applies to become a verified Teacher / Lecturer on HIPZI. |
| Preconditions | The user has a registered account. |
| Trigger | User selects the option to become a Teacher. |
| Success Outcome | The teacher application is submitted for Staff review. |
| Related Requirements | FR-TCH-001, FR-TCH-002 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |

#### Main Flow

1. User logs into HIPZI.
2. User opens the teacher application page.
3. User fills in teacher profile information.
4. User provides required teaching details such as subjects, experience, qualifications, and introduction.
5. User submits the application.
6. System validates required application information.
7. System saves the teacher application.
8. System sets the application status to Submitted or Pending Review.
9. System makes the application available in the Staff review queue.
10. User can view the application status.

#### Alternative Flows

- If required information is missing, the system shows validation errors.
- If the user already has a pending teacher application, the system prevents duplicate submission.
- If the user is already an approved Teacher, the system does not allow a duplicate teacher application.
- If the application is rejected, the user can view rejection status and may resubmit according to platform policy.

#### End State

The teacher application is available for Staff review.

---

### UF-TCH-002: Teacher Views Application Status

| Field | Value |
|---|---|
| Primary Actor | Teacher Applicant |
| Supporting Actors | System |
| Priority | MVP |
| Goal | A teacher applicant checks the current status of their application. |
| Preconditions | The user has submitted a teacher application. |
| Trigger | User opens the teacher application status page. |
| Success Outcome | The current application status is displayed. |
| Related Requirements | FR-TCH-002 |
| Related Business Rules | BR-TCH-002, BR-TCH-003 |

#### Main Flow

1. Teacher applicant logs into HIPZI.
2. Teacher applicant opens the teacher application status page.
3. System retrieves the current application status.
4. System displays the application status.
5. If available, the system displays Staff feedback or rejection reason.

#### Alternative Flows

- If the user has not submitted an application, the system shows an option to start a new teacher application.
- If the application has been approved, the system provides access to teacher tools.
- If the application has been rejected, the system may allow resubmission according to platform policy.

#### End State

The applicant understands the current state of their teacher verification process.

---

## 6. Staff Moderation Flows

### UF-STF-001: Staff Reviews Teacher Application

| Field | Value |
|---|---|
| Primary Actor | Staff |
| Supporting Actors | Teacher Applicant, Admin |
| Priority | MVP |
| Goal | Staff reviews and approves or rejects a teacher application. |
| Preconditions | The Staff member has Staff permissions and a submitted teacher application exists. |
| Trigger | Staff opens the teacher application review queue. |
| Success Outcome | The teacher application is approved or rejected. |
| Related Requirements | FR-STF-001, FR-STF-002, FR-STF-003 |
| Related Business Rules | BR-STF-001, BR-STF-002, BR-TCH-002, BR-TCH-003 |

#### Main Flow

1. Staff member logs into HIPZI.
2. Staff member opens the moderation dashboard.
3. Staff member opens the teacher application review queue.
4. System displays submitted teacher applications.
5. Staff member selects an application.
6. Staff member reviews teacher profile information.
7. Staff member chooses to approve or reject the application.
8. System updates the teacher application status.
9. If approved, system grants Teacher permissions to the applicant.
10. If rejected, system records the rejection status and optional reason.
11. System notifies or makes the result visible to the applicant.

#### Alternative Flows

- If the application information is incomplete, Staff may reject it or request resubmission according to platform policy.
- If Staff also owns the application being reviewed, the system blocks the review action.
- If the application requires higher-level decision-making, Staff may escalate it to Admin.
- If Admin later overrides the decision, the system updates the application status accordingly.

#### End State

The teacher application is resolved as approved or rejected, or escalated if necessary.

---

### UF-STF-002: Staff Reviews Uploaded Study Material

| Field | Value |
|---|---|
| Primary Actor | Staff |
| Supporting Actors | Teacher, Admin |
| Priority | MVP |
| Goal | Staff reviews learning materials uploaded by Teachers before student access. |
| Preconditions | A material has been submitted for review and the Staff member has Staff permissions. |
| Trigger | Staff opens the material review queue. |
| Success Outcome | The material status is updated based on Staff decision. |
| Related Requirements | FR-STF-004, FR-STF-005, FR-MAT-003, FR-MAT-005 |
| Related Business Rules | BR-STF-003, BR-STF-004, BR-MAT-003, BR-MAT-004, BR-MAT-005 |

#### Main Flow

1. Staff member logs into HIPZI.
2. Staff member opens the moderation dashboard.
3. Staff member opens the material review queue.
4. System displays materials pending review.
5. Staff member selects a material.
6. Staff member reviews the material title, subject, description, content, and quality.
7. Staff member selects a moderation action:
   - Approve.
   - Reject.
   - Request Revision.
   - Hide.
   - Archive.
8. System updates the material status according to the selected action.
9. System updates material visibility based on the new status.
10. Teacher can view the updated material status.

#### Alternative Flows

- If Staff approves the material, the material becomes visible to Students if all visibility conditions are met.
- If Staff rejects the material, the material remains hidden from Students.
- If Staff requests revision, the material returns to the Teacher for correction.
- If Staff also owns the material as a Teacher, the system blocks the review action.
- If the material contains a serious policy issue, Staff may escalate the case to Admin.

#### End State

The material has an updated moderation status and visibility is controlled accordingly.

---

### UF-STF-003: Staff Handles Reported Content

| Field | Value |
|---|---|
| Primary Actor | Staff |
| Supporting Actors | Student, Teacher, Admin |
| Priority | Phase 2 |
| Goal | Staff reviews user-reported content and takes moderation action. |
| Preconditions | A user report exists and the Staff member has Staff permissions. |
| Trigger | Staff opens the reported content queue. |
| Success Outcome | The report is processed and appropriate action is taken. |
| Related Requirements | FR-STF-008, FR-REP-001, FR-REP-002 |
| Related Business Rules | BR-STF-006, BR-AI-005 |

#### Main Flow

1. Staff member opens the moderation dashboard.
2. Staff member opens the reported content queue.
3. System displays submitted reports.
4. Staff member selects a report.
5. Staff member reviews the reported content and report reason.
6. Staff member chooses an appropriate action:
   - Dismiss report.
   - Hide content.
   - Request revision.
   - Archive content.
   - Escalate to Admin.
7. System updates the report status and content status where applicable.
8. System records the moderation action.

#### Alternative Flows

- If the report is invalid, Staff dismisses the report.
- If the report concerns a serious violation, Staff escalates to Admin.
- If the report involves AI-generated content, the system may mark it for AI quality review.
- If the reported content belongs to the Staff member acting as Teacher, the system blocks self-review.

#### End State

The report is resolved, dismissed, or escalated.

---

## 7. Admin Governance Flows

### UF-ADM-001: Admin Assigns Staff Role

| Field | Value |
|---|---|
| Primary Actor | Admin |
| Supporting Actors | User, Teacher |
| Priority | MVP |
| Goal | Admin assigns Staff permissions to an eligible user. |
| Preconditions | The actor has Admin permissions and the target user exists. |
| Trigger | Admin selects role assignment action. |
| Success Outcome | The target user receives Staff permissions. |
| Related Requirements | FR-ADM-003, FR-AUTH-003, FR-AUTH-006 |
| Related Business Rules | BR-ROLE-004, BR-ADM-001, BR-ADM-002, BR-TCH-006 |

#### Main Flow

1. Admin logs into HIPZI.
2. Admin opens the admin governance dashboard.
3. Admin opens user management.
4. Admin selects a user.
5. Admin reviews the user’s current roles and eligibility.
6. Admin assigns the Staff role.
7. System updates the user’s role assignments.
8. System grants Staff dashboard access to the user.
9. System records the role assignment action.

#### Alternative Flows

- If the user is not eligible for Staff role, Admin may cancel the action.
- If the user is a trusted Teacher, Admin may assign Staff role while preserving Teacher permissions.
- If the role assignment creates a conflict of interest, the system still enforces self-review prevention rules.
- If Admin revokes Staff role, the system removes Staff permissions from the user.

#### End State

The selected user has updated role permissions.

---

### UF-ADM-002: Admin Audits Staff Moderation Actions

| Field | Value |
|---|---|
| Primary Actor | Admin |
| Supporting Actors | Staff |
| Priority | Phase 2 |
| Goal | Admin reviews Staff moderation actions for accountability and governance. |
| Preconditions | Staff moderation actions have been recorded. |
| Trigger | Admin opens moderation audit logs. |
| Success Outcome | Admin can review Staff actions and identify issues if needed. |
| Related Requirements | FR-ADM-005 |
| Related Business Rules | BR-ADM-004 |

#### Main Flow

1. Admin logs into HIPZI.
2. Admin opens the admin governance dashboard.
3. Admin opens moderation audit logs.
4. System displays Staff actions related to teacher applications, material moderation, reports, and escalations.
5. Admin filters or selects a moderation action.
6. Admin reviews the action details.
7. Admin decides whether no action is needed or further review is required.

#### Alternative Flows

- If Admin finds an incorrect moderation decision, Admin may initiate an override.
- If Admin finds repeated quality issues, Admin may review Staff permissions.
- If the audit log is incomplete, Admin may flag a governance issue for system improvement.

#### End State

Admin has reviewed Staff actions and may take governance action if necessary.

---

### UF-ADM-003: Admin Overrides Staff Decision

| Field | Value |
|---|---|
| Primary Actor | Admin |
| Supporting Actors | Staff, Teacher, Student |
| Priority | Phase 2 |
| Goal | Admin overrides a Staff moderation decision when necessary. |
| Preconditions | A Staff decision exists and is eligible for override. |
| Trigger | Admin selects override action. |
| Success Outcome | The affected application, material, or moderation case is updated. |
| Related Requirements | FR-ADM-006 |
| Related Business Rules | BR-ADM-005, BR-ADM-006 |

#### Main Flow

1. Admin opens the admin governance dashboard.
2. Admin opens a Staff decision or escalated issue.
3. Admin reviews the decision details.
4. Admin selects an override action.
5. Admin provides an override reason if required.
6. System updates the affected record.
7. System records the Admin override action.
8. Relevant users can see the updated status where appropriate.

#### Alternative Flows

- If the decision is not eligible for override, the system blocks the action.
- If the override affects public visibility, the system updates student-facing access.
- If the override affects teacher status, the system updates teacher permissions.
- If the issue requires further investigation, Admin may leave the case unresolved.

#### End State

The Staff decision is overridden or remains unchanged after Admin review.

---

## 8. Study Material Flows

### UF-MAT-001: Teacher Uploads Study Material

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Staff |
| Priority | MVP |
| Goal | Teacher uploads a study material for Staff review. |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher selects Upload Material. |
| Success Outcome | The material is saved as Draft or Pending Review. |
| Related Requirements | FR-MAT-001, FR-MAT-002, FR-MAT-003, FR-MAT-004 |
| Related Business Rules | BR-TCH-004, BR-MAT-001, BR-MAT-002, BR-MAT-003, BR-MAT-005 |

#### Main Flow

1. Teacher logs into HIPZI.
2. Teacher opens the teacher dashboard.
3. Teacher selects Upload Material.
4. Teacher enters required material information:
   - Title.
   - Subject.
   - Description.
   - Content source or file.
5. Teacher chooses to save as Draft or submit for review.
6. System validates required information.
7. System assigns the material owner as the Teacher.
8. System saves the material.
9. If saved as Draft, system sets status to Draft.
10. If submitted for review, system sets status to Pending Review.
11. Material becomes available in Teacher material management area.
12. If submitted, material becomes available in Staff review queue.

#### Alternative Flows

- If required fields are missing, the system shows validation errors.
- If the user is not an approved Teacher, the system blocks upload access.
- If the uploaded file type is unsupported, the system rejects the upload.
- If the Teacher cancels, no submitted material is created.

#### End State

The material is stored as Draft or Pending Review.

---

### UF-MAT-002: Teacher Revises Material After Staff Feedback

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Staff |
| Priority | MVP |
| Goal | Teacher revises material after Staff requests revision or rejects the material. |
| Preconditions | The material belongs to the Teacher and has Rejected or Needs Revision status. |
| Trigger | Teacher opens material with Staff feedback. |
| Success Outcome | Teacher updates and resubmits the material for review. |
| Related Requirements | FR-MAT-006 |
| Related Business Rules | BR-MAT-006 |

#### Main Flow

1. Teacher logs into HIPZI.
2. Teacher opens material management.
3. Teacher selects a material marked as Rejected or Needs Revision.
4. Teacher reviews Staff feedback.
5. Teacher edits the material.
6. Teacher saves changes.
7. Teacher resubmits the material for review.
8. System validates required information.
9. System updates material status to Pending Review.
10. Staff can review the revised material.

#### Alternative Flows

- If the Teacher saves without submitting, the material remains Draft or Needs Revision.
- If required fields are missing, the system shows validation errors.
- If the material has been archived or locked, the system prevents editing.

#### End State

The revised material is resubmitted or saved for later editing.

---

### UF-MAT-003: Student Browses Approved Materials

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | System |
| Priority | MVP |
| Goal | Student discovers approved and visible study materials. |
| Preconditions | Approved and visible materials exist. |
| Trigger | Student opens subject browsing, material list, or search page. |
| Success Outcome | Student sees only approved and visible materials. |
| Related Requirements | FR-STU-002, FR-STU-003, FR-STU-004, FR-MAT-005, FR-SEARCH-001, FR-SEARCH-002, FR-SEARCH-003 |
| Related Business Rules | BR-MAT-001, BR-MAT-004 |

#### Main Flow

1. Student logs into HIPZI.
2. Student opens subject list, material browsing, or search.
3. Student selects a subject or enters a keyword.
4. System retrieves matching materials.
5. System filters materials by visibility and approval status.
6. System displays approved and visible materials only.
7. Student selects a material.
8. System displays material details and available practice activities.

#### Alternative Flows

- If no materials match the query, the system shows an empty state.
- If a material becomes hidden after being listed, the system prevents access when opened.
- If the Student searches using vague input, the system may show broad results or suggestions.

#### End State

Student can view an approved material and continue to learning or practice.

---

## 9. AI Content Generation Flows

### UF-AI-001: Teacher Generates Quiz with AI

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | AI System |
| Priority | MVP |
| Goal | Teacher generates a quiz from uploaded material using AI. |
| Preconditions | The user is an approved Teacher and has access to eligible material. |
| Trigger | Teacher selects Generate Quiz. |
| Success Outcome | AI-generated quiz is saved as draft for Teacher review. |
| Related Requirements | FR-AI-001, FR-AI-003, FR-AI-004 |
| Related Business Rules | BR-AI-002, BR-AI-006, BR-PRAC-001 |

#### Main Flow

1. Teacher opens an eligible material.
2. Teacher selects Generate Quiz.
3. System prepares material content for AI generation.
4. AI generates quiz questions, answer options, correct answers, and explanations where possible.
5. System saves the generated quiz as Draft.
6. System marks the quiz as AI-assisted.
7. Teacher opens the generated quiz for review.

#### Alternative Flows

- If the material content is insufficient, the system informs the Teacher that quiz generation may not be possible.
- If AI generation fails, the system shows an error and allows retry.
- If generated content quality is low, Teacher can edit or discard it.
- If platform policy requires Staff approval, the quiz remains unavailable to Students until moderation is complete.

#### End State

A draft AI-generated quiz exists and is ready for Teacher review.

---

### UF-AI-002: Teacher Generates Flashcards with AI

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | AI System |
| Priority | MVP |
| Goal | Teacher generates flashcards from uploaded material using AI. |
| Preconditions | The user is an approved Teacher and has access to eligible material. |
| Trigger | Teacher selects Generate Flashcards. |
| Success Outcome | AI-generated flashcards are saved as draft for Teacher review. |
| Related Requirements | FR-AI-002, FR-AI-003, FR-AI-004 |
| Related Business Rules | BR-AI-002, BR-AI-006, BR-PRAC-001 |

#### Main Flow

1. Teacher opens an eligible material.
2. Teacher selects Generate Flashcards.
3. System prepares material content for AI generation.
4. AI generates flashcards containing prompts, answers, definitions, formulas, or key concepts.
5. System saves generated flashcards as Draft.
6. System marks the flashcards as AI-assisted.
7. Teacher opens the flashcards for review.

#### Alternative Flows

- If the material has too little useful content, the system asks the Teacher to provide more content.
- If AI generation fails, the system shows an error and allows retry.
- If generated flashcards are inaccurate, Teacher can edit or discard them.

#### End State

Draft AI-generated flashcards exist and are ready for Teacher review.

---

### UF-AI-003: Teacher Reviews AI-Generated Content

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Staff, AI System |
| Priority | MVP |
| Goal | Teacher reviews, edits, and prepares AI-generated content for student use. |
| Preconditions | AI-generated quiz or flashcard content exists in Draft state. |
| Trigger | Teacher opens AI-generated content editor. |
| Success Outcome | AI-generated content is reviewed and either saved, discarded, submitted, or published according to policy. |
| Related Requirements | FR-AI-004, FR-AI-005, FR-AI-006, FR-AI-007 |
| Related Business Rules | BR-AI-001, BR-AI-002, BR-AI-003, BR-AI-006 |

#### Main Flow

1. Teacher opens AI-generated quiz or flashcard draft.
2. Teacher reviews generated questions, answers, explanations, or flashcard content.
3. Teacher edits inaccurate, unclear, or low-quality content.
4. Teacher saves the reviewed content.
5. System marks the content as Teacher Reviewed.
6. Teacher either:
   - Submits the content for Staff review if required by policy.
   - Publishes the content if policy allows direct publication after Teacher review.
   - Discards the content.
7. System controls student visibility based on review and moderation status.

#### Alternative Flows

- If Teacher discards the content, it is removed or marked as discarded.
- If Staff approval is required, the content is not visible to Students until approved.
- If Teacher does not complete review, the content remains unavailable to Students.
- If the content is reported later, Staff may re-review it.

#### End State

AI-generated content is reviewed and either prepared for student use, submitted for moderation, or discarded.

---

## 10. Student Practice Flows

### UF-PRAC-001: Student Practices with Quiz

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | System |
| Priority | MVP |
| Goal | Student completes a practice quiz and receives feedback. |
| Preconditions | The quiz is approved, visible, and available to Students. |
| Trigger | Student selects Start Quiz. |
| Success Outcome | Quiz attempt is scored and stored in learning history. |
| Related Requirements | FR-PRAC-001, FR-PRAC-002, FR-PRAC-003, FR-PRAC-004, FR-PRAC-005, FR-PRAC-006 |
| Related Business Rules | BR-PRAC-001, BR-PRAC-002, BR-PRAC-003, BR-PRAC-004, BR-PRAC-005 |

#### Main Flow

1. Student opens an approved material or practice activity.
2. Student selects a quiz.
3. Student selects Start Quiz.
4. System creates a quiz attempt.
5. Student answers quiz questions.
6. Student submits answers.
7. System records submitted answers.
8. System calculates quiz results based on answer keys or evaluation rules.
9. System displays score, correct answers, incorrect answers, and available feedback.
10. System stores the quiz attempt in learning history.

#### Alternative Flows

- If the quiz has no valid evaluation rules, the system cannot score automatically.
- If Student exits before submission, the attempt may remain incomplete according to platform policy.
- If the quiz is no longer available, the system prevents starting the attempt.
- If retakes are allowed, Student may start a new attempt.

#### End State

Student receives feedback and the quiz attempt is stored.

---

### UF-PRAC-002: Student Practices with Flashcards

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | System |
| Priority | MVP |
| Goal | Student practices knowledge using flashcards. |
| Preconditions | Flashcards are approved, visible, and available to Students. |
| Trigger | Student opens a flashcard set. |
| Success Outcome | Student completes flashcard practice or exits after reviewing cards. |
| Related Requirements | FR-PRAC-007 |
| Related Business Rules | BR-PRAC-001, BR-MAT-004 |

#### Main Flow

1. Student opens an approved material or practice area.
2. Student selects a flashcard set.
3. System displays flashcards one by one.
4. Student reviews each flashcard prompt.
5. Student reveals the answer or explanation.
6. Student continues until the set is completed or exits.
7. System may record basic flashcard activity in learning history.

#### Alternative Flows

- If flashcards are hidden or no longer approved, the system prevents access.
- If the flashcard set is empty, the system shows an empty state.
- If Student exits early, the system may store partial progress.

#### End State

Student completes or partially completes flashcard practice.

---

## 11. Personalization and Recommendation Flows

### UF-PER-001: Student Submits Learning Personalization Input

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | AI System |
| Priority | Phase 2 |
| Goal | Student provides learning context so AI can personalize the study experience. |
| Preconditions | Student is authenticated. |
| Trigger | Student opens AI learning assistant or personalization setup. |
| Success Outcome | Student learning input is saved for AI analysis. |
| Related Requirements | FR-PER-001, FR-PER-007 |
| Related Business Rules | BR-PER-001, BR-PER-006 |

#### Main Flow

1. Student opens the personalization or AI learning assistant area.
2. System asks for learning context.
3. Student enters learning goals.
4. Student enters current level.
5. Student enters weak areas or difficult topics.
6. Student enters available study time.
7. Student enters learning preferences.
8. Student submits the information.
9. System validates and stores the personalization input.
10. System makes the input available for AI analysis.

#### Alternative Flows

- If input is incomplete, the system may ask follow-up questions.
- If Student skips personalization, the system may use general recommendations.
- If Student updates preferences later, the system replaces or updates the previous input.

#### End State

Student personalization input is available for roadmap and recommendation generation.

---

### UF-PER-002: AI Generates Personalized Learning Roadmap

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | AI System |
| Priority | Phase 2 |
| Goal | AI generates a personalized learning roadmap for the Student. |
| Preconditions | Student has provided personalization input or has learning history. |
| Trigger | Student requests learning analysis or roadmap generation. |
| Success Outcome | Student receives a recommended roadmap. |
| Related Requirements | FR-PER-002, FR-PER-003, FR-PER-006 |
| Related Business Rules | BR-PER-001, BR-PER-002, BR-PER-005 |

#### Main Flow

1. Student requests a personalized learning roadmap.
2. System retrieves Student input and available learning history.
3. AI analyzes Student goals, current level, weak areas, available time, and learning preferences.
4. AI identifies priority subjects or topics.
5. AI generates a learning roadmap.
6. System presents the roadmap as a recommendation.
7. Student reviews the roadmap.
8. Student can start learning, adjust preferences, or ask for refinement.

#### Alternative Flows

- If there is insufficient data, the system asks clarifying questions.
- If no learning history exists, AI relies on Student-provided input.
- If Student rejects the roadmap, Student can update goals or preferences.
- If AI cannot generate a reliable roadmap, the system provides a general learning plan.

#### End State

Student has a recommended learning roadmap.

---

### UF-PER-003: AI Recommends Materials and Teachers

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | AI System, Teacher |
| Priority | Phase 2 |
| Goal | AI recommends approved materials and verified Teachers based on Student needs. |
| Preconditions | Student has a roadmap, learning goal, or personalization context. |
| Trigger | Student requests learning recommendations or views roadmap. |
| Success Outcome | Student receives relevant material and Teacher recommendations. |
| Related Requirements | FR-PER-004, FR-PER-005 |
| Related Business Rules | BR-PER-003, BR-PER-004, BR-MAT-004 |

#### Main Flow

1. Student opens recommendations or roadmap.
2. System retrieves Student context and roadmap.
3. System identifies relevant approved materials.
4. System identifies verified and active Teachers matching Student needs.
5. AI or recommendation system ranks materials and Teachers.
6. System displays recommended materials.
7. System displays recommended Teachers.
8. Student selects a material to study or a Teacher to view.

#### Alternative Flows

- If no approved materials match, the system shows a fallback recommendation.
- If no verified Teachers match, the system shows available alternatives or asks for broader criteria.
- If Student changes preferences, recommendations update accordingly.
- If a recommended material becomes hidden, it is removed from recommendations.

#### End State

Student receives personalized recommendations using only approved materials and verified Teachers.

---

## 12. Class and Course Flows

### UF-CLS-001: Teacher Creates Class

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Student |
| Priority | Phase 2 |
| Goal | Teacher creates a class for student participation. |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher selects Create Class. |
| Success Outcome | A class is created and associated with the Teacher. |
| Related Requirements | FR-CLS-001 |
| Related Business Rules | BR-CLS-001 |

#### Main Flow

1. Teacher opens teacher dashboard.
2. Teacher selects Create Class.
3. Teacher enters class information.
4. Teacher configures enrollment settings.
5. Teacher saves the class.
6. System creates the class and associates it with the Teacher.

#### Alternative Flows

- If required class information is missing, the system shows validation errors.
- If the Teacher is not approved, the system blocks class creation.
- If class creation requires Staff review in future policy, the class remains pending before public listing.

#### End State

The Teacher has created a class.

---

### UF-CLS-002: Student Requests Class Enrollment

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | Teacher |
| Priority | Phase 2 |
| Goal | Student requests to join a teacher-managed class. |
| Preconditions | The class exists and accepts enrollment requests. |
| Trigger | Student selects Request Enrollment. |
| Success Outcome | Enrollment request is sent to the Teacher. |
| Related Requirements | FR-CLS-002 |
| Related Business Rules | BR-CLS-002 |

#### Main Flow

1. Student opens a class page.
2. Student reviews class details.
3. Student selects Request Enrollment.
4. System creates an enrollment request.
5. System sets enrollment status to Requested.
6. Teacher can review the enrollment request.

#### Alternative Flows

- If the class is full, the system prevents enrollment request or shows waitlist status.
- If the class is open enrollment, the system may approve Student automatically.
- If Student has already requested enrollment, the system prevents duplicate requests.

#### End State

Student enrollment request is awaiting Teacher decision or is automatically handled by class settings.

---

### UF-CLS-003: Teacher Approves Class Enrollment

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Student |
| Priority | Phase 2 |
| Goal | Teacher approves or rejects student enrollment requests. |
| Preconditions | A Student has requested enrollment in the Teacher’s class. |
| Trigger | Teacher opens enrollment request queue. |
| Success Outcome | Student enrollment status is updated. |
| Related Requirements | FR-CLS-003 |
| Related Business Rules | BR-CLS-003 |

#### Main Flow

1. Teacher opens class management.
2. Teacher opens enrollment requests.
3. System displays pending requests.
4. Teacher selects a request.
5. Teacher approves or rejects the request.
6. System updates enrollment status.
7. If approved, Student gains access to class-specific materials.
8. If rejected, Student does not gain class access.

#### Alternative Flows

- If the request is no longer valid, the system blocks action.
- If class capacity is reached, the system prevents approval unless Teacher changes class settings.
- If Student withdraws request, Teacher no longer needs to process it.

#### End State

Student enrollment is approved or rejected.

---

### UF-COURSE-001: Teacher Creates Structured Course

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Staff |
| Priority | Future |
| Goal | Teacher creates a structured course with modules, lessons, materials, quizzes, and assignments. |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher selects Create Course. |
| Success Outcome | A structured course is created and may be submitted for review. |
| Related Requirements | FR-COURSE-001, FR-COURSE-002 |
| Related Business Rules | BR-CLS-004, BR-CLS-005 |

#### Main Flow

1. Teacher opens course builder.
2. Teacher creates a course.
3. Teacher adds modules.
4. Teacher adds lessons under modules.
5. Teacher attaches materials, quizzes, and assignments to lessons.
6. Teacher saves the course.
7. Teacher submits the course for review if required.
8. Staff reviews the course according to platform policy.

#### Alternative Flows

- If required course information is missing, the system shows validation errors.
- If course review is not required, the course may be published according to policy.
- If Staff requests revision, Teacher edits and resubmits the course.

#### End State

A structured course is saved, submitted, approved, or returned for revision according to policy.

---

## 13. Parent Flows

### UF-PAR-001: Parent Links to Student Account

| Field | Value |
|---|---|
| Primary Actor | Parent |
| Supporting Actors | Student |
| Priority | Future |
| Goal | Parent links their account to a Student account through verified authorization. |
| Preconditions | Parent and Student accounts exist. |
| Trigger | Parent requests account linkage. |
| Success Outcome | Parent is authorized to view permitted Student learning data. |
| Related Requirements | FR-PAR-001, FR-PAR-002 |
| Related Business Rules | BR-PAR-001, BR-PAR-002 |

#### Main Flow

1. Parent logs into HIPZI.
2. Parent opens student linkage area.
3. Parent submits a linkage request.
4. System verifies the linkage request according to platform policy.
5. Student or authorized process confirms the linkage.
6. System creates verified parent-student relationship.
7. Parent gains access to permitted Student learning information.

#### Alternative Flows

- If verification fails, the system rejects the linkage.
- If Student does not authorize, Parent cannot access learning data.
- If linkage already exists, the system prevents duplicate linkage.

#### End State

Parent is linked to Student account or the linkage request is rejected.

---

### UF-PAR-002: Parent Views Student Progress

| Field | Value |
|---|---|
| Primary Actor | Parent |
| Supporting Actors | Student |
| Priority | Future |
| Goal | Parent views authorized Student learning progress. |
| Preconditions | Parent-student relationship is verified. |
| Trigger | Parent opens student progress dashboard. |
| Success Outcome | Parent sees permitted learning progress data. |
| Related Requirements | FR-PAR-003 |
| Related Business Rules | BR-PAR-002 |

#### Main Flow

1. Parent logs into HIPZI.
2. Parent opens parent dashboard.
3. Parent selects linked Student.
4. System verifies Parent access permission.
5. System displays permitted learning progress data.
6. Parent reviews completed materials, quiz performance, and learning summaries.

#### Alternative Flows

- If relationship is not verified, the system blocks access.
- If Student data is unavailable, the system shows an empty state.
- If platform policy limits data visibility, only permitted data is displayed.

#### End State

Parent views authorized Student learning progress.

---

## 14. Reporting, Review, and Rating Flows

### UF-REP-001: User Reports Content or AI Mistake

| Field | Value |
|---|---|
| Primary Actor | Student, Teacher, Parent |
| Supporting Actors | Staff |
| Priority | Phase 2 |
| Goal | User reports incorrect, inappropriate, low-quality, or AI-generated content mistakes. |
| Preconditions | User is authenticated and can access the content. |
| Trigger | User selects report action. |
| Success Outcome | Report is submitted for Staff review. |
| Related Requirements | FR-REP-001, FR-REP-002 |
| Related Business Rules | BR-STF-006, BR-AI-005 |

#### Main Flow

1. User opens content or AI-generated output.
2. User selects Report.
3. User chooses report type.
4. User provides optional explanation.
5. System validates report input.
6. System records the report.
7. System makes the report available in Staff report queue.
8. Staff can review and process the report.

#### Alternative Flows

- If report information is missing, the system asks for required input.
- If duplicate reports exist, the system may group them.
- If content is already under review, the system may attach the report to the existing case.

#### End State

The report is submitted and ready for Staff handling.

---

### UF-REV-001: User Reviews Interacted Content

| Field | Value |
|---|---|
| Primary Actor | Student, Parent |
| Supporting Actors | Staff |
| Priority | Future |
| Goal | User rates or reviews content, Teacher, class, or course after valid interaction. |
| Preconditions | User has interacted with the target item. |
| Trigger | User submits review or rating. |
| Success Outcome | Review is stored and displayed according to platform policy. |
| Related Requirements | FR-REV-001, FR-REV-002 |
| Related Business Rules | BR-REV-001, BR-REV-002, BR-REV-003 |

#### Main Flow

1. User opens a material, Teacher profile, class, or course they have interacted with.
2. User selects review or rating option.
3. User enters rating and optional review text.
4. System checks whether the user has valid interaction with the target item.
5. System validates review content.
6. System stores the review.
7. System displays the review according to moderation and visibility policy.

#### Alternative Flows

- If the user has not interacted with the item, the system blocks the review.
- If Teacher attempts to review their own content, the system blocks the review.
- If review violates policy, Staff may hide or remove it.

#### End State

A valid review is stored or blocked according to platform rules.

---

## 15. Exam and Assessment Flows

### UF-EXAM-001: Teacher Creates Online Exam

| Field | Value |
|---|---|
| Primary Actor | Teacher |
| Supporting Actors | Student |
| Priority | Future |
| Goal | Teacher creates an online exam for Students. |
| Preconditions | The user is an approved Teacher. |
| Trigger | Teacher selects Create Exam. |
| Success Outcome | Online exam is created with configured settings. |
| Related Requirements | FR-EXAM-001 |
| Related Business Rules | BR-EXAM-001, BR-EXAM-002 |

#### Main Flow

1. Teacher opens exam management.
2. Teacher selects Create Exam.
3. Teacher enters exam information.
4. Teacher adds questions.
5. Teacher configures timing, attempt limits, and availability settings.
6. Teacher saves the exam.
7. System creates the exam.

#### Alternative Flows

- If required exam information is missing, the system shows validation errors.
- If exam contains written responses, AI-assisted grading may be configured only as a suggestion.
- If exam requires review before release, Staff or Admin review may be required according to future policy.

#### End State

An online exam is created and ready for release according to exam settings.

---

### UF-EXAM-002: Student Takes Online Exam

| Field | Value |
|---|---|
| Primary Actor | Student |
| Supporting Actors | Teacher |
| Priority | Future |
| Goal | Student takes a formal online exam. |
| Preconditions | The exam is available to the Student. |
| Trigger | Student selects Start Exam. |
| Success Outcome | Exam attempt is submitted and processed according to exam rules. |
| Related Requirements | FR-EXAM-002, FR-EXAM-003 |
| Related Business Rules | BR-EXAM-001, BR-EXAM-002, BR-EXAM-005 |

#### Main Flow

1. Student opens available exam.
2. Student reviews exam instructions.
3. Student starts the exam.
4. System creates an exam attempt.
5. Student answers exam questions.
6. Student submits the exam.
7. System records the submission.
8. System automatically grades objective questions where possible.
9. System waits for Teacher review where required.
10. Student views results according to exam settings.

#### Alternative Flows

- If time expires, the system submits or locks the attempt according to exam policy.
- If Student tries to access answers before submission, the system blocks access.
- If exam is unavailable, the system prevents starting the exam.
- If AI-assisted grading is used for written responses, Teacher review is required before finalization.

#### End State

Student exam attempt is submitted and processed.

---

## 16. Monetization and Payment Flows

### UF-PAY-001: User Accesses Premium Feature

| Field | Value |
|---|---|
| Primary Actor | Student, Parent, Teacher |
| Supporting Actors | System |
| Priority | Future |
| Goal | User accesses a premium feature if eligible. |
| Preconditions | Premium features are enabled. |
| Trigger | User selects a premium feature. |
| Success Outcome | System grants or restricts access based on user entitlement. |
| Related Requirements | FR-PAY-001 |
| Related Business Rules | BR-PAY-001, BR-PAY-002 |

#### Main Flow

1. User selects a premium feature.
2. System checks user plan or entitlement.
3. If user has access, system opens the feature.
4. If user does not have access, system shows upgrade or restriction message.

#### Alternative Flows

- If payment status is invalid, system restricts access.
- If premium policy changes, access is recalculated according to current entitlement.
- If feature is temporarily unavailable, system shows an availability message.

#### End State

User either accesses the premium feature or receives an access restriction message.

---

### UF-PAY-002: Teacher Marketplace Transaction

| Field | Value |
|---|---|
| Primary Actor | Student, Parent |
| Supporting Actors | Teacher, Admin |
| Priority | Future |
| Goal | User completes a paid transaction for teacher service if marketplace monetization is enabled. |
| Preconditions | Marketplace payment features are enabled. |
| Trigger | User selects a paid teacher service. |
| Success Outcome | Transaction is processed according to marketplace policy. |
| Related Requirements | FR-PAY-002 |
| Related Business Rules | BR-PAY-003 |

#### Main Flow

1. Student or Parent opens a paid teacher service.
2. User reviews price and service details.
3. User starts transaction.
4. System processes payment according to platform policy.
5. System confirms transaction status.
6. Teacher and user receive transaction confirmation.
7. Platform records commission if applicable.

#### Alternative Flows

- If payment fails, the transaction is not completed.
- If teacher service becomes unavailable, system cancels or blocks purchase.
- If refund policy applies, future refund handling may be required.

#### End State

Marketplace transaction is completed, failed, or canceled.

---

## 17. MVP User Flow Summary

The MVP should implement and validate these user flows first:

- `UF-AUTH-001`: User Registration and Login.
- `UF-AUTH-002`: Role-Based Access Check.
- `UF-TCH-001`: Teacher Application Submission.
- `UF-TCH-002`: Teacher Views Application Status.
- `UF-STF-001`: Staff Reviews Teacher Application.
- `UF-STF-002`: Staff Reviews Uploaded Study Material.
- `UF-ADM-001`: Admin Assigns Staff Role.
- `UF-MAT-001`: Teacher Uploads Study Material.
- `UF-MAT-002`: Teacher Revises Material After Staff Feedback.
- `UF-MAT-003`: Student Browses Approved Materials.
- `UF-AI-001`: Teacher Generates Quiz with AI.
- `UF-AI-002`: Teacher Generates Flashcards with AI.
- `UF-AI-003`: Teacher Reviews AI-Generated Content.
- `UF-PRAC-001`: Student Practices with Quiz.
- `UF-PRAC-002`: Student Practices with Flashcards.

Phase 2 should prioritize:

- `UF-PER-001`: Student Submits Learning Personalization Input.
- `UF-PER-002`: AI Generates Personalized Learning Roadmap.
- `UF-PER-003`: AI Recommends Materials and Teachers.
- `UF-CLS-001`: Teacher Creates Class.
- `UF-CLS-002`: Student Requests Class Enrollment.
- `UF-CLS-003`: Teacher Approves Class Enrollment.
- `UF-REP-001`: User Reports Content or AI Mistake.
- `UF-STF-003`: Staff Handles Reported Content.
- `UF-ADM-002`: Admin Audits Staff Moderation Actions.
- `UF-ADM-003`: Admin Overrides Staff Decision.

Future flows include:

- Parent account linking.
- Parent progress viewing.
- Structured course builder.
- Online exams.
- AI-assisted grading.
- Reviews and ratings.
- Premium access.
- Teacher marketplace transactions.

---

## 18. Notes for Acceptance Criteria

Each acceptance criterion in `05-acceptance-criteria.md` should reference one or more user flows from this document.

Acceptance criteria should verify:

- The correct actor can complete the flow.
- Unauthorized actors are blocked.
- Required validations are enforced.
- Status transitions are correct.
- Visibility rules are respected.
- Staff and Admin boundaries are preserved.
- AI-generated content is reviewed before student access.
- Student-facing content only includes approved and visible materials.
- Self-review conflicts are blocked.

Example traceability:

> UF-MAT-001 → FR-MAT-001 → BR-MAT-003 → AC-MAT-001

The next recommended document is `05-acceptance-criteria.md`.