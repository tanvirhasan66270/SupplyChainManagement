package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class SupplierRequestDTO {


    private String name;
    private String email;
    private String phone;
    private String password;



    private String contactPerson;
    private String address;
    private String nidNumber;
    private String passportNumber;
    private String gender;    // MALE / FEMALE / OTHER
    private String dob;       // e.g., "1999-10-10"
    private String image;     // Base64 string or image path
    private double rating;
    private int averageLeadTimeDays;


    private Long policeStationId;


}
