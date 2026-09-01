package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class SalesOfficerRequestDTO {
    private Long id;
    private String address;
    private String nidNumber;
    private String dob; // String input for standard formatting handler
    private String gender; // MALE, FEMALE, OTHER
    private String joiningDate; // "YYYY-MM-DD"
    private String designation;
    private String language; // BANGLA, ENGLISH
    private Long policeStationId;

    // Auth User Shared Fields
    private String name;
    private String email;
    private String phone;
    private String password;

}