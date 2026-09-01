package com.example.SCM.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerRequirementRequest {
    private String productName;
    private String productDescription;
    private String customerName;
    private String contactNumber;
    private String email;
}
