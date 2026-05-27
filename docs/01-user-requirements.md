# HIPZI User Requirements

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | User Requirements Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Document | 00-prd.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Designer, Researcher |
| Language | English |

---

## 1. Purpose

This document defines the user requirements for HIPZI from the perspective of each major user group.

The purpose of this document is to clarify what each user group needs from the platform before translating those needs into functional requirements, business rules, system requirements, user flows, acceptance criteria, edge cases, and implementation tasks.

This document focuses on user needs, goals, expectations, and learning workflows. It does not define technical implementation details, database design, API contracts, or system architecture.

---

## 2. Requirement Classification

Each requirement uses a stable requirement ID so that it can be referenced by future documents such as functional requirements, business rules, acceptance criteria, edge cases, testing strategy, and implementation tasks.

### 2.1 Requirement ID Prefixes

| Prefix | User Group |
|---|---|
| UR-STU | Student |
| UR-PAR | Parent |
| UR-TCH | Teacher / Lecturer |
| UR-STF | Staff |
| UR-ADM | Admin |
| UR-GEN | General / Cross-role |

### 2.2 Priority Levels

| Priority | Meaning |
|---|---|
| MVP | Required for the first usable version |
| Phase 2 | Important after the MVP is validated |
| Future | Long-term or advanced feature |

---

## 3. User Groups

HIPZI supports the following primary user groups:

| User Group | Description |
|---|---|
| Student | Learners who use HIPZI to find materials, practice knowledge, receive AI learning support, and connect with teachers |
| Parent | Users who help students find suitable teachers, courses, or learning resources |
| Teacher / Lecturer | Educators who upload materials, create learning content, manage classes, and support students |
| Staff | Platform operators who review teacher applications, moderate uploaded materials, handle reports, and support day-to-day content quality control |
| Admin | Platform governors who manage roles, assign staff permissions, configure policies, audit moderation actions, and override decisions when necessary |

---

## 4. Student Requirements

Students are the primary users of HIPZI. Their main goals are to find suitable learning materials, practice effectively, understand difficult topics, receive personalized guidance, and connect with suitable teachers or classes.

---

### UR-STU-001: Student Account Access

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to register, log in, and access the platform using a student account. |
| Rationale | Students need an account to save learning progress, practice history, preferences, and personalized recommendations. |
| Related PRD Section | 4.1 Students, 8.2.1 User Authentication and Role Management |

---

### UR-STU-002: Browse Study Materials by Subject

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to browse approved study materials by subject. |
| Rationale | Students often start learning by selecting a subject they want to study or review. |
| Related PRD Section | 8.2.2 Subject Management, 10.1 Student Learning Journey |

---

### UR-STU-003: Search for Relevant Study Materials

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to search for study materials by keyword, subject, topic, or learning goal. |
| Rationale | Students may not know exactly where a material is located and need a fast way to find relevant content. |
| Related PRD Section | 4.1 Students, 11.4 Smart Search |

---

### UR-STU-004: View Study Material Details

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to open and view study material details before learning or practicing. |
| Rationale | Students need to understand the content, subject, difficulty, teacher, and learning format before using a material. |
| Related PRD Section | 8.2.5 Material Browsing, 10.1 Student Learning Journey |

---

### UR-STU-005: Practice with Quizzes

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to practice knowledge using quizzes generated from study materials. |
| Rationale | Practice questions help students test understanding and reinforce learning. |
| Related PRD Section | 8.2.7 Student Practice |

---

### UR-STU-006: Practice with Flashcards

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to practice using flashcards created from study materials. |
| Rationale | Flashcards help students memorize concepts, definitions, formulas, vocabulary, and key ideas. |
| Related PRD Section | 8.2.6 AI Quiz and Flashcard Generation |

---

### UR-STU-007: View Quiz Results and Basic Feedback

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need to view quiz results, correct answers, and basic feedback after completing a quiz. |
| Rationale | Students need immediate feedback to understand mistakes and improve learning. |
| Related PRD Section | 8.2.7 Student Practice, 10.1 Student Learning Journey |

