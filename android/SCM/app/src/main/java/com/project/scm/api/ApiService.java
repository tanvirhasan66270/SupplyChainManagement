package com.project.scm.api;

import com.project.scm.model.request.LoginRequestDTO;
import com.project.scm.model.request.MessageRequestDTO;
import com.project.scm.model.response.ChatContactDTO;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.model.response.LoginResponseDTO;
import com.project.scm.model.response.ProductResponseDTO;
import com.project.scm.model.response.InvoiceResponseDTO;
import com.project.scm.model.response.MessageResponseDTO;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface ApiService {
    @POST("api/auth/login")
    Call<LoginResponseDTO> login(@Body LoginRequestDTO request);

    @GET("api/customer/user/{id}")
    Call<CustomerResponseDTO> getCustomerByUserId(@Path("id") Long id);

    @GET("api/customerOrders")
    Call<List<com.project.scm.model.response.CustomerOrderResponseDTO>> getAllCustomerOrders();

    @GET("api/customerOrders/track")
    Call<com.project.scm.model.response.CustomerOrderResponseDTO> trackOrder(@Query("orderNumber") String orderNumber);

    @POST("api/customerOrders")
    Call<com.project.scm.model.response.CustomerOrderResponseDTO> createOrder(@Body com.project.scm.model.request.CustomerOrderRequestDTO dto);

    @GET("api/products")
    Call<List<ProductResponseDTO>> getAllProducts();

    @GET("api/invoices")
    Call<List<InvoiceResponseDTO>> getAllInvoices();

    @GET("api/messages/chatlist")
    Call<List<ChatContactDTO>> getChatlist(@Header("X-User-Id") String userId);

    @GET("api/messages/history")
    Call<List<MessageResponseDTO>> getChatHistory(
            @Header("X-User-Id") String userId,
            @Query("contactId") String contactId
    );

    @POST("api/messages")
    Call<List<MessageResponseDTO>> sendMessage(
            @Header("X-User-Id") String userId,
            @Body MessageRequestDTO request
    );
}
