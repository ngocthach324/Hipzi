# HIPZI Product Requirements Document

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Product Requirements Document |
| Document Version | 1.0 |
| Status | Draft |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Designer, Researcher |
| Language | English |

---

## 1. Product Overview

HIPZI is an online education platform designed for students, parents, teachers, staff members, and administrators. The platform aims to create a modern learning ecosystem where learners can access study materials, practice knowledge through interactive learning formats, connect with suitable teachers, and receive AI-powered learning support.

HIPZI is not only intended to be a study material repository. Its long-term vision is to become an intelligent education platform that combines learning resources, teacher-led classes, course management, personalized learning, and artificial intelligence into a unified learning experience.

The core idea of HIPZI is to help learners study more effectively by transforming static educational content into interactive, personalized, and AI-assisted learning experiences.

---

## 2. Product Vision

HIPZI aims to become an intelligent learning platform that helps learners:

- Discover relevant study materials by subject, grade, topic, or learning goal.
- Practice knowledge through quizzes, flashcards, and other interactive learning formats.
- Connect with suitable teachers based on subject, learning need, schedule, and teaching style.
- Receive AI support for explaining lessons, solving exercises, recommending materials, and planning learning paths.
- Join classes, online courses, and future online exams organized by teachers.

For teachers, HIPZI provides tools to upload learning materials, manage classes, support students, generate quizzes with AI, and improve the quality of teaching content.

For staff members, HIPZI provides operational tools to review teacher applications, moderate learning materials, handle reported content, and support day-to-day platform quality control.

For administrators, HIPZI provides high-level governance tools to manage users, assign roles, manage staff permissions, configure platform policies, audit moderation actions, and override operational decisions when necessary.

---

## 3. Problem Statement

Many students struggle not because learning resources are unavailable, but because they face difficulties in finding the right materials, organizing their learning process, practicing effectively, and receiving timely guidance.

Common problems include:

- Learning materials are scattered across many platforms.
- Students do not know which materials are suitable for their current level.
- Static documents are often difficult to study from without practice questions or explanations.
- Teachers spend a lot of time creating quizzes, exercises, and learning resources manually.
- Students have difficulty finding reliable teachers or classes that match their needs.
- Learning progress is often not tracked clearly.
- Existing learning platforms are either too content-focused, too teacher-focused, or lack personalization.

HIPZI addresses these problems by combining curated learning materials, teacher support, class management, and AI-powered learning assistance into one platform.

---

## 4. Target Users

HIPZI supports multiple user groups. Each group has different needs, permissions, and product goals.

### 4.1 Students

Students are the primary users of HIPZI. They use the platform to:

- Search for study materials.
- Select subjects or topics to study.
- Practice using quizzes and flashcards.
- Ask AI for help with lessons or exercises.
- Register for classes or courses.
- Track their learning progress.
- Find suitable teachers.

### 4.2 Parents

Parents use HIPZI to:

- Find suitable teachers or courses for their children.
- Explore learning resources.
- Monitor their child’s learning progress in future versions.
- Support learning decisions based on teacher quality, course information, and learning outcomes.

Parent-focused features should be considered a later-stage development priority.

### 4.3 Teachers / Lecturers

Teachers, also referred to as lecturers, use HIPZI to:

- Register as verified educators.
- Create and maintain teacher profiles.
- Upload study materials for review.
- Create quizzes, flashcards, assignments, and courses.
- Manage classes and students.
- Approve students into classes.
- Use AI to generate learning content.
- Review and edit AI-generated learning content before publishing.
- Use AI to support grading or feedback in future versions.
- Track student performance.

Teachers are primarily responsible for teaching, creating educational content, and supporting students. Teachers are separate from staff members by default. However, trusted teachers with strong performance, verified expertise, or a history of high-quality contributions may be assigned an additional Staff role by an Admin.

### 4.4 Staff

Staff members are responsible for day-to-day platform operations and content quality control. They use HIPZI to:

- Review, approve, or reject teacher applications.
- Review learning materials uploaded by teachers.
- Approve, reject, request revision, hide, or archive learning materials.
- Review reported content.
- Support content quality assurance.
- Monitor teacher and material quality indicators.
- Escalate serious policy or quality issues to Admins.

Staff members are separate from teachers by default. A user may hold both Teacher and Staff roles only when explicitly assigned by an Admin. If a user has both roles, they must not review or approve their own teacher application, materials, courses, quizzes, exams, or AI-generated learning content.

### 4.5 Admins

