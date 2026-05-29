# HIPZI Business Rules

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Business Rules Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Designer, Researcher |
| Language | English |

---

## 1. Purpose

This document defines the business rules for HIPZI.

Business rules describe the mandatory policies, constraints, and operational rules that the platform must follow regardless of technical implementation.

This document focuses on what must be true in the business domain. It does not define API contracts, database schema, UI design, or implementation details.

The business rules in this document should guide future documents including:

- Functional requirements.
- User flows.
- Acceptance criteria.
- Edge cases.
- System requirements.
- Database design.
- API design.
- Testing strategy.

---

## 2. Rule Classification

Each business rule uses a stable ID so it can be referenced by functional requirements, acceptance criteria, tests, and implementation tasks.

### 2.1 Business Rule ID Prefixes

| Prefix | Category |
|---|---|
| BR-ROLE | Role and Permission Rules |
| BR-TCH | Teacher / Lecturer Rules |
| BR-STF | Staff Rules |
| BR-ADM | Admin Governance Rules |
| BR-MAT | Study Material Rules |
| BR-AI | AI-Generated Content Rules |
| BR-PRAC | Quiz, Flashcard, and Practice Rules |
| BR-PER | Personalization and Recommendation Rules |
| BR-CLS | Class, Course, and Enrollment Rules |
| BR-PAR | Parent Access Rules |
| BR-REV | Review and Rating Rules |
| BR-EXAM | Exam and Assessment Rules |
| BR-PAY | Monetization and Payment Rules |

### 2.2 Priority Levels

| Priority | Meaning |
|---|---|
| MVP | Required for the first usable version |
| Phase 2 | Important after the MVP is validated |
| Future | Long-term or advanced rule |

---

## 3. Core Governance Principle

HIPZI has five major user roles:

- Student
- Parent
- Teacher / Lecturer
- Staff
- Admin

The platform must separate teaching responsibilities from moderation responsibilities.

Teachers create educational content and support students. Staff members review teacher applications, moderate uploaded materials, and handle operational quality control. Admins manage high-level governance, role assignment, policy configuration, audit, and override decisions.

A user may hold multiple roles only when explicitly assigned by an Admin.

---

## 4. Role and Permission Rules

### BR-ROLE-001: Every User Must Have a Role

| Field | Value |
|---|---|
| Category | Role and Permission |
| Priority | MVP |
| Rule | Every user account must have at least one assigned role. |
| Rationale | HIPZI uses role-based permissions to control access to learning, teaching, moderation, and governance features. |
| Applies To | Student, Parent, Teacher, Staff, Admin |
| Related User Requirements | UR-GEN-001 |

---

### BR-ROLE-002: Role-Based Access Must Be Enforced

| Field | Value |
|---|---|
| Category | Role and Permission |
| Priority | MVP |
| Rule | Users may only access features and data permitted by their assigned role or roles. |
| Rationale | Role-based access prevents unauthorized users from accessing teacher tools, staff moderation tools, or admin governance functions. |
| Applies To | All Users |
| Related User Requirements | UR-GEN-001 |

---

### BR-ROLE-003: Teacher and Staff Are Separate Roles by Default

| Field | Value |
|---|---|
| Category | Role and Permission |
| Priority | MVP |
| Rule | Teacher and Staff must be treated as separate roles by default. |
| Rationale | Teachers create content, while Staff moderate and approve content. Separating these roles prevents conflicts of interest. |
| Applies To | Teacher, Staff, Admin |
| Related User Requirements | UR-GEN-003 |

---

### BR-ROLE-004: Multiple Roles Require Admin Assignment

| Field | Value |
|---|---|
| Category | Role and Permission |
| Priority | MVP |
| Rule | A user may hold multiple roles only when explicitly assigned by an Admin. |
| Rationale | Multi-role access must be controlled to avoid privilege abuse and governance issues. |
| Applies To | All Users |
| Related User Requirements | UR-GEN-002 |

---

### BR-ROLE-005: Admin-Only Operations Must Be Protected

