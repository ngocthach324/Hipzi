# Use Case Specification Document

**HIPZI Platform – Team 3**

## 1. Document Information
- **Võ Hồ Uyển Nhi** (Member) - DE200021
- **Phạm Đức Truyền** (Member) - DE201131
- **Văn Viết Nhật** (Member) - DE200475
- **Nguyễn Văn Nguyên** (Member) - DE200017
- **Nguyễn Ngọc Thạch** (Member) - DE200063

*Note: This document has been migrated to Markdown and updated to reflect the new MVP Phase 1 scope (Mock Exams, HIPZI Exams, Courses, and Wallet).*

---

## UC-01: System Login
**Summary:** Allows registered users to securely log into the HIPZI platform and access their respective workspace based on their assigned role.
- **Priority:** 5
- **Preconditions:** The user must already possess a valid, registered account.
- **Postconditions:** The user is successfully authenticated and redirected to their designated dashboard/workspace.
- **Primary Actor(s):** Student, Teacher, Staff, Admin
- **Secondary Actor(s):** Google Authentication API
- **Trigger:** The user navigates to the HIPZI Login page and initiates a login attempt.

**Main Scenario:**
1. The user navigates to the HIPZI Login page.
2. The user enters their registered Email and Password.
3. The user clicks the "Login" button.
4. The system validates the credentials against the database and identifies the user's role.
5. The system redirects the user to the corresponding interface.

**Extensions:**
- **Alt 1:** Login via Google: At step 2, the user selects "Sign in with Google" → System invokes API → Success → Step 5.
- **Exc 1:** Incorrect Credentials: At step 4, if mismatch → System displays: "Invalid email or password".
- **Exc 2:** Account Banned: At step 4, if account is suspended → System rejects login with an alert.

---

## UC-02: Upload Learning Document
**Summary:** Allows validated teachers to upload new learning materials and categorize them under a specific subject in a pending state.
- **Priority:** 4
- **Primary Actor(s):** Teacher
- **Main Scenario:**
  1. Teacher selects "Upload New Document".
  2. Teacher enters metadata (Title, Description, Subject).
  3. Teacher uploads the file (PDF/Word).
  4. Teacher clicks "Submit for Review".
  5. System saves document with "Pending" status.
  6. System displays success message.

---

## UC-03: Moderate Learning Document
**Summary:** Staff reviews documents in the "Pending" queue to either approve them for public release or reject them with constructive feedback.
- **Priority:** 4
- **Primary Actor(s):** Staff
- **Main Scenario:**
  1. Staff opens the "Pending Documents" list.
  2. Staff selects a document to inspect.
  3. Staff verifies the content and clicks "Approve".
  4. System updates status to Approved.
  5. System notifies Teacher and publishes the document.

---

## UC-04: Take Mock Exam (Updated from Practice Quiz)
**Summary:** Students select a Mock Exam (Thi thử) to test their knowledge, obtain a grade, and view rationales.
- **Priority:** 5
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student navigates to the Exam Room and selects a Mock Exam.
  2. System renders the interactive exam interface with a timer.
  3. Student submits the exam.
  4. System computes the final score.
  5. System displays the Results Screen (score, accuracy, explanations).
  6. System saves the attempt to the student's history.

---

## UC-05: Study with Flashcards
**Summary:** Students interact with a digital flashcard deck to review terms and definitions.
- **Priority:** 4
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student selects "Study Flashcards".
  2. System displays the front face of the first card.
  3. Student clicks to "Flip".
  4. System reveals the back face.
  5. Student evaluates retention ("Still Learning" or "Know").
  6. System loads the next card and records progress.

---

## UC-06: AI Automated Content Generation
**Summary:** Teachers prompt the built-in AI Engine to scan an uploaded document and generate draft Quizzes or Flashcards.
- **Priority:** 3
- **Primary Actor(s):** Teacher
- **Secondary Actor(s):** LLM API
- **Main Scenario:**
  1. Teacher clicks "Generate AI Smart Study Tools" on an uploaded file.
  2. System opens configuration panel.
  3. Teacher sets config and clicks "Generate".
  4. System sends text to AI and receives JSON payload.
  5. System renders generated items as Draft.
  6. Teacher audits, edits, and clicks "Confirm and Publish".

---

## UC-07: Create and Manage HIPZI Exams (New)
**Summary:** Staff or Admins create official, proctored HIPZI Exams that offer XP rewards to participants.
- **Priority:** 4
- **Primary Actor(s):** Staff, Admin
- **Main Scenario:**
  1. Staff navigates to HIPZI Exam Management.
  2. Staff creates a new Exam (Title, Time, Duration, XP Reward).
  3. Staff adds or imports questions.
  4. Staff publishes the exam.
  5. System schedules the exam to appear in the public Exam Room.

---

## UC-08: Participate in HIPZI Exam (New)
**Summary:** Students participate in official HIPZI Exams to compete on the leaderboard and earn XP.
- **Priority:** 4
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student navigates to "Kỳ thi HIPZI" section and clicks "Join".
  2. System verifies if the exam is currently active.
  3. Student completes the exam under strict time limits.
  4. System scores the exam and updates the Leaderboard.
  5. System automatically awards the specified XP to the Student's profile.

---

## UC-09: Create E-Learning Course (New)
**Summary:** Approved Teachers create structured e-learning courses (Modules, Lessons) and set a price.
- **Priority:** 4
- **Primary Actor(s):** Teacher
- **Main Scenario:**
  1. Teacher navigates to Course Management and creates a new Course.
  2. Teacher defines Course structure and price.
  3. Teacher submits the Course for Staff review.
  4. Staff approves the Course.
  5. System lists the Course publicly.

---

