# Plan 002: Fix Wrong ObjectMapper Imports

**Category:** Compilation Error
**Impact:** CRITICAL
**Effort:** S (Small)
**Risk:** Low
**Confidence:** HIGH

## Problem

12 controller files import `tools.jackson.databind.ObjectMapper` which is the Jackson 3.x alpha namespace. The project uses Spring Boot 4.0.6 which ships with Jackson 2.x (`com.fasterxml.jackson.databind.ObjectMapper`). This causes a compilation error because the Jackson 3.x `tools` artifact is not on the classpath.

## Affected Files

All under `src/main/java/com/example/SCM/controller/`:

1. `ProcurementController.java` (line 13)
2. `CommercialOfficerController.java` (line 13)
3. `SupplierController.java` (line 14)
4. `SalesOfficerController.java` (line 12)
5. `LogisticsOfficerController.java` (line 14)
6. `DriverController.java` (line 13)
7. `ManagerController.java` (line 13)
8. `QCInspectionController.java` (line 12)
9. `LetterOfCreditController.java` (line 12)
10. `ProductController.java` (line 11)
11. `QuotationController.java` (line 13)
12. `ShipmentController.java` (line 12)

## Fix

### Step 1: Replace import in each file

In each of the 12 files, replace:
```java
import tools.jackson.databind.ObjectMapper;
```

With:
```java
import com.fasterxml.jackson.databind.ObjectMapper;
```

**Example - SupplierController.java:**

Before:
```java
import tools.jackson.databind.ObjectMapper;
```

After:
```java
import com.fasterxml.jackson.databind.ObjectMapper;
```

## Files in Scope

Only the 12 controller files listed above.

## Files Out of Scope

- No other files should be modified
- Do NOT change any logic, only the import statement

## Verification

After making all changes, run:
```bash
mvn compile -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: BUILD SUCCESS with no compilation errors.

If there are still errors, check that `com.fasterxml.jackson.databind.ObjectMapper` is available in the classpath (it should be via Spring Boot's Jackson auto-configuration).

## Test Plan

1. After fixing imports, run `mvn compile` to verify no compilation errors
2. Start the application and test one of the affected controllers (e.g., `POST /api/suppliers` with multipart data) to verify ObjectMapper still works correctly
3. The ObjectMapper functionality should be identical - only the package changed

## Maintenance Note

- The Jackson 2.x ObjectMapper is the standard for Spring Boot applications
- Jackson 3.x is still in alpha and should not be used in production
- If upgrading to Jackson 3.x in the future, update ALL imports at once

## Escape Hatches

- If `mvn compile` still fails after fixing imports, check if there are other missing dependencies in pom.xml
- If the ObjectMapper behaves differently, check Jackson version compatibility (Jackson 2.x vs 3.x API differences)