| Field | Value |
|---|---|
| Category | Role and Permission |
| Priority | MVP |
| Rule | Admin-only operations must not be accessible to Students, Parents, Teachers, or Staff unless explicitly permitted by Admin-level authorization. |
| Rationale | Admin functions control platform governance and must be protected from unauthorized access. |
| Applies To | Admin |
| Related User Requirements | UR-ADM-001, UR-GEN-001 |

---

### BR-ROLE-006: Staff-Only Operations Must Be Protected

| Field | Value |
|---|---|
| Category | Role and Permission |
| Priority | MVP |
| Rule | Staff moderation operations must not be accessible to Students, Parents, or Teachers unless the user has been explicitly assigned a Staff role. |
| Rationale | Moderation authority must be limited to authorized Staff members. |
| Applies To | Staff |
| Related User Requirements | UR-STF-001, UR-GEN-001 |

---

## 5. Teacher / Lecturer Rules

### BR-TCH-001: Teacher Application Is Required

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | MVP |
| Rule | A user must submit a teacher application before becoming a verified Teacher on HIPZI. |
| Rationale | HIPZI must verify teachers before allowing them to publish educational content. |
| Applies To | Teacher, Staff |
| Related User Requirements | UR-TCH-001, UR-TCH-002 |

---

### BR-TCH-002: Staff Approval Is Required for Teacher Verification

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | MVP |
| Rule | A teacher application must be reviewed and approved by Staff before the user receives verified Teacher permissions. |
| Rationale | Staff-based teacher approval helps maintain educational quality and platform trust. |
| Applies To | Teacher, Staff |
| Related User Requirements | UR-TCH-002, UR-STF-002, UR-STF-003 |

---

### BR-TCH-003: Rejected Teacher Applications Must Not Grant Teacher Permissions

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | MVP |
| Rule | Rejected teacher applications must not grant access to teacher-only publishing or class management features. |
| Rationale | Only approved teachers should be able to create public educational content. |
| Applies To | Teacher, Staff |
| Related User Requirements | UR-TCH-002, UR-STF-003 |

---

### BR-TCH-004: Approved Teachers Can Upload Learning Materials for Review

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | MVP |
| Rule | Only approved teachers can upload learning materials for Staff review. |
| Rationale | Upload permissions should be limited to verified educators. |
| Applies To | Teacher |
| Related User Requirements | UR-TCH-003 |

---

### BR-TCH-005: Teachers Must Not Approve Their Own Content

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | MVP |
| Rule | Teachers must not approve their own teacher application, materials, courses, quizzes, exams, or AI-generated learning content, even if they also hold a Staff role. |
| Rationale | This prevents conflict of interest and preserves moderation fairness. |
| Applies To | Teacher, Staff, Admin |
| Related User Requirements | UR-STF-009, UR-GEN-003 |

---

### BR-TCH-006: Trusted Teachers May Receive Additional Staff Role

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | Phase 2 |
| Rule | Trusted teachers with strong performance, verified expertise, or a history of high-quality contributions may be assigned an additional Staff role by an Admin. |
| Rationale | This allows HIPZI to scale moderation capacity while maintaining quality standards. |
| Applies To | Teacher, Staff, Admin |
| Related User Requirements | UR-ADM-004, UR-GEN-002 |

---

### BR-TCH-007: Teacher Privileges May Be Suspended or Revoked

| Field | Value |
|---|---|
| Category | Teacher / Lecturer |
| Priority | Phase 2 |
| Rule | Teacher privileges may be suspended or revoked if quality issues, policy violations, or trust violations occur. |
| Rationale | HIPZI must protect students and maintain educational quality. |
| Applies To | Teacher, Staff, Admin |
| Related User Requirements | UR-ADM-009 |

---

## 6. Staff Rules

### BR-STF-001: Staff Can Review Teacher Applications

| Field | Value |
|---|---|
| Category | Staff |
| Priority | MVP |
| Rule | Staff can review teacher applications submitted by users who want to become verified educators. |
| Rationale | Staff are responsible for teacher verification workflows. |
| Applies To | Staff, Teacher |
| Related User Requirements | UR-STF-002 |

