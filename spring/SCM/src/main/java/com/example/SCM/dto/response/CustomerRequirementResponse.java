package com.example.SCM.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerRequirementResponse {
    private Long id;
    private String productName;
    private String productDescription;
    private String customerName;
    private String contactNumber;
    private String email;
    private String status;
    private LocalDateTime createdAt;
}
