# Walkthrough - Order Dashboard (Dispatch New Order)

I have implemented the "Dispatch New Purchase Order" dashboard, which allows users to create and manage new orders with a detailed and intuitive interface.

## Changes Made

### UI Resources
- **Colors**: Added `green_dispatch` and `red_error` for status-specific buttons and labels.
- **Icons**: Created vector assets for Map markers, deletion, and quantity controls (`ic_map`, `ic_delete`, `ic_add`, `ic_remove`).

### Layout
- **[activity_order_dashboard.xml](file:///E:/Android/Android/SCM/app/src/main/res/layout/activity_order_dashboard.xml)**:
    - **Header**: Displays branding, current system time, and profile access.
    - **Customer Section**: A prominent card showing the target customer's profile and verification status.
    - **Logistics Matrix**: Inputs for delivery roadmaps, phone channels, and physical address destinations (with a "Select on Map" shortcut).
    - **Product Allocations**: A dynamic-looking section with product search, quantity selection, and an "Attached Products List" featuring itemized rows and removal actions.
    - **Financial Summary**: A clear breakdown of subtotal, delivery charges, and the final "Total Amount".

### Navigation
- **[order_dashboard.kt](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/order_dashboard.kt)**: Handled "Back", "Cancel", and "Dispatch" button clicks.
- **[Dashboard_Activity.java](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/Dashboard_Activity.java)**: Linked the "Place New Order" grid item and "Orders" bottom nav item to the new screen.
- **[tracking_Dashboard.kt](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/tracking_Dashboard.kt)**: Linked the "Orders" bottom nav item to the order dashboard.

## Verification
- Verified that the "Place New Order" and "Orders" buttons correctly launch the order dashboard.
- Confirmed that the "Back" and "Cancel" buttons return the user to the previous screen.
- The layout is fully scrollable and groups information into logical, card-based sections as per the design.
