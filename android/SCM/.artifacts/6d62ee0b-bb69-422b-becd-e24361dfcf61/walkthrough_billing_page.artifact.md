# Walkthrough - Billing Ledger Implementation

I have implemented the **Billing Ledger** page as per the provided high-fidelity design. This page provides a clear overview of financial status and detailed invoice tracking.

## Changes Made

### UI Resources
- **Colors**: Added specialized colors for financial status and quick actions:
    - `orange_partially_paid`, `green_paid`, `green_issued`.
    - Soft background colors for action icons (`blue_soft_bg`, etc.).
- **Icons**: Created vector drawables for `ic_download`, `ic_filter`, `ic_invoice`, and `ic_chevron_right`.
- **Backgrounds**: Created `bg_search_bar.xml` and updated status badge drawables to support the new billing statuses.

### Layout
- **[activity_billing_page.xml](file:///E:/Android/Android/SCM/app/src/main/res/layout/activity_billing_page.xml)**:
    - **Header**: Includes branding and user profile access.
    - **Balance Dashboard**: A prominent card showing the "Outstanding Balance" with a detailed breakdown of invoices, paid, and due amounts.
    - **Search & Filter Area**: A clean search bar with a professional filter button.
    - **Invoice List**: Implemented detailed cards for each invoice entry, including customer info, order IDs, status badges (PARTIALLY PAID, ISSUED, PAID), and financial summaries.
    - **Quick Actions**: A footer section for common financial tasks (Download Statement, Payment History, etc.).
    - **Sticky Bottom Navigation**: Ensuring "Billing" is highlighted as the active tab.

### Navigation logic
- **[BillingPage.kt](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/BillingPage.kt)**: Added logic to handle bottom navigation and edge-to-edge rendering.
- **[Dashboard_Activity.java](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/Dashboard_Activity.java)**: Linked the "Billing Ledger" grid item and the "Billing" bottom navigation item.
- **[tracking_Dashboard.kt](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/tracking_Dashboard.kt)**: Updated bottom navigation to lead to the Billing page.

## Verification
- Verified that all financial labels and amounts match the design specifications.
- Confirmed that the page is fully scrollable and correctly respects system window insets.
- Validated navigation flows between Dashboard, Orders, Shipments (Tracking), and Billing.
