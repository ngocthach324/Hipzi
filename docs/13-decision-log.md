# HIPZI Decision Log

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | Decision Log |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md, 07-system-architecture.md, 08-database-design.md, 09-api-design.md, 10-non-functional-requirements.md, 11-tech-plan.md, 12-testing-strategy.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, System Architect, Backend Engineer, Frontend Engineer, QA Engineer |
| Language | English |

---

## 1. Purpose

This document records important product, business, architecture, and technical decisions made during the design and development of HIPZI.

The purpose of this document is to preserve the reasoning behind major decisions so that future developers, AI coding agents, reviewers, and stakeholders can understand why the system is designed in a specific way.

This document helps prevent confusion when the project grows, especially when new features, technical changes, or architectural changes are introduced.

This document should be updated whenever HIPZI makes an important decision that affects:

- Product direction.
- User roles.
- Business rules.
- System architecture.
- Database design.
- API design.
- Technology stack.
- AI workflow.
- Moderation workflow.
- Security rules.
- Testing strategy.
- UI/UX direction.
- Future scalability.

---

## 2. Decision Log Principles

The decision log should follow these principles:

- Record important decisions clearly.
- Explain why the decision was made.
- Describe the impact of the decision.
- Mention alternatives when relevant.
- Keep decisions traceable to related documents.
- Update the decision status when the decision changes.
- Avoid recording every small implementation detail.
- Focus on decisions that affect system behavior, architecture, or long-term maintainability.

---

## 3. Decision Status Definitions

| Status | Meaning |
|---|---|
| Proposed | The decision is being considered but has not been finalized |
| Accepted | The decision is approved and should be followed |
| Rejected | The decision was considered but not selected |
| Superseded | The decision was replaced by a newer decision |
| Deprecated | The decision is no longer recommended but may still exist in old implementation |

---

## 4. Decision Record Format

Each decision should use the following format:

| Field | Description |
|---|---|
| Decision ID | Stable identifier for the decision |
| Title | Short decision title |
| Status | Proposed, Accepted, Rejected, Superseded, or Deprecated |
| Date | Date when the decision was made or last updated |
| Context | Problem or situation that required a decision |
| Decision | The selected decision |
| Reason | Why this decision was made |
| Alternatives Considered | Other possible options |
| Impact | Effects on product, architecture, implementation, or future work |
| Related Documents | Documents connected to this decision |

---

## 5. Decision Summary

| Decision ID | Title | Status |
|---|---|---|
| DEC-001 | Use Modular Monolith Architecture for MVP | Accepted |
| DEC-002 | Use JSP for Frontend Rendering | Accepted |
| DEC-003 | Use Java Servlet MVC with Service Layer for Backend | Accepted |
| DEC-004 | Separate Teacher and Staff Roles | Accepted |
| DEC-005 | Allow Trusted Teachers to Also Receive Staff Role | Accepted |
| DEC-006 | Prevent Staff Self-Review | Accepted |
| DEC-007 | Staff Reviews Teacher Applications | Accepted |
| DEC-008 | Staff Reviews Teacher-Uploaded Materials | Accepted |
| DEC-009 | Admin Manages Roles and Governance | Accepted |
| DEC-010 | AI-Generated Content Starts as Draft | Accepted |
| DEC-011 | Teacher Review Is Required Before AI Content Reaches Students | Accepted |
| DEC-012 | Student-Facing Content Must Be Approved and Visible | Accepted |
| DEC-013 | Use Relational Database as Primary Database | Accepted |
| DEC-014 | Use Service Layer for Business Rules | Accepted |
| DEC-015 | Use DAO Layer for Database Access | Accepted |
| DEC-016 | Use Session-Based Authentication for JSP/Servlet MVP | Accepted |
| DEC-017 | Use Audit Logs for Important Staff and Admin Actions | Accepted |
| DEC-018 | Integrate Mock Exams, Courses, and Wallet Features into Phase 1 | Superseded |
| DEC-019 | Keep AI Recommendations as Phase 2 Scope | Accepted |
| DEC-020 | Keep UI/UX Design as a Separate Document | Accepted |

