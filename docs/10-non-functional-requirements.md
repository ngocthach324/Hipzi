# HIPZI API Design

## Document Information

| Field | Value |
|---|---|
| Product Name | HIPZI |
| Document Type | API Design Specification |
| Document Version | 1.0 |
| Status | Draft |
| Related Documents | 00-prd.md, 01-user-requirements.md, 02-business-rules.md, 03-functional-requirements.md, 04-user-flow.md, 05-acceptance-criteria.md, 06-edge-cases.md, 07-system-architecture.md, 08-database-design.md |
| Primary Audience | Product Owner, Developer, AI Coding Agent, Backend Engineer, Frontend Engineer, QA Engineer |
| Language | English |

---

## 1. Purpose

This document defines the API design for HIPZI.

The purpose of this document is to describe how frontend clients, backend services, AI workflows, Staff moderation tools, Admin governance tools, and Student learning features should communicate through APIs.

This document focuses on:

- API design principles.
- API module structure.
- Authentication and authorization rules.
- Resource naming conventions.
- Request and response standards.
- Error handling standards.
- Core MVP endpoints.
- Phase 2 and Future endpoints.
- Role-based API access.
- Workflow-based API behavior.
- API rules for AI-generated content.
- API rules for Staff moderation and Admin governance.

This document does not define:

- Exact implementation code.
- Exact framework routing files.
- Database migration scripts.
- UI screen design.
- Infrastructure deployment setup.

---

## 2. API Design Context

HIPZI is an AI-powered EdTech platform with multiple user roles and workflow-heavy business logic.

The API must support:

- User registration and login.
- Role-based access control.
- Teacher application submission.
- Staff review of Teacher applications.
- Admin role assignment and governance actions.
- Teacher material upload and management.
- Staff material moderation.
- Student browsing of approved materials.
- AI quiz and flashcard generation.
- Teacher review of AI-generated content.
- Student quiz and flashcard practice.
- Learning activity tracking.
- Search and discovery.
- Future personalization, classes, courses, parent features, exams, and monetization.

The API must preserve the core HIPZI governance model:

> Students learn from approved content.  
> Teachers create educational content.  
> Staff moderate teacher applications and uploaded content.  
> Admins govern roles, permissions, audits, and override decisions.  
> AI assists but does not bypass Teacher review or Staff moderation rules.

---

## 3. API Design Goals

HIPZI APIs should be designed to achieve the following goals:

- Clear separation between Student, Teacher, Staff, Admin, and Parent capabilities.
- Secure authentication and authorization.
- Consistent request and response format.
- Predictable error handling.
- Strong enforcement of business rules on the backend.
- Clear support for workflow state transitions.
- Traceability from API endpoints to functional requirements and business rules.
- Safe AI-generated content handling.
- Student-facing visibility filtering.
- Maintainable API structure for developers and AI coding agents.
- Extensible structure for future product phases.

---

## 4. API Architecture Style

HIPZI should use a REST-style API design for MVP.

REST is recommended because:

- It is simple and widely understood.
- It maps well to resources such as users, materials, quizzes, and applications.
- It is easier for AI coding agents to reason about.
- It works well for typical web application workflows.
- It is suitable for modular monolith backend architecture.

GraphQL may be considered later if HIPZI needs complex client-side data composition, but it is not necessary for MVP.

---

## 5. API Base Structure

Recommended base path:

    /api/v1

Example:

    /api/v1/auth/register
    /api/v1/materials
    /api/v1/staff/materials/{materialId}/approve
    /api/v1/admin/users/{userId}/roles

Versioning should be included from the beginning to support future API evolution.

---

## 6. API Design Principles

### 6.1 Backend Authorization Is Mandatory

Frontend role checks are not enough.

Every protected API endpoint must enforce authorization on the backend.

Examples:

- Student must not access Staff APIs.
- Teacher without Staff role must not access moderation APIs.
- Staff must not access Admin-only APIs.
- Teacher must not approve their own content.
- Student must not access unapproved or hidden materials.

---

### 6.2 Student-Facing APIs Must Filter Visibility

Student-facing APIs must only return approved and visible content.

Required filtering rule:

    material.status = approved
    AND material.visibility = visible
    AND material.deleted_at IS NULL

This rule applies to:

- Material listing.
- Material detail.
- Search results.
- Recommended materials.
- Practice activities.
- Future course listings.

---

### 6.3 Workflow State Transitions Must Be Explicit

APIs that change workflow state should be explicit.

Preferred:

    POST /materials/{materialId}/submit-review
    POST /staff/materials/{materialId}/approve
    POST /staff/materials/{materialId}/reject
    POST /staff/materials/{materialId}/request-revision

Avoid vague update endpoints for major state transitions.

Less preferred:

    PATCH /materials/{materialId}
    body: { status: "approved" }

Reason:

- Explicit endpoints are easier to secure.
- They are easier to audit.
- They reduce accidental invalid status changes.
- They map better to business rules and acceptance criteria.

---

### 6.4 AI Output Must Be Draft by Default

AI generation APIs must create draft AI content.

AI APIs must not directly publish content to Students.

Correct behavior:

    Teacher requests AI generation
    → API creates AI draft
    → Teacher reviews draft
    → Content becomes Teacher Reviewed
    → Staff review may be required
    → Student can access only after required review is complete

---

### 6.5 Staff and Admin APIs Must Be Separate

Staff APIs should support operational moderation.

Admin APIs should support governance.

Staff APIs:

- Review teacher applications.
- Review uploaded materials.
- Handle reports.
- Escalate serious issues.

Admin APIs:

- Assign roles.
- Revoke roles.
- Manage subjects.
- Audit Staff actions.
- Override Staff decisions.

This separation prevents Admin and Staff responsibilities from becoming mixed.

---

### 6.6 Important Actions Should Create Audit Logs

The API should create audit records for important actions.

Examples:

- Assign Staff role.
- Revoke Staff role.
- Approve Teacher application.
- Reject Teacher application.
- Approve material.
- Reject material.
- Request material revision.
- Hide material.
- Archive material.
- Admin override.
- Staff self-review blocked.

---

## 7. Authentication and Authorization Model

### 7.1 Authentication

Authentication identifies the current user.

HIPZI may use:

- Email and password.
- OAuth provider in future.
- Session-based authentication.
- Token-based authentication.

The API design should remain independent of the exact auth implementation.

Protected endpoints must require an authenticated user.

---

### 7.2 Authorization

Authorization determines what the authenticated user can do.

HIPZI should use role-based access control.

Core roles:

