# Plan 003: Remove @CrossOrigin("*") from Controllers

**Category:** Security
**Impact:** HIGH
**Effort:** M (Medium)
**Risk:** Low
**Confidence:** HIGH

## Problem

38 controller files have `@CrossOrigin(origins = "*")` or `@CrossOrigin("*")` annotations. This overrides the more restrictive CORS configuration in `SecurityConfig.java` (which only allows `localhost:4200` and `192.168.88.250:4200`). The wildcard CORS makes the SecurityConfig CORS configuration useless and allows any origin to make requests.

## Affected Files

All 38 controllers under `src/main/java/com/example/SCM/controller/`:

1. ProcurementController.java (line 20)
2. CommercialOfficerController.java (line 20)
3. SupplierController.java (line 21)
4. SalesOfficerController.java (line 19)
5. QCInspectorController.java (line 18)
6. LogisticsOfficerController.java (line 21)
7. DriverController.java (line 20)
8. CustomerController.java (line 19)
9. ManagerController.java (line 20)
10. DailyReportController.java (line 24)
11. MessageController.java (line 17)
12. NotificationController.java (line 14)
13. StockMovementController.java (line 16)
14. DeliveryTripController.java (line 18)
15. QCInspectionController.java (line 19)
16. PurchaseOrderController.java (line 16)
17. CustomerOrderController.java (line 16)
18. CountryController.java (line 16)
19. DistrictController.java (line 16)
20. DivisionController.java (line 16)
21. PoliceStationController.java (line 16)
22. WarehouseController.java (line 16)
23. LetterOfCreditController.java (line 19)
24. PurchaseRequisitionController.java (line 16)
25. LCBankController.java (line 16)
26. GRNLineItemController.java (line 16)
27. GoodsReceivedNoteController.java (line 16)
28. OrderLineItemController.java (line 14)
29. VehicleController.java (line 16)
30. QCChecklistController.java (line 16)
31. ShipmentController.java (line 19)
32. InvoiceController.java (line 16)
33. QuotationController.java (line 20)
34. InventoryController.java (line 16)
35. ProductController.java (line 18)
36. ActivityLogController.java (line 15)
37. CategoryController.java (line 16)
38. POLineItemController.java (line 16)

## Fix

### Step 1: Remove @CrossOrigin annotation from each controller

In each of the 38 files, remove the `@CrossOrigin` line entirely. The CORS is already handled centrally in `SecurityConfig.java`.

**Example - ProcurementController.java:**

Before:
```java
@RestController
@RequestMapping("/api/procurements")
@RequiredArgsConstructor
@CrossOrigin("*")
public class ProcurementController {
```

After:
```java
@RestController
@RequestMapping("/api/procurements")
@RequiredArgsConstructor
public class ProcurementController {
```

### Step 2: Also remove unused Spring Web import if present

After removing `@CrossOrigin`, check if the `org.springframework.web.bind.annotation.CrossOrigin` import can be removed. However, since the `@RestController` and `@RequestMapping` annotations come from the same package, the wildcard import `org.springframework.web.bind.annotation.*` usually covers it. Only remove the specific `CrossOrigin` import if it's a standalone import.

## Files in Scope

Only the 38 controller files listed above.

## Files Out of Scope

- `SecurityConfig.java` - the CORS config there is correct
- No other files should be modified

## Verification

After making all changes, run:
```bash
mvn compile -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: BUILD SUCCESS with no compilation errors.

## Test Plan

1. After removing all `@CrossOrigin` annotations, start the application
2. Test from Angular frontend (localhost:4200) - requests should work normally
3. Test from a different origin (e.g., localhost:3000) - requests should be blocked by CORS
4. Verify that the SecurityConfig CORS settings are now being enforced

## Maintenance Note

- CORS is now managed centrally in `SecurityConfig.java`
- If new origins need to be allowed, add them to `SecurityConfig.corsConfigurationSource()`
- Never use `@CrossOrigin("*")` in controllers when centralized CORS is configured
- If a controller needs different CORS settings, use specific origins: `@CrossOrigin(origins = "http://localhost:4200")`

## Escape Hatches

- If Angular frontend requests fail after this change, check that the Angular app is running on `localhost:4200` (which is allowed in SecurityConfig)
- If you need to temporarily allow all origins during development, modify SecurityConfig instead of adding `@CrossOrigin("*")` back
