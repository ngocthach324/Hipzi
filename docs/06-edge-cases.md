# HIPZI Edge Cases

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Edge Cases Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, QA Engineer, Designer, Researcher |
| Language | English |

---

## 1. Purpose

This document defines important edge cases for HIPZI.

Edge cases describe unusual, invalid, conflicting, incomplete, or unexpected situations that the system must handle correctly.

This document helps ensure that HIPZI does not only work in ideal happy-path flows, but also behaves safely and predictably when users, roles, permissions, content statuses, AI outputs, or workflow states become inconsistent or incomplete.

This document focuses on:

- Permission conflicts.
- Invalid state transitions.
- Moderation conflicts.
- AI-generated content risks.
- Student access control issues.
- Duplicate submissions.
- Missing or incomplete data.
- Multi-role conflicts.
- Visibility and privacy issues.
- Future scalability concerns.

This document does not define implementation details, database schema, API contracts, or UI visual design.

---

## 2. Edge Case Classification

Each edge case uses a stable ID so that it can be referenced by acceptance criteria, tests, implementation tasks, and future documentation.

### 2.1 Edge Case ID Prefixes

| Prefix | Module |
|---|---|
| EC-AUTH | Authentication and Role Access |
| EC-TCH | Teacher / Lecturer |
| EC-STF | Staff Moderation |
| EC-ADM | Admin Governance |
| EC-MAT | Study Materials |
| EC-AI | AI Content Generation |
| EC-PRAC | Student Practice |
| EC-SEARCH | Search and Discovery |
| EC-PER | Personalization and Recommendation |
| EC-CLS | Class Management |
| EC-COURSE | Course Management |
| EC-PAR | Parent Features |
| EC-REP | Reporting |
| EC-REV | Review and Rating |
| EC-EXAM | Exam and Assessment |
| EC-PAY | Monetization and Payment |

### 2.2 Priority Levels

| Priority | Meaning |
|---|---|
| MVP | Must be handled in the first usable version |
| Phase 2 | Should be handled after MVP validation |
| Future | Long-term or advanced edge case |

---

## 3. Core Edge Case Principles

HIPZI must follow these general principles when handling edge cases:

- Unauthorized users must not access protected features.
- Student-facing content must only include approved and visible materials.
- Teacher and Staff roles must remain separate by default.
- Users with both Teacher and Staff roles must not review their own content.
- AI-generated content must not bypass Teacher review or Staff moderation rules.
- Staff moderation actions must control content visibility correctly.
- Admins must have governance authority over role assignment, audit, and override workflows.
- The system should fail safely when data is missing, invalid, or inconsistent.
- The system should provide clear user feedback when an action cannot be completed.

---

## 4. Authentication and Role Access Edge Cases

### EC-AUTH-001: Duplicate Registration Attempt

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Scenario | A guest user attempts to register using an email or unique identifier that already belongs to an existing account. |
| Risk | Duplicate accounts may cause identity conflicts and role confusion. |
| Expected Handling | The system must prevent duplicate account creation and show a clear error message. |
| Related User Flow | UF-AUTH-001 |
| Related Functional Requirements | FR-AUTH-001 |
| Related Business Rules | BR-ROLE-001 |
| Related Acceptance Criteria | AC-AUTH-001 |

---

### EC-AUTH-002: Expired Session Accesses Protected Feature

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Scenario | A user session expires while the user attempts to access a protected feature. |
| Risk | The user may access protected data without a valid session. |
| Expected Handling | The system must redirect the user to login or require re-authentication before continuing. |
| Related User Flow | UF-AUTH-002 |
| Related Functional Requirements | FR-AUTH-002, FR-AUTH-004 |
| Related Business Rules | BR-ROLE-002 |
| Related Acceptance Criteria | AC-AUTH-002, AC-AUTH-003 |

---

### EC-AUTH-003: Student Attempts to Access Staff Dashboard

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Scenario | A Student attempts to access Staff moderation tools directly through URL, navigation manipulation, or API request. |
| Risk | Student may access moderation data or perform unauthorized actions. |
| Expected Handling | The system must deny access and return an authorization error or redirect to an appropriate page. |
| Related User Flow | UF-AUTH-002 |
| Related Functional Requirements | FR-AUTH-004, FR-AUTH-007 |
| Related Business Rules | BR-ROLE-002, BR-ROLE-006 |
| Related Acceptance Criteria | AC-AUTH-003 |

---

### EC-AUTH-004: Teacher Without Staff Role Attempts Moderation

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Scenario | A Teacher who does not have Staff role attempts to access material review or teacher application approval tools. |
| Risk | Teachers may bypass Staff moderation and approve content improperly. |
| Expected Handling | The system must deny access because Teacher permission alone is not sufficient for moderation tools. |
| Related User Flow | UF-AUTH-002 |
| Related Functional Requirements | FR-AUTH-005, FR-AUTH-007 |
| Related Business Rules | BR-ROLE-003, BR-ROLE-006 |
| Related Acceptance Criteria | AC-AUTH-003, AC-AUTH-004 |

---

