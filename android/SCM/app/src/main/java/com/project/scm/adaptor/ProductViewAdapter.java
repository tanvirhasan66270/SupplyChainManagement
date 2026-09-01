package com.project.scm.adaptor;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.bumptech.glide.Glide;
import com.project.scm.R;
import com.project.scm.model.response.ProductResponseDTO;
import com.project.scm.api.ApiClient;

import java.util.List;
import java.util.Locale;

public class ProductViewAdapter extends RecyclerView.Adapter<ProductViewAdapter.ViewHolder> {

    public interface OnViewClickListener {
        void onViewClick(ProductResponseDTO product);
    }

    private final List<ProductResponseDTO> productList;
    private final OnViewClickListener listener;

    public ProductViewAdapter(List<ProductResponseDTO> productList, OnViewClickListener listener) {
        this.productList = productList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_recommended_product, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ProductResponseDTO product = productList.get(position);

        holder.tvProductCodeBadge.setText(product.getProductCode() != null ? product.getProductCode() : "#" + product.getId());
        holder.productName.setText(product.getName() != null ? product.getName() : "N/A");
        holder.productPrice.setText(String.format(Locale.getDefault(), "৳%.2f", product.getSellingPrice()));

        // Explicitly clear any existing Glide request for this view to prevent recycling issues
        Glide.with(holder.itemView.getContext()).clear(holder.productImage);

        if (product.getImage() != null && !product.getImage().isEmpty()) {
            String imageUrl = ApiClient.IMAGE_URL+"product/" + product.getImage();
            Glide.with(holder.itemView.getContext())
                    .load(imageUrl)
                    .placeholder(R.drawable.baground) // Temporary truck during load
                    .error(R.drawable.ic_nav_profile)  // Different icon for errors to distinguish from default
                    .centerCrop()
                    .into(holder.productImage);
        } else {
            holder.productImage.setImageResource(R.drawable.baground);
        }

        holder.btnViewProduct.setOnClickListener(v -> {
            if (listener != null) {
                listener.onViewClick(product);
            }
        });
    }

    @Override
    public int getItemCount() {
        return productList.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView productImage;
        TextView tvProductCodeBadge;
        TextView productName;
        TextView productPrice;
        MaterialButton btnViewProduct;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            productImage = itemView.findViewById(R.id.productImage);
            tvProductCodeBadge = itemView.findViewById(R.id.tvProductCodeBadge);
            productName = itemView.findViewById(R.id.productName);
            productPrice = itemView.findViewById(R.id.productPrice);
            btnViewProduct = itemView.findViewById(R.id.btnViewProduct);
        }
    }
}
