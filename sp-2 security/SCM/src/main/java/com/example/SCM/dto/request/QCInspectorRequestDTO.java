package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class QCInspectorRequestDTO {
    //  User (Auth) Fields ---
    private String name;
    private String email;
    private String phone;
    private String password;
    private boolean userActive;

    // QC Inspector Profile Fields ---
    private String contactPerson;
    private String address;
    private String nidNumber;
    private String passportNumber;
    private String dob;
    private String gender;         // MALE, FEMALE, OTHERS
    private String image;
    private String joiningDate;    // "YYYY-MM-DD"
    private String designation;
    private String language;       // BANGLA, ENGLISH, OTHERS
    private Long policeStationId;
}