| Role | Description |
|---|---|
| Student | Learner who studies approved materials and practices |
| Parent | Future role for authorized Student progress viewing |
| Teacher | Verified educator who creates learning content |
| Staff | Platform operator who reviews applications and content |
| Admin | Governance role that manages roles, audits, and overrides |

---

### 7.3 Common Authorization Rules

| Action | Required Role / Condition |
|---|---|
| Browse approved materials | Student or authenticated user |
| Upload material | Approved Teacher |
| Submit material for review | Material owner Teacher |
| Review teacher application | Staff |
| Review material | Staff |
| Approve material | Staff, not content owner |
| Assign Staff role | Admin |
| Revoke Staff role | Admin |
| Manage subjects | Admin |
| Generate AI quiz | Approved Teacher with access to material |
| Review AI content | Teacher owner |
| Practice quiz | Student with access to approved quiz |
| View Admin audit logs | Admin |

---

## 8. Request and Response Standards

### 8.1 Request Format

Requests should use JSON for structured data.

For file uploads, use multipart form data or a separate file upload flow depending on implementation.

Example JSON request body:

    {
      "title": "Algebra Basics",
      "description": "Introduction to algebra concepts",
      "subjectId": "subject-uuid",
      "contentText": "Learning material content..."
    }

---

### 8.2 Standard Success Response

Recommended success response format:

    {
      "success": true,
      "data": {},
      "message": "Operation completed successfully."
    }

Example:

    {
      "success": true,
      "data": {
        "id": "material-uuid",
        "title": "Algebra Basics",
        "status": "draft"
      },
      "message": "Material created successfully."
    }

---

### 8.3 Standard Error Response

Recommended error response format:

    {
      "success": false,
      "error": {
        "code": "VALIDATION_ERROR",
        "message": "Title is required.",
        "details": {}
      }
    }

Common error fields:

| Field | Purpose |
|---|---|
| `success` | Always false for errors |
| `error.code` | Machine-readable error code |
| `error.message` | Human-readable message |
| `error.details` | Optional field-level or contextual details |

---

### 8.4 Pagination Response

List endpoints should support pagination.

Recommended query parameters:

| Parameter | Purpose |
|---|---|
| `page` | Page number |
| `limit` | Number of items per page |
| `sort` | Sort field |
| `order` | asc or desc |

Example response:

    {
      "success": true,
      "data": {
        "items": [],
        "pagination": {
          "page": 1,
          "limit": 20,
          "totalItems": 120,
          "totalPages": 6
        }
      }
    }

---

### 8.5 Timestamp Format

All timestamps should use ISO 8601 format.

Example:

    2026-05-13T10:30:00Z

---

## 9. HTTP Status Code Standards

| Status Code | Meaning | Usage |
|---|---|---|
| 200 | OK | Successful read or update |
| 201 | Created | Resource created |
| 204 | No Content | Successful delete or empty response |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | User is not authenticated |
| 403 | Forbidden | User is authenticated but lacks permission |
| 404 | Not Found | Resource does not exist or is not accessible |
| 409 | Conflict | Duplicate or invalid workflow conflict |
| 422 | Unprocessable Entity | Validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

Important security note:

For private or unauthorized resources, the API may return `404 Not Found` instead of `403 Forbidden` to avoid revealing resource existence.

---

## 10. Error Code Standards

Recommended error codes:

| Error Code | Meaning |
|---|---|
| `AUTH_REQUIRED` | Authentication is required |
| `INVALID_CREDENTIALS` | Login credentials are invalid |
| `FORBIDDEN` | User lacks required permission |
| `VALIDATION_ERROR` | Request validation failed |
| `RESOURCE_NOT_FOUND` | Resource not found |
| `DUPLICATE_RESOURCE` | Duplicate resource exists |
| `INVALID_STATUS_TRANSITION` | Workflow status change is not allowed |
| `SELF_REVIEW_NOT_ALLOWED` | Staff cannot review own content |
| `TEACHER_APPROVAL_REQUIRED` | User must be an approved Teacher |
| `STAFF_PERMISSION_REQUIRED` | Staff role is required |
| `ADMIN_PERMISSION_REQUIRED` | Admin role is required |
| `CONTENT_NOT_VISIBLE` | Content is not visible to current user |
| `AI_GENERATION_FAILED` | AI generation failed |
| `AI_REVIEW_REQUIRED` | AI content requires Teacher review |
| `STAFF_REVIEW_REQUIRED` | Staff review is required |
| `DUPLICATE_SUBMISSION` | Duplicate submission detected |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

---

## 11. API Module Overview

HIPZI APIs should be grouped by domain.

Recommended API groups:

| API Group | Purpose |
|---|---|
| `/auth` | Registration, login, logout, current user |
| `/users` | User profile and account access |
| `/roles` | Role information |
| `/teacher-applications` | Teacher application submission and status |
| `/teacher` | Teacher dashboard and teacher-owned resources |
| `/materials` | Student-facing and Teacher material APIs |
| `/staff` | Staff moderation APIs |
| `/admin` | Admin governance APIs |
| `/ai` | AI generation and AI content workflows |
| `/quizzes` | Quiz access and management |
| `/flashcards` | Flashcard access and management |
| `/practice` | Student quiz attempts and practice |
| `/search` | Search and discovery |
| `/personalization` | Phase 2 learning roadmap and recommendations |
| `/classes` | Phase 2 class management |
| `/courses` | Future course management |
| `/reports` | Phase 2 reporting |
| `/reviews` | Future reviews and ratings |
| `/exams` | Future exams |
| `/payments` | Future payments |

---

## 12. Authentication APIs

### 12.1 Register User

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/auth/register` |
| Access | Public |
| Purpose | Create a new user account |
| Related Requirements | FR-AUTH-001 |
| Related Acceptance Criteria | AC-AUTH-001 |

Request body:

    {
      "email": "student@example.com",
      "password": "securePassword",
      "displayName": "Ngoc Thach"
    }

Success response:

    {
      "success": true,
      "data": {
        "userId": "user-uuid",
        "email": "student@example.com",
        "displayName": "Ngoc Thach"
      },
      "message": "Account created successfully."
    }

Rules:

- Email must be unique.
- Password must be securely hashed.
- Default role should be assigned according to platform policy.
- Duplicate accounts must be rejected.

---

### 12.2 Login User

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/auth/login` |
| Access | Public |
| Purpose | Authenticate user |
| Related Requirements | FR-AUTH-002 |
| Related Acceptance Criteria | AC-AUTH-002 |

Request body:

    {
      "email": "student@example.com",
      "password": "securePassword"
    }

Success response:

    {
      "success": true,
      "data": {
        "user": {
          "id": "user-uuid",
          "email": "student@example.com",
          "displayName": "Ngoc Thach",
          "roles": ["student"]
        },
        "accessToken": "token-if-token-auth-is-used"
      },
      "message": "Login successful."
    }

