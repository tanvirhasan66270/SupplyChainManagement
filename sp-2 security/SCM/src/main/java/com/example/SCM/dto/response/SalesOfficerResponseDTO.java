package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class SalesOfficerResponseDTO {
    private Long id;
    private String address;
    private String nidNumber;
    private LocalDate dob;
    private String gender;
    private String image;
    private LocalDate joiningDate;
    private String designation;
    private String language;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


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

    // Flattened Security Core User Details
    private Long userId;
    private String name;
    private String email;
    private String phone;
    private String role;
}