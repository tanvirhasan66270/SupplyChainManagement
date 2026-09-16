package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class PoliceStationResponseDTO {
    private Long id;
    private String name;
    private String nameBn;
    private String postalCode;
    private Boolean active;

    //  Flattened Location Details for UI Grid ---
    private Long districtId;
    private String districtName;
    private String divisionName;
    private String countryName;
}