---

## 6. Product and Architecture Decisions

### DEC-001: Use Modular Monolith Architecture for MVP

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 07-system-architecture.md, 10-non-functional-requirements.md, 11-tech-plan.md |

#### Context

HIPZI contains many modules, including authentication, roles, teacher applications, Staff moderation, Admin governance, learning materials, AI content generation, quizzes, flashcards, search, and future personalization.

A decision was needed on whether to start with a monolithic architecture, modular monolith, or microservices.

#### Decision

HIPZI will start with a modular monolith architecture for the MVP.

The application will be deployed as one main Java web application, but internally organized into clear modules.

#### Reason

A modular monolith is suitable because:

- HIPZI is still in the MVP stage.
- The product requirements may continue to evolve.
- The project should avoid premature infrastructure complexity.
- The team can develop faster.
- Data consistency is easier to maintain.
- JSP and Servlet MVC fit naturally with a modular monolith.
- AI coding agents can understand and modify the codebase more easily when modules are organized clearly.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Simple unstructured monolith | Too risky because business logic may become messy and hard to maintain |
| Microservices | Too complex for MVP and unnecessary before scale is proven |
| Serverless-first architecture | Not aligned with the selected JSP/Servlet technical direction |

#### Impact

- The project should be organized by modules.
- Business rules should be centralized in Services.
- Database access should be isolated in DAOs.
- Future service extraction remains possible.
- The MVP can be built faster and maintained more easily.

---

### DEC-002: Use JSP for Frontend Rendering

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 11-tech-plan.md, 14-ui-ux-design.md |

#### Context

HIPZI needs a frontend implementation approach for the MVP. The project direction is based on Java web development using Servlet and MVC.

#### Decision

HIPZI will use JSP for frontend rendering in the MVP.

JSP will be used for:

- Login and registration pages.
- Student dashboard.
- Teacher dashboard.
- Staff moderation dashboard.
- Admin governance dashboard.
- Material pages.
- Quiz practice pages.
- Flashcard practice pages.
- AI content review pages.

#### Reason

JSP is selected because:

- It fits the Java Servlet MVC model.
- It supports server-side rendering.
- It is suitable for a Java web application learning and implementation direction.
- It reduces the need for a separate frontend framework in the MVP.
- It keeps the project stack consistent.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| React | More frontend complexity and not aligned with the selected JSP direction |
| Vue | Additional frontend stack and build process |
| Static HTML only | Not suitable for dynamic user-specific pages |
| Full SPA architecture | Unnecessary for MVP |

#### Impact

- JSP files should focus only on rendering.
- JSP should not contain business logic.
- JSP should not query the database directly.
- Reusable JSP layouts and fragments should be used.
- JavaScript should be used only for interaction enhancement, not core security logic.

---

### DEC-003: Use Java Servlet MVC with Service Layer for Backend

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 07-system-architecture.md, 09-api-design.md, 11-tech-plan.md |

#### Context

HIPZI needs a backend architecture that supports role-based access, workflow rules, database operations, AI integration, and JSP rendering.

#### Decision

HIPZI will use Java Servlet with MVC architecture and a Service Layer.

Recommended flow:

    JSP View
    → Servlet Controller
    → Service Layer
    → DAO Layer
    → Database

#### Reason

This approach is selected because:

- It fits the selected Java web stack.
- It separates request handling from business logic.
- It keeps JSP files focused on rendering.
- It keeps database access separate from Servlets.
- It allows business rules to be centralized in Services.
- It is easier to test Services than large Servlets.
- It supports maintainability for AI coding agents.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Servlet with logic directly inside controllers | Too difficult to maintain and test |
| JSP with embedded business logic | Unsafe and hard to scale |
| Spring MVC | More powerful, but not aligned with the current requirement to use standard Servlet |
| Node.js backend | Not aligned with the selected Java Servlet direction |

