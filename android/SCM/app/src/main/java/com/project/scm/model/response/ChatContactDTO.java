package com.project.scm.model.response;

import lombok.Data;

@Data
public class ChatContactDTO {
    private Long id;
    private String name;
    private String email;
    private String role;
    private String phoneNumber;
}
