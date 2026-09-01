package com.project.scm;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.gson.Gson;
import com.project.scm.model.response.InvoiceResponseDTO;
import com.project.scm.utils.PdfGenerator;

import java.io.File;
import java.util.Locale;

public class Invoice_Details_Activity extends AppCompatActivity {

    private InvoiceResponseDTO invoice;
    private final Gson gson = new Gson();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_invoice_details);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        String json = getIntent().getStringExtra("invoice_data");
        if (json != null) {
            invoice = gson.fromJson(json, InvoiceResponseDTO.class);
        }

        if (invoice == null) {
            Toast.makeText(this, "Invoice data not found", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        bindData();
        setupClickListeners();
    }

    private void bindData() {
        String invNum = invoice.getInvoiceNumber() != null ? invoice.getInvoiceNumber() : "INV-" + invoice.getId();
        ((TextView) findViewById(R.id.tvHeaderInvoiceNum)).setText("Invoice #" + invNum);

        // Section 1: Invoice Details
        setupFieldRow(R.id.rowInvoiceNum, R.drawable.ic_invoice, "Invoice #", invNum);
        setupFieldRow(R.id.rowRecordId, R.drawable.ic_copy, "Record ID", String.valueOf(invoice.getId()));
        setupFieldRow(R.id.rowOrderId, R.drawable.ic_sync, "Customer Order ID", String.valueOf(invoice.getCustomerOrderId()));
        setupFieldRow(R.id.rowIssuedTo, R.drawable.ic_person, "Issued To", invoice.getIssuedToName());
        setupFieldRow(R.id.rowEmail, R.drawable.ic_mail, "Customer Email", invoice.getCustomerEmail());
        setupFieldRow(R.id.rowSalesOfficer, R.drawable.ic_person, "Sales Officer ID", String.valueOf(invoice.getSalesOfficerId() != null ? invoice.getSalesOfficerId() : "N/A"));

        // Section 2: Financial Breakdown
        String currency = invoice.getCurrency() != null ? invoice.getCurrency() : "BDT";
        String symbol = "BDT".equalsIgnoreCase(currency) ? "৳" : currency;

        setupTableRow(R.id.tableRowCurrency, "Currency", currency);
        setupTableRow(R.id.tableRowSubtotal, "Subtotal", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getSubtotal()));
        setupTableRow(R.id.tableRowTax, "Tax Rate", String.format(Locale.getDefault(), "%.1f%% (%s%.2f)", invoice.getTaxRate(), symbol, invoice.getTaxAmount()));
        setupTableRow(R.id.tableRowDiscount, "Discount Rate", String.format(Locale.getDefault(), "%.1f%% (%s%.2f)", invoice.getDiscountPercentage(), symbol, invoice.getDiscountAmount()));
        setupTableRow(R.id.tableRowShipping, "Shipping Fees", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getShippingFees()));
        
        setupTableRow(R.id.tableRowTotal, "Total Amount", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getTotalAmount()));
        setupTableRow(R.id.tableRowPaid, "Paid Amount", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getPaidAmount()));
        setupTableRow(R.id.tableRowDue, "Due Amount", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getDueAmount()));

        // Section 3: Payment & Status
        setupFieldRow(R.id.rowPaymentStatus, R.drawable.ic_check_circle, "Payment Status", invoice.getPaymentStatus());
        setupFieldRow(R.id.rowPaymentMethod, R.drawable.ic_bank, "Payment Method", invoice.getPaymentMethod());
        setupFieldRow(R.id.rowTransactionRef, R.drawable.ic_copy, "Transaction Ref", invoice.getTransactionReference());
        setupFieldRow(R.id.rowInvoiceStatus, R.drawable.ic_invoice, "Invoice Status", invoice.getInvoiceStatus());
        setupFieldRow(R.id.rowIssuedDate, R.drawable.ic_calendar, "Issued Date", invoice.getIssuedAt());
        setupFieldRow(R.id.rowDeliveryDate, R.drawable.ic_calendar, "Delivery Date", invoice.getDeliveryDate());
        setupFieldRow(R.id.rowDeliveryAddress, R.drawable.ic_location, "Delivery Address", invoice.getDeliveryAddress());
        setupFieldRow(R.id.rowNotes, R.drawable.ic_copy, "Notes", invoice.getNotes());
    }

    private void setupFieldRow(int viewId, int iconRes, String label, String value) {
        View row = findViewById(viewId);
        ((ImageView) row.findViewById(R.id.ivIcon)).setImageResource(iconRes);
        ((TextView) row.findViewById(R.id.tvLabel)).setText(label);
        ((TextView) row.findViewById(R.id.tvValue)).setText(value != null && !value.isEmpty() ? value : "N/A");
    }

    private void setupTableRow(int viewId, String label, String value) {
        View row = findViewById(viewId);
        ((TextView) row.findViewById(R.id.tvLabel)).setText(label);
        ((TextView) row.findViewById(R.id.tvValue)).setText(value != null ? value : "N/A");
    }

    private void setupClickListeners() {
        findViewById(R.id.btnClose).setOnClickListener(v -> finish());
        findViewById(R.id.btnDownloadPdf).setOnClickListener(v -> downloadPdf());
    }

    private void downloadPdf() {
        File pdfFile = PdfGenerator.generateInvoicePdf(this, invoice);
        if (pdfFile != null && pdfFile.exists()) {
            try {
                Uri fileUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", pdfFile);
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setDataAndType(fileUri, "application/pdf");
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(intent);
            } catch (Exception e) {
                Toast.makeText(this, "PDF Generated: " + pdfFile.getAbsolutePath(), Toast.LENGTH_LONG).show();
            }
        } else {
            Toast.makeText(this, "Failed to generate PDF", Toast.LENGTH_SHORT).show();
        }
    }
}