---

### BR-STF-002: Staff Can Approve or Reject Teacher Applications

| Field | Value |
|---|---|
| Category | Staff |
| Priority | MVP |
| Rule | Staff can approve or reject teacher applications according to platform policy. |
| Rationale | Staff approval controls which users can become verified Teachers. |
| Applies To | Staff, Teacher |
| Related User Requirements | UR-STF-003 |

---

### BR-STF-003: Staff Can Review Uploaded Learning Materials

| Field | Value |
|---|---|
| Category | Staff |
| Priority | MVP |
| Rule | Staff can review learning materials uploaded by approved Teachers before the materials become publicly visible to Students. |
| Rationale | Content review is necessary to maintain trust and educational quality. |
| Applies To | Staff, Teacher, Student |
| Related User Requirements | UR-STF-004, UR-TCH-003 |

---

### BR-STF-004: Staff Can Moderate Learning Materials

| Field | Value |
|---|---|
| Category | Staff |
| Priority | MVP |
| Rule | Staff can approve, reject, request revision, hide, or archive learning materials according to platform policy. |
| Rationale | Staff need moderation actions to control content quality and visibility. |
| Applies To | Staff |
| Related User Requirements | UR-STF-005 |

---

### BR-STF-005: Staff Must Not Review Their Own Content

| Field | Value |
|---|---|
| Category | Staff |
| Priority | MVP |
| Rule | If a Staff member also has a Teacher role, they must not review or approve their own teacher application, uploaded materials, courses, quizzes, exams, or AI-generated learning content. |
| Rationale | Self-review creates conflicts of interest and weakens platform trust. |
| Applies To | Staff, Teacher |
| Related User Requirements | UR-STF-009 |

---

### BR-STF-006: Staff Can Review Reported Content

| Field | Value |
|---|---|
| Category | Staff |
| Priority | Phase 2 |
| Rule | Staff can review reported materials, AI-generated content, teacher profiles, courses, or community content. |
| Rationale | Reporting workflows help maintain platform safety and educational accuracy. |
| Applies To | Staff, Student, Teacher |
| Related User Requirements | UR-STF-006, UR-GEN-007 |

---

### BR-STF-007: Staff Can Escalate Serious Issues to Admins

| Field | Value |
|---|---|
| Category | Staff |
| Priority | Phase 2 |
| Rule | Staff must escalate serious policy violations, disputes, or high-risk moderation issues to Admins. |
| Rationale | High-impact decisions require Admin-level governance authority. |
| Applies To | Staff, Admin |
| Related User Requirements | UR-STF-008, UR-ADM-009 |

---

## 7. Admin Governance Rules

### BR-ADM-001: Admins Can Assign and Revoke Staff Permissions

| Field | Value |
|---|---|
| Category | Admin Governance |
| Priority | MVP |
| Rule | Admins can assign or revoke Staff permissions for eligible users. |
| Rationale | Staff permissions must be governed by Admin authority. |
| Applies To | Admin, Staff |
| Related User Requirements | UR-ADM-003 |

---

### BR-ADM-002: Admins Can Manage User Roles

| Field | Value |
|---|---|
| Category | Admin Governance |
| Priority | MVP |
| Rule | Admins can manage user roles and role assignments across the platform. |
| Rationale | Role management is required for platform governance and access control. |
| Applies To | Admin, All Users |
| Related User Requirements | UR-ADM-002, UR-GEN-002 |

---

### BR-ADM-003: Admins Can Manage Platform Subjects and Categories

| Field | Value |
|---|---|
| Category | Admin Governance |
| Priority | MVP |
| Rule | Admins can create, update, and manage subjects and platform-level learning categories. |
| Rationale | Materials must be organized by subjects and categories for learning discovery. |
| Applies To | Admin |
| Related User Requirements | UR-ADM-008 |

---

### BR-ADM-004: Admins Can Audit Staff Actions