---

### UR-STU-008: Save Basic Learning History

| Field | Value |
|---|---|
| User Group | Student |
| Priority | MVP |
| Description | Students need the platform to save basic learning history, including completed materials, quiz attempts, and practice activity. |
| Rationale | Learning history is required for progress tracking, recommendations, and personalized learning support. |
| Related PRD Section | 11.3 Progress Tracking |

---

### UR-STU-009: Receive AI Explanation Support

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need to ask AI to explain difficult concepts, questions, or document sections. |
| Rationale | Students often need immediate explanations when studying independently. |
| Related PRD Section | 6.3 AI-Powered Learning Assistance, 11.6 AI Explanation Assistant |

---

### UR-STU-010: Request Different Explanation Styles from AI

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need AI to explain content in different styles such as simple explanation, step-by-step explanation, short summary, real-world example, or advanced explanation. |
| Rationale | Different students learn in different ways and need flexible explanation styles. |
| Related PRD Section | 11.6 AI Explanation Assistant |

---

### UR-STU-011: Provide Learning Input for AI Personalization

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need to provide input to AI about their learning goals, current level, weak areas, preferred subjects, available study time, and learning preferences. |
| Rationale | AI needs user-provided context to analyze learning needs and personalize the study experience. |
| Related PRD Section | 11.1 Personalized Learning Path, 11.2 Study Plan and Timetable |

---

### UR-STU-012: Receive AI Analysis of Learning Needs

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need AI to analyze their input and identify what subjects or topics they should study, what areas they are weak in, and what learning goals should be prioritized. |
| Rationale | Many students do not know what they should study first or where their weaknesses are. AI can help diagnose learning needs from user input and learning history. |
| Related PRD Section | 11.1 Personalized Learning Path, 11.3 Progress Tracking |

---

### UR-STU-013: Receive Personalized Learning Roadmap

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need AI to generate a personalized learning roadmap based on their goals, weak areas, available time, and current learning level. |
| Rationale | A structured roadmap helps students know what to study, in what order, and how to make progress over time. |
| Related PRD Section | 11.1 Personalized Learning Path |

---

### UR-STU-014: Receive Recommended Study Materials

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need AI to recommend suitable study materials based on their learning roadmap, weak areas, subject interests, and current level. |
| Rationale | Personalized material recommendations reduce the time students spend searching and increase the relevance of learning content. |
| Related PRD Section | 6.3 AI-Powered Learning Assistance, 11.1 Personalized Learning Path |

---

### UR-STU-015: Receive Recommended Teachers

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need AI to recommend suitable teachers based on subject, learning needs, weak areas, schedule, level, and preferred learning style. |
| Rationale | Students often need guidance from teachers who match their current learning situation and goals. |
| Related PRD Section | 4.1 Students, 5 Product Positioning |

---

### UR-STU-016: Track Learning Progress

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need to track learning progress, including studied materials, quiz results, accuracy rate, weak topics, and learning streaks. |
| Rationale | Progress tracking helps students understand improvement and stay motivated. |
| Related PRD Section | 11.3 Progress Tracking |

---

### UR-STU-017: Register for Classes or Courses

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Phase 2 |
| Description | Students need to register for classes or courses provided by teachers. |
| Rationale | HIPZI aims to connect students with teacher-led learning experiences beyond self-study materials. |
| Related PRD Section | 7.2 Mid-Term Goals, 10.1 Student Learning Journey |

---

### UR-STU-018: Join Study Groups or Discussions

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Future |
| Description | Students need to participate in study groups, class discussions, or subject-based Q&A communities. |
| Rationale | Community learning can improve engagement and help students learn from peers and teachers. |
| Related PRD Section | 11.9 Community and Q&A |

---

### UR-STU-019: Participate in Online Exams

| Field | Value |
|---|---|
| User Group | Student |
| Priority | Future |
| Description | Students need to participate in online exams organized by teachers or the platform. |
| Rationale | Online exams can support assessment and structured learning evaluation in later phases. |
| Related PRD Section | 11.14 Online Exams |

