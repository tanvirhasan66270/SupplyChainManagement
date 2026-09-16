package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class CustomerResponseDTO {

    private Long id;
    private Long userId;

    private String name;
    private String email;
    private String phone;
    private String role;

    private String address;
    private String gender;
    private String dob;
    private String nidNumber;
    private String image;
    private String createdAt;

    // Location IDs
    private Long countryId;
    private Long divisionId;
    private Long districtId;
    private Long policeStationId;

    // Location Names
    private String countryName;
    private String divisionName;
    private String districtName;
    private String policeStationName;
}