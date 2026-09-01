# Sales Officer Profile Implementation

I have implemented a fully dynamic Sales Officer Profile screen in Flutter, based on the patterns found in the project and the provided Angular code.

## Changes Made

### [sales_officer]

#### [NEW] [sales_officer_profile_screen.dart](file:///F:/flutter/Flutter/scm_flutter/lib/sales_officer/screen/sales_officer_profile_screen.dart)
- Created a comprehensive profile screen for the Sales Officer role.
- **Dynamic Data**: Uses `currentSalesOfficerProvider` to fetch real-time profile data.
- **Editing Mode**: Allows editing of personal and staff registry details (Name, Designation, Email, Phone, Gender, DOB, Joining Date, Language, NID, Address).
- **Image Management**: Supports picking and uploading a profile avatar.
- **Completion Indicator**: Shows a visual progress bar of profile completion.
- **Location Metadata**: Displays territorial node info (Police Station).

### [route]

#### [MODIFY] [appRoute.dart](file:///F:/flutter/Flutter/scm_flutter/lib/route/appRoute.dart)
- Added import for `SalesOfficerProfileScreen`.
- Added role-based redirection for `SALES_OFFICER` and `ROLE_SALES_OFFICER`.
- Added named route `/sales-officer-profile` with `_RequireAuth` guard.

## Verification Results

- The `SalesOfficerProfileScreen` was successfully created and linked.
- The screen follows the project's theme and widget structure.
- Logic for updating the profile via `SalesOfficerRepository` is implemented and handles both data and multipart image files.

> [!TIP]
> To access the profile screen, the user must be logged in with a `SALES_OFFICER` role. The dashboard will automatically redirect to this screen for now.
