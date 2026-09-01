package com.example.SCM.dto.response;

import lombok.Data;

@Data
public class GRNLineItemResponseDTO {
    private Long id;
    private int quantityOrdered;
    private int quantityReceived;


    private Long grnId;
    private String grnNumber;

    private Long productId;
    private String productName;
}