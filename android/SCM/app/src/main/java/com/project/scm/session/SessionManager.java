package com.project.scm.session;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.gson.Gson;
import com.project.scm.model.response.CustomerResponseDTO;
import com.project.scm.model.response.LoginResponseDTO;

public class SessionManager {
    private static final String PREF_NAME = "courier_pref";

    private static final String TOKEN = "token";
    private static final String USER = "user";
    private static final String CUSTOMER = "customer";

    private final SharedPreferences preferences;

    private final Gson gson = new Gson();

    public SessionManager(Context context){

        preferences =
                context.getSharedPreferences(PREF_NAME,Context.MODE_PRIVATE);

    }

    //=========================
    // TOKEN
    //=========================

    public void saveToken(String token){

        preferences.edit().putString(TOKEN,token).apply();

    }

    public String getToken(){

        return preferences.getString(TOKEN,null);

    }

    //=========================
    // USER
    //=========================

    public void saveUser(LoginResponseDTO user){

        preferences.edit()
                .putString(USER,gson.toJson(user))
                .apply();

    }

    public LoginResponseDTO getUser(){

        String json=preferences.getString(USER,null);

        if(json==null)
            return null;

        return gson.fromJson(json,LoginResponseDTO.class);

    }

    //=========================
    // CUSTOMER
    //=========================

    public void saveCustomer(CustomerResponseDTO customer){

        preferences.edit()
                .putString(CUSTOMER,gson.toJson(customer))
                .apply();

    }

    public CustomerResponseDTO getCustomer(){

        String json=preferences.getString(CUSTOMER,null);

        if(json==null)
            return null;

        return gson.fromJson(json,CustomerResponseDTO.class);

    }

    public boolean isLoggedIn(){

        return getToken()!=null;

    }

    public void logout(){

        preferences.edit().clear().apply();

    }
}
