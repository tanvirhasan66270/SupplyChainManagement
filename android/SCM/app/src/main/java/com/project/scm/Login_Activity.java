package com.project.scm;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.textfield.TextInputEditText;

import com.project.scm.model.request.LoginRequestDTO;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.model.response.LoginResponseDTO;
import com.project.scm.repository.AuthRepository;
import com.project.scm.repository.CustomerRepository;
import com.project.scm.session.SessionManager;

import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class Login_Activity extends AppCompatActivity {
    private String email, password;
    private Button loginBtn;
    private TextInputEditText emailTxt, passwordTxt;
    private AuthRepository authRepository;
    private CustomerRepository customerRepository;
    private SessionManager sessionManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);

        bindView();

        authRepository = new AuthRepository(this);
        customerRepository = new CustomerRepository(this);
        sessionManager = new SessionManager(this);

        loginBtn.setOnClickListener(v -> login());

    }

    private void bindView(){
        emailTxt = findViewById(R.id.email);
        passwordTxt = findViewById(R.id.password);
        loginBtn = findViewById(R.id.btnLogin);

    }

    private void login(){
        email = Objects.requireNonNull(emailTxt.getText()).toString().trim();
        password = Objects.requireNonNull(passwordTxt.getText()).toString().trim();

        if (email.isEmpty()) {
            emailTxt.setError("Email is required");
            emailTxt.requestFocus();
            return;
        }

        if (password.isEmpty()) {
            passwordTxt.setError("Password is required");
            passwordTxt.requestFocus();
            return;
        }

        LoginRequestDTO dto = new LoginRequestDTO();
        dto.setEmail(email);
        dto.setPassword(password);

        loginBtn.setEnabled(false);

        authRepository.login(dto, new Callback<LoginResponseDTO>() {
            @Override
            public void onResponse(@NonNull Call<LoginResponseDTO> call, @NonNull Response<LoginResponseDTO> response) {
                if (response.isSuccessful() && response.body() != null) {
                    LoginResponseDTO responseDTO = response.body();
                    sessionManager.saveUser(responseDTO);
                    sessionManager.saveToken(responseDTO.getToken());
                    
                    // Now fetch customer profile before navigating
                    getCustomer(responseDTO.getUserId());
                    
                } else {
                    loginBtn.setEnabled(true);
                    Toast.makeText(getApplicationContext(), "Login failed: Invalid credentials", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<LoginResponseDTO> call, @NonNull Throwable t) {
                loginBtn.setEnabled(true);
                Toast.makeText(getApplicationContext(), "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });

    }

    private void getCustomer(Long id){
        customerRepository.getCustomerByUserId(id, new Callback<CustomerResponseDTO>() {
            @Override
            public void onResponse(@NonNull Call<CustomerResponseDTO> call, @NonNull Response<CustomerResponseDTO> response) {
                if (response.isSuccessful() && response.body() != null) {
                    CustomerResponseDTO ct = response.body();
                    sessionManager.saveCustomer(ct);
                } else {
                    Toast.makeText(getApplicationContext(), "Failed to fetch profile data", Toast.LENGTH_SHORT).show();
                }
                
                // Navigate to dashboard regardless of whether profile fetch succeeded 
                // (as long as login was successful)
                navigateToDashboard();
            }

            @Override
            public void onFailure(@NonNull Call<CustomerResponseDTO> call, @NonNull Throwable throwable) {
                Toast.makeText(getApplicationContext(), "Network error while fetching profile", Toast.LENGTH_SHORT).show();
                navigateToDashboard();
            }
        });
    }

    private void navigateToDashboard() {
        Toast.makeText(getApplicationContext(), "Logged in successfully", Toast.LENGTH_SHORT).show();
        Intent intent = new Intent(Login_Activity.this, Dashboard_Activity.class);
        startActivity(intent);
        finish();
    }
}