### EC-AUTH-005: Staff Attempts Admin-Only Action

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Scenario | A Staff member attempts to assign roles, revoke Staff permissions, or access Admin governance tools. |
| Risk | Staff may gain governance authority beyond their intended operational role. |
| Expected Handling | The system must deny access unless the user also has Admin permissions. |
| Related User Flow | UF-AUTH-002 |
| Related Functional Requirements | FR-AUTH-008, FR-ADM-001 |
| Related Business Rules | BR-ROLE-005 |
| Related Acceptance Criteria | AC-AUTH-003, AC-ADM-001 |

---

### EC-AUTH-006: Role Updated During Active Session

| Field | Value |
|---|---|
| Module | Authentication and Role Access |
| Priority | MVP |
| Scenario | Admin revokes or assigns a role while the affected user is currently logged in. |
| Risk | The user may continue using old permissions during the active session. |
| Expected Handling | The system should apply updated permissions on active session refresh, next protected action, or next login according to platform policy. |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-AUTH-003, FR-AUTH-004, FR-ADM-003 |
| Related Business Rules | BR-ROLE-004, BR-ADM-001 |
| Related Acceptance Criteria | AC-AUTH-005, AC-ADM-002 |

---

## 5. Teacher / Lecturer Edge Cases

### EC-TCH-001: User Submits Duplicate Teacher Application

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Scenario | A user with an existing pending teacher application attempts to submit another application. |
| Risk | Duplicate applications may create inconsistent review queues and conflicting statuses. |
| Expected Handling | The system must prevent duplicate submission and direct the user to their existing application status. |
| Related User Flow | UF-TCH-001 |
| Related Functional Requirements | FR-TCH-001, FR-TCH-002 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |
| Related Acceptance Criteria | AC-TCH-001 |

---

### EC-TCH-002: Rejected Applicant Attempts to Access Teacher Tools

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Scenario | A user whose teacher application was rejected attempts to access teacher-only tools. |
| Risk | Rejected users may upload content or create teaching resources without approval. |
| Expected Handling | The system must deny access and show the user their rejected application status. |
| Related User Flow | UF-TCH-002 |
| Related Functional Requirements | FR-TCH-003, FR-TCH-006 |
| Related Business Rules | BR-TCH-003 |
| Related Acceptance Criteria | AC-TCH-002, AC-TCH-003 |

---

### EC-TCH-003: Unapproved Teacher Attempts Material Upload

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | MVP |
| Scenario | A teacher applicant or regular user attempts to upload learning materials before Staff approval. |
| Risk | Unverified educators may contribute unreviewed learning content. |
| Expected Handling | The system must block the upload and inform the user that Teacher approval is required. |
| Related User Flow | UF-MAT-001 |
| Related Functional Requirements | FR-TCH-006, FR-MAT-001 |
| Related Business Rules | BR-TCH-003, BR-TCH-004 |
| Related Acceptance Criteria | AC-TCH-003, AC-MAT-001 |

---

### EC-TCH-004: Suspended Teacher Attempts Teacher Actions

| Field | Value |
|---|---|
| Module | Teacher / Lecturer |
| Priority | Phase 2 |
| Scenario | A Teacher whose privileges were suspended attempts to upload material, create classes, or generate public learning content. |
| Risk | Suspended Teachers may continue contributing content despite quality or policy issues. |
| Expected Handling | The system must deny restricted Teacher actions while suspension is active. |
| Related User Flow | UF-TCH-002, UF-MAT-001 |
| Related Functional Requirements | FR-TCH-003, FR-MAT-001 |
| Related Business Rules | BR-TCH-007 |
| Related Acceptance Criteria | AC-TCH-003 |

---

## 6. Staff Moderation Edge Cases

### EC-STF-001: Staff Attempts to Review Own Teacher Application

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Scenario | A user with both Teacher and Staff roles attempts to review their own teacher application. |
| Risk | Self-approval creates conflict of interest and weakens platform trust. |
| Expected Handling | The system must block the action and require another Staff member or Admin to review the application. |
| Related User Flow | UF-STF-001 |
| Related Functional Requirements | FR-STF-006 |
| Related Business Rules | BR-TCH-005, BR-STF-005 |
| Related Acceptance Criteria | AC-STF-004 |

---

### EC-STF-002: Staff Attempts to Approve Own Material

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Scenario | A Staff member who also owns a material as Teacher attempts to approve that material. |
| Risk | Staff may bypass independent content review. |
| Expected Handling | The system must block the moderation action and require another Staff member or Admin to handle the review. |
| Related User Flow | UF-STF-002 |
| Related Functional Requirements | FR-STF-006 |
| Related Business Rules | BR-TCH-005, BR-STF-005 |
| Related Acceptance Criteria | AC-STF-004 |

---

### EC-STF-003: Two Staff Members Review Same Material Simultaneously

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Scenario | Two Staff members open and review the same Pending Review material at the same time. |
| Risk | Conflicting decisions may overwrite each other and create inconsistent material status. |
| Expected Handling | The system should prevent stale updates by checking the latest material status before saving a moderation action. |
| Related User Flow | UF-STF-002 |
| Related Functional Requirements | FR-STF-005, FR-MAT-003 |
| Related Business Rules | BR-STF-004, BR-MAT-003 |
| Related Acceptance Criteria | AC-STF-003, AC-MAT-002 |

