package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class StockMovementResponseDTO {
    private Long id;

    // Product Details Flattened
    private Long productId;
    private String productName;

    // Target/Destination Warehouse Details Flattened
    private Long warehouseId;
    private String warehouseName;

    // Source Warehouse Details (Only for TRANSFER type)
    private Long sourceWarehouseId;
    private String sourceWarehouseName;

    private String movementType;
    private int quantity;
    private String referenceId;

    // Performed By Personnel Flattened
    private Long performedBy;
    private String performedByName;

    private LocalDateTime movedAt;
    private String remarks;
}