#### Impact

- Servlets should remain thin.
- Services should enforce business rules.
- DAOs should handle database access.
- Models and DTOs should keep data structured.
- Filters should handle authentication and route-level authorization.

---

## 7. Role and Governance Decisions

### DEC-004: Separate Teacher and Staff Roles

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 03-functional-requirements.md, 07-system-architecture.md |

#### Context

HIPZI needs both content creators and content reviewers.

A decision was needed on whether Teachers should automatically act as Staff, or whether Staff should be a separate operational role.

#### Decision

Teacher and Staff roles will be separate by default.

A Teacher does not automatically become Staff.

A Staff member does not automatically become Teacher.

#### Reason

This decision is important because:

- Teachers are content creators.
- Staff are platform moderators.
- Moderation should be independent from content creation.
- Platform trust depends on clear review boundaries.
- It prevents Teachers from automatically approving their own content.
- It keeps operational moderation separate from teaching activity.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Every Teacher is also Staff | Creates conflict of interest |
| Staff and Teacher are the same role | Makes moderation unclear |
| Admin reviews everything | Too much workload for Admin |

#### Impact

- Teacher tools and Staff tools must be separated.
- Staff dashboard should require Staff role.
- Teacher dashboard should require Teacher role.
- Backend authorization must enforce this separation.

---

### DEC-005: Allow Trusted Teachers to Also Receive Staff Role

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 07-system-architecture.md, 09-api-design.md |

#### Context

Some Teachers may become trusted contributors over time and may help moderate platform content.

A decision was needed on whether a Teacher can also become Staff.

#### Decision

HIPZI will allow trusted Teachers to also receive Staff role, but only through explicit Admin assignment.

#### Reason

This decision supports platform growth because:

- Experienced Teachers can help maintain content quality.
- Staff capacity can grow without creating a completely separate team.
- Admin can selectively assign Staff permission to trusted Teachers.
- The system remains flexible for real-world operations.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Never allow Teachers to become Staff | Too restrictive for future platform operations |
| Automatically promote Teachers to Staff | Unsafe and may cause conflict of interest |
| Allow Teachers to self-request Staff role without Admin approval | Too risky |

#### Impact

- Users may hold multiple roles.
- Admin role assignment APIs must support multi-role users.
- Staff self-review prevention must always remain active.
- Teacher + Staff users must not review their own content.

---

### DEC-006: Prevent Staff Self-Review

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 05-acceptance-criteria.md, 06-edge-cases.md, 10-non-functional-requirements.md |

#### Context

If a user has both Teacher and Staff roles, they may own content and also have moderation permissions.

A decision was needed on whether the system should allow the same user to approve their own application or content.

#### Decision

HIPZI will prevent Staff members from reviewing or approving their own content or applications.

#### Reason

This decision is necessary because:

- Self-review creates conflict of interest.
- Platform trust depends on independent moderation.
- Staff moderation must remain credible.
- Teacher + Staff users should not bypass quality control.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Allow self-review for trusted Teachers | Weakens moderation trust |
| Allow self-review but log it | Logging does not remove the conflict |
| Require Admin review for all Teacher + Staff content | Too heavy for normal operations |

#### Impact

The backend must block self-review for:

- Teacher applications.
- Uploaded materials.
- AI-generated content if Staff review is required.
- Courses in future phases.
- Exams in future phases.

Self-review block should create an audit log.

---

### DEC-007: Staff Reviews Teacher Applications

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md |

#### Context

Users may apply to become Teachers on HIPZI.

A decision was needed on who should review and approve Teacher applications.

#### Decision

Staff will review Teacher applications.

#### Reason

This decision is selected because:

- Teacher approval is an operational review process.
- Staff can handle daily application review.
- Admin should focus on governance, not every operational review.
- It separates platform operations from high-level administration.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Admin reviews all Teacher applications | Not scalable |
| Teacher applications are auto-approved | Unsafe and reduces platform trust |
| Existing Teachers approve new Teachers | May create quality and conflict issues |