Admins are responsible for high-level platform governance. They use HIPZI to:

- Manage user accounts and role assignments.
- Assign or revoke Staff permissions.
- Configure platform policies.
- Manage subjects, courses, and platform-level categories.
- Audit Staff moderation actions.
- Override Staff decisions when necessary.
- Handle serious policy violations or disputes.
- Ensure the long-term quality, safety, and governance of the platform.

Admins have the highest level of authority in the platform. Staff members handle most day-to-day review and moderation workflows, while Admins govern, audit, and intervene when necessary.

---

## 5. Product Positioning

HIPZI can be positioned as:

> An intelligent learning platform that helps teachers transform study materials into interactive learning experiences with AI, while helping students discover materials, practice knowledge, and connect with suitable teachers.

HIPZI’s differentiation comes from combining four elements:

1. A structured study material repository.
2. AI-generated quizzes and learning support.
3. Teacher-led learning and class management.
4. Personalized learning guidance for students.

Instead of being only a document-sharing website, HIPZI should evolve into a learning operating system for students and teachers.

---

## 6. Core Value Proposition

HIPZI provides value through three core pillars.

### 6.1 Study Material Repository

HIPZI provides a structured repository of learning materials organized by subject, topic, grade, difficulty, teacher, and learning format.

Materials may include:

- Text documents.
- Images.
- PDF files.
- Multiple-choice questions.
- Flashcards.
- Quizzes.
- Assignments.
- Course lessons.

### 6.2 Learning and User Management

HIPZI supports multiple user roles including students, parents, teachers, staff members, and admins. The platform should support role-based access and workflows such as:

- Teacher registration and Staff-based approval.
- Student enrollment.
- Class management.
- Course management.
- Learning progress tracking.
- Staff moderation.
- Admin governance and role management.

### 6.3 AI-Powered Learning Assistance

AI is a core component of HIPZI. It should support both learners and teachers.

For students, AI can:

- Explain difficult concepts.
- Guide exercise solving.
- Recommend learning materials.
- Suggest teachers or courses.
- Generate personalized learning paths.
- Support quiz-based practice.

For teachers, AI can:

- Generate quizzes from uploaded materials.
- Create flashcards.
- Summarize documents.
- Generate practice questions.
- Support grading and feedback in future versions.
- Analyze common student mistakes.

---

## 7. Product Goals

### 7.1 Short-Term Goals

The short-term goal is to build a usable MVP focused on study materials and AI-generated practice.

The MVP should allow:

- Students to browse and study materials.
- Teachers to upload learning materials.
- Staff members to review teacher applications and moderate uploaded materials.
- AI to generate quizzes or flashcards from uploaded content.
- Teachers to review AI-generated quizzes or flashcards before publishing.
- Students to practice using generated quizzes or flashcards.
- Staff and Admins to organize official HIPZI Exams with XP rewards.
- Admins to manage roles, audit moderation actions, and override decisions when necessary.

### 7.2 Mid-Term Goals

The mid-term goal is to expand HIPZI into a basic learning management platform.

This includes:

- Teacher profiles.
- Class creation.
- Student enrollment.
- Teacher approval of students.
- Learning progress tracking.
- Course structure.
- Assignment management.
- Teacher dashboard.

### 7.3 Long-Term Goals

The long-term goal is to build HIPZI into a full AI-powered education ecosystem.

This includes:

- AI tutors by subject.
- Personalized learning paths.
- Online courses.
- Online exams.
- AI-assisted grading.
- Parent dashboard.
- Marketplace for teachers and courses.
- Monetization through subscriptions, commissions, or premium learning tools.

---

## 8. MVP Scope

### 8.1 MVP Objective

The MVP should validate the core learning workflow:

> Teacher uploads learning material → Staff reviews and approves content → AI generates quizzes or flashcards → Teacher reviews AI-generated content → Student practices → Platform tracks learning activity → Staff and Admins govern content quality.

This workflow should be the foundation of HIPZI.

### 8.2 MVP Features

The first version of HIPZI should include the following features.

#### 8.2.1 User Authentication and Role Management

- Users can register and log in.
- Users can have roles: Student, Parent, Teacher, Staff, and Admin.
- Teachers and Staff are separate roles by default.
- A user may hold multiple roles only when explicitly assigned by an Admin.
- Role-based permissions should control access to features.

#### 8.2.2 Subject Management

- Admins can create and manage subjects.
- Materials should be categorized by subject.
- Students can browse materials by subject.

#### 8.2.3 Teacher Registration

