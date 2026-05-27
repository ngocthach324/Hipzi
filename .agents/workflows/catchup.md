---
description: 
---

# Workflow: Catchup

## 1. Purpose

Use this workflow when the AI agent needs to understand the current HIPZI project state before making changes.

This is useful when:

- Starting a new session.
- Returning after a break.
- Understanding a feature area.
- Preparing to implement a new task.
- Reviewing what has already been built.

---

## 2. Catchup Goals

The agent should understand:

- Current project structure.
- Current docs.
- Current tech stack.
- Current role model.
- Current business rules.
- Current feature status.
- Current implementation state.
- Current risks or missing pieces.

---

## 3. Documentation Reading Order

Start with:

1. `README.md`
2. `docs/00-prd.md`
3. `docs/07-system-architecture.md`
4. `docs/11-tech-plan.md`
5. `docs/13-decision-log.md`

Then read task-specific docs:

- Business behavior: `02`, `03`, `04`, `05`, `06`.
- Database: `08`.
- API/Servlet: `09`.
- Testing: `12`.
- UI: `14`.

---

## 4. Codebase Review Order

Review:

1. Project folders.
2. Java packages.
3. JSP views.
4. Servlet routes.
5. Services.
6. DAOs.
7. Models.
8. Database migrations.
9. CSS and JS.
10. Tests.

---

## 5. Catchup Checklist

Answer:

- What is the project trying to build?
- What tech stack is being used?
- What roles exist?
- What are the core business rules?
- What has already been implemented?
- What is incomplete?
- What docs are relevant to the next task?
- What risks should be considered?

---

## 6. Output Format

After catchup, summarize:

- Current understanding.
- Relevant docs.
- Relevant files.
- Current implementation status.
- Recommended next step.
- Risks or questions.

Do not make code changes during catchup unless explicitly asked.

---

# .agents/workflows/implement.md

# Workflow: Implement

## 1. Purpose

Use this workflow when implementing a new HIPZI feature or enhancement.

---

## 2. Implementation Process

### Step 1: Understand the Request

Clarify:

- What feature is needed?
- Which user role uses it?
- Which workflow does it belong to?
- What is the expected behavior?
- Is this MVP, Phase 2, or Future scope?

---

### Step 2: Read Relevant Docs

Read:

- `02-business-rules.md`
- `03-functional-requirements.md`
- `04-user-flow.md`
- `05-acceptance-criteria.md`
- `06-edge-cases.md`

Then read technical docs:

- `08-database-design.md`
- `09-api-design.md`
- `11-tech-plan.md`
- `12-testing-strategy.md`
- `14-ui-ux-design.md` if UI is involved

---

### Step 3: Identify Affected Layers

Determine if implementation needs:

- JSP.
- Servlet.
- Service.
- DAO.
- Model.
- DTO.
- Filter.
- Database migration.
- CSS.
- JavaScript.
- Tests.
- Docs update.

---

### Step 4: Implement in Correct Order

Recommended order:

1. Model / DTO.
2. DAO.
3. Service.
4. Servlet.
5. JSP.
6. CSS / JavaScript.
7. Tests.
8. Documentation update.

---

### Step 5: Enforce Business Rules

Before finishing, verify:

- Authentication required where needed.
- Role check implemented.
- Ownership check implemented.
- Staff self-review prevention implemented if relevant.
- Student visibility filtering implemented if relevant.
- AI draft rule implemented if relevant.
- Audit log created if relevant.
- Status transition valid.

---

### Step 6: Test

Run or describe:

- Service tests.
- DAO tests.
- Servlet tests.
- Manual JSP tests.
- Regression tests.

---

### Step 7: Summarize

Final summary should include:

- What was implemented.
- Files changed.
- Rules enforced.
- Tests added or recommended.
- Docs updated or recommended.
- Known risks.

---
