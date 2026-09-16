package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.ProductRequirementRequestDTO;
import com.example.SCM.dto.response.ProductRequirementResponseDTO;
import com.example.SCM.entity.ProductRequirement;
import com.example.SCM.enumClass.ProductRequestStatus;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class ProductRequirementMapper {

    public ProductRequirement toEntity(ProductRequirementRequestDTO dto) {
        if (dto == null) return null;

        ProductRequirement entity = new ProductRequirement();
        // Auto-generate unique reference number
        entity.setRequestReferenceNo("PRQ-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        entity.setCustomerOrderNumber(dto.getCustomerOrderNumber());
        entity.setProductName(dto.getProductName());
        entity.setDescription(dto.getDescription());
        entity.setRequestedQuantity(dto.getRequestedQuantity());
        entity.setUnit(dto.getUnit());
        entity.setTargetPriceRange(dto.getTargetPriceRange());
        entity.setUrgencyLevel(dto.getUrgencyLevel());
        entity.setRequestedByOfficerId(dto.getRequestedByOfficerId());
        entity.setRequestedByOfficerName(dto.getRequestedByOfficerName());
        entity.setProcurementRemarks(dto.getProcurementRemarks());
        entity.setStatus(ProductRequestStatus.PENDING);
        return entity;
    }

    public ProductRequirementResponseDTO toResponseDTO(ProductRequirement entity) {
        if (entity == null) return null;

        ProductRequirementResponseDTO dto = new ProductRequirementResponseDTO();
        dto.setId(entity.getId());
        dto.setRequestReferenceNo(entity.getRequestReferenceNo());
        dto.setCustomerOrderNumber(entity.getCustomerOrderNumber());
        dto.setProductName(entity.getProductName());
        dto.setDescription(entity.getDescription());
        dto.setRequestedQuantity(entity.getRequestedQuantity());
        dto.setUnit(entity.getUnit());
        dto.setTargetPriceRange(entity.getTargetPriceRange());
        dto.setUrgencyLevel(entity.getUrgencyLevel());
        dto.setStatus(entity.getStatus());
        dto.setRequestedByOfficerId(entity.getRequestedByOfficerId());
        dto.setRequestedByOfficerName(entity.getRequestedByOfficerName());
        dto.setProcurementRemarks(entity.getProcurementRemarks());
        dto.setCreatedAt(entity.getCreatedAt());
        return dto;
    }

    public void updateEntity(ProductRequirementRequestDTO dto, ProductRequirement entity) {
        if (dto == null || entity == null) return;

        if (dto.getCustomerOrderNumber() != null) entity.setCustomerOrderNumber(dto.getCustomerOrderNumber());
        if (dto.getProductName() != null)         entity.setProductName(dto.getProductName());
        if (dto.getDescription() != null)         entity.setDescription(dto.getDescription());
        entity.setRequestedQuantity(dto.getRequestedQuantity());
        if (dto.getUnit() != null)                entity.setUnit(dto.getUnit());
        if (dto.getTargetPriceRange() != null)    entity.setTargetPriceRange(dto.getTargetPriceRange());
        if (dto.getUrgencyLevel() != null)        entity.setUrgencyLevel(dto.getUrgencyLevel());
        if (dto.getProcurementRemarks() != null)  entity.setProcurementRemarks(dto.getProcurementRemarks());
        if (dto.getStatus() != null) {
            entity.setStatus(ProductRequestStatus.valueOf(dto.getStatus().toUpperCase()));
        }
        if (dto.getRequestedByOfficerId() != null)   entity.setRequestedByOfficerId(dto.getRequestedByOfficerId());
        if (dto.getRequestedByOfficerName() != null) entity.setRequestedByOfficerName(dto.getRequestedByOfficerName());
    }
}
