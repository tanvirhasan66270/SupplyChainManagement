# Plan 007: Fix Password Validation and Add Missing @Transactional

**Category:** Security/Quality
**Impact:** MEDIUM
**Effort:** S (Small)
**Risk:** Low
**Confidence:** HIGH

## Problem

Two issues in `AuthService.java`:

1. **Weak password validation (line 163)** - Minimum password length is only 4 characters. Industry standard is 8+ characters with complexity requirements.

2. **Missing @Transactional annotations** - `forgotPassword()` and `resetPassword()` methods modify data but lack `@Transactional` annotation. The `verifyEmail()` method already has it (line 107).

## Fix

### Fix 1: Strengthen password validation

**File:** `src/main/java/com/example/SCM/auth/AuthService.java`

Replace lines 163-164:
```java
// Before:
if (dto.getNewPassword() == null || dto.getNewPassword().length() < 4) {
    throw new RuntimeException("Password must be at least 4 characters");
}

// After:
if (dto.getNewPassword() == null || dto.getNewPassword().length() < 8) {
    throw new RuntimeException("Password must be at least 8 characters");
}
if (!dto.getNewPassword().matches(".*[A-Z].*")) {
    throw new RuntimeException("Password must contain at least one uppercase letter");
}
if (!dto.getNewPassword().matches(".*[a-z].*")) {
    throw new RuntimeException("Password must contain at least one lowercase letter");
}
if (!dto.getNewPassword().matches(".*\\d.*")) {
    throw new RuntimeException("Password must contain at least one digit");
}
```

### Fix 2: Add @Transactional to forgotPassword()

**File:** `src/main/java/com/example/SCM/auth/AuthService.java`

Add `@Transactional` annotation before line 145:
```java
// Before:
public void forgotPassword(ForgotPasswordRequestDTO dto) {

// After:
@Transactional
public void forgotPassword(ForgotPasswordRequestDTO dto) {
```

### Fix 3: Add @Transactional to resetPassword()

**File:** `src/main/java/com/example/SCM/auth/AuthService.java`

Add `@Transactional` annotation before line 158:
```java
// Before:
public void resetPassword(ResetPasswordRequestDTO dto) {

// After:
@Transactional
public void resetPassword(ResetPasswordRequestDTO dto) {
```

## Files in Scope

1. `src/main/java/com/example/SCM/auth/AuthService.java`

## Files Out of Scope

- No other files should be modified
- The `@Transactional` import already exists (line 39)

## Verification

After making all changes, run:
```bash
mvn compile -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: BUILD SUCCESS with no compilation errors.

## Test Plan

1. Test password reset with a weak password (e.g., "abc") - should fail with validation error
2. Test password reset with a strong password (e.g., "Abcdef1!") - should succeed
3. Test forgot password flow to verify @Transactional works correctly
4. Verify that failed password resets are properly rolled back

## Maintenance Note

- Consider adding password validation to user registration as well (if applicable)
- The password validation regex can be made configurable via application.properties
- For production, consider using a password strength library (e.g., zxcvbn)
- The `@Transactional` annotation ensures that if `userRepository.save()` fails, the entire operation is rolled back

## Escape Hatches

- If existing users cannot reset passwords, check if the new validation is too strict
- If password validation is handled elsewhere (e.g., frontend), consider making backend validation configurable
- If the application uses Spring Security's `@Validated`, consider moving validation there