#### Impact

- Staff dashboard must include a Teacher application review queue.
- Staff can approve or reject applications.
- Approved applicants receive Teacher permissions.
- Rejected applicants do not receive Teacher permissions.
- Staff review actions should be logged.

---

### DEC-008: Staff Reviews Teacher-Uploaded Materials

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md |

#### Context

Teachers can upload learning materials. HIPZI needs a quality control process before Students access those materials.

#### Decision

Staff will review Teacher-uploaded materials before they become visible to Students.

#### Reason

This decision is necessary because:

- Students should access only reviewed content.
- Uploaded materials may be incomplete, low quality, or inappropriate.
- Staff moderation protects platform quality.
- Teachers should not directly publish content to Students without review in the MVP workflow.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Auto-publish all Teacher materials | Unsafe for learning quality |
| Admin reviews all materials | Not scalable |
| Peer review by other Teachers only | More complex and less controllable for MVP |

#### Impact

- Materials need moderation statuses.
- Staff dashboard must include material review queue.
- Students must only see approved and visible materials.
- Staff actions should create moderation records and audit logs.

---

### DEC-009: Admin Manages Roles and Governance

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 07-system-architecture.md, 09-api-design.md |

#### Context

HIPZI needs a role that can manage platform-level authority, permissions, subjects, audit logs, and override decisions.

#### Decision

Admin will manage roles and governance-level actions.

Admin responsibilities include:

- Assigning roles.
- Revoking roles.
- Assigning Staff permissions.
- Managing subjects.
- Viewing audit logs.
- Overriding Staff decisions in Phase 2.
- Handling serious policy issues.

#### Reason

This decision is selected because:

- Admin authority should be clearly separated from Staff operations.
- Staff handles daily moderation.
- Admin handles platform governance.
- Role assignment is sensitive and should be limited to Admins.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Staff can assign roles | Too much privilege for operational moderators |
| Teacher can request and auto-receive Staff role | Unsafe |
| No Admin governance layer | Not suitable for a multi-role platform |

#### Impact

- Admin APIs must be separate from Staff APIs.
- Admin dashboard should focus on governance.
- Admin actions must be protected by backend authorization.
- Important Admin actions must create audit logs.

---

## 8. AI Workflow Decisions

### DEC-010: AI-Generated Content Starts as Draft

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 03-functional-requirements.md, 06-edge-cases.md, 09-api-design.md |

#### Context

HIPZI uses AI to generate quizzes and flashcards from learning materials.

AI-generated content may contain mistakes, unclear explanations, duplicated questions, or low-quality outputs.

#### Decision

All AI-generated educational content will start as draft.

#### Reason

This decision protects Students because:

- AI output can be inaccurate.
- Teachers must verify educational correctness.
- Draft status prevents accidental publication.
- It aligns AI with a human-review workflow.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| AI content is published immediately | Unsafe for educational quality |
| AI content is hidden forever until Staff review only | Slower and less Teacher-centered |
| AI content is treated the same as manually created content | Does not account for AI-specific risks |

#### Impact

- AI generation APIs must create draft records.
- AI content must have status tracking.
- Students cannot access AI drafts.
- Teacher review page is required.

---

### DEC-011: Teacher Review Is Required Before AI Content Reaches Students

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 05-acceptance-criteria.md, 06-edge-cases.md, 10-non-functional-requirements.md |

#### Context

AI-generated quizzes and flashcards may be useful, but they should not be trusted without human review.

#### Decision

Teacher review is required before AI-generated learning content becomes available to Students.

#### Reason

This decision is necessary because:

- Teachers are responsible for educational correctness.
- AI may hallucinate or produce wrong answers.
- Students should not learn from unreviewed AI output.
- HIPZI should use AI as an assistant, not an authority.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| AI content can be published automatically | Unsafe |
| Staff reviews all AI content before Teacher | Slower and less aligned with Teacher ownership |
| Student can access AI drafts with warning | Still risky for learning correctness |

