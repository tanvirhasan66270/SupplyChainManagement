package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class DivisionRequestDTO {
    private Long id;
    private String name;
    private String nameBn;
    private Boolean active;
    private Long countryId;
}