package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class DistrictRequestDTO {
    private Long id;
    private String name;
    private String nameBn;
    private String districtCode;
    private Boolean active;
    private Long divisionId;
}