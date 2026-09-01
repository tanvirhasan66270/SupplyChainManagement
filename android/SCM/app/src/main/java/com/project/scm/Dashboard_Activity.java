package com.project.scm;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.project.scm.adaptor.OrderAdapter;
import com.project.scm.adaptor.PipelineAdapter;
import com.project.scm.adaptor.ProductViewAdapter;
import com.project.scm.api.ApiClient;
import com.project.scm.model.response.CustomerOrderResponseDTO;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.model.response.LoginResponseDTO;
import com.project.scm.model.response.ProductResponseDTO;
import com.project.scm.session.SessionManager;
import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

public class Dashboard_Activity extends AppCompatActivity {

    private ImageView profile;

    // Welcome Card views
    private TextView welcomeTitleName;

    // Wallet & Payments views
    private TextView wallerBalance;
    private TextView duePayment;

    // Stats Bar Grid views
    private TextView totalOrdersCount;
    private TextView activeOrder;
    private TextView deliveredValue;
    private TextView pendingValue;

    // Analysis & Activity views
    private View containerNoLogistics;

    // Recommended Product views
    private RecyclerView recyclerRecommended;
    private ProductViewAdapter recommendedProductAdapter;
    private final List<ProductResponseDTO> recommendedProductList = new ArrayList<>();

    // Pipeline Views
    private RecyclerView recyclerPipelineLogs;
    private PipelineAdapter pipelineAdapter;
    private final List<CustomerOrderResponseDTO> pipelineList = new ArrayList<>();

    // RecyclerView for Recent Orders
    private RecyclerView recyclerRecentOrders;
    private OrderAdapter orderAdapter;
    private final List<CustomerOrderResponseDTO> orderList = new ArrayList<>();
    private TextView findAllOrder;

    private SessionManager sessionManager;
    private CustomerResponseDTO customer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_dashboard);

        sessionManager = new SessionManager(this);

        bindViews();
        setupToolbar();
        setupRecyclerView();
        setupClickListeners();

        loadUserData();
        loadRecentOrder();
        loadRecommendedProducts();
    }

    private void bindViews() {
        profile=findViewById(R.id.profile);
        welcomeTitleName = findViewById(R.id.welcomeTitleName);

        wallerBalance = findViewById(R.id.wallerBalance);
        duePayment=findViewById(R.id.duePayment);

        totalOrdersCount = findViewById(R.id.totalOrdersCount);
        activeOrder = findViewById(R.id.activeOrder);
        deliveredValue = findViewById(R.id.deliveredValue);
        pendingValue = findViewById(R.id.pendingValue);

        containerNoLogistics = findViewById(R.id.containerNoLogistics);
        recyclerPipelineLogs = findViewById(R.id.recyclerPipelineLogs);
        recyclerRecommended = findViewById(R.id.recyclerRecommended);
        recyclerRecentOrders = findViewById(R.id.recyclerRecentOrders);
        findAllOrder = findViewById(R.id.findAllOrder);
    }

    private void setupToolbar() {
        // Toolbar related setup
    }

    private void setupRecyclerView() {
        if (recyclerRecentOrders != null) {
            recyclerRecentOrders.setLayoutManager(new LinearLayoutManager(this));
            recyclerRecentOrders.setHasFixedSize(true);
            orderAdapter = new OrderAdapter(orderList, order -> {
                Intent intent = new Intent(Dashboard_Activity.this, TrackingDashboardActivity.class);
                intent.putExtra("orderNumber", order.getOrderNumber());
                startActivity(intent);
            });
            recyclerRecentOrders.setAdapter(orderAdapter);
        }

        if (recyclerPipelineLogs != null) {
            recyclerPipelineLogs.setLayoutManager(new LinearLayoutManager(this));
            pipelineAdapter = new PipelineAdapter(pipelineList, order -> {
                Intent intent = new Intent(Dashboard_Activity.this, TrackingDashboardActivity.class);
                intent.putExtra("orderNumber", order.getOrderNumber());
                startActivity(intent);
            });
            recyclerPipelineLogs.setAdapter(pipelineAdapter);
        }

        if (recyclerRecommended != null) {
            recyclerRecommended.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));
            recommendedProductAdapter = new ProductViewAdapter(recommendedProductList, product -> {
                Intent intent = new Intent(Dashboard_Activity.this, Product_Details_Activity.class);
                intent.putExtra("product_data", new com.google.gson.Gson().toJson(product));
                startActivity(intent);
            });
            recyclerRecommended.setAdapter(recommendedProductAdapter);
        }
    }

    private void setupClickListeners() {
        View trackProduct = findViewById(R.id.btn_track_product);
        if (trackProduct != null) trackProduct.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, TrackingDashboardActivity.class)));

        View newOrder = findViewById(R.id.btn_new_order);
        if (newOrder != null) {
            newOrder.setOnClickListener(v -> {
                startActivity(new Intent(Dashboard_Activity.this, OrderDashboardActivity.class));
            });
        }

        View billingLedger = findViewById(R.id.btn_billing_ledger);
        if (billingLedger != null) billingLedger.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, BillingPage.class)));

        View btnProfileCard = findViewById(R.id.btn_profile_card);
        if (btnProfileCard != null) {
            btnProfileCard.setOnClickListener(v -> {
                startActivity(new Intent(Dashboard_Activity.this, Profile_View_Activity.class));
            });
        }

        View supportDesk = findViewById(R.id.btn_support_desk);
        if (supportDesk != null) supportDesk.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, SupportDesk.class)));

        View navOrders = findViewById(R.id.btn_nav_orders);
        if (navOrders != null) navOrders.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, OrderDashboardActivity.class)));

        View navShipments = findViewById(R.id.btn_nav_shipments);
        if (navShipments != null) navShipments.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, TrackingDashboardActivity.class)));

        View navBilling = findViewById(R.id.btn_nav_billing);
        if (navBilling != null) navBilling.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, BillingPage.class)));

        if (findAllOrder != null) findAllOrder.setOnClickListener(v -> startActivity(new Intent(Dashboard_Activity.this, OrderDashboardActivity.class)));

        View logout = findViewById(R.id.btn_logout);
        if (logout != null) logout.setOnClickListener(v -> {
            sessionManager.logout();
            startActivity(new Intent(this, Login_Activity.class));
            finish();
        });

        if (profile != null) {
            profile.setOnClickListener(v -> {
                startActivity(new Intent(Dashboard_Activity.this, Profile_View_Activity.class));
            });
        }
    }

