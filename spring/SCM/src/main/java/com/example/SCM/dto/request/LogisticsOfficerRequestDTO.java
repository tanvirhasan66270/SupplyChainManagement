package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class LogisticsOfficerRequestDTO {
    private Long id;
    private String contactPerson;
    private String address;
    private String nidNumber;
    private String passportNumber;
    private String dob; // Multi-format parsing handler
    private String gender; // MALE, FEMALE, OTHER
    private String joiningDate; // "YYYY-MM-DD"
    private String designation;
    private String language; // BANGLA, ENGLISH
    private Long policeStationId;

    // Auth User System Mapping
    private String name;
    private String email;
    private String phone;
    private String password;
}