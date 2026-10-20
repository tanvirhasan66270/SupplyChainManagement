package com.project.scm;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.project.scm.adaptor.ChatMessageAdapter;
import com.project.scm.adaptor.ChatUserAdapter;
import com.project.scm.api.ApiClient;
import com.project.scm.api.ApiService;
import com.project.scm.model.request.MessageRequestDTO;
import com.project.scm.model.response.ChatContactDTO;
import com.project.scm.model.response.LoginResponseDTO;
import com.project.scm.model.response.MessageResponseDTO;
import com.project.scm.session.SessionManager;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class SupportDesk extends AppCompatActivity {

    private RecyclerView rvContacts, rvMessages;
    private ChatUserAdapter contactAdapter;
    private ChatMessageAdapter messageAdapter;
    private final List<ChatContactDTO> contactList = new ArrayList<>();
    private final List<ChatContactDTO> filteredContactList = new ArrayList<>();
    private final List<MessageResponseDTO> messageList = new ArrayList<>();

    private View containerPlaceholder, containerChat;
    private TextView tvActiveChatName, tvActiveChatStatus;
    private EditText etMessage;
    private ChatContactDTO activeContact;

    private ApiService apiService;
    private String currentUserId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_support_desk);

        apiService = ApiClient.getClient(this);
        SessionManager sessionManager = new SessionManager(this);
        LoginResponseDTO user = sessionManager.getUser();
        if (user != null && user.getUserId() != null) {
            currentUserId = String.valueOf(user.getUserId());
        } else {
            Toast.makeText(this, "Session error", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        View mainView = findViewById(R.id.main);
        View header = findViewById(R.id.header);

        ViewCompat.setOnApplyWindowInsetsListener(mainView, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            header.setPadding(header.getPaddingLeft(), systemBars.top, header.getPaddingRight(), header.getPaddingBottom());
            return insets;
        });

        bindViews();
        setupContacts();
        setupChat();
        setupListeners();

        loadChatlist();
    }

    private void bindViews() {
        rvContacts = findViewById(R.id.rvContacts);
        rvMessages = findViewById(R.id.rvMessages);
        containerPlaceholder = findViewById(R.id.containerPlaceholder);
        containerChat = findViewById(R.id.containerChat);
        tvActiveChatName = findViewById(R.id.tvActiveChatName);
        tvActiveChatStatus = findViewById(R.id.tvActiveChatStatus);
        etMessage = findViewById(R.id.etMessage);

        findViewById(R.id.btnHome).setOnClickListener(v -> {
            startActivity(new Intent(this, Dashboard_Activity.class));
            finish();
        });
    }

    private void setupContacts() {
        rvContacts.setLayoutManager(new LinearLayoutManager(this));
        contactAdapter = new ChatUserAdapter(filteredContactList, this::openChat);
        rvContacts.setAdapter(contactAdapter);

        EditText etSearch = findViewById(R.id.etSearchContacts);
        etSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                filterContacts(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void loadChatlist() {
        apiService.getChatlist(currentUserId).enqueue(new Callback<List<ChatContactDTO>>() {
            @Override
            public void onResponse(@NonNull Call<List<ChatContactDTO>> call, @NonNull Response<List<ChatContactDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    contactList.clear();
                    contactList.addAll(response.body());
                    filterContacts("");
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<ChatContactDTO>> call, @NonNull Throwable t) {
                Toast.makeText(SupportDesk.this, "Failed to load contacts", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void filterContacts(String query) {
        filteredContactList.clear();
        if (query.isEmpty()) {
            filteredContactList.addAll(contactList);
        } else {
            for (ChatContactDTO user : contactList) {
                if (user.getName() != null && user.getName().toLowerCase().contains(query.toLowerCase())) {
                    filteredContactList.add(user);
                }
            }
        }
        contactAdapter.notifyDataSetChanged();
    }

    private void setupChat() {
        // Use a reverse LinearLayoutManager to show newest messages at the bottom
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        rvMessages.setLayoutManager(layoutManager);
        messageAdapter = new ChatMessageAdapter(messageList, currentUserId);
        rvMessages.setAdapter(messageAdapter);
    }

    private void openChat(ChatContactDTO contact) {
        activeContact = contact;
        containerPlaceholder.setVisibility(View.GONE);
        containerChat.setVisibility(View.VISIBLE);
        
        tvActiveChatName.setText(contact.getName());
        tvActiveChatStatus.setText("Support Active");
        tvActiveChatStatus.setTextColor(getResources().getColor(R.color.blue_primary));

        loadChatHistory(String.valueOf(contact.getId()));
    }

    private void loadChatHistory(String contactId) {
        apiService.getChatHistory(currentUserId, contactId).enqueue(new Callback<List<MessageResponseDTO>>() {
            @Override
            public void onResponse(@NonNull Call<List<MessageResponseDTO>> call, @NonNull Response<List<MessageResponseDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    messageList.clear();
                    messageList.addAll(response.body());
                    messageAdapter.notifyDataSetChanged();
                    if (!messageList.isEmpty()) {
                        rvMessages.scrollToPosition(messageList.size() - 1);
                    }
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<MessageResponseDTO>> call, @NonNull Throwable t) {
                Toast.makeText(SupportDesk.this, "Failed to load history", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void setupListeners() {
        findViewById(R.id.btnSend).setOnClickListener(v -> sendMessage());
    }

    private void sendMessage() {
        String content = etMessage.getText().toString().trim();
        if (content.isEmpty() || activeContact == null) return;

        MessageRequestDTO dto = new MessageRequestDTO();
        dto.setRecipientId(String.valueOf(activeContact.getId()));
        dto.setBody(content);
        dto.setSubject("Chat Message");
        dto.setPriority("NORMAL");

        apiService.sendMessage(currentUserId, dto).enqueue(new Callback<List<MessageResponseDTO>>() {
            @Override
            public void onResponse(@NonNull Call<List<MessageResponseDTO>> call, @NonNull Response<List<MessageResponseDTO>> response) {
                if (response.isSuccessful() && response.body() != null) {
                    messageList.clear();
                    messageList.addAll(response.body());
                    messageAdapter.notifyDataSetChanged();
                    rvMessages.scrollToPosition(messageList.size() - 1);
                    etMessage.setText("");
                } else {
                    Toast.makeText(SupportDesk.this, "Failed to send message", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<MessageResponseDTO>> call, @NonNull Throwable t) {
                Toast.makeText(SupportDesk.this, "Error sending message", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
