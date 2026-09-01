package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class GRNLineItemRequestDTO {
    private Long id;
    private Long grnId;             // FK -> GoodsReceivedNote
    private Long productId;         // FK -> Product
    private int quantityOrdered;
    private int quantityReceived;
}