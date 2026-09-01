package com.project.scm.adaptor;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.R;
import com.project.scm.model.response.ChatContactDTO;

import java.util.List;

public class ChatUserAdapter extends RecyclerView.Adapter<ChatUserAdapter.ViewHolder> {

    private final List<ChatContactDTO> users;
    private final OnUserClickListener listener;

    public interface OnUserClickListener {
        void onUserClick(ChatContactDTO user);
    }

    public ChatUserAdapter(List<ChatContactDTO> users, OnUserClickListener listener) {
        this.users = users;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_chat_user, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ChatContactDTO user = users.get(position);
        holder.tvUserName.setText(user.getName());
        holder.tvUserRole.setText(user.getRole() != null ? user.getRole() : "CONTACT");
        
        // Initials logic
        String name = user.getName();
        String initials = "??";
        if (name != null && !name.isEmpty()) {
            String[] parts = name.split(" ");
            if (parts.length >= 2) {
                initials = (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
            } else {
                initials = name.substring(0, Math.min(2, name.length())).toUpperCase();
            }
        }
        holder.tvInitials.setText(initials);
        
        // Online status dot (not in DTO, hidden by default or used for some other logic)
        holder.statusDot.setVisibility(View.GONE);

        // Avatar (not in DTO)
        holder.ivAvatar.setVisibility(View.GONE);

        holder.itemView.setOnClickListener(v -> listener.onUserClick(user));
    }

    @Override
    public int getItemCount() {
        return users.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvUserName, tvUserRole, tvInitials;
        ImageView ivAvatar;
        View statusDot;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvUserName = itemView.findViewById(R.id.tvUserName);
            tvUserRole = itemView.findViewById(R.id.tvUserRole);
            tvInitials = itemView.findViewById(R.id.tvInitials);
            ivAvatar = itemView.findViewById(R.id.ivAvatar);
            statusDot = itemView.findViewById(R.id.statusDot);
        }
    }
}
