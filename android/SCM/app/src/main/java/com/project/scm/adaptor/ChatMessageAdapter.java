package com.project.scm.adaptor;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.R;
import com.project.scm.model.response.MessageResponseDTO;

import java.util.List;

public class ChatMessageAdapter extends RecyclerView.Adapter<ChatMessageAdapter.ViewHolder> {

    private final List<MessageResponseDTO> messages;
    private final String currentUserId;
    private static final int TYPE_SENT = 1;
    private static final int TYPE_RECEIVED = 2;

    public ChatMessageAdapter(List<MessageResponseDTO> messages, String currentUserId) {
        this.messages = messages;
        this.currentUserId = currentUserId;
    }

    @Override
    public int getItemViewType(int position) {
        MessageResponseDTO msg = messages.get(position);
        return (msg.getSenderId() != null && msg.getSenderId().equals(currentUserId)) ? TYPE_SENT : TYPE_RECEIVED;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        int layout = (viewType == TYPE_SENT) ? R.layout.layout_chat_message_sent : R.layout.layout_chat_message_received;
        View view = LayoutInflater.from(parent.getContext()).inflate(layout, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        MessageResponseDTO message = messages.get(position);
        holder.tvMessage.setText(message.getBody());
        holder.tvTime.setText(message.getCreatedAt() != null ? message.getCreatedAt() : "");

        if (getItemViewType(position) == TYPE_RECEIVED) {
            TextView tvSender = holder.itemView.findViewById(R.id.tvSenderName);
            if (tvSender != null) {
                tvSender.setText(message.getSenderName() != null ? message.getSenderName() : "Unknown");
            }
        }
    }

    @Override
    public int getItemCount() {
        return messages.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvMessage, tvTime;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvMessage = itemView.findViewById(R.id.tvMessage);
            tvTime = itemView.findViewById(R.id.tvTime);
        }
    }
}
