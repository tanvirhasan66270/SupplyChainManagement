package com.project.scm;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.project.scm.api.ApiClient;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.session.SessionManager;

import java.util.ArrayList;
import java.util.List;

public class Profile_View_Activity extends AppCompatActivity {

    private SessionManager sessionManager;
    private CustomerResponseDTO customer;

    // Header views
    private ImageView profileImage;
    private TextView profileName, profileRole, profileScore, profileStatus;

    // Completion views
    private ProgressBar profileProgressBar;
    private TextView tvCompletionPercent;
    private ImageView checkName, checkComm, checkAvatar;

    // Edit Actions (Hidden by default)
    private View btnChooseImage, btnUploadAvatar, btnUpdateProfile;
    private final List<View> rowActionIcons = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_profile_view);
        
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        sessionManager = new SessionManager(this);
        customer = sessionManager.getCustomer();

        if (customer == null) {
            Toast.makeText(this, "Session expired", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        bindViews();
        setupData();
        setupClickListeners();
    }

    private void bindViews() {
        profileImage = findViewById(R.id.profileImage);
        profileName = findViewById(R.id.profileName);
        profileRole = findViewById(R.id.profileRole);
        profileScore = findViewById(R.id.profileScore);
        profileStatus = findViewById(R.id.profileStatus);

        profileProgressBar = findViewById(R.id.profileProgressBar);
        tvCompletionPercent = findViewById(R.id.tvCompletionPercent);
        checkName = findViewById(R.id.checkName);
        checkComm = findViewById(R.id.checkComm);
        checkAvatar = findViewById(R.id.checkAvatar);

        btnChooseImage = findViewById(R.id.btnChooseImage);
        btnUploadAvatar = findViewById(R.id.btnUploadAvatar);
        btnUpdateProfile = findViewById(R.id.btnUpdateProfile);
    }

    private void setupData() {
        // Basic Info
        profileName.setText(customer.getName() != null ? customer.getName() : "N/A");
        profileRole.setText(customer.getRole() != null ? customer.getRole().toUpperCase() : "CUSTOMER");
        profileScore.setText("4.9"); // Static as per screenshot
        profileStatus.setText("Active"); // Static as per screenshot

        // Profile Image
        if (customer.getImage() != null && !customer.getImage().isEmpty()) {
            String imageUrl = ApiClient.IMAGE_URL + "customer/" + customer.getImage();
            Glide.with(this)
                    .load(imageUrl)
                    .placeholder(android.R.drawable.sym_def_app_icon)
                    .circleCrop()
                    .into(profileImage);
        }

        // Rows - Clear list first to avoid duplication on config changes if any
        rowActionIcons.clear();
        setupRow(R.id.rowName, "Full Customer Name", customer.getName(), R.drawable.ic_person);
        setupRow(R.id.rowEmail, "Corporate Secure Email", customer.getEmail(), R.drawable.ic_mail);
        setupRow(R.id.rowPhone, "Secure Mobile Route", customer.getPhone(), R.drawable.ic_phone);
        setupRow(R.id.rowGender, "Gender Node", customer.getGender(), R.drawable.ic_gender);
        setupRow(R.id.rowDob, "Date of Birth", customer.getDob(), R.drawable.ic_calendar);
        setupRow(R.id.rowNid, "National ID (NID)", customer.getNidNumber(), R.drawable.ic_id_card);

        // Logistics
        TextView tvTerminal = findViewById(R.id.tvTerminalDetails);
        String terminalText = String.format("Division Node: %s\nDistrict Sector: %s\nPolice Station: %s",
                customer.getDivisionName(), customer.getDistrictName(), customer.getPoliceStationName());
        tvTerminal.setText(terminalText);

        TextView tvAddress = findViewById(R.id.tvDetailedAddress);
        tvAddress.setText(customer.getAddress() != null ? customer.getAddress() : "N/A");

        TextView tvRegistered = findViewById(R.id.tvRegisteredTime);
        tvRegistered.setText("Registered: " + (customer.getCreatedAt() != null ? customer.getCreatedAt() : "N/A"));

        calculateCompletion();
    }

    private void setupRow(int rowId, String label, String value, int iconRes) {
        View row = findViewById(rowId);
        ((TextView) row.findViewById(R.id.rowLabel)).setText(label);
        ((TextView) row.findViewById(R.id.rowValue)).setText(value != null && !value.isEmpty() ? value : "N/A");
        ((ImageView) row.findViewById(R.id.rowIcon)).setImageResource(iconRes);
        
        View actionIcon = row.findViewById(R.id.rowAction);
        actionIcon.setVisibility(View.GONE); // Hidden by default
        rowActionIcons.add(actionIcon);
    }

    private void calculateCompletion() {
        int completion = 0;
        boolean nameDone = customer.getName() != null && !customer.getName().isEmpty();
        boolean commDone = (customer.getEmail() != null && !customer.getEmail().isEmpty()) || 
                          (customer.getPhone() != null && !customer.getPhone().isEmpty());
        boolean avatarDone = customer.getImage() != null && !customer.getImage().isEmpty();

        if (nameDone) completion += 34;
        if (commDone) completion += 33;
        if (avatarDone) completion += 33;

        profileProgressBar.setProgress(completion);
        tvCompletionPercent.setText(completion + "%");

        checkName.setAlpha(nameDone ? 1.0f : 0.3f);
        checkComm.setAlpha(commDone ? 1.0f : 0.3f);
        checkAvatar.setAlpha(avatarDone ? 1.0f : 0.3f);
    }

    private void setupClickListeners() {
        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
        
        findViewById(R.id.btnEditTop).setOnClickListener(v -> {
            // Toggle visibility of edit buttons
            int visibility = (btnUpdateProfile.getVisibility() == View.VISIBLE) ? View.GONE : View.VISIBLE;
            btnChooseImage.setVisibility(visibility);
            btnUploadAvatar.setVisibility(visibility);
            btnUpdateProfile.setVisibility(visibility);
            
            // Toggle visibility of row action icons (chevrons)
            for (View icon : rowActionIcons) {
                icon.setVisibility(visibility);
            }
            
            String msg = (visibility == View.VISIBLE) ? "Edit mode enabled" : "Edit mode disabled";
            Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
        });

        btnUpdateProfile.setOnClickListener(v -> Toast.makeText(this, "Profile registry updated", Toast.LENGTH_SHORT).show());
        btnChooseImage.setOnClickListener(v -> Toast.makeText(this, "Choose image coming soon", Toast.LENGTH_SHORT).show());
        btnUploadAvatar.setOnClickListener(v -> Toast.makeText(this, "Upload avatar coming soon", Toast.LENGTH_SHORT).show());
    }
}
