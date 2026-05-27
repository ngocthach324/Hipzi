# HIPZI Database Design Analysis for `08-database-design.md`

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Database Design Analysis |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md, 07-system-architecture.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Database Designer, Backend Engineer, QA Engineer |
| Language | English |

---

## 1. Purpose

This document analyzes the database needs of HIPZI before writing the full `08-database-design.md`.

The purpose of database design is to define how HIPZI should store, relate, protect, and query data.

If previous documents define the product, requirements, rules, flows, acceptance criteria, edge cases, and architecture, then database design answers the following questions:

- What data does HIPZI need to store?
- How should major entities relate to each other?
- Which tables are required for MVP?
- Which tables should be deferred to Phase 2 or Future?
- Which statuses and constraints are needed?
- How should role-based access and moderation workflows be supported?
- How should AI-generated content be stored safely?
- How should Student-facing visibility be enforced?
- How should auditability be preserved?

This document does not define exact production migrations or ORM implementation details. Those should be written later based on the selected technology stack.

---

## 2. Database Design Context

HIPZI is not a simple content website. It is an AI-powered education platform with multiple roles and governance workflows.

The database must support:

- Users with multiple roles.
- Students browsing approved learning content.
- Teachers applying for verification.
- Staff reviewing teacher applications.
- Staff moderating uploaded materials.
- Admins assigning roles, managing Staff permissions, auditing actions, and overriding decisions.
- Teachers generating quizzes and flashcards using AI.
- Teachers reviewing AI-generated content before Student access.
- Students practicing quizzes and flashcards.
- Learning history for future personalization.
- AI-powered roadmap and recommendation features in Phase 2.
- Classes, courses, parent dashboard, exams, ratings, and payments in future phases.

Because of this, the database must be designed around workflow states, ownership, permissions, and auditability.

---

## 3. Recommended Database Approach

HIPZI should use a relational database as the primary database.

Recommended database:

- PostgreSQL is the best default choice.
- MySQL is acceptable if the team prefers it.
- SQLite may be used only for local prototypes, not for production design.

A relational database fits HIPZI because the platform has structured relationships:

- Users have roles.
- Users can apply to become Teachers.
- Teachers upload materials.
- Materials belong to subjects.
- Staff moderate teacher applications and materials.
- Materials can generate AI quizzes and flashcards.
- Students attempt quizzes.
- Admins assign Staff roles.
- Reports and audit logs reference users and content.

A document database may be considered later for analytics events, AI logs, or unstructured activity data, but the core platform should use relational tables.

---

## 4. Core Database Design Principles

### 4.1 Use Stable Primary Keys

Every major table should have a stable primary key.

Recommended approach:

- Use UUID primary keys for production-ready design.
- Use auto-increment IDs only if simplicity is preferred for MVP.

Examples:

- `users.id`
- `materials.id`
- `teacher_applications.id`
- `quizzes.id`
- `quiz_attempts.id`

UUIDs are useful because they are safer for public APIs and future distributed systems.

---

### 4.2 Use Clear Ownership

Any user-generated or teacher-generated content should have a clear owner.

Examples:

- A material should have `owner_teacher_id`.
- A quiz should have `created_by_teacher_id`.
- A flashcard set should have `created_by_teacher_id`.
- A report should have `reporter_user_id`.
- A moderation action should have `actor_staff_id`.

Ownership is important for:

- Permission checks.
- Teacher dashboards.
- Staff self-review prevention.
- Audit logs.
- Content accountability.
- Future revenue sharing or teacher marketplace features.

---

### 4.3 Use Status Fields for Workflows

HIPZI depends heavily on workflow states.

Important status fields include:

- Teacher application status.
- Material moderation status.
- AI content status.
- Quiz attempt status.
- Class enrollment status.
- Report status.
- Payment status in future phases.

Status values should be controlled by enums or strict application-level constants.

Example material statuses:

- `draft`
- `pending_review`
- `approved`
- `rejected`
- `needs_revision`
- `hidden`
- `archived`

Status should not be stored as uncontrolled free text.

---

### 4.4 Separate Moderation Status from Visibility

For learning materials, it is useful to separate moderation status from visibility.

Recommended fields:

- `status`
- `visibility`

Example:

- `status = approved`
- `visibility = visible`

Student-facing access should require:

- `status = approved`
- `visibility = visible`
- `deleted_at IS NULL`

This gives HIPZI better control later. For example, a material can be approved but temporarily hidden.

---

### 4.5 Store Audit Logs for Important Actions

HIPZI has Staff moderation and Admin governance. Therefore, important decisions should be auditable.

Actions that should be logged:

- Staff approves teacher application.
- Staff rejects teacher application.
- Staff approves material.
- Staff rejects material.
- Staff requests material revision.
- Staff hides material.
- Staff archives material.
- Admin assigns Staff role.
- Admin revokes Staff role.
- Admin overrides Staff decision.
- Self-review attempt is blocked.
- AI generation succeeds or fails.

Audit logs support:

