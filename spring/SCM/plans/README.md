# SCM Improvement Plans

**Project:** Spring Boot 4.0.6 Supply Chain Management (SCM)
**Generated:** 2026-07-13
**Base Package:** `com.example.SCM`

## Priority Order & Dependencies

| # | Plan | Category | Impact | Effort | Status |
|---|------|----------|--------|--------|--------|
| 001 | [Fix SecurityConfig wildcard](001-fix-security-wildcard.md) | Security | CRITICAL | S | DONE |
| 002 | [Fix ObjectMapper imports](002-fix-objectmapper-imports.md) | Compilation | CRITICAL | S | DONE |
| 003 | [Remove controller CORS wildcard](003-remove-controller-cors.md) | Security | HIGH | M | DONE |
| 004 | [Externalize credentials](004-externalize-credentials.md) | Security | HIGH | M | DONE |
| 005 | [Fix entity/repository bugs](005-fix-entity-repository-bugs.md) | Correctness | MEDIUM | S | DONE |
| 006 | [Fix naming & code quality](006-fix-naming-code-quality.md) | DX/Quality | LOW | S | DONE |
| 007 | [Fix password validation & transactions](007-fix-password-tx.md) | Security/Quality | MEDIUM | S | DONE |

## Dependency Graph

```
Plan 001 (SecurityConfig) ← Plan 003 (CORS controllers)
Plan 004 (Credentials) - independent
Plan 002 (ObjectMapper) - independent
Plan 005 (Entity/Repo) - independent
Plan 006 (Naming) - independent
Plan 007 (Password/TX) - independent
```

## Execution Summary

All 7 plans have been executed successfully:

1. **Plan 001** - Removed `/**` wildcard from SecurityConfig.permitAll()
2. **Plan 002** - Fixed `tools.jackson.databind.ObjectMapper` → `com.fasterxml.jackson.databind.ObjectMapper` in 12 controllers
3. **Plan 003** - Removed `@CrossOrigin("*")` from 38 controllers
4. **Plan 004** - Externalized credentials to environment variables in application.properties
5. **Plan 005** - Fixed @Temporal on String field, removed invalid repository method, fixed typos
6. **Plan 006** - Renamed QuotationServiceImpl → QuotationServiceImp for consistency
7. **Plan 007** - Strengthened password validation (min 8 chars + complexity) and added @Transactional

## What Was NOT Audited

- Full test coverage analysis (only 2 test files exist)
- Deployment pipeline (no CI config found)
- Frontend TypeScript file (`scm-interfaces.ts`) alignment with backend
- Performance profiling (no runtime data available)
- Database migration strategy (uses `ddl-auto=update`)

## Important Notes

**ROTATE CREDENTIALS** - The old hardcoded credentials are still in git history. You should:
1. Change database password
2. Change email app password
3. Generate a new JWT secret (at least 256 bits)
4. Change Spring Security user password

## Considered and Rejected Findings

None at this time.
