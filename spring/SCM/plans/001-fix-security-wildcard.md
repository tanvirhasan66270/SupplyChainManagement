# Plan 001: Fix SecurityConfig Wildcard PermitAll

**Category:** Security
**Impact:** CRITICAL
**Effort:** S (Small)
**Risk:** Low
**Confidence:** HIGH

## Problem

The `SecurityConfig` at `src/main/java/com/example/SCM/security/security/SecurityConfig.java:53` has `"/**"` in the `permitAll()` matcher list. This effectively disables ALL security on every endpoint in the application. Any unauthenticated user can access any API endpoint without a JWT token.

Current vulnerable code:
```java
.requestMatchers("/api/auth/login",
    "/api/customerOrders/track",
    "/api/drivers",
    "/api/customers",
    "/**", "/images/**").permitAll()
```

## Fix

### Step 1: Remove the `"/**"` pattern

**File:** `src/main/java/com/example/SCM/security/SecurityConfig.java`

Replace lines 48-53 with:
```java
// ── Public endpoints (no token needed) ────────────
.requestMatchers("/api/auth/login",
        "/api/customerOrders/track",
        "/api/drivers",
        "/api/customers",
        "/images/**").permitAll()
```

### Step 2: Add explicit denyAll fallback (optional but recommended)

After the `.permitAll()` block and before `.authenticationProvider(...)`, add:
```java
.anyRequest().authenticated()
```

Full corrected security filter chain:
```java
http
    .cors(cors -> cors.configurationSource(corsConfigurationSource()))
    .csrf(AbstractHttpConfigurer::disable)
    .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
    .authorizeHttpRequests(auth -> auth
        // ── Public endpoints (no token needed) ────────────
        .requestMatchers("/api/auth/login",
                "/api/customerOrders/track",
                "/api/drivers",
                "/api/customers",
                "/images/**").permitAll()
        // ── Everything else requires authentication ───────
        .anyRequest().authenticated()
    )
    .authenticationProvider(authenticationProvider())
    .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
```

## Files in Scope

- `src/main/java/com/example/SCM/security/SecurityConfig.java` (only this file)

## Files Out of Scope

- All other files should not be touched

## Verification

After making the change, run:
```bash
mvn compile -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: BUILD SUCCESS with no compilation errors.

Then verify the security config by checking that unauthenticated requests to protected endpoints return 403:
```bash
curl -v http://localhost:8085/api/products
```
Expected: 403 Forbidden (not 200 OK)

## Test Plan

1. Start the application
2. Verify public endpoints still work: `curl http://localhost:8085/api/auth/login` should not return 403
3. Verify protected endpoints require auth: `curl http://localhost:8085/api/products` should return 403
4. Verify login still works with valid credentials

## Maintenance Note

- If new public endpoints are needed in the future, add them to the `requestMatchers` list explicitly
- Never use `"/**"` in `permitAll()` - it defeats the purpose of having security
- The `"/images/**"` pattern is kept as it serves static resources

## Escape Hatches

- If the application fails to start after this change, check that the `anyRequest().authenticated()` line is properly placed
- If Angular frontend requests fail, ensure the Angular app sends the JWT token in the Authorization header for protected endpoints