#### Impact

- AI content status must include `generated_draft` and `teacher_reviewed`.
- Teacher review UI must exist.
- Student-facing APIs must exclude unreviewed AI content.
- AI-assisted metadata should remain traceable.

---

### DEC-012: Student-Facing Content Must Be Approved and Visible

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 02-business-rules.md, 05-acceptance-criteria.md, 08-database-design.md, 09-api-design.md |

#### Context

HIPZI has materials with different statuses such as draft, pending review, approved, rejected, needs revision, hidden, and archived.

A decision was needed on what content Students can access.

#### Decision

Students can access only content that is both approved and visible.

Student-facing access rule:

    status = approved
    AND visibility = visible
    AND deleted_at IS NULL

#### Reason

This decision protects Students from:

- Draft content.
- Pending content.
- Rejected content.
- Hidden content.
- Archived content.
- Incomplete or unreviewed learning materials.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Students can see pending content with warning | Unsafe |
| Students can see all Teacher content | Bypasses moderation |
| Only frontend hides unavailable content | Not secure |

#### Impact

- Student-facing APIs must filter visibility.
- Search results must filter visibility.
- Recommendations must filter visibility.
- Direct URL access must still check visibility.
- Backend must enforce the rule, not only JSP.

---

## 9. Database and API Decisions

### DEC-013: Use Relational Database as Primary Database

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 08-database-design.md |

#### Context

HIPZI has structured relationships between users, roles, teacher applications, materials, subjects, quizzes, flashcards, attempts, moderation actions, and audit logs.

#### Decision

HIPZI will use a relational database as the primary database.

Recommended options:

- PostgreSQL.
- MySQL.

#### Reason

A relational database is suitable because:

- HIPZI has strong relationships between entities.
- Role and permission data should be consistent.
- Workflow statuses require reliable updates.
- Quiz attempts and learning history need structured storage.
- Moderation and audit logs benefit from relational integrity.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Document database as primary database | Less ideal for relational workflows and constraints |
| File-based storage | Not suitable for multi-user platform |
| In-memory database only | Not persistent enough for real use |

#### Impact

- Database design should use tables, foreign keys, constraints, and indexes.
- DAO layer should handle database access.
- Workflow-critical updates should use transactions when possible.

---

### DEC-014: Use Service Layer for Business Rules

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 07-system-architecture.md, 11-tech-plan.md |

#### Context

HIPZI has many important business rules that must be enforced consistently.

Examples:

- Only approved Teachers can upload materials.
- Staff cannot review their own content.
- Students can only access approved and visible materials.
- AI content must start as draft.
- Quiz attempts cannot be submitted twice.

#### Decision

Business rules will be implemented in the Service Layer.

#### Reason

This decision improves maintainability because:

- Business logic is centralized.
- Servlets remain thin.
- JSP files remain focused on rendering.
- Tests can target Services directly.
- AI coding agents can find business rules more easily.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Put business rules in JSP | Unsafe and unmaintainable |
| Put business rules directly in Servlets | Leads to large controllers |
| Put business rules in DAOs | Mixes domain logic with persistence logic |

#### Impact

- Services must be the source of business behavior.
- Servlets should delegate to Services.
- DAO classes should not enforce high-level business policies.
- Service tests should be prioritized.

---

### DEC-015: Use DAO Layer for Database Access

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 08-database-design.md, 11-tech-plan.md |

#### Context

HIPZI needs a clear way to isolate database access from Servlets and Services.

#### Decision

HIPZI will use a DAO Layer for database access.

#### Reason

This decision is selected because:

- It separates persistence logic from business logic.
- It keeps SQL away from JSP and Servlet files.
- It makes database operations easier to test.
- It improves maintainability.
- It fits well with Java Servlet MVC.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| SQL directly inside Servlets | Hard to maintain and unsafe |
| SQL directly inside JSP | Strongly unsafe and unprofessional |
| Full ORM from the beginning | May be more complex than needed for MVP |