- Accountability.
- Debugging.
- Admin governance.
- Dispute handling.
- Security review.
- Future moderation analytics.

---

### 4.6 Prefer Soft Delete for Important Records

HIPZI should avoid hard deleting important domain records.

Do not immediately delete:

- Users.
- Materials.
- Teacher applications.
- Quizzes.
- Flashcards.
- Quiz attempts.
- Moderation actions.
- Audit logs.

Recommended fields:

- `deleted_at`
- `archived_at`
- `status = archived`

Important principle:

- Do not soft delete audit logs.
- Do not delete quiz attempts if they are part of learning history.
- Do not delete moderation decisions if they are needed for governance.

---

## 5. Main Entity Groups

HIPZI database can be divided into the following entity groups:

1. Identity and Role Entities.
2. User Profile Entities.
3. Teacher Verification Entities.
4. Subject and Learning Category Entities.
5. Study Material Entities.
6. AI Content Entities.
7. Quiz and Flashcard Entities.
8. Student Practice and Learning Activity Entities.
9. Staff, Admin, and Audit Entities.
10. Search and Discovery Support Entities.
11. Personalization and Recommendation Entities.
12. Class and Course Entities.
13. Parent Access Entities.
14. Reporting, Review, and Rating Entities.
15. Exam and Assessment Entities.
16. Payment and Monetization Entities.

For MVP, not all groups are required.

---

## 6. MVP Database Scope

The MVP should focus on the core HIPZI workflow:

> Teacher uploads learning material → Staff reviews and approves content → AI generates quiz or flashcards → Teacher reviews AI-generated content → Student practices → Platform stores learning activity → Staff and Admins govern content quality.

### 6.1 Required MVP Tables

The following tables should be included in the MVP:

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

### 6.2 Optional MVP Tables

The following tables are useful but can be added after the basic MVP:

- `notifications`
- `material_versions`
- `ai_generation_jobs`
- `reports`

### 6.3 Phase 2 and Future Tables

The following tables should be deferred until they are needed:

- `student_learning_preferences`
- `learning_roadmaps`
- `learning_roadmap_items`
- `classes`
- `class_enrollments`
- `courses`
- `course_modules`
- `course_lessons`
- `lesson_items`
- `parent_student_links`
- `reviews`
- `exams`
- `exam_attempts`
- `subscriptions`
- `payment_transactions`

---

## 7. Identity and Role Tables

### 7.1 `users`

The `users` table stores core account information.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `email` | String | Unique login identifier |
| `password_hash` | String | Password hash if using email/password authentication |
| `display_name` | String | User display name |
| `avatar_url` | String | Optional profile image |
| `account_status` | Enum | active, suspended, disabled |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |
| `deleted_at` | Timestamp | Soft delete timestamp |

Notes:

- Do not store plain-text passwords.
- `email` should be unique.
- `account_status` should control whether the user can access the platform.
- OAuth provider fields can be added later if needed.

---

### 7.2 `roles`

The `roles` table stores available platform roles.

Recommended role values:

| Role |
|---|
| student |
| parent |
| teacher |
| staff |
| admin |

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `name` | String | Role name |
| `description` | Text | Role description |
| `created_at` | Timestamp | Creation timestamp |

Important rule:

- `roles.name` should be unique.

---

### 7.3 `user_roles`

The `user_roles` table stores the many-to-many relationship between users and roles.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `user_id` | UUID | References `users.id` |
| `role_id` | UUID | References `roles.id` |
| `assigned_by_user_id` | UUID | Admin who assigned the role |
| `assigned_at` | Timestamp | Assignment timestamp |
| `revoked_at` | Timestamp | Revocation timestamp |
| `is_active` | Boolean | Whether the role is currently active |

Why this table is important:

- A user can have multiple roles.
- A trusted Teacher can also become Staff.
- Staff role must be explicitly assigned by Admin.
- Role assignment should be auditable.

Important business rule:

> A user may hold multiple roles only when explicitly assigned by an Admin.

---

## 8. User Profile Tables

### 8.1 `student_profiles`

The `student_profiles` table stores Student-specific information.

MVP fields:

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `user_id` | UUID | References `users.id` |
| `grade_level` | String | Optional grade or level |
| `school_name` | String | Optional school name |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

Phase 2 fields may include:

| Field | Type | Purpose |
|---|---|---|
| `learning_goals` | Text / JSON | Student goals |
| `weak_areas` | Text / JSON | Known weak topics |
| `preferred_subjects` | JSON | Preferred subjects |
| `available_study_time` | String / JSON | Study availability |
| `learning_preferences` | JSON | Learning style or preferences |

Recommended refinement:

For personalization, use a separate table named `student_learning_preferences` instead of storing all personalization fields directly in `student_profiles`.

---

### 8.2 `teacher_profiles`