---

### EC-STF-004: Material Changes While Staff Is Reviewing

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | MVP |
| Scenario | A Teacher edits or resubmits material while Staff is already reviewing an older version. |
| Risk | Staff may approve outdated or incorrect material content. |
| Expected Handling | The system should prevent editing during active review or require Staff to review the latest submitted version only. |
| Related User Flow | UF-STF-002, UF-MAT-002 |
| Related Functional Requirements | FR-STF-005, FR-MAT-006 |
| Related Business Rules | BR-MAT-003, BR-MAT-005, BR-MAT-006 |
| Related Acceptance Criteria | AC-STF-003, AC-MAT-004 |

---

### EC-STF-005: Staff Rejects Material Without Reason

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | Phase 2 |
| Scenario | Staff rejects or requests revision for a material without providing a reason. |
| Risk | Teacher may not understand how to improve the material. |
| Expected Handling | The system should require or strongly encourage Staff feedback when rejecting or requesting revision. |
| Related User Flow | UF-STF-002, UF-MAT-002 |
| Related Functional Requirements | FR-STF-005 |
| Related Business Rules | BR-STF-004 |
| Related Acceptance Criteria | AC-STF-003, AC-MAT-004 |

---

### EC-STF-006: Staff Escalates Issue That Was Already Resolved

| Field | Value |
|---|---|
| Module | Staff Moderation |
| Priority | Phase 2 |
| Scenario | Staff attempts to escalate a moderation issue that has already been resolved or overridden. |
| Risk | Duplicate governance cases may confuse Admin review. |
| Expected Handling | The system should block duplicate escalation or attach the new escalation to the existing case. |
| Related User Flow | UF-STF-003 |
| Related Functional Requirements | FR-STF-007 |
| Related Business Rules | BR-STF-007 |
| Related Acceptance Criteria | AC-STF-005 |

---

## 7. Admin Governance Edge Cases

### EC-ADM-001: Non-Admin Attempts Role Assignment

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Scenario | A non-Admin user attempts to assign or revoke roles. |
| Risk | Unauthorized users may escalate privileges. |
| Expected Handling | The system must deny the action and preserve existing role assignments. |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-ADM-003, FR-AUTH-003 |
| Related Business Rules | BR-ROLE-004, BR-ADM-001, BR-ADM-002 |
| Related Acceptance Criteria | AC-AUTH-005, AC-ADM-002 |

---

### EC-ADM-002: Admin Revokes Staff Role During Active Review

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | MVP |
| Scenario | Admin revokes a Staff member’s role while the Staff member is reviewing content. |
| Risk | The Staff member may complete moderation actions after permissions are revoked. |
| Expected Handling | The system should re-check permissions before saving moderation actions and block the action if Staff permissions are no longer valid. |
| Related User Flow | UF-ADM-001, UF-STF-002 |
| Related Functional Requirements | FR-AUTH-004, FR-AUTH-006, FR-STF-005 |
| Related Business Rules | BR-ROLE-002, BR-ADM-001 |
| Related Acceptance Criteria | AC-AUTH-005, AC-STF-003 |

---

### EC-ADM-003: Admin Overrides Staff Decision on Public Material

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | Phase 2 |
| Scenario | Admin overrides a Staff decision for a material that is already visible to Students. |
| Risk | Students may continue accessing content that should no longer be visible. |
| Expected Handling | The system must update student-facing visibility immediately according to the override decision. |
| Related User Flow | UF-ADM-003 |
| Related Functional Requirements | FR-ADM-006, FR-MAT-005 |
| Related Business Rules | BR-ADM-005, BR-MAT-004 |
| Related Acceptance Criteria | AC-ADM-005, AC-MAT-003 |

---

### EC-ADM-004: Admin Assigns Staff Role to Trusted Teacher

| Field | Value |
|---|---|
| Module | Admin Governance |
| Priority | Phase 2 |
| Scenario | Admin assigns Staff role to a trusted Teacher. |
| Risk | The user may have both content ownership and moderation authority. |
| Expected Handling | The system may allow the multi-role assignment, but must continue enforcing self-review prevention rules. |
| Related User Flow | UF-ADM-001 |
| Related Functional Requirements | FR-AUTH-005, FR-ADM-003 |
| Related Business Rules | BR-ROLE-004, BR-TCH-006, BR-STF-005 |
| Related Acceptance Criteria | AC-AUTH-004, AC-STF-004 |

---

## 8. Study Material Edge Cases

### EC-MAT-001: Material Missing Required Information

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Scenario | Teacher attempts to upload or submit a material without title, subject, description, or content source. |
| Risk | Incomplete materials may be difficult to review, categorize, search, or use. |
| Expected Handling | The system must show validation errors and prevent submission until required information is provided. |
| Related User Flow | UF-MAT-001 |
| Related Functional Requirements | FR-MAT-002 |
| Related Business Rules | BR-MAT-001, BR-MAT-002 |
| Related Acceptance Criteria | AC-MAT-001 |

