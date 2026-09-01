package com.project.scm.adaptor;

import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.R;
import com.project.scm.model.response.CustomerOrderResponseDTO;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class PipelineAdapter extends RecyclerView.Adapter<PipelineAdapter.PipelineViewHolder> {

    public interface OnPipelineClickListener {
        void onPipelineClick(CustomerOrderResponseDTO order);
    }

    private final List<CustomerOrderResponseDTO> pipelineList;
    private final OnPipelineClickListener listener;

    public PipelineAdapter(List<CustomerOrderResponseDTO> pipelineList, OnPipelineClickListener listener) {
        this.pipelineList = pipelineList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public PipelineViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_pipeline_log, parent, false);
        return new PipelineViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull PipelineViewHolder holder, int position) {
        CustomerOrderResponseDTO order = pipelineList.get(position);

        holder.tvOrderNumber.setText(order.getOrderNumber() != null ? order.getOrderNumber() : "N/A");

        if (order.getCreatedAt() != null) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
                Date date = sdf.parse(order.getCreatedAt());
                if (date != null) {
                    holder.tvDate.setText(DateFormat.format("MMM d, yyyy", date));
                } else {
                    holder.tvDate.setText(order.getCreatedAt());
                }
            } catch (ParseException e) {
                holder.tvDate.setText(order.getCreatedAt());
            }
        } else {
            holder.tvDate.setText("Recently Updated");
        }

        String status = order.getStatus() != null ? order.getStatus() : "Unknown";
        holder.tvStatus.setText(capitalize(status));
        
        // Dynamic status styling
        int color = getStatusColor(status);
        if (holder.tvStatus.getBackground() instanceof GradientDrawable) {
            GradientDrawable bg = (GradientDrawable) holder.tvStatus.getBackground().mutate();
            bg.setStroke(2, color);
            holder.tvStatus.setTextColor(color);
        }

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onPipelineClick(order);
            }
        });
    }

    @Override
    public int getItemCount() {
        return pipelineList.size();
    }

    private String capitalize(String text) {
        if (text == null || text.isEmpty()) return "";
        return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase().replace("_", " ");
    }

    private int getStatusColor(String status) {
        if (status == null) return Color.GRAY;
        switch (status.toUpperCase()) {
            case "CONFIRMED": return Color.parseColor("#4F46E5"); // Indigo
            case "PROCESSING": return Color.parseColor("#0288D1"); // Light Blue
            case "SHIPPED": return Color.parseColor("#F59E0B"); // Amber
            case "OUT_FOR_DELIVERY": return Color.parseColor("#10B981"); // Emerald
            case "DELIVERED": return Color.parseColor("#059669"); // Green
            default: return Color.GRAY;
        }
    }

    static class PipelineViewHolder extends RecyclerView.ViewHolder {
        TextView tvOrderNumber, tvDate, tvStatus;

        PipelineViewHolder(@NonNull View itemView) {
            super(itemView);
            tvOrderNumber = itemView.findViewById(R.id.tvOrderNumber);
            tvDate = itemView.findViewById(R.id.tvDate);
            tvStatus = itemView.findViewById(R.id.tvStatus);
        }
    }
}