---

## 5. Teacher / Lecturer Requirements

Teachers are responsible for contributing educational content, creating learning experiences, managing students, and supporting learners through materials, quizzes, classes, assignments, and future AI-assisted teaching tools.

Teachers are separate from Staff by default. Trusted teachers with strong performance, verified expertise, or high-quality contribution history may be assigned an additional Staff role by an Admin.

---

### UR-TCH-001: Teacher Account Registration

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to register an account and apply to become verified educators on HIPZI. |
| Rationale | HIPZI must identify and verify teachers before allowing them to publish educational content. |
| Related PRD Section | 4.3 Teachers / Lecturers, 8.2.3 Teacher Registration |

---

### UR-TCH-002: Submit Teacher Profile for Review

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to submit profile information for Staff review, such as teaching subjects, experience, qualifications, and introduction. |
| Rationale | Staff review helps maintain trust and educational quality on the platform. |
| Related PRD Section | 8.2.3 Teacher Registration, 10.2 Teacher Content Creation Journey |

---

### UR-TCH-003: Upload Study Materials for Review

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Approved teachers need to upload study materials for Staff review. |
| Rationale | Teacher-uploaded materials are a core source of learning content, but materials must be reviewed before becoming publicly visible to students. |
| Related PRD Section | 8.2.4 Material Upload, 8.2.8 Staff Moderation |

---

### UR-TCH-004: Categorize Uploaded Materials

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to categorize uploaded materials by subject, topic, grade, difficulty, or learning format. |
| Rationale | Categorization helps students find relevant materials and supports future AI recommendations. |
| Related PRD Section | 6.1 Study Material Repository, 8.2.2 Subject Management |

---

### UR-TCH-005: Generate Quizzes from Materials Using AI

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to use AI to generate quizzes from uploaded learning materials. |
| Rationale | AI quiz generation helps teachers save time and transform static materials into interactive practice. |
| Related PRD Section | 8.2.6 AI Quiz and Flashcard Generation |

---

### UR-TCH-006: Generate Flashcards from Materials Using AI

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to use AI to generate flashcards from uploaded learning materials. |
| Rationale | Flashcards help learners memorize key concepts and allow teachers to create practice resources efficiently. |
| Related PRD Section | 8.2.6 AI Quiz and Flashcard Generation |

---

### UR-TCH-007: Review and Edit AI-Generated Content

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to review and edit AI-generated quizzes, flashcards, answers, and explanations before publishing. |
| Rationale | AI-generated educational content may contain mistakes and should be reviewed by teachers before students use it. |
| Related PRD Section | 8.2.6 AI Quiz and Flashcard Generation, 14.3 AI Accuracy |

---

### UR-TCH-008: Submit Learning Content for Publication

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | MVP |
| Description | Teachers need to submit learning content for review and publish content only after it is approved according to platform moderation policy. |
| Rationale | Learning content should meet platform quality standards before becoming visible to students. |
| Related PRD Section | 8.2.8 Staff Moderation, 10.2 Teacher Content Creation Journey |

---

### UR-TCH-009: Manage Uploaded Materials

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Phase 2 |
| Description | Teachers need to update, archive, or manage their uploaded materials. |
| Rationale | Learning materials may need corrections, improvements, versioning, or removal over time. |
| Related PRD Section | 7.2 Mid-Term Goals |

---

### UR-TCH-010: Create and Manage Classes

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Phase 2 |
| Description | Teachers need to create and manage classes for students. |
| Rationale | Class management allows HIPZI to support teacher-led learning beyond standalone materials. |
| Related PRD Section | 7.2 Mid-Term Goals, 15.2 Phase 2 |

---

### UR-TCH-011: Approve Students into Classes

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Phase 2 |
| Description | Teachers need to approve or reject student enrollment requests for their classes. |
| Rationale | Teachers may need to control class size, student suitability, and enrollment quality. |
| Related PRD Section | 7.2 Mid-Term Goals |

