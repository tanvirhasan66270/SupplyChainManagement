package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class ChangePasswordRequestDTO {
    private String currentPassword;
    private String newPassword;
}
