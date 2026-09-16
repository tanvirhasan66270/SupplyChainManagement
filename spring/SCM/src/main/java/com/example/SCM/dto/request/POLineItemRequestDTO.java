package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class POLineItemRequestDTO {

    private Long poId;
    private Long productId;
    private int quantity;
    private double unitPrice;
    private String quotationRef;
    private String poNumber;
    private String deliveryDate; // "YYYY-MM-DD"
    private String shipmentMethod;
    private String notes;
    private String status;       // "PENDING", "SHIPPED", "CANCELLED"
}