---

### UR-TCH-012: View Student Learning Progress

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Phase 2 |
| Description | Teachers need to view student progress, quiz performance, weak topics, and learning activity. |
| Rationale | Progress visibility helps teachers support students more effectively. |
| Related PRD Section | 11.3 Progress Tracking, 11.7 Teacher Dashboard |

---

### UR-TCH-013: Create Assignments

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Future |
| Description | Teachers need to create assignments for students or classes. |
| Rationale | Assignments support structured learning and teacher-led evaluation. |
| Related PRD Section | 11.12 Assignment Management |

---

### UR-TCH-014: Use AI Teaching Assistant

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Future |
| Description | Teachers need an AI assistant to summarize documents, generate review questions, create exercises, create exam questions, analyze common mistakes, and suggest teaching improvements. |
| Rationale | AI can reduce repetitive teaching workload and help teachers improve learning content. |
| Related PRD Section | 11.13 AI Teaching Assistant |

---

### UR-TCH-015: Create Structured Courses

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Future |
| Description | Teachers need to create structured courses using modules, lessons, materials, quizzes, and assignments. |
| Rationale | Structured courses allow HIPZI to evolve from a material platform into a full learning management system. |
| Related PRD Section | 11.8 Course Builder |

---

### UR-TCH-016: Organize Online Exams

| Field | Value |
|---|---|
| User Group | Teacher / Lecturer |
| Priority | Future |
| Description | Teachers need to create and manage online exams for students. |
| Rationale | Online exams can support formal assessment in later phases of the platform. |
| Related PRD Section | 11.14 Online Exams |

---

## 6. Staff Requirements

Staff members are responsible for day-to-day platform operations, teacher application review, content moderation, reported content handling, and platform quality control.

Staff are separate from teachers by default. A user may hold both Teacher and Staff roles only when explicitly assigned by an Admin. If a user has both roles, they must not review or approve their own teacher application, materials, courses, quizzes, exams, or AI-generated learning content.

---

### UR-STF-001: Staff Moderation Dashboard Access

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | MVP |
| Description | Staff need secure access to a staff moderation dashboard. |
| Rationale | Staff need a dedicated interface to review teacher applications, uploaded materials, and reported content. |
| Related PRD Section | 4.4 Staff, 8.2.8 Staff Moderation |

---

### UR-STF-002: Review Teacher Applications

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | MVP |
| Description | Staff need to review teacher applications submitted by users who want to become verified educators. |
| Rationale | Teacher verification helps maintain educational quality and platform trust. |
| Related PRD Section | 8.2.3 Teacher Registration, 10.3 Staff Moderation Journey |

---

### UR-STF-003: Approve or Reject Teacher Applications

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | MVP |
| Description | Staff need to approve or reject teacher applications according to platform policy. |
| Rationale | Only qualified or accepted teachers should be allowed to upload and publish educational content. |
| Related PRD Section | 8.2.3 Teacher Registration, 8.2.8 Staff Moderation |

---

### UR-STF-004: Review Uploaded Learning Materials

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | MVP |
| Description | Staff need to review learning materials uploaded by teachers before they become publicly visible to students. |
| Rationale | Material review helps ensure content quality, relevance, and platform trust. |
| Related PRD Section | 8.2.4 Material Upload, 8.2.8 Staff Moderation |

---

### UR-STF-005: Moderate Learning Materials

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | MVP |
| Description | Staff need to approve, reject, request revision, hide, or archive learning materials. |
| Rationale | Staff need moderation actions to manage content quality and visibility. |
| Related PRD Section | 8.2.8 Staff Moderation |

---

### UR-STF-006: Review Reported Content

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | Phase 2 |
| Description | Staff need to review reported materials, AI-generated content, teacher profiles, courses, or community content. |
| Rationale | Reporting workflows help maintain platform safety, accuracy, and trust. |
| Related PRD Section | 4.4 Staff, 10.3 Staff Moderation Journey |