The `teacher_profiles` table stores Teacher profile information.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `user_id` | UUID | References `users.id` |
| `display_title` | String | Teacher title or professional name |
| `bio` | Text | Teacher introduction |
| `experience_summary` | Text | Teaching experience |
| `qualifications` | Text / JSON | Credentials or qualification information |
| `teaching_subjects` | Text / JSON | Teaching subjects |
| `verification_status` | Enum | pending, verified, rejected, suspended |
| `rating_average` | Decimal | Future rating average |
| `rating_count` | Integer | Future rating count |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

Important note:

Teacher profile is not the same as Teacher approval.

Teacher approval should be tracked through `teacher_applications`.

---

## 9. Teacher Verification Tables

### 9.1 `teacher_applications`

The `teacher_applications` table stores applications from users who want to become verified Teachers.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `user_id` | UUID | Applicant user |
| `status` | Enum | draft, pending_review, approved, rejected, suspended |
| `submitted_at` | Timestamp | Submission timestamp |
| `reviewed_by_staff_id` | UUID | Staff reviewer |
| `reviewed_at` | Timestamp | Review timestamp |
| `review_notes` | Text | Staff notes |
| `rejection_reason` | Text | Reason if rejected |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

Teacher application statuses:

- `draft`
- `pending_review`
- `approved`
- `rejected`
- `suspended`

Important rules:

- A user should not have multiple active teacher applications.
- Staff approval grants Teacher permissions.
- Staff rejection does not grant Teacher permissions.
- Staff cannot review their own application if they also have Staff role.

---

## 10. Subject and Learning Category Tables

### 10.1 `subjects`

The `subjects` table stores subjects such as Math, English, Programming, Physics, Chemistry, or course-specific categories.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `name` | String | Subject name |
| `slug` | String | URL-safe identifier |
| `description` | Text | Subject description |
| `parent_subject_id` | UUID | Optional hierarchy |
| `is_active` | Boolean | Whether subject is active |
| `created_by_admin_id` | UUID | Admin creator |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

Why this table matters:

- Materials must belong to subjects.
- Students browse by subject.
- Teachers categorize content by subject.
- AI recommendations can use subject context.
- Admins manage platform-level learning categories.

---

## 11. Study Material Tables

### 11.1 `materials`

The `materials` table stores learning materials uploaded by Teachers.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `owner_teacher_id` | UUID | References `users.id` of Teacher |
| `subject_id` | UUID | References `subjects.id` |
| `title` | String | Material title |
| `description` | Text | Material description |
| `content_text` | Text | Optional text content |
| `status` | Enum | draft, pending_review, approved, rejected, needs_revision, hidden, archived |
| `visibility` | Enum | private, visible, hidden |
| `difficulty_level` | String | Optional difficulty |
| `grade_level` | String | Optional grade |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |
| `submitted_at` | Timestamp | Review submission timestamp |
| `approved_at` | Timestamp | Approval timestamp |
| `archived_at` | Timestamp | Archive timestamp |
| `deleted_at` | Timestamp | Soft delete timestamp |

Material statuses:

- `draft`
- `pending_review`
- `approved`
- `rejected`
- `needs_revision`
- `hidden`
- `archived`

Visibility values:

- `private`
- `visible`
- `hidden`

Student-facing visibility rule:

    status = approved
    AND visibility = visible
    AND deleted_at IS NULL

Important rules:

- Only approved Teachers can create materials.
- Materials must have an owner.
- Materials must belong to at least one subject.
- Students must not see unapproved, hidden, rejected, archived, or deleted materials.

---

### 11.2 `material_files`

The `material_files` table stores files attached to materials.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `material_id` | UUID | References `materials.id` |
| `file_url` | String | Object storage URL |
| `file_name` | String | Original file name |
| `file_type` | String | pdf, image, doc, etc. |
| `mime_type` | String | MIME type |
| `file_size` | Integer | File size |
| `uploaded_by_user_id` | UUID | Uploader |
| `created_at` | Timestamp | Upload timestamp |

Why separate table?

- One material may have multiple files.
- File metadata should be separate from material metadata.
- Object storage should store the actual file.
- Database should store only file references and metadata.

---

### 11.3 `material_versions`

The `material_versions` table is optional for MVP, but useful for Phase 2.

It stores material version history.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `material_id` | UUID | References `materials.id` |
| `version_number` | Integer | Version number |
| `title` | String | Snapshot title |
| `description` | Text | Snapshot description |
| `content_text` | Text | Snapshot content |
| `created_by_user_id` | UUID | User who created the version |
| `created_at` | Timestamp | Version timestamp |
| `change_summary` | Text | Summary of changes |

Why useful:

- Approved materials may need re-review after major edits.
- Staff can review what changed.
- Admins can audit content evolution.
- Teachers can maintain content history safely.

---

### 11.4 `material_moderation_actions`

The `material_moderation_actions` table stores Staff moderation decisions for materials.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `material_id` | UUID | References `materials.id` |
| `actor_staff_id` | UUID | Staff who performed action |
| `action` | Enum | approve, reject, request_revision, hide, archive |
| `previous_status` | String | Status before action |
| `new_status` | String | Status after action |
| `reason` | Text | Optional or required reason |
| `created_at` | Timestamp | Action timestamp |

Important rules:

