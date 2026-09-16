package com.example.SCM.dto.response;

import com.example.SCM.enumClass.QuotationStatus;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class QuotationResponseDTO {
    private Long id;
    private String quotationNumber;
    private LocalDate validUntil;
    private int leadTimeDays;
    private LocalDate receivedAt;
    private QuotationStatus status;
    private String productDescription;
    private double unitPrice;
    private int quantity;
    private double totalPrice;              // (unitPrice * quantity)
    private LocalDate deliveryTime;
    private String warranty;
    private String notes;
    private String attachmentUrl;
    private LocalDateTime createdAt;

    // Flattened Supplier Details
    private Long supplierId;
    private String supplierName;
    private String email;

    // Auto-loaded via Purchase Requisition Framework
    private Long productIds;
    private String productName;

    // Flattened Purchase Requisition Details
    private Long purchaseRequisitionId;
}