| Field | Value |
|---|---|
| Category | Admin Governance |
| Priority | Phase 2 |
| Rule | Admins can audit Staff moderation actions, including teacher approval decisions, material decisions, hidden content, and escalated reports. |
| Rationale | Auditability improves accountability and fairness. |
| Applies To | Admin, Staff |
| Related User Requirements | UR-ADM-006 |

---

### BR-ADM-005: Admins Can Override Staff Decisions

| Field | Value |
|---|---|
| Category | Admin Governance |
| Priority | Phase 2 |
| Rule | Admins can override Staff decisions when necessary. |
| Rationale | Admins hold final platform governance authority. |
| Applies To | Admin, Staff |
| Related User Requirements | UR-ADM-007 |

---

### BR-ADM-006: Admins Can Handle Serious Policy Violations

| Field | Value |
|---|---|
| Category | Admin Governance |
| Priority | Future |
| Rule | Admins can handle serious policy violations, abuse cases, disputes, or high-risk moderation issues escalated by Staff. |
| Rationale | Some issues require final decision-making authority. |
| Applies To | Admin |
| Related User Requirements | UR-ADM-009 |

---

## 8. Study Material Rules

### BR-MAT-001: Materials Must Belong to a Subject

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | MVP |
| Rule | Every study material must belong to at least one subject or platform-level learning category. |
| Rationale | Subject classification is required for browsing, search, and recommendations. |
| Applies To | Teacher, Staff, Admin, Student |
| Related User Requirements | UR-TCH-004, UR-STU-002 |

---

### BR-MAT-002: Materials Must Have an Owner

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | MVP |
| Rule | Every study material must have an owner, usually the Teacher who uploaded it. |
| Rationale | Ownership is required for accountability, editing, and moderation. |
| Applies To | Teacher |
| Related User Requirements | UR-TCH-003 |

---

### BR-MAT-003: Uploaded Materials Must Have a Moderation Status

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | MVP |
| Rule | Uploaded materials must have a moderation status such as Draft, Pending Review, Approved, Rejected, Needs Revision, Hidden, or Archived. |
| Rationale | Content visibility depends on moderation status. |
| Applies To | Teacher, Staff, Student |
| Related User Requirements | UR-TCH-003, UR-STF-005 |

---

### BR-MAT-004: Student Access Requires Approved and Visible Materials

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | MVP |
| Rule | Students can only access materials that are approved and visible. |
| Rationale | Students should not access unreviewed, rejected, hidden, or archived materials. |
| Applies To | Student, Teacher, Staff |
| Related User Requirements | UR-STU-002, UR-STU-004, UR-STF-004 |

---

### BR-MAT-005: Teacher-Uploaded Materials Require Staff Review

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | MVP |
| Rule | Teacher-uploaded materials must be reviewed by Staff before becoming publicly visible to Students. |
| Rationale | Staff moderation helps ensure content quality and trust. |
| Applies To | Teacher, Staff, Student |
| Related User Requirements | UR-TCH-003, UR-STF-004 |

---

### BR-MAT-006: Teachers Can Edit Draft or Rejected Materials

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | MVP |
| Rule | Teachers can edit their own Draft, Rejected, or Needs Revision materials. |
| Rationale | Teachers need to improve materials before resubmitting them for review. |
| Applies To | Teacher |
| Related User Requirements | UR-TCH-009 |

---

### BR-MAT-007: Approved Materials May Require Re-Review After Major Edits

| Field | Value |
|---|---|
| Category | Study Material |
| Priority | Phase 2 |
| Rule | Approved materials may require Staff re-review after major edits. |
| Rationale | Major changes may affect content quality or correctness. |
| Applies To | Teacher, Staff |
| Related User Requirements | UR-TCH-009, UR-STF-005 |

---

## 9. AI-Generated Content Rules

### BR-AI-001: AI-Generated Content Must Be Identifiable

| Field | Value |
|---|---|
| Category | AI-Generated Content |
| Priority | MVP |
| Rule | AI-generated or AI-assisted educational content should be clearly identifiable. |
| Rationale | Users should understand when content was generated or assisted by AI. |
| Applies To | Student, Teacher, Staff |
| Related User Requirements | UR-GEN-006 |