- Staff must not moderate their own materials.
- Every important moderation action should be logged.
- Admin override may be stored in `audit_logs`, `admin_overrides`, or both.

---

## 12. AI Content Tables

HIPZI needs to store AI-generated outputs separately from source materials.

AI-generated content should never become public immediately.

### 12.1 `ai_contents`

The `ai_contents` table stores AI-generated educational content metadata.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `source_material_id` | UUID | References `materials.id` |
| `created_by_teacher_id` | UUID | Teacher who generated content |
| `content_type` | Enum | quiz, flashcard_set, explanation, roadmap |
| `status` | Enum | generated_draft, teacher_reviewed, submitted_for_review, approved, rejected, published, discarded |
| `ai_assisted` | Boolean | Whether content is AI-assisted |
| `generation_prompt` | Text | Optional prompt metadata |
| `generation_model` | String | Optional model metadata |
| `generated_at` | Timestamp | Generation timestamp |
| `reviewed_by_teacher_id` | UUID | Teacher reviewer |
| `reviewed_at` | Timestamp | Teacher review timestamp |
| `staff_review_required` | Boolean | Whether Staff review is required |
| `staff_reviewed_by_id` | UUID | Staff reviewer |
| `staff_reviewed_at` | Timestamp | Staff review timestamp |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

AI content statuses:

- `generated_draft`
- `teacher_reviewed`
- `submitted_for_review`
- `approved`
- `rejected`
- `published`
- `discarded`

Important rules:

- AI output starts as `generated_draft`.
- Teacher review is required before Student access.
- Staff approval may be required depending on platform policy.
- AI-assisted metadata should remain traceable even after Teacher editing.

---

### 12.2 `ai_generation_jobs`

The `ai_generation_jobs` table is optional for MVP, but useful if AI generation is asynchronous.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `requested_by_user_id` | UUID | User who requested generation |
| `source_material_id` | UUID | Material used for generation |
| `job_type` | Enum | quiz_generation, flashcard_generation, roadmap_generation |
| `status` | Enum | queued, processing, completed, failed, cancelled |
| `error_message` | Text | Error details |
| `result_ai_content_id` | UUID | Generated content |
| `created_at` | Timestamp | Creation timestamp |
| `started_at` | Timestamp | Processing start |
| `completed_at` | Timestamp | Completion timestamp |

Useful for:

- Long AI processing.
- Retry behavior.
- Debugging.
- User feedback.
- Background job tracking.

---

## 13. Quiz and Flashcard Tables

### 13.1 `quizzes`

The `quizzes` table stores quiz sets.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `material_id` | UUID | Source material |
| `ai_content_id` | UUID | Optional AI content reference |
| `created_by_teacher_id` | UUID | Teacher creator |
| `title` | String | Quiz title |
| `description` | Text | Quiz description |
| `status` | Enum | draft, teacher_reviewed, approved, published, archived |
| `is_ai_assisted` | Boolean | Whether quiz is AI-assisted |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

Student access rule:

    A quiz should be available only if:
    - The related material is approved and visible.
    - The quiz status allows Student access.
    - Required Teacher review is completed.
    - Required Staff review is completed if policy requires it.

---

### 13.2 `quiz_questions`

The `quiz_questions` table stores quiz questions.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `quiz_id` | UUID | References `quizzes.id` |
| `question_text` | Text | Question content |
| `question_type` | Enum | multiple_choice, true_false, short_answer |
| `explanation` | Text | Explanation after submission |
| `order_index` | Integer | Question order |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

---

### 13.3 `quiz_options`

The `quiz_options` table stores answer options for objective questions.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `question_id` | UUID | References `quiz_questions.id` |
| `option_text` | Text | Option text |
| `is_correct` | Boolean | Whether option is correct |
| `order_index` | Integer | Option order |

Important rule:

- For multiple-choice questions, at least one option should be correct.
- A question without evaluation rules should not produce an invalid score.

---

### 13.4 `flashcard_sets`

The `flashcard_sets` table stores flashcard groups.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `material_id` | UUID | Source material |
| `ai_content_id` | UUID | Optional AI content reference |
| `created_by_teacher_id` | UUID | Teacher creator |
| `title` | String | Set title |
| `description` | Text | Set description |
| `status` | Enum | draft, teacher_reviewed, approved, published, archived |
| `is_ai_assisted` | Boolean | Whether flashcard set is AI-assisted |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

---

### 13.5 `flashcards`

The `flashcards` table stores individual flashcards.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `flashcard_set_id` | UUID | References `flashcard_sets.id` |
| `front_text` | Text | Prompt or question |
| `back_text` | Text | Answer or explanation |
| `order_index` | Integer | Card order |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

---

## 14. Student Practice Tables

### 14.1 `quiz_attempts`