Rules:

- Invalid credentials must not reveal whether email or password is wrong.
- Suspended or disabled accounts should not be allowed to log in.

---

### 12.3 Logout User

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/auth/logout` |
| Access | Authenticated |
| Purpose | End current session |
| Related Requirements | FR-AUTH-002 |
| Related Acceptance Criteria | AC-AUTH-002 |

Success response:

    {
      "success": true,
      "data": null,
      "message": "Logout successful."
    }

---

### 12.4 Get Current User

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/auth/me` |
| Access | Authenticated |
| Purpose | Return current authenticated user |
| Related Requirements | FR-AUTH-004 |
| Related Acceptance Criteria | AC-AUTH-003 |

Success response:

    {
      "success": true,
      "data": {
        "id": "user-uuid",
        "email": "user@example.com",
        "displayName": "User Name",
        "roles": ["student", "teacher"]
      }
    }

Rules:

- Must return active roles only.
- Should not expose sensitive account data.

---

## 13. User and Profile APIs

### 13.1 Get User Profile

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/users/me/profile` |
| Access | Authenticated |
| Purpose | Get current user profile |

Success response:

    {
      "success": true,
      "data": {
        "id": "user-uuid",
        "displayName": "User Name",
        "avatarUrl": null,
        "roles": ["student"]
      }
    }

---

### 13.2 Update User Profile

| Field | Value |
|---|---|
| Method | PATCH |
| Endpoint | `/api/v1/users/me/profile` |
| Access | Authenticated |
| Purpose | Update current user profile |

Request body:

    {
      "displayName": "Updated Name",
      "avatarUrl": "https://example.com/avatar.png"
    }

Rules:

- User can update only their own profile unless Admin permissions apply.
- Restricted fields such as roles must not be updated through this endpoint.

---

## 14. Teacher Application APIs

### 14.1 Submit Teacher Application

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/teacher-applications` |
| Access | Authenticated User |
| Purpose | Submit application to become a verified Teacher |
| Related Requirements | FR-TCH-001 |
| Related User Flow | UF-TCH-001 |
| Related Acceptance Criteria | AC-TCH-001 |
| Related Business Rules | BR-TCH-001, BR-TCH-002 |

Request body:

    {
      "displayTitle": "Math Teacher",
      "bio": "I teach high school math.",
      "experienceSummary": "3 years of tutoring experience.",
      "qualifications": "Bachelor in Mathematics",
      "teachingSubjects": ["Mathematics", "Algebra"]
    }

Success response:

    {
      "success": true,
      "data": {
        "applicationId": "application-uuid",
        "status": "pending_review"
      },
      "message": "Teacher application submitted successfully."
    }

Rules:

- User must be authenticated.
- Duplicate active applications should be rejected.
- New application should enter `pending_review` status.
- Application should become visible to Staff review queue.

---

### 14.2 Get My Teacher Application Status

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/teacher-applications/me` |
| Access | Authenticated User |
| Purpose | View current user's teacher application status |
| Related Requirements | FR-TCH-002 |
| Related User Flow | UF-TCH-002 |
| Related Acceptance Criteria | AC-TCH-002 |

Success response:

    {
      "success": true,
      "data": {
        "applicationId": "application-uuid",
        "status": "pending_review",
        "submittedAt": "2026-05-13T10:30:00Z",
        "reviewNotes": null,
        "rejectionReason": null
      }
    }

Rules:

- User can only view their own application through this endpoint.
- If no application exists, return a clear empty state.

---

## 15. Staff Teacher Application Review APIs

### 15.1 List Teacher Applications for Review

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/staff/teacher-applications` |
| Access | Staff |
| Purpose | List teacher applications pending review |
| Related Requirements | FR-STF-001, FR-STF-002 |
| Related User Flow | UF-STF-001 |
| Related Acceptance Criteria | AC-STF-001, AC-STF-002 |

Query parameters:

| Parameter | Purpose |
|---|---|
| `status` | Filter by application status |
| `page` | Page number |
| `limit` | Items per page |

Success response:

    {
      "success": true,
      "data": {
        "items": [
          {
            "id": "application-uuid",
            "userId": "user-uuid",
            "displayName": "Teacher Applicant",
            "status": "pending_review",
            "submittedAt": "2026-05-13T10:30:00Z"
          }
        ],
        "pagination": {
          "page": 1,
          "limit": 20,
          "totalItems": 1,
          "totalPages": 1
        }
      }
    }

Rules:

- Staff role is required.
- Non-Staff users must be denied.

---

### 15.2 Get Teacher Application Detail

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/staff/teacher-applications/{applicationId}` |
| Access | Staff |
| Purpose | View teacher application detail for review |
| Related Requirements | FR-STF-002 |
| Related Acceptance Criteria | AC-STF-002 |

Rules:

- Staff role is required.
- Sensitive user data should not be exposed unnecessarily.

---

### 15.3 Approve Teacher Application

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/teacher-applications/{applicationId}/approve` |
| Access | Staff |
| Purpose | Approve a teacher application |
| Related Requirements | FR-STF-003 |
| Related User Flow | UF-STF-001 |
| Related Acceptance Criteria | AC-STF-002 |
| Related Business Rules | BR-STF-002, BR-TCH-002 |

Request body:

    {
      "reviewNotes": "Application approved."
    }

Success response:

    {
      "success": true,
      "data": {
        "applicationId": "application-uuid",
        "status": "approved",
        "teacherUserId": "user-uuid"
      },
      "message": "Teacher application approved."
    }

Rules:

- Staff role is required.
- Staff must not approve their own teacher application.
- Approval should grant Teacher permissions.
- Audit log should be created.

---

### 15.4 Reject Teacher Application

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/teacher-applications/{applicationId}/reject` |
| Access | Staff |
| Purpose | Reject a teacher application |
| Related Requirements | FR-STF-003 |
| Related Acceptance Criteria | AC-STF-002 |

Request body:

    {
      "rejectionReason": "Missing required teaching qualification information."
    }

Rules:

- Staff role is required.
- Rejected applicant must not receive Teacher permissions.
- Rejection reason should be stored.
- Audit log should be created.

---

## 16. Admin Governance APIs

### 16.1 List Users

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/admin/users` |
| Access | Admin |
| Purpose | List users for governance management |
| Related Requirements | FR-ADM-002 |
| Related Acceptance Criteria | AC-ADM-001, AC-ADM-002 |

Query parameters:

| Parameter | Purpose |
|---|---|
| `role` | Filter by role |
| `status` | Filter by account status |
| `search` | Search by name or email |
| `page` | Page number |
| `limit` | Items per page |