---

### BR-AI-002: AI-Generated Quizzes and Flashcards Require Teacher Review

| Field | Value |
|---|---|
| Category | AI-Generated Content |
| Priority | MVP |
| Rule | AI-generated quizzes and flashcards must be reviewed and edited by a Teacher before being published to Students. |
| Rationale | AI-generated educational content may contain errors and should not be published without human review. |
| Applies To | Teacher, Student |
| Related User Requirements | UR-TCH-007 |

---

### BR-AI-003: AI-Generated Content May Require Staff Approval Before Public Release

| Field | Value |
|---|---|
| Category | AI-Generated Content |
| Priority | MVP |
| Rule | AI-generated learning content may require Staff approval before becoming publicly visible, depending on platform moderation policy. |
| Rationale | Some AI-generated content may affect learning quality and should be moderated. |
| Applies To | Teacher, Staff, Student |
| Related User Requirements | UR-STF-005, UR-TCH-008 |

---

### BR-AI-004: AI Explanations Are Learning Support, Not Guaranteed Truth

| Field | Value |
|---|---|
| Category | AI-Generated Content |
| Priority | Phase 2 |
| Rule | AI-generated explanations, answers, or recommendations should be treated as learning support, not as guaranteed authoritative truth. |
| Rationale | AI may produce incorrect or incomplete educational explanations. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-STU-009, UR-GEN-006 |

---

### BR-AI-005: Users Should Be Able to Report AI Mistakes

| Field | Value |
|---|---|
| Category | AI-Generated Content |
| Priority | Phase 2 |
| Rule | Users should be able to report incorrect AI-generated explanations, answers, quizzes, flashcards, or recommendations. |
| Rationale | User reporting helps improve platform quality and AI safety. |
| Applies To | Student, Teacher, Staff |
| Related User Requirements | UR-GEN-007, UR-STF-006 |

---

### BR-AI-006: AI Must Not Bypass Moderation

| Field | Value |
|---|---|
| Category | AI-Generated Content |
| Priority | MVP |
| Rule | AI-generated content must not bypass Teacher review or Staff moderation rules when those rules apply. |
| Rationale | AI should support educational workflows, not override governance. |
| Applies To | AI System, Teacher, Staff |
| Related User Requirements | UR-TCH-007, UR-STF-005 |

---

## 10. Mock Exams and HIPZI Exams Rules

### BR-MOCK-001: Mock Exam Availability

| Field | Value |
|---|---|
| Category | Mock Exams |
| Priority | MVP |
| Rule | Mock exams must be explicitly published to be visible in the Exam Room. |
| Rationale | Students should only take ready and approved mock exams. |
| Applies To | Student, Staff |
| Related User Requirements | UR-STU-005 |

---

### BR-MOCK-002: Mock Exam Evaluation

| Field | Value |
|---|---|
| Category | Mock Exams |
| Priority | MVP |
| Rule | Objective questions (Trắc nghiệm, Flashcard) are automatically scored. Essay questions (Tự luận) may require manual grading by Teachers. |
| Rationale | Automated scoring handles standard questions, while essays need human review. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-STU-005, UR-TCH-016 |

---

### BR-MOCK-003: Attempt Storage

| Field | Value |
|---|---|
| Category | Mock Exams |
| Priority | MVP |
| Rule | All Mock Exam attempts must be stored for history and scoring. |
| Rationale | It is important to track student testing history. |
| Applies To | Student |
| Related User Requirements | UR-STU-008 |

---

### BR-HIPZI-001: HIPZI Exams Creation and Management

| Field | Value |
|---|---|
| Category | HIPZI Exams |
| Priority | MVP |
| Rule | HIPZI Exams can only be created and managed by Staff or Admins. |
| Rationale | HIPZI Exams are official, system-wide events requiring centralized governance. |
| Applies To | Staff, Admin |
| Related User Requirements | UR-ADM-008 |

