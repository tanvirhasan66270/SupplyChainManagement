package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class QuotationRequestDTO {
    private Long supplierId;
    private Long purchaseRequisitionId;
    private int leadTimeDays;
    private String receivedAt;              // "YYYY-MM-DD"
    private String status;                  // "PENDING", "UNDER_REVIEW"
    private String productDescription;
    private double unitPrice;
    private int quantity;
    private String deliveryTime;            // "YYYY-MM-DD"
    private String warranty;
    private String notes;
    private String attachmentUrl;
}