Rules:

- Admin role is required.
- Staff users without Admin role must be denied.

---

### 16.2 Assign Role to User

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/admin/users/{userId}/roles` |
| Access | Admin |
| Purpose | Assign a role to a user |
| Related Requirements | FR-AUTH-003, FR-ADM-003 |
| Related User Flow | UF-ADM-001 |
| Related Acceptance Criteria | AC-AUTH-005, AC-ADM-002 |

Request body:

    {
      "role": "staff"
    }

Success response:

    {
      "success": true,
      "data": {
        "userId": "user-uuid",
        "roles": ["student", "teacher", "staff"]
      },
      "message": "Role assigned successfully."
    }

Rules:

- Admin role is required.
- Duplicate active role assignment should be rejected.
- Assigning Staff role should create audit log.
- A trusted Teacher may receive Staff role, but self-review prevention must still apply.

---

### 16.3 Revoke Role from User

| Field | Value |
|---|---|
| Method | DELETE |
| Endpoint | `/api/v1/admin/users/{userId}/roles/{roleName}` |
| Access | Admin |
| Purpose | Revoke a role from a user |
| Related Requirements | FR-AUTH-006, FR-ADM-003 |
| Related Acceptance Criteria | AC-AUTH-005, AC-ADM-002 |

Rules:

- Admin role is required.
- Revocation should update active permissions.
- Revoking Staff role should prevent future Staff actions.
- Audit log should be created.

---

### 16.4 Create Subject

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/admin/subjects` |
| Access | Admin |
| Purpose | Create a subject or learning category |
| Related Requirements | FR-ADM-004 |
| Related Acceptance Criteria | AC-ADM-003 |

Request body:

    {
      "name": "Mathematics",
      "slug": "mathematics",
      "description": "Math learning materials"
    }

Rules:

- Admin role is required.
- Subject slug must be unique.

---

### 16.5 Update Subject

| Field | Value |
|---|---|
| Method | PATCH |
| Endpoint | `/api/v1/admin/subjects/{subjectId}` |
| Access | Admin |
| Purpose | Update subject metadata |
| Related Requirements | FR-ADM-004 |
| Related Acceptance Criteria | AC-ADM-003 |

---

### 16.6 Get Audit Logs

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/admin/audit-logs` |
| Access | Admin |
| Purpose | View platform audit logs |
| Priority | Phase 2 |
| Related Requirements | FR-ADM-005 |
| Related Acceptance Criteria | AC-ADM-004 |

Rules:

- Admin role is required.
- Logs should support filtering by actor, action, entity type, and date.

---

### 16.7 Override Staff Decision

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/admin/overrides` |
| Access | Admin |
| Purpose | Override a Staff decision |
| Priority | Phase 2 |
| Related Requirements | FR-ADM-006 |
| Related Acceptance Criteria | AC-ADM-005 |

Request body:

    {
      "targetEntityType": "material",
      "targetEntityId": "material-uuid",
      "newStatus": "hidden",
      "reason": "Content requires further review."
    }

Rules:

- Admin role is required.
- Override must create audit log.
- If override affects material visibility, Student-facing access must update immediately.

---

## 17. Subject APIs

### 17.1 List Subjects

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/subjects` |
| Access | Public or Authenticated |
| Purpose | List active subjects for browsing and material categorization |

Success response:

    {
      "success": true,
      "data": {
        "items": [
          {
            "id": "subject-uuid",
            "name": "Mathematics",
            "slug": "mathematics"
          }
        ]
      }
    }

Rules:

- Only active subjects should be returned to general users.
- Admin may have separate endpoint for inactive subjects.

---

## 18. Material APIs

### 18.1 Create Material

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/materials` |
| Access | Approved Teacher |
| Purpose | Create a new learning material |
| Related Requirements | FR-MAT-001, FR-MAT-002 |
| Related User Flow | UF-MAT-001 |
| Related Acceptance Criteria | AC-MAT-001 |
| Related Business Rules | BR-TCH-004, BR-MAT-001, BR-MAT-002 |

Request body:

    {
      "title": "Algebra Basics",
      "description": "Introduction to algebra concepts.",
      "subjectId": "subject-uuid",
      "contentText": "Material content...",
      "visibility": "private"
    }

Success response:

    {
      "success": true,
      "data": {
        "id": "material-uuid",
        "title": "Algebra Basics",
        "status": "draft",
        "visibility": "private"
      },
      "message": "Material created successfully."
    }

Rules:

- User must be an approved Teacher.
- Material owner must be the current Teacher.
- Required fields must be validated.
- New material should be saved as `draft` unless submitted directly according to platform policy.

---

### 18.2 Upload Material File

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/materials/{materialId}/files` |
| Access | Material Owner Teacher |
| Purpose | Upload file attachment for a material |
| Related Requirements | FR-MAT-001, FR-MAT-002 |

Rules:

- User must own the material.
- Material must be editable.
- File metadata should be stored in `material_files`.
- Unsupported file types should be rejected.

---

### 18.3 Get My Materials

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/teacher/materials` |
| Access | Approved Teacher |
| Purpose | List materials owned by current Teacher |
| Related Requirements | FR-TCH-005 |
| Related Acceptance Criteria | AC-MAT-001, AC-MAT-004 |

Rules:

- Return only materials owned by current Teacher.
- Include moderation status.

---

### 18.4 Update Material

| Field | Value |
|---|---|
| Method | PATCH |
| Endpoint | `/api/v1/materials/{materialId}` |
| Access | Material Owner Teacher |
| Purpose | Update editable material |
| Related Requirements | FR-MAT-006 |
| Related Acceptance Criteria | AC-MAT-004 |

Rules:

- Teacher can edit their own material only.
- Editable statuses include `draft`, `rejected`, and `needs_revision`.
- Editing approved material may require versioning and re-review in Phase 2.
- Teacher cannot edit another Teacher’s material.

---

### 18.5 Submit Material for Review

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/materials/{materialId}/submit-review` |
| Access | Material Owner Teacher |
| Purpose | Submit material for Staff review |
| Related Requirements | FR-MAT-004 |
| Related User Flow | UF-MAT-001 |
| Related Acceptance Criteria | AC-MAT-002 |

Success response:

    {
      "success": true,
      "data": {
        "materialId": "material-uuid",
        "status": "pending_review"
      },
      "message": "Material submitted for review."
    }

Rules:

- Material must belong to current Teacher.
- Required fields must be complete.
- Status should become `pending_review`.
- Material should appear in Staff material review queue.

---

### 18.6 List Student-Visible Materials

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/materials` |
| Access | Student or Authenticated User |
| Purpose | Browse approved and visible materials |
| Related Requirements | FR-STU-003, FR-MAT-005 |
| Related User Flow | UF-MAT-003 |
| Related Acceptance Criteria | AC-MAT-003 |

