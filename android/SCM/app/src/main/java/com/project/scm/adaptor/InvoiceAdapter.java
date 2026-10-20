package com.project.scm.adaptor;

import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.R;
import com.project.scm.model.response.InvoiceResponseDTO;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class InvoiceAdapter extends RecyclerView.Adapter<InvoiceAdapter.InvoiceViewHolder> {

    public interface OnInvoiceClickListener {
        void onInvoiceClick(InvoiceResponseDTO invoice);
    }

    private List<InvoiceResponseDTO> invoiceList;
    private final OnInvoiceClickListener listener;

    public InvoiceAdapter(List<InvoiceResponseDTO> invoiceList, OnInvoiceClickListener listener) {
        this.invoiceList = invoiceList != null ? invoiceList : new ArrayList<>();
        this.listener = listener;
    }

    public void updateList(List<InvoiceResponseDTO> newList) {
        this.invoiceList = newList != null ? newList : new ArrayList<>();
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public InvoiceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_invoice, parent, false);
        return new InvoiceViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull InvoiceViewHolder holder, int position) {
        InvoiceResponseDTO invoice = invoiceList.get(position);

        String invNum = invoice.getInvoiceNumber() != null ? invoice.getInvoiceNumber() : 
                (invoice.getTransactionReference() != null ? invoice.getTransactionReference() : "INV-" + invoice.getId());
        holder.tvInvoiceNumber.setText(invNum);
        holder.tvInvoiceId.setText("ID: " + (invoice.getId() != null ? invoice.getId() : "N/A"));

        String name = invoice.getIssuedToName();
        if (name == null || name.trim().isEmpty()) {
            name = invoice.getCustomerEmail() != null ? invoice.getCustomerEmail() : "N/A";
        }
        holder.tvCustomerName.setText(name);

        String orderId = invoice.getCustomerOrderId() != null ? "ORD-" + invoice.getCustomerOrderId() : "N/A";
        holder.tvCustomerOrderId.setText(orderId);

        String invStatus = invoice.getInvoiceStatus() != null ? invoice.getInvoiceStatus().toUpperCase(Locale.ROOT) : "ISSUED";
        holder.tvInvoiceStatus.setText(invStatus);

        String currency = invoice.getCurrency() != null ? invoice.getCurrency() : "৳";
        if ("BDT".equalsIgnoreCase(currency)) {
            currency = "৳";
        }

        holder.tvTotalAmount.setText(String.format(Locale.getDefault(), "%s%.2f", currency, invoice.getTotalAmount()));
        holder.tvPaidAmount.setText(String.format(Locale.getDefault(), "%s%.2f", currency, invoice.getPaidAmount()));
        holder.tvDueAmount.setText(String.format(Locale.getDefault(), "%s%.2f", currency, invoice.getDueAmount()));

        String payStatus = invoice.getPaymentStatus() != null ? invoice.getPaymentStatus().toUpperCase(Locale.ROOT) : "UNPAID";
        holder.tvPaymentStatus.setText(payStatus.replace("_", " "));
        
        applyStatusStyle(holder.tvPaymentStatus, payStatus);

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onInvoiceClick(invoice);
            }
        });
    }

    @Override
    public int getItemCount() {
        return invoiceList.size();
    }

    private void applyStatusStyle(TextView textView, String status) {
        int colorRes;
        int bgRes = R.drawable.bg_status_badge_partially_paid;
        
        switch (status) {
            case "PAID":
                colorRes = R.color.green_paid;
                bgRes = R.drawable.bg_status_badge_paid;
                break;
            case "PARTIALLY_PAID":
                colorRes = R.color.orange_partially_paid;
                bgRes = R.drawable.bg_status_badge_partially_paid;
                break;
            case "UNPAID":
            case "OVERDUE":
                colorRes = R.color.red_status;
                bgRes = R.drawable.bg_status_badge_partially_paid;
                break;
            default:
                colorRes = R.color.gray_text;
                bgRes = R.drawable.bg_status_badge_delivered;
                break;
        }

        textView.setBackgroundResource(bgRes);
        textView.setTextColor(textView.getContext().getResources().getColor(colorRes, textView.getContext().getTheme()));
    }

    static class InvoiceViewHolder extends RecyclerView.ViewHolder {
        TextView tvInvoiceNumber, tvInvoiceId, tvCustomerName, tvCustomerOrderId, tvInvoiceStatus;
        TextView tvPaymentStatus, tvTotalAmount, tvPaidAmount, tvDueAmount;

        InvoiceViewHolder(@NonNull View itemView) {
            super(itemView);
            tvInvoiceNumber = itemView.findViewById(R.id.tvInvoiceNumber);
            tvInvoiceId = itemView.findViewById(R.id.tvInvoiceId);
            tvCustomerName = itemView.findViewById(R.id.tvCustomerName);
            tvCustomerOrderId = itemView.findViewById(R.id.tvCustomerOrderId);
            tvInvoiceStatus = itemView.findViewById(R.id.tvInvoiceStatus);
            tvPaymentStatus = itemView.findViewById(R.id.tvPaymentStatus);
            tvTotalAmount = itemView.findViewById(R.id.tvTotalAmount);
            tvPaidAmount = itemView.findViewById(R.id.tvPaidAmount);
            tvDueAmount = itemView.findViewById(R.id.tvDueAmount);
        }
    }
}
