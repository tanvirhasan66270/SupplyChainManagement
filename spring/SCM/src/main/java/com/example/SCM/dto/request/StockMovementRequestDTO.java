package com.example.SCM.dto.request;

import lombok.Data;

@Data
public class StockMovementRequestDTO {
    private Long productId;
    private Long warehouseId;
    private Long sourceWarehouseId;
    private String movementType;    // INWARD, OUTWARD, TRANSFER, ADJUSTMENT
    private int quantity;
    private String referenceId;     // GRN-Code, Invoice-Code, etc.
    private Long performedBy;
    private String remarks;
}