# HIPZI Database Design

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Database Design |
| Document Version | 2.0 (Updated to 8-module structure) |
| Status | Approved |

---

## 1. Overview

HIPZI's database is structured into 9 distinct modules to ensure scalability, ease of deployment, and clear separation of concerns. The physical SQL files are located in the `database/` folder and must be executed in order from `01` to `09` to resolve all foreign key dependencies.

### Execution Order & Modules

1. **`01-identity-auth.sql`**: Core user accounts, roles, and authentication.
2. **`02-profiles-notifications.sql`**: Student profiles, parent links, and system notifications.
3. **`03-teacher-applications.sql`**: Teacher verification workflow.
4. **`04-materials-repository.sql`**: Public learning material repository.
5. **`05-classrooms-core.sql`**: Virtual classrooms, enrollments, and basic modules.
6. **`06-classroom-quizzes-exams.sql`**: Quizzes and formal exams *inside* classrooms.
7. **`07-mock-exams.sql`**: Standalone public mock exams (Multiple Choice, Flashcard, Essay).
8. **`08-courses-wallet.sql`**: E-learning courses, lessons, and wallet transactions.
9. **`09-hipzi-exams.sql`**: Official proctored HIPZI exams with XP rewards.

---

## 2. Module 1: Identity & Authentication (`01-identity-auth.sql`)

Handles user accounts, role-based access control, and authentication tokens.

### Tables
- `roles`: Defines system roles (`student`, `parent`, `teacher`, `staff`, `admin`).
- `users`: Core account data, OAuth references, account status, and the `wallet_balance` field (added in module 08).
- `user_roles`: Many-to-many relationship linking users to roles. Support active/revoked states.
- `otp_codes`: Tracks OTPs for 2FA, registration, and password resets.
- `remember_me_tokens`: Persistent login sessions.

---

## 3. Module 2: Profiles & Notifications (`02-profiles-notifications.sql`)

Handles extended user data and system-to-user communication.

### Tables
- `student_profiles`: Caches dashboard statistics (level, XP, streak) and school info.
- `notifications`: In-app notification inbox.
- `parent_student_links`: Links parent accounts to student accounts.

---

## 4. Module 3: Teacher Applications (`03-teacher-applications.sql`)

Handles the workflow of a user applying to become a verified teacher.

### Tables
- `teacher_applications`: Stores applicant credentials, bio, and Staff review status (`pending`, `approved`, `rejected`).

---

## 5. Module 4: Materials Repository (`04-materials-repository.sql`)

Stores public learning materials uploaded by Teachers and reviewed by Staff.

### Tables
- `repository_materials`: Core table for materials. Includes workflow `status` (`DRAFT`, `PENDING`, `APPROVED`) and `visibility`.

---

## 6. Module 5: Classrooms Core (`05-classrooms-core.sql`)

The foundation for Virtual Classrooms managed by Teachers.

### Tables
- `classrooms`: The main class entity (schedule, capacity, teacher_id).
- `classroom_modules`: Customizable tabs/modules inside a class.
- `classroom_enrollments`: Student join requests and statuses.
- `classroom_materials`: Files shared privately within a class.
- `classroom_homework`: Assignments with due dates.
- `classroom_rules`: Class guidelines.

---

## 7. Module 6: Classroom Quizzes & Exams (`06-classroom-quizzes-exams.sql`)

Assessment tools specific to a Virtual Classroom.

### Tables
- `classroom_quizzes` & `classroom_quiz_questions`: Private quizzes generated via AI or manual entry.
- `classroom_quiz_attempts` & `classroom_quiz_answers`: Student practice history within the class.
- `classroom_exams`: Formal scheduled exams restricted to classroom members.

---

## 8. Module 7: Mock Exams (`07-mock-exams.sql`)

Public assessment tools available in the "Phòng Thi" (Exam Room). Designed to replace the old "Luyện tập" (Practice) system.

### Tables
- `mock_exams`: The exam container. Supports 3 types: `multiple_choice`, `flashcard`, `essay`.
- `mock_exam_questions`: Trắc nghiệm (Multiple choice) questions.
- `mock_exam_flashcards`: Flashcard data (front/back).
- `mock_exam_essays`: Tự luận (Essay) prompts.
- `mock_exam_attempts`: Tracking student starts and completions.
- `mock_exam_answers`: Trắc nghiệm selections.
- `mock_exam_essay_submissions`: Essay submissions by students and teacher feedback.

---

## 9. Module 8: Courses & Wallet (`08-courses-wallet.sql`)

Monetization and structured learning modules.

### Tables
- *Note*: Alters the `users` table to add `wallet_balance`.
- `courses`: Structured learning paths with pricing.
- `course_lessons`: Video/text lessons inside a course. Supports free previews.
- `course_enrollments`: Tracks which students own which courses.
- `wallet_transactions`: Ledger for deposits, course purchases, and revenue.

---

## 10. Module 9: HIPZI Exams (`09-hipzi-exams.sql`)

Official, proctored exams managed by Staff and Admins with rewards.

### Tables
- `hipzi_exams`: The exam configuration, schedule, and reward (XP).
- `hipzi_exam_questions` & `hipzi_exam_options`: Exam questions.
- `hipzi_exam_attempts` & `hipzi_exam_answers`: Student attempt tracking and responses.
- `hipzi_exam_leaderboards`: Rankings for completed exams.

---

## 11. Core Design Principles

1. **UUID Primary Keys**: All tables use `gen_random_uuid()` for distributed safety.
2. **Soft Deletes**: Major entities (`users`, `materials`) use `deleted_at` or `status = 'archived'`.
3. **Auditability**: `wallet_transactions` and status changes trace back to the user who triggered them.
4. **Referential Integrity**: Cascading deletes (`ON DELETE CASCADE`) are used for dependent child records (e.g., questions of a quiz), but restricted (`ON DELETE RESTRICT`) for core entities like roles.