- Users can register as teachers.
- Teacher registration may require additional information.
- Staff members can review, approve, or reject teacher applications according to platform policy.
- Admins can audit, override, or manage Staff permissions when necessary.

#### 8.2.4 Material Upload

- Approved teachers can upload study materials.
- Materials can include text, images, or documents.
- Materials must be associated with a subject.
- Uploaded materials should have a status such as pending, approved, or rejected.

#### 8.2.5 Material Browsing

- Students can browse approved materials.
- Students can view material details.
- Students can search or filter materials by subject.

#### 8.2.6 AI Quiz and Flashcard Generation

- Teachers can use AI to generate quizzes or flashcards from uploaded materials.
- AI-generated content should be editable by teachers before publishing.
- Generated quizzes should include questions, answer options, correct answers, and explanations where possible.

#### 8.2.7 Mock Exams & Courses

- Students can participate in Mock Exams (Multiple choice, Flashcard, Essay) in the Exam Room.
- Students can purchase and enroll in Courses using their internal Wallet Balance.
- The system stores exam attempts, essay submissions, and wallet transaction history.

#### 8.2.8 Staff Moderation

- Staff members can review teacher applications.
- Staff members can approve or reject teacher applications.
- Staff members can review uploaded learning materials.
- Staff members can approve, reject, request revision, hide, or archive materials.
- Staff members can manage reported content in future versions.

#### 8.2.9 Admin Governance

- Admins can manage user roles and permissions.
- Admins can assign or revoke Staff permissions.
- Admins can audit Staff moderation actions.
- Admins can override Staff decisions when necessary.
- Admins can handle serious policy violations or disputes.

---

## 9. Out of Scope for MVP

The following features should not be included in the initial MVP unless necessary:

- Full online exam system.
- AI grading for complex written answers.
- Parent dashboard.
- Built-in video classroom.
- Payment system.
- Teacher marketplace monetization.
- Advanced anti-cheating system.
- Full course builder.
- Mobile application.
- Complex analytics dashboard.

These features can be considered in later development phases after the core learning workflow is validated.

---

## 10. Key User Journeys

### 10.1 Student Learning Journey

1. Student registers or logs in.
2. Student selects a subject.
3. Student browses available materials.
4. Student opens a material.
5. Student practices using quiz or flashcard.
6. Student receives score, feedback, or explanation.
7. Student continues learning or saves material for later.

### 10.2 Teacher Content Creation Journey

1. Teacher registers an account.
2. Teacher submits teacher profile for review.
3. Staff reviews and approves or rejects the teacher application.
4. Approved teacher uploads study material.
5. Staff reviews and approves, rejects, or requests revision for the uploaded material.
6. Teacher uses AI to generate quiz or flashcard from approved or draft material.
7. Teacher reviews and edits AI-generated content.
8. Teacher submits or publishes the learning content according to platform moderation policy.
9. Students use the approved content for learning.

### 10.3 Staff Moderation Journey

1. Staff member logs into the moderation dashboard.
2. Staff member reviews teacher applications.
3. Staff member approves or rejects teacher applications.
4. Staff member reviews uploaded learning materials.
5. Staff member approves, rejects, requests revision, hides, or archives materials.
6. Staff member reviews reported content when available.
7. Staff member escalates serious issues to Admins when necessary.

### 10.4 Admin Governance Journey

1. Admin logs into the admin dashboard.
2. Admin manages users, roles, and permissions.
3. Admin assigns or revokes Staff permissions.
4. Admin reviews moderation logs or escalated issues.
5. Admin overrides Staff decisions when necessary.
6. Admin monitors platform quality and governance.

---

## 11. Future Development Opportunities

HIPZI can be expanded in several directions after the MVP.

### 11.1 Personalized Learning Path

Students can enter their goals, current level, and available study time. HIPZI can generate a personalized learning path.

Example goals:

- Recover from weak math foundation in two months.
- Prepare for a final exam in three weeks.
- Learn basic English communication in thirty days.
- Review programming fundamentals for university courses.

### 11.2 Study Plan and Timetable

HIPZI can provide study planning tools that allow learners to:

- Set learning goals.
- Create weekly or monthly study plans.
- Receive study reminders.
- Track completion.
- Adjust plans automatically when progress is delayed.

### 11.3 Progress Tracking

HIPZI can track:

- Number of materials studied.
- Quiz completion rate.
- Accuracy rate.
- Weak subjects or topics.
- Learning streak.
- Practice history.
- Class-level learning progress for teachers.