---

### BR-HIPZI-002: HIPZI Exam Rewards

| Field | Value |
|---|---|
| Category | HIPZI Exams |
| Priority | MVP |
| Rule | Students who complete a HIPZI Exam may receive bonus XP (Experience Points) added to their profile level, based on the exam's configuration. |
| Rationale | Rewards encourage student participation and gamify the learning experience. |
| Applies To | Student, Staff, Admin |
| Related User Requirements | UR-STU-008 |

---

## 11. Personalization and Recommendation Rules

### BR-PER-001: Personalization Requires Student Context

| Field | Value |
|---|---|
| Category | Personalization and Recommendation |
| Priority | Phase 2 |
| Rule | Personalized learning analysis must be based on student-provided input, learning history, quiz performance, selected goals, or available platform data. |
| Rationale | AI needs relevant context to generate useful recommendations. |
| Applies To | Student, AI System |
| Related User Requirements | UR-STU-011, UR-STU-012 |

---

### BR-PER-002: Learning Roadmaps Are Recommendations

| Field | Value |
|---|---|
| Category | Personalization and Recommendation |
| Priority | Phase 2 |
| Rule | AI-generated learning roadmaps should be presented as recommendations, not mandatory academic requirements. |
| Rationale | Students should understand that AI roadmaps are guidance and may need adjustment. |
| Applies To | Student, AI System |
| Related User Requirements | UR-STU-013 |

---

### BR-PER-003: Recommended Materials Must Be Approved and Visible

| Field | Value |
|---|---|
| Category | Personalization and Recommendation |
| Priority | Phase 2 |
| Rule | AI-recommended study materials must be approved and visible to the Student. |
| Rationale | AI must not recommend hidden, rejected, archived, or unreviewed materials. |
| Applies To | Student, AI System |
| Related User Requirements | UR-STU-014 |

---

### BR-PER-004: Recommended Teachers Must Be Verified and Active

| Field | Value |
|---|---|
| Category | Personalization and Recommendation |
| Priority | Phase 2 |
| Rule | AI-recommended teachers must be verified, active, and eligible to be shown to Students. |
| Rationale | AI should only recommend trusted and available teachers. |
| Applies To | Student, Teacher, AI System |
| Related User Requirements | UR-STU-015 |

---

### BR-PER-005: Insufficient Data Requires Fallback Behavior

| Field | Value |
|---|---|
| Category | Personalization and Recommendation |
| Priority | Phase 2 |
| Rule | If there is insufficient student data, the system should ask for more input or provide a general learning roadmap. |
| Rationale | AI should avoid overconfident recommendations when data is limited. |
| Applies To | Student, AI System |
| Related User Requirements | UR-STU-011, UR-STU-012, UR-STU-013 |

---

### BR-PER-006: Students Can Update Learning Preferences

| Field | Value |
|---|---|
| Category | Personalization and Recommendation |
| Priority | Phase 2 |
| Rule | Students should be able to update learning goals, weak areas, available study time, and learning preferences. |
| Rationale | Learning needs change over time and personalization should adapt. |
| Applies To | Student |
| Related User Requirements | UR-STU-011 |

---

## 12. Class, Course, and Enrollment Rules

### BR-CLS-001: Only Approved Teachers Can Create Classes

| Field | Value |
|---|---|
| Category | Class, Course, and Enrollment |
| Priority | Phase 2 |
| Rule | Only approved Teachers can create classes. |
| Rationale | Class creation should be restricted to verified educators. |
| Applies To | Teacher, Student |
| Related User Requirements | UR-TCH-010 |

---

### BR-CLS-002: Students May Need Approval to Join Teacher-Managed Classes

| Field | Value |
|---|---|
| Category | Class, Course, and Enrollment |
| Priority | Phase 2 |
| Rule | Students must request enrollment before joining teacher-managed classes unless the class is configured as open enrollment. |
| Rationale | Teachers may need to control class size and student suitability. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-STU-017, UR-TCH-011 |

---

### BR-CLS-003: Teachers Can Approve or Reject Class Enrollment Requests

