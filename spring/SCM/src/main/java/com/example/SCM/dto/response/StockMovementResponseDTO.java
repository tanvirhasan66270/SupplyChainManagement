package com.example.SCM.dto.response;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class StockMovementResponseDTO {
    private Long id;

    private Long productId;
    private String productName;

    private Long warehouseId;
    private String warehouseName;

    private Long sourceWarehouseId;
    private String sourceWarehouseName;

    private String movementType;
    private int quantity;
    private String referenceId;

    private Long performedBy;
    private String performedByName;

    private LocalDateTime movedAt;
    private String remarks;
}