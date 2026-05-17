# C12: Password Validation + Passkey Support

**Repo:** `zice-core`
**Type:** Backend
**Priority:** High
**Milestone:** M2
**Est. Size:** Small (26-200 LOC)
**Blocked by:** C5 (Auth middleware), C6 (Auth API endpoints)
**Blocks:** F6 (Password strength meter + passkey UI)

## Description

Add server-side password strength validation to the auth signup and password change handlers. Ensure the Go API correctly accepts JWTs issued via passkey authentication (no special handling needed — JWT validation is method-agnostic).

## Acceptance Criteria

- [ ] `PasswordPolicy` struct with configurable rules: MinLength(10), RequireUppercase, RequireLowercase, RequireDigit, RequireSymbol
- [ ] `ValidatePassword()` function returns array of violation messages
- [ ] `POST /api/v1/auth/signup` validates password before proxying to Supabase
- [ ] `PUT /api/v1/auth/password` (password change) validates new password
- [ ] Password validation errors returned as structured JSON with specific violation reasons
- [ ] Passkey-issued JWTs accepted without changes (verify existing JWT validation is method-agnostic)
- [ ] Unit tests for all password policy rules and edge cases
- [ ] Unit test confirming passkey JWTs are accepted

## Technical Details

### Password Policy

```go
type PasswordPolicy struct {
    MinLength        int  // 10
    RequireUppercase bool // true
    RequireLowercase bool // true
    RequireDigit     bool // true
    RequireSymbol    bool // true
}

var DefaultPolicy = PasswordPolicy{
    MinLength: 10, RequireUppercase: true,
    RequireLowercase: true, RequireDigit: true, RequireSymbol: true,
}
```

### Allowed Symbols

`!@#$%^&*()_+-=[]{};'\:"|<>?,./~`

## Design Reference

See design doc Section 18.1: Strong Password Enforcement
