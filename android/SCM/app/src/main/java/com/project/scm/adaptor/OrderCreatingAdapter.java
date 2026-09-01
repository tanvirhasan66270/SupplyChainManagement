package com.project.scm.adaptor;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.project.scm.R;
import com.project.scm.model.response.ProductResponseDTO;
import java.util.List;

public class OrderCreatingAdapter extends RecyclerView.Adapter<OrderCreatingAdapter.ViewHolder> {

    public static class OrderItem {
        public ProductResponseDTO product;
        public int quantity;
        public String notes;

        public OrderItem(ProductResponseDTO product, int quantity, String notes) {
            this.product = product;
            this.quantity = quantity;
            this.notes = notes;
        }
    }

    private final List<OrderItem> items;
    private final OnItemDeleteListener deleteListener;

    public interface OnItemDeleteListener {
        void onDelete(int position);
    }

    public OrderCreatingAdapter(List<OrderItem> items, OnItemDeleteListener deleteListener) {
        this.items = items;
        this.deleteListener = deleteListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_order_creation, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        OrderItem item = items.get(position);
        holder.tvName.setText(item.product.getName());
        holder.tvQty.setText("Quantity: " + item.quantity + " units");
        
        if (item.product.getImage() != null && !item.product.getImage().isEmpty()) {
            String imageUrl = com.project.scm.api.ApiClient.IMAGE_URL + "product/" + item.product.getImage();
            com.bumptech.glide.Glide.with(holder.itemView.getContext())
                    .load(imageUrl)
                    .placeholder(R.drawable.baground)
                    .error(R.drawable.baground)
                    .into(holder.ivProduct);
        } else {
            holder.ivProduct.setImageResource(R.drawable.baground);
        }

        if (item.notes != null && !item.notes.isEmpty()) {
            holder.tvNotes.setVisibility(View.VISIBLE);
            holder.tvNotes.setText("Notes: " + item.notes);
        } else {
            holder.tvNotes.setVisibility(View.GONE);
        }

        holder.btnDelete.setOnClickListener(v -> {
            if (deleteListener != null) {
                deleteListener.onDelete(position);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvName, tvQty, tvNotes;
        ImageView btnDelete, ivProduct;

        ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvProductName);
            tvQty = itemView.findViewById(R.id.tvProductQty);
            tvNotes = itemView.findViewById(R.id.tvProductNotes);
            btnDelete = itemView.findViewById(R.id.btnDelete);
            ivProduct = itemView.findViewById(R.id.ivProduct);
        }
    }
}
