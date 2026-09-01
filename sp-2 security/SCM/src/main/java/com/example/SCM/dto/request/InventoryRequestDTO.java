package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class InventoryRequestDTO {
    private Long productId;
    private Long warehouseId;
    private int quantityOnHand;
    private int quantityReserved;
    private String locationStatus;
    private String expiryDate;
    private String stockStatus;
}