---

### UR-STF-007: Monitor Teacher and Material Quality Indicators

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | Phase 2 |
| Description | Staff need to view teacher quality indicators, material quality indicators, moderation history, and reported issue trends. |
| Rationale | Quality indicators help Staff make better review and moderation decisions. |
| Related PRD Section | 13.4 Platform Quality Metrics |

---

### UR-STF-008: Escalate Serious Issues to Admins

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | Phase 2 |
| Description | Staff need to escalate serious policy violations, disputes, or high-risk quality issues to Admins. |
| Rationale | Admins should handle high-impact decisions, overrides, and governance-level issues. |
| Related PRD Section | 10.3 Staff Moderation Journey, 10.4 Admin Governance Journey |

---

### UR-STF-009: Avoid Reviewing Own Content

| Field | Value |
|---|---|
| User Group | Staff |
| Priority | MVP |
| Description | Staff who also have a Teacher role must not review or approve their own teacher application, uploaded materials, courses, quizzes, exams, or AI-generated learning content. |
| Rationale | This prevents conflict of interest and preserves fairness in platform moderation. |
| Related PRD Section | 4.4 Staff |

---

## 7. Admin Requirements

Admins are responsible for high-level platform governance, role assignment, staff permission management, policy configuration, audit, override authority, and serious issue handling.

---

### UR-ADM-001: Admin Dashboard Access

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | MVP |
| Description | Admins need secure access to an admin governance dashboard. |
| Rationale | Admins need a dedicated interface to manage roles, permissions, policies, audit logs, and platform-level governance. |
| Related PRD Section | 4.5 Admins, 8.2.9 Admin Governance |

---

### UR-ADM-002: Manage User Accounts

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | MVP |
| Description | Admins need to view and manage user accounts across different roles. |
| Rationale | User management is required for platform governance and operational control. |
| Related PRD Section | 4.5 Admins |

---

### UR-ADM-003: Assign or Revoke Staff Permissions

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | MVP |
| Description | Admins need to assign or revoke Staff permissions for eligible users. |
| Rationale | Staff permissions should only be granted through explicit Admin assignment. |
| Related PRD Section | 4.4 Staff, 4.5 Admins, 8.2.9 Admin Governance |

---

### UR-ADM-004: Assign Additional Staff Role to Trusted Teachers

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | Phase 2 |
| Description | Admins need to assign an additional Staff role to trusted teachers with strong performance, verified expertise, or a history of high-quality contributions. |
| Rationale | This allows HIPZI to scale moderation capacity while maintaining quality control. |
| Related PRD Section | 4.3 Teachers / Lecturers, 4.4 Staff |

---

### UR-ADM-005: Configure Platform Policies

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | Phase 2 |
| Description | Admins need to configure platform policies related to teacher verification, material moderation, content visibility, AI-generated content, and role permissions. |
| Rationale | Platform policies define how Staff and users should operate within HIPZI. |
| Related PRD Section | 4.5 Admins |

---

### UR-ADM-006: Audit Staff Moderation Actions

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | Phase 2 |
| Description | Admins need to review Staff moderation actions, including teacher approvals, material approvals, rejected content, hidden materials, and escalated reports. |
| Rationale | Auditability helps ensure accountability, fairness, and quality in moderation workflows. |
| Related PRD Section | 8.2.9 Admin Governance, 10.4 Admin Governance Journey |

---

### UR-ADM-007: Override Staff Decisions

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | Phase 2 |
| Description | Admins need to override Staff decisions when necessary, including teacher approval decisions, material moderation decisions, or serious policy cases. |
| Rationale | Admins hold final authority for platform governance and high-impact decisions. |
| Related PRD Section | 4.5 Admins, 8.2.9 Admin Governance |

---

### UR-ADM-008: Manage Subjects and Platform Categories

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | MVP |
| Description | Admins need to create, update, and manage subjects and platform-level learning categories. |
| Rationale | Study materials must be organized by subject so that students can browse and search effectively. |
| Related PRD Section | 8.2.2 Subject Management |

