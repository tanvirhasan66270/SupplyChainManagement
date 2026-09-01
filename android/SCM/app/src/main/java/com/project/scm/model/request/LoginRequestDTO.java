package com.project.scm.model.request;


import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

public class LoginRequestDTO {
    private String email;
    private String password;
}