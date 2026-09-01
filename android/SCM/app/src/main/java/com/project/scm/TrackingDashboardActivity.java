package com.project.scm;

import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.project.scm.api.ApiClient;
import com.project.scm.api.ApiService;
import com.project.scm.model.response.CustomerOrderResponseDTO;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.session.SessionManager;

import java.util.Locale;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class TrackingDashboardActivity extends AppCompatActivity {

    private View containerOrderDetails;
    private TextView tvOrderIdDisplay, tvStatusBadge;
    private TextView tvRecipientName, tvPaymentStatus, tvEstimatedArrival, tvTotalValue;
    private TextView tvCurrentLocation, tvCourierName, tvServiceType, tvUpdateTime;
    private TextView tvDetailOrderNumber, tvWeightDetail, tvAddressDetail;
    private ImageView ivMilestonePipeline, ivMilestonePointer, ivProfileImage;
    private TextView tvMilestonePending, tvMilestoneConfirmed, tvMilestoneProcessing, tvMilestoneShipped, tvMilestoneDelivered;
    private android.widget.LinearLayout containerTimeline;
    private EditText etTrackId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_tracking_dashboard);

        bindViews();
        setupInsets();
        setupNavigation();
        loadUserData();

        findViewById(R.id.btnTrackNow).setOnClickListener(v -> {
            String trackId = etTrackId.getText().toString().trim();
            if (!trackId.isEmpty()) {
                trackOrder(trackId);
            } else {
                Toast.makeText(this, "Please enter an Order ID", Toast.LENGTH_SHORT).show();
            }
        });

        // Check if an Order Number was passed via Intent
        String incomingOrder = getIntent().getStringExtra("orderNumber");
        if (incomingOrder != null && !incomingOrder.isEmpty()) {
            etTrackId.setText(incomingOrder);
            trackOrder(incomingOrder);
        }
    }

    private void bindViews() {
        etTrackId = findViewById(R.id.etTrackId);
        containerOrderDetails = findViewById(R.id.containerOrderDetails);

        tvOrderIdDisplay = findViewById(R.id.tvOrderIdDisplay);
        tvStatusBadge = findViewById(R.id.tvStatusBadge);

        tvRecipientName = findViewById(R.id.tvRecipientName);
        tvPaymentStatus = findViewById(R.id.tvPaymentStatus);
        tvEstimatedArrival = findViewById(R.id.tvEstimatedArrival);
        tvTotalValue = findViewById(R.id.tvTotalValue);

        tvCurrentLocation = findViewById(R.id.tvCurrentLocation);
        tvCourierName = findViewById(R.id.tvCourierName);
        tvServiceType = findViewById(R.id.tvServiceType);
        tvUpdateTime = findViewById(R.id.tvUpdateTime);

        tvDetailOrderNumber = findViewById(R.id.tvDetailOrderNumber);
        tvWeightDetail = findViewById(R.id.tvWeightDetail);
        tvAddressDetail = findViewById(R.id.tvAddressDetail);

        ivMilestonePipeline = findViewById(R.id.ivMilestonePipeline);
        ivMilestonePointer = findViewById(R.id.ivMilestonePointer);
        ivProfileImage = findViewById(R.id.ivProfileImage);
        tvMilestonePending = findViewById(R.id.tvMilestonePending);
        tvMilestoneConfirmed = findViewById(R.id.tvMilestoneConfirmed);
        tvMilestoneProcessing = findViewById(R.id.tvMilestoneProcessing);
        tvMilestoneShipped = findViewById(R.id.tvMilestoneShipped);
        tvMilestoneDelivered = findViewById(R.id.tvMilestoneDelivered);

        containerTimeline = findViewById(R.id.containerTimeline);
    }

    private void setupInsets() {
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
    }

    private void setupNavigation() {
        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
        
        View btnHome = findViewById(R.id.btnHome);
        if (btnHome != null) {
            btnHome.setOnClickListener(v -> {
                startActivity(new Intent(this, Dashboard_Activity.class));
                finish();
            });
        }

        findViewById(R.id.btn_nav_home).setOnClickListener(v -> {
            startActivity(new Intent(this, Dashboard_Activity.class));
            finish();
        });

        findViewById(R.id.btn_nav_orders).setOnClickListener(v -> {
            startActivity(new Intent(this, OrderDashboardActivity.class));
            finish();
        });

        findViewById(R.id.btn_nav_billing).setOnClickListener(v -> {
            startActivity(new Intent(this, BillingPage.class));
            finish();
        });

        findViewById(R.id.btn_nav_profile).setOnClickListener(v -> {
            startActivity(new Intent(this, SupportDesk.class));
            finish();
        });
    }

    private void loadUserData() {
        SessionManager session = new SessionManager(getApplicationContext());
        CustomerResponseDTO customer = session.getCustomer();

        if (customer != null && ivProfileImage != null) {
            String imageUrl = ApiClient.IMAGE_URL + "customer/" + customer.getImage();
            Glide.with(this)
                    .load(imageUrl)
                    .placeholder(android.R.drawable.sym_def_app_icon)
                    .error(android.R.drawable.sym_def_app_icon)
                    .circleCrop()
                    .into(ivProfileImage);
        }
    }

    private void trackOrder(String orderNumber) {
        ApiService apiService = ApiClient.getClient(getApplicationContext());
        apiService.trackOrder(orderNumber).enqueue(new Callback<CustomerOrderResponseDTO>() {
            @Override
            public void onResponse(@NonNull Call<CustomerOrderResponseDTO> call, @NonNull Response<CustomerOrderResponseDTO> response) {
                if (response.isSuccessful() && response.body() != null) {
                    populateOrderDetails(response.body());
                } else {
                    containerOrderDetails.setVisibility(View.GONE);
                    Toast.makeText(TrackingDashboardActivity.this, "Order not found", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<CustomerOrderResponseDTO> call, @NonNull Throwable t) {
                containerOrderDetails.setVisibility(View.GONE);
                Toast.makeText(TrackingDashboardActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void populateOrderDetails(CustomerOrderResponseDTO order) {
        containerOrderDetails.setVisibility(View.VISIBLE);

        tvOrderIdDisplay.setText(order.getOrderNumber());
        tvStatusBadge.setText(order.getStatus());

        tvRecipientName.setText(order.getCustomerName() != null ? order.getCustomerName() : "Unknown");
        tvPaymentStatus.setText(order.getPaymentStatus() != null ? order.getPaymentStatus() : "PENDING");
        tvEstimatedArrival.setText(order.getEstimatedDelivery() != null ? order.getEstimatedDelivery() : "TBD");
        tvTotalValue.setText(String.format(Locale.getDefault(), "৳%.2f", order.getTotalAmount()));

        tvCurrentLocation.setText(order.getDeliveryAddress() != null ? "Current Node" : "N/A");
        tvCourierName.setText("SCM Logistics");
        tvServiceType.setText(order.getServiceType() != null ? order.getServiceType() : "Standard");
        tvUpdateTime.setText(order.getCreatedAt() != null ? order.getCreatedAt().split("T")[0] : "N/A");

        tvDetailOrderNumber.setText(order.getOrderNumber());
        tvWeightDetail.setText(String.format(Locale.getDefault(), "%.2f kg", order.getWeight()));
        tvAddressDetail.setText(order.getDeliveryAddress());

        updateMilestonePipeline(order.getStatus());
        updateMilestonePointer(order.getStatus());
        populateVerticalTimeline(order.getStatus(), order.getCreatedAt());
    }

    private void updateMilestonePointer(String status) {
        if (ivMilestonePointer == null || status == null) return;
        
        float bias = 0.0f;
        switch (status.toUpperCase()) {
            case "PENDING": bias = 0.0f; break;
            case "CONFIRMED": bias = 0.25f; break;
            case "PROCESSING": bias = 0.50f; break;
            case "SHIPPED": bias = 0.75f; break;
            case "DELIVERED": bias = 1.0f; break;
        }

        androidx.constraintlayout.widget.ConstraintLayout.LayoutParams params = 
            (androidx.constraintlayout.widget.ConstraintLayout.LayoutParams) ivMilestonePointer.getLayoutParams();
        params.horizontalBias = bias;
        ivMilestonePointer.setLayoutParams(params);
    }

    private void populateVerticalTimeline(String currentStatus, String dateStr) {
        if (containerTimeline == null) return;
        containerTimeline.removeAllViews();

        String[] statuses = {"PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "DELIVERED"};
        String[] titles = {"Order Placed", "Order Confirmed", "Processing", "Shipped", "Delivered"};
        String[] descriptions = {
            "Your order has been placed successfully.",
            "Seller has confirmed your order.",
            "Your package is being prepared for dispatch.",
            "Order is on its way to your destination.",
            "Order has been successfully delivered."
        };
        int[] icons = {
            R.drawable.ic_nav_home,
            R.drawable.ic_check_circle,
            R.drawable.ic_sync,
            R.drawable.ic_truck,
            R.drawable.ic_package
        };

        boolean isPastOrCurrent = true;
        for (int i = 0; i < statuses.length; i++) {
            if (!isPastOrCurrent) break;

            addTimelineStep(titles[i], descriptions[i], dateStr, icons[i], i == statuses.length - 1);

            if (statuses[i].equalsIgnoreCase(currentStatus)) {
                isPastOrCurrent = false;
            }
        }
    }

    private void addTimelineStep(String title, String desc, String date, int iconRes, boolean isLast) {
        View stepView = getLayoutInflater().inflate(R.layout.item_timeline_step, containerTimeline, false);
        
        TextView tvTitle = stepView.findViewById(R.id.tvStepTitle);
        TextView tvDesc = stepView.findViewById(R.id.tvStepDescription);
        TextView tvDate = stepView.findViewById(R.id.tvStepDate);
        ImageView ivIcon = stepView.findViewById(R.id.ivStepIcon);
        View viewLine = stepView.findViewById(R.id.viewLine);

        tvTitle.setText(title);
        tvDesc.setText(desc);
        
        if (date != null && !date.isEmpty()) {
            tvDate.setText(date.split("T")[0]);
        }
        
        ivIcon.setImageResource(iconRes);
        ivIcon.setImageTintList(ColorStateList.valueOf(Color.parseColor("#15803D")));
        viewLine.setBackgroundColor(Color.parseColor("#15803D"));

        if (isLast) {
            viewLine.setVisibility(View.GONE);
        }

        containerTimeline.addView(stepView);
    }

    private void updateMilestonePipeline(String status) {
        // Reset all milestone styles
        int dimColor = Color.parseColor("#CCCCCC");
        int activeColor = Color.parseColor("#15803D"); // Green

        tvMilestonePending.setTextColor(dimColor);
        tvMilestoneConfirmed.setTextColor(dimColor);
        tvMilestoneProcessing.setTextColor(dimColor);
        tvMilestoneShipped.setTextColor(dimColor);
        tvMilestoneDelivered.setTextColor(dimColor);
        ivMilestonePipeline.setImageTintList(ColorStateList.valueOf(dimColor));

        if (status == null) return;

        switch (status.toUpperCase()) {
            case "PENDING":
                tvMilestonePending.setTextColor(activeColor);
                break;
            case "CONFIRMED":
                tvMilestoneConfirmed.setTextColor(activeColor);
                break;
            case "PROCESSING":
                tvMilestoneProcessing.setTextColor(activeColor);
                break;
            case "SHIPPED":
                tvMilestoneShipped.setTextColor(activeColor);
                break;
            case "DELIVERED":
                tvMilestoneDelivered.setTextColor(activeColor);
                ivMilestonePipeline.setImageTintList(ColorStateList.valueOf(activeColor));
                break;
        }
    }
}
