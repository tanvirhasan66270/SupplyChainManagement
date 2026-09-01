# Implementation Plan - Standardize Billing Page Header

Update the `BillingPage` header to match the provided design (Logo on left, Notification and Profile on right) and ensure it follows the app's standard high-fidelity style.

## Proposed Changes

### Layout Layer

#### [MODIFY] [activity_billing_page.xml](file:///E:/Android/Android/SCM/app/src/main/res/layout/activity_billing_page.xml)
- **Header Refinement**:
    - Set header height to `56dp` (standard toolbar height).
    - Remove the `btnMenu` icon to match the design screenshot.
    - Align the **Logo** (`ivLogo`) to the left.
    - Group the **Notification icon** and **Profile image** on the right.
    - Style the profile image (`profileImage`) to be `32dp x 32dp`.

### Activity Layer

#### [MODIFY] [BillingPage.java](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/BillingPage.java)
- **Inset Logic**:
    - Implement the same dynamic inset padding logic as used in `OrderDashboardActivity` to ensure the header background flows behind the status bar correctly.
- **Navigation logic**:
    - Ensure the Home icon or Logo navigation (if applicable) is consistent.
- **Data Binding**:
    - Ensure the user's profile photo is loaded into `profileImage` using Glide (this is already partially implemented but needs to be verified with the updated layout).

## Verification Plan

### Automated Tests
- Run `gradle_build assembleDebug` to verify compilation.

### Manual Verification
- Deploy to emulator.
- Open the Billing screen.
- Verify the header looks identical in height and layout to the provided design.
- Verify the profile photo is loaded and circular.
