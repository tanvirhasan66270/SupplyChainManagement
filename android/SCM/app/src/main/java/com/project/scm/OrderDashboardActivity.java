package com.project.scm;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.adaptor.OrderCreatingAdapter;
import com.project.scm.api.ApiClient;
import com.project.scm.api.ApiService;
import com.project.scm.model.request.CustomerOrderRequestDTO;
import com.project.scm.model.request.OrderLineItemRequestDTO;
import com.project.scm.model.response.CustomerOrderResponseDTO;
import com.project.scm.model.response.ProductResponseDTO;
import com.project.scm.session.SessionManager;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class OrderDashboardActivity extends AppCompatActivity {

    private EditText etAddress, etDeliveryPhone, etCodAmount, etRemarks;
    private EditText etProductQty, etProductNotes;
    private AutoCompleteTextView etProductName;
    private Spinner spinnerDeliveryRoadmap, spinnerServiceStrategy, spinnerOrderPriority, spinnerPayment;
    private TextView tvCustomerName, tvSubtotal, tvDueAmount, tvPaidAmount, tvTotalAmount, tvAttachedTitle, tvMfsDetails;
    private View panelBank, panelMFS;
    private EditText etBankAccount, etMfsWallet;
    private RecyclerView recyclerOrderItems;

    private List<ProductResponseDTO> allProducts = new ArrayList<>();
    private List<OrderCreatingAdapter.OrderItem> selectedItems = new ArrayList<>();
    private OrderCreatingAdapter orderCreatingAdapter;
    private ApiService apiService;
    private ProductResponseDTO selectedProduct;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_order_dashboard);

        apiService = ApiClient.getClient(this);

        bindViews();
        setupSpinners();
        setupRecyclerView();
        setupNavigation();
        loadCustomerData();
        loadProducts();

        findViewById(R.id.btnDispatch).setOnClickListener(v -> submitOrder());
        findViewById(R.id.btnAddProduct).setOnClickListener(v -> addItemToList());
    }

    private void bindViews() {
        View mainView = findViewById(R.id.main);
        View header = findViewById(R.id.header);

        if (mainView != null) {
            ViewCompat.setOnApplyWindowInsetsListener(mainView, (v, insets) -> {
                Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
                if (header != null) {
                    // Standard toolbar height is 56dp. We add the system bar top inset.
                    int standardHeight = (int) (56 * getResources().getDisplayMetrics().density);
                    header.getLayoutParams().height = standardHeight + systemBars.top;
                    header.setPadding(header.getPaddingLeft(), systemBars.top, header.getPaddingRight(), header.getPaddingBottom());
                    header.requestLayout();
                }
                return insets;
            });
        }

        etAddress = findViewById(R.id.etAddress);
        etDeliveryPhone = findViewById(R.id.etDeliveryPhone);
        spinnerDeliveryRoadmap = findViewById(R.id.spinnerDeliveryRoadmap);
        spinnerServiceStrategy = findViewById(R.id.spinnerServiceStrategy);
        spinnerOrderPriority = findViewById(R.id.spinnerOrderPriority);
        spinnerPayment = findViewById(R.id.spinnerPayment);
        etCodAmount = findViewById(R.id.etCodAmount);
        etRemarks = findViewById(R.id.etRemarks);

        panelBank = findViewById(R.id.panelBank);
        panelMFS = findViewById(R.id.panelMFS);
        tvMfsDetails = findViewById(R.id.tvMfsDetails);
        etBankAccount = findViewById(R.id.etBankAccount);
        etMfsWallet = findViewById(R.id.etMfsWallet);

        etProductName = findViewById(R.id.etProductName);
        etProductQty = findViewById(R.id.etProductQty);
        etProductNotes = findViewById(R.id.etProductNotes);

        tvCustomerName = findViewById(R.id.tvCustomerName);
        tvSubtotal = findViewById(R.id.tvSubtotal);
        tvPaidAmount = findViewById(R.id.tvPaidAmount);
        tvDueAmount = findViewById(R.id.tvDueAmount);
        tvTotalAmount = findViewById(R.id.tvTotalAmount);
        tvAttachedTitle = findViewById(R.id.tvAttachedTitle);
        recyclerOrderItems = findViewById(R.id.recyclerOrderItems);
    }

    private void setupSpinners() {
        // Delivery Roadmap
        String[] roadmaps = {"Auto-Fixed by Priority Rule", "Express Node Delivery", "Standard Land Transport"};
        spinnerDeliveryRoadmap.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, roadmaps));

        // Service Strategy
        String[] services = {"STANDARD Logistics Delivery", "EXPRESS Bullet Velocity", "OVERNIGHT Cargo"};
        spinnerServiceStrategy.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, services));

        // Order Priority
        String[] priorities = {"NORMAL Priority (90 Days Standard)", "LOW Priority (120 Days)", "HIGH Priority (50 Days)", "URGENT Priority (30 Days)"};
        spinnerOrderPriority.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, priorities));

        // Payment Router
        String[] payments = {"CASH On Delivery", "BANK Transfer Swift Service", "BKASH Mobile Wallet", "NAGAD Fast Engine", "ROCKET DBBL Node"};
        spinnerPayment.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, payments));
        spinnerPayment.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (panelBank == null || panelMFS == null || tvMfsDetails == null) return;
                String selected = payments[position];
                
                if (selected.startsWith("BANK")) {
                    panelBank.setVisibility(View.VISIBLE);
                    panelMFS.setVisibility(View.GONE);
                } else if (selected.startsWith("BKASH")) {
                    panelBank.setVisibility(View.GONE);
                    panelMFS.setVisibility(View.VISIBLE);
                    tvMfsDetails.setText("BKASH Merchant/Personal:01712-345678");
                } else if (selected.startsWith("NAGAD")) {
                    panelBank.setVisibility(View.GONE);
                    panelMFS.setVisibility(View.VISIBLE);
                    tvMfsDetails.setText("NAGAD Merchant/Personal:01712-345678");
                } else if (selected.startsWith("ROCKET")) {
                    panelBank.setVisibility(View.GONE);
                    panelMFS.setVisibility(View.VISIBLE);
                    tvMfsDetails.setText("ROCKET Merchant/Personal:01712-345678");
                } else {
                    panelBank.setVisibility(View.GONE);
                    panelMFS.setVisibility(View.GONE);
                }
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
    }

    private void setupRecyclerView() {
        recyclerOrderItems.setLayoutManager(new LinearLayoutManager(this));
        orderCreatingAdapter = new OrderCreatingAdapter(selectedItems, position -> {
            selectedItems.remove(position);
            orderCreatingAdapter.notifyItemRemoved(position);
            updateTotals();
        });
        recyclerOrderItems.setAdapter(orderCreatingAdapter);
    }

    private void loadProducts() {
        apiService.getAllProducts().enqueue(new Callback<List<ProductResponseDTO>>() {
            @Override
            public void onResponse(@NonNull Call<List<ProductResponseDTO>> call, @NonNull Response<List<ProductResponseDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    allProducts.clear();
                    allProducts.addAll(response.body());
                    setupProductAutocomplete();
                }
            }
            @Override
            public void onFailure(@NonNull Call<List<ProductResponseDTO>> call, @NonNull Throwable t) {}
        });
    }

    private void setupProductAutocomplete() {
        List<String> displayNames = new ArrayList<>();
        for (ProductResponseDTO p : allProducts) {
            displayNames.add(String.format(Locale.US, "%s (৳%.0f)", p.getName(), p.getSellingPrice()));
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_dropdown_item_1line, displayNames);
        etProductName.setAdapter(adapter);
        
        // Trigger dropdown on click or focus to show all products instantly
        etProductName.setOnClickListener(v -> etProductName.showDropDown());
        etProductName.setOnFocusChangeListener((v, hasFocus) -> {
            if (hasFocus) {
                etProductName.showDropDown();
            }
        });

        etProductName.setOnItemClickListener((parent, view, position, id) -> {
            String selectedText = (String) parent.getItemAtPosition(position);
            for (ProductResponseDTO p : allProducts) {
                String formatted = String.format(Locale.US, "%s (৳%.0f)", p.getName(), p.getSellingPrice());
                if (selectedText.equals(formatted)) {
                    selectedProduct = p;
                    break;
                }
            }
        });
    }

    private void addItemToList() {
        if (selectedProduct == null) {
            Toast.makeText(this, "Select a valid product", Toast.LENGTH_SHORT).show();
            return;
        }

        int qty = 1;
        try {
            qty = Integer.parseInt(etProductQty.getText().toString());
        } catch (Exception ignored) {}

        String notes = etProductNotes.getText().toString();

        selectedItems.add(new OrderCreatingAdapter.OrderItem(selectedProduct, qty, notes));
        orderCreatingAdapter.notifyItemInserted(selectedItems.size() - 1);

        etProductName.setText("");
        etProductQty.setText("1");
        etProductNotes.setText("");
        selectedProduct = null;
        updateTotals();
    }

    private void updateTotals() {
        double subtotal = 0;
        for (OrderCreatingAdapter.OrderItem item : selectedItems) {
            subtotal += item.product.getSellingPrice() * item.quantity;
        }
        double delivery = 13710.0; // Hardcoded to match design screenshot for fidelity
        double total = subtotal + delivery;

        tvSubtotal.setText(String.format(Locale.US, "৳%,.2f", subtotal));
        if (tvPaidAmount != null) tvPaidAmount.setText("৳0.00");
        tvTotalAmount.setText(String.format(Locale.US, "৳%,.2f", total));
        tvDueAmount.setText(String.format(Locale.US, "৳%,.2f", total));
        tvAttachedTitle.setText("ATTACHED PRODUCTS (" + selectedItems.size() + ")");
    }

    private void loadCustomerData() {
        SessionManager session = new SessionManager(this);
        if (session.getCustomer() != null) {
            tvCustomerName.setText(session.getCustomer().getName() + " (" + session.getCustomer().getEmail() + ")");
        }
    }

    private void setupNavigation() {
        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
        findViewById(R.id.btnHome).setOnClickListener(v -> {
            startActivity(new Intent(this, Dashboard_Activity.class));
            finish();
        });
        findViewById(R.id.btnCancel).setOnClickListener(v -> finish());
    }

    private void submitOrder() {
        if (selectedItems.isEmpty()) {
            Toast.makeText(this, "Please add items to dispatch", Toast.LENGTH_SHORT).show();
            return;
        }
        
        CustomerOrderRequestDTO dto = new CustomerOrderRequestDTO();
        SessionManager session = new SessionManager(this);
        if (session.getCustomer() != null) dto.setCustomerId(session.getCustomer().getId());

        dto.setDeliveryAddress(etAddress.getText().toString());
        dto.setDeliveryPhone(etDeliveryPhone.getText().toString());
        
        String paymentEnum = spinnerPayment.getSelectedItem().toString().split(" ")[0].toUpperCase();
        dto.setPaymentMethod(paymentEnum);
        dto.setServiceType(spinnerServiceStrategy.getSelectedItem().toString().split(" ")[0].toUpperCase());
        dto.setStatus("PENDING");
        dto.setCurrency("BDT"); // Ensuring backend requirement

        String baseRemarks = etRemarks.getText().toString();
        if (paymentEnum.equals("BANK") && etBankAccount != null && !etBankAccount.getText().toString().isEmpty()) {
            baseRemarks += "\n[Payment Account Index: " + etBankAccount.getText().toString() + "]";
        } else if ((paymentEnum.equals("BKASH") || paymentEnum.equals("NAGAD") || paymentEnum.equals("ROCKET")) && etMfsWallet != null && !etMfsWallet.getText().toString().isEmpty()) {
            baseRemarks += "\n[MFS Wallet Number: " + etMfsWallet.getText().toString() + "]";
        }
        
        double codAmt = 0;
        if (etCodAmount != null && !etCodAmount.getText().toString().isEmpty()) {
            try { codAmt = Double.parseDouble(etCodAmount.getText().toString()); } catch (Exception ignored) {}
        }
        dto.setCodAmount(codAmt);

        List<OrderLineItemRequestDTO> items = new ArrayList<>();
        for (OrderCreatingAdapter.OrderItem item : selectedItems) {
            OrderLineItemRequestDTO line = new OrderLineItemRequestDTO();
            line.setProductId(item.product.getId());
            line.setQuantity(item.quantity);
            line.setRemarks(item.notes);
            items.add(line);
        }
        dto.setItems(items);

        apiService.createOrder(dto).enqueue(new Callback<CustomerOrderResponseDTO>() {
            @Override
            public void onResponse(@NonNull Call<CustomerOrderResponseDTO> call, @NonNull Response<CustomerOrderResponseDTO> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(OrderDashboardActivity.this, "Order Dispatched!", Toast.LENGTH_SHORT).show();
                    finish();
                }
            }
            @Override
            public void onFailure(@NonNull Call<CustomerOrderResponseDTO> call, @NonNull Throwable t) {}
        });
    }
}
