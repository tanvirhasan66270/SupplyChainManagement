package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class ResetPasswordRequestDTO {

    private String token;
    private String newPassword;
}