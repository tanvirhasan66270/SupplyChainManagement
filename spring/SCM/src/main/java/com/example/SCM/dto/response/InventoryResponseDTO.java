package com.example.SCM.dto.response;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class InventoryResponseDTO {
    private Long id;

    // Product Details
    private Long productId;
    private String productCode;
    private String productName;

    // Warehouse Details
    private Long warehouseId;
    private String warehouseName;

    // Inventory Core Fields
    private int quantityOnHand;
    private int quantityReserved;
    private int availableQuantity; // (quantityOnHand - quantityReserved)
    private String locationStatus;
    private LocalDate expiryDate;
    private String stockStatus;
    private LocalDateTime lastUpdated;
}
