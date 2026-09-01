package com.project.scm.adaptor;

import android.graphics.drawable.GradientDrawable;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.R;
import com.project.scm.model.response.CustomerOrderResponseDTO;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class OrderAdapter extends RecyclerView.Adapter<OrderAdapter.OrderViewHolder> {

    public interface OnOrderClickListener {
        void onOrderClick(CustomerOrderResponseDTO order);
    }

    private final List<CustomerOrderResponseDTO> orderList;
    private final OnOrderClickListener listener;

    public OrderAdapter(List<CustomerOrderResponseDTO> orderList, OnOrderClickListener listener) {
        this.orderList = orderList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public OrderViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_order, parent, false);
        return new OrderViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull OrderViewHolder holder, int position) {
        CustomerOrderResponseDTO order = orderList.get(position);

        holder.tvOrderId.setText(order.getOrderNumber() != null ? order.getOrderNumber() : "N/A");

        if (order.getCreatedAt() != null) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
                Date date = sdf.parse(order.getCreatedAt());
                if (date != null) {
                    holder.orderDate.setText(DateFormat.format("MMM d, yyyy • hh:mm a", date));
                } else {
                    holder.orderDate.setText(order.getCreatedAt());
                }
            } catch (ParseException e) {
                holder.orderDate.setText(order.getCreatedAt());
            }
        } else {
            holder.orderDate.setText("Recent Order");
        }
        
        holder.productPrice.setText(String.format(Locale.getDefault(), "%.2f", order.getTotalAmount()));

        holder.tvStatus.setText(statusLabel(order.getStatus()));

        if (holder.tvStatus.getBackground() instanceof GradientDrawable) {
            GradientDrawable bg = (GradientDrawable) holder.tvStatus.getBackground().mutate();
            bg.setColor(statusColor(holder.itemView, order.getStatus()));
        } else {
            holder.tvStatus.setBackgroundColor(statusColor(holder.itemView, order.getStatus()));
        }

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onOrderClick(order);
            }
        });
    }

    @Override
    public int getItemCount() {
        return orderList.size();
    }

    private String statusLabel(String status) {
        if (status == null) return "Unknown";
        switch (status) {
            case "PENDING":
                return "Pending";
            case "CONFIRMED":
                return "Confirmed";
            case "PROCESSING":
                return "Processing";
            case "SHIPPED":
                return "Shipped";
            case "OUT_FOR_DELIVERY":
                return "Out for Delivery";
            case "DELIVERED":
                return "Delivered";
            case "CANCELLED":
                return "Cancelled";
            default:
                return status;
        }
    }

    @ColorInt
    private int statusColor(View context, String status) {
        int colorRes;
        if (status == null) {
            colorRes = R.color.gray_text;
        } else {
            switch (status) {
                case "PENDING":
                case "CANCELLED":
                    colorRes = R.color.orange_paid;
                    break;
                case "PROCESSING":
                case "CONFIRMED":
                case "SHIPPED":
                case "OUT_FOR_DELIVERY":
                    colorRes = R.color.blue_primary;
                    break;
                case "DELIVERED":
                    colorRes = R.color.green_status;
                    break;
                default:
                    colorRes = R.color.gray_text;
            }
        }
        return context.getResources().getColor(colorRes, context.getContext().getTheme());
    }

    static class OrderViewHolder extends RecyclerView.ViewHolder {
        TextView tvOrderId, orderDate, tvStatus, productPrice;

        OrderViewHolder(@NonNull View itemView) {
            super(itemView);
            tvOrderId = itemView.findViewById(R.id.tvOrderId1);
            orderDate = itemView.findViewById(R.id.orderDate);
            tvStatus = itemView.findViewById(R.id.tvStatus1);
            productPrice = itemView.findViewById(R.id.productPrice);
        }
    }
}