### 11.4 Smart Search

HIPZI can provide intelligent search across materials, subjects, quizzes, teachers, and courses.

Users should be able to search using natural language queries such as:

- “Easy derivative exercises with explanations.”
- “CSD201 final exam review materials.”
- “Basic English grammar flashcards.”

### 11.5 AI Tutor by Subject

HIPZI can develop subject-specific AI tutors such as:

- Math AI Tutor.
- English AI Tutor.
- Programming AI Tutor.
- Physics AI Tutor.
- Chemistry AI Tutor.

Each AI tutor should be optimized for the learning style of its subject.

### 11.6 AI Explanation Assistant

Students can select a question, paragraph, or document section and ask AI to explain it in different formats:

- Simple explanation.
- Step-by-step explanation.
- Short summary.
- Real-world example.
- Advanced explanation.
- Similar practice questions.

### 11.7 Teacher Dashboard

Teachers can access a dashboard showing:

- Uploaded materials.
- Classes managed.
- Pending student approvals.
- Student quiz performance.
- Commonly missed questions.
- Learning activity.
- AI suggestions for improving teaching materials.

### 11.8 Course Builder

Teachers can create structured courses using the following hierarchy:

- Course
  - Module
    - Lesson
      - Material
      - Quiz
      - Assignment

This would allow HIPZI to evolve from a material platform into a full learning management system.

### 11.9 Community and Q&A

HIPZI can support discussion and community learning through:

- Subject-based Q&A.
- Comments under materials.
- Class discussions.
- Study groups.
- AI-supported answers.
- Teacher-verified answers.

This feature can increase user engagement and create a stronger learning community around the platform.

### 11.10 Gamification

HIPZI can improve motivation through:

- Learning points.
- Badges.
- Streaks.
- Daily missions.
- Leaderboards.
- Achievement records.

Gamification should support learning outcomes and should not become the main focus of the product.

### 11.11 Rating and Review System

HIPZI can allow users to review and rate:

- Study materials.
- Quizzes.
- Flashcards.
- Teachers.
- Courses.
- Classes.

This helps learners identify high-quality content and helps the platform maintain trust.

### 11.12 Assignment Management

HIPZI can support teacher-created assignments.

This may include:

- Assignment creation.
- Assignment deadlines.
- Student submissions.
- Teacher feedback.
- Score tracking.
- AI-assisted feedback in future versions.

### 11.13 AI Teaching Assistant

HIPZI can provide an AI assistant for teachers.

The AI Teaching Assistant can help teachers:

- Summarize documents.
- Generate review questions.
- Create practice exercises.
- Create exam questions.
- Analyze common student mistakes.
- Suggest improvements to teaching materials.
- Support grading and feedback in future versions.

### 11.14 Online Exams

HIPZI can support online exams in later phases.

This may include:

- Exam creation.
- Question banks.
- Timed exams.
- Student submissions.
- Automatic grading for objective questions.
- AI-assisted grading for written responses in future versions.
- Result analytics.

Online exams should be developed carefully due to concerns around cheating prevention, grading accuracy, and platform reliability.

### 11.15 Parent Dashboard

HIPZI can provide a parent dashboard in later versions.

Parents may be able to:

- View student learning progress.
- View completed materials.
- View quiz performance.
- View teacher or class information.
- Receive learning summaries.

This feature should be added only after the student and teacher workflows are stable.

---

## 12. Monetization Opportunities

HIPZI can explore monetization after the product has active users and validated demand.

### 12.1 Freemium Model

Free users may access:

- Basic materials.
- Limited quizzes.
- Limited AI usage.

Premium users may access:

- More AI Tutor usage.
- Advanced materials.
- Personalized learning paths.
- Detailed learning analytics.
- Premium courses.

### 12.2 Teacher Marketplace Commission

HIPZI can charge a commission when students register for paid classes or courses through the platform.

### 12.3 Teacher Subscription

Teachers can pay for advanced tools such as:

- More AI-generated quizzes.
- More class capacity.
- Advanced teacher dashboard.
- Profile promotion.
- Student analytics.

---

## 13. Success Metrics

The success of HIPZI should be measured through both learning engagement and platform growth.

### 13.1 User Metrics

- Number of registered students.
- Number of registered teachers.
- Number of approved teachers.
- Number of active staff members.
- Number of active students per week.
- Number of returning users.

### 13.2 Content Metrics

- Number of uploaded materials.
- Number of approved materials.
- Number of AI-generated quizzes.
- Number of published flashcards.
- Number of subjects covered.