| Field | Value |
|---|---|
| Category | Class, Course, and Enrollment |
| Priority | Phase 2 |
| Rule | Teachers can approve or reject student enrollment requests for their classes. |
| Rationale | Teachers manage class membership and learning participation. |
| Applies To | Teacher, Student |
| Related User Requirements | UR-TCH-011 |

---

### BR-CLS-004: Courses Should Follow a Structured Hierarchy

| Field | Value |
|---|---|
| Category | Class, Course, and Enrollment |
| Priority | MVP |
| Rule | Courses should follow a structured hierarchy: Course → Module → Lesson. |
| Rationale | Structured courses support organized learning. |
| Applies To | Teacher, Student |
| Related User Requirements | UR-TCH-015 |

---

### BR-CLS-005: Courses May Require Staff Review Before Public Listing

| Field | Value |
|---|---|
| Category | Class, Course, and Enrollment |
| Priority | MVP |
| Rule | Courses may require Staff review before being publicly listed. |
| Rationale | Course-level moderation helps maintain quality. |
| Applies To | Teacher, Staff |
| Related User Requirements | UR-TCH-015, UR-STF-005 |

---

## 13. Parent Access Rules

### BR-PAR-001: Parent Features Are Future Scope

| Field | Value |
|---|---|
| Category | Parent Access |
| Priority | Future |
| Rule | Parent-focused features should be developed after student, teacher, staff, and admin workflows are stable. |
| Rationale | Parent workflows depend on reliable student progress tracking and permissions. |
| Applies To | Parent, Student |
| Related User Requirements | UR-PAR-001, UR-PAR-003 |

---

### BR-PAR-002: Parent Access to Student Data Requires Verified Relationship

| Field | Value |
|---|---|
| Category | Parent Access |
| Priority | Future |
| Rule | Parent access to student learning data requires a verified parent-student relationship or appropriate authorization. |
| Rationale | Student learning data is private and should not be exposed without permission. |
| Applies To | Parent, Student |
| Related User Requirements | UR-PAR-003, UR-PAR-004 |

---

## 14. Review and Rating Rules

### BR-REV-001: Reviews Require Valid Interaction

| Field | Value |
|---|---|
| Category | Review and Rating |
| Priority | Future |
| Rule | Users can only review materials, teachers, classes, or courses they have interacted with. |
| Rationale | Reviews should reflect real usage and learning experience. |
| Applies To | Student, Parent, Teacher |
| Related User Requirements | UR-STU-018, UR-PAR-002 |

---

### BR-REV-002: Teachers Cannot Review Their Own Content

| Field | Value |
|---|---|
| Category | Review and Rating |
| Priority | Future |
| Rule | Teachers cannot review their own materials, classes, or courses. |
| Rationale | Self-review would reduce trust in rating systems. |
| Applies To | Teacher |
| Related User Requirements | UR-GEN-005 |

---

### BR-REV-003: Reviews May Be Moderated

| Field | Value |
|---|---|
| Category | Review and Rating |
| Priority | Future |
| Rule | Reviews may be hidden or removed if they violate platform policy. |
| Rationale | Review moderation protects platform quality and user trust. |
| Applies To | Staff, Admin |
| Related User Requirements | UR-STF-006, UR-ADM-009 |

---

## 15. Exam and Assessment Rules

### BR-EXAM-001: Formal Exams Must Be Distinguished from Practice Quizzes

| Field | Value |
|---|---|
| Category | Exam and Assessment |
| Priority | Future |
| Rule | Formal exams must be clearly distinguished from practice quizzes. |
| Rationale | Practice activities and formal assessments have different rules and consequences. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-STU-019, UR-TCH-016 |

---

### BR-EXAM-002: Exams May Have Attempt and Time Limits

| Field | Value |
|---|---|
| Category | Exam and Assessment |
| Priority | Future |
| Rule | Formal exams may have time limits, attempt limits, and availability windows. |
| Rationale | Exams require stricter control than practice quizzes. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-STU-019, UR-TCH-016 |

