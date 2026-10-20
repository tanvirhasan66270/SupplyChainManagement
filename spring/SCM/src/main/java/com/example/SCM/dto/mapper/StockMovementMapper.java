package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.StockMovementRequestDTO;
import com.example.SCM.dto.response.StockMovementResponseDTO;
import com.example.SCM.entity.Product;
import com.example.SCM.entity.StockMovement;
import com.example.SCM.entity.User;
import com.example.SCM.entity.Warehouse;
import com.example.SCM.enumClass.StockMovementType;
import org.springframework.stereotype.Component;

@Component
public class StockMovementMapper {

    public StockMovement toEntity(StockMovementRequestDTO dto, Product product, Warehouse warehouse, Warehouse sourceWarehouse, User performer) {
        if (dto == null) return null;

        StockMovement entity = new StockMovement();

        entity.setProduct(product);
        entity.setWarehouse(warehouse);
        entity.setSourceWarehouse(sourceWarehouse);
        entity.setPerformedBy(performer);

        entity.setQuantity(dto.getQuantity());
        entity.setReferenceId(dto.getReferenceId());
        entity.setRemarks(dto.getRemarks());

        if (dto.getMovementType() != null && !dto.getMovementType().trim().isEmpty()) {
            entity.setMovementType(StockMovementType.valueOf(dto.getMovementType().toUpperCase()));
        }

        return entity;
    }


    public StockMovementResponseDTO convertTOResponseDTO(StockMovement entity) {
        if (entity == null) return null;

        StockMovementResponseDTO dto = new StockMovementResponseDTO();
        dto.setId(entity.getId());
        dto.setQuantity(entity.getQuantity());
        dto.setReferenceId(entity.getReferenceId());
        dto.setMovedAt(entity.getMovedAt());
        dto.setRemarks(entity.getRemarks());

        if (entity.getMovementType() != null) {
            dto.setMovementType(entity.getMovementType().name());
        }

        if (entity.getProduct() != null) {
            dto.setProductId(entity.getProduct().getId());
            dto.setProductName(entity.getProduct().getName());
        }

        if (entity.getWarehouse() != null) {
            dto.setWarehouseId(entity.getWarehouse().getId());
            dto.setWarehouseName(entity.getWarehouse().getName());
        }

        if (entity.getSourceWarehouse() != null) {
            dto.setSourceWarehouseId(entity.getSourceWarehouse().getId());
            dto.setSourceWarehouseName(entity.getSourceWarehouse().getName());
        }

        if (entity.getPerformedBy() != null) {
            dto.setPerformedBy(entity.getPerformedBy().getId());
            dto.setPerformedByName(entity.getPerformedBy().getName());
        }

        return dto;
    }
}