---

### EC-MAT-002: Student Attempts to Access Pending Review Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Scenario | Student attempts to access a material with Pending Review status through direct URL or cached listing. |
| Risk | Student may access unreviewed content. |
| Expected Handling | The system must deny access and exclude the material from student-facing pages. |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-MAT-005, FR-STU-003 |
| Related Business Rules | BR-MAT-004 |
| Related Acceptance Criteria | AC-MAT-003 |

---

### EC-MAT-003: Student Attempts to Access Hidden or Archived Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Scenario | Student attempts to open a material that was hidden or archived after being previously visible. |
| Risk | Student may access content that should no longer be available. |
| Expected Handling | The system must block access and show an unavailable or removed content state. |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-MAT-005 |
| Related Business Rules | BR-MAT-004 |
| Related Acceptance Criteria | AC-MAT-003 |

---

### EC-MAT-004: Material Becomes Hidden While Student Is Viewing It

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | Phase 2 |
| Scenario | A material is hidden by Staff or Admin while a Student is currently viewing it. |
| Risk | Student may continue learning from content that has been removed from public access. |
| Expected Handling | The system should prevent further interaction and show an updated availability message on refresh or next action. |
| Related User Flow | UF-STF-002, UF-MAT-003 |
| Related Functional Requirements | FR-MAT-005 |
| Related Business Rules | BR-MAT-004 |
| Related Acceptance Criteria | AC-MAT-003 |

---

### EC-MAT-005: Teacher Edits Approved Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | Phase 2 |
| Scenario | Teacher edits a material that was already approved and visible to Students. |
| Risk | Approved content may change without Staff re-review. |
| Expected Handling | The system should either create a draft revision or require Staff re-review for major edits according to platform policy. |
| Related User Flow | UF-MAT-002 |
| Related Functional Requirements | FR-MAT-006, FR-MAT-007 |
| Related Business Rules | BR-MAT-007 |
| Related Acceptance Criteria | AC-MAT-004 |

---

### EC-MAT-006: Teacher Attempts to Edit Another Teacher’s Material

| Field | Value |
|---|---|
| Module | Study Materials |
| Priority | MVP |
| Scenario | Teacher attempts to edit material owned by another Teacher. |
| Risk | Content ownership and accountability may be violated. |
| Expected Handling | The system must deny editing access unless explicit permissions are granted by platform policy. |
| Related User Flow | UF-MAT-002 |
| Related Functional Requirements | FR-MAT-006 |
| Related Business Rules | BR-MAT-002, BR-MAT-006 |
| Related Acceptance Criteria | AC-MAT-004 |

---

## 9. AI Content Generation Edge Cases

### EC-AI-001: AI Generation Fails

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Scenario | AI quiz or flashcard generation fails due to service error, timeout, or unsupported content. |
| Risk | Teacher may receive incomplete or unreliable generated content. |
| Expected Handling | The system must show an error, avoid publishing incomplete output, and allow retry where appropriate. |
| Related User Flow | UF-AI-001, UF-AI-002 |
| Related Functional Requirements | FR-AI-001, FR-AI-002 |
| Related Business Rules | BR-AI-006 |
| Related Acceptance Criteria | AC-AI-001, AC-AI-002 |

---

### EC-AI-002: AI Generates Low-Quality or Incorrect Content

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Scenario | AI generates quiz questions, answers, explanations, or flashcards that are inaccurate, unclear, duplicated, or low quality. |
| Risk | Students may learn incorrect information if content is published without review. |
| Expected Handling | The system must keep AI-generated content in Draft state and require Teacher review before student access. |
| Related User Flow | UF-AI-003 |
| Related Functional Requirements | FR-AI-003, FR-AI-004, FR-AI-005 |
| Related Business Rules | BR-AI-002, BR-AI-006 |
| Related Acceptance Criteria | AC-AI-003, AC-AI-004 |

---

### EC-AI-003: Teacher Attempts to Publish Unreviewed AI Content

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Scenario | Teacher attempts to make AI-generated content visible to Students without completing review. |
| Risk | Unverified AI content may become available to Students. |
| Expected Handling | The system must block publication until Teacher review is completed. |
| Related User Flow | UF-AI-003 |
| Related Functional Requirements | FR-AI-005 |
| Related Business Rules | BR-AI-002, BR-AI-006 |
| Related Acceptance Criteria | AC-AI-004 |

---

### EC-AI-004: AI Content Requires Staff Approval but Staff Approval Is Missing

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Scenario | Platform policy requires Staff approval for AI-generated content, but Teacher attempts to publish after Teacher review only. |
| Risk | AI content may bypass moderation policy. |
| Expected Handling | The system must keep the content unavailable to Students until Staff approval is completed. |
| Related User Flow | UF-AI-003 |
| Related Functional Requirements | FR-AI-005 |
| Related Business Rules | BR-AI-003, BR-AI-006 |
| Related Acceptance Criteria | AC-AI-004 |

---

