package com.project.scm;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.bumptech.glide.Glide;
import com.google.gson.Gson;
import com.project.scm.api.ApiClient;
import com.project.scm.model.response.ProductResponseDTO;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class Product_Details_Activity extends AppCompatActivity {

    private ProductResponseDTO product;
    private final Gson gson = new Gson();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_product_details);
        
        View mainView = findViewById(R.id.main);
        View header = findViewById(R.id.header);
        View btnHome = findViewById(R.id.btnHome);
        
        ViewCompat.setOnApplyWindowInsetsListener(mainView, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            header.setPadding(header.getPaddingLeft(), systemBars.top, header.getPaddingRight(),
                    header.getPaddingBottom());
            return insets;
        });

        if (btnHome != null) {
            btnHome.setOnClickListener(v -> {
                startActivity(new Intent(this, Dashboard_Activity.class));
                finish();
            });
        }

        String productJson = getIntent().getStringExtra("product_data");
        if (productJson != null) {
            product = gson.fromJson(productJson, ProductResponseDTO.class);
            bindProductData();
        } else {
            Toast.makeText(this, "Product data missing", Toast.LENGTH_SHORT).show();
            finish();
        }

        updateHeaderTimestamp();
    }

    private void bindProductData() {
        // Basic Info (Hero Section)
        setDetailItem(R.id.itemCode, R.drawable.ic_copy, "Product Code", product.getProductCode());
        setDetailItem(R.id.itemName, R.drawable.ic_package, "Name", product.getName());
        setDetailItem(R.id.itemCategory, R.drawable.ic_ledger, "Category", product.getCategoryName()
                + " (ID: " + product.getCategoryId() + ")");
        setDetailItem(R.id.itemUnit, R.drawable.ic_cart, "Unit", product.getUnit());

        // Status Badge
        TextView tvStatusText = findViewById(R.id.tvStatusText);
        View viewStatusDot = findViewById(R.id.viewStatusDot);
        if (product.isActive()) {
            tvStatusText.setText("Active Product");
            viewStatusDot.setBackgroundTintList(android.content.res.ColorStateList.valueOf(0xFF549934)); // Green
        } else {
            tvStatusText.setText("Inactive Product");
            viewStatusDot.setBackgroundTintList(android.content.res.ColorStateList.valueOf(0xFFEA4335)); // Red
        }

        // Product Information Table
        setInfoRow(R.id.rowQuantity, R.drawable.ic_warehouse, "Quantity", String.valueOf(product.getQuantity()));
        setInfoRow(R.id.rowWeight, R.drawable.ic_gear, "Weight", String.format(
                Locale.getDefault(), "%.1f", product.getWeight()));
        setInfoRow(R.id.rowUnitCost, R.drawable.ic_wallet, "Unit Cost", "৳"
                + String.format(Locale.getDefault(), "%,.1f", product.getUnitCost()));
        setInfoRow(R.id.rowSellingPrice, R.drawable.ic_cart, "Selling Price", "৳"
                + String.format(Locale.getDefault(), "%,.1f", product.getSellingPrice()));
        setInfoRow(R.id.rowReorderPoint, R.drawable.ic_sync, "Reorder Point", String.valueOf(product.getReorderPoint()));
        
        // Dynamic Availability Styling
        TextView tvAvailValue = findViewById(R.id.rowAvailability).findViewById(R.id.tvRowValue);
        ((ImageView) findViewById(R.id.rowAvailability).findViewById(R.id.ivRowIcon)).setImageResource(R.drawable.ic_check_circle);
        ((TextView) findViewById(R.id.rowAvailability).findViewById(R.id.tvRowLabel)).setText("Availability");
        tvAvailValue.setText(product.getAvailability() != null ? product.getAvailability().toUpperCase() : "N/A");
        if ("AVAILABLE".equalsIgnoreCase(product.getAvailability())) {
            tvAvailValue.setTextColor(0xFF15803D); // Dark Green
        }

        // Dynamic Expiry Styling
        TextView tvExpiryValue = findViewById(R.id.rowExpiry).findViewById(R.id.tvRowValue);
        ((ImageView) findViewById(R.id.rowExpiry).findViewById(R.id.ivRowIcon)).setImageResource(R.drawable.ic_bell);
        ((TextView) findViewById(R.id.rowExpiry).findViewById(R.id.tvRowLabel)).setText("Has Expiry Date");
        tvExpiryValue.setText(product.getHasExpiryDate() != null ? product.getHasExpiryDate().toUpperCase() : "N/A");
        if ("NO".equalsIgnoreCase(product.getHasExpiryDate())) {
            tvExpiryValue.setTextColor(0xFFEA4335); // Red
        } else if ("YES".equalsIgnoreCase(product.getHasExpiryDate())) {
            tvExpiryValue.setTextColor(0xFF15803D); // Green
        }

        // Dynamic Active Status Styling
        TextView tvActiveValue = findViewById(R.id.rowActive).findViewById(R.id.tvRowValue);
        ((ImageView) findViewById(R.id.rowActive).findViewById(R.id.ivRowIcon)).setImageResource(R.drawable.ic_logout);
        ((TextView) findViewById(R.id.rowActive).findViewById(R.id.tvRowLabel)).setText("Active Status");
        tvActiveValue.setText(product.isActive() ? "Active" : "Inactive");
        tvActiveValue.setTextColor(product.isActive() ? 0xFF15803D : 0xFFEA4335);

        // Product Image
        ImageView ivProductImage = findViewById(R.id.ivProductImage);
        if (product.getImage() != null && !product.getImage().isEmpty()) {
            String imageUrl = ApiClient.IMAGE_URL + "product/" + product.getImage();
            Glide.with(this)
                    .load(imageUrl)
                    .placeholder(R.drawable.baground)
                    .error(R.drawable.baground)
                    .into(ivProductImage);
        }
    }

    private void setDetailItem(int layoutId, int iconRes, String label, String value) {
        View view = findViewById(layoutId);
        ((ImageView) view.findViewById(R.id.ivItemIcon)).setImageResource(iconRes);
        ((TextView) view.findViewById(R.id.tvItemLabel)).setText(label);
        ((TextView) view.findViewById(R.id.tvItemValue)).setText(value != null ? value : "N/A");
    }

    private void setInfoRow(int layoutId, int iconRes, String label, String value) {
        View view = findViewById(layoutId);
        ((ImageView) view.findViewById(R.id.ivRowIcon)).setImageResource(iconRes);
        ((TextView) view.findViewById(R.id.tvRowLabel)).setText(label);
        ((TextView) view.findViewById(R.id.tvRowValue)).setText(value != null ? value : "N/A");
    }

    private void updateHeaderTimestamp() {
        SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.getDefault());
        Date now = new Date();
        
        TextView tvFooterTimestamp = findViewById(R.id.tvFooterTimestamp);
        if (tvFooterTimestamp != null) {
            tvFooterTimestamp.setText(fullDateFormat.format(now));
        }
    }
}