# Plan 005: Fix Entity and Repository Bugs

**Category:** Correctness
**Impact:** MEDIUM
**Effort:** S (Small)
**Risk:** Low
**Confidence:** HIGH

## Problem

Three correctness issues in entity and repository files:

1. **Supplier.java:37-38** - `@Temporal(TemporalType.DATE)` annotation on a `String` field. `@Temporal` is only valid on `java.util.Date` or `java.util.Calendar` types.

2. **UserRepository.java:26** - Invalid method signature `Role Role(Role role);` which is semantically meaningless and will cause Spring Data query derivation errors.

3. **CustomUserDetailsService.java:37** - Typos in error message: "Accoun" should be "Account", "contuct" should be "contact".

## Fix

### Fix 1: Remove @Temporal from Supplier.java

**File:** `src/main/java/com/example/SCM/entity/Supplier.java`

Remove lines 37-38:
```java
// Before:
@Temporal(TemporalType.DATE)
private String dob;

// After:
private String dob;
```

### Fix 2: Remove invalid method from UserRepository.java

**File:** `src/main/java/com/example/SCM/repository/UserRepository.java`

Remove line 26:
```java
// Before:
Role Role(Role role);

// After: (remove the line entirely)
```

### Fix 3: Fix typos in CustomUserDetailsService.java

**File:** `src/main/java/com/example/SCM/serviceImp/CustomUserDetailsService.java`

Replace line 37:
```java
// Before:
"User Accoun is inactive please contuct Manager"

// After:
"User Account is inactive please contact Manager"
```

## Files in Scope

1. `src/main/java/com/example/SCM/entity/Supplier.java`
2. `src/main/java/com/example/SCM/repository/UserRepository.java`
3. `src/main/java/com/example/SCM/serviceImp/CustomUserDetailsService.java`

## Files Out of Scope

- No other files should be modified

## Verification

After making all changes, run:
```bash
mvn compile -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: BUILD SUCCESS with no compilation errors.

## Test Plan

1. After fixing Supplier.java, verify the entity still maps correctly to the database table
2. After fixing UserRepository.java, verify Spring Data can still derive queries
3. After fixing CustomUserDetailsService.java, test login with an inactive account to see the corrected error message

## Maintenance Note

- The `dob` field in Supplier is stored as a String - consider changing it to `LocalDate` for better type safety in the future
- The removed `Role Role(Role role)` method was never used - verify no code references it
- Always proofread error messages before committing

## Escape Hatches

- If Spring Data fails to start after removing the `Role Role(Role role)` method, check if any code was calling it (unlikely)
- If the Supplier entity fails to persist, check that the `dob` field format matches the database column type
