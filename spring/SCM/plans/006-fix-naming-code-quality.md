# Plan 006: Fix Naming Inconsistencies and Code Quality

**Category:** DX/Quality
**Impact:** LOW
**Effort:** S (Small)
**Risk:** Low
**Confidence:** HIGH

## Problem

Several naming inconsistencies and code quality issues:

1. **QuotationServiceImpl.java** - Class name uses `Impl` (with lowercase 'l') while all other 39 service implementations use `Imp` (without 'l'). The file is also named `QuotationServiceImpl.java` instead of `QuotationServiceImp.java`.

2. **MessageServiceImp.java** - Does not implement any interface, breaking the consistent Interface-Implementation pattern used by all other services.

3. **application.properties:21** - Hardcoded file upload path with typo "Assats" (should be "Assets").

## Fix

### Fix 1: Rename QuotationServiceImpl to QuotationServiceImp

**Note:** This is a file rename AND class rename. Be careful with references.

1. Rename the file:
   - From: `src/main/java/com/example/SCM/serviceImp/QuotationServiceImpl.java`
   - To: `src/main/java/com/example/SCM/serviceImp/QuotationServiceImp.java`

2. Inside the file, rename the class:
   ```java
   // Before:
   public class QuotationServiceImpl implements QuotationService {
   
   // After:
   public class QuotationServiceImp implements QuotationService {
   ```

3. Search for any references to `QuotationServiceImpl` in other files and update them:
   ```bash
   grep -r "QuotationServiceImpl" src/
   ```

### Fix 2: Create MessageService interface (optional, for consistency)

**Note:** This is optional but recommended for consistency.

1. Create `src/main/java/com/example/SCM/service/MessageService.java`:
   ```java
   package com.example.SCM.service;
   
   import com.example.SCM.dto.request.MessageRequestDTO;
   import com.example.SCM.dto.response.MessageResponseDTO;
   import com.example.SCM.entity.User;
   
   import java.util.List;
   
   public interface MessageService {
       List<MessageResponseDTO> sendMessage(MessageRequestDTO dto, User currentUser);
       List<MessageResponseDTO> getInbox(String userId);
       void markAsRead(Long id);
   }
   ```

2. Update `MessageServiceImp.java` to implement the interface:
   ```java
   // Before:
   public class MessageServiceImp {
   
   // After:
   public class MessageServiceImp implements MessageService {
   ```

### Fix 3: Fix typo in upload path

**File:** `src/main/resources/application.properties`

Replace line 21:
```properties
# Before:
image.upload.dir=E:/spring/Spring-boot/sp-2 security/Assats

# After:
image.upload.dir=E:/spring/Spring-boot/sp-2 security/Assets
```

**Note:** This only fixes the typo. The path is still hardcoded and should be externalized (covered in Plan 004).

## Files in Scope

1. `src/main/java/com/example/SCM/serviceImp/QuotationServiceImpl.java` (rename to QuotationServiceImp.java)
2. `src/main/java/com/example/SCM/service/MessageService.java` (new file, optional)
3. `src/main/java/com/example/SCM/serviceImp/MessageServiceImp.java` (add implements)
4. `src/main/resources/application.properties` (fix typo)

## Files Out of Scope

- No other files should be modified
- Do NOT rename other service implementations - they are already consistent

## Verification

After making all changes, run:
```bash
mvn compile -f "E:\spring\Spring-boot\sp-2 security\SCM\pom.xml"
```

Expected: BUILD SUCCESS with no compilation errors.

## Test Plan

1. After renaming QuotationServiceImpl, verify all Quotation endpoints still work
2. After creating MessageService interface, verify MessageController still works
3. After fixing the upload path typo, verify file uploads work (if the Assets directory exists)

## Maintenance Note

- Follow the `*ServiceImp` naming convention for all new service implementations
- Always create an interface for new services
- Use relative paths or environment variables for file paths
- The directory must be renamed from "Assats" to "Assets" on the filesystem as well

## Escape Hatches

- If QuotationServiceImp references break, check all files that import or reference `QuotationServiceImpl`
- If file uploads fail after fixing the path typo, verify the `Assets` directory exists at the specified location
