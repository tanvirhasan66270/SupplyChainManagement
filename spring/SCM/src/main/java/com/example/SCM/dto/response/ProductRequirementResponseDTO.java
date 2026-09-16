package com.example.SCM.dto.response;

import com.example.SCM.enumClass.ProductRequestStatus;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ProductRequirementResponseDTO {

    private Long id;
    private String requestReferenceNo;
    private String customerOrderNumber;
    private String productName;
    private String description;
    private int requestedQuantity;
    private String unit;
    private String targetPriceRange;
    private String urgencyLevel;
    private ProductRequestStatus status;
    private Long requestedByOfficerId;
    private String requestedByOfficerName;
    private String procurementRemarks;
    private LocalDateTime createdAt;
}
