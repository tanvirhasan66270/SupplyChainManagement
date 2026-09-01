package com.project.scm.repository;

import android.content.Context;

import com.project.scm.api.ApiClient;
import com.project.scm.api.ApiService;

import retrofit2.Call;
import retrofit2.Callback;
import com.project.scm.model.request.LoginRequestDTO;
import com.project.scm.model.response.LoginResponseDTO;

public class AuthRepository {
    private final ApiService apiService;

    public AuthRepository(Context context) {
        apiService = ApiClient.getClient(context);
    }

    public void login(LoginRequestDTO request,
                      Callback<LoginResponseDTO> callback) {

        Call<LoginResponseDTO> call = apiService.login(request);

        call.enqueue(callback);
    }
}
