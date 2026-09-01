# Implementation Plan - Fix Billing Statement PDF

Complete the implementation of the `generateStatementPdf` method in `PdfGenerator.java` to create a professional and data-rich billing statement report.

## User Review Required

> [!NOTE]
> The statement report will summarize all filtered invoices currently visible on the Billing Page. It will include a summary header and a detailed table of transactions.

## Proposed Changes

### 1. Enhanced Statement PDF Generation
#### [MODIFY] [PdfGenerator.java](file:///E:/Android/Android/SCM/app/src/main/java/com/project/scm/utils/PdfGenerator.java)
- Update `generateStatementPdf` to include:
    - **Branded Header**: SCM Logo and "BILLING STATEMENT REPORT" title.
    - **Summary Section**: A high-level overview showing Total Billed, Total Paid, and Total Outstanding Balance.
    - **Detailed Table**: A multi-column table listing all provided invoices with:
        - Invoice Number
        - Issued Date
        - Payment Status
        - Total Amount
        - Due Amount
    - **Professional Styling**: Consistent use of brand colors (`#103B79`), right-aligned financial data, and structured borders.
    - **Pagination Support**: Logic to handle multiple pages if the list of invoices exceeds one page.

## Verification Plan

### Manual Verification
- Open the **Billing Page**.
- Click **Download Statement** at the bottom.
- Verify the generated PDF contains:
    - The company logo and correct title.
    - Accurate totals matching the on-screen metrics.
    - A clear table listing all invoices with correct data.
    - Professional alignment and formatting.