#### Impact

- DAO classes should handle queries and updates.
- Services should call DAOs.
- DAOs should not contain business rules.
- Prepared statements should be used if JDBC is selected.

---

### DEC-016: Use Session-Based Authentication for JSP/Servlet MVP

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 10-non-functional-requirements.md, 11-tech-plan.md |

#### Context

HIPZI uses JSP and Servlet with server-rendered pages.

A decision was needed on whether to use session-based authentication or token-based authentication for the MVP.

#### Decision

HIPZI will use session-based authentication for the JSP/Servlet MVP.

#### Reason

Session-based authentication is suitable because:

- JSP/Servlet applications naturally support HTTP sessions.
- It is simpler for server-rendered pages.
- It is easier to implement for MVP.
- It fits form-based login and role-based dashboard routing.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| JWT token authentication | More suitable for SPA/mobile API-first architecture |
| OAuth-only authentication | More complex for MVP |
| No session management | Not acceptable for protected user workflows |

#### Impact

- Login creates a server-side session.
- Logout invalidates the session.
- AuthenticationFilter should protect authenticated routes.
- Role checks can use session data and Service verification.
- Sensitive data should not be stored in session.

---

### DEC-017: Use Audit Logs for Important Staff and Admin Actions

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 08-database-design.md, 10-non-functional-requirements.md, 12-testing-strategy.md |

#### Context

HIPZI includes moderation and governance workflows.

Important Staff and Admin decisions need accountability and traceability.

#### Decision

HIPZI will store audit logs for important Staff and Admin actions.

#### Reason

Audit logs are required because:

- Role assignment is sensitive.
- Material approval affects Student access.
- Teacher approval affects platform trust.
- Admin override decisions should be traceable.
- Self-review attempts should be recorded.
- Future disputes may require review history.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| No audit logs in MVP | Risky for moderation and governance |
| Only server logs | Hard to query and not structured for governance |
| Audit logs only in Phase 2 | Could lose important early history |

#### Impact

Audit logs should be created for:

- Role assignment.
- Staff role revocation.
- Teacher application approval.
- Teacher application rejection.
- Material approval.
- Material rejection.
- Material revision request.
- Material hide.
- Material archive.
- Admin override.
- Self-review block.

---

## 10. Scope and Roadmap Decisions

### DEC-018: Integrate Mock Exams, Courses, and Wallet Features into Phase 1

| Field | Value |
|---|---|
| Status | Superseded (Previously Accepted to defer) |
| Date | 2026-05-29 |
| Related Documents | 00-prd.md, 03-functional-requirements.md, 11-tech-plan.md, 08-database-design.md |

#### Context

HIPZI originally deferred payment, online exams, structured courses, and marketplace transactions to Phase 2 to focus on the core MVP. However, a strategic decision was made to integrate these core business drivers immediately.

#### Decision

Mock Exams (Trắc nghiệm, Flashcard, Tự luận), Courses (Khóa học), and Wallet Balance (Số dư ví) are moved from Phase 2 to Phase 1 (MVP). Parent features and advanced analytics remain deferred.

#### Reason

This decision is made because:

- Mock exams and courses provide immediate high value for Student retention.
- A basic wallet system establishes the foundation for monetization early.
- The technical foundation (modular monolith) allows these features to be integrated cleanly without destabilizing the core.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Keep deferring to Phase 2 | Delays business value and monetization opportunities |
| Build full advanced payment gateways immediately | Too complex; a simple internal wallet balance is safer for MVP |

#### Impact

MVP now includes:

- Mock Exams in the Exam Room.
- Course listings and enrollments.
- Internal Wallet Balance for Users.
- Teacher application.
- Staff moderation.
- Material upload.
- Student browsing.
- AI quiz and flashcard generation.
- Teacher review of AI content.
- Student practice.
- Basic Admin governance.
- Audit logs.