### EC-AI-005: AI-Generated Content Loses AI-Assisted Label After Editing

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | MVP |
| Scenario | Teacher edits AI-generated content and the AI-assisted label disappears. |
| Risk | Users may not know that content was AI-assisted. |
| Expected Handling | The system should preserve AI-assisted traceability according to platform policy. |
| Related User Flow | UF-AI-003 |
| Related Functional Requirements | FR-AI-006 |
| Related Business Rules | BR-AI-001 |
| Related Acceptance Criteria | AC-AI-005 |

---

### EC-AI-006: AI Uses Insufficient Material Content

| Field | Value |
|---|---|
| Module | AI Content Generation |
| Priority | Phase 2 |
| Scenario | Teacher tries to generate quiz or flashcards from material with too little meaningful content. |
| Risk | AI may produce generic, irrelevant, or hallucinated content. |
| Expected Handling | The system should warn the Teacher, ask for more content, or generate only limited draft output. |
| Related User Flow | UF-AI-001, UF-AI-002 |
| Related Functional Requirements | FR-AI-001, FR-AI-002 |
| Related Business Rules | BR-AI-004, BR-AI-006 |
| Related Acceptance Criteria | AC-AI-001, AC-AI-002 |

---

## 10. Student Practice Edge Cases

### EC-PRAC-001: Student Submits Quiz Twice

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Scenario | Student clicks submit multiple times or resubmits a completed quiz attempt. |
| Risk | Duplicate submissions may create duplicate scores or inconsistent learning history. |
| Expected Handling | The system must prevent duplicate scoring for the same attempt. |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-002, FR-PRAC-005 |
| Related Business Rules | BR-PRAC-003 |
| Related Acceptance Criteria | AC-PRAC-002, AC-PRAC-004 |

---

### EC-PRAC-002: Quiz Has Missing Evaluation Rules

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Scenario | Student submits a quiz that has questions without correct answers or evaluation rules. |
| Risk | System may calculate invalid scores. |
| Expected Handling | The system must not produce invalid scores and should flag the quiz for Teacher or Staff review. |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-003 |
| Related Business Rules | BR-PRAC-002 |
| Related Acceptance Criteria | AC-PRAC-003 |

---

### EC-PRAC-003: Quiz Becomes Unavailable During Attempt

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | Phase 2 |
| Scenario | A quiz is hidden, archived, or removed while a Student is taking it. |
| Risk | Student may complete an invalid or unavailable practice activity. |
| Expected Handling | The system should either allow the current attempt to finish or stop the attempt according to platform policy, while preventing new attempts. |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-001, FR-PRAC-002, FR-PRAC-005 |
| Related Business Rules | BR-MAT-004, BR-PRAC-003 |
| Related Acceptance Criteria | AC-PRAC-001, AC-PRAC-004 |

---

### EC-PRAC-004: Student Exits Quiz Before Submission

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Scenario | Student starts a quiz but closes the page or exits before submitting. |
| Risk | Incomplete attempts may pollute learning history or confuse progress tracking. |
| Expected Handling | The system should mark the attempt as incomplete, discard it, or save partial progress according to platform policy. |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-005 |
| Related Business Rules | BR-PRAC-003 |
| Related Acceptance Criteria | AC-PRAC-004 |

---

### EC-PRAC-005: Student Attempts to Retake Restricted Activity

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Scenario | Student attempts to retake a practice activity that is configured as non-retakable or restricted. |
| Risk | Student may bypass activity rules. |
| Expected Handling | The system must block the retake and explain that the activity is restricted. |
| Related User Flow | UF-PRAC-001 |
| Related Functional Requirements | FR-PRAC-006 |
| Related Business Rules | BR-PRAC-005 |
| Related Acceptance Criteria | AC-PRAC-005 |

---

### EC-PRAC-006: Flashcard Set Is Empty

| Field | Value |
|---|---|
| Module | Student Practice |
| Priority | MVP |
| Scenario | Student opens a flashcard set that has no cards. |
| Risk | Student may encounter a broken or confusing practice experience. |
| Expected Handling | The system must show an empty state and avoid starting an invalid practice session. |
| Related User Flow | UF-PRAC-002 |
| Related Functional Requirements | FR-PRAC-007 |
| Related Business Rules | BR-PRAC-001 |
| Related Acceptance Criteria | AC-PRAC-006 |

---

## 11. Search and Discovery Edge Cases

### EC-SEARCH-001: Search Returns Hidden or Unapproved Materials

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Scenario | Search query matches materials that are Draft, Pending Review, Rejected, Needs Revision, Hidden, or Archived. |
| Risk | Student may discover content that should not be visible. |
| Expected Handling | The system must exclude all unapproved or non-visible materials from Student search results. |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-SEARCH-001, FR-SEARCH-003 |
| Related Business Rules | BR-MAT-004 |
| Related Acceptance Criteria | AC-SEARCH-001, AC-SEARCH-002 |

---