//    private void loadUserData() {
//        System.out.println("#########################################################");
//
//        SessionManager s = new SessionManager(getApplicationContext());
//
//
//
//        if (s.getCustomer() != null) {
//            CustomerResponseDTO customer = s.getCustomer();
//
//
//            if (customer.getImage() != null && !customer.getImage().isEmpty()) {
//                String imageUrl = ApiClient.IMAGE_URL + "customer/" + customer.getImage();
//                System.out.println(imageUrl+"**************************************************");
//
//                Glide.with(this)
//                        .load(imageUrl)
//                        .placeholder(android.R.drawable.sym_def_app_icon)
//                        .error(android.R.drawable.sym_def_app_icon)
//                        .circleCrop()
//                        .into(profile);
//            } else {
//                profile.setImageResource(android.R.drawable.sym_def_app_icon);
//            }
//        } else {
//            profile.setImageResource(android.R.drawable.sym_def_app_icon);
//            System.out.println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
//        }
//
//        if (welcomeTitleName != null) {
//            LoginResponseDTO user = sessionManager.getUser();
//            if (user != null && user.getName() != null) {
//                welcomeTitleName.setText("Welcome back, " + user.getName());
//            } else if (sessionManager.getCustomer() != null && sessionManager.getCustomer().getName() != null) {
//                welcomeTitleName.setText("Welcome back, sessionManager.getCustomer().getName()"); // ঠিক করে নিচের লাইনটি ব্যবহার করুন
//                welcomeTitleName.setText("Welcome back, " + sessionManager.getCustomer().getName());
//            } else {
//                welcomeTitleName.setText("Welcome back, Customer");
//            }
//        }
//    }

    private void loadUserData() {


        SessionManager sessionManager =
                new SessionManager(getApplicationContext());
        if(sessionManager.getCustomer() != null){
            customer = sessionManager.getCustomer();
        } else {
            Toast.makeText(getApplicationContext(), "failed", Toast.LENGTH_SHORT).show();

        }

        LoginResponseDTO user = sessionManager.getUser();

        // =====================================================
        // PROFILE IMAGE
        // =====================================================

       try {
           if (customer != null) {
               Toast.makeText(getApplicationContext(), customer.toString(), Toast.LENGTH_SHORT).show();
               String imageUrl =
                       ApiClient.IMAGE_URL
                               + "customer/"
                               + customer.getImage();

               System.out.println("Customer Image = " + customer.getImage());
               System.out.println("Image URL = " + imageUrl);

               Glide.with(this)
                       .load(imageUrl)
                       .placeholder(android.R.drawable.sym_def_app_icon)
                       .error(android.R.drawable.sym_def_app_icon)
                       .circleCrop()
                       .into(profile);

           } else {

               profile.setImageResource(
                       android.R.drawable.sym_def_app_icon
               );


           }
       } catch (Exception e) {
           Toast.makeText(getApplicationContext(), e.toString(), Toast.LENGTH_SHORT).show();
       }



        // =====================================================
        // WELCOME NAME
        // =====================================================

        if (welcomeTitleName != null) {

            if (user != null
                    && user.getName() != null
                    && !user.getName().isEmpty()) {

                welcomeTitleName.setText(
                        "Welcome back, " + user.getName()
                );

            } else if (customer != null
                    && customer.getName() != null
                    && !customer.getName().isEmpty()) {

                welcomeTitleName.setText(
                        "Welcome back, " + customer.getName()
                );

            } else {

                welcomeTitleName.setText(
                        "Welcome back, Customer"
                );
            }
        }


    }

    private void loadRecentOrder() {
        com.project.scm.api.ApiService apiService = com.project.scm.api.ApiClient.getClient(getApplicationContext());
        apiService.getAllCustomerOrders().enqueue(new retrofit2.Callback<List<CustomerOrderResponseDTO>>() {
            @Override
            public void onResponse(@NonNull retrofit2.Call<List<CustomerOrderResponseDTO>> call, @NonNull retrofit2.Response<List<CustomerOrderResponseDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    orderList.clear();
                    orderList.addAll(response.body());
                    if (orderAdapter != null) orderAdapter.notifyDataSetChanged();
                    updatePipelineLogs(orderList);
                    calculateAndShowStats(orderList);
                }
            }

            @Override
            public void onFailure(@NonNull retrofit2.Call<List<CustomerOrderResponseDTO>> call, @NonNull Throwable t) {
                android.widget.Toast.makeText(Dashboard_Activity.this, "Failed to load orders", android.widget.Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void loadRecommendedProducts() {
        com.project.scm.api.ApiService apiService = com.project.scm.api.ApiClient.getClient(getApplicationContext());
        apiService.getAllProducts().enqueue(new retrofit2.Callback<List<ProductResponseDTO>>() {
            @Override
            public void onResponse(@NonNull retrofit2.Call<List<ProductResponseDTO>> call, @NonNull retrofit2.Response<List<ProductResponseDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    recommendedProductList.clear();
                    recommendedProductList.addAll(response.body());
                    if (recommendedProductAdapter != null) recommendedProductAdapter.notifyDataSetChanged();
                }
            }

            @Override
            public void onFailure(@NonNull retrofit2.Call<List<ProductResponseDTO>> call, @NonNull Throwable t) {
            }
        });
    }

    private void calculateAndShowStats(List<CustomerOrderResponseDTO> orders) {
        if (orders == null) return;
        int activeCount = 0, deliveredCount = 0, pendingCount = 0;
        double totalBalanceValue = 0;double totalDueValue = 0;

        for (CustomerOrderResponseDTO order : orders) {

            if ("PAID".equals(order.getPaymentStatus())) {
                totalBalanceValue += order.getTotalAmount();
            }else {
                if (order.getDueAmount() != null) {
                    try {
                        totalDueValue += Double.parseDouble(order.getDueAmount());
                    } catch (NumberFormatException e) {
                    }
                }
            }

            String status = order.getStatus();
            if (status != null) {
                switch (status) {
                    case "DELIVERED": deliveredCount++; break;
                    case "PENDING": pendingCount++; break;
                    case "CONFIRMED":
                    case "PROCESSING":
                    case "SHIPPED":
                    case "OUT_FOR_DELIVERY": activeCount++; break;
                }
            }
        }

        if (wallerBalance != null) wallerBalance.setText(String.format(java.util.Locale.getDefault(), "৳%.2f", totalBalanceValue));
        if (duePayment != null) duePayment.setText(String.format(java.util.Locale.getDefault(), "৳%.2f", totalDueValue));
        if (totalOrdersCount != null) totalOrdersCount.setText(String.valueOf(orders.size()));
        if (activeOrder != null) activeOrder.setText(String.valueOf(activeCount));
        if (deliveredValue != null) deliveredValue.setText(String.valueOf(deliveredCount));
        if (pendingValue != null) pendingValue.setText(String.valueOf(pendingCount));
    }

    private void updatePipelineLogs(List<CustomerOrderResponseDTO> orders) {
        if (orders == null || pipelineAdapter == null) return;
        pipelineList.clear();
        for (CustomerOrderResponseDTO order : orders) {
            String status = order.getStatus();
            if (status != null && (status.equals("CONFIRMED") || status.equals("PROCESSING") ||
                    status.equals("SHIPPED") || status.equals("OUT_FOR_DELIVERY") || status.equals("DELIVERED"))) {
                pipelineList.add(order);
            }
        }
        pipelineAdapter.notifyDataSetChanged();
        if (pipelineList.isEmpty()) {
            if (containerNoLogistics != null) containerNoLogistics.setVisibility(View.VISIBLE);
            if (recyclerPipelineLogs != null) recyclerPipelineLogs.setVisibility(View.GONE);
        } else {
            if (containerNoLogistics != null) containerNoLogistics.setVisibility(View.GONE);
            if (recyclerPipelineLogs != null) recyclerPipelineLogs.setVisibility(View.VISIBLE);
        }
    }
}