Query parameters:

| Parameter | Purpose |
|---|---|
| `subjectId` | Filter by subject |
| `keyword` | Search by keyword |
| `page` | Page number |
| `limit` | Items per page |

Rules:

- Must return only approved and visible materials.
- Must exclude draft, pending_review, rejected, needs_revision, hidden, archived, and deleted materials.
- Visibility filtering must happen on backend.

---

### 18.7 Get Student-Visible Material Detail

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/materials/{materialId}` |
| Access | Student or Authenticated User |
| Purpose | View approved material detail |
| Related Requirements | FR-STU-004, FR-MAT-005 |
| Related Acceptance Criteria | AC-MAT-003 |

Rules:

- Material must be approved and visible.
- If material is hidden, archived, rejected, or pending, return not found or access denied.
- Include available approved quizzes and flashcards.

---

## 19. Staff Material Moderation APIs

### 19.1 List Materials Pending Review

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/staff/materials` |
| Access | Staff |
| Purpose | List materials requiring Staff moderation |
| Related Requirements | FR-STF-004 |
| Related User Flow | UF-STF-002 |
| Related Acceptance Criteria | AC-STF-003 |

Query parameters:

| Parameter | Purpose |
|---|---|
| `status` | pending_review, needs_revision, etc. |
| `subjectId` | Filter by subject |
| `page` | Page number |
| `limit` | Items per page |

Rules:

- Staff role is required.
- Should show moderation-relevant material metadata.

---

### 19.2 Get Material Review Detail

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/staff/materials/{materialId}` |
| Access | Staff |
| Purpose | View material details for moderation |
| Related Requirements | FR-STF-004 |
| Related Acceptance Criteria | AC-STF-003 |

Rules:

- Staff role is required.
- Should include owner information and moderation history.
- If current Staff owns the material as Teacher, the API should indicate self-review restriction.

---

### 19.3 Approve Material

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/materials/{materialId}/approve` |
| Access | Staff |
| Purpose | Approve uploaded material |
| Related Requirements | FR-STF-005 |
| Related User Flow | UF-STF-002 |
| Related Acceptance Criteria | AC-STF-003, AC-MAT-002 |
| Related Business Rules | BR-STF-004, BR-MAT-004 |

Request body:

    {
      "reason": "Material meets quality standards."
    }

Rules:

- Staff role is required.
- Staff must not approve their own material.
- Material status should become `approved`.
- Visibility may become `visible` according to platform policy.
- Moderation action must be logged.
- Audit log should be created.

---

### 19.4 Reject Material

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/materials/{materialId}/reject` |
| Access | Staff |
| Purpose | Reject uploaded material |
| Related Requirements | FR-STF-005 |
| Related Acceptance Criteria | AC-STF-003 |

Request body:

    {
      "reason": "Material lacks sufficient explanation."
    }

Rules:

- Staff role is required.
- Staff must not reject their own material if self-review prevention applies.
- Material status should become `rejected`.
- Student must not see rejected material.
- Reason should be stored.

---

### 19.5 Request Material Revision

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/materials/{materialId}/request-revision` |
| Access | Staff |
| Purpose | Request Teacher revision |
| Related Requirements | FR-STF-005 |
| Related Acceptance Criteria | AC-STF-003, AC-MAT-004 |

Request body:

    {
      "reason": "Please improve examples and fix formatting."
    }

Rules:

- Material status should become `needs_revision`.
- Teacher should be able to edit and resubmit.
- Student must not see material while in revision status.

---

### 19.6 Hide Material

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/materials/{materialId}/hide` |
| Access | Staff |
| Purpose | Hide material from Student-facing pages |
| Related Requirements | FR-STF-005 |
| Related Acceptance Criteria | AC-STF-003, AC-MAT-003 |

Rules:

- Material status or visibility should prevent Student access.
- Existing Student-facing access must update accordingly.
- Moderation action should be logged.

---

### 19.7 Archive Material

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/materials/{materialId}/archive` |
| Access | Staff |
| Purpose | Archive material |
| Related Requirements | FR-STF-005 |
| Related Acceptance Criteria | AC-STF-003 |

Rules:

- Archived material must not appear to Students.
- Archive action should be logged.

---

## 20. AI Content APIs

### 20.1 Generate Quiz with AI

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/ai/materials/{materialId}/generate-quiz` |
| Access | Approved Teacher with material access |
| Purpose | Generate AI quiz draft from material |
| Related Requirements | FR-AI-001, FR-AI-003 |
| Related User Flow | UF-AI-001 |
| Related Acceptance Criteria | AC-AI-001 |

Request body:

    {
      "questionCount": 10,
      "difficulty": "medium",
      "questionTypes": ["multiple_choice"]
    }

Success response:

    {
      "success": true,
      "data": {
        "aiContentId": "ai-content-uuid",
        "quizId": "quiz-uuid",
        "status": "generated_draft",
        "aiAssisted": true
      },
      "message": "AI quiz draft generated successfully."
    }

Rules:

- User must be an approved Teacher.
- Teacher must have access to source material.
- AI output must be saved as draft.
- AI output must not be visible to Students before Teacher review.
- AI-assisted flag must be preserved.

---

### 20.2 Generate Flashcards with AI

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/ai/materials/{materialId}/generate-flashcards` |
| Access | Approved Teacher with material access |
| Purpose | Generate AI flashcard draft from material |
| Related Requirements | FR-AI-002, FR-AI-003 |
| Related User Flow | UF-AI-002 |
| Related Acceptance Criteria | AC-AI-002 |

Rules:

- Same AI draft rules as quiz generation.
- Generated flashcards must be saved as draft.
- Generated flashcards must not be visible to Students until review requirements are met.

---

### 20.3 Get AI Content Draft

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/ai/contents/{aiContentId}` |
| Access | Owner Teacher, Staff if review required, Admin |
| Purpose | View AI-generated draft content |
| Related Requirements | FR-AI-004 |
| Related Acceptance Criteria | AC-AI-003 |

Rules:

- Owner Teacher can view and edit.
- Staff can view if content is submitted for Staff review.
- Student must not access draft AI content.

---

### 20.4 Review AI Content

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/ai/contents/{aiContentId}/teacher-review` |
| Access | Owner Teacher |
| Purpose | Mark AI-generated content as Teacher Reviewed |
| Related Requirements | FR-AI-004, FR-AI-005 |
| Related User Flow | UF-AI-003 |
| Related Acceptance Criteria | AC-AI-003, AC-AI-004 |

