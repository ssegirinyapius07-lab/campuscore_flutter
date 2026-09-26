# CampusCore Authentication API

This document defines the contract between the Flutter client and the CampusCore backend.

## Login

`POST /api/auth/login/`

Request:

```json
{
  "identifier": "BACS/M/25D/UG/001",
  "password": "user-password"
}
```

Successful response:

```json
{
  "access": "access-token",
  "user_id": "123",
  "role": "student",
  "display_name": "John Mukasa"
}
```

The Flutter client does not decide whether a password is valid. The backend is responsible for credential validation, account status, role assignment, rate limiting, and audit logging.

## Logout

`POST /api/auth/logout/`

Header:

```text
Authorization: Bearer <access-token>
```

## Planned authentication rules

- Passwords are stored and verified only by the backend using secure password hashing.
- The Flutter client must never store a plaintext password.
- Roles are assigned by the backend and must not be trusted from client-side input.
- Login failures should be rate-limited by the backend.
- Protected API endpoints must validate the access token server-side.
- Password reset and first-login password changes will be handled by the backend.
