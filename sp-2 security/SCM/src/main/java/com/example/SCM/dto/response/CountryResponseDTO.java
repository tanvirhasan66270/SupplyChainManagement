package com.example.SCM.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class CountryResponseDTO {
    private Long id;
    private String name;
    private String code;
    private String phoneCode;
    private Boolean active;


    private List<String> divisions;
}