Request body:

    {
      "reviewNotes": "Reviewed and corrected questions."
    }

Rules:

- Only owner Teacher can complete Teacher review.
- Status should become `teacher_reviewed`.
- If Staff review is required, content remains unavailable to Students.
- If Staff review is not required, content may become publishable according to policy.

---

### 20.5 Discard AI Content

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/ai/contents/{aiContentId}/discard` |
| Access | Owner Teacher |
| Purpose | Discard AI-generated content |
| Related Requirements | FR-AI-007 |
| Related Acceptance Criteria | AC-AI-003 |

Rules:

- Discarded content should not be visible to Students.
- System should preserve audit or metadata according to platform policy.

---

## 21. Quiz APIs

### 21.1 Get Available Quizzes for Material

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/materials/{materialId}/quizzes` |
| Access | Student or Authenticated User |
| Purpose | List approved quizzes for a visible material |
| Related Requirements | FR-PRAC-001 |
| Related Acceptance Criteria | AC-PRAC-001 |

Rules:

- Material must be approved and visible.
- Quizzes must be available to Students.
- Unreviewed AI-generated quizzes must be excluded.

---

### 21.2 Get Quiz Detail

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/quizzes/{quizId}` |
| Access | Student with access |
| Purpose | Get quiz detail for practice |
| Related Requirements | FR-PRAC-001 |

Rules:

- Must not expose correct answers before submission unless quiz settings allow it.
- Must only return available quizzes.

---

## 22. Flashcard APIs

### 22.1 Get Available Flashcard Sets for Material

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/materials/{materialId}/flashcard-sets` |
| Access | Student or Authenticated User |
| Purpose | List approved flashcard sets for a visible material |
| Related Requirements | FR-PRAC-007 |
| Related Acceptance Criteria | AC-PRAC-006 |

Rules:

- Material must be approved and visible.
- Flashcard set must be approved or published according to policy.
- Unreviewed AI flashcards must be excluded.

---

### 22.2 Get Flashcard Set Detail

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/flashcard-sets/{flashcardSetId}` |
| Access | Student with access |
| Purpose | View flashcards for practice |
| Related Requirements | FR-PRAC-007 |

Rules:

- Empty sets should return an empty state.
- Hidden or unapproved sets must not be accessible.

---

## 23. Practice APIs

### 23.1 Start Quiz Attempt

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/practice/quizzes/{quizId}/attempts` |
| Access | Student |
| Purpose | Start a quiz attempt |
| Related Requirements | FR-PRAC-001 |
| Related User Flow | UF-PRAC-001 |
| Related Acceptance Criteria | AC-PRAC-001 |

Success response:

    {
      "success": true,
      "data": {
        "attemptId": "attempt-uuid",
        "quizId": "quiz-uuid",
        "status": "started"
      }
    }

Rules:

- Student role is required.
- Quiz must be available.
- Related material must be approved and visible.
- Restricted retake rules must be enforced.

---

### 23.2 Submit Quiz Attempt

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/practice/attempts/{attemptId}/submit` |
| Access | Student who owns attempt |
| Purpose | Submit quiz answers |
| Related Requirements | FR-PRAC-002, FR-PRAC-003, FR-PRAC-004, FR-PRAC-005 |
| Related Acceptance Criteria | AC-PRAC-002, AC-PRAC-003, AC-PRAC-004 |

Request body:

    {
      "answers": [
        {
          "questionId": "question-uuid",
          "selectedOptionId": "option-uuid"
        }
      ]
    }

Success response:

    {
      "success": true,
      "data": {
        "attemptId": "attempt-uuid",
        "status": "scored",
        "score": 8,
        "maxScore": 10
      },
      "message": "Quiz submitted successfully."
    }

Rules:

- Student must own the attempt.
- Duplicate submission must be prevented.
- Score should be calculated only when valid evaluation rules exist.
- Attempt must be stored in learning history.

---

### 23.3 Get Quiz Attempt Result

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/practice/attempts/{attemptId}/result` |
| Access | Student who owns attempt |
| Purpose | View quiz results and feedback |
| Related Requirements | FR-PRAC-004 |
| Related Acceptance Criteria | AC-PRAC-003 |

Rules:

- Student can view only their own attempt results.
- Correct answers and explanations should follow quiz settings.

---

### 23.4 Get My Learning Activity

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/practice/me/learning-activities` |
| Access | Student |
| Purpose | View basic learning history |
| Related Requirements | FR-STU-005, FR-PRAC-005 |
| Related Acceptance Criteria | AC-PRAC-004 |

Rules:

- Student can access only their own learning history.
- Data should be paginated.

---

## 24. Search APIs

### 24.1 Search Materials

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/search/materials` |
| Access | Student or Authenticated User |
| Purpose | Search approved and visible materials |
| Related Requirements | FR-SEARCH-001, FR-SEARCH-002, FR-SEARCH-003 |
| Related Acceptance Criteria | AC-SEARCH-001, AC-SEARCH-002 |

Query parameters:

| Parameter | Purpose |
|---|---|
| `q` | Search keyword |
| `subjectId` | Subject filter |
| `page` | Page number |
| `limit` | Items per page |

Rules:

- Must only return approved and visible materials.
- Hidden or unapproved materials must be excluded.
- Empty result should return a clear empty state.

---

### 24.2 Natural-Language Search

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/search/natural-language` |
| Access | Student |
| Purpose | Search materials using natural-language query |
| Priority | Phase 2 |
| Related Requirements | FR-SEARCH-004 |
| Related Acceptance Criteria | AC-SEARCH-003 |

Rules:

- Must only return approved and visible materials.
- AI or semantic search must not bypass visibility rules.

---

## 25. Personalization APIs

### 25.1 Submit Learning Preferences

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/personalization/preferences` |
| Access | Student |
| Purpose | Save Student learning personalization input |
| Priority | Phase 2 |
| Related Requirements | FR-PER-001, FR-PER-007 |
| Related User Flow | UF-PER-001 |
| Related Acceptance Criteria | AC-PER-001 |

Request body:

    {
      "learningGoals": "Improve Grade 10 Math",
      "currentLevel": "Beginner",
      "weakAreas": ["Functions", "Equations"],
      "availableStudyTime": "45 minutes per day",
      "learningStyle": "Step-by-step explanation"
    }

Rules:

- Student can update only their own preferences.
- Partial input may be allowed according to platform policy.

---

