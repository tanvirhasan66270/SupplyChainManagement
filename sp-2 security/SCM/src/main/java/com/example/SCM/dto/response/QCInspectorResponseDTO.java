package com.example.SCM.dto.response;

import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.example.SCM.role.Role;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class QCInspectorResponseDTO {
    private Long id;
    private String contactPerson;
    private String address;
    private String nidNumber;
    private String passportNumber;
    private LocalDate dob;
    private GenderStatus gender;
    private String image;
    private LocalDate joiningDate;
    private String designation;
    private LanguageStatus language;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Flattened User (Source of Truth) Details ---
    private Long userId;
    private String name;
    private String email;
    private String phone;
    private Role role;
    private boolean userActive;

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