---

### UR-ADM-009: Handle Serious Policy Violations or Disputes

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | Future |
| Description | Admins need to handle serious policy violations, disputes, abuse cases, or high-risk moderation issues escalated by Staff. |
| Rationale | Some platform issues require final governance authority and cannot be handled only by Staff. |
| Related PRD Section | 4.5 Admins, 10.4 Admin Governance Journey |

---

### UR-ADM-010: View Platform Metrics

| Field | Value |
|---|---|
| User Group | Admin |
| Priority | Future |
| Description | Admins need to view platform metrics such as active users, uploaded materials, approved teachers, active Staff members, quiz activity, ratings, reports, and moderation performance. |
| Rationale | Platform metrics help Admins evaluate growth, content quality, learning engagement, moderation efficiency, and operational risks. |
| Related PRD Section | 13. Success Metrics |

---

## 8. Parent Requirements

Parents are secondary users of HIPZI. Parent-focused features should be developed after student, teacher, staff, and admin workflows are stable.

---

### UR-PAR-001: Browse Learning Resources for Children

| Field | Value |
|---|---|
| User Group | Parent |
| Priority | Future |
| Description | Parents need to browse learning resources, courses, or teachers suitable for their children. |
| Rationale | Parents often support learning decisions and may want to find trusted resources. |
| Related PRD Section | 4.2 Parents |

---

### UR-PAR-002: Find Suitable Teachers

| Field | Value |
|---|---|
| User Group | Parent |
| Priority | Future |
| Description | Parents need to find suitable teachers based on subject, level, teaching style, ratings, and availability. |
| Rationale | Parents may use HIPZI to help students connect with reliable teachers. |
| Related PRD Section | 4.2 Parents, 11.15 Parent Dashboard |

---

### UR-PAR-003: View Student Learning Progress

| Field | Value |
|---|---|
| User Group | Parent |
| Priority | Future |
| Description | Parents need to view a student’s learning progress, completed materials, quiz performance, and learning summaries. |
| Rationale | Parents may want visibility into how their children are learning and improving. |
| Related PRD Section | 11.15 Parent Dashboard |

---

### UR-PAR-004: Receive Learning Summaries

| Field | Value |
|---|---|
| User Group | Parent |
| Priority | Future |
| Description | Parents need to receive summaries about student learning activity, progress, and areas that need support. |
| Rationale | Learning summaries help parents support students outside the platform. |
| Related PRD Section | 11.15 Parent Dashboard |

---

## 9. General Cross-Role Requirements

These requirements apply to multiple user groups.

---

### UR-GEN-001: Role-Based Access

| Field | Value |
|---|---|
| User Group | General |
| Priority | MVP |
| Description | Users need access to features based on their assigned role, such as Student, Parent, Teacher, Staff, or Admin. |
| Rationale | HIPZI supports multiple user groups with different permissions and workflows. |
| Related PRD Section | 8.2.1 User Authentication and Role Management |

---

### UR-GEN-002: Multiple Role Assignment

| Field | Value |
|---|---|
| User Group | General |
| Priority | MVP |
| Description | A user may hold multiple roles only when explicitly assigned by an Admin. |
| Rationale | HIPZI allows trusted users, such as high-performing teachers, to receive additional Staff permissions while preserving role governance. |
| Related PRD Section | 4.3 Teachers / Lecturers, 4.4 Staff, 4.5 Admins |

---

### UR-GEN-003: Teacher and Staff Role Separation

| Field | Value |
|---|---|
| User Group | General |
| Priority | MVP |
| Description | Teacher and Staff roles must be separate by default. |
| Rationale | Teachers create educational content, while Staff moderate platform content and teacher applications. Separating these roles prevents conflicts of interest. |
| Related PRD Section | 4.3 Teachers / Lecturers, 4.4 Staff |

---

### UR-GEN-004: Clear Navigation

