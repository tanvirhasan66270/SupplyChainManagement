package com.example.SCM.dto.response;

import com.example.SCM.enumClass.PurchaseOrderStatus;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class PurchaseOrderResponseDTO {
    private Long id;
    private String poNumber;
    private Integer quantity;
    private double totalAmount;
    private String currency;
    private LocalDate expectedDeliveryDate;
    private PurchaseOrderStatus status;
    private Long issuedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    //Auto Loaded Supplier Details
    private Long supplierId;
    private String supplierName;
    private String supplierEmail;

    //Auto Loaded Purchase Requisition Details
    private Long purchaseRequisitionId;

    //Quotation Connection Details
    private Long quotationId;

    private java.util.List<Long> productIds;
    private java.util.List<String> productNames;
}