## UC-10: Purchase Course via Wallet (New)
**Summary:** Students use their internal Wallet balance to purchase and unlock a premium Course.
- **Priority:** 5
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student clicks "Purchase" on a Course details page.
  2. System checks the Student's wallet balance.
  3. If sufficient, the system deducts the amount and creates a transaction record.
  4. System grants the Student access to the Course content.
  5. (Future) System credits the Teacher's wallet revenue.

---

## UC-11: Create Classroom Assignment / Quiz
**Summary:** Teachers create assignments (homework requiring file upload) or multiple-choice quizzes within a specific Classroom.
- **Priority:** 3
- **Primary Actor(s):** Teacher
- **Main Scenario:**
  1. Teacher navigates to a specific Classroom they manage.
  2. Teacher selects "Create Assignment" or "Create Quiz".
  3. Teacher fills in the details (Title, Description, Due Date, Points).
  4. (For Quiz) Teacher adds multiple-choice questions; (For Assignment) Teacher attaches instruction files.
  5. Teacher clicks "Publish".
  6. System saves the assignment/quiz and notifies enrolled students.

---

## UC-12: Submit Classroom Assignment / Quiz
**Summary:** Students view and submit their homework files or complete multiple-choice quizzes assigned in their Classroom.
- **Priority:** 3
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student accesses the Classroom and selects a pending Assignment or Quiz.
  2. (For Quiz) Student answers the questions and clicks "Submit"; (For Assignment) Student uploads their homework file (PDF/Word/Image) and clicks "Turn In".
  3. System records the submission time and marks it as Submitted.
  4. System (if it's an objective Quiz) auto-grades the submission, or (if it's an Assignment) updates the status to "Pending Grading" for the Teacher.

---

## UC-13: Register Account
**Summary:** New users create an account on the HIPZI platform to access its features.
- **Priority:** 5
- **Primary Actor(s):** Guest
- **Main Scenario:**
  1. Guest navigates to the Registration page.
  2. Guest enters details (Name, Email, Password) or uses Google OAuth.
  3. System verifies data and creates an account with default "Student" role.
  4. System sends a verification email (or auto-verifies via Google).
  5. User is logged in and redirected to the dashboard.

---

## UC-14: Apply for Teacher Role
**Summary:** Registered users submit an application with credentials to become verified Teachers.
- **Priority:** 5
- **Primary Actor(s):** Student (or standard user)
- **Main Scenario:**
  1. User navigates to the "Become a Teacher" section.
  2. User uploads credentials (degrees, certificates, identity proof).
  3. User submits the application.
  4. System saves the application with "Pending" status and notifies Staff.

---

## UC-15: Moderate Teacher Application
**Summary:** Staff or Admins review and approve/reject teacher applications.
- **Priority:** 5
- **Primary Actor(s):** Staff, Admin
- **Main Scenario:**
  1. Staff accesses the "Teacher Applications" queue.
  2. Staff reviews the submitted credentials.
  3. Staff clicks "Approve" (or "Reject" with reason).
  4. System updates the user's role to "Teacher" and notifies them.

---

## UC-16: Browse and Search Learning Materials
**Summary:** Students search, filter, and access approved study materials from the public repository.
- **Priority:** 5
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student navigates to the "Material Repository".
  2. Student enters a keyword or selects a Subject/Category filter.
  3. System displays a list of approved, visible materials matching the criteria.
  4. Student clicks on a material to view details or download it.

---

## UC-17: Create and Manage Classroom
**Summary:** Teachers create virtual classrooms to organize students, materials, and assignments.
- **Priority:** 4
- **Primary Actor(s):** Teacher
- **Main Scenario:**
  1. Teacher navigates to the "Classrooms" section and clicks "Create Classroom".
  2. Teacher enters Classroom name, subject, and description.
  3. System generates a unique invite code/link.
  4. Teacher shares the code with students or manages join requests.

---

## UC-18: Enroll in Classroom
**Summary:** Students join a Teacher's classroom using an invite code or by requesting access.
- **Priority:** 4
- **Primary Actor(s):** Student
- **Main Scenario:**
  1. Student navigates to the "Classrooms" section and clicks "Join Class".
  2. Student enters the class code provided by the Teacher.
  3. System verifies the code and adds the Student to the classroom (or sets status to "Pending Approval").
  4. Student can now access classroom-specific materials and assignments.

---

## UC-19: Grade Classroom Assignment
**Summary:** Teachers review student homework submissions, provide feedback, and assign scores.
- **Priority:** 4
- **Primary Actor(s):** Teacher
- **Main Scenario:**
  1. Teacher opens a Classroom Assignment and views the list of submissions.
  2. Teacher selects a student's submission (e.g., uploaded PDF).
  3. Teacher reviews the work, enters a score, and types feedback.
  4. Teacher clicks "Return/Grade".
  5. System updates the student's grade and sends a notification.

---

## UC-20: Deposit to Wallet
**Summary:** Users top up their internal Wallet balance to purchase courses.
- **Priority:** 4
- **Primary Actor(s):** Student, Parent
- **Main Scenario:**
  1. User navigates to the "Wallet" section and selects "Deposit".
  2. User enters the amount and chooses a payment method (e.g., Bank Transfer, VNPay).
  3. User completes the transaction via the payment gateway.
  4. System verifies the payment and adds the funds to the user's `wallet_balance`.

---

## UC-21: Manage User Roles and System Governance
**Summary:** Admins manage the entire platform, assigning Staff roles, managing subjects, and overriding decisions.
- **Priority:** 5
- **Primary Actor(s):** Admin
- **Main Scenario:**
  1. Admin accesses the Admin Dashboard.
  2. Admin navigates to User Management to assign/revoke Staff or Teacher roles.
  3. Admin navigates to Subject Management to add/edit categories.
  4. System applies these platform-wide changes immediately.
