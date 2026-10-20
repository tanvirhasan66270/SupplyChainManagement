package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class LogisticsOfficerResponseDTO {
    private Long id;
    private String contactPerson;
    private String address;
    private String nidNumber;
    private String passportNumber;
    private LocalDate dob;
    private String gender;
    private String image;
    private LocalDate joiningDate;
    private String designation;
    private String language;
     private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Auth User Flattened Details
    private Long userId;
    private String name;
    private String email;
    private String phone;
    private String role;

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