### 13.3 Learning Metrics

- Number of completed quizzes.
- Average quiz completion rate.
- Average score improvement.
- Number of materials completed per student.
- Learning streaks.

### 13.4 Platform Quality Metrics

- Teacher approval rate.
- Material rejection rate.
- User report rate.
- Average material rating.
- Average teacher rating.
- Staff moderation completion rate.
- Average teacher application review time.
- Average material review time.
- Number of moderation decisions overridden by Admins.

---

## 14. Key Risks

### 14.1 Scope Creep

HIPZI has potential to become very large. Building too many features too early may slow development and reduce product quality.

Mitigation:

- Focus the MVP on study materials, AI quiz generation, student practice, teacher upload, Staff moderation, and Admin governance.
- Defer online exams, payments, parent dashboard, and advanced AI grading.

### 14.2 Content Quality

If teachers upload low-quality materials, users may lose trust in the platform.

Mitigation:

- Add Staff-based content moderation.
- Use teacher verification.
- Add rating and reporting systems.
- Allow AI-assisted content quality checks in later versions.
- Allow Admins to audit and override Staff moderation decisions when necessary.

### 14.3 AI Accuracy

AI-generated quizzes, explanations, or grading may contain errors.

Mitigation:

- Require teacher review before publishing AI-generated educational content.
- Show AI-generated content as assistive, not authoritative.
- Provide correction and reporting mechanisms.

### 14.4 Teacher Trust and Verification

The platform depends on the quality and credibility of teachers.

Mitigation:

- Require teacher profile verification.
- Require Staff review and approval for teacher applications.
- Add student reviews and ratings.
- Track teacher performance over time.
- Allow Admins to audit teacher approval decisions and revoke teacher or Staff privileges when necessary.

### 14.5 Learning Engagement

Students may register but not continue learning.

Mitigation:

- Add progress tracking.
- Add study plans.
- Add reminders.
- Use gamification carefully.
- Recommend next learning actions.

---

## 15. Development Roadmap

### 15.1 Phase 1: MVP — Study Materials and AI Quiz Generation

Focus:

- Authentication and role management.
- Subject management.
- Teacher application and Staff approval.
- Teacher material upload.
- Staff material moderation.
- Student material browsing.
- AI quiz and flashcard generation.
- Teacher review of AI-generated content.
- Mock Exams (Multiple Choice, Flashcard, Essay).
- Course browsing and enrollment.
- Internal Wallet Balance and transactions.
- Admin governance and role management.

### 15.2 Phase 2: Teacher and Class Management

Focus:

- Teacher profiles.
- Student enrollment.
- Class creation.
- Teacher approval of students.
- Basic class dashboard.
- Basic progress tracking.

### 15.3 Phase 3: Personalization and AI Tutor

Focus:

- AI Tutor by subject.
- Personalized learning path.
- Study plan.
- Smart search.
- Learning recommendations.

### 15.4 Phase 4: Community & Advanced Features

Focus:

- Course builder (Advanced drag-and-drop).
- Assignment management.
- Study groups.
- Discussion and Q&A.
- Rating and review system.
- Gamification.

### 15.5 Phase 5: Advanced Education Ecosystem

Focus:

- Full-scale Online exams (Proctoring/Anti-cheat).
- AI-assisted grading.
- Parent dashboard.
- Advanced Payment system (Stripe/PayPal integrations).
- Teacher marketplace.
- Advanced analytics.

---

## Product Language

HIPZI’s user-facing website content must be written in Vietnamese for the MVP.

This includes:

- Landing page content
- Navigation labels
- Buttons
- Forms
- Validation messages
- Empty states
- Error states
- Status labels
- Dashboard copy
- Student learning content interface
- Teacher workflow messages
- Staff moderation messages
- Admin interface labels

Technical documentation may remain in English, but the actual user-facing product interface should be Vietnamese.

## 16. Conclusion

HIPZI is an AI-powered EdTech platform with the potential to become a full learning ecosystem. However, the initial product should remain focused and practical.

The first version should validate the most important workflow:

> Teacher uploads learning materials → Staff reviews and approves content → AI generates quiz or flashcards → Teacher reviews AI-generated content → Student practices → Platform tracks basic learning activity → Staff and Admins govern content quality.

If this workflow works well, HIPZI can gradually expand into teacher-led classes, personalized learning paths, online courses, AI tutors, online exams, and a teacher marketplace.

The product should prioritize learning effectiveness, content quality, and user trust before expanding into advanced features.