### 25.2 Generate Learning Roadmap

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/personalization/roadmaps/generate` |
| Access | Student |
| Purpose | Generate AI-personalized learning roadmap |
| Priority | Phase 2 |
| Related Requirements | FR-PER-002, FR-PER-003 |
| Related Acceptance Criteria | AC-PER-002, AC-PER-003 |

Rules:

- AI should use Student input and learning history when available.
- If data is insufficient, API should return clarifying questions or a general roadmap.
- Roadmap must be presented as recommendation, not mandatory requirement.

---

### 25.3 Get Recommendations

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/personalization/recommendations` |
| Access | Student |
| Purpose | Recommend materials and Teachers |
| Priority | Phase 2 |
| Related Requirements | FR-PER-004, FR-PER-005 |
| Related Acceptance Criteria | AC-PER-004, AC-PER-005 |

Rules:

- Recommended materials must be approved and visible.
- Recommended Teachers must be verified and active.
- Hidden materials and inactive Teachers must be excluded.

---

## 26. Reporting APIs

### 26.1 Submit Report

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/reports` |
| Access | Authenticated User |
| Purpose | Report content or AI mistake |
| Priority | Phase 2 |
| Related Requirements | FR-REP-001, FR-REP-002 |
| Related Acceptance Criteria | AC-REP-001 |

Request body:

    {
      "targetEntityType": "ai_content",
      "targetEntityId": "ai-content-uuid",
      "reasonType": "ai_error",
      "description": "The explanation contains an incorrect formula."
    }

Rules:

- User must be authenticated.
- Report should become visible to Staff.
- Duplicate reports may be grouped in future.

---

### 26.2 Staff List Reports

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/staff/reports` |
| Access | Staff |
| Purpose | View reported content queue |
| Priority | Phase 2 |
| Related Requirements | FR-STF-008 |
| Related Acceptance Criteria | AC-REP-001 |

---

### 26.3 Staff Resolve Report

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/staff/reports/{reportId}/resolve` |
| Access | Staff |
| Purpose | Resolve a report |
| Priority | Phase 2 |

Request body:

    {
      "action": "hide_content",
      "resolutionNote": "Content was hidden due to incorrect explanation."
    }

Rules:

- Staff role is required.
- If content is hidden, Student visibility must update.
- Audit log should be created.

---

## 27. Class APIs

### 27.1 Create Class

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/classes` |
| Access | Approved Teacher |
| Purpose | Create teacher-managed class |
| Priority | Phase 2 |
| Related Requirements | FR-CLS-001 |
| Related Acceptance Criteria | AC-CLS-001 |

Rules:

- User must be an approved Teacher.
- Unapproved Teacher must be denied.

---

### 27.2 Request Class Enrollment

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/classes/{classId}/enrollment-requests` |
| Access | Student |
| Purpose | Request enrollment in class |
| Priority | Phase 2 |
| Related Requirements | FR-CLS-002 |
| Related Acceptance Criteria | AC-CLS-002 |

Rules:

- Duplicate active enrollment requests should be rejected.
- Class capacity rules should be respected if configured.

---

### 27.3 Teacher Approves Enrollment

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/classes/{classId}/enrollments/{enrollmentId}/approve` |
| Access | Class Owner Teacher |
| Purpose | Approve Student enrollment |
| Priority | Phase 2 |
| Related Requirements | FR-CLS-003 |
| Related Acceptance Criteria | AC-CLS-003 |

Rules:

- Teacher must own the class.
- Enrollment status should become approved or active according to policy.

---

## 28. Course APIs

### 28.1 Create Course

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/courses` |
| Access | Approved Teacher |
| Purpose | Create structured course |
| Priority | Future |
| Related Requirements | FR-COURSE-001 |

Rules:

- Approved Teacher required.
- Course may include modules and lessons in future endpoints.

---

### 28.2 Submit Course for Review

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/courses/{courseId}/submit-review` |
| Access | Course Owner Teacher |
| Purpose | Submit course for Staff review |
| Priority | Future |
| Related Requirements | FR-COURSE-002 |

Rules:

- Course review may be required before public listing.
- Staff review workflow should mirror material moderation patterns.

---

## 29. Parent APIs

### 29.1 Request Student Link

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/parent/student-links` |
| Access | Parent |
| Purpose | Request link to Student account |
| Priority | Future |
| Related Requirements | FR-PAR-002 |
| Related Acceptance Criteria | AC-PAR-001 |

Rules:

- Parent access to Student data requires verified relationship.
- Pending link should not grant access.

---

### 29.2 Get Linked Student Progress

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/parent/students/{studentId}/progress` |
| Access | Verified Parent |
| Purpose | View permitted Student progress |
| Priority | Future |
| Related Requirements | FR-PAR-003 |
| Related Acceptance Criteria | AC-PAR-002 |

Rules:

- Parent must have verified link to Student.
- Only permitted Student progress data should be returned.

---

## 30. Review and Rating APIs

### 30.1 Submit Review

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/reviews` |
| Access | Authenticated User |
| Purpose | Review material, Teacher, class, or course |
| Priority | Future |
| Related Requirements | FR-REV-001 |
| Related Acceptance Criteria | AC-REV-001 |

Rules:

- User must have valid interaction with target item.
- Teacher must not review their own content.

---

## 31. Exam APIs

### 31.1 Create Exam

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/exams` |
| Access | Approved Teacher |
| Purpose | Create online exam |
| Priority | Future |
| Related Requirements | FR-EXAM-001 |
| Related Acceptance Criteria | AC-EXAM-001 |

Rules:

- Formal exams must be distinguished from practice quizzes.
- Time and attempt limits should be stored if configured.

---