### EC-SEARCH-002: No Search Results

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | MVP |
| Scenario | Student searches for a keyword or subject with no approved matching materials. |
| Risk | Student may think the platform is broken or empty. |
| Expected Handling | The system should show a clear empty state and may suggest broader search terms or subjects. |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-SEARCH-001, FR-SEARCH-002 |
| Related Business Rules | BR-MAT-004 |
| Related Acceptance Criteria | AC-SEARCH-001, AC-SEARCH-002 |

---

### EC-SEARCH-003: Material Status Changes After Search Result Is Displayed

| Field | Value |
|---|---|
| Module | Search and Discovery |
| Priority | Phase 2 |
| Scenario | Student sees a material in search results, but the material is hidden or archived before the Student opens it. |
| Risk | Student may access content that is no longer visible. |
| Expected Handling | The system must re-check visibility when the Student opens the material and block access if it is no longer approved and visible. |
| Related User Flow | UF-MAT-003 |
| Related Functional Requirements | FR-MAT-005, FR-SEARCH-003 |
| Related Business Rules | BR-MAT-004 |
| Related Acceptance Criteria | AC-MAT-003, AC-SEARCH-001 |

---

## 12. Personalization and Recommendation Edge Cases

### EC-PER-001: Student Provides Insufficient Personalization Input

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Scenario | Student requests AI personalization but provides incomplete learning goals, weak areas, or available study time. |
| Risk | AI may generate overconfident or irrelevant recommendations. |
| Expected Handling | The system should ask clarifying questions or provide a general roadmap with clear limitations. |
| Related User Flow | UF-PER-001, UF-PER-002 |
| Related Functional Requirements | FR-PER-001, FR-PER-002, FR-PER-006 |
| Related Business Rules | BR-PER-001, BR-PER-005 |
| Related Acceptance Criteria | AC-PER-001, AC-PER-002 |

---

### EC-PER-002: AI Recommends Unapproved Material

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Scenario | AI recommendation process selects material that is not approved or not visible. |
| Risk | Student may be directed to unreviewed or hidden content. |
| Expected Handling | The system must filter recommendations to include only approved and visible materials. |
| Related User Flow | UF-PER-003 |
| Related Functional Requirements | FR-PER-004 |
| Related Business Rules | BR-PER-003, BR-MAT-004 |
| Related Acceptance Criteria | AC-PER-004 |

---

### EC-PER-003: AI Recommends Unverified or Inactive Teacher

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Scenario | AI recommends a Teacher who is not verified, inactive, suspended, or not eligible for recommendation. |
| Risk | Student may be connected to an unsuitable or unavailable Teacher. |
| Expected Handling | The system must filter Teacher recommendations to include only verified, active, and eligible Teachers. |
| Related User Flow | UF-PER-003 |
| Related Functional Requirements | FR-PER-005 |
| Related Business Rules | BR-PER-004 |
| Related Acceptance Criteria | AC-PER-005 |

---

### EC-PER-004: No Matching Materials or Teachers

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Scenario | Student roadmap requires materials or Teachers that do not exist on the platform. |
| Risk | Student may receive empty or low-value recommendations. |
| Expected Handling | The system should show fallback recommendations, ask the Student to broaden criteria, or provide a general learning suggestion. |
| Related User Flow | UF-PER-003 |
| Related Functional Requirements | FR-PER-004, FR-PER-005 |
| Related Business Rules | BR-PER-003, BR-PER-004, BR-PER-005 |
| Related Acceptance Criteria | AC-PER-004, AC-PER-005 |

---

### EC-PER-005: Student Updates Preferences After Roadmap Generation

| Field | Value |
|---|---|
| Module | Personalization and Recommendation |
| Priority | Phase 2 |
| Scenario | Student changes learning goals, weak areas, or available study time after a roadmap was already generated. |
| Risk | Old roadmap may no longer match Student needs. |
| Expected Handling | The system should allow roadmap regeneration or indicate that recommendations are based on previous preferences. |
| Related User Flow | UF-PER-001, UF-PER-002 |
| Related Functional Requirements | FR-PER-007, FR-PER-003 |
| Related Business Rules | BR-PER-006 |
| Related Acceptance Criteria | AC-PER-001, AC-PER-003 |

---

## 13. Class and Course Edge Cases

### EC-CLS-001: Unapproved Teacher Attempts to Create Class

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Scenario | A user who is not an approved Teacher attempts to create a class. |
| Risk | Unverified users may create teacher-led learning spaces. |
| Expected Handling | The system must block class creation and require Teacher approval. |
| Related User Flow | UF-CLS-001 |
| Related Functional Requirements | FR-CLS-001 |
| Related Business Rules | BR-CLS-001 |
| Related Acceptance Criteria | AC-CLS-001 |

---

### EC-CLS-002: Duplicate Class Enrollment Request

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Scenario | Student submits multiple enrollment requests for the same class. |
| Risk | Duplicate requests may confuse Teacher review and enrollment status. |
| Expected Handling | The system must prevent duplicate active enrollment requests. |
| Related User Flow | UF-CLS-002 |
| Related Functional Requirements | FR-CLS-002 |
| Related Business Rules | BR-CLS-002 |
| Related Acceptance Criteria | AC-CLS-002 |