The `quiz_attempts` table stores Student quiz attempts.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `student_user_id` | UUID | Student |
| `quiz_id` | UUID | Quiz attempted |
| `status` | Enum | started, submitted, scored, reviewed, incomplete |
| `score` | Decimal | Score value |
| `max_score` | Decimal | Maximum score |
| `started_at` | Timestamp | Attempt start |
| `submitted_at` | Timestamp | Submission time |
| `scored_at` | Timestamp | Scoring time |
| `created_at` | Timestamp | Creation timestamp |

Important rules:

- Duplicate submission for the same attempt should be prevented.
- Practice attempts should be stored for learning history.
- Retakes should create new attempts.
- Practice quiz scores are learning feedback, not formal academic grades.

---

### 14.2 `quiz_attempt_answers`

The `quiz_attempt_answers` table stores answers submitted by Students.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `quiz_attempt_id` | UUID | References `quiz_attempts.id` |
| `question_id` | UUID | References `quiz_questions.id` |
| `selected_option_id` | UUID | For objective questions |
| `answer_text` | Text | For text-based answers |
| `is_correct` | Boolean | Result if auto-gradable |
| `score_awarded` | Decimal | Score for answer |
| `created_at` | Timestamp | Timestamp |

---

### 14.3 `learning_activities`

The `learning_activities` table stores general learning activity.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `student_user_id` | UUID | Student |
| `activity_type` | Enum | view_material, start_quiz, submit_quiz, practice_flashcards |
| `material_id` | UUID | Optional material reference |
| `quiz_id` | UUID | Optional quiz reference |
| `flashcard_set_id` | UUID | Optional flashcard reference |
| `metadata` | JSON | Optional metadata |
| `created_at` | Timestamp | Activity timestamp |

Why this matters:

- Learning history.
- Progress tracking.
- Future personalization.
- Recommendation input.
- Student dashboard analytics.

---

## 15. Search and Discovery Data

For MVP, search can query the `materials` table directly.

Student-facing material search must always filter:

    materials.status = approved
    AND materials.visibility = visible
    AND materials.deleted_at IS NULL

Recommended MVP indexes:

- `materials.title`
- `materials.description`
- `materials.subject_id`
- `materials.status`
- `materials.visibility`
- `materials.owner_teacher_id`

Future search may use:

- Full-text search.
- Search index table.
- External search provider.
- Embeddings for semantic search.

### 15.1 `search_index_entries`

This table is optional for future search improvements.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `entity_type` | Enum | material, teacher, course |
| `entity_id` | UUID | Related entity |
| `search_text` | Text | Searchable text |
| `status` | Enum | active, stale, removed |
| `updated_at` | Timestamp | Last index update |

---

## 16. Personalization and Recommendation Tables

Personalization is Phase 2.

### 16.1 `student_learning_preferences`

The `student_learning_preferences` table stores Student personalization input.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `student_user_id` | UUID | Student |
| `learning_goals` | Text / JSON | Student goals |
| `current_level` | String | Current level |
| `weak_areas` | Text / JSON | Weak topics |
| `preferred_subjects` | JSON | Preferred subjects |
| `available_study_time` | String / JSON | Time availability |
| `learning_style` | String / JSON | Optional learning style |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

---

### 16.2 `learning_roadmaps`

The `learning_roadmaps` table stores AI-generated or manually generated learning roadmaps.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `student_user_id` | UUID | Student |
| `generated_by` | Enum | ai, teacher, system |
| `title` | String | Roadmap title |
| `summary` | Text | Roadmap summary |
| `status` | Enum | active, archived |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

---

### 16.3 `learning_roadmap_items`

The `learning_roadmap_items` table stores roadmap steps.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `roadmap_id` | UUID | References `learning_roadmaps.id` |
| `subject_id` | UUID | Optional subject |
| `title` | String | Step title |
| `description` | Text | Step description |
| `order_index` | Integer | Step order |
| `recommended_material_id` | UUID | Optional recommended material |
| `recommended_teacher_id` | UUID | Optional recommended Teacher |
| `estimated_duration` | String | Optional duration |
| `status` | Enum | pending, in_progress, completed, skipped |

Important recommendation rules:

    recommended_material_id must point to an approved and visible material.
    recommended_teacher_id must point to a verified and active Teacher.

---

## 17. Staff, Admin, and Audit Tables

### 17.1 `audit_logs`

The `audit_logs` table stores important system and governance actions.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `actor_user_id` | UUID | User who performed the action |
| `actor_role` | String | Role used for action |
| `action` | String | Action name |
| `entity_type` | String | material, user, teacher_application, role, etc. |
| `entity_id` | UUID | Target record |
| `previous_value` | JSON | Optional previous value |
| `new_value` | JSON | Optional new value |
| `reason` | Text | Optional reason |
| `created_at` | Timestamp | Timestamp |

Examples of audit actions:

- `assign_staff_role`
- `revoke_staff_role`
- `approve_teacher_application`
- `reject_teacher_application`
- `approve_material`
- `reject_material`
- `request_material_revision`
- `hide_material`
- `archive_material`
- `admin_override`
- `self_review_blocked`

Why this matters:

- Governance.
- Debugging.
- Security.
- Dispute handling.
- Moderator accountability.

---

### 17.2 `admin_overrides`

