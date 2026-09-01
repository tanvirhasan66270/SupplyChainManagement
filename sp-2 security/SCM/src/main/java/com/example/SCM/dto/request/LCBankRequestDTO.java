package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class LCBankRequestDTO {
    private String name;
    private String swiftCode;
    private String branchName;
    private String address;
    private String contactEmail;
    private String contactPhone;
}