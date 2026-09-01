package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class LCBankResponseDTO {
    private Long id;
    private String name;
    private String swiftCode;
    private String branchName;
    private String address;
    private String contactEmail;
    private String contactPhone;
    private String createdAt;
    private String updatedAt;
}