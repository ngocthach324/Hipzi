# Skill: Update Docs

## 1. Purpose

Use this skill when updating HIPZI documentation.

Documentation updates are required when:

- Business behavior changes.
- Role rules change.
- Workflow changes.
- Database schema changes.
- API route changes.
- Technical architecture changes.
- UI/UX direction changes.
- AI workflow changes.
- Testing expectations change.
- Decision log needs a new decision.

---

## 2. Documentation Principles

HIPZI docs should be:

- Clear.
- Professional.
- Traceable.
- Consistent.
- Useful for AI coding agents.
- Useful for human developers.
- Aligned with implementation.

Do not update only one file if the change affects multiple documentation layers.

---

## 3. Documentation Map

Core docs:

- `00-prd.md`: product overview and vision.
- `01-user-requirements.md`: user needs.
- `02-business-rules.md`: business rules.
- `03-functional-requirements.md`: what the system must do.
- `04-user-flow.md`: user workflows.
- `05-acceptance-criteria.md`: feature correctness criteria.
- `06-edge-cases.md`: abnormal and risky cases.
- `07-system-architecture.md`: architecture.
- `08-database-design.md`: database.
- `09-api-design.md`: API/Servlet routes.
- `10-non-functional-requirements.md`: quality requirements.
- `11-tech-plan.md`: implementation plan.
- `12-testing-strategy.md`: testing approach.
- `13-decision-log.md`: major decisions.
- `14-ui-ux-design.md`: UI/UX direction.

---

## 4. When to Update Which File

### Business Rule Change

Update:

- `02-business-rules.md`
- `03-functional-requirements.md`
- `05-acceptance-criteria.md`
- `06-edge-cases.md`
- `12-testing-strategy.md`
- `13-decision-log.md` if major

---

### Workflow Change

Update:

- `04-user-flow.md`
- `05-acceptance-criteria.md`
- `06-edge-cases.md`
- `09-api-design.md`
- `12-testing-strategy.md`

---

### Database Change

Update:

- `08-database-design.md`
- `09-api-design.md`
- `11-tech-plan.md`
- `12-testing-strategy.md`

---

### API or Servlet Route Change

Update:

- `09-api-design.md`
- `11-tech-plan.md`
- `12-testing-strategy.md`

---

### UI Change

Update:

- `14-ui-ux-design.md`
- `05-acceptance-criteria.md` if behavior changes
- `12-testing-strategy.md` if test flow changes

---

### AI Workflow Change

Update:

- `02-business-rules.md`
- `03-functional-requirements.md`
- `06-edge-cases.md`
- `08-database-design.md`
- `09-api-design.md`
- `10-non-functional-requirements.md`
- `12-testing-strategy.md`
- `13-decision-log.md` if major

---

## 5. Documentation Style Rules

Use:

- Clear headings.
- Tables for structured information.
- Stable IDs where applicable.
- Consistent terminology.
- Professional English.
- Simple and direct wording.

Avoid:

- Vague requirements.
- Contradictory rules.
- Overly casual writing.
- Implementation details in product docs.
- Product decisions hidden only in code.

---

## 6. Traceability Rule

When updating docs, preserve traceability.

Example:

    BR-MAT-004
    → FR-MAT-005
    → UF-MAT-003
    → AC-MAT-003
    → EC-MAT-002
    → API: GET /materials
    → DB: materials.status + materials.visibility
    → Test: TC-MAT-004

---

## 7. Decision Log Rule

If a major decision changes, update `13-decision-log.md`.

Examples requiring decision log:

- Switching from JSP to another frontend.
- Switching from Servlet to Spring MVC.
- Changing database from MySQL to PostgreSQL.
- Allowing Teachers to publish without Staff review.
- Changing AI review rules.
- Changing role model.
- Adding payment as MVP scope.
- Moving from modular monolith to services.

---

## 8. Completion Response

When docs are updated, summarize:

- Docs changed.
- Reason for change.
- Related features.
- Any remaining docs that may need review.
- Any implementation impact.

---
