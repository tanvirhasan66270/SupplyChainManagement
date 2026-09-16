package com.example.SCM.dto.request;
import lombok.Data;

@Data
public class AdminRequest {
    private String name;
    private String email;
    private String phone;
    private String password;

}