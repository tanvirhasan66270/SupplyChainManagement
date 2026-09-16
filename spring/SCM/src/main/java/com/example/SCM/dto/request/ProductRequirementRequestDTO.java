package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class ProductRequirementRequestDTO {

    private String customerOrderNumber;
    private String productName;
    private String description;
    private int requestedQuantity;
    private String unit;
    private String targetPriceRange;
    private String urgencyLevel;          // LOW, MEDIUM, HIGH, URGENT
    private String status;                // PENDING, APPROVED, REJECTED, PROCESSING
    private Long requestedByOfficerId;
    private String requestedByOfficerName;
    private String procurementRemarks;
}
