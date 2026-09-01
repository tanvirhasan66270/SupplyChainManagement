package com.project.scm.repository;

import android.content.Context;

import com.project.scm.api.ApiClient;
import com.project.scm.api.ApiService;
import com.project.scm.model.response.CustomerResponseDTO;

import retrofit2.Call;
import retrofit2.Callback;

public class CustomerRepository {
    private final ApiService apiService;

    public CustomerRepository(Context context) {
        apiService = ApiClient.getClient(context);
    }

    public void getCustomerByUserId(Long userId,
                                    Callback<CustomerResponseDTO> callback) {

        Call<CustomerResponseDTO> call =
                apiService.getCustomerByUserId(userId);

        call.enqueue(callback);

    }
}