---

### DEC-019: Keep AI Recommendations as Phase 2 Scope

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 01-user-requirements.md, 03-functional-requirements.md, 07-system-architecture.md |

#### Context

HIPZI includes a vision where Students can provide input to AI, and AI can analyze what they need to study, identify weak areas, generate roadmaps, and recommend materials or Teachers.

A decision was needed on whether to include this in MVP.

#### Decision

AI personalization and recommendation will be treated as Phase 2 scope.

#### Reason

This decision is selected because:

- Personalization requires reliable learning history.
- Roadmap quality depends on available content and Student context.
- Recommendation systems require safety filters.
- The MVP should first validate content creation, moderation, and practice workflows.
- AI recommendations should not recommend unapproved content or unverified Teachers.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Include full AI recommendation in MVP | Too complex and depends on data not yet available |
| Remove AI recommendation from product vision | Reduces HIPZI’s long-term value |
| Recommend without moderation filters | Unsafe |

#### Impact

Phase 2 should include:

- Student learning preferences.
- AI learning need analysis.
- Personalized learning roadmap.
- Approved material recommendation.
- Verified Teacher recommendation.
- Recommendation safety filters.

---

### DEC-020: Keep UI/UX Design as a Separate Document

| Field | Value |
|---|---|
| Status | Accepted |
| Date | TBD |
| Related Documents | 14-ui-ux-design.md |

#### Context

HIPZI has multiple role-specific interfaces: Student, Teacher, Staff, Admin, and future Parent.

A decision was needed on whether UI/UX details should be mixed into PRD, functional requirements, or technical plan.

#### Decision

UI/UX design will be documented separately in `14-ui-ux-design.md`.

#### Reason

This decision is selected because:

- UI/UX needs detailed role-specific screen design.
- Functional requirements should not be overloaded with layout details.
- Technical plan should focus on implementation strategy.
- Designers, developers, and AI coding agents need a clear UI reference.
- Student, Teacher, Staff, and Admin experiences should be designed intentionally.

#### Alternatives Considered

| Alternative | Reason Not Selected |
|---|---|
| Put UI/UX inside PRD | Makes PRD too large |
| Put UI/UX inside Tech Plan | Mixes product experience with implementation |
| Skip UI/UX documentation | Risky because JSP pages may become inconsistent |

#### Impact

`14-ui-ux-design.md` should define:

- Role-based navigation.
- Page structure.
- Dashboard structure.
- Form behavior.
- Empty states.
- Error states.
- Loading states.
- AI content review UX.
- Quiz and flashcard UX.
- Staff moderation UX.
- Admin governance UX.
- Responsive design expectations.
- Accessibility expectations.

---

## 11. Future Decision Candidates

The following decisions are not finalized yet and should be recorded when they are made.

### Future Decision Candidate: PostgreSQL vs MySQL

| Field | Value |
|---|---|
| Status | Proposed |
| Context | HIPZI needs to choose a final relational database. |
| Options | PostgreSQL, MySQL |
| Notes | PostgreSQL is recommended for production-ready relational design, but MySQL is also acceptable depending on project constraints. |

---

### Future Decision Candidate: JDBC vs ORM

| Field | Value |
|---|---|
| Status | Proposed |
| Context | HIPZI needs to choose whether to use direct JDBC or an ORM. |
| Options | JDBC, Hibernate/JPA, MyBatis |
| Notes | JDBC is simpler and more transparent for learning. ORM may improve productivity but adds abstraction. |

---

### Future Decision Candidate: Local File Storage vs Object Storage

| Field | Value |
|---|---|
| Status | Proposed |
| Context | HIPZI needs a file storage strategy for uploaded materials. |
| Options | Local server storage, object storage |
| Notes | Local storage may be acceptable for development. Object storage is preferred for production. |

---

### Future Decision Candidate: AI Provider Selection

