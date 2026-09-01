package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class CountryRequestDTO {
    private Long id;
    private String name;
    private String code;
    private String phoneCode;
    private Boolean active;
}