---

### EC-CLS-003: Class Reaches Capacity During Enrollment

| Field | Value |
|---|---|
| Module | Class Management |
| Priority | Phase 2 |
| Scenario | A class reaches capacity while a Student is requesting or awaiting enrollment approval. |
| Risk | Teacher may approve more Students than the class can support. |
| Expected Handling | The system should prevent approval beyond capacity or move Students to a waitlist if supported. |
| Related User Flow | UF-CLS-002, UF-CLS-003 |
| Related Functional Requirements | FR-CLS-002, FR-CLS-003 |
| Related Business Rules | BR-CLS-002, BR-CLS-003 |
| Related Acceptance Criteria | AC-CLS-002, AC-CLS-003 |

---

### EC-COURSE-001: Course Submitted Without Required Structure

| Field | Value |
|---|---|
| Module | Course Management |
| Priority | Future |
| Scenario | Teacher submits a course without required modules, lessons, or learning content. |
| Risk | Students may see incomplete or unusable courses. |
| Expected Handling | The system should show validation errors or prevent public listing until minimum structure is satisfied. |
| Related User Flow | UF-COURSE-001 |
| Related Functional Requirements | FR-COURSE-001, FR-COURSE-002 |
| Related Business Rules | BR-CLS-004, BR-CLS-005 |
| Related Acceptance Criteria | AC-COURSE-001, AC-COURSE-002 |

---

## 14. Parent Edge Cases

### EC-PAR-001: Parent Attempts to View Student Data Without Verification

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Scenario | Parent attempts to access Student progress without a verified parent-student relationship. |
| Risk | Student learning data may be exposed without authorization. |
| Expected Handling | The system must deny access until the relationship is verified. |
| Related User Flow | UF-PAR-001, UF-PAR-002 |
| Related Functional Requirements | FR-PAR-002, FR-PAR-003 |
| Related Business Rules | BR-PAR-002 |
| Related Acceptance Criteria | AC-PAR-001, AC-PAR-002 |

---

### EC-PAR-002: Student Revokes Parent Access

| Field | Value |
|---|---|
| Module | Parent Features |
| Priority | Future |
| Scenario | Student or authorized process revokes a previously verified Parent relationship. |
| Risk | Parent may continue accessing Student data after authorization is removed. |
| Expected Handling | The system should remove Parent access immediately according to platform policy. |
| Related User Flow | UF-PAR-002 |
| Related Functional Requirements | FR-PAR-002, FR-PAR-003 |
| Related Business Rules | BR-PAR-002 |
| Related Acceptance Criteria | AC-PAR-002 |

---

## 15. Reporting, Review, and Rating Edge Cases

### EC-REP-001: Duplicate Reports on Same Content

| Field | Value |
|---|---|
| Module | Reporting |
| Priority | Phase 2 |
| Scenario | Multiple users report the same material, AI output, Teacher profile, or community content. |
| Risk | Staff review queue may become cluttered with duplicate issues. |
| Expected Handling | The system may group duplicate reports or attach them to the same moderation case. |
| Related User Flow | UF-REP-001, UF-STF-003 |
| Related Functional Requirements | FR-REP-001, FR-STF-008 |
| Related Business Rules | BR-STF-006 |
| Related Acceptance Criteria | AC-REP-001 |

---

### EC-REP-002: User Reports Content Already Hidden

| Field | Value |
|---|---|
| Module | Reporting |
| Priority | Phase 2 |
| Scenario | User attempts to report content that has already been hidden or archived. |
| Risk | Report may be redundant or refer to inaccessible content. |
| Expected Handling | The system should either prevent the report or attach it to the existing moderation record. |
| Related User Flow | UF-REP-001 |
| Related Functional Requirements | FR-REP-001 |
| Related Business Rules | BR-STF-006 |
| Related Acceptance Criteria | AC-REP-001 |

---

### EC-REV-001: User Reviews Content Without Valid Interaction

| Field | Value |
|---|---|
| Module | Review and Rating |
| Priority | Future |
| Scenario | User attempts to review a material, Teacher, class, or course they have not interacted with. |
| Risk | Reviews may become unreliable or spammy. |
| Expected Handling | The system must block the review unless valid interaction exists. |
| Related User Flow | UF-REV-001 |
| Related Functional Requirements | FR-REV-001 |
| Related Business Rules | BR-REV-001 |
| Related Acceptance Criteria | AC-REV-001 |

---

### EC-REV-002: Teacher Reviews Own Content

| Field | Value |
|---|---|
| Module | Review and Rating |
| Priority | Future |
| Scenario | Teacher attempts to review or rate their own material, class, or course. |
| Risk | Rating and trust systems may be manipulated. |
| Expected Handling | The system must block self-review. |
| Related User Flow | UF-REV-001 |
| Related Functional Requirements | FR-REV-002 |
| Related Business Rules | BR-REV-002 |
| Related Acceptance Criteria | AC-REV-002 |

---

## 16. Exam and Assessment Edge Cases

