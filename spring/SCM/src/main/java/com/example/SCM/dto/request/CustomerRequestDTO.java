package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class CustomerRequestDTO {

    private String name;
   private String email;
    private String phone;
    private String password;
    private String address;
    private String gender;
    private String dob;
    private String nidNumber;
    private Long policeStationId;

}