### 31.2 Start Exam Attempt

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/exams/{examId}/attempts` |
| Access | Student |
| Purpose | Start formal exam attempt |
| Priority | Future |
| Related Requirements | FR-EXAM-002 |
| Related Acceptance Criteria | AC-EXAM-002 |

Rules:

- Exam must be available to Student.
- Attempt limits must be enforced.
- Correct answers must not be exposed before submission.

---

## 32. Payment APIs

### 32.1 Access Premium Feature

| Field | Value |
|---|---|
| Method | GET |
| Endpoint | `/api/v1/payments/entitlements` |
| Access | Authenticated User |
| Purpose | Check user premium entitlements |
| Priority | Future |
| Related Requirements | FR-PAY-001 |
| Related Acceptance Criteria | AC-PAY-001 |

---

### 32.2 Create Teacher Marketplace Transaction

| Field | Value |
|---|---|
| Method | POST |
| Endpoint | `/api/v1/payments/teacher-services/transactions` |
| Access | Student or Parent |
| Purpose | Start paid teacher service transaction |
| Priority | Future |
| Related Requirements | FR-PAY-002 |
| Related Acceptance Criteria | AC-PAY-002 |

Rules:

- Payment must succeed before service access is granted.
- Failed payments must not complete transaction.

---

## 33. API Security Requirements

### 33.1 Authentication Security

APIs should:

- Require authentication for protected routes.
- Use secure password hashing.
- Avoid exposing sensitive user data.
- Handle invalid credentials safely.
- Support session expiration or token expiration.

---

### 33.2 Authorization Security

APIs must enforce:

- Student access boundaries.
- Teacher approval requirements.
- Staff permission requirements.
- Admin permission requirements.
- Self-review prevention.
- Content ownership rules.

---

### 33.3 Input Validation

APIs must validate:

- Required fields.
- Field types.
- Enum values.
- IDs and ownership.
- File types and file sizes.
- Workflow status transitions.

---

### 33.4 Rate Limiting

Rate limiting should be considered for:

- Login attempts.
- Registration attempts.
- AI generation.
- Search APIs.
- Report submissions.
- Payment APIs in future.

---

## 34. API Audit Requirements

The following API actions should create audit logs:

- Admin assigns role.
- Admin revokes role.
- Staff approves Teacher application.
- Staff rejects Teacher application.
- Staff approves material.
- Staff rejects material.
- Staff requests material revision.
- Staff hides material.
- Staff archives material.
- Admin overrides Staff decision.
- Staff self-review attempt is blocked.
- AI generation failure occurs.
- Report is resolved or escalated.

Audit log should include:

- Actor user ID.
- Actor role.
- Action name.
- Target entity type.
- Target entity ID.
- Previous value when applicable.
- New value when applicable.
- Reason when applicable.
- Timestamp.

---

## 35. MVP API Scope

The MVP should implement the following API groups first:

- Authentication APIs.
- Current user profile APIs.
- Teacher application APIs.
- Staff teacher application review APIs.
- Admin role and subject management APIs.
- Material creation and management APIs.
- Staff material moderation APIs.
- Student material browsing APIs.
- AI quiz generation APIs.
- AI flashcard generation APIs.
- AI content review APIs.
- Quiz practice APIs.
- Flashcard practice APIs.
- Basic search APIs.
- Basic learning activity APIs.
- Basic audit logging APIs.

The MVP should not require:

- Payment APIs.
- Full course APIs.
- Full exam APIs.
- Parent dashboard APIs.
- Full review and rating APIs.
- Complex recommendation APIs.
- Advanced analytics APIs.

---

## 36. Critical API Rules for HIPZI

### 36.1 Student Content Access Rule

Student-facing APIs must only return approved and visible content.

Required rule:

    material.status = approved
    AND material.visibility = visible
    AND material.deleted_at IS NULL

---

### 36.2 Teacher Upload Rule

Only approved Teachers can create and submit learning materials.

API must check:

- Authenticated user.
- Teacher role.
- Approved Teacher status.
- Account is active.

---

### 36.3 Staff Moderation Rule

Only Staff can moderate Teacher applications and materials.

API must check:

- Authenticated user.
- Active Staff role.
- Self-review prevention.

---

### 36.4 Admin Governance Rule

Only Admins can assign roles, revoke roles, manage governance tools, and override Staff decisions.

API must check:

- Authenticated user.
- Active Admin role.

---

### 36.5 AI Draft Rule

AI generation APIs must create draft content.

AI-generated content must not be visible to Students until:

- Teacher review is completed.
- Staff review is completed if required.
- Related source material is approved and visible.

---

### 36.6 Quiz Attempt Rule

Quiz attempt APIs must prevent:

- Duplicate submission.
- Access by non-owner Student.
- Attempt on hidden or unavailable quiz.
- Invalid scoring when answer keys are missing.

---

## 37. API Traceability Examples

### 37.1 Material Upload Traceability

| Layer | Reference |
|---|---|
| Business Rule | BR-TCH-004, BR-MAT-003 |
| Functional Requirement | FR-MAT-001, FR-MAT-004 |
| User Flow | UF-MAT-001 |
| Acceptance Criteria | AC-MAT-001, AC-MAT-002 |
| Edge Case | EC-TCH-003, EC-MAT-001 |
| Database | materials, material_files |
| API | POST /api/v1/materials, POST /api/v1/materials/{materialId}/submit-review |

---

### 37.2 Staff Material Approval Traceability

| Layer | Reference |
|---|---|
| Business Rule | BR-STF-004, BR-MAT-004 |
| Functional Requirement | FR-STF-005 |
| User Flow | UF-STF-002 |
| Acceptance Criteria | AC-STF-003, AC-MAT-003 |
| Edge Case | EC-STF-002, EC-STF-003 |
| Database | materials, material_moderation_actions, audit_logs |
| API | POST /api/v1/staff/materials/{materialId}/approve |

---

### 37.3 AI Quiz Generation Traceability

| Layer | Reference |
|---|---|
| Business Rule | BR-AI-002, BR-AI-006 |
| Functional Requirement | FR-AI-001, FR-AI-003 |
| User Flow | UF-AI-001 |
| Acceptance Criteria | AC-AI-001, AC-AI-004 |
| Edge Case | EC-AI-001, EC-AI-002 |
| Database | ai_contents, quizzes, quiz_questions, quiz_options |
| API | POST /api/v1/ai/materials/{materialId}/generate-quiz |

---

## 38. Notes for Implementation

Implementation should follow these guidelines:

- Keep API route handlers thin.
- Place business rules in domain services.
- Place database logic in repositories or data access modules.
- Use middleware or guards for authentication and role checks.
- Use centralized error handling.
- Use centralized validation schemas.
- Use transactions for multi-step workflow changes.
- Create audit logs inside the same transaction where possible.
- Ensure student-facing APIs apply visibility filters.
- Ensure AI APIs never publish directly to Students.

---

## 39. Notes for Testing

API tests should verify:

- Authentication requirements.
- Authorization by role.
- Teacher approval requirements.
- Staff self-review prevention.
- Admin-only governance protection.
- Material status transitions.
- Student visibility filtering.
- AI draft and Teacher review workflow.
- Quiz attempt submission and duplicate submission prevention.
- Audit log creation for important actions.
- Error response consistency.

Recommended test types:

- Unit tests for service-level rules.
- Integration tests for API endpoints.
- End-to-end tests for core workflows.
- Security tests for unauthorized access.
- Regression tests for visibility filtering.

---

## 40. Next Document

The next recommended document is:

`10-non-functional-requirements.md`

That document should define system qualities such as:

- Performance.
- Security.
- Reliability.
- Scalability.
- Availability.
- Maintainability.
- Privacy.
- Accessibility.
- Observability.
- AI safety.
- Data protection.

The API design should remain aligned with all previous HIPZI documents and should protect the core product principle:

> HIPZI must provide safe AI-assisted learning while preserving human review, Staff moderation, Admin governance, and Student access to approved educational content only.