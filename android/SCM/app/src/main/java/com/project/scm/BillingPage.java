package com.project.scm;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;

import com.bumptech.glide.Glide;
import com.project.scm.adaptor.InvoiceAdapter;
import com.project.scm.api.ApiClient;
import com.project.scm.api.ApiService;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.model.response.LoginResponseDTO;
import com.project.scm.model.response.InvoiceResponseDTO;
import com.project.scm.session.SessionManager;
import com.project.scm.utils.PdfGenerator;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class BillingPage extends AppCompatActivity implements InvoiceAdapter.OnInvoiceClickListener {

    private List<InvoiceResponseDTO> allInvoices = new ArrayList<>();
    private List<InvoiceResponseDTO> filteredInvoices = new ArrayList<>();
    
    private InvoiceAdapter adapter;
    private RecyclerView rvInvoices;
    private LinearLayout layoutEmptyState;
    private EditText etSearchInvoice;
    private TextView tvBalanceAmount, tvInvoiceCount, tvTotalAmountSum, tvPaidAmountSum, tvDueAmountSum, tvFilterStatusLabel;
    private ImageView profileImage;

    private SessionManager sessionManager;
    private LoginResponseDTO currentUser;
    private CustomerResponseDTO currentCustomer;

    private String currentSearchQuery = "";
    private String currentPaymentStatusFilter = "ALL";
    private String currentInvoiceStatusFilter = "ALL";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_billing_page);

        View mainView = findViewById(R.id.main);
        View header = findViewById(R.id.header);
        View bottomNav = findViewById(R.id.bottomNav);

        ViewCompat.setOnApplyWindowInsetsListener(mainView, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            if (header != null) {
                int standardHeight = (int) (56 * getResources().getDisplayMetrics().density);
                header.getLayoutParams().height = standardHeight + systemBars.top;
                header.setPadding(header.getPaddingLeft(), systemBars.top, header.getPaddingRight(), header.getPaddingBottom());
            }
            if (bottomNav != null) {
                bottomNav.setPadding(bottomNav.getPaddingLeft(), bottomNav.getPaddingTop(), bottomNav.getPaddingRight(), systemBars.bottom);
            }
            return insets;
        });

        // Initialize UI Components
        rvInvoices = findViewById(R.id.rvInvoices);
        layoutEmptyState = findViewById(R.id.layoutEmptyState);
        etSearchInvoice = findViewById(R.id.etSearchInvoice);
        tvBalanceAmount = findViewById(R.id.tvBalanceAmount);
        tvInvoiceCount = findViewById(R.id.tvInvoiceCount);
        tvTotalAmountSum = findViewById(R.id.tvTotalAmountSum);
        tvPaidAmountSum = findViewById(R.id.tvPaidAmountSum);
        tvDueAmountSum = findViewById(R.id.tvDueAmountSum);
        tvFilterStatusLabel = findViewById(R.id.tvFilterStatusLabel);
        profileImage = findViewById(R.id.profileImage);

        sessionManager = new SessionManager(this);
        currentUser = sessionManager.getUser();
        currentCustomer = sessionManager.getCustomer();

        loadProfileImage();

        // RecyclerView Setup
        rvInvoices.setLayoutManager(new LinearLayoutManager(this));
        adapter = new InvoiceAdapter(filteredInvoices, this);
        rvInvoices.setAdapter(adapter);

        if (profileImage != null) {
            profileImage.setOnClickListener(v -> {
                startActivity(new Intent(BillingPage.this, Profile_View_Activity.class));
            });
        }

        // Search Input Listener
        if (etSearchInvoice != null) {
            etSearchInvoice.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    currentSearchQuery = s.toString().trim();
                    applyFilters();
                }

                @Override
                public void afterTextChanged(Editable s) {}
            });
        }

        // Filter Button Listener
        findViewById(R.id.btnFilter).setOnClickListener(v -> showFilterDialog());

        // Quick Action Footer Listeners
        findViewById(R.id.btnDownloadStatement).setOnClickListener(v -> generateAndOpenStatementPdf());
        findViewById(R.id.btnPaymentHistory).setOnClickListener(v -> filterByPaymentHistory());
        findViewById(R.id.btnFinancialSummary).setOnClickListener(v -> showFinancialSummaryDialog());
        findViewById(R.id.btnNewPayment).setOnClickListener(v -> showNewPaymentDialog());

        // Navigation
        findViewById(R.id.btn_nav_home).setOnClickListener(v -> {
            startActivity(new Intent(this, Dashboard_Activity.class));
            finish();
        });

        findViewById(R.id.btn_nav_orders).setOnClickListener(v -> {
            startActivity(new Intent(this, OrderDashboardActivity.class));
            finish();
        });

        findViewById(R.id.btn_nav_shipments).setOnClickListener(v -> {
            startActivity(new Intent(this, TrackingDashboardActivity.class));
            finish();
        });

        findViewById(R.id.btn_nav_billing).setOnClickListener(v -> {
            // Already on Billing
        });

        findViewById(R.id.btn_nav_profile).setOnClickListener(v -> {
            startActivity(new Intent(this, SupportDesk.class));
            finish();
        });

        loadInvoices();
    }

    private void loadInvoices() {
        ApiService apiService = ApiClient.getClient(getApplicationContext());
        apiService.getAllInvoices().enqueue(new Callback<List<InvoiceResponseDTO>>() {
            @Override
            public void onResponse(Call<List<InvoiceResponseDTO>> call, Response<List<InvoiceResponseDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    List<InvoiceResponseDTO> list = response.body();
                    allInvoices = new ArrayList<>();
                    
                    // Filter invoices for current user only
                    String userEmail = currentUser != null ? currentUser.getEmail() : 
                                      (currentCustomer != null ? currentCustomer.getEmail() : null);
                    
                    if (userEmail != null) {
                        for (InvoiceResponseDTO inv : list) {
                            if (userEmail.equalsIgnoreCase(inv.getCustomerEmail())) {
                                allInvoices.add(inv);
                            }
                        }
                    }
                } else {
                    allInvoices = new ArrayList<>();
                }
                applyFilters();
            }

            @Override
            public void onFailure(Call<List<InvoiceResponseDTO>> call, Throwable t) {
                Toast.makeText(BillingPage.this, "Failed to load invoices: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                allInvoices = new ArrayList<>();
                applyFilters();
            }
        });
    }

    private void loadProfileImage() {
        if (currentCustomer != null && currentCustomer.getImage() != null && !currentCustomer.getImage().isEmpty()) {
            String imageUrl = ApiClient.IMAGE_URL + "customer/" + currentCustomer.getImage();
            Glide.with(this)
                    .load(imageUrl)
                    .placeholder(R.drawable.ic_person)
                    .error(R.drawable.ic_person)
                    .circleCrop()
                    .into(profileImage);
        }
    }

    private void applyFilters() {
        filteredInvoices = new ArrayList<>();
        String query = currentSearchQuery.toLowerCase(Locale.ROOT);

        for (InvoiceResponseDTO inv : allInvoices) {
            boolean matchesSearch = true;
            if (!query.isEmpty()) {
                String invNum = inv.getInvoiceNumber() != null ? inv.getInvoiceNumber().toLowerCase(Locale.ROOT) : "";
                String invId = inv.getId() != null ? String.valueOf(inv.getId()) : "";
                String customer = inv.getIssuedToName() != null ? inv.getIssuedToName().toLowerCase(Locale.ROOT) : "";
                String email = inv.getCustomerEmail() != null ? inv.getCustomerEmail().toLowerCase(Locale.ROOT) : "";
                String ref = inv.getTransactionReference() != null ? inv.getTransactionReference().toLowerCase(Locale.ROOT) : "";

                matchesSearch = invNum.contains(query) || invId.contains(query) || customer.contains(query) || email.contains(query) || ref.contains(query);
            }

            boolean matchesPaymentStatus = true;
            if (!"ALL".equalsIgnoreCase(currentPaymentStatusFilter)) {
                String status = inv.getPaymentStatus() != null ? inv.getPaymentStatus() : "";
                matchesPaymentStatus = status.equalsIgnoreCase(currentPaymentStatusFilter);
            }

            boolean matchesInvoiceStatus = true;
            if (!"ALL".equalsIgnoreCase(currentInvoiceStatusFilter)) {
                String status = inv.getInvoiceStatus() != null ? inv.getInvoiceStatus() : "";
                matchesInvoiceStatus = status.equalsIgnoreCase(currentInvoiceStatusFilter);
            }

            if (matchesSearch && matchesPaymentStatus && matchesInvoiceStatus) {
                filteredInvoices.add(inv);
            }
        }

        adapter.updateList(filteredInvoices);
        updateSummaryMetrics(allInvoices, filteredInvoices);

        if (filteredInvoices.isEmpty()) {
            rvInvoices.setVisibility(View.GONE);
            layoutEmptyState.setVisibility(View.VISIBLE);
        } else {
            rvInvoices.setVisibility(View.VISIBLE);
            layoutEmptyState.setVisibility(View.GONE);
        }
    }

    private void updateSummaryMetrics(List<InvoiceResponseDTO> fullList, List<InvoiceResponseDTO> displayedList) {
        double totalBalanceDue = 0;
        double totalBilledSum = 0;
        double totalPaidSum = 0;

        for (InvoiceResponseDTO inv : fullList) {
            totalBalanceDue += inv.getDueAmount();
            totalBilledSum += inv.getTotalAmount();
            totalPaidSum += inv.getPaidAmount();
        }

        if (tvBalanceAmount != null) {
            tvBalanceAmount.setText(String.format(Locale.getDefault(), "৳%.2f", totalBalanceDue));
        }
        if (tvInvoiceCount != null) {
            tvInvoiceCount.setText(String.valueOf(displayedList.size()));
        }
        if (tvTotalAmountSum != null) {
            tvTotalAmountSum.setText(formatKOrAmount(totalBilledSum));
        }
        if (tvPaidAmountSum != null) {
            tvPaidAmountSum.setText(formatKOrAmount(totalPaidSum));
        }
        if (tvDueAmountSum != null) {
            tvDueAmountSum.setText(formatKOrAmount(totalBalanceDue));
        }
    }

    private String formatKOrAmount(double amount) {
        if (amount >= 1000000) {
            return String.format(Locale.getDefault(), "৳%.1fM", amount / 1000000.0);
        } else if (amount >= 1000) {
            return String.format(Locale.getDefault(), "৳%.1fk", amount / 1000.0);
        } else {
            return String.format(Locale.getDefault(), "৳%.0f", amount);
        }
    }

    private void showFilterDialog() {
        String[] options = {"All Invoices", "Paid Only", "Partially Paid", "Unpaid Only", "Issued Status", "Draft Status", "Cancelled Status"};
        
        new MaterialAlertDialogBuilder(this)
                .setTitle("Filter Billing Ledger")
                .setItems(options, (dialog, which) -> {
                    switch (which) {
                        case 0:
                            currentPaymentStatusFilter = "ALL";
                            currentInvoiceStatusFilter = "ALL";
                            tvFilterStatusLabel.setText("Filter: All");
                            break;
                        case 1:
                            currentPaymentStatusFilter = "PAID";
                            currentInvoiceStatusFilter = "ALL";
                            tvFilterStatusLabel.setText("Filter: Paid");
                            break;
                        case 2:
                            currentPaymentStatusFilter = "PARTIALLY_PAID";
                            currentInvoiceStatusFilter = "ALL";
                            tvFilterStatusLabel.setText("Filter: Partially Paid");
                            break;
                        case 3:
                            currentPaymentStatusFilter = "UNPAID";
                            currentInvoiceStatusFilter = "ALL";
                            tvFilterStatusLabel.setText("Filter: Unpaid");
                            break;
                        case 4:
                            currentPaymentStatusFilter = "ALL";
                            currentInvoiceStatusFilter = "ISSUED";
                            tvFilterStatusLabel.setText("Filter: Issued");
                            break;
                        case 5:
                            currentPaymentStatusFilter = "ALL";
                            currentInvoiceStatusFilter = "DRAFT";
                            tvFilterStatusLabel.setText("Filter: Draft");
                            break;
                        case 6:
                            currentPaymentStatusFilter = "ALL";
                            currentInvoiceStatusFilter = "CANCELLED";
                            tvFilterStatusLabel.setText("Filter: Cancelled");
                            break;
                    }
                    applyFilters();
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    @Override
    public void onInvoiceClick(InvoiceResponseDTO invoice) {
        Intent intent = new Intent(this, Invoice_Details_Activity.class);
        intent.putExtra("invoice_data", new com.google.gson.Gson().toJson(invoice));
        startActivity(intent);
    }

    private void showInvoiceDetailDialog(InvoiceResponseDTO inv) {
        StringBuilder details = new StringBuilder();
        details.append("📌 INVOICE DETAILS\n");
        details.append("------------------------------\n");
        details.append("Invoice #: ").append(inv.getInvoiceNumber() != null ? inv.getInvoiceNumber() : "INV-" + inv.getId()).append("\n");
        details.append("Record ID: ").append(inv.getId() != null ? inv.getId() : "N/A").append("\n");
        details.append("Customer Order ID: ").append(inv.getCustomerOrderId() != null ? inv.getCustomerOrderId() : "N/A").append("\n");
        details.append("Issued To: ").append(inv.getIssuedToName() != null ? inv.getIssuedToName() : "N/A").append("\n");
        details.append("Customer Email: ").append(inv.getCustomerEmail() != null ? inv.getCustomerEmail() : "N/A").append("\n");
        details.append("Sales Officer ID: ").append(inv.getSalesOfficerId() != null ? inv.getSalesOfficerId() : "N/A").append("\n");
        details.append("\n💰 FINANCIAL BREAKDOWN\n");
        details.append("------------------------------\n");
        details.append("Currency: ").append(inv.getCurrency() != null ? inv.getCurrency() : "BDT").append("\n");
        details.append(String.format(Locale.getDefault(), "Subtotal: ৳%.2f\n", inv.getSubtotal()));
        details.append(String.format(Locale.getDefault(), "Tax Rate: %.1f%% (৳%.2f)\n", inv.getTaxRate(), inv.getTaxAmount()));
        details.append(String.format(Locale.getDefault(), "Discount Rate: %.1f%% (৳%.2f)\n", inv.getDiscountPercentage(), inv.getDiscountAmount()));
        details.append(String.format(Locale.getDefault(), "Shipping Fees: ৳%.2f\n", inv.getShippingFees()));
        details.append(String.format(Locale.getDefault(), "Total Amount: ৳%.2f\n", inv.getTotalAmount()));
        details.append(String.format(Locale.getDefault(), "Paid Amount: ৳%.2f\n", inv.getPaidAmount()));
        details.append(String.format(Locale.getDefault(), "Due Amount: ৳%.2f\n", inv.getDueAmount()));
        details.append("\n💳 PAYMENT & STATUS\n");
        details.append("------------------------------\n");
        details.append("Payment Status: ").append(inv.getPaymentStatus() != null ? inv.getPaymentStatus() : "N/A").append("\n");
        details.append("Payment Method: ").append(inv.getPaymentMethod() != null ? inv.getPaymentMethod() : "N/A").append("\n");
        details.append("Transaction Ref: ").append(inv.getTransactionReference() != null ? inv.getTransactionReference() : "N/A").append("\n");
        details.append("Invoice Status: ").append(inv.getInvoiceStatus() != null ? inv.getInvoiceStatus() : "N/A").append("\n");
        details.append("Issued Date: ").append(inv.getIssuedAt() != null ? inv.getIssuedAt() : "N/A").append("\n");
        details.append("Delivery Date: ").append(inv.getDeliveryDate() != null ? inv.getDeliveryDate() : "N/A").append("\n");
        details.append("Delivery Address: ").append(inv.getDeliveryAddress() != null ? inv.getDeliveryAddress() : "N/A").append("\n");
        
        if (inv.getNotes() != null && !inv.getNotes().isEmpty()) {
            details.append("Notes: ").append(inv.getNotes()).append("\n");
        }
        if (inv.getCancelledReason() != null && !inv.getCancelledReason().isEmpty()) {
            details.append("Cancelled Reason: ").append(inv.getCancelledReason()).append("\n");
        }

        new MaterialAlertDialogBuilder(this)
                .setTitle("Invoice #" + (inv.getInvoiceNumber() != null ? inv.getInvoiceNumber() : inv.getId()))
                .setMessage(details.toString())
                .setPositiveButton("Download PDF", (dialog, which) -> openInvoicePdf(inv))
                .setNegativeButton("Close", null)
                .show();
    }

    private void openInvoicePdf(InvoiceResponseDTO inv) {
        File pdfFile = PdfGenerator.generateInvoicePdf(this, inv);
        if (pdfFile != null && pdfFile.exists()) {
            try {
                Uri fileUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", pdfFile);
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setDataAndType(fileUri, "application/pdf");
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(intent);
            } catch (Exception e) {
                Toast.makeText(this, "Generated PDF: " + pdfFile.getAbsolutePath(), Toast.LENGTH_LONG).show();
            }
        } else {
            Toast.makeText(this, "Failed to generate PDF invoice", Toast.LENGTH_SHORT).show();
        }
    }

    private void generateAndOpenStatementPdf() {
        if (allInvoices == null || allInvoices.isEmpty()) {
            Toast.makeText(this, "No invoice records available for statement", Toast.LENGTH_SHORT).show();
            return;
        }

        File pdfFile = PdfGenerator.generateStatementPdf(this, filteredInvoices);
        if (pdfFile != null && pdfFile.exists()) {
            try {
                Uri fileUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", pdfFile);
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setDataAndType(fileUri, "application/pdf");
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(intent);
            } catch (Exception e) {
                Toast.makeText(this, "Billing Statement saved to: " + pdfFile.getAbsolutePath(), Toast.LENGTH_LONG).show();
            }
        } else {
            Toast.makeText(this, "Failed to generate statement PDF", Toast.LENGTH_SHORT).show();
        }
    }

    private void filterByPaymentHistory() {
        currentPaymentStatusFilter = "PAID";
        currentInvoiceStatusFilter = "ALL";
        tvFilterStatusLabel.setText("Filter: Payment History (Paid)");
        applyFilters();
        Toast.makeText(this, "Showing Paid Payment History", Toast.LENGTH_SHORT).show();
    }

    private void showFinancialSummaryDialog() {
        double totalBilled = 0;
        double totalPaid = 0;
        double totalDue = 0;
        double totalTax = 0;
        double totalDiscount = 0;

        for (InvoiceResponseDTO inv : allInvoices) {
            totalBilled += inv.getTotalAmount();
            totalPaid += inv.getPaidAmount();
            totalDue += inv.getDueAmount();
            totalTax += inv.getTaxAmount();
            totalDiscount += inv.getDiscountAmount();
        }

        String summary = String.format(Locale.getDefault(),
                "📊 FINANCIAL SUMMARY METRICS\n" +
                "---------------------------------\n" +
                "Total Invoices Count: %d\n" +
                "Gross Total Revenue: ৳%.2f\n" +
                "Total Cash Collected: ৳%.2f\n" +
                "Total Outstanding Due: ৳%.2f\n" +
                "Total Tax Collected: ৳%.2f\n" +
                "Total Discounts Provided: ৳%.2f\n",
                allInvoices.size(), totalBilled, totalPaid, totalDue, totalTax, totalDiscount);

        new MaterialAlertDialogBuilder(this)
                .setTitle("Financial Summary")
                .setMessage(summary)
                .setPositiveButton("Download Report", (dialog, which) -> generateAndOpenStatementPdf())
                .setNegativeButton("Close", null)
                .show();
    }

    private void showNewPaymentDialog() {
        if (allInvoices == null || allInvoices.isEmpty()) {
            Toast.makeText(this, "No invoices available to record payment", Toast.LENGTH_SHORT).show();
            return;
        }

        List<String> unpaidInvoiceTitles = new ArrayList<>();
        List<InvoiceResponseDTO> unpaidInvoices = new ArrayList<>();

        for (InvoiceResponseDTO inv : allInvoices) {
            if (inv.getDueAmount() > 0) {
                unpaidInvoices.add(inv);
                String invNum = inv.getInvoiceNumber() != null ? inv.getInvoiceNumber() : "INV-" + inv.getId();
                unpaidInvoiceTitles.add(invNum + " - Due: ৳" + inv.getDueAmount());
            }
        }

        if (unpaidInvoices.isEmpty()) {
            Toast.makeText(this, "All invoices are fully paid!", Toast.LENGTH_SHORT).show();
            return;
        }

        String[] items = unpaidInvoiceTitles.toArray(new String[0]);

        new MaterialAlertDialogBuilder(this)
                .setTitle("Record Payment for Invoice")
                .setItems(items, (dialog, which) -> {
                    InvoiceResponseDTO selectedInv = unpaidInvoices.get(which);
                    promptPaymentAmount(selectedInv);
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void promptPaymentAmount(InvoiceResponseDTO inv) {
        EditText etAmount = new EditText(this);
        etAmount.setHint(String.format(Locale.getDefault(), "Enter amount (Max: ৳%.2f)", inv.getDueAmount()));
        etAmount.setInputType(android.text.InputType.TYPE_CLASS_NUMBER | android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL);

        new MaterialAlertDialogBuilder(this)
                .setTitle("Payment for " + (inv.getInvoiceNumber() != null ? inv.getInvoiceNumber() : "INV-" + inv.getId()))
                .setView(etAmount)
                .setPositiveButton("Record", (dialog, which) -> {
                    String input = etAmount.getText().toString().trim();
                    if (!input.isEmpty()) {
                        try {
                            double amountPaidNew = Double.parseDouble(input);
                            if (amountPaidNew > 0) {
                                double newPaidTotal = inv.getPaidAmount() + amountPaidNew;
                                inv.setPaidAmount(newPaidTotal);
                                inv.setDueAmount(Math.max(0, inv.getTotalAmount() - newPaidTotal));
                                if (inv.getDueAmount() <= 0) {
                                    inv.setPaymentStatus("PAID");
                                } else {
                                    inv.setPaymentStatus("PARTIALLY_PAID");
                                }
                                applyFilters();
                                Toast.makeText(this, "Payment recorded successfully!", Toast.LENGTH_SHORT).show();
                            }
                        } catch (NumberFormatException e) {
                            Toast.makeText(this, "Invalid amount", Toast.LENGTH_SHORT).show();
                        }
                    }
                })
                .setNegativeButton("Cancel", null)
                .show();
    }
}