| Field | Value |
|---|---|
| User Group | General |
| Priority | MVP |
| Description | Users need clear navigation to access learning materials, practice features, teacher tools, staff moderation tools, and admin governance tools based on their role. |
| Rationale | A clear interface reduces confusion and improves usability across user groups. |
| Related PRD Section | 10. Key User Journeys |

---

### UR-GEN-005: Safe and Trustworthy Content

| Field | Value |
|---|---|
| User Group | General |
| Priority | MVP |
| Description | Users need learning content to be reviewed, reliable, and safe to use. |
| Rationale | Trust is critical for an education platform that allows teacher-uploaded and AI-generated content. |
| Related PRD Section | 14.2 Content Quality, 14.3 AI Accuracy |

---

### UR-GEN-006: AI Transparency

| Field | Value |
|---|---|
| User Group | General |
| Priority | Phase 2 |
| Description | Users need to know when content, explanations, recommendations, or feedback are generated by AI. |
| Rationale | AI-generated educational content may contain errors and should be clearly identified as AI-assisted. |
| Related PRD Section | 14.3 AI Accuracy |

---

### UR-GEN-007: Feedback and Reporting

| Field | Value |
|---|---|
| User Group | General |
| Priority | Phase 2 |
| Description | Users need to report incorrect materials, inappropriate content, AI mistakes, teacher issues, or platform issues. |
| Rationale | Reporting mechanisms help improve content quality and platform safety. |
| Related PRD Section | 14.2 Content Quality, 14.3 AI Accuracy |

---

### UR-GEN-008: Responsive User Experience

| Field | Value |
|---|---|
| User Group | General |
| Priority | Phase 2 |
| Description | Users need the platform to work smoothly across common device sizes such as desktop, tablet, and mobile browsers. |
| Rationale | Students, teachers, staff, admins, and parents may access HIPZI from different devices. |
| Related PRD Section | 9. Out of Scope for MVP, 11. Future Development Opportunities |

---

## 10. Requirement Priority Summary

### 10.1 MVP Requirements

The MVP should prioritize the following user needs:

- Student account access.
- Student browsing and searching study materials.
- Student viewing materials.
- Student practicing with quizzes and flashcards.
- Student viewing basic quiz results.
- Teacher registration and profile submission.
- Staff review and approval of teacher applications.
- Teacher material upload for review.
- Staff review and moderation of uploaded materials.
- Teacher AI quiz and flashcard generation.
- Teacher review of AI-generated content.
- Admin role and permission management.
- Admin assignment or revocation of Staff permissions.
- Subject management.
- Role-based access.
- Teacher and Staff role separation.
- Safe and trustworthy content.

### 10.2 Phase 2 Requirements

Phase 2 should focus on:

- AI explanation support.
- AI personalization from student input.
- AI analysis of weak areas.
- Personalized learning roadmap.
- Recommended materials and teachers.
- Student progress tracking.
- Teacher class management.
- Teacher dashboard.
- Staff report handling.
- Staff quality monitoring.
- Admin audit of Staff moderation actions.
- Admin override of Staff decisions.
- AI transparency.
- Feedback and reporting.

### 10.3 Future Requirements

Future phases may include:

- Parent dashboard.
- Course builder.
- Online exams.
- AI teaching assistant.
- Assignment management.
- Community and Q&A.
- Study groups.
- Teacher marketplace.
- Advanced analytics.
- Payment and monetization workflows.
- Serious dispute handling.
- Advanced governance tools.

---

## 11. Notes for Future Requirement Refinement

This document defines user-level requirements only. Each requirement should later be translated into more detailed documents:

- Functional requirements.
- Business rules.
- User flows.
- Acceptance criteria.
- Edge cases.
- System requirements.
- API design.
- Database design.
- Testing strategy.

The next recommended document is `02-business-rules.md`, followed by `03-functional-requirements.md`.

When writing functional requirements, each feature should reference one or more user requirements from this document.

When writing business rules, the role separation between Teacher, Staff, and Admin should be treated as a core governance rule.