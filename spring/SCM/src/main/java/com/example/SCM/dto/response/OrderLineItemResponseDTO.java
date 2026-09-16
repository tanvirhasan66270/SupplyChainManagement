package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class OrderLineItemResponseDTO {
    private Long id;
    private Long productId;
    private String productName;
    private String productCode;
    private int quantity;
    private double unitPrice;
    private double lineTotal;
    private double itemWeightTotal;
    private String remarks;
}