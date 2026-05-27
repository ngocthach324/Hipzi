# Skill: Build Feature

## 1. Purpose

Use this skill when implementing a new HIPZI feature.

A feature may include:

- New JSP page.
- New Servlet.
- New Service method.
- New DAO query.
- New database table or field.
- New AI workflow.
- New Staff moderation workflow.
- New Admin governance action.
- New Student learning feature.

---

## 2. Required Mindset

When building a feature, the AI agent must:

- Understand the requirement before coding.
- Check related docs.
- Identify impacted layers.
- Respect MVC structure.
- Put business logic in Services.
- Put database access in DAOs.
- Keep JSP focused on rendering.
- Add tests where possible.
- Update docs if behavior changes.

---

## 3. Pre-Implementation Checklist

Before coding, answer:

1. What feature is being built?
2. Which user role uses this feature?
3. Which docs define this behavior?
4. Which business rules apply?
5. Which acceptance criteria apply?
6. Which edge cases apply?
7. Which database tables are involved?
8. Which JSP page is needed?
9. Which Servlet is needed?
10. Which Service method is needed?
11. Which DAO methods are needed?
12. Which tests should be added?

---

## 4. Documentation Reading Order

For product behavior:

1. `docs/02-business-rules.md`
2. `docs/03-functional-requirements.md`
3. `docs/04-user-flow.md`
4. `docs/05-acceptance-criteria.md`
5. `docs/06-edge-cases.md`

For technical implementation:

1. `docs/07-system-architecture.md`
2. `docs/08-database-design.md`
3. `docs/09-api-design.md`
4. `docs/10-non-functional-requirements.md`
5. `docs/11-tech-plan.md`
6. `docs/12-testing-strategy.md`
7. `docs/13-decision-log.md`
8. `docs/14-ui-ux-design.md`

---

## 5. Implementation Layer Order

Implement in this order when possible:

1. Model or DTO.
2. DAO.
3. Service.
4. Servlet.
5. JSP.
6. CSS or JavaScript.
7. Tests.
8. Documentation update.

---

## 6. Standard Feature Flow

For a normal JSP/Servlet feature:

    User opens JSP page
    → GET Servlet loads data
    → JSP renders page
    → User submits form
    → POST Servlet reads request
    → Servlet creates Request DTO
    → Service validates business rules
    → DAO reads/writes database
    → Service returns result
    → Servlet redirects or forwards
    → JSP shows success or error

---

## 7. Business Rule Check

Before finishing a feature, verify:

- Does this feature require authentication?
- Does this feature require a specific role?
- Does this feature require ownership?
- Does this feature change workflow status?
- Does this feature affect Student visibility?
- Does this feature require audit log?
- Does this feature involve AI-generated content?
- Does this feature need Staff self-review prevention?

---

## 8. Example: Build Material Upload Feature

Required layers:

- JSP: `teacher/material-form.jsp`
- Servlet: `MaterialCreateServlet`
- Service: `MaterialService.createMaterial`
- DAO: `MaterialDao.create`
- Model: `Material`
- DTO: `MaterialCreateRequest`
- Database: `materials`, `material_files`
- Tests: `MaterialServiceTest`, manual JSP test

Rules:

- Approved Teacher required.
- Required fields validated.
- Material owner is current Teacher.
- New material starts as draft.
- Student must not see draft material.

---

## 9. Example: Build Staff Material Approval Feature

Required layers:

- JSP: `staff/material-review-detail.jsp`
- Servlet: `StaffMaterialApproveServlet`
- Service: `MaterialModerationService.approveMaterial`
- DAO: `MaterialDao`, `MaterialModerationActionDao`, `AuditLogDao`
- Database: `materials`, `material_moderation_actions`, `audit_logs`

Rules:

- Staff role required.
- Staff cannot approve own material.
- Material must be in valid review status.
- Material status becomes approved.
- Visibility updates according to policy.
- Audit log is created.
- Student can access material only after approved and visible.

---

## 10. Example: Build AI Quiz Generation Feature

Required layers:

- JSP: `ai/generate-quiz.jsp`, `ai/review-ai-content.jsp`
- Servlet: `AIQuizGenerateServlet`
- Service: `AIContentService.generateQuizDraft`
- Integration: `AIProviderAdapter`
- DAO: `AIContentDao`, `QuizDao`, `QuizQuestionDao`, `QuizOptionDao`
- Database: `ai_contents`, `quizzes`, `quiz_questions`, `quiz_options`

Rules:

- Approved Teacher required.
- Teacher must have access to source material.
- AI output starts as draft.
- AI-assisted metadata is stored.
- Student cannot access draft.
- Teacher review required.

---

## 11. Testing Requirement

For every feature, add tests when possible.

Minimum expected tests:

- Service test for business rules.
- DAO test for database behavior if new query is added.
- Servlet integration test if route behavior is complex.
- Manual JSP test if UI is affected.

---

## 12. Completion Response

When complete, summarize:

- Feature implemented.
- Files changed.
- Business rules enforced.
- Tests added or recommended.
- Docs updated or recommended.
- Known risks or follow-up tasks.
---