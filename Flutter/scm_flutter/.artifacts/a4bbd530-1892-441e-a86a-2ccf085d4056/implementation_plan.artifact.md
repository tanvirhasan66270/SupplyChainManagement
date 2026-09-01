# Implement Sales Officer Profile Screen

The goal is to create a fully dynamic profile screen for the Sales Officer role in Flutter, mirroring the functionality and data fields found in the provided Angular code and following the established Flutter profile patterns (e.g., `CustomerProfileScreen`).

## Proposed Changes

### [sales_officer]

#### [NEW] [sales_officer_profile_screen.dart](file:///F:/flutter/Flutter/scm_flutter/lib/sales_officer/screen/sales_officer_profile_screen.dart)
- Create a `ConsumerStatefulWidget` to display and edit the Sales Officer's profile.
- Fetch profile data using `currentSalesOfficerProvider`.
- Implement text controllers for: `name`, `email`, `phone`, `designation`, `nidNumber`, `dob`, `joiningDate`, `language`, and `address`.
- Implement image picking and uploading using `ImagePicker` and `SalesOfficerRepository.update`.
- Support field validation and error handling (e.g., duplicate entries).
- Include sections for "Personal Registry Details" and "Logistics & Location Metadata".

### [route]

#### [MODIFY] [appRoute.dart](file:///F:/flutter/Flutter/scm_flutter/lib/route/appRoute.dart)
- Import `SalesOfficerProfileScreen`.
- Add a route for `/sales-officer-profile` (if needed) or update the role-based dashboard navigation to include the profile option.
- Update `_RequireAuth` to handle the `SALES_OFFICER` role if necessary.

## Verification Plan

### Manual Verification
- Navigate to the Sales Officer Profile screen.
- Verify that data is correctly fetched and displayed.
- Test the "Edit" mode:
    - Change text fields and save.
    - Pick a new image and upload.
    - Verify that changes persist after a refresh (invalidation of provider).
- Test validation (e.g., empty mandatory fields).