The `admin_overrides` table is optional, but useful if override workflows become important.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `admin_user_id` | UUID | Admin who overrides |
| `target_entity_type` | String | material, teacher_application, report |
| `target_entity_id` | UUID | Target entity |
| `previous_status` | String | Previous status |
| `new_status` | String | New status |
| `reason` | Text | Override reason |
| `created_at` | Timestamp | Timestamp |

Alternative:

Admin overrides can also be stored only in `audit_logs`, but a separate table is cleaner if override workflows become common.

---

## 18. Reporting, Review, and Rating Tables

### 18.1 `reports`

The `reports` table is planned for Phase 2.

It stores reported content and AI mistakes.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `reporter_user_id` | UUID | User who reported |
| `target_entity_type` | Enum | material, quiz, flashcard, teacher, ai_content |
| `target_entity_id` | UUID | Report target |
| `reason_type` | Enum | incorrect, inappropriate, low_quality, ai_error, other |
| `description` | Text | Optional explanation |
| `status` | Enum | submitted, in_review, resolved, dismissed, escalated |
| `reviewed_by_staff_id` | UUID | Staff reviewer |
| `reviewed_at` | Timestamp | Review timestamp |
| `created_at` | Timestamp | Report timestamp |

---

### 18.2 `reviews`

The `reviews` table is future scope.

It stores ratings and reviews for materials, Teachers, classes, or courses.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `reviewer_user_id` | UUID | User who reviewed |
| `target_entity_type` | Enum | material, teacher, class, course |
| `target_entity_id` | UUID | Target record |
| `rating` | Integer | Numeric rating |
| `review_text` | Text | Optional text |
| `status` | Enum | visible, hidden, removed |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

Important rules:

- Users can only review items they interacted with.
- Teachers cannot review their own content.
- Staff may moderate reviews in future phases.

---

## 19. Class and Course Tables

These tables are Phase 2 and Future scope.

### 19.1 `classes`

The `classes` table stores teacher-managed classes.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `teacher_user_id` | UUID | Teacher owner |
| `subject_id` | UUID | Subject |
| `title` | String | Class title |
| `description` | Text | Class description |
| `enrollment_policy` | Enum | open, approval_required, invite_only |
| `capacity` | Integer | Optional capacity limit |
| `status` | Enum | draft, active, archived |
| `created_at` | Timestamp | Creation timestamp |

---

### 19.2 `class_enrollments`

The `class_enrollments` table stores Student enrollment records.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `class_id` | UUID | Class |
| `student_user_id` | UUID | Student |
| `status` | Enum | requested, approved, rejected, active, removed |
| `requested_at` | Timestamp | Request timestamp |
| `reviewed_by_teacher_id` | UUID | Teacher reviewer |
| `reviewed_at` | Timestamp | Review timestamp |

Important rule:

- A Student should not have duplicate active enrollment requests for the same class.

---

### 19.3 `courses`

The `courses` table stores structured courses.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `teacher_user_id` | UUID | Teacher owner |
| `subject_id` | UUID | Subject |
| `title` | String | Course title |
| `description` | Text | Course description |
| `status` | Enum | draft, pending_review, approved, published, archived |
| `created_at` | Timestamp | Creation timestamp |
| `updated_at` | Timestamp | Last update timestamp |

---

### 19.4 `course_modules`

The `course_modules` table stores modules inside a course.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `course_id` | UUID | Course |
| `title` | String | Module title |
| `description` | Text | Module description |
| `order_index` | Integer | Module order |

---

### 19.5 `course_lessons`

The `course_lessons` table stores lessons inside modules.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `module_id` | UUID | Course module |
| `title` | String | Lesson title |
| `description` | Text | Lesson description |
| `order_index` | Integer | Lesson order |

---

### 19.6 `lesson_items`

The `lesson_items` table connects lessons to materials, quizzes, flashcards, or assignments.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `lesson_id` | UUID | Lesson |
| `item_type` | Enum | material, quiz, flashcard_set, assignment |
| `item_id` | UUID | Target item |
| `order_index` | Integer | Item order |

---

## 20. Parent Access Tables

### 20.1 `parent_student_links`

The `parent_student_links` table is future scope.

It stores verified relationships between Parents and Students.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `parent_user_id` | UUID | Parent |
| `student_user_id` | UUID | Student |
| `status` | Enum | pending, verified, rejected, revoked |
| `verified_at` | Timestamp | Verification timestamp |
| `created_at` | Timestamp | Creation timestamp |
| `revoked_at` | Timestamp | Revocation timestamp |

Important rule:

> Parent access to Student learning data requires a verified relationship.

---

## 21. Exam and Assessment Tables

Exam and assessment features are future scope.

### 21.1 `exams`

The `exams` table stores formal online exams.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `teacher_user_id` | UUID | Teacher creator |
| `title` | String | Exam title |
| `description` | Text | Exam description |
| `status` | Enum | draft, published, archived |
| `time_limit_minutes` | Integer | Optional time limit |
| `attempt_limit` | Integer | Optional attempt limit |
| `available_from` | Timestamp | Start time |
| `available_until` | Timestamp | End time |
| `created_at` | Timestamp | Creation timestamp |

