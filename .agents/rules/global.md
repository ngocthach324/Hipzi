---
trigger: always_on
---

# HIPZI Global Agent Rules

## 1. Purpose

This file defines the global rules that every AI coding agent must follow when working on HIPZI.

These rules apply to all tasks, including feature implementation, bug fixing, testing, documentation updates, UI changes, database changes, and refactoring.

HIPZI is an AI-powered EdTech platform built with:

- JSP for frontend rendering.
- Java Servlet for backend request handling.
- MVC architecture.
- Service Layer for business logic.
- DAO Layer for database access.
- Relational database as the primary data store.
- Role-based workflows for Student, Teacher, Staff, and Admin.
- Human-reviewed AI-assisted educational content.

The AI agent must respect HIPZI’s product rules, technical architecture, and documentation structure.

---

## 2. Core Project Context

HIPZI supports multiple user roles:

- Student.
- Teacher / Lecturer.
- Staff.
- Admin.
- Parent in future phases.

The core MVP workflow is:

1. User registers and logs in.
2. User applies to become a Teacher.
3. Staff reviews and approves or rejects Teacher applications.
4. Approved Teacher uploads learning materials.
5. Staff reviews uploaded materials.
6. Students can access only approved and visible materials.
7. Teacher generates AI quizzes or flashcards from materials.
8. AI-generated content starts as draft.
9. Teacher reviews AI-generated content.
10. Students can practice quizzes and flashcards after review requirements are satisfied.
11. Admin manages roles, Staff permissions, subjects, and governance actions.

---

## 3. Mandatory Documentation Reading Rule

Before implementing or modifying any important feature, the AI agent must check the relevant documentation.

Important docs:

- `docs/00-prd.md`
- `docs/01-user-requirements.md`
- `docs/02-business-rules.md`
- `docs/03-functional-requirements.md`
- `docs/04-user-flow.md`
- `docs/05-acceptance-criteria.md`
- `docs/06-edge-cases.md`
- `docs/07-system-architecture.md`
- `docs/08-database-design.md`
- `docs/09-api-design.md`
- `docs/10-non-functional-requirements.md`
- `docs/11-tech-plan.md`
- `docs/12-testing-strategy.md`
- `docs/13-decision-log.md`
- `docs/14-ui-ux-design.md`

The agent should not guess business behavior if the behavior is already defined in the docs.

---

## 4. Architecture Rules

HIPZI uses MVC with Service Layer.

Required flow:

    JSP View
    → Servlet Controller
    → Service Layer
    → DAO Layer
    → Database

Rules:

- JSP must render UI only.
- Servlet must handle request flow only.
- Service must enforce business rules.
- DAO must handle database access.
- Model must represent domain data.
- DTO must structure request and response data.
- Filters should handle authentication and route-level authorization.
- Services must still enforce important authorization and ownership rules.

---

## 5. Business Rule Protection

The AI agent must never violate HIPZI’s core business rules.

Critical rules:

- Students can access only approved and visible materials.
- Teacher and Staff are separate roles by default.
- A Teacher does not automatically become Staff.
- A Staff member does not automatically become Teacher.
- Admin can assign Staff role to trusted Teachers.
- Staff cannot review their own Teacher application.
- Staff cannot approve, reject, hide, archive, or request revision for their own materials.
- Only approved Teachers can upload learning materials.
- AI-generated content must start as draft.
- AI-generated content requires Teacher review before Student access.
- Admin-only actions must be protected.
- Important Staff and Admin actions must create audit logs.
- Quiz attempts must prevent duplicate submission.

---

## 6. Security Rules

The AI agent must implement security on the backend.

Rules:

- Do not rely only on JSP or JavaScript for permission checks.
- Protected Servlets must require authentication.
- Staff routes must require active Staff role.
- Admin routes must require active Admin role.
- Teacher creation tools must require approved Teacher status.
- Student-facing queries must filter content by approval and visibility.
- Passwords must never be stored in plain text.
- SQL must use prepared statements if JDBC is used.
- Error pages must not expose stack traces or database details.
- File uploads must validate file type and file size.

---

## 7. Student Visibility Rule

Any Student-facing material query must apply this rule:

    material.status = approved
    AND material.visibility = visible
    AND material.deleted_at IS NULL

This applies to:

- Material browsing.
- Material detail.
- Search results.
- Recommended materials.
- Quiz listing.
- Flashcard listing.
- Future course listings.

If this rule is missed, the implementation is unsafe.

---

## 8. AI Safety Rule

AI must assist, not decide.

Rules:

- AI output must be saved as draft.
- AI-generated quizzes and flashcards must be marked as AI-assisted.
- Teacher review is required before Student access.
- Staff review may be required depending on platform policy.
- AI must not directly publish to Students.
- AI-generated content must remain traceable to source material.
- AI failure must not publish incomplete content.
- AI recommendations in Phase 2 must only recommend approved materials and verified Teachers.

---

## 9. Audit Rule

The agent must create audit logs for important moderation and governance actions.

Actions requiring audit logs:

- Assign role.
- Revoke role.
- Approve Teacher application.
- Reject Teacher application.
- Approve material.
- Reject material.
- Request material revision.
- Hide material.
- Archive material.
- Admin override.
- Staff self-review blocked.

Audit log should include:

- Actor user ID.
- Actor role.
- Action.
- Target entity type.
- Target entity ID.
- Previous value if applicable.
- New value if applicable.
- Reason if applicable.
- Timestamp.

---

## 10. JSP Rules

JSP may:

- Render data.
- Show forms.
- Show validation messages.
- Show status badges.
- Show role-specific navigation.
- Use JSTL for simple loops and conditions.

JSP must not:

- Query the database.
- Create DAO objects.
- Create Service objects.
- Perform business rules.
- Approve or reject content.
- Call AI providers.
- Enforce security as the only protection layer.

---

## 11. Servlet Rules

Servlets may:

- Receive requests.
- Read request parameters.
- Create DTOs.
- Call Services.
- Forward to JSP.
- Redirect after successful POST.
- Return JSON for dynamic endpoints.

Servlets must not:

- Contain SQL.
- Contain complex business rules.
- Perform material moderation logic directly.
- Perform AI workflow logic directly.
- Perform role assignment logic directly.
- Duplicate Service rules.

---

## 12. Service Rules

Services must:

- Enforce business rules.
- Check permissions.
- Check ownership.
- Check valid status transitions.
- Coordinate DAO operations.
- Create audit logs when needed.
- Use transactions for multi-step workflows when possible.

Services should be the main target for unit tests.

---

## 13. DAO Rules

DAOs must:

- Handle database queries.
- Use prepared statements if JDBC is used.
- Map rows to Models or DTOs.
- Avoid HTTP request/response logic.
- Avoid high-level business rules.
- Avoid JSP rendering logic.

---

## 14. Documentation Update Rule

If implementation changes behavior, update related docs.

Examples:

If material workflow changes, update:

- `02-business-rules.md`
- `03-functional-requirements.md`
- `05-acceptance-criteria.md`
- `06-edge-cases.md`
- `08-database-design.md`
- `09-api-design.md`

If technical structure changes, update:

- `07-system-architecture.md`
- `11-tech-plan.md`
- `13-decision-log.md`

If UI changes significantly, update:

- `14-ui-ux-design.md`

---

## 15. Agent Response Rule

When finishing a task, the AI agent should summarize:

- What was changed.
- Which files were affected.
- Which business rules were considered.
- Which tests were added or should be added.
- Whether documentation needs updating.
- Any risks or follow-up work.

---