### EC-EXAM-001: Student Attempts to Access Answers Before Submission

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Scenario | Student attempts to view correct exam answers before submitting the exam. |
| Risk | Exam integrity is compromised. |
| Expected Handling | The system must block access to correct answers before submission and according to exam settings. |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-002 |
| Related Business Rules | BR-EXAM-005 |
| Related Acceptance Criteria | AC-EXAM-002 |

---

### EC-EXAM-002: Exam Time Expires During Attempt

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Scenario | Student is taking a timed exam and the time limit expires. |
| Risk | Student may continue answering beyond allowed time. |
| Expected Handling | The system should auto-submit, lock, or end the exam attempt according to exam policy. |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-002 |
| Related Business Rules | BR-EXAM-002 |
| Related Acceptance Criteria | AC-EXAM-002 |

---

### EC-EXAM-003: Student Attempts to Retake Restricted Exam

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Scenario | Student attempts to retake a formal exam beyond the allowed attempt limit. |
| Risk | Exam rules may be bypassed. |
| Expected Handling | The system must block additional attempts beyond configured limits. |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-002 |
| Related Business Rules | BR-EXAM-002 |
| Related Acceptance Criteria | AC-EXAM-002 |

---

### EC-EXAM-004: AI-Assisted Written Grading Without Teacher Review

| Field | Value |
|---|---|
| Module | Exam and Assessment |
| Priority | Future |
| Scenario | AI generates a written-response grade, but the system attempts to finalize it without Teacher review. |
| Risk | Incorrect AI grading may become official. |
| Expected Handling | The system must keep AI grading as a suggestion until Teacher review is completed. |
| Related User Flow | UF-EXAM-002 |
| Related Functional Requirements | FR-EXAM-004 |
| Related Business Rules | BR-EXAM-004 |
| Related Acceptance Criteria | AC-EXAM-004 |

---

## 17. Monetization and Payment Edge Cases

### EC-PAY-001: User Attempts Premium Feature Without Entitlement

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Scenario | User attempts to access a premium feature without valid entitlement or subscription. |
| Risk | Premium access rules may be bypassed. |
| Expected Handling | The system must restrict access and show an upgrade or access message. |
| Related User Flow | UF-PAY-001 |
| Related Functional Requirements | FR-PAY-001 |
| Related Business Rules | BR-PAY-001, BR-PAY-002 |
| Related Acceptance Criteria | AC-PAY-001 |

---

### EC-PAY-002: Payment Fails During Teacher Marketplace Transaction

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Scenario | Payment fails while Student or Parent is purchasing a paid Teacher service. |
| Risk | User may receive access without successful payment or transaction state may become inconsistent. |
| Expected Handling | The system must not complete the transaction and must show payment failure status. |
| Related User Flow | UF-PAY-002 |
| Related Functional Requirements | FR-PAY-002 |
| Related Business Rules | BR-PAY-003 |
| Related Acceptance Criteria | AC-PAY-002 |

---

### EC-PAY-003: Teacher Service Becomes Unavailable During Payment

| Field | Value |
|---|---|
| Module | Monetization and Payment |
| Priority | Future |
| Scenario | A paid Teacher service becomes unavailable while a payment transaction is in progress. |
| Risk | User may pay for a service that can no longer be delivered. |
| Expected Handling | The system should cancel or block the transaction and notify the user. |
| Related User Flow | UF-PAY-002 |
| Related Functional Requirements | FR-PAY-002 |
| Related Business Rules | BR-PAY-003 |
| Related Acceptance Criteria | AC-PAY-002 |

---

## 18. MVP Edge Case Summary

The MVP must handle the following edge case groups:

- Duplicate registration.
- Expired sessions.
- Unauthorized access to Staff and Admin tools.
- Teacher and Staff role separation.
- Staff self-review prevention.
- Teacher application duplicate submission.
- Rejected or unapproved Teacher access attempts.
- Unapproved Teacher material upload attempts.
- Material missing required information.
- Student access to unapproved, hidden, rejected, or archived materials.
- Staff moderation conflicts.
- AI generation failure.
- AI-generated content remaining unavailable until Teacher review.
- AI-assisted label preservation.
- Student duplicate quiz submission.
- Quiz missing evaluation rules.
- Flashcard empty state.
- Search excluding hidden or unapproved content.
- Admin role assignment and revocation behavior.

---

## 19. Notes for Testing

Edge cases should be translated into test cases in `12-testing-strategy.md`.

Testing should prioritize:

- Access control failures.
- Role boundary violations.
- Staff self-review prevention.
- Material status transitions.
- Student visibility filtering.
- AI-generated content review workflow.
- Quiz submission consistency.
- Search filtering correctness.
- Admin role assignment and revocation.
- Moderation conflict handling.

Recommended test categories:

- Unit tests for permission checks and state transitions.
- Integration tests for multi-role workflows.
- End-to-end tests for Teacher upload → Staff review → Student access.
- AI workflow tests for draft generation and Teacher review.
- Regression tests for material visibility and role enforcement.

Example traceability:

> EC-MAT-002 → AC-MAT-003 → FR-MAT-005 → BR-MAT-004

The next recommended document is `07-system-architecture.md`.