---

### 21.2 `exam_attempts`

The `exam_attempts` table stores Student exam attempts.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `exam_id` | UUID | Exam |
| `student_user_id` | UUID | Student |
| `status` | Enum | started, submitted, graded, reviewed |
| `score` | Decimal | Score |
| `started_at` | Timestamp | Start time |
| `submitted_at` | Timestamp | Submission time |
| `graded_at` | Timestamp | Grading time |

---

## 22. Payment and Monetization Tables

Payment and monetization features are future scope.

### 22.1 `subscriptions`

The `subscriptions` table stores user subscription records.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `user_id` | UUID | User |
| `plan_name` | String | Plan name |
| `status` | Enum | active, cancelled, expired, past_due |
| `started_at` | Timestamp | Start date |
| `ended_at` | Timestamp | End date |

---

### 22.2 `payment_transactions`

The `payment_transactions` table stores payment transaction records.

| Field | Type | Purpose |
|---|---|---|
| `id` | UUID | Primary key |
| `payer_user_id` | UUID | Student or Parent |
| `payee_user_id` | UUID | Teacher or platform |
| `amount` | Decimal | Payment amount |
| `currency` | String | Currency |
| `status` | Enum | pending, succeeded, failed, refunded |
| `provider` | String | Payment provider |
| `provider_transaction_id` | String | External provider transaction ID |
| `created_at` | Timestamp | Creation timestamp |

---

## 23. Important Relationships

### 23.1 User and Role

A user can have multiple roles.

    users
    → user_roles
    → roles

This supports:

- Student only.
- Teacher only.
- Staff only.
- Teacher + Staff.
- Admin.

---

### 23.2 User and Teacher Application

A user may apply to become a Teacher.

    users
    → teacher_applications

Staff reviews this application.

---

### 23.3 Teacher and Material

A Teacher owns uploaded materials.

    users
    → materials

The relationship is represented by:

    materials.owner_teacher_id → users.id

---

### 23.4 Material and Subject

Each material belongs to a subject.

    subjects
    → materials

The relationship is represented by:

    materials.subject_id → subjects.id

---

### 23.5 Material and Moderation Actions

Each Staff moderation decision should be logged.

    materials
    → material_moderation_actions

This supports Staff accountability and Admin audit.

---

### 23.6 Material and AI Content

AI-generated content references source materials.

    materials
    → ai_contents
    → quizzes / flashcard_sets

This makes AI content traceable to source material.

---

### 23.7 Quiz and Quiz Attempt

Quizzes contain questions and options.

    quizzes
    → quiz_questions
    → quiz_options

Students create attempts.

    quizzes
    → quiz_attempts
    → quiz_attempt_answers

---

### 23.8 Student and Learning Activity

Students generate learning activity records.

    users
    → learning_activities

This supports:

- Learning history.
- Progress tracking.
- Future recommendations.
- AI roadmap generation.

---

## 24. Status Design Summary

### 24.1 Teacher Application Status

Recommended values:

- `draft`
- `pending_review`
- `approved`
- `rejected`
- `suspended`

---

### 24.2 Material Status

Recommended values:

- `draft`
- `pending_review`
- `approved`
- `rejected`
- `needs_revision`
- `hidden`
- `archived`

---

### 24.3 Material Visibility

Recommended values:

- `private`
- `visible`
- `hidden`

---

### 24.4 AI Content Status

Recommended values:

- `generated_draft`
- `teacher_reviewed`
- `submitted_for_review`
- `approved`
- `rejected`
- `published`
- `discarded`

---

### 24.5 Quiz Status

Recommended values:

- `draft`
- `teacher_reviewed`
- `approved`
- `published`
- `archived`

---

### 24.6 Quiz Attempt Status

Recommended values:

- `started`
- `submitted`
- `scored`
- `reviewed`
- `incomplete`

---

### 24.7 Report Status

Recommended values:

- `submitted`
- `in_review`
- `resolved`
- `dismissed`
- `escalated`

---

### 24.8 Enrollment Status

Recommended values:

- `requested`
- `approved`
- `rejected`
- `active`
- `removed`

---

## 25. Database Constraints and Rules

### 25.1 Unique Constraints

Recommended unique constraints:

- `users.email` should be unique.
- `roles.name` should be unique.
- `subjects.slug` should be unique.
- Active `user_roles(user_id, role_id)` should be unique.
- Active `class_enrollments(class_id, student_user_id)` should be unique.
- A user should not have multiple active pending or approved teacher applications.

Possible database-level rule:

    user_roles(user_id, role_id, is_active)
    should prevent duplicate active role assignment.

---

### 25.2 Foreign Key Constraints

Important foreign keys:

- `user_roles.user_id → users.id`
- `user_roles.role_id → roles.id`
- `teacher_profiles.user_id → users.id`
- `student_profiles.user_id → users.id`
- `teacher_applications.user_id → users.id`
- `materials.owner_teacher_id → users.id`
- `materials.subject_id → subjects.id`
- `material_files.material_id → materials.id`
- `material_moderation_actions.material_id → materials.id`
- `ai_contents.source_material_id → materials.id`
- `quizzes.material_id → materials.id`
- `quiz_questions.quiz_id → quizzes.id`
- `quiz_options.question_id → quiz_questions.id`
- `quiz_attempts.quiz_id → quizzes.id`
- `quiz_attempts.student_user_id → users.id`
- `learning_activities.student_user_id → users.id`

---

### 25.3 Soft Delete Strategy

Recommended tables with soft delete:

- `users`
- `materials`
- `quizzes`
- `flashcard_sets`
- `classes`
- `courses`
- `reviews`

Recommended field:

    deleted_at TIMESTAMP NULL

Important rules:

- Do not soft delete audit logs.
- Do not delete quiz attempts if they are part of learning history.
- Do not delete moderation records if they are required for accountability.

---

### 25.4 Indexing Strategy

Recommended MVP indexes:

- `users.email`
- `user_roles.user_id`
- `teacher_applications.user_id`
- `teacher_applications.status`
- `materials.owner_teacher_id`
- `materials.subject_id`
- `materials.status`
- `materials.visibility`
- `materials.created_at`
- `material_moderation_actions.material_id`
- `ai_contents.source_material_id`
- `quizzes.material_id`
- `quiz_attempts.student_user_id`
- `quiz_attempts.quiz_id`
- `learning_activities.student_user_id`

For search:

- `materials.title`
- `materials.description`

Future search improvement:

    Full-text search index on:
    materials.title + materials.description + materials.content_text

---

## 26. Critical Database Rules for HIPZI

### 26.1 Staff Self-Review Prevention

The system must prevent a Staff member from reviewing their own:

- Teacher application.
- Material.
- AI-generated content.
- Course.
- Exam.

This should be enforced in application logic and supported by ownership fields.

Example logic:

    material.owner_teacher_id != current_staff_user_id

---

### 26.2 Student Visibility Filtering

Student-facing material queries must always filter:

    materials.status = 'approved'
    AND materials.visibility = 'visible'
    AND materials.deleted_at IS NULL

This must be enforced in backend queries, not only in frontend UI.

---

### 26.3 AI Content Draft Rule

AI-generated content must start as:

    status = generated_draft

It must not become visible to Students until:

- Teacher review is completed.
- Staff review is completed if platform policy requires it.
- Related material is approved and visible.

---

### 26.4 Approved Teacher Upload Rule

Only approved Teachers can upload materials.

This should be checked through:

- User role.
- Teacher application status.
- Teacher profile verification status if applicable.

---

### 26.5 Audit Important Actions

The following actions should create audit logs:

- Role assignment.
- Staff role revocation.
- Teacher application approval.
- Teacher application rejection.
- Material approval.
- Material rejection.
- Material revision request.
- Material hidden.
- Material archived.
- Admin override.
- Self-review block.

---

## 27. MVP Database Design Recommendation

For the MVP, HIPZI should implement these tables first:

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

Optional but useful for MVP:

- `notifications`
- `ai_generation_jobs`
- `material_versions`
- `reports`

Defer until Phase 2 or Future:

- `student_learning_preferences`
- `learning_roadmaps`
- `learning_roadmap_items`
- `classes`
- `class_enrollments`
- `courses`
- `course_modules`
- `course_lessons`
- `lesson_items`
- `parent_student_links`
- `reviews`
- `exams`
- `exam_attempts`
- `subscriptions`
- `payment_transactions`

---

## 28. Recommended Structure for Full `08-database-design.md`

The full `08-database-design.md` should include:

1. Document Information.
2. Purpose.
3. Database Design Principles.
4. MVP Database Scope.
5. Entity Relationship Overview.
6. Table Definitions.
7. Status and Enum Definitions.
8. Relationship Definitions.
9. Constraints and Indexes.
10. Access and Visibility Rules.
11. Audit and Logging Tables.
12. Phase 2 and Future Tables.
13. MVP Database Summary.
14. Notes for API Design.

---

## 29. Notes for API Design

The next document should be:

`09-api-design.md`

API design should be based on:

- Database entities.
- Role permissions.
- Workflow statuses.
- Visibility rules.
- Audit requirements.

Examples:

- `POST /materials` should create a material owned by an approved Teacher.
- `POST /materials/{id}/submit-review` should set material status to `pending_review`.
- `POST /staff/materials/{id}/approve` should create a moderation action and set status to `approved`.
- `GET /materials` for Students should only return approved and visible materials.
- `POST /ai/quizzes/generate` should create AI-generated draft content, not published content.
- `POST /admin/users/{id}/roles/staff` should assign Staff role and create audit log.

The database design should protect the core HIPZI rule:

> Students only access approved learning content.  
> Teachers create content.  
> Staff moderate content.  
> Admins govern the platform.  
> AI assists but does not bypass human review.