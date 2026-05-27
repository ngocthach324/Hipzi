---
description: 
---

# Workflow: Ship

## 1. Purpose

Use this workflow before considering a HIPZI feature or release ready.

Shipping means the implementation is safe, tested, documented, and aligned with HIPZI rules.

---

## 2. Ship Checklist

### 2.1 Product Alignment

Verify:

- Feature matches PRD.
- Feature matches user requirements.
- Feature follows business rules.
- Feature follows acceptance criteria.
- Feature handles key edge cases.

---

### 2.2 Architecture Alignment

Verify:

- JSP only renders.
- Servlet handles request flow.
- Service enforces business rules.
- DAO handles database access.
- No SQL in JSP.
- No business logic in JSP.
- No complex business logic in Servlet.

---

### 2.3 Security Check

Verify:

- Authentication required where needed.
- Role authorization enforced.
- Backend checks exist.
- Student visibility filters exist.
- Staff self-review blocked.
- Admin actions protected.
- Sensitive data not exposed.
- Errors are safe.

---

### 2.4 AI Safety Check

Verify if AI is involved:

- AI output starts as draft.
- AI-assisted flag is stored.
- Teacher review is required.
- Student cannot access AI draft.
- AI failure does not publish content.
- Source material is traceable.

---

### 2.5 Data Check

Verify:

- Correct tables updated.
- Required records created.
- Status transitions valid.
- Audit logs created.
- Duplicate submissions prevented.
- No orphaned records.

---

### 2.6 UI/UX Check

Verify:

- Page follows HIPZI design direction.
- Status badges are clear.
- Empty states exist.
- Error states exist.
- Loading states exist where needed.
- Forms show validation errors.
- Role-specific navigation is correct.
- Mobile layout is not broken.

---

### 2.7 Testing Check

Verify:

- Service tests added or updated.
- DAO tests added if needed.
- Servlet tests added if needed.
- Manual JSP test completed.
- Regression tests considered.
- Critical workflows tested.

---

### 2.8 Documentation Check

Verify whether docs need update:

- Business rules.
- Functional requirements.
- Acceptance criteria.
- Edge cases.
- Database design.
- API design.
- Tech plan.
- Testing strategy.
- Decision log.
- UI/UX design.

---

## 3. Release Summary Format

When shipping, summarize:

- Feature or fix completed.
- Business rules verified.
- Security checks completed.
- Tests completed.
- Docs updated.
- Known limitations.
- Recommended follow-up tasks.

---

## 4. Do Not Ship If

Do not ship if:

- Student can access unapproved content.
- Staff can self-review.
- AI content can bypass Teacher review.
- Admin-only action is accessible to non-Admin.
- Quiz can be submitted twice.
- Sensitive data is exposed.
- Critical workflow is untested.
- JSP contains database logic.
- Servlet contains major business logic.
- Required audit logs are missing.