| Field | Value |
|---|---|
| Status | Proposed |
| Context | HIPZI needs to choose an AI provider for quiz and flashcard generation. |
| Options | External AI API provider, self-hosted model, hybrid approach |
| Notes | The system should use an adapter so the provider can be changed later. |

---

### Future Decision Candidate: Search Strategy

| Field | Value |
|---|---|
| Status | Proposed |
| Context | HIPZI needs a scalable search approach as content grows. |
| Options | Database search, full-text search, external search service, semantic search |
| Notes | MVP can start with database search. Phase 2 may require full-text or semantic search. |

---

### Future Decision Candidate: Deployment Platform

| Field | Value |
|---|---|
| Status | Proposed |
| Context | HIPZI needs a production deployment platform. |
| Options | VPS with Tomcat, cloud platform, containerized deployment |
| Notes | MVP can deploy simply, but production should consider reliability, backups, and security. |

---

## 12. Decision Review Process

Decision records should be reviewed when:

- A major feature is added.
- A technical direction changes.
- A business rule changes.
- A role or permission model changes.
- AI workflow behavior changes.
- Database schema changes significantly.
- API design changes significantly.
- A previous decision becomes outdated.
- The project moves from MVP to Phase 2.

When a decision changes:

1. Do not delete the old decision.
2. Mark the old decision as `Superseded` or `Deprecated`.
3. Add a new decision record.
4. Explain why the decision changed.
5. Update related documents.

---

## 13. Decision Log Maintenance Rules

This document should be maintained as part of the project documentation.

Rules:

- Add new decisions when important choices are made.
- Keep decision IDs stable.
- Do not reuse decision IDs.
- Keep decision titles clear.
- Keep decision reasons honest and specific.
- Link decisions to related documents.
- Update decision status when necessary.
- Avoid recording trivial implementation details.

Examples of decisions worth recording:

- Changing database from MySQL to PostgreSQL.
- Changing AI provider.
- Adding payment features.
- Changing role model.
- Allowing Teachers to publish without Staff review.
- Introducing course marketplace.
- Moving from session auth to token auth.
- Moving from modular monolith to services.

Examples of decisions not worth recording:

- Renaming a CSS class.
- Changing button color.
- Fixing a typo.
- Moving a helper function.
- Minor copy update.

---

## 14. MVP Decision Summary

The current MVP decisions are:

- HIPZI will use modular monolith architecture.
- HIPZI will use JSP for frontend rendering.
- HIPZI will use Java Servlet MVC with Service Layer for backend.
- HIPZI will separate Teacher and Staff roles.
- Trusted Teachers may also become Staff only through Admin assignment.
- Staff self-review is not allowed.
- Staff reviews Teacher applications.
- Staff reviews Teacher-uploaded materials.
- Admin manages roles and governance.
- AI-generated content starts as draft.
- Teacher review is required before AI content reaches Students.
- Students only access approved and visible content.
- HIPZI will use a relational database.
- Business rules belong in the Service Layer.
- Database access belongs in the DAO Layer.
- Session-based authentication is used for JSP/Servlet MVP.
- Important Staff and Admin actions require audit logs.
- Parent, payment, exam, and advanced course features are deferred.
- AI personalization and recommendations are Phase 2 scope.
- UI/UX design is documented separately.

---

## 15. Notes for AI Coding Agent

When working on HIPZI, the AI coding agent should use this decision log to understand why the project is structured in a specific way.

The AI coding agent should not change major design directions without checking this document.

Before implementing a feature, the AI coding agent should verify whether the feature is affected by any decision records.

Examples:

- Before implementing material approval, check DEC-008, DEC-012, DEC-017.
- Before implementing AI quiz generation, check DEC-010 and DEC-011.
- Before implementing Staff role assignment, check DEC-005 and DEC-009.
- Before implementing Teacher + Staff behavior, check DEC-006.
- Before changing project architecture, check DEC-001, DEC-002, DEC-003.
- Before adding personalization, check DEC-019.

If implementation requires changing a major decision, update this document and related docs before coding.

---
