package com.example.SCM.dto.response;

import com.example.SCM.role.Role;
import lombok.Data;

@Data
public class AdminResponse {
    private Long id;
    private String name;
    private String phone;
    private String email;
    private Long userId;
    private String phoneNumber;
    private boolean active;
    private Role role;
}