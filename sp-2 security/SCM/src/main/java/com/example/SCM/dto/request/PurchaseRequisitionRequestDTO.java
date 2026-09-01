package com.example.SCM.dto.request;

import lombok.Data;
import java.util.List;

@Data
public class PurchaseRequisitionRequestDTO {
    private Long requestedBy;
    private List<Long> productIds;
    private List<Long> supplierIds;
    private String currency;        // "USD"
    private int quantityRequired;
    private String urgencyLevel;    // "HIGH", "CRITICAL"
    private String requiredByDate;  // "YYYY-MM-DD"
    private String remarks;
}