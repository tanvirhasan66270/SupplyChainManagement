# Plan 004: Externalize Hardcoded Credentials

**Category:** Security
**Impact:** HIGH
**Effort:** M (Medium)
**Risk:** Medium
**Confidence:** HIGH

## Problem

`application.properties` contains hardcoded credentials:
- Database username/password (line 6-7)
- Email credentials (line 32-33)
- JWT secret key (line 46)
- Spring Security user credentials (line 43-44)

These should be externalized via environment variables to prevent credential leakage in version control.

**IMPORTANT:** The credentials must be rotated (changed) after this fix, as they have been committed to the repository.

## Files Affected

- `src/main/resources/application.properties`

## Fix

### Step 1: Replace hardcoded values with environment variable placeholders

**File:** `src/main/resources/application.properties`

Replace lines 6-7 (database credentials):
```properties
# Before:
spring.datasource.username=root
spring.datasource.password=1234

# After:
spring.datasource.username=${DB_USERNAME:root}
spring.datasource.password=${DB_PASSWORD:changeme}
```

Replace lines 32-33 (email credentials):
```properties
# Before:
spring.mail.username=tanvirhasan66270
spring.mail.password=ebdv qkrn pwgx yvzl

# After:
spring.mail.username=${MAIL_USERNAME:}
spring.mail.password=${MAIL_PASSWORD:}
```

Replace line 43-44 (Spring Security):
```properties
# Before:
spring.security.user.name=admin
spring.security.user.password=1234

# After:
spring.security.user.name=${SECURITY_USER_NAME:admin}
spring.security.user.password=${SECURITY_USER_PASSWORD:changeme}
```

Replace line 46 (JWT secret):
```properties
# Before:
jwt.secret=9aH4fX7vK3mQ9zB2wE5rTanvir8yU1iO4p7aS0dF3gG6hJ9kL2zX5cC8vB1nM4b7vC9xZ6wQ3eR2tY1

# After:
jwt.secret=${JWT_SECRET:changeme-use-a-real-secret}
```

### Step 2: Create a local development properties file (optional)

Create `src/main/resources/application-local.properties` for local development:
```properties
# Local development only - DO NOT commit this file
spring.datasource.username=root
spring.datasource.password=your_local_password
spring.mail.username=your_email
spring.mail.password=your_app_password
jwt.secret=your_jwt_secret_at_least_256_bits
```

### Step 3: Update .gitignore

Add to `.gitignore`:
```
# Local properties with credentials
src/main/resources/application-local.properties
```

## Files in Scope

- `src/main/resources/application.properties`
- `src/main/resources/application-local.properties` (new file)
- `.gitignore`

## Files Out of Scope

- No Java files should be modified
- No other configuration files

## Verification

1. Set environment variables:
```bash
# Windows PowerShell
$env:DB_USERNAME="root"
$env:DB_PASSWORD="your_password"
$env:MAIL_USERNAME="your_email"
$env:MAIL_PASSWORD="your_app_password"
$env:JWT_SECRET="your_256_bit_secret"
$env:SECURITY_USER_NAME="admin"
$env:SECURITY_USER_PASSWORD="your_password"
```

2. Run the application:
```bash
mvn spring-boot:run -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: Application starts successfully and can connect to the database.

## Test Plan

1. Start the application with environment variables set
2. Test login endpoint to verify JWT secret works
3. Test email sending to verify mail credentials work
4. Verify database connection works

## Maintenance Note

- **ROTATE ALL CREDENTIALS** after this change - the old values are in git history
- Use a secrets manager (e.g., AWS Secrets Manager, HashiCorp Vault) for production
- Never commit real credentials to version control
- The `${VAR:default}` syntax means: use env var `VAR`, fallback to `default` if not set
- For production, do NOT provide defaults - force the env vars to be set

## Escape Hatches

- If the application fails to start, check that all required environment variables are set
- If using an IDE, configure environment variables in the run configuration
- If deploying to a server, configure environment variables in the deployment script