---

### BR-EXAM-003: Objective Exam Questions May Be Automatically Graded

| Field | Value |
|---|---|
| Category | Exam and Assessment |
| Priority | Future |
| Rule | Objective exam questions may be automatically graded if they have clear correct answers or evaluation rules. |
| Rationale | Automatic grading is reliable for structured objective questions. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-TCH-016 |

---

### BR-EXAM-004: AI-Assisted Grading Requires Teacher Review

| Field | Value |
|---|---|
| Category | Exam and Assessment |
| Priority | Future |
| Rule | AI-assisted grading for written responses should require Teacher review before finalization. |
| Rationale | AI grading may be inaccurate and should not become final without human oversight. |
| Applies To | Teacher, Student, AI System |
| Related User Requirements | UR-TCH-014, UR-TCH-016 |

---

### BR-EXAM-005: Students Must Not Access Exam Answers Before Submission

| Field | Value |
|---|---|
| Category | Exam and Assessment |
| Priority | Future |
| Rule | Students must not access correct exam answers before submitting the exam. |
| Rationale | Early answer access would compromise assessment integrity. |
| Applies To | Student |
| Related User Requirements | UR-STU-019 |

---

## 16. Wallet and Monetization Rules

### BR-WLT-001: Internal Wallet Balance

| Field | Value |
|---|---|
| Category | Wallet and Monetization |
| Priority | MVP |
| Rule | Students and Teachers have an internal wallet balance to buy or sell courses. |
| Rationale | A wallet system allows internal transactions without complex external payment gateways initially. |
| Applies To | Student, Teacher |
| Related User Requirements | UR-STU-018 |

---

### BR-WLT-002: Course Purchase Deducts Wallet

| Field | Value |
|---|---|
| Category | Wallet and Monetization |
| Priority | MVP |
| Rule | Purchasing a course deducts the specified amount from the Student's wallet balance. If balance is insufficient, purchase is denied. |
| Rationale | Ensures valid transaction logic. |
| Applies To | Student |
| Related User Requirements | UR-STU-018 |

---

## 17. Business State Models

This section defines important business states that future functional requirements and database design should support.

### 17.1 Teacher Application Status

Teacher applications may follow this lifecycle:

> Draft → Submitted → Approved / Rejected → Suspended

### 17.2 Material Moderation Status

Learning materials may follow this lifecycle:

> Draft → Pending Review → Approved / Rejected / Needs Revision → Hidden / Archived

### 17.3 AI-Generated Content Status

AI-generated learning content may follow this lifecycle:

> Generated Draft → Teacher Reviewed → Submitted for Review → Approved / Rejected → Published / Discarded

### 17.4 Class Enrollment Status

Class enrollment may follow this lifecycle:

> Requested → Approved / Rejected → Active → Removed

### 17.5 Quiz Attempt Status

Quiz attempts may follow this lifecycle:

> Started → Submitted → Scored → Reviewed

---

## 18. MVP Business Rule Summary

The MVP must enforce the following rule groups:

- Role-based access.
- Teacher and Staff role separation.
- Admin-controlled multi-role assignment.
- Staff-based teacher application review.
- Staff-based material moderation.
- Teacher review of AI-generated content.
- Student access only to approved and visible materials.
- Quiz and flashcard practice linked to learning context.
- Practice attempts stored for learning history.
- Admin governance over roles, Staff permissions, audit, and override authority.

---

## 19. Notes for Future Refinement

These business rules should be refined when writing:

- `03-functional-requirements.md`
- `04-user-flow.md`
- `05-acceptance-criteria.md`
- `06-edge-cases.md`
- `07-system-architecture.md`
- `08-database-design.md`
- `09-api-design.md`
- `12-testing-strategy.md`

Each future functional requirement should reference one or more business rules from this document.

Example traceability:

> UR-STU-013 → BR-PER-002 → FR-AI-ROADMAP-001 → AC-AI-ROADMAP-001

The role separation between Teacher, Staff, and Admin should remain a core governance principle throughout the product.