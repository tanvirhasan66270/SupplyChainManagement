package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class CommercialOfficerRequestDTO {
    private Long id;
    private String address;
    private String nidNumber;
    private String passportNumber;
    private String dob;
    private String gender;
    private String joiningDate;
    private String designation;
    private String language;
    private Long policeStationId;

    // Auth User Fields
    private String name;
    private String email;
    private String phone;
    private String password;
}